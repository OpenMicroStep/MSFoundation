/*
 
 _MHServerPrivate.m
 
 This file is is a part of the MicroStep Application Server over Http Framework.
 
 Initial copyright LOGITUD Solutions (logitud@logitud.fr) since 2012
 
 Herve Malaingre : herve@malaingre.com
 Jean-Michel Bertheas :  jean-michel.bertheas@club-internet.fr
 
 
 This software is a computer program whose purpose is to [describe
 functionalities and technical features of your software].
 
 This software is governed by the CeCILL-C license under French law and
 abiding by the rules of distribution of free software.  You can  use, 
 modify and/ or redistribute the software under the terms of the CeCILL-C
 license as circulated by CEA, CNRS and INRIA at the following URL
 "http://www.cecill.info". 
 
 As a counterpart to the access to the source code and  rights to copy,
 modify and redistribute granted by the license, users are provided only
 with a limited warranty  and the software's author,  the holder of the
 economic rights,  and the successive licensors  have only  limited
 liability. 
 
 In this respect, the user's attention is drawn to the risks associated
 with loading,  using,  modifying and/or developing or reproducing the
 software by the user in light of its specific status of free software,
 that may mean  that it is complicated to manipulate,  and  that  also
 therefore means  that it is reserved for developers  and  experienced
 professionals having in-depth computer knowledge. Users are therefore
 encouraged to load and test the software's suitability as regards their
 requirements in conditions enabling the security of their systems and/or
 data to be ensured and,  more generally, to use and operate it in the 
 same conditions as regards security. 
 
 The fact that you are presently reading this means that you have had
 knowledge of the CeCILL-C license and that you accept its terms.
 
 */

#import "MSNet_Private.h"
//#import <openssl/err.h>
//#import <openssl/rand.h>
//#import <openssl/evp.h>
//#import <openssl/ssl.h>

#ifdef WO451
@interface MHThreadFakeLauncher : NSObject
- (void)fakeLaunch:(id)parameters ;
@end
#endif

#define MASH_SERVER_NAME @"MASHServer"
#define MH_NET_REPOSITORY_SERVER_NAME @"MHNetRepository"

#define MAX_NB_HEADERS 10   // maximum number of headers we look at
#define ACCEPT_TIMEOUT 5
#define RECV_TIMEOUT 5    // timeout in s for the client to give us a response
#define MAX_FD_PER_SELECT 32

#define HTTP_200_OK "HTTP/1.1 200 OK\r\n"
#define HTTP_301_MOVED_PERMANENTLY "HTTP/1.1 301 Moved Permanently\r\n"
#define HTTP_302_FOUND "HTTP/1.1 302 Found\r\n"
#define HTTP_304_NOT_MODIFIED "HTTP/1.1 304 Not Modified\r\n"
#define HTTP_307_TEMPORARY_REDIRECT "HTTP/1.1 307 Temporary Redirect\r\n"
#define HTTP_400_MALFORMED "HTTP/1.1 400 Malformed Request\r\n"
#define HTTP_401_UNAUTHORIZED "HTTP/1.1 401 Not Authorized\r\n"
#define HTTP_403_FORBIDDEN "HTTP/1.1 403 Forbidden\r\n"
#define HTTP_404_NOT_FOUND "HTTP/1.1 404 Not found\r\n"
#define HTTP_405_NOT_ALLOWED "HTTP/1.1 405 Method Not Allowed\r\n"
#define HTTP_408_REQUEST_TIMEOUT "HTTP/1.1 408 Request Timeout\r\n"
#define HTTP_500_INTERNAL_SERVER_ERROR "HTTP/1.1 500 Internal Server Error\r\n"
#define HTTP_501_NOT_IMPLEMENTED "HTTP/1.1 501 Not Implemented\r\n"
#define HTTP_503_NOT_AVAILABLE "HTTP/1.1 503 Service Unavailable\r\n"

static Class __staticApplication = nil ;
static MSUInt __baseUrlComponentsCount ;
static NSString *__serverName = nil ;

//response headers
//static NSString *__header_mash_auth_get_session = @"MASH_AUTH_GET_SESSION" ;
static NSString *__header_mash_session_id       = @"Set-Cookie" ;
static NSString *__header_mash_context_id       = @"MASH_CONTEXT_ID" ;

//server configuration
static NSString *__mashRoot ;

#define DEFAULT_SERVER_PORT 443
static NSString *__serverCertificate = nil ;
static NSString *__serverPrivateKey = nil ;
static NSString *__serverLogFile = nil ;

static NSDictionary *__netRepositoryConfigurations = nil ;

static NSMapTable *__applicationsByPort = NULL ;
static MSMutableArray *__applications = nil ;

static NSMutableArray *__applicationsInfos = nil ;
static mutex_t __applicationsMutex ;

static NSMapTable *__sessions = NULL ;
static mutex_t __sessionsMutex ;

static NSMapTable *__sessionContexts = NULL ;
static mutex_t __sessionContextsMutex ;

static NSMapTable *__resourcesCache = NULL ;
static mutex_t __resourcesCacheMutex ;

static NSMapTable *__authenticationTickets = NULL ;
static mutex_t __authenticationTicketsMutex ;

static unsigned int __currentUploadId = 0 ;

//administration application configuration
#define DEFAULT_ADMIN_PORT  444
static MSInt __adminPort = 0 ;
static NSString *__adminLogin = nil ;
static NSString *__adminPassword = nil ;

static mutex_t __blacklist_mutex ; // mutex to access the IP blacklist
static ip_log __iplist[BLACKLIST_SIZE] = {{0,0}} ;
static unsigned long __blacklist[BLACKLIST_SIZE] = {0} ;
static int __blacklist_idx = 0 ;
static MSUInt __whitelist[WHITELIST_SIZE] = {0} ;
static BOOL __disableBlacklist = NO ;

#define MINI_RESOURCE_SIZE_FOR_COMPRESSION  1048576
static BOOL __disableDeflateCompression = NO ;

static MSLong __ssl_options = 0 ;
static char *__certificateFile = 0 ;
static char *__keyFile = 0 ;

//Client reading threads pool management
#define DEFAULT_MAX_CLIENT_READING_THREADS     4
#define MAX_REQUEST_PER_PERIOD 400
#define BLACKLIST_SLEEP_TIME 15 // check the blacklist every 15 seconds
static event_t __newClientConnectionAccepted;  // Event to report a new client connection
static mutex_t __client_accept_mutex ; // mutex for critical section on socket accepts
static MSMutableNaturalArray *__waitingAcceptedClientSockets ;
static MSUShort __maxClientReadingThreads ;
static MSUShort __usedClientReadingThreads ;
//static mutex_t __unusedClientReadingThreadsMutex ;

#define DEFAULT_MAX_CLIENT_PROCESSING_THREADS  4
#define DEFAULT_MAX_CLIENT_PROCESSING_REQUESTS 64
static MHQueue *__clientProcessingQueue ;
static MSUInt __maxClientProcessingRequests = 0 ;
static MSUShort __maxClientProcessingThreads ;
static MSUShort __usedClientProcessingThreads ;
static MSUInt __currentClientProcessingRequestCount = 0;
//static mutex_t __unusedClientProcessingThreadsMutex ;
static event_t __newClientProcessingQueueEntry ;
static mutex_t __clientProcessingQueueMutex ;

static MHQueue *__clientWaitingQueue ;
static MSUShort __maxClientWaitingThreads ;
static MSUShort __usedClientWaitingThreads ;
static event_t __newClientWaitingQueueEntry ;
static mutex_t __clientWaitingQueueMutex ;
//static mutex_t __unusedClientWaitingThreadsMutex ;

static CElementPool *__clientNotificationsPool = NULL ;

//Admin reading threads pool management
#define DEFAULT_ADMIN_READING_THREADS         2
static event_t __newAdminConnectionAccepted;  // Event to report a new admin connection
static mutex_t __admin_accept_mutex ; // mutex for critical section on socket accepts
static MSMutableNaturalArray *__waitingAcceptedAdminSockets ;
static MSUShort __maxAdminReadingThreads ;
static MSUShort __usedAdminReadingThreads ;
//static mutex_t __unusedAdminReadingThreadsMutex ;

#define DEFAULT_MAX_ADMIN_PROCESSING_REQUESTS 16
#define DEFAULT_ADMIN_PROCESSING_THREADS      2
static MHQueue *__adminProcessingQueue ;
static MSUInt __maxAdminProcessingRequests = 0 ;
static MSUShort __maxAdminProcessingThreads ;
static MSUShort __usedAdminProcessingThreads ;
static MSUInt __currentAdminProcessingRequestCount = 0;
//static mutex_t __unusedAdminProcessingThreadsMutex ;
static event_t __newAdminProcessingQueueEntry ;
static mutex_t __adminProcessingQueueMutex ;

static MHQueue *__adminWaitingQueue ;
static MSUShort __maxAdminWaitingThreads ;
static MSUShort __usedAdminWaitingThreads ;
static event_t __newAdminWaitingQueueEntry ;
static mutex_t __adminWaitingQueueMutex ;
//static mutex_t __unusedAdminWaitingThreadsMutex ;

static CElementPool *__adminNotificationsPool = NULL ;

static MHAdminApplication *__adminApplication = nil ;

#define MAX_ACCEPT_COUNT_BEFORE_CLEAN   5

static MHLogging *__logger = nil ;

//configuration file parameters
static NSDictionary *__parameters = nil ;
static NSMutableDictionary *__bundlesConfig = nil ;
static NSString *__temporaryFolderPath ;
NSMutableDictionary *MHBundlesConfig() { return __bundlesConfig ; }

typedef callback_t(* MHThreadMainFunctionProto)(void *) ;

MSUInt maxClientProcessingRequests() { return __maxClientProcessingRequests ; }
MSUInt currentClientProcessingRequestCount() { return __currentClientProcessingRequestCount ; } 
MSUShort maxClientReadingThreads() { return __maxClientReadingThreads ; } 
MSUShort usedClientReadingThreads() { return __usedClientReadingThreads ; } 
MSUShort maxClientProcessingThreads() { return __maxClientProcessingThreads ; } 
MSUShort usedClientProcessingThreads() { return __usedClientProcessingThreads ; } 
MSUShort maxClientWaitingThreads() { return __maxClientWaitingThreads ; } 
MSUShort usedClientWaitingThreads() { return __usedClientWaitingThreads ; } 

MSInt adminPort() { return __adminPort ; }
MSUInt maxAdminProcessingRequests() { return __maxAdminProcessingRequests ; }
MSUInt currentAdminProcessingRequestCount() { return __currentAdminProcessingRequestCount ; } 
MSUShort maxAdminReadingThreads() { return __maxAdminReadingThreads ; } 
MSUShort usedAdminReadingThreads() { return __usedAdminReadingThreads ; } 
MSUShort maxAdminProcessingThreads() { return __maxAdminProcessingThreads ; } 
MSUShort usedAdminProcessingThreads() { return __usedAdminProcessingThreads ; } 
MSUShort maxAdminWaitingThreads() { return __maxAdminWaitingThreads ; } 
MSUShort usedAdminWaitingThreads() { return __usedAdminWaitingThreads ; }

void decreaseCurrentClientProcessingRequestCount(void) ;
void decreaseCurrentAdminProcessingRequestCount(void) ;

static NSComparisonResult compareNumbers(id obj1, id obj2, void *c)
{
    NSNumber *n1 = (NSNumber *)obj1 ;
    NSNumber *n2 = (NSNumber *)obj2 ;
    
    return [n1 compare:n2] ;
}

static MSInt _MHCreateNewThreadPool(MSShort nbThreads, MHThreadMainFunctionProto threadFunction, char *info, void *isAdmin)
{
    MSShort i ;
    thread_t thread ;

    MH_LOG_ENTER(@"_MHCreateNewThreadPool") ;
    // Launch our threadpool
    for (i=0; i<nbThreads; i++)
    {
        if(thread_create(thread, threadFunction, isAdmin) == -1)
        {
            if (info) MHServerLogWithLevel(MHLogCritical, @"Error occured while creating thread #%d (%s)", i, info) ; 
            else MHServerLogWithLevel(MHLogCritical, @"Error occured while creating thread #%d", i) ;
            return EXIT_FAILURE;
        }
        //fprintf(stdout, "START %s -> #%d\n", info, i);
    }
    
    MH_LOG_LEAVE(@"_MHCreateNewThreadPool") ;
    return EXIT_SUCCESS ;
}

// Send a HTTP error message
// return -1, doesn't close the connection neither the thread
// don't care about _MHProcessingDequeue exception occured issues
static void _send_error_message(MHSSLSocket *secureSocket, const char *error_msg)
{
    if (![secureSocket writeBytes:error_msg length:(int)strlen(error_msg)])
    {
        MHServerLogWithLevel(MHLogError, @"ERROR RESPONSE NOT RETURNED ON CLIENT (KO) %d", [secureSocket socket]) ;
    }
    
    [secureSocket close] ;
}

// Display error message on stderr and exit
void _fatal_error(const char *msg, int errcode)
{
#ifdef WIN32
    char *lpMsgBuf;
    
    lpMsgBuf = (LPVOID)"Unknown error";
    if (FormatMessageA(
                       FORMAT_MESSAGE_ALLOCATE_BUFFER |
                       FORMAT_MESSAGE_FROM_SYSTEM |
                       FORMAT_MESSAGE_IGNORE_INSERTS,
                       NULL, errcode,
                       MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                       (LPTSTR)&lpMsgBuf, 0, NULL))
    {
        MHServerLogWithLevel(MHLogCritical, @"%s: Error %d: %s", msg, errcode, lpMsgBuf) ;
        LocalFree(lpMsgBuf);
    } else
        MHServerLogWithLevel(MHLogCritical, @"%s: Error %d", msg, errcode) ;
#else
    MHServerLogWithLevel(MHLogCritical, @"%s (cerrno #%d: %s)", msg, errcode, strerror(errcode)) ;
#endif
}

static MSTimeInterval MHModifiedSinceTimeIntervalFromMessage(MHHTTPMessage *message)
{
    NSString *ifModifiedSince = [message getHeader:MHHTTPIfModifiedSince] ;
    if (ifModifiedSince) {
        NSArray *httpDateComponents = [ifModifiedSince componentsSeparatedByString:@" "] ;
        //Example : 'Thu, 16-Aug-2012 15:42:13 GMT'
        if ([httpDateComponents count] == 4) {
            NSString *tz = [httpDateComponents objectAtIndex:3] ;
            if ([@"GMT" isEqual:[tz uppercaseString]]) {
                MSTimeInterval result = 0 ;
                NSString *date = [httpDateComponents objectAtIndex:1] ;
                NSString *time = [httpDateComponents objectAtIndex:2] ;
                NSArray *dateComponents = [date componentsSeparatedByString:@"-"] ;
                NSArray *timeComponents = [time componentsSeparatedByString:@":"] ;
                MSUInt month = 0 ;
                
                NS_DURING
                NSString *uppMonthStr = [[dateComponents objectAtIndex:1] uppercaseString] ;

                if      ([@"JAN" isEqual:uppMonthStr]) month = 1 ;
                else if ([@"FEB" isEqual:uppMonthStr]) month = 2 ;
                else if ([@"MAR" isEqual:uppMonthStr]) month = 3 ;
                else if ([@"APR" isEqual:uppMonthStr]) month = 4 ;
                else if ([@"MAY" isEqual:uppMonthStr]) month = 5 ;
                else if ([@"JUN" isEqual:uppMonthStr]) month = 6 ;
                else if ([@"JUL" isEqual:uppMonthStr]) month = 7 ;
                else if ([@"AUG" isEqual:uppMonthStr]) month = 8 ;
                else if ([@"SEP" isEqual:uppMonthStr]) month = 9 ;
                else if ([@"OCT" isEqual:uppMonthStr]) month = 10 ;
                else if ([@"NOV" isEqual:uppMonthStr]) month = 11 ;
                else if ([@"DEC" isEqual:uppMonthStr]) month = 12 ;
                    
                result= GMTWithYMDHMS(
                  (unsigned)[[dateComponents objectAtIndex:2] intValue],
                  month,
                  (unsigned)[[dateComponents objectAtIndex:0] intValue],
                  (unsigned)[[timeComponents objectAtIndex:0] intValue],
                  (unsigned)[[timeComponents objectAtIndex:1] intValue],
                  (unsigned)[[timeComponents objectAtIndex:2] intValue]);
                NS_HANDLER
                NS_ENDHANDLER
                
                return result ;
            }
        }        
    }
    return 0 ;
}

static MHApplication *_MHApplicationForURLAndPort(NSString *url, MSInt listeningPort, MSUInt baseUrlComponentCount)
{
    NSString *urlWithoutQueryParams = [url containsString:@"?"] ? [url substringBeforeString:@"?"] : url ;
    NSArray *urlComponents = [urlWithoutQueryParams componentsSeparatedByString:@"/"] ;
    
    if ([urlComponents count] >= baseUrlComponentCount) {
        
        switch(baseUrlComponentCount)
        {
            case BASE_URL_COMPONENT_COUNT_BUNDLE_MODE :
                return applicationForPortAndKey(listeningPort,
                                                [NSString stringWithFormat:@"%@/%@/%@/",
                                                 [urlComponents objectAtIndex:0], //client URL subpart
                                                 [urlComponents objectAtIndex:1], //service URL subpart
                                                 [urlComponents objectAtIndex:2]]) ; //application instance URL subpart
                
            case BASE_URL_COMPONENT_COUNT_STATIC_MODE :
                return applicationForPortAndKey(listeningPort,
                                                [NSString stringWithFormat:@"%@/",
                                                 [urlComponents objectAtIndex:0]]) ; //application instance URL subpart
            default : break ;
        }
    }
    return nil ;
}

static NSArray *_MHGUIApplicationsForPort(MSInt listeningPort, MSUInt baseUrlComponentCount)
{
    NSMutableArray *guiAppsInfos = [NSMutableArray array] ;
    NSEnumerator *appsInfosEnum = [__applicationsInfos objectEnumerator] ;
    NSDictionary *appInfo = nil ;
    MHApplication *application = nil ;
    MSUInt appPort = 0 ;
    
    while ((appInfo = [appsInfosEnum nextObject]))
    {
        application = [appInfo objectForKey:@"application"] ;
        appPort = [[appInfo objectForKey:@"listeningPort"] intValue] ;
        
        if(appPort == listeningPort && [application isKindOfClass:[MHGUIApplication class]])
        {
            [guiAppsInfos addObject:appInfo] ;
        }
    }
    return guiAppsInfos ;
}

static MHHTTPMessage *_receive_http_message(MHSSLSocket *secureSocket)
{
    char buf[MH_HTTP_MAX_HEADERS_SIZE];
    MSInt len ;
    char *head_end;
    char *body;
    // Boundary string for upload requests (multipart)
    char boundary[73] = "--";
    MSASCIIString * url = nil ;
    
    MH_LOG_ENTER(@"_receive_http_message") ;
    
    len = [secureSocket readHeadersIn:buf length:(MH_HTTP_MAX_HEADERS_SIZE - 1)];
    if(len == -1) {
        MH_LOG_LEAVE(@"_receive_http_message") ;
        return nil;
    }
    
    // Minimum size for an HTTP request
    if(len < 14)
    {
        MHServerLogWithLevel(MHLogWarning, @"Request is too small") ;
        _send_error_message(secureSocket, HTTP_400_RESPONSE);
        MH_LOG_LEAVE(@"_receive_http_message") ;
        return nil ;
    }
    // End the buffer string so we can use str functions
    buf[len] = '\0'; len++ ;
    // Look for the end of headers
    head_end = strstr(buf, "\r\n\r\n");
    if(!head_end)
    {
        MHServerLogWithLevel(MHLogError, @"Received a malformed request : No head end!") ;
        _send_error_message(secureSocket, HTTP_400_RESPONSE);
        MH_LOG_LEAVE(@"_receive_http_message") ;
        return nil ;
    }
    
    body = head_end + 4;
    // No body
    if(body >= buf + len) body = NULL;
    
    if(!strncmp(buf, "HEAD /", 6))
    {
        MHRespondToClientOnSocket(secureSocket, nil, HTTPOK, NO);
        MH_LOG_LEAVE(@"_receive_http_message") ;
        return nil ;
    }
    else if (!strncmp(buf, "GET /", 5))
    {
        MH_LOG_LEAVE(@"_receive_http_message") ;
        return [MHHTTPMessage retainedMessageFromSocket:secureSocket withBytes:buf length:len lastMessage:NULL] ;
    }
    else if (!strncmp(buf, "POST /", 6)) {
        unsigned long long body_length = 0;
        char *token = strstr(buf, "\r\n");
        char * url_end = strchr(buf + 6, 32);
        
        if(token > url_end)
        {
            url = [MSASCIIString stringWithBytes:(buf + 6) length:(url_end - buf - 6)] ;
        }
        else
        {
            // Should not happen : no protocol specified
            MHServerLogWithLevel(MHLogError, @"Received a malformed request : no body length on POST message!") ;
            _send_error_message(secureSocket, HTTP_400_RESPONSE);   
            MH_LOG_LEAVE(@"_receive_http_message") ;
            return nil ;
        }

        while (token && token < head_end)
        {
            token += 2 ;
            if(!strncasecmp(token, "Content-Length: ", 16)) {
                body_length = CStrToULongLong(token + 16, NULL);
            }
            // A file has been sent through an upload form
            else if(!strncasecmp(token, "Content-Type: multipart/form-data; boundary=", 44)) {
                char * ptr = token + 44;
                char * end = strstr(ptr, "\r\n");
                if(end)
                {
                    int boundary_length = (int)(end - ptr);
                    /* The only mandatory parameter for the multipart Content-Type is the boundary parameter,
                     which consists of 1 to 70 characters from a set of characters known to be very robust
                     through email gateways, and NOT ending with white space. */
                    if(boundary_length < 71) strncpy(boundary + 2, ptr, boundary_length);
                    boundary[boundary_length + 2] = 0;
                    MHServerLogWithLevel(MHLogDevel, @"multipart boundary : '%s'", boundary) ;
                }
            }
            token = strstr(token, "\r\n");
        }
        
        if(!body_length) {
            MHServerLogWithLevel(MHLogError, @"Received a malformed request : no body length on POST message!") ;
            _send_error_message(secureSocket, HTTP_400_RESPONSE);   
            MH_LOG_LEAVE(@"_receive_http_message") ;
            return nil ;
        }
        else {
            unsigned long long current_body_length = buf + len - body - 1;
            MSULong boundaryLength = strlen(boundary) ;
            
            if(current_body_length > body_length)
            {
                MHServerLogWithLevel(MHLogError, @"Received a malformed request : too long body on POST message!") ;
                _send_error_message(secureSocket, HTTP_400_RESPONSE);   
                MH_LOG_LEAVE(@"_receive_http_message") ;
                return nil ;
            }
            else if(boundaryLength > 2)
            {
                // !! UPLOAD !!
                MHApplication *application = _MHApplicationForURLAndPort(url, [secureSocket localPort], __baseUrlComponentsCount) ;
                if(![application hasUploadSupport])
                {
                    MHServerLogWithLevel(MHLogError, @"Received a invalid request : the application does not have UPLOAD support") ;
                    _send_error_message(secureSocket, HTTP_501_RESPONSE);   
                    MH_LOG_LEAVE(@"_receive_http_message") ;
                    return nil ;
                }
                
                // Fast check on body length
                if(body_length < (boundaryLength * 2) + 4)
                {
                    MHServerLogWithLevel(MHLogError, @"Received a malformed request : too short body on multipart POST message!") ;
                    _send_error_message(secureSocket, HTTP_400_RESPONSE);   
                    MH_LOG_LEAVE(@"_receive_http_message") ;
                    return nil ;
                }
                else
                {
                    char body_buffer[MH_HTTP_MAX_HEADERS_SIZE];
                    unsigned long body_length_to_read = body_length - current_body_length;
                    NSString * queryString = [url substringAfterString:@"?"] ;
                    NSString * uploadID = nil ;
                    NSString *upResourceURL ;
                    MHUploadResource *upResourceFromCache ;
                    
                    if(queryString)
                    {
                        NSArray * kvPairs = [queryString componentsSeparatedByString:@"&"] ;
                        NSEnumerator * enu = [kvPairs objectEnumerator] ;
                        NSString * kv = nil ;
                        
                        while ((kv = [enu nextObject]))
                        {
                            if([kv containsString:@"="])
                            {
                                NSArray * pair = [kv componentsSeparatedByString:@"="] ;
                                if([(NSString*)[pair objectAtIndex:0] isEqualToString:@"id"])
                                {
                                    uploadID = [pair objectAtIndex:1] ;
                                }
                            }
                        }
                    }
                    
                    if(!uploadID)
                    {
                        MHServerLogWithLevel(MHLogError, @"Received a invalid upload submission : missing upload ID parameter") ;
                        _send_error_message(secureSocket, HTTP_400_RESPONSE);   
                        MH_LOG_LEAVE(@"_receive_http_message") ;
                        return nil ;
                    }
                    
                    //get upload resource from resouces cache
                    upResourceURL = MHGetUploadResourceURLForID(application, uploadID) ; // /ville/group/app/upload/ID
                    
                    lock_resources_mutex() ;
                    upResourceFromCache = (MHUploadResource *)resourceForKey(upResourceURL) ;
                    unlock_resources_mutex() ;
                    
                    if(!upResourceFromCache)
                    {
                        MHServerLogWithLevel(MHLogError, @"Invalid upload submission : no resource found in cache for url :'%@'", upResourceURL) ;
                        _send_error_message(secureSocket, HTTP_500_INTERNAL_SERVER_ERROR);
                        MH_LOG_LEAVE(@"_receive_http_message") ;
                        return nil ;
                    }

                    
                    if(!current_body_length)
                    {
                        len = [secureSocket readIn:body_buffer length:(int)MIN(body_length_to_read, MH_HTTP_MAX_HEADERS_SIZE)] ;
                        if(len == 1)
                        {
                            // Fix for Chrome
                            len += [secureSocket readIn:body_buffer+1 length:(int)MIN(body_length_to_read, MH_HTTP_MAX_HEADERS_SIZE) - 1] ;
                        }
                        MHServerLogWithLevel(MHLogDevel, @"Received %d bytes from file upload : '%.*s'", len, len, body_buffer) ;
                        body = body_buffer;
                        current_body_length = len ;
                    }
                    else
                    {
                        len -= body - buf + 1 ;
                    }
                    
                    if(!strncmp(body, boundary, boundaryLength))
                    {
                        // Boundary + CRLF
                        char * ptr = body + boundaryLength + 2;

                        if(!strncasecmp(ptr, "Content-Disposition: form-data; name=\"", 38))
                        {
                            ptr += 38;
                            ptr = strstr(ptr, "\"; filename=\"");
                            if(ptr)
                            {
                                char * filename_end;
                                ptr += 13;
                                filename_end = strstr(ptr, "\"\r\n") ;
                                
                                if(filename_end)
                                {
                                    // First copy the file's name
                                    int filename_length = (int) (filename_end - ptr);
                                    char * filename_ptr = malloc(filename_length + 1); //allocated pointer
                                    char * filename = filename_ptr ; //can be altered
                                    char *lastPathComponentPos = NULL ;
                                    unsigned char boundary_end_mark[75] ;
                                    // We use a double-sized buffer in order to search our boundary end mark
                                    unsigned char AB[MH_HTTP_MAX_HEADERS_SIZE*2];
                                    int x;
                                    BOOL finished = NO;
                                    BOOL error = NO;
                                    const unsigned char * position;
                                    MHHTTPMessage *message = nil;
                                                                       
                                    strncpy(filename, ptr, filename_length);
                                    filename[filename_length] = 0;
                                    MHServerLogWithLevel(MHLogDevel, @"Starting upload of file %s.", filename) ;

                                    snprintf((char*)boundary_end_mark, boundaryLength + 4, "\r\n%s--", boundary);
                                    boundary_end_mark[boundaryLength + 4] = 0 ;
                                    
                                    // Next get the content of the file. Now we have to work on binary data
                                    ptr = strstr(filename_end, "\r\n\r\n") + 4;
                                    x = (int) (body + len - ptr);
                                    MHServerLogWithLevel(MHLogDevel, @"Put %d bytes from file upload in buffer", x) ;
                                    memmove(AB, ptr, x);                                   
                                    
                                    //we make sure to have a single filename as opposed to path/filename or path\filename
                                    if((lastPathComponentPos = strrchr(filename,'\\'))) { filename = lastPathComponentPos+1 ; }
                                    else if((lastPathComponentPos = strrchr(filename,'/'))) { filename = lastPathComponentPos+1 ; }
                                    
                                    //upload : set name and expected size BEFORE writing any data
                                    [upResourceFromCache setName:[NSString stringWithCString:filename encoding:NSUTF8StringEncoding]] ;
                                    [upResourceFromCache setExpectedSize:body_length] ;
                                    
                                    if(body_length - current_body_length <= 0) finished = YES ;
                                    
                                    while(YES)
                                    {
                                        while(!finished)
                                        {
                                            // Try to fill our double-sized buffer
                                            len = [secureSocket readIn:AB + x length:MH_HTTP_MAX_HEADERS_SIZE*2 - x] ;
                                            MHServerLogWithLevel(MHLogDevel, @"Received %d bytes from file upload", len) ;
                                            if(len <= 0)
                                            {
                                                // No more data
                                                finished = YES;
                                                break;
                                            }
                                            current_body_length += len;
                                            x += len;
                                            if(x == MH_HTTP_MAX_HEADERS_SIZE*2)
                                            {
                                                // The buffer is full
                                                break;
                                            }
                                            if(body_length - current_body_length <= 0)
                                            {
                                                MHServerLogWithLevel(MHLogDevel, @"Receive the full HTTP body") ;
                                                finished = YES ;
                                                break;
                                            }
                                        }
                                       
                                        position = bmh_memmem(AB, x, boundary_end_mark, strlen((char*)boundary_end_mark));

                                        if(!position)
                                        {
                                            // boundary end mark not found
                                            if(!finished)
                                            {
                                                // AB is filled
                                                //upload : write first part of the buffer to disk
                                                if(! [upResourceFromCache addBytes:AB length:MH_HTTP_MAX_HEADERS_SIZE boundaryLength:0])
                                                {
                                                    MHServerLogWithLevel(MHLogError, @"Unable to write to temporary file %@ (%lu bytes to write)", [upResourceFromCache resourcePathOndisk], MH_HTTP_MAX_HEADERS_SIZE) ;
                                                    _send_error_message(secureSocket, HTTP_500_INTERNAL_SERVER_ERROR);
                                                    MH_LOG_LEAVE(@"_receive_http_message") ;
                                                    return nil ;
                                                }                                              
                                                memmove(AB, AB + MH_HTTP_MAX_HEADERS_SIZE, MH_HTTP_MAX_HEADERS_SIZE);
                                                
                                            }
                                            else
                                            {
                                                // No more data on the socket and boundary end mark not found :(
                                                error = YES;
                                                break;
                                            }
                                        }
                                        else
                                        {
                                            //upload : end mark found :)
                                            // write the end of the file and exit the loop
                                            MHServerLogWithLevel(MHLogDevel, @"Boundary end mark found !", len) ;

                                            if(![upResourceFromCache addBytes:AB length:position - AB boundaryLength:(boundaryLength-2)])
                                            {
                                                MHServerLogWithLevel(MHLogError, @"Unable to write to temporary file %@ (%lu bytes to write)", [upResourceFromCache resourcePathOndisk], position - AB) ;
                                                _send_error_message(secureSocket, HTTP_500_INTERNAL_SERVER_ERROR);
                                                MH_LOG_LEAVE(@"_receive_http_message") ;
                                                return nil ;
                                            }
                                            
                                            
                                            break;
                                        }
                                        x = MH_HTTP_MAX_HEADERS_SIZE;
                                    }

                                    if(error)
                                    {                                       
                                        [upResourceFromCache setStatus:UPLOAD_ERROR] ;
                                        MHServerLogWithLevel(MHLogError, @"No more data on the socket and boundary end mark not found") ;
                                        _send_error_message(secureSocket, HTTP_500_RESPONSE);
                                    }
                                    else
                                    {
                                        [upResourceFromCache setStatus:UPLOAD_COMPLETED] ;
                                        // We reuse buf to create a smaller MHMessage with POST method and two headers with filenames
                                        ptr = strstr(buf, "\r\n\r\n") + 2;
                                        memcpy(buf, "POST ", 5);
                                        sprintf(ptr, "MASH_UPLD_FILE_NAME: %s\r\nMASH_UPLD_RSRC_URL: %s\r\n\r\n", filename, [[upResourceFromCache url] UTF8String]);
                                        message = [MHHTTPMessage retainedMessageFromSocket:secureSocket
                                                                                 withBytes:buf
                                                                                    length:(MSUInt)strlen(buf)
                                                                               lastMessage:NULL] ;
                                        MHPutResourceInCache(upResourceFromCache);
                                    }
                                    free(filename_ptr);
                                    return message;
                                }
                            }
                            MHServerLogWithLevel(MHLogError, @"No filename specified for upload") ;
                            _send_error_message(secureSocket, HTTP_400_MALFORMED);
                            MH_LOG_LEAVE(@"_receive_http_message") ;
                            return nil ;
                        }
                    }
                }
            }
            // There is more data to read
            else
            {
                MHHTTPMessage *lastMessage = nil, *message = nil ; 
                unsigned long body_length_to_read = body_length - current_body_length;
                
                if (body_length_to_read == 0) {
                    message = [MHHTTPMessage retainedMessageFromSocket:secureSocket withBytes:buf length:len-1 lastMessage:&lastMessage] ; //does no longer contain 0 terminal
                }
                else {
                    char body_buffer[MH_HTTP_MAX_HEADERS_SIZE];
                    MHHTTPMessage *messageToGrow = nil ;
                    
                    message = [MHHTTPMessage retainedMessageFromSocket:secureSocket withBytes:buf length:len-1 lastMessage:&lastMessage] ; //0 terminal will be added at the end
                    messageToGrow = lastMessage ? lastMessage : message ;
                    
                    while ((body_length_to_read > 0) && (len != SOCKET_ERROR)) {
                        
                        len = [secureSocket readIn:body_buffer length:(int)MIN(body_length_to_read, MH_HTTP_MAX_HEADERS_SIZE)] ;

                        if(len > 0)
                        {
                            MHHTTPMessage *newLastMessage = nil ;
                            [messageToGrow appendBytes:body_buffer length:len lastMessage:&newLastMessage] ;
                            if (newLastMessage) messageToGrow = newLastMessage ;
                            current_body_length += len ;
                        }
                        else {
                            MHServerLogWithLevel(MHLogError ,@"Socket was closed! len = %lu (body_length_to_read = %lu)", len, body_length_to_read) ;
                            MH_LOG_LEAVE(@"_receive_http_message") ;
                            return nil ;
                        }
                        body_length_to_read = body_length - current_body_length;
                    }
                }
                return message ;
            }
        }
    }
/*    else if (!strncmp(buf, "OPTIONS /", 9))
    {
        MHServerLogWithLevel(MHLogDebug ,@"Received an OPTIONS http method") ;
        _send_error_message(secureSocket, HTTP_200_OPTIONS_RESPONSE);
        MH_LOG_LEAVE(@"_receive_http_message") ;
        return nil ;
    }*/

    buf[14] = 0 ;
    MHServerLogWithLevel(MHLogWarning ,@"Received a not implemented http method. Message begins with '%s'", buf) ;
    _send_error_message(secureSocket, HTTP_501_RESPONSE);
    MH_LOG_LEAVE(@"_receive_http_message") ;
    return nil ;
}

static BOOL _MHIsStandardResourceDownload(const MHNotificationType notificationType)
{
    return (notificationType == MHAuthenticatedResourceDownload ||
            notificationType == MHPublicResourceDownload) ;
}

static BOOL _MHIsResourceDownload(const MHNotificationType notificationType)
{
    return (notificationType == MHAuthenticatedResourceDownload ||
            notificationType == MHUncResourceDownload ||
            notificationType == MHPublicResourceDownload) ;
}

static void _MHRunApplicationWithNoSessionGetRequest(MHApplication *application,
                                              MHHTTPMessage *message,
                                              MHNotificationType notificationType,
                                              MHSSLSocket *secureSocket,
                                              NSString *url,
                                              BOOL isAdmin)
{
    MH_LOG_ENTER(@"_MHRunApplicationWithNoSessionGetRequest") ;
    
    if ([application isGUIApplication] &&
        [url isEqualToString:[(MHGUIApplication *)application loginURL]]) // GUI Application requests login page
    {
        MSBuffer *loginInterface = [(MHGUIApplication *)application loginInterfaceWithErrorMessage:nil] ;
        MHRespondToClientOnSocketWithAdditionalHeaders(secureSocket, loginInterface, HTTPOK, isAdmin, nil, nil, NO) ;

    }
    else if ([url isEqualToString:[application baseURL]]) //Authentication
    {
        NSString *headerLogin       = [message getHeader:MHHTTPAuthLogin] ;
        NSString *headerTarget      = [message getHeader:MHHTTPAuthTarget] ;
        NSString *headerURN         = [message getHeader:MHHTTPAuthURN] ;
        
        if([application canAuthenticateWithTicket]
           && [message fastContainsQueryParameterNamed:MHAUTH_QUERY_PARAM_TICKET]) //AUTHENTICATION WITH TICKET
        {
            NSDictionary *queryParameters = [message parameters] ;
            NSString *ticket = [queryParameters objectForKey:MHAUTH_QUERY_PARAM_TICKET] ;
            
            if([ticket length])
            {
                MHNotification *notification = nil ;
                MHSession *session = nil ;
                NSString *linkedSession =  linkedSessionForTicket(application, ticket) ;
                
                if ([linkedSession length]) //Ticket authentication with linked session
                {
                    session = sessionForKey(linkedSession) ;
                    
                    if (session)
                    {
                        notificationType = MHTicketWithLinkedSession ;
                        [session storeMember:ticket named:@"ticket"] ;
                        
                        notification = [MHNotification retainedNotificationWithMessage:message
                                                                               session:session
                                                                        retainedTarget:application
                                                                        retainedAction:@"validateAuthentication:"
                                                                      notificationType:notificationType
                                                                   isAdminNotification:isAdmin] ;
                        
                        [notification storeAuthenticationTicket:ticket] ;
                        MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : TICKET APPLICATION AUTHENTICATION WITH LINKED SESSION : '%@' REQUEST MESSAGE on socket %d", linkedSession, [secureSocket socket]) ;
                        MHProcessingEnqueueNotificationOrSendError() ;
                    } else
                    {
                        MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : TICKET APPLICATION AUTHENTICATION FAILED : NO LINKED SESSION : '%@' on socket %d", linkedSession, [secureSocket socket]) ;
                         _send_error_message(secureSocket, HTTP_401_UNAUTHORIZED);
                    }
                    
                } else //Ticket authentication with new session
                {
                    MHContext *context = MHCreateInitialContextAndSession(application, MHAuthTicket) ;
                    session = [context session] ;
                    [session storeMember:[context contextID] named:@"contextID"] ;
                    [session storeMember:ticket named:@"ticket"] ;
                    
                    notification = [MHNotification retainedNotificationWithMessage:message
                                                                           session:session
                                                                    retainedTarget:application
                                                                    retainedAction:@"validateAuthentication:"
                                                                  notificationType:notificationType
                                                               isAdminNotification:isAdmin] ;
                    
                    [notification storeAuthenticationTicket:ticket] ;
                    MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : TICKET APPLICATION AUTHENTICATION REQUEST MESSAGE on socket %d", [secureSocket socket]) ;
                    MHProcessingEnqueueNotificationOrSendError() ;
                }
            }
            else {
                _send_error_message(secureSocket, HTTP_401_UNAUTHORIZED);
            }
        } else if ([application canAuthenticateWithPKChallenge] && headerURN) // PK CHALLENGE AUTHENTICATION
        {
            NSString *challengeStored = nil ;
            NSMutableDictionary *headers = nil ;
            MSBuffer *response = nil ;
            void *bytes = NULL ;
            MHAppAuthentication authType = MHAuthPKChallengeAndURN ;
            
            //store plain challenge in session
            NSString *challengeSent = [application generatePKChallengeURN:headerURN storedPlainChallenge:&challengeStored] ;
            
            MHContext *context = MHCreateInitialContextAndSession(application, authType) ;
            MHSession *session = [context session] ;
            [session storeMember:[context contextID] named:@"contextID"] ;
            
            if (challengeStored) { [session storeMember:challengeStored named:SESSION_PARAM_CHALLENGE] ; }
            [session storeMember:headerURN named:SESSION_PARAM_URN] ;
            [session changeStatus:MHSessionStatusLoginInterfaceSent] ;
            
            bytes = (void *)[challengeSent UTF8String] ;
            response = AUTORELEASE(MSCreateBufferWithBytesNoCopyNoFree(bytes, strlen(bytes))) ;
            
            MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : CHALLENGE GENERATED for authentication type %@ on socket %d",
                                 MHAuthenticationNameForType(authType),
                                 [secureSocket socket]) ;
            MHRespondToClientOnSocketWithAdditionalHeaders(secureSocket, response, HTTPOK, isAdmin, headers, session, NO) ;
            
        } else if ((headerLogin && [application canAuthenticateWithChallengedPasswordLogin]) ||
                   (headerLogin && headerTarget && [application canAuthenticateWithChallengedPasswordLoginOnTarget])) //CHALLENGED PASSWORD AUTHENTICATION
                    
        {
            MHAppAuthentication authType = headerTarget ? MHAuthChallengedPasswordLoginOnTarget : MHAuthChallengedPasswordLogin ;
            NSMutableDictionary *headers = nil ;
            MSBuffer *response = nil ;
            void *bytes = NULL ;
          
            //store plain challenge in session
            MHContext *context = MHCreateInitialContextAndSession(application, authType) ;
            MHSession *session = [context session] ;
            NSString *challengeSent = [application generateChallengeInfoForLogin:headerLogin withSession:session] ;
            [session storeMember:[context contextID] named:@"contextID"] ;
            if (headerTarget) { [session storeMember:headerTarget named:SESSION_PARAM_TARGET] ; }
            [session storeMember:headerLogin named:SESSION_PARAM_LOGIN] ;
            [session storeMember:challengeSent named:SESSION_PARAM_CHALLENGE] ;
            [session changeStatus:MHSessionStatusLoginInterfaceSent] ;
            
            bytes = (void *)[challengeSent UTF8String] ;
            response = AUTORELEASE(MSCreateBufferWithBytesNoCopyNoFree(bytes, strlen(bytes))) ;
            
            MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : CHALLENGE GENERATED for authentication type %@ on socket %d",
                                 MHAuthenticationNameForType(authType),
                                 [secureSocket socket]) ;
            MHRespondToClientOnSocketWithAdditionalHeaders(secureSocket, response, HTTPOK, isAdmin, headers, session, NO) ;
        }
        else if ([application canAuthenticateWithCustomAuthentication]) //AUTHENTICATION CUSTOM
        {
            MHNotification *notification ;
            MHContext *context = MHCreateInitialContextAndSession(application, MHAuthCustom) ;
            [[context session] storeMember:[context contextID] named:@"contextID"] ;
            
            notification = [MHNotification retainedNotificationWithMessage:message
                                                                   session:[context session]
                                                            retainedTarget:application
                                                            retainedAction:@"validateAuthentication:"
                                                          notificationType:notificationType
                                                       isAdminNotification:isAdmin] ;
            
            [notification storeAuthenticationCustomMode] ;
            MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : CUSTOM APPLICATION AUTHENTICATION REQUEST GET MESSAGE on socket %d", [secureSocket socket]) ;
            MHProcessingEnqueueNotificationOrSendError() ;
            
        }
        else if ([application canHaveNoAuthentication]) //No authentication
        {
            MHNotification *notification ;
            MHContext *context = MHCreateInitialContextAndSession(application, MHAuthNone) ;
            
            
            notification = [MHNotification retainedNotificationWithMessage:message
                                                                   session:[context session]
                                                            retainedTarget:application
                                                            retainedAction:@"awakeOnRequest:"
                                                          notificationType:notificationType
                                                       isAdminNotification:isAdmin] ;
            
            MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : NOT AUTHENTIFIED GET MESSAGE WITH NO SESSION on socket %d", [secureSocket socket]) ;
            MHProcessingEnqueueNotificationOrSendError() ;
        }
        else {
            MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : NOT AUTHENTIFIED GET MESSAGE WITH NO SESSION : could not find a valid authentication method on socket %d", [secureSocket socket]) ;
            _send_error_message(secureSocket, HTTP_401_UNAUTHORIZED) ;
        }
    }
    else {
        MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : NOT AUTHENTIFIED GET MESSAGE WITH NO SESSION : wrong url for authentication on socket %d", [secureSocket socket]) ;
        _send_error_message(secureSocket, HTTP_401_UNAUTHORIZED) ;
    }
    MH_LOG_LEAVE(@"_MHRunApplicationWithNoSessionGetRequest") ;
}


static void _MHRunApplicationWithNoSessionPostRequest(MHApplication *application,
                                               MHHTTPMessage *message,
                                               MHNotificationType notificationType,
                                               MHSSLSocket *secureSocket,
                                               NSString *url,
                                               BOOL isAdmin)
{
    MH_LOG_ENTER(@"_MHRunApplicationWithNoSessionPostRequest") ;
    
    if ([url isEqualToString:[application baseURL]])
    {
        NSString *userLogin = [message parameterNamed:MHGUI_AUTH_FORM_LOGIN] ;
        NSString *userPassword = [message parameterNamed:MHGUI_AUTH_FORM_PASSWORD] ;
        
        if ([application canAuthenticateWithSimpleGUILoginPassword] && [userLogin length] && userPassword) //SimpleGUIAuthentication
        {
            MHNotification *notification ;
            MHContext *context = MHCreateInitialContextAndSession(application, MHAuthSimpleGUIPasswordAndLogin) ;
            [[context session] storeMember:[context contextID] named:@"contextID"] ;
            
            notification = [MHNotification retainedNotificationWithMessage:message
                                                                   session:[context session]
                                                            retainedTarget:application
                                                            retainedAction:@"validateAuthentication:"
                                                          notificationType:notificationType
                                                       isAdminNotification:isAdmin] ;
            
            [notification storeAuthenticationLogin:userLogin andPassword:userPassword authType:MHAuthSimpleGUIPasswordAndLogin] ;
            MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : SIMPLE GUI AUTHENTICATION REQUEST MESSAGE on socket %d", [secureSocket socket]) ;
            MHProcessingEnqueueNotificationOrSendError() ;
        }
        else if ([application canAuthenticateWithCustomAuthentication]) //CUSTOM AUTH POST
        {
            MHNotification *notification ;
            MHContext *context = MHCreateInitialContextAndSession(application, MHAuthCustom) ;
            [[context session] storeMember:[context contextID] named:@"contextID"] ;
            
            notification = [MHNotification retainedNotificationWithMessage:message
                                                                   session:[context session]
                                                            retainedTarget:application
                                                            retainedAction:@"validateAuthentication:"
                                                          notificationType:notificationType
                                                       isAdminNotification:isAdmin] ;
            
            [notification storeAuthenticationCustomMode] ;
            MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : CUSTOM APPLICATION AUTHENTICATION REQUEST POST MESSAGE on socket %d", [secureSocket socket]) ;
            MHProcessingEnqueueNotificationOrSendError() ;
        }
        else if ([application canHaveNoAuthentication]) //No authentication
        {
            MHNotification *notification ;
            MHContext *context = MHCreateInitialContextAndSession(application, MHAuthNone) ;
            
            
            notification = [MHNotification retainedNotificationWithMessage:message
                                                                   session:[context session]
                                                            retainedTarget:application
                                                            retainedAction:@"awakeOnRequest:"
                                                          notificationType:notificationType
                                                       isAdminNotification:isAdmin] ;
            
            MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : NOT AUTHENTIFIED POST MESSAGE WITH NO SESSION on socket %d", [secureSocket socket]) ;
            MHProcessingEnqueueNotificationOrSendError() ;
        }
        else
        {
            MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : NOT AUTHENTIFIED POST MESSAGE WITH NO SESSION : could not find a valid authentication method on socket %d", [secureSocket socket]) ;
            _send_error_message(secureSocket, HTTP_401_UNAUTHORIZED) ;
        }
        
    } else
    {
        MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : NOT AUTHENTIFIED POST MESSAGE WITH NO SESSION : wrong url for authentication on socket %d", [secureSocket socket]) ;
        _send_error_message(secureSocket, HTTP_401_UNAUTHORIZED) ;
    }
    
    MH_LOG_LEAVE(@"_MHRunApplicationWithNoSessionPostRequest") ;
}


static void _MHRunApplicationWithNoSession(MHApplication *application,
                                    MHHTTPMessage *message,
                                    MHNotificationType notificationType,
                                    MHSSLSocket *secureSocket,
                                    NSString *url,
                                    BOOL isAdmin)
{
    BOOL isGetRequest = [message isGetRequest] ;
    MH_LOG_ENTER(@"_MHRunApplicationWithNoSession") ;
    
    if(isGetRequest)
    {
        if(_MHIsResourceDownload(notificationType)) //GET resource is it's a public resource in bundle, else HTTPForbidden
        {
            MHDownloadResource *resource ;
            
            if(notificationType == MHPublicResourceDownload &&
               (resource = MHGetResourceFromCacheOrApplication(url, application, [message contentType], notificationType)))
            {
                MHSendResourceOrHTTPNotModifiedToClientOnSocket(secureSocket, resource, isAdmin, nil, message, nil) ;
            }
            else
            {
                MHContext *context = MHCreateInitialContextAndSession(application, MHAuthNone) ;
                MHNotification *notification = notification = [MHNotification retainedNotificationWithMessage:message
                                                                                                      session:[context session]
                                                                                               retainedTarget:application
                                                                                               retainedAction:@"awakeOnRequest:"
                                                                                             notificationType:notificationType
                                                                                          isAdminNotification:isAdmin] ;
                
                MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : AUTHENTICATED GET PUBLIC RESSOURCE WITH NO SESSION on socket %d", [secureSocket socket]) ;
                MHProcessingEnqueueNotificationOrSendError() ;
            }
        } else //GET message, not on a resource
        {
            _MHRunApplicationWithNoSessionGetRequest(application, message, notificationType, secureSocket, url, isAdmin) ;
        }
    } else //POST message, not on a resource
    {
        _MHRunApplicationWithNoSessionPostRequest(application, message, notificationType, secureSocket, url, isAdmin) ;
    }
    MH_LOG_LEAVE(@"_MHRunApplicationWithNoSession") ;
}

static void _MHRunApplicationWithSession(MHApplication *application,
                                  MHHTTPMessage *message,
                                  MHSession *session,
                                  MHContext *context,
                                  MHNotificationType notificationType,
                                  MHSSLSocket *secureSocket,
                                  NSString *url,
                                  NSArray *urlComponents,
                                  BOOL isAdmin)
{
    MHSessionStatus status = [session status] ;
    BOOL isGetRequest = [message isGetRequest] ;
    BOOL internalSubURLNotFound = YES ;
    MSUInt urlComponentsCount = (MSUInt)[urlComponents count] ;
    MH_LOG_ENTER(@"_MHRunApplicationWithSession") ;
    
    if (isGetRequest)
    {
        if([url hasSuffix:@"getUploadID"]) {
            if([application hasUploadSupport]) { MHReplyWithNewUploadID(secureSocket, application) ; }
            else { MHRespondToClientOnSocket(secureSocket, nil, HTTPUnauthorized, isAdmin) ; }
            internalSubURLNotFound = NO ;
            
        } else if(urlComponentsCount > __baseUrlComponentsCount && [[urlComponents objectAtIndex:__baseUrlComponentsCount] hasPrefix:@"getUploadStatus"]) {
            
            NSString * uploadID = [message parameterNamed:@"id"] ;
            NSDictionary * response = nil ;
            MHUploadResource *upResource = nil ;
            NSDictionary * hdrs = [NSDictionary dictionaryWithObjectsAndKeys:@"no-cache", @"Pragma",
                                   @"no-cache, must-revalidate", @"Cache-Control",
                                   @"application/json", @"Content-Type",
                                   nil] ;
            lock_resources_mutex() ;
            upResource = (MHUploadResource *)resourceForKey([[[url stringByDeletingLastURLComponent] stringByAppendingURLComponent:[MHUploadResource uploadPathComponent]] stringByAppendingURLComponent:uploadID]) ;
            unlock_resources_mutex() ;
            
            if(upResource) {
                response = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInt:[upResource status]], @"upload_status",
                            [NSNumber numberWithUnsignedLongLong:[upResource expectedSize]], @"expected_size",
                            [NSNumber numberWithUnsignedLongLong:[upResource receivedSizeWithBoundary]], @"received_size", nil] ;
            } else {
                response = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:UPLOAD_UNKNOWN_ID ] forKey:@"upload_status"] ;
            }
            MHRespondToClientOnSocketWithAdditionalHeaders(secureSocket, [response MSTEncodedBuffer], HTTPOK, isAdmin, hdrs, nil, NO) ;
            internalSubURLNotFound = NO ;
        } else {
            if(([url rangeOfString:[application postProcessingURL]]).length) {
                MHPreparePostProcess(message, isAdmin) ;
                internalSubURLNotFound = NO ;
            }
        }
    }
    
    if (internalSubURLNotFound) { //no internal sub-url has been found.
        
        if (notificationType == MHPublicResourceDownload) //public resource request
        {
            //get on public resource with session
            MHNotification *notification ;
            MHDownloadResource *resource ;
            BOOL isStandardResourceDownload = _MHIsStandardResourceDownload(notificationType) ;
            
            if(isStandardResourceDownload && (resource = MHGetResourceFromCacheOrApplication(url, application, [message contentType], notificationType)))
            {
                MHSendResourceOrHTTPNotModifiedToClientOnSocket(secureSocket, resource, isAdmin, nil, message, nil) ;
            }
            else
            {
                notification = [MHNotification retainedNotificationWithMessage:message
                                //                             retainedContext:context
                                                                       session:[context session]
                                                                retainedTarget:application
                                                                retainedAction:@"awakeOnRequest:"
                                                              notificationType:notificationType
                                                           isAdminNotification:isAdmin] ;
                
                MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : AUTHENTICATED GET PUBLIC RESSOURCE WITH SESSION on socket %d", [secureSocket socket]) ;
                MHProcessingEnqueueNotificationOrSendError() ;
            }
            
        } else
        {
            switch(status) //check if not expired and returns session status
            {
                case MHSessionStatusAuthenticated :
                {
                    NSString *sessionTicket = [session memberNamed:@"ticket"] ;
                    MHDownloadResource *resource ;
                    BOOL isStandardResourceDownload = _MHIsStandardResourceDownload(notificationType) ;
                    
                    if ([application isGUIApplication] &&
                        [url isEqualToString:[(MHGUIApplication *)application loginURL]]) //request login interface, destroy dession
                    {
                        NSMutableDictionary *headers = [NSMutableDictionary dictionary] ;
                        MSBuffer *loginInterface = [(MHGUIApplication *)application loginInterfaceWithErrorMessage:nil] ;
                        MHDestroySession(session) ;
                        MHRespondToClientOnSocketWithAdditionalHeaders(secureSocket, loginInterface, HTTPOK, isAdmin, headers, nil, NO) ;
                    }
                    else if ([url isEqualToString:[application logoutURL]]) //logout : destroys session
                    {
                        MHDestroySession(session) ;
                        MHRespondToClientOnSocketWithAdditionalHeaders(secureSocket, nil, HTTPOK, isAdmin, nil, nil, NO) ;
                    }
                    else if ([url isEqualToString:[application baseURL]] && //already authenticated, and specifies a new ticket
                             [application canAuthenticateWithTicket] &&
                             [message fastContainsQueryParameterNamed:MHAUTH_QUERY_PARAM_TICKET] &&
                             ! [sessionTicket isEqualToString:[message parameterNamed:MHAUTH_QUERY_PARAM_TICKET]])
                    {
                        MHDestroySession(session) ;
                        MHRedirectToURL(secureSocket, [@"/" stringByAppendingURLComponent:[message getHeader:MHHTTPUrl]], NO) ;
                    }
                    else if(isStandardResourceDownload && (resource = MHGetResourceFromCacheOrApplication(url, application, [message contentType], notificationType)))
                    {
                        MHSendResourceOrHTTPNotModifiedToClientOnSocket(secureSocket, resource, isAdmin, session, message, nil) ;
                    }
                    else {
                        BOOL isKeepAliveRequest = NO ;
                        if(urlComponentsCount > __baseUrlComponentsCount) {
                            isKeepAliveRequest = [[urlComponents objectAtIndex:__baseUrlComponentsCount] hasPrefix:KEEP_ALIVE_URL_COMPONENT] ;
                        }
                        
                        if (isKeepAliveRequest) {
                            BOOL isGetKeepAliveIntervalRequest =  [[urlComponents objectAtIndex:__baseUrlComponentsCount + 1] hasPrefix:GET_KEEP_ALIVE_INTERVAL_URL_COMPONENT] ;
                            
                            if (isGetKeepAliveIntervalRequest) {
                                NSDictionary *getKeepAliveIntervalResponse = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                              [NSNumber numberWithUnsignedInt:[application getKeepAliveInterval]],
                                                                              @"keepAliveInterval",
                                                                              nil] ;
                                
                                MHRespondToClientOnSocketWithAdditionalHeaders(secureSocket, [getKeepAliveIntervalResponse MSTEncodedBuffer], HTTPOK, isAdmin, nil, session, NO) ;
                            }
                            else {
                                //mise à jour de la session
                                [session keepAliveTouch] ;
                                
                                MHRespondToClientOnSocketWithAdditionalHeaders(secureSocket, [@"OK" MSTEncodedBuffer], HTTPOK, isAdmin, nil, session, NO) ; //Just for clean warning on web client if body is empty in an ajax response
                            }
                        }
                        else {
                            MHNotification *notification = [MHNotification retainedNotificationWithMessage:message
                                                                                                   session:session
                                                                                            retainedTarget:application
                                                                                            retainedAction:@"awakeOnRequest:"
                                                                                          notificationType:notificationType
                                                                                       isAdminNotification:isAdmin] ;
                            
                            MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : AUTHENTICATED MESSAGE on socket %d", [secureSocket socket]) ;
                            MHProcessingEnqueueNotificationOrSendError() ;
                        }
                    }
                    
                    break ;
                }
                    
                case MHSessionStatusLoginInterfaceSent : //continue challenge authentication application authentication process
                {
                    NSString *headerChallenge   = [message getHeader:MHHTTPAuthChallenge] ;
                    NSString *headerPassword    = [message getHeader:MHHTTPAuthPassword] ;
                    
                    if (isGetRequest && (headerChallenge || headerPassword))
                    {
                        MHNotification *notification = [MHNotification retainedNotificationWithMessage:message
                                                                                               session:session
                                                                                        retainedTarget:application
                                                                                        retainedAction:@"validateAuthentication:"
                                                                                      notificationType:notificationType
                                                                                   isAdminNotification:isAdmin] ;
                        
                        //session contains authentication challenge authentication type
                        [notification setAuthenticationType:[session authenticationType]] ;
                        
                        if (headerPassword)         //password challenged authentication
                        {
                            NSString *sessionTargetURN = [session memberNamed:SESSION_PARAM_URN] ;
                            NSString *sessionLogin = [session memberNamed:SESSION_PARAM_LOGIN] ;
                            
                            if (sessionTargetURN) //authentication on target URN
                            {
                                [notification storeAuthenticationLogin:sessionLogin andPassword:headerPassword andTarget:sessionTargetURN] ;
                            } else
                            {
                                [notification storeAuthenticationLogin:sessionLogin andPassword:headerPassword authType:[session authenticationType]] ;
                            }

                        } else if (headerChallenge) //public key challenge authentication
                        {
                            [notification storeAuthenticationChallenge:headerChallenge] ;
                        }
                        
                        MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : CHALLENGE APPLICATION AUTHENTICATION REQUEST MESSAGE for authentication type %@ on socket %d",
                                             MHAuthenticationNameForType([session authenticationType]),
                                             [secureSocket socket]) ;
                        MHProcessingEnqueueNotificationOrSendError() ;
                        
                    } else
                    {
                        MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : CHALLENGE APPLICATION AUTHENTICATION REQUEST MESSAGE : wrong parameters on socket %d") ;
                        MHDestroySession(session) ;
                        _send_error_message(secureSocket, HTTP_401_UNAUTHORIZED) ;
                    }
                    break ;
                }
                    
                default: //MHSessionStatusExpired
                {
                    MHNotification *notification ;
                    MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : EXPIRED SESSION on socket %d", [secureSocket socket]) ;
                    
                    notification = [MHNotification retainedNotificationWithMessage:message
                                                                           session:session
                                                                    retainedTarget:application
                                                                    retainedAction:@"sessionWillExpire:"
                                                                  notificationType:notificationType
                                                               isAdminNotification:isAdmin] ;
                    
                    if (!MHProcessingEnqueueNotification(notification)) {
                        _send_error_message(secureSocket, HTTP_503_NOT_AVAILABLE) ;
                        [notification end] ;
                    }
                    MHDestroySession(session) ;
                }
            }
        }
    }
    MH_LOG_LEAVE(@"_MHRunApplicationWithSession") ;

}

static void _MHRunGUIApplicationChoice(NSString *knownCustomer,
                                NSString *knownGroup,
                                MHSSLSocket *secureSocket,
                                NSString *url,
                                NSArray *urlComponents,
                                BOOL isAdmin)
{
    MSUInt urlComponentsCount = (MSUInt)[urlComponents count] ;
    
    if(urlComponentsCount >= __baseUrlComponentsCount && [[urlComponents objectAtIndex:__baseUrlComponentsCount-1] length]) {
        MHRedirectToURL(secureSocket, [NSString stringWithFormat:@"/%@/%@/", knownCustomer, knownGroup], NO) ;
    }
    else {
        NSMutableDictionary *headers = nil ;
        NSMutableDictionary *params = [NSMutableDictionary dictionary] ;
        MSBuffer *loginInterface ;
        NSArray *guiAppsAndURLs = _MHGUIApplicationsForPort([secureSocket localPort], __baseUrlComponentsCount) ;
        
        if(knownCustomer) [params setObject:knownCustomer forKey:@"knownCustomer"] ;
        if(knownGroup) [params setObject:knownGroup forKey:@"knownGroup"] ;
        [params setObject:url forKey:@"url"] ;
        [params setObject:guiAppsAndURLs forKey:@"guiApplications"] ;
        
        loginInterface = [MHGUIApplication loginInterfaceAppChoiceWithParameters:params] ;
        MHRespondToClientOnSocketWithAdditionalHeaders(secureSocket, loginInterface, HTTPOK, isAdmin, headers, nil, NO) ;
    }
}

static callback_t _MHApplicationRun(void *arg)
{
    MSInt sock;
    MHSSLServerSocket *secureSocket = nil ;
    event_t newConnectionAccepted = NULL ;
    MSMutableNaturalArray *waitingAcceptedSockets = nil ;
    mutex_t *accept_mutex = NULL ;
    BOOL isAdmin = (arg != NULL) ;
    
    if (isAdmin) { //admin mode
        newConnectionAccepted = __newAdminConnectionAccepted ;
        accept_mutex = &__admin_accept_mutex ;
        waitingAcceptedSockets = __waitingAcceptedAdminSockets ;
    }
    else { //client mode
        newConnectionAccepted = __newClientConnectionAccepted ;
        accept_mutex = &__client_accept_mutex ;
        waitingAcceptedSockets = __waitingAcceptedClientSockets ;
    }
    
    while (1)
    {
        //        myLog("_MHApplicationRun waiting for new event...") ;
        if(!event_wait(newConnectionAccepted))
        {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init] ;
            MH_LOG_ENTER(@"_MHApplicationRun") ;
            
            if (isAdmin) { //admin mode
                __usedAdminReadingThreads++ ;
            }
            else {
                __usedClientReadingThreads++ ;
            }
            
            sock = -1 ;
            mutex_lock(*accept_mutex);
            if ([waitingAcceptedSockets count]) {
                sock = (MSInt)[waitingAcceptedSockets naturalAtIndex:0] ;
                [waitingAcceptedSockets removeNaturalAtIndex:0] ;
            }
            mutex_unlock(*accept_mutex);
            
            while (sock != -1)
            {
                NS_DURING
                APPLICATION_PORT_CTX *appPortCtx = NULL ;
                struct sockaddr_in sin ;
                char byte[10] ;
                int one = 1;             // need this for setsockopt
                timeout_t timeout ;
#ifdef WO451
                unsigned long nonblocking = 1 ;
                int addrlen = sizeof(sin) ;
#else
                socklen_t addrlen = sizeof(sin) ;
                int flags ;
#endif
                timeout_set(timeout, RECV_TIMEOUT);
                
                if(getsockname(sock, (struct sockaddr *)&sin, &addrlen) == -1) { MHServerLogWithLevel(MHLogError, @"getsockname error, cannot get information from socket") ; break ; }
                
                if(!(appPortCtx = applicationCtxForPort(ntohs(sin.sin_port)))) { MHServerLogWithLevel(MHLogError, @"cannot get ssl application context for port %d",ntohs(sin.sin_port)) ; }
                else {
                    if(!appPortCtx->ssl_ctx) { MHServerLogWithLevel(MHLogError, @"cannot get ssl context for port %d",ntohs(sin.sin_port)) ; }
                    
                    secureSocket = [[MHSSLServerSocket alloc] initWithContext:appPortCtx->ssl_ctx andSocket:sock isBlockingIO:NO] ;
                }
                
#ifdef WIN32
                if ((setsockopt(sock, IPPROTO_TCP, TCP_NODELAY,(char*)&one, sizeof(one)) == SOCKET_ERROR) ||
                    (setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, (char*)&timeout, sizeof(timeout)) == SOCKET_ERROR) ||
                    (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR,(char*)&one, sizeof(one))==SOCKET_ERROR))
#else
                if ((setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, (char*)&timeout, sizeof(timeout)) == SOCKET_ERROR) ||
                    (setsockopt(sock, SOL_SOCKET, SO_NOSIGPIPE, (char*)&one, sizeof(one)) == SOCKET_ERROR) ||
                    (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR,(char*)&one, sizeof(one))==SOCKET_ERROR))
#endif
                {
                    MHServerLogWithLevel(MHLogError, @"Unable to set client socket in non blocking mode for port %d", ntohs(sin.sin_port)) ;
                }
                else {
                    // Set non-blocking socket
                    if(recv(sock, &byte, 10, MSG_PEEK)==10) { //wait to receive at least 10 bytes
#ifdef WIN32
                        ioctlsocket(sock, FIONBIO, &nonblocking);
#else
                        flags = fcntl(sock, F_GETFL, 0);
                        fcntl(sock, F_SETFL, flags | O_NONBLOCK);
#endif
                        if([secureSocket accept]) //ssl handshake
                        {
                            MHHTTPMessage *message = _receive_http_message(secureSocket) ;
                            if (message) {
                                
                                NSString *url = [message getHeader:MHHTTPUrl] ;
                                NSString *knownGroup = nil ;
                                NSString *knownCustomer = nil ;
                                
                                MHNotificationType notificationType = MHStandardNotification ;
                                BOOL isStandardResourceDownload = NO ;
                                MHApplication *application = (isAdmin) ? (MHApplication *)__adminApplication : _MHApplicationForURLAndPort(url, [secureSocket localPort], __baseUrlComponentsCount) ;
                                MHSession *session = sessionWithKeyForApplication([message getHeader:MHHTTPCookie], application) ;
                                MHContext *context = contextForKey([message getHeader:MHHTTPContextId]) ; //get context from contextID
                                
                                NSMutableArray *urlComponents ;
                                MSUInt urlComponentsCount ;
                                
                                if ([url containsString:@"?"]) { url = [url substringBeforeString:@"?"] ; } //delete query parameters from url local var
                                
                                urlComponents = [[url componentsSeparatedByString:@"/"] mutableCopy] ;
                                urlComponentsCount = (MSUInt)[urlComponents count] ;
                                
                                if(urlComponentsCount && ![[urlComponents objectAtIndex:urlComponentsCount-1] length]) { [urlComponents removeLastObject]; urlComponentsCount-- ; }
                                
                                if((urlComponentsCount == __baseUrlComponentsCount) && !([url characterAtIndex:[url length] -1] == '/')) { url = [NSString stringWithFormat:@"%@/", url] ; } //if url is only a base url, add a final / if not present
                                
                                //if bundle mode and no application found for url check url customer and group validity
                                if(!__staticApplication)
                                {
                                    NSString *customerURL = nil, *groupURL = nil, *applicationURL = nil ;
                                    
                                    NSEnumerator *e = [__applicationsInfos objectEnumerator] ;
                                    NSDictionary *baseURL ;
                                    
                                    customerURL     = (urlComponentsCount)      ? [urlComponents objectAtIndex:0] : nil ;
                                    groupURL        = (urlComponentsCount > 1 ) ? [urlComponents objectAtIndex:1] : nil ;
                                    applicationURL  = (urlComponentsCount > 2 ) ? [urlComponents objectAtIndex:2] : nil ;
                                    
                                    
                                    while((baseURL = [e nextObject]))
                                    {
                                        //checks if customer only is valid
                                        if(!knownCustomer && urlComponentsCount && [[baseURL objectForKey:@"customer"] isEqual:customerURL])
                                            knownCustomer = customerURL ;
                                        
                                        //checks if customer + group is a valid URL
                                        if([[baseURL objectForKey:@"customer"] isEqual:customerURL] && [[baseURL objectForKey:@"group"] isEqual:groupURL])
                                        {
                                            knownCustomer = customerURL ;
                                            knownGroup = groupURL ;
                                            break ;
                                        }
                                    }
                                }
                                
                                if(application) {
                                    
                                    //We choose this notification type
                                    if ([message getHeader:MHHTTPUploadResourceURL])
                                    {
                                        notificationType = MHResourceUpload ;
                                    }
                                    else if (urlComponentsCount > __baseUrlComponentsCount) {
                                        if ([RESOURCE_AUTHENTICATED_URL_COMPONENT isEqual:[urlComponents objectAtIndex:__baseUrlComponentsCount]])
                                        {
                                            //notification must be considered as a standard authenticated download resource request
                                            notificationType = MHAuthenticatedResourceDownload ;
                                            isStandardResourceDownload = YES ;
                                        } else if([RESOURCE_PUBLIC_URL_COMPONENT isEqual:[urlComponents objectAtIndex:__baseUrlComponentsCount]])
                                        {
                                            //notification must be considered as a standard public resource request
                                            notificationType = MHPublicResourceDownload ;
                                            isStandardResourceDownload = YES ;
                                        }
                                        else if([RESOURCE_URL_UNC_COMPONENT isEqual:[urlComponents objectAtIndex:__baseUrlComponentsCount]])
                                        {
                                            //notification must be considered as a special download resource request with UNC path
                                            notificationType = MHUncResourceDownload ;
                                        }
                                    }
                                    
                                    if(session) {
                                        if([session application] == application) //valid session and application matches the url
                                        {
                                            _MHRunApplicationWithSession(application,
                                                                         message,
                                                                         session,
                                                                         context,
                                                                         notificationType,
                                                                         secureSocket,
                                                                         url,
                                                                         urlComponents,
                                                                         isAdmin) ;
                                        } else
                                        {
                                            MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun : wrong application for session on socket %d", [secureSocket socket]) ;
                                            _send_error_message(secureSocket, HTTP_401_UNAUTHORIZED) ; //wrong application for session
                                        }
                                        
                                    } else { //application && !session
                                        _MHRunApplicationWithNoSession(application,
                                                                       message,
                                                                       notificationType,
                                                                       secureSocket,
                                                                       url,
                                                                       isAdmin) ;
                                    }
                                } else { //!application
                                    if(! __staticApplication && knownCustomer && knownGroup) { //bundle mode : valid customer and group, send GUI login interface
                                        
                                        _MHRunGUIApplicationChoice(knownCustomer,
                                                                   knownGroup,
                                                                   secureSocket,
                                                                   url,
                                                                   urlComponents,
                                                                   isAdmin) ;
                                    } else {
                                        _send_error_message(secureSocket, HTTP_404_RESPONSE) ;
                                    }
                                }
                                RELEASE(message) ;
                            }
                            else {
                                MHServerLogWithLevel(MHLogDebug, @"_MHApplicationRun I HAVE NO MESSAGE") ;
                            }
                        }
                    }
                }
                RELEASE(secureSocket) ;
                
                NS_HANDLER
                MHServerLogWithLevel(MHLogError, @"_MHApplicationRun exception occured : %s - %s", [[localException name] UTF8String], [[localException reason] UTF8String]) ;
                NS_ENDHANDLER
                
                sock = -1 ;
                mutex_lock(*accept_mutex);
                if ([waitingAcceptedSockets count]) {
                    sock = (MSInt)[waitingAcceptedSockets naturalAtIndex:0] ;
                    [waitingAcceptedSockets removeNaturalAtIndex:0] ;
                }
                mutex_unlock(*accept_mutex);
            }
            
            if (isAdmin) { //admin mode
                __usedAdminReadingThreads-- ;
            }
            else {
                __usedClientReadingThreads-- ;
            }
            
            MH_LOG_LEAVE(@"_MHApplicationRun") ;
            RELEASE(pool) ;
        }
    }
    return 0 ;
}

static callback_t _MHProcessingDequeue(void *arg)
{
    MHNotification *notification;
    event_t newProcessingQueueEntry = NULL ;
    BOOL isAdmin = (arg != NULL) ;
    
    if (isAdmin) { //admin mode
        newProcessingQueueEntry = __newAdminProcessingQueueEntry ;
    }
    else { //client mode
        newProcessingQueueEntry = __newClientProcessingQueueEntry ;
    }
    
    while(1)
    {
        notification = nil;
        
        if(!event_wait(newProcessingQueueEntry))
        {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init] ;
            BOOL errorOccured = NO ;
            MH_LOG_ENTER(@"_MHProcessingDequeue") ;
            
            if (isAdmin) { //admin mode
                __usedAdminProcessingThreads++ ;
            }
            else {
                __usedClientProcessingThreads++ ;
            }
            
            NS_DURING
            // If there is always some notifications after dequeue, awake another worker thread
            notification = MHProcessingDequeueNotification(isAdmin) ;
            if (notification) {
                [notification performActionOnTarget] ;
            }
            NS_HANDLER
            MHServerLogWithLevel(MHLogWarning, @"_MHProcessingDequeue exception occured : %@ - %@", [localException name], [localException reason]) ;
            errorOccured = YES ;
            NS_ENDHANDLER
            
            if (notification) {
                if (errorOccured) {
                    NS_DURING
                    _send_error_message([notification clientSecureSocket], HTTP_500_RESPONSE);
                    NS_HANDLER
                    NS_ENDHANDLER
                }
                RELEASE(notification) ;
            }
            
            if (isAdmin) { //admin mode
                __usedAdminProcessingThreads-- ;
            }
            else {
                __usedClientProcessingThreads-- ;
            }
            
            MH_LOG_LEAVE(@"_MHProcessingDequeue") ;
            RELEASE(pool) ;
        }
    }
    return 0;
}

static callback_t _MHWaitingDequeue(void *arg)
{
    fd_set fds;
    MSInt fd_tab[MAX_FD_PER_SELECT];
    MSInt next_fd_tab[MAX_FD_PER_SELECT];
    
    int nb_free = MAX_FD_PER_SELECT; // tunning. Should not be more than 1024
    int nb_socket = 0 ; //nb of socket to be watched by select
    int next_nb_socket = 0 ;
    int nb_activity; // result from select()
    
    struct timeval timeout;
    int maxSocketNbr ;
    MSInt fd;
    MHQueue *queue = nil ;
    event_t newWaitingQueueEntry = NULL ;
    mutex_t *waitingQueueMutex = NULL ;
    
    NSMutableArray * notificationArray = [[NSMutableArray alloc] init];
    NSMutableArray * nextNotificationArray = [[NSMutableArray alloc] init];
    MHNotification * notif;
    BOOL isAdmin = (arg != NULL) ;
    
    if (isAdmin) { //admin mode
        queue = __adminWaitingQueue;
        newWaitingQueueEntry = __newAdminWaitingQueueEntry ;
        waitingQueueMutex = &__adminWaitingQueueMutex ;
    }
    else { //client mode
        queue = __clientWaitingQueue;
        newWaitingQueueEntry = __newClientWaitingQueueEntry ;
        waitingQueueMutex = &__clientWaitingQueueMutex ;
    }
    
    timeout.tv_sec  = 1 ;
    timeout.tv_usec = 0; //1 second timeout on read file descriptors
    
    while(1)
    {
        if(!event_wait(newWaitingQueueEntry))
        {
            BOOL starting = YES ;
            
            if (isAdmin) { //admin mode
                __usedAdminWaitingThreads++ ;
            }
            else {
                __usedClientWaitingThreads++ ;
            }
            
            while (starting || [nextNotificationArray count])
            {
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init] ;
                MSInt i, j ;
                
                starting = NO ;
                
                NS_DURING
                // notificationArray is always empty at the beginning of the loop
                // copy the notifications we haven't receive data for
                if ([nextNotificationArray count]) {
                    [notificationArray addObjectsFromArray:nextNotificationArray];
                    [nextNotificationArray removeAllObjects];
                }
                // copy the array of sockets still waiting for activity
                if(nb_socket>0) memcpy(fd_tab, next_fd_tab, sizeof(int) * nb_socket);
                
                // can we monitor more notification socket in our thread ?
                nb_free = MAX_FD_PER_SELECT - nb_socket ;
                if(nb_free > 0)
                {
                    mutex_lock(*waitingQueueMutex);
                    // unqueue the maximim of notifications we can
                    while( [queue count] && nb_free > 0 )
                    {
                        notif = [queue dequeue];
                        fd = [notif applicationSocket];
                        fd_tab[nb_socket++] = fd;
                        [notificationArray addObject:notif];
                        nb_free--;
                        MHServerLogWithLevel(MHLogDebug, @"WAIT FOR SOCKET %u", fd) ;
                    }
                    if ([queue count]) event_set(newWaitingQueueEntry); //we advertise potentially other waiting threads that there are more notification to take
                    mutex_unlock(*waitingQueueMutex);
                }
                
                maxSocketNbr = 0;
                FD_ZERO(&fds);
                for(j=0; j<nb_socket; j++) {
                    MSInt socket = fd_tab[j] ;
                    maxSocketNbr = maxSocketNbr > socket ? maxSocketNbr : socket;
                    FD_SET(socket, &fds);
                }
                
                nb_activity = 0;
                // check weither timeout is susceptible to be modified by select
                if (nb_socket>0) {
                    MHServerLogWithLevel(MHLogDebug, @"_MHWaitingDequeue waiting for activity on %d socket(s)", nb_socket) ;
                    nb_activity = select(maxSocketNbr + 1, &fds, NULL, NULL, &timeout);   
                }
                
                // for every file descriptor and every associated notification
                next_nb_socket = 0 ;
                for(i=nb_socket-1; i>=0; i--)
                {
                    // detected activity
                    MSInt socket = fd_tab[i] ;
                    MHNotification *lastNotification = (MHNotification *)[notificationArray lastObject] ;
                    if(nb_activity && FD_ISSET(socket, &fds))
                    {
                        char byte ;
                        nb_activity--;
                        
//                        MHServerLogWithLevel(MHLogDebug, @"_MHWaitingDequeue activity detected on socket %d", fd_tab[i]) ;
                        if (recv(socket, &byte, 1, MSG_PEEK)>0) { //read one byte on socket within removing it from the input queue
                            //data received on socket
                            [lastNotification changeActionToReceiveData] ;
                        }
                        else {
                            //socket was closed!
                            [lastNotification changeActionToFailReceiveData:MH_FAILURE_REASON_DISCONNECTED] ;
                        }
                        MHProcessingRequeueNotification(lastNotification);
                    }
                    else
                    {
                        // notification hasn't timed out yet
                        if([lastNotification expirationDate] - GMTNow() > 0)
                        {
                            // so keep the descriptor and the notification for the next loop
                            next_fd_tab[next_nb_socket++] = socket;
                            [nextNotificationArray addObject:lastNotification];
                        }
                        // The server connection timed out
                        else
                        {
                            // TODO : report the problem to the client (and destroy its session ?)
                            [lastNotification changeActionToFailReceiveData:MH_FAILURE_REASON_TIMEOUT] ;
                            MHProcessingRequeueNotification(lastNotification);
                        }
                    }
                    // in every case we empty the notificationArray
                    [notificationArray removeLastObject];
                }
                nb_socket = next_nb_socket ;
                
                if([notificationArray count])
                {
                    MHServerLogWithLevel(MHLogError, @"Error: notificationArray should be empty, got %s", [[notificationArray description] UTF8String]) ;
                    [notificationArray removeAllObjects];
                }
                
                NS_HANDLER
                MHServerLogWithLevel(MHLogError, @"_MHWaitingDequeue exception occured : %s - %s", [[localException name] UTF8String], [[localException reason] UTF8String]) ;
                NS_ENDHANDLER
                
                RELEASE(pool) ;
            }
            
            if (isAdmin) { //admin mode
                __usedAdminWaitingThreads-- ;
            }
            else {
                __usedClientWaitingThreads-- ;
            }
        }
    }
    return 0 ;
}

static MSInt _MHServerInitLogger(MSInt level, MSInt standardOutput)
{
    NSString *logFileName = [__mashRoot stringByAppendingPathComponent:__serverLogFile];
    
    if((level < MHLogDevel) || (level > MHLogCritical)) level = MHLogWarning ;
    
    __logger = [MHLogging newLoggingWithFile:logFileName] ;
    [__logger setLogLevel:level] ;
    if (standardOutput) [__logger setLogMode:MHScreenMode enabled:YES] ;
    
    return __logger ? EXIT_SUCCESS : EXIT_FAILURE ;
}

static BOOL _MHServerCreateMainTemporaryFolder()
{
#ifdef WO451
    if(! [[NSFileManager defaultManager] createDirectoryAtPath:__temporaryFolderPath attributes:nil] )
#else
        if(! [[NSFileManager defaultManager] createDirectoryAtPath:__temporaryFolderPath withIntermediateDirectories:NO attributes:nil error:nil] )
#endif
        {
            MHServerLogWithLevel(MHLogError, @"Error : cannot create temporary folder at path : '%@'", __temporaryFolderPath) ;
            return NO ;
        }
    return YES ;
}

static BOOL _MHCleanTemporaryFolder(BOOL isDefaultTemporaryFolder)
{
    NSDirectoryEnumerator *e = [[NSFileManager defaultManager] enumeratorAtPath:__temporaryFolderPath] ;
    NSString *file ;
    
    if(isDefaultTemporaryFolder) // deletes directory and creates it again
    {
#ifdef WO451
        if(! [[NSFileManager defaultManager] removeFileAtPath:__temporaryFolderPath handler:NO])
#else
            
        if(! [[NSFileManager defaultManager] removeItemAtPath:__temporaryFolderPath error:nil])
#endif
        {
            MHServerLogWithLevel(MHLogError, @"Cannot delete temporary folder '%@'", __temporaryFolderPath) ;
            return NO ;
        }
        
        if(! _MHServerCreateMainTemporaryFolder())
        {
            MHServerLogWithLevel(MHLogError, @"Cannot create temporary folder '%@'", __temporaryFolderPath) ;
            return NO ;
        }
        
        
    }else // deletes directory content
    {
        while ((file = [e nextObject]))
        {
#ifdef WO451
            if(! [[NSFileManager defaultManager] removeFileAtPath:[__temporaryFolderPath stringByAppendingPathComponent:file] handler:NO])
#else
                
            if(! [[NSFileManager defaultManager] removeItemAtPath:[__temporaryFolderPath stringByAppendingPathComponent:file] error:nil])
#endif
            {
                MHServerLogWithLevel(MHLogError, @"Cannot delete temporary file '%@'", [__temporaryFolderPath stringByAppendingPathComponent:file]) ;
            }
        }
    }
    return YES ;
}

BOOL MHMakeTemporaryDir(NSString *name)
{    
#ifdef WO451
    if(! [[NSFileManager defaultManager] createDirectoryAtPath:name attributes:nil] )
#else
    if(! [[NSFileManager defaultManager] createDirectoryAtPath:name withIntermediateDirectories:NO attributes:nil error:nil] )
#endif
    {
        MHServerLogWithLevel(MHLogError, @"Error : cannot create temporary folder at path : '%@'", name) ;
        return NO ;
    }
    
    return YES ;
}

NSString *MHMakeTemporaryName()
{
    return [[NSProcessInfo processInfo] globallyUniqueString] ;
}

NSString *MHMakeTemporaryFileName()
{
    return [__temporaryFolderPath stringByAppendingPathComponent:MHMakeTemporaryName()] ;
}

static MSInt _MHServerLoadPortsFromConfiguration()
{
    // - add admin application port context
    APPLICATION_PORT_CTX *adminPortCtx = (APPLICATION_PORT_CTX *) malloc(sizeof(APPLICATION_PORT_CTX)) ;
    NSEnumerator *portsEnum = nil ;
    NSDictionary *portDict = nil ;
    
    adminPortCtx->ssl_ctx = MHCreateServerSSLContext(__ssl_options, NO) ;
    adminPortCtx->twoWayAuth = NO ;
    adminPortCtx->applications = NULL ;
    if((MHLoadCertificate(adminPortCtx->ssl_ctx, __certificateFile, __keyFile)) != EXIT_SUCCESS) return EXIT_FAILURE ;
    addApplicationPortCtxForPort(__adminPort, adminPortCtx) ;
    
    // - add application port contexts
    portsEnum = [[__parameters objectForKey:@"sslPorts"] objectEnumerator] ;
    while ((portDict = [portsEnum nextObject])) {
        //create ssl context for a listening port and associed applications
        MSInt listeningPort ;
        BOOL twoWayAuth =  [@"twoWay" isEqualToString:[portDict objectForKey:@"sslAuthMode"]] ;
        APPLICATION_PORT_CTX *appPortCtx = (APPLICATION_PORT_CTX *) malloc(sizeof(APPLICATION_PORT_CTX)) ;
        
        if(!(listeningPort = [[portDict objectForKey:@"listeningPort"] intValue])) {
            MHServerLogWithLevel(MHLogError, @"[listeningPort] parameter not found") ;
            return EXIT_FAILURE ;
        }
        
        appPortCtx->ssl_ctx = MHCreateServerSSLContext(__ssl_options, twoWayAuth) ;
        appPortCtx->applications = NSCreateMapTableWithZone(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 32, NSDefaultMallocZone()) ;
        appPortCtx->twoWayAuth = twoWayAuth ;
        
        //load server certificate
        if((MHLoadCertificate(appPortCtx->ssl_ctx, __certificateFile, __keyFile)) != EXIT_SUCCESS) return EXIT_FAILURE ;
        
        //configure SSL_CTX for two way auth
        if(twoWayAuth) {
            
            NSString *CAFile ;
            char *CAFileStr ;
            MSInt verificationDepth ;
            
            if( !(CAFile = [portDict objectForKey:@"CAFile"])) {
                MHServerLogWithLevel(MHLogError, @"[CAFile] parameter not found for twoWay auth port %d",listeningPort) ;
                return EXIT_FAILURE ;
            }
            CAFile = [__mashRoot stringByAppendingPathComponent:CAFile] ;
            CAFileStr = (char *)[CAFile fileSystemRepresentation]  ;

            if(!OPENSSL_SSL_CTX_load_verify_locations(appPortCtx->ssl_ctx, CAFileStr, NULL))
            {
                MHServerLogWithLevel(MHLogCritical, @"Server certificate verification failed : check CAfile parameter. error : '%@'", MSGetOpenSSLErrStr()) ;
                return EXIT_FAILURE;
            }
            
            if(!(verificationDepth = [[portDict objectForKey:@"verificationDepth"] intValue])) {
                MHServerLogWithLevel(MHLogError, @"[verificationDepth] parameter not found for twoWay auth port %d",listeningPort) ;
                return EXIT_FAILURE ;
            }
            OPENSSL_SSL_CTX_set_verify_depth(appPortCtx->ssl_ctx, verificationDepth) ;
        }
        
        addApplicationPortCtxForPort(listeningPort, appPortCtx) ;
    }
    return EXIT_SUCCESS ;
}

static BOOL _MHCheckNetRepositoryParameters(NSDictionary *netRepositoryParameters, NSString *name)
{
    NSString *serverAddress = [netRepositoryParameters objectForKey:@"serverAddress"] ;
    MSUInt serverPort = [[netRepositoryParameters objectForKey:@"serverPort"] intValue] ;
    NSString *CAFile = [netRepositoryParameters objectForKey:@"CAFile"] ;
    NSString *applicationBaseURL = [netRepositoryParameters objectForKey:@"url"] ;
    BOOL isDir = NO ;
    
    if (![serverAddress length])
    {
        MHServerLogWithLevel(MHAppError, @"Parameter not found : 'serverAddress' for repository configuration '%@'", name) ;
        return NO ;
    }
    
    if (!serverPort)
    {
        MHServerLogWithLevel(MHAppError, @"Parameter not found : 'serverPort' for repository configuration '%@'", name) ;
        return NO ;
    }
    
    if (![applicationBaseURL length])
    {
        MHServerLogWithLevel(MHAppError, @"Parameter not found : 'url' for repository configuration '%@'", name) ;
        return NO ;
    }
    
    if (![CAFile length])
    {
        MHServerLogWithLevel(MHAppError, @"Parameter not found : 'CAFile' for repository configuration '%@'", name) ;
        return NO ;
    }
    
    if (! MSFileExistsAtPath(CAFile, &isDir) && !isDir)
    {
        MHServerLogWithLevel(MHAppError, @"CAFile not found at path %@ for repository configuration '%@'", CAFile , name) ;
        return NO ;
    }
    
    return YES ;
}

static MSInt _MHServerLoadNetRepositoryConfiguration()
{
    NSDictionary *netRepositoryParameters = [__parameters objectForKey:@"netRepositories"] ;
    
    if ([netRepositoryParameters count])
    {
        NSEnumerator *confEnum = [netRepositoryParameters keyEnumerator] ;
        NSString *name = nil ;
        NSDictionary *configurationParameters = nil ;
        
        while ((name = [confEnum nextObject]))
        {
            configurationParameters = [netRepositoryParameters objectForKey:name] ;
            
            if (! _MHCheckNetRepositoryParameters(configurationParameters, name))
            {
                return EXIT_FAILURE ;
            }
        }
        __netRepositoryConfigurations = [netRepositoryParameters retain] ;
    }
    
    return EXIT_SUCCESS ;
}

static NSDictionary *_MHGetParametersDictionary(NSDictionary *appDictionary, NSString **error)
{
    NSDictionary *parameters = [appDictionary objectForKey:@"parameters"] ;
    NSString *repositoryName = [[parameters objectForKey:@"netRepository"] objectForKey:@"repositoryName"] ;
    
    if ([repositoryName length])
    {
        NSDictionary *netRepositoryParameters = [__netRepositoryConfigurations objectForKey:repositoryName] ;
        
        if (netRepositoryParameters)
        {
            parameters = [[parameters mutableCopy] autorelease] ;
            [[parameters objectForKey:@"netRepository"] setObject:netRepositoryParameters forKey:@"netRepositories"] ;
            parameters = [NSDictionary dictionaryWithDictionary:parameters] ;
        }
        else if (error)
        {
            *error = [NSString stringWithFormat:@"Could not find net repository parameters for name '%@'", repositoryName] ;
        }
    }
    
    return parameters ;
}

//load application instances
static MSInt _MHServerLoadApplicationInstances(NSDictionary *httpServerParams, NSDictionary *bundlesInfo)
{
    NSString *bundlePath = nil ;
    NSEnumerator *appsEnum = [[__parameters objectForKey:@"applications"] objectEnumerator] ;
    NSBundle *applicationBundle = nil ;
    NSDictionary *appDict ;
    Class applicationClass;
    MHApplication *loadedApplication ;
    NSString *appType ;
    NSString *bundleName ;
    BOOL isDir = NO ;
    NSMutableDictionary *loadedBundles = [NSMutableDictionary dictionary] ;
    NSMutableArray *uniqueURLCheck = [NSMutableArray array] ;
    
    if(!__staticApplication)
    {
        if(!(bundlePath = [httpServerParams objectForKey:@"bundlePath"]))
        {
            MHServerLogWithLevel(MHLogCritical, @"Cannot find bundlePath parameter in config file") ;
            return EXIT_FAILURE;
        }
        
        if(!(MSFileExistsAtPath(bundlePath, &isDir) && isDir))
        {
            MHServerLogWithLevel(MHLogCritical, @"Cannot find bundlePath at %@", bundlePath) ;
            return EXIT_FAILURE;
        }
    }
    
    while ((appDict = [appsEnum nextObject]))
    {
        NSString *url = [appDict objectForKey:@"url"] ;
        NSArray *urlComponents = [url componentsSeparatedByString:@"/" ] ;
        NSString *baseUrl = ([url hasSuffix:@"/"]) ? url : [url stringByAppendingString:@"/"] ;
        NSString *appUrl = ([urlComponents count]) ? [urlComponents objectAtIndex:0] : nil ;
        
        NSArray *listeningPorts = [appDict objectForKey:@"listeningPorts"] ;
        NSEnumerator *listeningPortsEnum = [listeningPorts objectEnumerator] ;
        MSInt listeningPort ;
        NSDictionary *parametersDict = nil ;
        NSString *appParametersError = nil ;

        if(![url length]) {
            MHServerLogWithLevel(MHLogCritical, @"Cannot find url parameter in config file for application : %@",appDict) ;
            return EXIT_FAILURE;
        }
        
        if([uniqueURLCheck containsObject:baseUrl]) {
            MHServerLogWithLevel(MHLogCritical, @"Cannot load instance, url already used config file : '%@'", baseUrl) ;
            return EXIT_FAILURE;
        } else { [uniqueURLCheck addObject:baseUrl] ; }
        
        if(![listeningPorts count]) {
            MHServerLogWithLevel(MHLogCritical, @"Missing listeningPorts definition for instance on url : '%@'", baseUrl) ;
            return EXIT_FAILURE;
        }
        
        //load application parameter section and alter it with suitable repository parameters if needed
        parametersDict = _MHGetParametersDictionary(appDict, &appParametersError) ;
        if ([appParametersError length])
        {
            MHServerLogWithLevel(MHLogCritical, appParametersError) ;
            return EXIT_FAILURE;
        }
        
        if (__staticApplication) {//load static app instances

            loadedApplication = [(MHApplication *)[__staticApplication alloc] initOnBaseURL:baseUrl
                                                                               instanceName:[__staticApplication applicationFullName]
                                                                                 withLogger:__logger
                                                                                 parameters:parametersDict] ;
            if (!loadedApplication) {
                MHServerLogWithLevel(MHLogCritical, @"Failed to initialize application named:%@ for url:%@", [__staticApplication applicationFullName], baseUrl) ;
                return EXIT_FAILURE;
            }
            [loadedApplication setBundle:[NSBundle mainBundle]] ;
            
            while((listeningPort = [[listeningPortsEnum nextObject] intValue]))
            {
                NSMutableDictionary *urlsInfos = [NSMutableDictionary dictionary] ;
                APPLICATION_PORT_CTX *ctx = applicationCtxForPort(listeningPort) ;
                if(ctx)
                {
                    if(ctx->twoWayAuth && ![loadedApplication canVerifyPeerCertificate]) {
                        MHServerLogWithLevel(MHLogCritical, @"Cannot load %@ : port [%d] requires two-way authenticated applications only", [loadedApplication applicationName], listeningPort) ;
                        return EXIT_FAILURE;
                    }
                } else
                {
                    MHServerLogWithLevel(MHLogCritical, @"Cannot find port definition %d for instance %@", listeningPort, [loadedApplication applicationName]) ;
                    return EXIT_FAILURE;
                }
                if(appUrl) { [urlsInfos setObject:appUrl forKey:@"application"] ; }
                [urlsInfos setObject:loadedApplication forKey:@"application"] ;
                [urlsInfos setObject:[NSNumber numberWithInt:listeningPort] forKey:@"listeningPort"] ;
                [__applicationsInfos addObject:urlsInfos] ;
                
                setApplicationForPortAndKey(listeningPort, loadedApplication, baseUrl) ;
            }
            
        }
        else { // load bundles
            
            NSString *bundleFilePath = nil ;
            applicationBundle = nil ;
            appType = [appDict objectForKey:@"type"] ;
            
            if(!appType)
            {
                MHServerLogWithLevel(MHLogError, @"Error: missing application type in application entry : %@", appDict);
                continue; // TO BE CHANGED ?
            }
            
            if(!(bundleName = [bundlesInfo objectForKey:appType]))
            {
                MHServerLogWithLevel(MHLogError, @"Error: no matching bundle entry for type %@", appType);
                continue; // TO BE CHANGED ?
            }
            
            //load bundle
            if (!(applicationBundle = [loadedBundles objectForKey:bundleName])) {
                bundleFilePath = [NSString stringWithFormat:@"%@/%@.bundle", bundlePath, bundleName] ;
                
                if (MSFileExistsAtPath(bundleFilePath, &isDir)) {
                    applicationBundle = [NSBundle bundleWithPath:bundleFilePath];
                    
                    if(!applicationBundle)
                    {
                        MHServerLogWithLevel(MHLogError, @"Bundle not loaded : %@ (expected : %@)", bundleName, bundleFilePath);
                        continue;  // TO BE CHANGED ?
                    }
                    else {
                        NSString *versionFile = [applicationBundle pathForResource:@"version" ofType:@"config"] ;
                        NSString *bundleConfig ;
                        [loadedBundles setObject:applicationBundle forKey:bundleName] ;
                        if (versionFile) {
                            NSDictionary *versionDict = [NSDictionary dictionaryWithContentsOfFile:versionFile] ;
                            MHServerLogWithLevel(MHLogDebug, @"* BUNDLE '%@' LOADED - v%@.%@.%@ (%@)", bundleName,
                                                 [versionDict objectForKey:@"version"],
                                                 [versionDict objectForKey:@"release"],
                                                 [versionDict objectForKey:@"compilation"],
                                                 [versionDict objectForKey:@"name"]) ;
                        }
                        else {
                            MHServerLogWithLevel(MHLogError, @"Bundle version not found : %@", bundleName);
                        }
                        
                        bundleConfig = [applicationBundle pathForResource:@"bundle" ofType:@"config"] ;
                        if (bundleConfig) {
                            NSDictionary *bundleConfigDict ;
                            NS_DURING
                            bundleConfigDict = [[NSString stringWithContentsOfUTF8File:bundleConfig] stringsDictionaryValue] ;
                            NS_HANDLER
                            fprintf(stderr, "Error while reading bundles config file %s [2]\n", [bundleConfig UTF8String]);
                            return EXIT_FAILURE ;
                            NS_ENDHANDLER
                            
                            [__bundlesConfig setObject:bundleConfigDict forKey:NSStringFromClass([applicationBundle principalClass])] ;
                        }
                        else {
                            MHServerLogWithLevel(MHLogWarning, @"bundle.config file not found : %@", bundleName);
                        }
                    }
                }
                else
                {
                    MHServerLogWithLevel(MHLogError, @"Bundle not found : %@ (expected : %@)", bundleName, bundleFilePath);
                    continue;  // TO BE CHANGED ?
                }
            }
            
            if((applicationClass = [applicationBundle principalClass]))
            {
                NSString *customerURL, *groupURL, *applicationURL ;
                NSUInteger componentsCount = [urlComponents count] ;
                
                loadedApplication = [(MHApplication *)[applicationClass alloc] initOnBaseURL:baseUrl
                                                                                instanceName:[appDict objectForKey:@"name"]
                                                                                  withLogger:__logger
                                                                                  parameters:parametersDict] ;
                
                if (!loadedApplication)
                {
                    MHServerLogWithLevel(MHLogCritical, @"Failed to initialize application named:%@ for url:%@", [appDict objectForKey:@"name"], baseUrl) ;
                    return EXIT_FAILURE ;
                }
                
                [loadedApplication setBundle:applicationBundle] ;
                
                while((listeningPort = [[listeningPortsEnum nextObject] intValue]))
                {
                    NSMutableDictionary *urlsInfos = [NSMutableDictionary dictionary] ;
                    APPLICATION_PORT_CTX *ctx = applicationCtxForPort(listeningPort) ;
                    if(ctx)
                    {
                        if(ctx->twoWayAuth && ![loadedApplication canVerifyPeerCertificate]) {
                            MHServerLogWithLevel(MHLogCritical, @"Cannot load %@ : port [%d] requires two-way authenticated applications only", [loadedApplication applicationName], listeningPort) ;
                            return EXIT_FAILURE;
                        }
                    } else
                    {
                        MHServerLogWithLevel(MHLogCritical, @"Cannot find port definition %d for instance %@", listeningPort, [loadedApplication applicationName]) ;
                        return EXIT_FAILURE;
                    }
                    customerURL     = (componentsCount)      ? [urlComponents objectAtIndex:0] : nil ;
                    groupURL        = (componentsCount > 1 ) ? [urlComponents objectAtIndex:1] : nil ;
                    applicationURL  = (componentsCount > 2 ) ? [urlComponents objectAtIndex:2] : nil ;
                    
                    if(customerURL)     [urlsInfos setObject:customerURL    forKey:@"customer"] ;
                    if(groupURL)        [urlsInfos setObject:groupURL       forKey:@"group"] ;
                    if(applicationURL)  [urlsInfos setObject:applicationURL forKey:@"application"] ;
                    if(baseUrl)             [urlsInfos setObject:baseUrl            forKey:@"url"] ;
                    
                    [urlsInfos setObject:loadedApplication forKey:@"application"] ;
                    [urlsInfos setObject:[NSNumber numberWithInt:listeningPort] forKey:@"listeningPort"] ;
                    [__applicationsInfos addObject:urlsInfos] ;
                    
                    setApplicationForPortAndKey(listeningPort, loadedApplication, baseUrl) ;
                }
            }
            else
            {
                MHServerLogWithLevel(MHLogError, @"No main class found in the bundle %@", bundleName);
                return EXIT_FAILURE ;
            }
        }
        [__applications addObject:loadedApplication] ;
    }
    return EXIT_SUCCESS ;
}

static MSInt _MHServerLoadConfigurationFile(NSArray *params)
{
    NSDictionary *httpServerParams = nil ;
    NSDictionary *bundlesInfo = nil ;
    NSString *whitelist = nil ;
    BOOL isDefaultTemporaryFolder = NO ;
    NSString *mashVersionFile = [[NSBundle bundleForClass:[MHApplication class]]  pathForResource:@"version" ofType:@"config"] ;
    NSDictionary *mashVersionDict = [NSDictionary dictionaryWithContentsOfFile:mashVersionFile] ;
    NSDictionary *generalConfig = nil ;
    NSString *serverConfigFile = nil ;
    NSString *bundlesConfigFile = nil ;
    NSString *certificateFile, *keyFile ;
    
    if(!__staticApplication) { //bundle mode
        bundlesConfigFile = [__mashRoot stringByAppendingPathComponent:@"bundles.config"] ;
    }
    serverConfigFile = [__mashRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.config", __serverName]] ;
    
    NS_DURING
    __parameters = [[NSString stringWithContentsOfUTF8File:serverConfigFile] dictionaryValue] ;
    NS_HANDLER
    fprintf(stderr, "Error while reading server config file %s\n", [serverConfigFile UTF8String]);
    return EXIT_FAILURE ;
    NS_ENDHANDLER
    
    NS_DURING
    bundlesInfo = [[NSString stringWithContentsOfUTF8File:bundlesConfigFile] dictionaryValue] ;
    NS_HANDLER
    fprintf(stderr, "Error while reading bundles config file %s\n", [bundlesConfigFile UTF8String]);
    return EXIT_FAILURE ;
    NS_ENDHANDLER
    
    //extracting bundle infos and executables infos
    generalConfig = [bundlesInfo objectForKey:@"general"] ;
    if(!generalConfig) generalConfig = [NSMutableDictionary dictionary] ;
    __bundlesConfig = [NSMutableDictionary dictionaryWithObject:generalConfig forKey:@"general"] ;
    
    bundlesInfo = [bundlesInfo objectForKey:@"bundles"] ;
    if(! __parameters)
    {
        fprintf(stderr, "Error while reading server config file %s [2]\n", (char *)[[serverConfigFile dataUsingEncoding:NSUTF8StringEncoding] bytes]);
        return EXIT_FAILURE ;
    }
    
    //test parameters
    if(!(httpServerParams = [__parameters objectForKey:@"httpServer"])) {
        fprintf(stderr, "'httpServer' entry not found\n");
    }
    
    if(!(__serverLogFile = [httpServerParams objectForKey:@"logFile"]))
    {
        fprintf(stderr, "[httpServer] : 'logFile' parameter not found\n");
        return EXIT_FAILURE ;
    }
    
    if(!(__adminPort = [[httpServerParams objectForKey:@"adminPort"] intValue])) __adminPort = DEFAULT_ADMIN_PORT ;
    
    __adminLogin = [[httpServerParams objectForKey:@"adminLogin"] description] ;
    if(![__adminLogin length])
    {
        fprintf(stderr, "[httpServer] : 'adminLogin' parameter not found\n");
        return EXIT_FAILURE ;
    }
    
    __adminPassword = [[httpServerParams objectForKey:@"adminPassword"] description] ;
    if(![__adminPassword length])
    {
        fprintf(stderr, "[httpServer] : 'adminPassword' parameter not found\n");
        return EXIT_FAILURE ;
    }
    
    if(!(__serverCertificate = [httpServerParams objectForKey:@"certificate"]))
    {
        fprintf(stderr, "[httpServer] : 'certificate' parameter not found\n");
        return EXIT_FAILURE ;
    }
    
    if(!(__serverPrivateKey = [httpServerParams objectForKey:@"key"]))
    {
        fprintf(stderr, "[httpServer] : 'key' parameter not found\n");
        return EXIT_FAILURE ;
    }

    if(!(__disableBlacklist = [[httpServerParams objectForKey:@"disableBlacklist"] boolValue])) __disableBlacklist = NO ;
    
    if((__disableDeflateCompression = [[httpServerParams objectForKey:@"disableDeflateCompression"] boolValue])) __disableDeflateCompression = YES ;

    if([[httpServerParams objectForKey:@"disableSSLv2"]   boolValue]) { __ssl_options |= OPENSSL_SSL_OP_NO_SSLv2 ; }
    if([[httpServerParams objectForKey:@"disableSSLv3"]   boolValue]) { __ssl_options |= OPENSSL_SSL_OP_NO_SSLv3 ; }
    if([[httpServerParams objectForKey:@"disableTLSv1_0"] boolValue]) { __ssl_options |= OPENSSL_SSL_OP_NO_TLSv1 ; }
    if([[httpServerParams objectForKey:@"disableTLSv1_1"] boolValue]) { __ssl_options |= OPENSSL_SSL_OP_NO_TLSv1_1 ; }
    if([[httpServerParams objectForKey:@"disableTLSv1_2"] boolValue]) { __ssl_options |= OPENSSL_SSL_OP_NO_TLSv1_2 ; }
    
    if((__maxClientProcessingRequests = [[httpServerParams objectForKey:@"maxProcessingRequests"] intValue]) < DEFAULT_MAX_CLIENT_PROCESSING_REQUESTS ) 
        __maxClientProcessingRequests = DEFAULT_MAX_CLIENT_PROCESSING_REQUESTS ;
    
    if((__maxClientReadingThreads = [[httpServerParams objectForKey:@"maxReadingThreads"] intValue]) < DEFAULT_MAX_CLIENT_READING_THREADS)
        __maxClientReadingThreads = DEFAULT_MAX_CLIENT_READING_THREADS ;
    
    if((__maxClientProcessingThreads = [[httpServerParams objectForKey:@"maxProcessingThreads"] intValue]) < DEFAULT_MAX_CLIENT_PROCESSING_THREADS)
        __maxClientProcessingThreads = DEFAULT_MAX_CLIENT_PROCESSING_THREADS ;
    
    //init logger
    _MHServerInitLogger([[httpServerParams objectForKey:@"logLevel"] intValue], [[httpServerParams objectForKey:@"logStardardOutput"] intValue]);
    MHServerLogWithLevel(MHLogInfo, @"**************************************************************") ;
    MHServerLogWithLevel(MHLogInfo, @"*") ;

    if (mashVersionDict) {
        MHServerLogWithLevel(MHLogInfo, @"* STARTING %@ v%@.%@.%@...",
                             [__serverName uppercaseString],
                             [mashVersionDict objectForKey:@"version"],
                             [mashVersionDict objectForKey:@"release"],
                             [mashVersionDict objectForKey:@"compilation"]) ;
    }
    else { MHServerLogWithLevel(MHLogInfo, @"* STARTING %@ SERVER #UNKNOWN VERSION#...", [__serverName uppercaseString]) ; }
    
    if(! (__temporaryFolderPath = [httpServerParams objectForKey:@"temporaryFolderPath"]))
    {
        BOOL isDir = YES;
        
        //create default temporary folder
        __temporaryFolderPath = [__mashRoot stringByAppendingPathComponent:@"tmp"] ;
        isDefaultTemporaryFolder = YES ;
        
        if(! MSFileExistsAtPath(__temporaryFolderPath, &isDir))
        {
            if(! _MHServerCreateMainTemporaryFolder())
                return EXIT_FAILURE ;
        }
    }
    //dummy code to transform '\' to '/' in path if needed
    __temporaryFolderPath = [[__temporaryFolderPath stringByAppendingPathComponent:@"dummy"] stringByDeletingLastPathComponent] ;
    
    //tests write permission in temporary folder
    if(! [[NSFileManager defaultManager] isWritableFileAtPath:__temporaryFolderPath])
    {
        MHServerLogWithLevel(MHLogError, @"no write access in temporary folder at path : '%@'", __temporaryFolderPath) ;
        return EXIT_FAILURE ;
    }
    
    //deletes folder content
    if(! _MHCleanTemporaryFolder(isDefaultTemporaryFolder))
    {
        MHServerLogWithLevel(MHLogError, @"problem cleaning temporary folder at path : '%@'", __temporaryFolderPath) ;
        return EXIT_FAILURE ;
    }
    
    //certificate and key files
    certificateFile = [__mashRoot stringByAppendingPathComponent:__serverCertificate] ;
    keyFile = [__mashRoot stringByAppendingPathComponent:__serverPrivateKey] ;
    __certificateFile = (char *)[certificateFile fileSystemRepresentation]  ;
    __keyFile = (char *)[keyFile fileSystemRepresentation]  ;
    
    __applicationsInfos = [NSMutableArray array] ;
    
    //load ports and contexts
    if(_MHServerLoadPortsFromConfiguration() != EXIT_SUCCESS) { return EXIT_FAILURE ; }
    
    //load net repository configurations
    if(_MHServerLoadNetRepositoryConfiguration() != EXIT_SUCCESS) { return EXIT_FAILURE ; }
    
    //load application instances
    if(_MHServerLoadApplicationInstances(httpServerParams, bundlesInfo) != EXIT_SUCCESS) { return EXIT_FAILURE ; }
    
    if((whitelist = [httpServerParams objectForKey:@"whitelist"]))
    {
        NSArray * ranges = [whitelist componentsSeparatedByString:@","] ;
        NSEnumerator * enumarator = [ranges objectEnumerator] ;
        NSString * range ;
        NSArray * ips ;
        const char * ip ;
        MSUInt i = 0 ;
        MSUInt min, max, tmp;
        unsigned long netaddr;
        
        memset(__whitelist, 0, sizeof(__whitelist));
        
        while((range = [((NSString *)[enumarator nextObject]) trim]) && (i < WHITELIST_SIZE))
        {
            min = max = tmp = 0;
            ips = [range componentsSeparatedByString:@"-"] ;
            if([ips count] == 2)
            {
#ifdef WIN32
                ip = [[[ips objectAtIndex:0] trim] cString] ;
#else
                ip = [[[ips objectAtIndex:0] trim] UTF8String] ;
#endif
                if(ip)
                {
                    netaddr = inet_addr(ip);
                    if(netaddr == INADDR_NONE) continue;
                    min = htonl(netaddr);
                }
#ifdef WIN32
                ip = [[[ips objectAtIndex:1] trim] cString] ;
#else
                ip = [[[ips objectAtIndex:1] trim] UTF8String] ;
#endif
                if(ip)
                {
                    netaddr = inet_addr(ip);
                    if(netaddr == INADDR_NONE) continue;
                    max = htonl(netaddr);
                }
                if(max < min)
                {
                    tmp = min;
                    min = max;
                    max = tmp;
                }
            }
            else if([ips count] == 1)
            {
#ifdef WIN32
                ip = [[[ips objectAtIndex:0] trim] cString] ;
#else
                ip = [[[ips objectAtIndex:0] trim] UTF8String] ;
#endif
                if(ip)
                {
                    netaddr = inet_addr(ip);
                    if(netaddr == INADDR_NONE) continue;
                    min = htonl(netaddr);
                }
                max = min;
            }
            __whitelist[i] = min;
            __whitelist[i+1] = max;
            i += 2;
        }
    }
    
    return EXIT_SUCCESS ;
}

static MSInt _MHServerThreadsPoolsInitialize()
{
    MSInt result ;
    static BOOL isAdmin = YES ; 
    __newClientConnectionAccepted = NULL ;
    __newClientProcessingQueueEntry = NULL ;
    __waitingAcceptedClientSockets = [ALLOC(MSMutableNaturalArray) initWithCapacity:DEFAULT_MAX_CLIENT_PROCESSING_REQUESTS];
    
    /* SERVER INIT FOR CLIENT CONNECTIONS */
    // Event set to false because we aren't waiting for clients yet
    event_create(__newClientConnectionAccepted, 0);
    // Processing Queue is empty at launch
    event_create(__newClientProcessingQueueEntry, 0);
    // Waiting Queue is empty at launch
    event_create(__newClientWaitingQueueEntry, 0);
    
    if(!__newClientConnectionAccepted || !__newClientProcessingQueueEntry)
    {
        MHServerLogWithLevel(MHLogCritical, @"Error initializing locks for reading threads") ;
        return EXIT_FAILURE;
    }
    //launch the client threads of the reading pool 
    result = _MHCreateNewThreadPool(__maxClientReadingThreads, _MHApplicationRun, "Client Reading pool", nil) ;
    if (result != EXIT_SUCCESS) return result ;
    
    //launch the client threads of the processing pool 
    result = _MHCreateNewThreadPool(__maxClientProcessingThreads, _MHProcessingDequeue, "Client processing pool", nil) ;
    if (result != EXIT_SUCCESS) return result ;
    
    //launch the client threads of the waiting pool 
    result = _MHCreateNewThreadPool(__maxClientWaitingThreads, _MHWaitingDequeue, "Client waiting pool", nil) ;
    if (result != EXIT_SUCCESS) return result ;
    
    __newAdminConnectionAccepted = NULL ;
    __newAdminProcessingQueueEntry = NULL ;
    __waitingAcceptedAdminSockets = [ALLOC(MSMutableNaturalArray) initWithCapacity:DEFAULT_MAX_ADMIN_PROCESSING_REQUESTS];

    /* SERVER INIT FOR ADMIN CONNECTIONS */
    // Event set to false because we aren't waiting for clients yet
    event_create(__newAdminConnectionAccepted, 0);
    // Processing Queue is empty at launch
    event_create(__newAdminProcessingQueueEntry, 0);
    // Waiting Queue is empty at launch
    event_create(__newAdminWaitingQueueEntry, 0);
    
    if(!__newAdminConnectionAccepted || !__newAdminProcessingQueueEntry)
    {
        fprintf(stderr, "Error initializing locks for reading threads for admin connections\n");
        return EXIT_FAILURE;
    }
    //launch the admin threads of the reading pool 
    result = _MHCreateNewThreadPool(__maxAdminReadingThreads, _MHApplicationRun, "Admin reading pool", (void *)&isAdmin) ;
    if (result != EXIT_SUCCESS) return result ;
    
    //launch the admin threads of the processing pool 
    result = _MHCreateNewThreadPool(__maxAdminProcessingThreads, _MHProcessingDequeue, "Admin processing pool", (void *)&isAdmin) ;
    if (result != EXIT_SUCCESS) return result ;
    
    //launch the admin threads of the waiting pool 
    return _MHCreateNewThreadPool(__maxAdminWaitingThreads, _MHWaitingDequeue, "Admin waiting pool", (void *)&isAdmin) ;
}

MSInt MHServerInitialize(NSArray *params, Class staticApplication)
{
    MSInt result = 0 ;
    NSZone *defaultZone = NSDefaultMallocZone() ;
    MSArray *enabledSSLMethods = MSCreateArray(5);
    MSCouple *listeningPorts ;
    
    // TODO: MSLanguage not yet ported
    //_initializeLanguageInfos() ;
  
    //initialize ssl libssl
    MHInitSSL() ;
    
    __serverName = [[[params objectAtIndex:0] lastPathComponent] stringByDeletingPathExtension] ;
    
    __staticApplication = staticApplication ;
    __baseUrlComponentsCount = (__staticApplication) ? BASE_URL_COMPONENT_COUNT_STATIC_MODE : BASE_URL_COMPONENT_COUNT_BUNDLE_MODE ;
    __applicationsByPort = NSCreateMapTableWithZone(NSIntegerMapKeyCallBacks, NSIntegerMapValueCallBacks, 32, defaultZone) ;
    __applications = [MSMutableArray array] ;
    __sessions = NSCreateMapTableWithZone(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 32, defaultZone) ;
    __sessionContexts = NSCreateMapTableWithZone(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 64, defaultZone) ;
    __resourcesCache = NSCreateMapTableWithZone(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 128, defaultZone) ;
    __authenticationTickets = NSCreateMapTableWithZone(NSIntegerMapKeyCallBacks, NSObjectMapValueCallBacks, 32, defaultZone) ;
    
    mutex_init(__sessionsMutex) ;
    mutex_init(__applicationsMutex) ;
    mutex_init(__sessionContextsMutex) ;
    mutex_init(__resourcesCacheMutex) ;
    mutex_init(__authenticationTicketsMutex) ;
    mutex_init(__blacklist_mutex) ; // mutex to access the IP blacklist
    
    /* SERVER INIT FOR CLIENTS */
    __maxClientProcessingRequests = DEFAULT_MAX_CLIENT_PROCESSING_REQUESTS ;
    
    mutex_init(__client_accept_mutex);
    mutex_init(__clientProcessingQueueMutex); // mutex to access the Client Processing Queue
    mutex_init(__clientWaitingQueueMutex);
    //    mutex_init(__unusedClientReadingThreadsMutex) ;
    //    mutex_init(__unusedClientProcessingThreadsMutex) ;
    //    mutex_init(__unusedClientWaitingThreadsMutex) ;
    
    /* SERVER INIT FOR CLIENTS */
    __maxAdminProcessingRequests = DEFAULT_MAX_ADMIN_PROCESSING_REQUESTS ;
    __maxAdminReadingThreads = DEFAULT_ADMIN_READING_THREADS ;
    __maxAdminProcessingThreads = DEFAULT_ADMIN_PROCESSING_THREADS ;
    
    mutex_init(__admin_accept_mutex);
    mutex_init(__adminProcessingQueueMutex); // mutex to access the Admin Processing Queue
    mutex_init(__adminWaitingQueueMutex);
    //    mutex_init(__unusedAdminReadingThreadsMutex) ;
    //    mutex_init(__unusedAdminProcessingThreadsMutex) ;
    //    mutex_init(__unusedAdminWaitingThreadsMutex) ;
    
    /* MASH_ROOT definition */
    if([params count] > 1) {
        __mashRoot = [params objectAtIndex:1] ; //use command line parameter
    } else {
        NSString * environmentKey = [NSString stringWithFormat:@"%@_ROOT", [__serverName uppercaseString]] ;
        __mashRoot = [[[NSProcessInfo processInfo] environment] objectForKey:environmentKey] ;
        if(!__mashRoot) { fprintf(stderr, "Environment variable '%s_ROOT' is not set !\n", [[__serverName uppercaseString] asciiCString]); }
    }
        
    /* Loading conf file */
    if(_MHServerLoadConfigurationFile(params) != EXIT_SUCCESS) { return EXIT_FAILURE ; }
    
    __maxClientWaitingThreads = (MSUShort)ceil((double)__maxClientProcessingRequests / MAX_FD_PER_SELECT) ;
    
    __usedClientReadingThreads = __usedClientProcessingThreads = __currentClientProcessingRequestCount = __usedClientWaitingThreads = 0 ;
    
    __clientNotificationsPool = CElementPoolCreate(2*__maxClientProcessingThreads) ;
    __clientProcessingQueue = [MHQueue createQueueWithElementPool:__clientNotificationsPool] ;
    __clientWaitingQueue = [MHQueue createQueueWithElementPool:__clientNotificationsPool] ;
    
    __maxAdminWaitingThreads = (MSUShort)ceil((double)__maxAdminProcessingRequests / MAX_FD_PER_SELECT) ;
    
    __usedAdminReadingThreads = __usedAdminProcessingThreads = __currentAdminProcessingRequestCount = __usedAdminWaitingThreads = 0 ;
    
    __adminNotificationsPool = CElementPoolCreate(2*__maxAdminProcessingThreads) ;
    __adminProcessingQueue = [MHQueue createQueueWithElementPool:__adminNotificationsPool] ;
    __adminWaitingQueue = [MHQueue createQueueWithElementPool:__adminNotificationsPool] ;
    
    __adminApplication = [[MHAdminApplication alloc] initOnBaseURL:ADMIN_APPLICATION_URL
                                                        instanceName:@"(none)"
                                                        withLogger:__logger
                                                        parameters:[NSDictionary dictionaryWithObjectsAndKeys:__adminLogin, @"adminLogin", __adminPassword, @"adminPassword", nil]] ;
    
    if (!__adminApplication)
    {
        MHServerLogWithLevel(MHLogCritical, @"Failed to initialize admin application") ;
        return EXIT_FAILURE ;
    }

    result = _MHServerThreadsPoolsInitialize() ;

    //enabled ssl methods
    if (!(__ssl_options & OPENSSL_SSL_OP_NO_SSLv2))    { MSAAdd(enabledSSLMethods, @" SSLv2") ; }
    if (!(__ssl_options & OPENSSL_SSL_OP_NO_SSLv3))    { MSAAdd(enabledSSLMethods, @" SSLv3") ; }
    if (!(__ssl_options & OPENSSL_SSL_OP_NO_TLSv1))    { MSAAdd(enabledSSLMethods, @" TLSv1.0") ; }
    if (!(__ssl_options & OPENSSL_SSL_OP_NO_TLSv1_1))  { MSAAdd(enabledSSLMethods, @" TLSv1.1") ; }
    if (!(__ssl_options & OPENSSL_SSL_OP_NO_TLSv1_2))  { MSAAdd(enabledSSLMethods, @" TLSv1.2") ; }
    
    //get listening ports
    listeningPorts = listeningPortsSortedBySSLAuthMode() ;

    MHServerLogWithLevel(MHLogDebug, @"*") ;
    if([(NSArray *)[listeningPorts firstMember] count])  MHServerLogWithLevel(MHLogDebug, @"* . SSL ONE WAY AUTH LISTENING PORTS :   %@", [[listeningPorts firstMember] componentsJoinedByString:@", "]) ;
    if([(NSArray *)[listeningPorts secondMember] count]) MHServerLogWithLevel(MHLogDebug, @"* . SSL TWO WAY AUTH LISTENING PORTS :   %@", [[listeningPorts secondMember] componentsJoinedByString:@", "]) ;
    MHServerLogWithLevel(MHLogDebug, @"* . CLIENT MAX ACCEPTED REQUESTS : %8u", __maxClientProcessingRequests) ;
    MHServerLogWithLevel(MHLogDebug, @"* . CLIENT READING THREADS :       %8u", __maxClientReadingThreads) ;
    MHServerLogWithLevel(MHLogDebug, @"* . CLIENT PROCESSING THREADS :    %8u", __maxClientProcessingThreads) ;
    MHServerLogWithLevel(MHLogDebug, @"* . CLIENT WAITING THREADS :       %8u", __maxClientWaitingThreads) ;
    MHServerLogWithLevel(MHLogDebug, @"* . ADMIN LISTENING PORT :         %8u", __adminPort) ;
    MHServerLogWithLevel(MHLogDebug, @"* . ADMIN MAX ACCEPTED REQUESTS :  %8u", __maxAdminProcessingRequests) ;
    MHServerLogWithLevel(MHLogDebug, @"* . ADMIN READING THREADS :        %8u", __maxAdminReadingThreads) ;
    MHServerLogWithLevel(MHLogDebug, @"* . ADMIN PROCESSING THREADS :     %8u", __maxAdminProcessingThreads) ;
    MHServerLogWithLevel(MHLogDebug, @"* . ADMIN WAITING THREADS :        %8u", __maxAdminWaitingThreads) ;
    MHServerLogWithLevel(MHLogDebug, @"* . BLACKLIST :                    %@", __disableBlacklist ? @"disabled" : @" enabled") ;
    MHServerLogWithLevel(MHLogDebug, @"* . DEFLATE COMPRESSION :          %@", __disableDeflateCompression ? @"disabled" : @" enabled") ;
    MHServerLogWithLevel(MHLogInfo, @"* . ENABLED SSL METHODS :%@", MSACount(enabledSSLMethods) ? [enabledSSLMethods componentsJoinedByString:@"," ] : @"none") ;
    MHServerLogWithLevel(MHLogInfo, @"*") ;
    MHServerLogWithLevel(MHLogInfo, @"**************************************************************") ;
    
    return result ;
}

// Look for server abuse
static callback_t _generate_blacklist(void *arg)
{
    int i;
    struct in_addr current_ip;
    int current_count;
    
    while(1)
    {
        NSAutoreleasePool *pool ;
        time_t last_loop_start;
        
        current_ip.s_addr = 0;
        current_count = 0;
        pool = [[NSAutoreleasePool alloc] init] ;
        MH_LOG_ENTER(@"_generate_blacklist") ;       
        sleep(BLACKLIST_SLEEP_TIME);
        last_loop_start = time(NULL) - BLACKLIST_SLEEP_TIME;
        
        lock_blacklist_mutex() ;
        qsort_iplist() ;
        for(i=0; i<BLACKLIST_SIZE; i++)
        {
            // Empty IP (0.0.0.0) : no more valid IP to search
            ip_log *ipTemp = iplistAtIndex(i) ;
            if (ipTemp->ipv4 == 0) break ;
            if (ipTemp->ipv4 == current_ip.s_addr)
            {
                if(ipTemp->timestamp > last_loop_start) { current_count++; }
            }
            else // another list of IP addresses
            {
                MHServerLogWithLevel(MHLogDebug, @"Found %d instances of IP %s", current_count, inet_ntoa(current_ip)) ;
                if(current_count >= MAX_REQUEST_PER_PERIOD)
                {
                    blacklist_ip(current_ip.s_addr) ;
                }
                current_ip.s_addr = ipTemp->ipv4 ;
                current_count = 1;
            }
            ipTemp->ipv4 = 0 ;
            ipTemp->timestamp = 0 ;
        }
        if(current_ip.s_addr != 0)
        {
            MHServerLogWithLevel(MHLogDebug, @"Found %d instances of IP %s", current_count, inet_ntoa(current_ip)) ;
            if(current_count >= MAX_REQUEST_PER_PERIOD)
            {
                blacklist_ip(current_ip.s_addr) ;
            }
        }
        unlock_blacklist_mutex() ;
        
        MH_LOG_LEAVE(@"_generate_blacklist") ;
        
        RELEASE(pool) ;
    }
    return 0 ;
}

static void _MHServerSessionClean()
{
    NSArray *sessionArray = nil ;
    MHSession *session = nil ;
    NSEnumerator *sessionEnumerator ;
    
    //lock mutexes
    lock_sessions_mutex() ;
    lock_contexts_mutex() ;
    
    sessionArray = allSessions() ;
    sessionEnumerator = [sessionArray objectEnumerator] ;

    while((session = (MHSession *)[sessionEnumerator nextObject]))
    {
        //Tests if session reached timeout
        if(![session fastNotificationsCount] && ![session isValid])
        {
            MHApplication * app = [session application] ;
            
            if(app)
            {
                MHNotification *notification = nil ;
                //Tells the application that the session is terminating
                MHServerLogWithLevel(MHLogDebug, @"Session '%@' timeout... terminating.", [session sessionID]) ;

                notification = [MHNotification retainedNotificationWithMessage:nil
//                                                             retainedContext:context
                                                                       session:session
                                                                retainedTarget:app
                                                                retainedAction:@"sessionWillExpire:"
                                                              notificationType:MHStandardNotification
                                                           isAdminNotification:[app isAdminApplication]] ;
                
                if (!MHProcessingEnqueueNotification(notification)) {
                    [notification end] ;
                    MHServerLogWithLevel(MHLogError, @"Unable to enqueue notification in order to expire session ID '%@'.", [session sessionID]) ;
                }
            }            

            //remove session from map, and destroys it
            removeSessionForKey([session sessionID]) ;
        }
    }

    //unlock mutexes
    unlock_contexts_mutex() ;
    unlock_sessions_mutex() ;
}

static void _MHCleanResourceTree(id resource)
{
    if([resource resourcePathOndisk]) //if cached on disk, delete it.
    {
        if([resource isKindOfClass:[MHDownloadResource class]] && [[resource baseDirPathOndisk] length]) //a directory has been created to store several children files
        {
            if(! MSRemoveRecursiveDirectory([resource baseDirPathOndisk]))
            {
                MHServerLogWithLevel(MHLogError, @"MHCleanResourceTree : cannot delete temporary directory '%@'", [resource baseDirPathOndisk]) ;
            } else {
                //remove resource from cache
                MHResource *child = nil ;
                NSEnumerator *childrenEnum = [[((MHDownloadResource *)resource) childrenResources] objectEnumerator] ;
                
                while((child = [childrenEnum nextObject]))
                {
                    MHServerLogWithLevel(MHLogDebug, @"MHCleanResourceTree : remove child resource on disk %@ from cache map '%@'", [child resourcePathOndisk], [child url]) ;
                    removeResourceForKey([child url]) ;
                }
            }
        }
        else //single file to delete
        {
            if ([resource mustDeleteFileOnCLean]) //do not delete resources who have been initialized with a big file
            {
                if(! MSDeleteFile([resource resourcePathOndisk]))
                {
                    MHServerLogWithLevel(MHLogError, @"MHCleanResourceTree : cannot delete single file '%@'", [resource resourcePathOndisk]) ;
                } else
                {
                    MHServerLogWithLevel(MHLogDebug, @"MHCleanResourceTree : delete single file '%@'", [resource resourcePathOndisk]) ;
                }
            }
        }
    }
    
    MHServerLogWithLevel(MHLogDebug, @"MHCleanResourceTree : remove resource from cache map '%@'", [resource url]) ;
    removeResourceForKey([resource url]) ;
}

static void _MHServerCacheClean()
{
    NSArray *resourceArray = nil ;
    MHResource *resource = nil ;
    NSEnumerator *e ;
    
    //lock mutexes
    mutex_lock(__resourcesCacheMutex) ;
    
    resourceArray = allResources() ;
    e = [resourceArray objectEnumerator] ;
    
    // search parent resources to delete
    while((resource = [e nextObject]))
    {
        //Tests if resource reached timeout & remove parent and children from download resources
        if(![resource isValid]) { _MHCleanResourceTree(resource) ; }
    }

    //unlock mutexes
    mutex_unlock(__resourcesCacheMutex) ;
}


static void _MHTicketsClean()
{
    
    NSEnumerator *appTicketEnum = [allApplicationsTickets() objectEnumerator] ;
    MHApplication *application = nil ;
    
    while (application = (MHApplication *)[appTicketEnum nextObject])
    {
        NSMutableDictionary *tickets = ticketsForApplication(application) ;
        NSEnumerator *ticketsEnum = [tickets keyEnumerator] ;
        NSString *ticket = nil ;
        NSMutableArray *removableTickets = [NSMutableArray array] ;
        
        // search for tickets that are not valid anymore
        while ((ticket = [ticketsEnum nextObject]))
        {
            MSTimeInterval ticketValidityEnd = [validityForTicket(application, ticket) longLongValue] ;
            if (GMTNow() > ticketValidityEnd)
            {
                if(ticketValidityEnd!=0){
                    [removableTickets addObject:ticket] ;
                }
            }
        }
        
        // delete removable tickets for application
        lock_authentication_tickets_mutex() ;
        [tickets removeObjectsForKeys:removableTickets] ;
        unlock_authentication_tickets_mutex() ;
    }
}

static void _MHServerClean()
{
    NSEnumerator *applicationsEnum = nil ;
    MHApplication *app = nil ;
    MH_LOG_ENTER(@"_MHServerClean") ;
    
    // Clean sessions and contexts
    _MHServerSessionClean() ;
    
    // Clean cache
    _MHServerCacheClean() ;
    
    _MHTicketsClean() ;
    
    // Clean each loaded loaded application
    applicationsEnum = [__applications objectEnumerator] ;
    while ((app = [applicationsEnum nextObject])) { [app clean] ; }
    
    MH_LOG_LEAVE(@"_MHServerClean") ;
}

static SOCKET _MHMakeListeningSocket(MSInt listeningPort)
{
    SOCKET srv_sock ;
    timeout_t timeout ;
    SOCKADDR_IN sin ;
    int one = 1 ;
/*#ifndef WIN32
    int flags ;
#endif*/
    srv_sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) ;
    if (srv_sock == -1) {
        _fatal_error("server socket() error", cerrno);
        return -1 ;
    }
    
    timeout_set(timeout, ACCEPT_TIMEOUT);
#ifdef WIN32
    if (setsockopt(srv_sock, IPPROTO_TCP, TCP_NODELAY,(char*)&one, sizeof(one)) == SOCKET_ERROR) {
        _fatal_error("Server can't change TCP delay.", cerrno);
        return -1;
    }
    if (setsockopt(srv_sock, SOL_SOCKET, SO_RCVTIMEO, (char*)&timeout, sizeof(timeout)) == SOCKET_ERROR) {
        _fatal_error("Server can't set timeout.", cerrno);
        return -1;
    }
    if (setsockopt(srv_sock, SOL_SOCKET, SO_REUSEADDR,(char*)&one, sizeof(one))==SOCKET_ERROR) {
        _fatal_error("Server can't reuse port.", cerrno);
        return -1;
    }
#else
    if (setsockopt(srv_sock, SOL_SOCKET, SO_RCVTIMEO, (char*)&timeout, sizeof(timeout)) == SOCKET_ERROR) {
        _fatal_error("Server can't set timeout.", cerrno);
        return -1;
    }
    if (setsockopt(srv_sock, SOL_SOCKET, SO_REUSEADDR, (char*)&one, sizeof(int)) == SOCKET_ERROR) {
        _fatal_error("Server can't reuse port.", cerrno);
        return -1;
    }
#endif
    
    // fill up the server addr
    memset((char*)&sin, 0, sizeof(sin)) ;
    sin.sin_family = AF_INET;
    sin.sin_port = htons(listeningPort);
    sin.sin_addr.s_addr = htonl(INADDR_ANY);
    
    // bind srv_sock on the network interface (all)
    if (bind(srv_sock, (SOCKADDR *)&sin, sizeof(sin)))
    {
        _fatal_error("server bind error", cerrno);
        return -1;
    }
    
    // Listen on srv_sock
    if (listen(srv_sock, SOMAXCONN))
    {
        _fatal_error("server listen error", cerrno);
        return -1;
    }
    
    // Set non-blocking socket
/*#ifdef WIN32
    ioctlsocket(srv_sock, FIONBIO, &nonblocking);
#else
    flags = fcntl(srv_sock, F_GETFL, 0);
    fcntl(srv_sock, F_SETFL, flags | O_NONBLOCK);
#endif*/
    
    MHServerLogWithLevel(MHLogInfo, @"Server is listening on port : %u", listeningPort) ;

    return srv_sock ;
}

static BOOL _MHBlacklistManagement(MSInt clientSocket, SOCKADDR_IN csin)
{
    MSInt i ;
    MSInt blacklisted;
    ip_log *ipTemp = NULL ;
    
    // Keep the last blacklisted IP : Abuser will probably try to connect again very soon
    static MSUInt last_blacklisted_ip = 1;
    static MSInt j = 0 ;
    
    if(! __disableBlacklist)
    {
        if(__whitelist[0]) // If a whitelist have been defined
        {
            i = 0;
            while((i < WHITELIST_SIZE) && __whitelist[i])
            {
                // Is the IP addr in an allowed range ?
                if((htonl(csin.sin_addr.s_addr) >= __whitelist[i]) && (htonl(csin.sin_addr.s_addr) <= __whitelist[i+1]))
                {
                    i = -1; // -1 means allowed
                    break;
                }
                i += 2;
            }
            if(i != -1)
            {
                MHCloseSocket(clientSocket) ;
                return NO ;
            }
        }
        else
        {
            blacklisted = 0;
            lock_blacklist_mutex() ;
            
            if(last_blacklisted_ip == csin.sin_addr.s_addr)
            {
                MHCloseSocket(clientSocket) ;
                unlock_blacklist_mutex() ;
                return NO ;
            }
            
            for(i=0; i<BLACKLIST_SIZE; i++)
            {
                unsigned long *blacklistedIp = blacklistAtIndex(i) ;
                if (*blacklistedIp == csin.sin_addr.s_addr)
                {
                    blacklisted = 1;
                    last_blacklisted_ip = csin.sin_addr.s_addr;
                    break;
                }
            }
            
            if(blacklisted)
            {
                MHCloseSocket(clientSocket);
                unlock_blacklist_mutex() ;
                return NO ;
            }
            
            if(j >= BLACKLIST_SIZE) j = 0;
            ipTemp = iplistAtIndex(j) ;
            ipTemp->ipv4 = csin.sin_addr.s_addr ;
            ipTemp->timestamp = time(NULL) ;
            j++;
            unlock_blacklist_mutex() ;
        }
    }
    
    return YES ;
}

MSInt MHMainThread()
{
    NSAutoreleasePool *pool = NEW(NSAutoreleasePool) ;
    thread_t thread;

    NSEnumerator *applicationPorts = nil ;
    MSInt listeningPortNumber ;
    MSInt listeningPortCount = (MSInt)[allApplicationPorts() count] ;
    MSInt adminPortIndex = -1 ;
    MSInt clientSocket ;
    int i ;
    int one = 1;             // need this for setsockopt
#ifdef WIN32
    MSInt sinsize;
#else
    socklen_t sinsize;
#endif
    MSInt sock_error;
    SOCKADDR_IN csin;
    unsigned int acceptCount = 0 ;
    
    SOCKET *listeningSockets = (SOCKET *)malloc(listeningPortCount * sizeof(SOCKET)) ;
    int *listeningPortNumbers = (int *)malloc(listeningPortCount * sizeof(int)) ;
    struct fd_set fds ;
    MSInt nbActivity ;
    MSInt maxSocketNumberPlusOne = 0 ;
    struct timeval selectTimeout = {60 , 0} ;
    
#ifdef WO451
    //force some initializations under WO451
    [NSThread detachNewThreadSelector:@selector(fakeLaunch:) toTarget:[MHThreadFakeLauncher new] withObject:nil];
#endif
    
    socket_init();
    //start the black list management thread
    if (! __disableBlacklist)
    {
        if (thread_create(thread, _generate_blacklist, NULL) == -1)
        {
            MHServerLogWithLevel(MHLogCritical, @"Error occured while trying to launch the blacklist thread") ;
        }
    }
    
    // We are in our main thread
    // Create the TCP server sockets
    i = 0 ;
    applicationPorts = [allApplicationPorts() objectEnumerator] ;
    while((listeningPortNumber = [[applicationPorts nextObject] intValue]))
    {
        SOCKET srv_sock = _MHMakeListeningSocket(listeningPortNumber) ;
        if(srv_sock < 0) { return EXIT_FAILURE ; }
        listeningSockets[i] = srv_sock ;
        listeningPortNumbers[i] = listeningPortNumber ;
        if(maxSocketNumberPlusOne < srv_sock) { maxSocketNumberPlusOne = srv_sock ; }
        if(listeningPortNumber == __adminPort) { adminPortIndex = i ; }
        i++ ;
    }
    maxSocketNumberPlusOne++ ;   
    
    
    //Main loop, performs select() on all listening ports
    while (1)
    {
        FD_ZERO(&fds);
        for(i = 0; i<listeningPortCount; i++) {
            FD_SET(listeningSockets[i], &fds) ;
        }
        
        nbActivity = select(maxSocketNumberPlusOne, &fds, NULL, NULL, &selectTimeout) ;

        if(nbActivity > 0)
        {
            for (i = 0; i < listeningPortCount; i++)
            {
                MSMutableNaturalArray *waitingAcceptingSockets ;
                MSUInt maxProcessingRequests ;
                MHQueue *processingQueue ;
                mutex_t acceptMutex ;
                event_t newConnectionAccepted ;
                
                if(i == adminPortIndex) //isAdmin
                {
                    waitingAcceptingSockets = __waitingAcceptedAdminSockets ;
                    maxProcessingRequests = __maxAdminProcessingRequests ;
                    processingQueue = __adminProcessingQueue ;
                    acceptMutex = __client_accept_mutex ;
                    newConnectionAccepted = __newAdminConnectionAccepted ;
                    
                } else {
                    waitingAcceptingSockets = __waitingAcceptedClientSockets ;
                    maxProcessingRequests = __maxClientProcessingRequests ;
                    processingQueue = __clientProcessingQueue ;
                    acceptMutex = __admin_accept_mutex ;
                    newConnectionAccepted = __newClientConnectionAccepted ;
                }
                
                if (FD_ISSET(listeningSockets[i], &fds))
                {
                    timeout_t timeout ;
                    sinsize = sizeof(csin);
                    
                    nbActivity -= 1;
                    
                    clientSocket = accept(listeningSockets[i], (SOCKADDR *)&csin, &sinsize) ;
                    if (clientSocket == INVALID_SOCKET)
                    {
                        sock_error = cerrno;
                        if (sock_error == EWOULDBLOCK || sock_error == EINTR) { continue ; }
                        _fatal_error("server accept()", sock_error) ;
                    }
                        
                    if(!_MHBlacklistManagement(clientSocket, csin)) { continue ; }
                        
                    // increment valid accept count
                    acceptCount++ ;
                        
                    MHServerLogWithLevel(MHLogDevel, @"acceptCount = %d/%d processingQueue size=%d", acceptCount, MAX_ACCEPT_COUNT_BEFORE_CLEAN, [__clientProcessingQueue count]) ;
                    // Attempt to clean sessions and cache if max of consecutive accepts is reached
                    if(acceptCount >= MAX_ACCEPT_COUNT_BEFORE_CLEAN && ![__clientProcessingQueue count])
                    {
                        _MHServerClean();
                        acceptCount = 0 ;
                    }
                        
                    // Critical section : change the client socket variable
                    mutex_lock(acceptMutex);
                    if ([waitingAcceptingSockets count] <= 2*maxProcessingRequests) {
                        timeout_set(timeout, RECV_TIMEOUT);
                        one = 1;
#ifdef WIN32
                        if ((setsockopt(clientSocket ,IPPROTO_TCP, TCP_NODELAY,(char*)&timeout, sizeof(timeout)) == SOCKET_ERROR) ||
                            (setsockopt(clientSocket, SOL_SOCKET, SO_REUSEADDR,(char*)&one, sizeof(int))==SOCKET_ERROR))
#else
                        if ((setsockopt(clientSocket, SOL_SOCKET, SO_RCVTIMEO, (char*)&timeout, sizeof(timeout)) == SOCKET_ERROR) ||
                            (setsockopt(clientSocket, SOL_SOCKET, SO_NOSIGPIPE, (char*)&one, sizeof(one)) == SOCKET_ERROR))
#endif
                        {
                            _fatal_error("server setsockopt()", cerrno);
                            MHCloseSocket(clientSocket) ;
                        }
                        else {
                            [waitingAcceptingSockets addNatural:clientSocket] ;
                                    
                            // Warn the threads we have a new client
                            event_set(newConnectionAccepted);
                        }
                    }
                    else {
                        MHServerLogWithLevel(MHLogWarning, @"Connection refused : too many connections waiting on client readind thead (max = %u)", 2*__maxClientProcessingRequests) ;
                        MHCloseSocket(clientSocket) ;
                    }
                    mutex_unlock(acceptMutex);
                }
            }
        }
        RELEASE(pool) ;
        pool = NEW(NSAutoreleasePool) ;
    }
    return EXIT_SUCCESS;
}

NSArray *allApplicationPorts() {
    NSMutableArray *array = [NSMutableArray array] ;
    NSMapEnumerator mapEnum = NSEnumerateMapTable(__applicationsByPort) ;
    
    MSInt *key ;
    APPLICATION_PORT_CTX *ctx ;
    
    while (NSNextMapEnumeratorPair(&mapEnum, (void **)&key, (void **)&ctx)) { [array addObject:[NSNumber numberWithInt:(MSInt)key]] ; }
    return array ;
}

NSArray *allApplicationsForPort(MSInt listeningPort) {
    if (listeningPort) {
        APPLICATION_PORT_CTX *appCtx = (APPLICATION_PORT_CTX *)NSMapGet((NSMapTable *)__applicationsByPort, (const void *)(intptr_t)listeningPort) ;
        if(appCtx) return appCtx->applications ;
    }
    return nil ;
}

APPLICATION_PORT_CTX *applicationCtxForPort(MSInt listeningPort) {
    if(listeningPort > 0) {
        return (APPLICATION_PORT_CTX *)NSMapGet((NSMapTable *)__applicationsByPort, (const void *)(intptr_t)listeningPort) ;
    }
    return NULL ;
}

MHApplication *applicationForPortAndKey(MSInt listeningPort, NSString *key) {
    if(key && listeningPort)
    {
        APPLICATION_PORT_CTX *appCtx = (APPLICATION_PORT_CTX *)NSMapGet((NSMapTable *)__applicationsByPort, (const void *)(intptr_t)listeningPort) ;
        
        if(appCtx && appCtx->applications) {
            return (MHApplication *)NSMapGet((NSMapTable *)appCtx->applications, (const void *)key) ;
        }
    }
    return nil ;
}

MSCouple *listeningPortsSortedBySSLAuthMode()
{
    MSMutableArray *oneWayAuth = [MSCreateMutableArray(5) autorelease] ;
    MSMutableArray *twoWayAuth = [MSCreateMutableArray(5) autorelease] ;
    
    NSEnumerator *portEnum = [allApplicationPorts() objectEnumerator] ;
    NSNumber *listeningPort ;
    
    while((listeningPort = [portEnum nextObject]))
    {
        APPLICATION_PORT_CTX *portCtx = (APPLICATION_PORT_CTX *)NSMapGet((NSMapTable *)__applicationsByPort, (const void *)(intptr_t)[listeningPort intValue]) ;
        if(portCtx)
        {
            (portCtx->twoWayAuth) ? [twoWayAuth addObject:listeningPort] : [oneWayAuth addObject:listeningPort] ;
        }
    }
    
    return [MSCreateCouple([oneWayAuth sortedArrayUsingFunction:compareNumbers context:nil],
                           [twoWayAuth sortedArrayUsingFunction:compareNumbers context:nil]) autorelease] ; ;
}


void addApplicationPortCtxForPort(MSInt listeningPort, APPLICATION_PORT_CTX *appCtx) { if(listeningPort && appCtx) NSMapInsertKnownAbsent(__applicationsByPort, (const void *)(intptr_t)listeningPort, (const void *)(intptr_t)appCtx) ; }

void setApplicationForPortAndKey(MSInt listeningPort, MHApplication *application, NSString *key) {
    if(application && key && listeningPort)
    {
        APPLICATION_PORT_CTX *appCtx = (APPLICATION_PORT_CTX *)NSMapGet((NSMapTable *)__applicationsByPort, (const void *)(intptr_t)listeningPort) ;
        
        if(appCtx && appCtx->applications) {
            NSMapInsertKnownAbsent(appCtx->applications, (const void *)key, (const void *)application) ;
        }
    }
}

NSArray *allSessions() { return NSAllMapTableValues((NSMapTable *)__sessions) ; }
MHSession *sessionForKey(NSString *key) { return (MHSession *)NSMapGet((NSMapTable *)__sessions, (const void *)key) ; }

MHSession *sessionWithKeyForApplication(NSString *key, MHApplication *application)
{
    NSArray *cookies ;
    NSEnumerator *enumerator ;
    NSArray *cookie ;
    NSString *kv ;
    MHSession *session ;
    
    if(!key || !application) return nil;
    cookies = [key componentsSeparatedByString:@";"] ;
    enumerator = [cookies objectEnumerator] ;
    while((kv = [enumerator nextObject]))
    {
        cookie = (NSArray *)[[kv trim] componentsSeparatedByString:@"="] ;
        if([cookie count] == 2)
        {
            if([[cookie objectAtIndex:0] isEqualToString:[NSString stringWithFormat:@"SESS_%@", [application applicationName]]])
            {
                session = (MHSession *)NSMapGet((NSMapTable *)__sessions, (const void *)[[cookie objectAtIndex:1] description]) ;
                if([session application] == application)
                {
                    return session ;
                }
                break;
            }
        }
    }
    return nil;
}

void setSessionForKey(MHSession *session, NSString *key)
{
    if (key && session) NSMapInsertKnownAbsent(__sessions, (const void *)key, (const void *)session) ;
}

void changeSessionIDForKey(MHSession *session, NSString *key, NSString *newKey)
{
    if(key && newKey)
    {
        removeSessionForKey(key) ;
        setSessionForKey(session, newKey) ;
    }
}

void removeSessionForKey(NSString *key) { NSMapRemove(__sessions, (const void *)key) ; }
void lock_sessions_mutex() { mutex_lock(__sessionsMutex) ; }
void unlock_sessions_mutex() { mutex_unlock(__sessionsMutex) ; }

MHContext *contextForKey(NSString *key) { return (MHContext *)NSMapGet((NSMapTable *)__sessionContexts, (const void *)key) ; }
void setContextForKey(MHContext *context, NSString *key) { if (key && context) { NSMapInsertKnownAbsent(__sessionContexts, (const void *)key, (const void *)context) ; } }
void removeContextForKey(NSString *key) { NSMapRemove(__sessionContexts, (const void *)key) ; }
void lock_contexts_mutex() { mutex_lock(__sessionContextsMutex) ; }
void unlock_contexts_mutex() { mutex_unlock(__sessionContextsMutex) ; }

NSArray *allResources() { return NSAllMapTableValues((NSMapTable *)__resourcesCache) ; }
MHResource *resourceForKey(NSString *key) { return (MHResource *)NSMapGet((NSMapTable *)__resourcesCache, (const void *)key) ; }
void setResourceForKey(MHResource *resource, NSString *key) { if (key && resource) { NSMapInsertIfAbsent(__resourcesCache, (const void *)key, (const void *)resource) ; } }
void removeResourceForKey(NSString *key) { NSMapRemove(__resourcesCache, (const void *)key) ; }
void lock_resources_mutex() { mutex_lock(__resourcesCacheMutex) ; }
void unlock_resources_mutex() { mutex_unlock(__resourcesCacheMutex) ; }

NSMutableDictionary *ticketsForApplication(MHApplication *application)
{
    NSMutableDictionary *tickets = (NSMutableDictionary *)NSMapGet((NSMapTable *)__authenticationTickets, (const void *)(intptr_t)application) ;
    
    if (!tickets)
    {
        tickets = [NSMutableDictionary dictionary] ;
        NSMapInsertKnownAbsent(__authenticationTickets, (const void *)application, (const void *)tickets) ;
    }
    
    return tickets ;
}

static NSString *_generateNewTicketID()
{
    MSBuffer *randBuff= AUTORELEASE(MSCreateRandomBuffer(6));
    return FMT(@"TKT%@", MSBytesToHexaString([randBuff bytes], [randBuff length], NO));
}

static NSString *_uniqueTicketID(MHApplication *application, MHTicketFormatterCallback ticketFormatterCallback)
{
    NSString *ticket = nil ;
    do {
        MSUShort minTicketSize = 4 ;
        if (ticketFormatterCallback) {
            ticket = ticketFormatterCallback(minTicketSize);
            if ([ticket length]<minTicketSize) MSRaise(NSInternalInconsistencyException, @"Too short ticket") ;
        }
        else {
            ticket = _generateNewTicketID() ;
        }
    } while (getTicket(application, ticket)) ;
    
    return ticket ;
}

NSArray *allApplicationsTickets(void) { return NSAllMapTableValues((NSMapTable *)__authenticationTickets) ; }

NSString *ticketForValidityAndLinkedSession(MHApplication *application, MSTimeInterval duration, NSString *linkedSessionID, BOOL useOnce, MHTicketFormatterCallback ticketFormatterCallback)
{
    NSString *newTicket ;
    MSTimeInterval ticketEndValidity ;
    NSMutableDictionary *ticketDictionary ;
    NSMutableDictionary *tickets ;
    
    lock_authentication_tickets_mutex() ;
    
    tickets = ticketsForApplication(application) ;
    newTicket = _uniqueTicketID(application, ticketFormatterCallback) ;
    
    ticketEndValidity = duration ? GMTNow() + duration : 0 ; //validité permanente : duration = 0
    
    ticketDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithLongLong:ticketEndValidity], MHAPP_TICKET_VALIDITY,
                        [NSNumber numberWithLongLong:GMTNow()], MHAPP_TICKET_CREATIONDATE,
                        (useOnce) ? MSTrue : MSFalse, MHAPP_TICKET_USE_ONCE,
                        nil] ;
    
    //link a session to a new ticket
    if (linkedSessionID)
    {
        MHSession *session = nil ;
        
        lock_sessions_mutex() ;
        session = sessionForKey(linkedSessionID) ;
        unlock_sessions_mutex() ;
        
        if (session) { [ticketDictionary setObject:linkedSessionID forKey:MHAPP_TICKET_LINKED_SESSION] ; }
    }
    
    [tickets setObject:ticketDictionary forKey:newTicket] ;
    
    unlock_authentication_tickets_mutex() ;
    
    return newTicket ;
}

NSString *ticketForValidity(MHApplication *application, MSTimeInterval duration)
{
    return ticketForValidityAndLinkedSession(application, duration, nil, NO, NULL) ;
}

NSMutableDictionary *getTicket(MHApplication *application, NSString *ticket)
{
    NSMutableDictionary *ticketDict = nil ;
    
    if ([ticket length])
    {
        ticketDict = [ticketsForApplication(application) objectForKey:ticket] ;
    }
    
    return ticketDict ;
}


void setTicketsForApplication(MHApplication *application, NSDictionary *tickets)
{
    NSMutableDictionary *applicationTickets = (tickets) ? [tickets mutableCopy] : [NSMutableDictionary dictionary] ;
    
    lock_authentication_tickets_mutex() ;
    NSMapInsertKnownAbsent(__authenticationTickets, (const void *)application, (const void *)applicationTickets) ;
    unlock_authentication_tickets_mutex() ;
}


static id _valueForTicketKey(MHApplication *application, NSString *ticket, NSString *key)
{
    id value = nil ;
    
    if ([ticket length] && [key length])
    {
        lock_authentication_tickets_mutex() ;
        value = [getTicket(application, ticket) objectForKey:key] ;
        unlock_authentication_tickets_mutex() ;
    }
    
    return value ;
}

static void _setValueForTicketKey(MHApplication *application, NSString *ticket, id value, NSString *key)
{
    
    if ([ticket length] && [key length] && value)
    {
        NSMutableDictionary *ticketDictionary = getTicket(application, ticket) ;
        
        if (ticketDictionary)
        {
            lock_authentication_tickets_mutex() ;
            [ticketDictionary setObject:value forKey:key] ;
            unlock_authentication_tickets_mutex() ;
        }
    }
}


id objectForTicket(MHApplication *application, NSString *ticket)
{
    return _valueForTicketKey(application, ticket, MHAPP_TICKET_PARAMETERS) ;
}

void setObjectForTicket(MHApplication *application, id object, NSString *ticket)
{
    _setValueForTicketKey(application, ticket, object, MHAPP_TICKET_PARAMETERS) ;
}
 
NSNumber *validityForTicket(MHApplication *application, NSString *ticket)
{
    return _valueForTicketKey(application, ticket, MHAPP_TICKET_VALIDITY) ;
}

NSNumber *creationDateForTicket(MHApplication *application, NSString *ticket)
{
    return _valueForTicketKey(application, ticket, MHAPP_TICKET_CREATIONDATE) ;
}

NSString *linkedSessionForTicket(MHApplication *application, NSString *ticket)
{
    return _valueForTicketKey(application, ticket, MHAPP_TICKET_LINKED_SESSION) ;
}

void removeTicket(MHApplication *application, NSString *ticket)
{
    NSMutableDictionary *tickets = ticketsForApplication(application) ;
    
    lock_authentication_tickets_mutex() ;
    [tickets removeObjectForKey:ticket] ;
    unlock_authentication_tickets_mutex() ;
}

void lock_authentication_tickets_mutex(void) { mutex_lock(__authenticationTicketsMutex) ; }
void unlock_authentication_tickets_mutex(void) { mutex_unlock(__authenticationTicketsMutex) ; }

static void increaseCurrentClientProcessingRequestCount()
{
    if (__currentClientProcessingRequestCount != (MSUInt)-1) __currentClientProcessingRequestCount++ ;
}

void decreaseCurrentClientProcessingRequestCount()
{
    if (__currentClientProcessingRequestCount) __currentClientProcessingRequestCount-- ;
}

static void increaseCurrentAdminProcessingRequestCount()
{
    if (__currentAdminProcessingRequestCount != (MSUInt)-1) __currentAdminProcessingRequestCount++ ;
}

void decreaseCurrentAdminProcessingRequestCount()
{
    if (__currentAdminProcessingRequestCount) __currentAdminProcessingRequestCount-- ;
}

// Non-empty IPs are at the beginning of the array
static int sort(ip_log *x, ip_log *y)
{
    long result = x->ipv4 - y->ipv4;
    if(result > 0) return -1;
    if(result < 0) return 1;
    return 0;
}

typedef int (*compfn)(const void*, const void*);

void lock_blacklist_mutex() { mutex_lock(__blacklist_mutex) ; }
void unlock_blacklist_mutex() { mutex_unlock(__blacklist_mutex) ; }
void delete_blacklist_mutex() { mutex_delete(__blacklist_mutex) ; }
void qsort_iplist() { qsort((void*)__iplist, BLACKLIST_SIZE, sizeof(ip_log), (compfn)sort) ; }
ip_log *iplistAtIndex(int index) { return &__iplist[index] ; }

unsigned long *blacklistAtIndex(int index) { return &__blacklist[index] ; }
void blacklist_ip(unsigned long ip)
{ 
    __blacklist[__blacklist_idx++] = ip;
    MHServerLogWithLevel(MHLogDebug, @"Blacklisting IP address %s", inet_ntoa(*(struct in_addr *)&ip)) ;
    if(__blacklist_idx >= BLACKLIST_SIZE) __blacklist_idx = 0;
}
void removeFromBlacklist(unsigned long ip)
{
    int i;
    for(i=0; i<BLACKLIST_SIZE; i++)
    {
        if(ip == __blacklist[i])
        {
            __blacklist[i] = 0xFFFFFFFF;
        }
    }
}

void MHUpdateStatsForClientIP(unsigned long ip)
{
#warning TO BE IMPLEMENTED MHUpdateStatsForClientIP
}

void MHCleanStats()
{
#warning TO BE IMPLEMENTED MHCleanStats
}

void MHPutResourceInCache(MHResource *aResource)
{
    if (aResource && ![aResource isCached]) {
        lock_resources_mutex() ;
        setResourceForKey(aResource, [aResource url]) ; 
        [aResource setIsCached] ;
        unlock_resources_mutex() ;
    }

}

static void MHRemoveResourceFromCache(NSString *url)
{
    lock_resources_mutex() ;
    removeResourceForKey(url) ;
    unlock_resources_mutex() ;
}

BOOL MHResourceExistsInCache(NSString *url)
{
    MHResource *resource = nil ;
    NSRange range ;
    NSString *shortURL  = url ;
    
    // removes everything after the interrogation mark
    range = [url rangeOfString:@"?"] ;
    if(range.location != NSNotFound)
    {
        shortURL = [url substringToIndex:range.location] ;
    }
    
    lock_resources_mutex() ;
    resource = resourceForKey(shortURL) ;
    unlock_resources_mutex() ;
    
    return (resource != nil) ;
}

MHDownloadResource *MHGetResourceFromCacheOrApplication(NSString *url, MHApplication *application, NSString *mimeType, MHNotificationType notificationType)
{
    MHDownloadResource *resource = nil ;
    NSRange range ;
    NSString *shortURL  = url ;
    
    // removes everything after the interrogation mark
    range = [url rangeOfString:@"?"] ;
    if(range.location != NSNotFound)
    {
        shortURL = [url substringToIndex:range.location] ;
    }
    
    lock_resources_mutex() ;
    resource = (MHDownloadResource *)resourceForKey(shortURL) ;
    unlock_resources_mutex() ;
    RETAIN(resource) ;
    
    if (!resource && application && mimeType) {
        BOOL isPublicResource = (notificationType == MHPublicResourceDownload) ;
        resource = (MHDownloadResource *)[application getResourceFromBundleForURL:url mimeType:mimeType isPublicResource:isPublicResource] ;
        if (resource) {
            [resource setURL:shortURL] ;
            [resource setValidityDuration:MHRESOURCE_INFINITE_LIFETIME] ;
            [resource setUseOnce:NO] ;
            MHPutResourceInCache(resource) ;
            RETAIN(resource) ;
        }
        return resource ;
    }
    
    if ([resource useOnce]) {
        MHServerLogWithLevel(MHLogDebug, @"MHGetResourceFromCacheOrApplication : remove resource from cache map '%@'", [resource url]) ;
        MHRemoveResourceFromCache([resource url]) ;
    }
    
    return resource ;
}

static BOOL _MHCacheResource(MHDownloadResource *resource, BOOL toDisk, NSString *uniqueName, BOOL isDirectory, BOOL useOnce) //cache resource to disk or memory and calculate url
{
    NSString *relativePath = [resource name] ;
    NSString *finalPathOnDisk = nil ;
    NSString *url = [[[resource application] baseURL] stringByAppendingURLComponent:[MHDownloadResource authenticatedResourceURLComponent]] ;
    
    if(isDirectory)
    {
        if(toDisk)
        {
            finalPathOnDisk = [__temporaryFolderPath stringByAppendingPathComponent:uniqueName] ;
            [resource setBaseDirPathOndisk:finalPathOnDisk] ; //set base directory for future deletion
            finalPathOnDisk = [finalPathOnDisk stringByAppendingPathComponent:relativePath] ; // /tmpdir/unique/file or /tmpdir/uniq/subdir/filename
        }
        
        url = [[url stringByAppendingURLComponent:uniqueName] stringByAppendingURLComponent:relativePath] ;
    }
    else //caching single file
    {
        if(toDisk)
        {
            NSString *fileName = nil ;
            
            if (uniqueName) fileName = [NSString stringWithFormat:@"%@_%@", uniqueName, [relativePath lastPathComponent]] ;
            else fileName = [relativePath lastPathComponent] ;
            
            finalPathOnDisk = [__temporaryFolderPath stringByAppendingPathComponent:fileName] ;
        }
        
        if (uniqueName)  url = [url stringByAppendingURLComponent:uniqueName] ;
        url = [url stringByAppendingURLComponent:relativePath] ;
    }
    
    if(toDisk && ![resource isInitWithBigFile]) //persist file on disk if needeed (no need if created with initWithFile AND a big resource)
    {
        BOOL isDirectoryPath = YES ;
        NSString *finalDirectoryPath = [finalPathOnDisk stringByDeletingLastPathComponent] ;

        //create directory on disk if it does not exist
        if( ! MSFileExistsAtPath(finalDirectoryPath, &isDirectoryPath))
        {
            if(! MSCreateRecursiveDirectory(finalDirectoryPath)) //create necessary subdirectories
            {
                MHServerLogWithLevel(MHLogError, @"failed to create subdirectories to cache resource in '%@'", finalPathOnDisk) ;
                return NO ;
            }
        }
        
        //effectively cache resource buffer to disk
        if(! [[resource buffer] writeToFile:finalPathOnDisk atomically:YES])
        {
            MHServerLogWithLevel(MHLogError, @"failed to write cache resource to disk in '%@'", finalPathOnDisk) ;
            return NO ;
        }
        
        //unload buffer, since file is cached on disk
        [resource destroyBuffer] ;
        [resource setResourcePathOndisk:finalPathOnDisk] ;
        [resource setMustDeleteFileOnCLean:YES] ; //must delete temporary file on Resource clean
        
    }
    
    [resource setURL:url] ;
    [resource setUseOnce:useOnce] ;
    
    MHPutResourceInCache(resource) ;
    return YES ;
}

BOOL MHPrepareAndCacheResource(MHDownloadResource *resource, NSArray *childrenResources, BOOL useOnce, MSULong lifetime, BOOL forceToDisk)
{
    BOOL toDisk = forceToDisk ;

    if(!resource) return NO ;
    
    if(![childrenResources count] && useOnce)
    {
        //single resource for unique usage -> cache to memory with new URL
        if (lifetime > 0) [resource setValidityDuration:lifetime] ;
        
        return _MHCacheResource(resource, forceToDisk, MHMakeTemporaryName(), NO, YES) ;
    }
    
    toDisk = forceToDisk || [resource isBigResource] ;
    
    //set main resource duration
    if (lifetime > 0) [resource setValidityDuration:lifetime] ;
    
    //cache resources to disk or memory
    if([childrenResources count])
    {
        NSEnumerator *e ;
        NSString *uniqueName = MHMakeTemporaryName() ;
        MHDownloadResource *childResource = nil ;
        
        // add children to resource
        [resource setChildrenResources:childrenResources] ;
        
        // first loop : keep searching for a big resource
        if(! toDisk)
        {
            e = [childrenResources objectEnumerator] ;
            while ((childResource = [e nextObject]))
            {
                if((toDisk = (forceToDisk || [childResource isBigResource])))
                    break ;
            }
        }
       
        //second loop : cache resources
        e = [childrenResources objectEnumerator] ;
        while ((childResource = [e nextObject]))
        {
            if( !_MHCacheResource(childResource, toDisk, uniqueName, YES, useOnce))
                return NO ;
        }
        
        if( !_MHCacheResource(resource, toDisk, uniqueName, YES, useOnce))
            return NO ;
        
    }else
    {
        //change name to unique filename
        if( !_MHCacheResource(resource, toDisk, nil, NO, NO))
            return NO ;
    }
    
    return YES ;
}

BOOL MHPostProcess(MHDownloadResource *input, MHDownloadResource *parameters, MHDownloadResource **output,
                   MHDownloadResource **html, MHHTTPMessage *message)
{
    //call postprocessing delegate
    MHPostProcessingDelegate *delegate = [[[MHPostProcessingDelegate alloc] init] autorelease] ;
    
    [delegate postProcessInput:input
                withParameters:parameters
              toOutputResource:output
       andToOutputHTMLResource:html
usingExternalExecutablesDefinitions:[[input application] bundleParameterForKey:@"externalExecutables"]
                  postedValues:[message parameters]] ;
    
    return YES ;
}

void MHPreparePostProcess(MHHTTPMessage *message, BOOL isAdmin)
{
    MHDownloadResource *inputFile, *postProcFile ;
    MHDownloadResource *outputFile, *outputHTML ;
    NSDictionary * parameters = [message parameters] ;
    
    BOOL res ;
    
    inputFile = (MHDownloadResource *)MHGetResourceFromCacheOrApplication([parameters objectForKey:@"input"], nil, nil, 0) ;
    postProcFile = (MHDownloadResource *)MHGetResourceFromCacheOrApplication([parameters objectForKey:@"postproc"], nil, nil, 0) ;
    
    //minimum files, cannot be nil
    if(!inputFile && !postProcFile) {
        _send_error_message([message clientSecureSocket], HTTP_500_RESPONSE) ;
    }
    else {
        res = MHPostProcess(inputFile, postProcFile, &outputFile, &outputHTML, message) ;
        
        if(res)
        {
            NSDictionary *hdrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"no-cache", @"Pragma",
                                  nil] ;
            
            MHRespondToClientOnSocketWithAdditionalHeaders([message clientSecureSocket], [outputHTML buffer], HTTPOK, isAdmin, hdrs, nil, NO) ;
        }
        else
        {
            _send_error_message([message clientSecureSocket], HTTP_500_RESPONSE) ;
        }
    }    
}

NSString *MHGetUploadResourceURLForID(MHApplication *application, NSString *uploadID)
{
    return [[[application baseURL] stringByAppendingURLComponent:[MHUploadResource uploadPathComponent]] stringByAppendingURLComponent:uploadID] ;
}

void MHSendResourceOrHTTPNotModifiedToClientOnSocket(MHSSLSocket *secureSocket, MHDownloadResource *resource, BOOL isAdmin, MHSession *session, MHHTTPMessage *message, NSDictionary *headers)
{
    if ([resource firstActivity] > MHModifiedSinceTimeIntervalFromMessage(message))
    {
        MHServerLogWithLevel(MHLogDebug, @"Replying with cached data");
        MHSendResourceToClientOnSocket(secureSocket, resource, isAdmin, session, message, nil) ;
    }
    else {
        MHServerLogWithLevel(MHLogDebug, @"Replying with 304 (not modified)");
        MHRespondToClientOnSocket(secureSocket, nil, HTTPNotModified, isAdmin);
    }
    RELEASE(resource) ;
}

BOOL MHSendResourceToClientOnSocket(MHSSLSocket *secureSocket, MHDownloadResource *resource, BOOL isAdmin, MHSession *session, MHHTTPMessage *message, NSDictionary *headers)
{
    NSDictionary *headersDict = [NSDictionary dictionaryWithObjectsAndKeys:[resource mimeType], @"Content-Type",
                             GMTdescriptionRfc1123([resource firstActivity]), @"Last-Modified",
                             nil] ;
    BOOL ret = NO ;
    
    if (headers) //add additional headers
    {
        NSMutableDictionary *headersDictCopy = [[headersDict mutableCopy] autorelease] ;
        [headersDictCopy addEntriesFromDictionary:headers] ;
        headersDict = headersDictCopy ;
    }
    
    [resource touch] ;
    
    if ([resource isInitWithBigFile]) //if big data inititialized with an existing file, send data with several writes
    {
        MSFileHandle handle = MSOpenFileForReadingAtPath([resource resourcePathOndisk]) ;
        
        if (handle == MSInvalidFileHandle) { MSRaise(NSInternalInconsistencyException, @"MHSendResourceToClientOnSocket : could not create file descriptor to open file at path '%@'", [resource resourcePathOndisk]) ; }
        else
        {
            MSLong fileSize = [resource size] ;
            MSLong remainingBytesToSend = fileSize ;
            NSUInteger readBytes = 0 ;
            char readBuf[MHDONWLOAD_RESOURCE_CHUNK_SIZE] ;
            BOOL ok = YES ;
            MHChunkSendingPart chunkPos = CHUNK_SENDING_HEAD ; //only happens once because MHDONWLOAD_RESOURCE_CHUNK_SIZE << MHRESOURCE_BIGRESOURCE_LENGTH
            MSBuffer *buf = nil ;
            
            while (ok)
            {
                ok = (MSFileOperationSuccess == MSReadFromFile(handle, readBuf, MHDONWLOAD_RESOURCE_CHUNK_SIZE, &readBytes) && (readBytes > 0)) ;
                if (ok)
                {
                    buf = MSCreateBufferWithBytesNoCopyNoFree(readBuf, readBytes) ;
                    
                    ok = MHRespondToClientOnSocketWithAdditionalHeadersAndChunks(secureSocket, buf, HTTPOK, isAdmin, headersDict, session, NO, YES , chunkPos, fileSize) ;
                    remainingBytesToSend -= readBytes ;
                    
                    RELEASE(buf) ;
                } else
                {
                    if (remainingBytesToSend > 0)
                    {
                        [secureSocket close] ;
                        MSRaise(NSInternalInconsistencyException, @"MHSendResourceToClientOnSocket : could not read from file descriptor to file at path '%@'", [resource resourcePathOndisk]) ;
                    } else
                    {
                        ret = YES ;
                    }
                }
                
                if (chunkPos == CHUNK_SENDING_HEAD) { chunkPos = CHUNK_SENDING_BODY ; }
                else if(chunkPos == CHUNK_SENDING_BODY && remainingBytesToSend <= MHDONWLOAD_RESOURCE_CHUNK_SIZE) { chunkPos = CHUNK_SENDING_TAIL ; }
            }
         
            MSCloseFile(handle) ;
        }
    } else
    {
        ret = MHRespondToClientOnSocketWithAdditionalHeaders(secureSocket, [resource buffer], HTTPOK, isAdmin, headersDict, session, (!__disableDeflateCompression && [message clientBrowserSupportsDeflateCompression])) ;
    }
    
    return ret ;
}

BOOL MHRespondToClientOnSocketWithAdditionalHeaders(MHSSLSocket *secureSocket, MSBuffer *body, MSUInt status, BOOL isAdmin, NSDictionary *headers, MHSession *session, BOOL canCompress)
{
    return MHRespondToClientOnSocketWithAdditionalHeadersAndChunks(secureSocket, body, status, isAdmin, headers, session, canCompress, NO, NO_CHUNKS, 0) ;
}

BOOL MHRespondToClientOnSocketWithAdditionalHeadersAndChunks(MHSSLSocket *secureSocket, MSBuffer *body, MSUInt status, BOOL isAdmin, NSDictionary *headers, MHSession *session, BOOL canCompress, BOOL sendChuncks, MHChunkSendingPart chunkPosition, MSLong totalLength)
{
    if(![secureSocket SSLSocket])
    {
        MHServerLogWithLevel(MHLogWarning, @"MHRespondToClientOnSocketWithAdditionalHeaders : Invalid socket") ;
        return NO;
    } else
    {
        BOOL result = YES ;
        MSBuffer *data = MSCreateBuffer(256) ;
     
        if (!sendChuncks || (sendChuncks && (chunkPosition == CHUNK_SENDING_HEAD)))
        {
            char statusLine[255];
            char *str ;
            NSEnumerator *enumerator;
            id aKey = nil;
            NSMutableString *stringHeaders = [NSMutableString string];
            NSMutableDictionary *finalHeaders = [NSMutableDictionary dictionaryWithDictionary:headers];
            
            MHServerLogWithLevel(MHLogDebug, @"MHRespondToClientOnSocket %u", status) ;
            
            if ([session mustChangeSessionID])
            {
                [session changeSessionID] ;
                [session setMustChangeSessionID:NO] ;
            }
            
            switch(status)
            {
                case 200 :
                    strcpy(statusLine, HTTP_200_OK) ;
                    break ;
                case 301 :
                    strcpy(statusLine, HTTP_301_MOVED_PERMANENTLY) ;
                    break ;
                case 302 :
                    strcpy(statusLine, HTTP_302_FOUND) ;
                    break ;
                case 304 :
                    strcpy(statusLine, HTTP_304_NOT_MODIFIED) ;
                    break ;
                case 307:
                    strcpy(statusLine, HTTP_307_TEMPORARY_REDIRECT);
                    break;
                case 400 :
                    strcpy(statusLine, HTTP_400_MALFORMED) ;
                    break ;
                case 401 :
                    strcpy(statusLine, HTTP_401_UNAUTHORIZED) ;
                    break ;
                case 403 :
                    strcpy(statusLine, HTTP_403_FORBIDDEN) ;
                    break ;
                case 404 :
                    strcpy(statusLine, HTTP_404_NOT_FOUND) ;
                    break ;
                case 501 :
                    strcpy(statusLine, HTTP_501_NOT_IMPLEMENTED) ;
                    break ;
                case 503 :
                    strcpy(statusLine, HTTP_503_NOT_AVAILABLE) ;
                    break ;
                default :
                    strcpy(statusLine, HTTP_500_INTERNAL_SERVER_ERROR) ;
                    break ;
            }
            
            [finalHeaders setObject:@"close" forKey:@"Connection"] ;
            if(![finalHeaders objectForKey:@"Content-Type"])  [finalHeaders setObject:@"text/html; charset=utf-8" forKey:@"Content-type"];
            if(![finalHeaders objectForKey:@"Cache-Control"]) [finalHeaders setObject:@"no-cache, no-store, must-revalidate" forKey:@"Cache-Control"];
            if(![finalHeaders objectForKey:@"Pragma"])        [finalHeaders setObject:@"no-cache" forKey:@"Pragma"];
            if(![finalHeaders objectForKey:@"Expires"])       [finalHeaders setObject:@"0" forKey:@"Expires"];
          
            if ([session isValid]) [finalHeaders setObject:[session cookieHeader] forKey:__header_mash_session_id] ;
            
            [finalHeaders setObject:GMTdescriptionRfc1123(GMTNow())
                             forKey:@"Date"];
            
            CBufferAppendBytes((CBuffer *)data, (void *)statusLine, strlen(statusLine)) ;
            
            enumerator = [finalHeaders keyEnumerator];
            
            while ( (aKey = [enumerator nextObject]) != nil)
            {
                id value = [finalHeaders objectForKey:aKey];
                [stringHeaders appendFormat:@"%@: %@\r\n", aKey, value];
            }
            
            if([stringHeaders length])
            {
#ifdef WO451
                CBufferAppendBytes((CBuffer *)data, (void *)[stringHeaders cString], strlen([stringHeaders cString])) ;
#else
                CBufferAppendBytes((CBuffer *)data, (void *)[stringHeaders UTF8String], strlen([stringHeaders UTF8String])) ;
#endif
            }
            
            if(body)
            {
                MSLong contentLength = 0 ;
                char tmp[21] ;
                
                if (canCompress && ([body length] > MINI_RESOURCE_SIZE_FOR_COMPRESSION)) {
                    body = [body compressed] ;
                    str = "Content-Encoding: deflate\r\n" ;
                    CBufferAppendBytes((CBuffer *)data, (void *)str, strlen(str)) ;
                }
                
                
                contentLength = sendChuncks ? totalLength : [body length] ;
                str = "Content-Length: " ;
                CBufferAppendBytes((CBuffer *)data, (void *)str, strlen(str)) ;
                
#ifdef WO451
                ulltostr(contentLength, tmp, 10) ;
                
                CBufferAppendBytes((CBuffer *)data,
                                   (void *)[[NSString stringWithFormat:@"%s\r\n", tmp] cString],
                                   strlen([[NSString stringWithFormat:@"%s\r\n", tmp] cString])) ;
#else
                tmp[0] = 0 ;
                CBufferAppendBytes((CBuffer *)data,
                                   (void *)[[NSString stringWithFormat:@"%lld\r\n", contentLength] UTF8String],
                                   strlen([[NSString stringWithFormat:@"%lld\r\n", contentLength] UTF8String])) ;
#endif
            }
            
            str = "\r\n" ;
            CBufferAppendBytes((CBuffer *)data, (void *)str, strlen(str)) ;
        }
        
        if([body length])
        {
            CBufferAppendBytes((CBuffer *)data, (void *)[body bytes], [body length]) ;
        }
        
        if ([data length])
        {
            result = ([secureSocket writeBytes:[data bytes] length:(MSUInt)[data length]]) ;
        }        
        
        if (!sendChuncks || chunkPosition == CHUNK_SENDING_TAIL) { [secureSocket close] ; }
        
        
        RELEASE(data) ;
        
        return result ;        
    }
}

BOOL MHRespondToClientOnSocket(MHSSLSocket *secureSocket, MSBuffer *body, MSUInt status, BOOL isAdmin)
{
    return MHRespondToClientOnSocketWithAdditionalHeaders(secureSocket, body, status, isAdmin, nil, nil, NO) ;
}

BOOL MHReplyWithNewUploadID(MHSSLSocket *secureSocket, MHApplication *application)
{
    MHUploadResource *resource ;
    NSString *uploadStrId ;
    
    NSDictionary * hdrs = [NSDictionary dictionaryWithObjectsAndKeys:@"no-cache", @"Pragma",
    @"no-cache, must-revalidate", @"Cache-Control",
    @"application/json", @"Content-Type",
    nil] ;
    
    //add new upload resource to cache
    lock_resources_mutex() ;
    __currentUploadId++ ;
    uploadStrId = [[NSNumber numberWithInt:__currentUploadId]  stringValue] ;
    resource = [MHUploadResource resourceWithUploadIdentifier:uploadStrId forApplication:application] ;
    
    setResourceForKey(resource, [resource url]) ;
    unlock_resources_mutex() ;
    
    return MHRespondToClientOnSocketWithAdditionalHeaders(secureSocket,
                                                          [[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%u", __currentUploadId]
                                                                                       forKey:@"id"] MSTEncodedBuffer],
                                                          HTTPOK, NO, hdrs, nil, NO) ;
}

BOOL MHRedirectToURL(MHSSLSocket *secureSocket, NSString *URL, BOOL isPermanent)
{
    NSDictionary * hdrs = [NSDictionary dictionaryWithObject:URL forKey:@"Location"] ;
    return MHRespondToClientOnSocketWithAdditionalHeaders(secureSocket, nil, isPermanent ? HTTPMovedPermanently : HTTPFound , NO, hdrs, nil, NO) ;
}

BOOL MHCloseBrowserSession(MHSSLSocket *secureSocket, MHSession *session, MSUInt status)
{
    NSDictionary * hdrs ;
    NSString * cookieHdr = [NSString stringWithFormat:@"SESS_%@=deleted; Expires=Thu, 01 Jan 1970 00:00:01 GMT; Path=/%@; Secure",
                            [[session application] applicationName],
                            [[session application] baseURL]] ;
    hdrs = [NSDictionary dictionaryWithObjectsAndKeys:cookieHdr, __header_mash_session_id,
            @"no-cache", @"Pragma",
            nil] ;
    
    return MHRespondToClientOnSocketWithAdditionalHeaders(secureSocket, nil, status, NO, hdrs, nil, NO) ;
}

MSUInt _MHIPAddressFromString(NSString *string)
{
    MSUInt adr = MHBadAddress ;
    if ([string length]) {
        adr = ntohl(inet_addr([string UTF8String])) ;
        if (adr == MHBadAddress) {
            NSHost *host = [NSHost hostWithName:string] ;
            NSArray *adresses = [host addresses] ;
            NSEnumerator *e = [adresses objectEnumerator] ;
            while ((string = [e nextObject])) {
                if ([string length]) {
                    adr = ntohl(inet_addr([string UTF8String])) ;
                    if (adr != MHBadAddress) break ;
                }
                
            }
        }
    }
    return adr ;
}



BOOL MHSendDataOnConnectedSSLSocket(MSBuffer *aData, MHSSLSocket *secureSocket, NSString **anError)
{
    BOOL result = (MSInt)[secureSocket writeBytes:[aData bytes] length:(MSUInt)[aData length]] ;

    if (!result) {
        MHServerLogWithLevel(MHLogError, @"DATA NOT SENT ON SSL SOCKET %u (KO)", [secureSocket socket]) ;
    }
    
    return result ;
}

MSLong MHReceiveDataOnConnectedSSLSocket(MHSSLSocket *secureSocket, void *buffer, MSInt length)
{
    return [secureSocket readIn:buffer length:length] ;
}

void MHEnqueueWaitingNotification(MHNotification *aNotif)
{
    RETAIN(aNotif) ;
    if ([aNotif isAdminNotification]) { //admin mode
        mutex_lock(__adminWaitingQueueMutex);
        [__adminWaitingQueue enqueue:aNotif];
        mutex_unlock(__adminWaitingQueueMutex);
        event_set(__newAdminWaitingQueueEntry);
    } 
    else { //client mode
        mutex_lock(__clientWaitingQueueMutex);
        [__clientWaitingQueue enqueue:aNotif];
        mutex_unlock(__clientWaitingQueueMutex);
        event_set(__newClientWaitingQueueEntry);
    }
}

BOOL MHProcessingEnqueueNotification(MHNotification *aNotif) //to use to enqueue a new incoming request
{
    BOOL result = NO ;
    
    if ([aNotif isAdminNotification]) { //admin mode
        mutex_lock(__adminProcessingQueueMutex);
        if (__currentAdminProcessingRequestCount < __maxAdminProcessingRequests)
        {
            result = [__adminProcessingQueue enqueue:aNotif] ;
            if (result) increaseCurrentAdminProcessingRequestCount() ;            
        }
        mutex_unlock(__adminProcessingQueueMutex);
        if(result) event_set(__newAdminProcessingQueueEntry);
    } 
    else { //client mode
        mutex_lock(__clientProcessingQueueMutex);
        if (__currentClientProcessingRequestCount < __maxClientProcessingRequests)
        {
            result = [__clientProcessingQueue enqueue:aNotif] ;
            if (result) increaseCurrentClientProcessingRequestCount() ;
        }
        mutex_unlock(__clientProcessingQueueMutex);
        if(result) event_set(__newClientProcessingQueueEntry);
    }
    return result ;
}

BOOL MHProcessingRequeueNotification(MHNotification *aNotif) //to use to requeue a waiting request
{
    BOOL result = NO ;
    
    if ([aNotif isAdminNotification]) { //admin mode
        mutex_lock(__adminProcessingQueueMutex);
        result = [__adminProcessingQueue enqueue:aNotif] ;
        if (result) increaseCurrentAdminProcessingRequestCount() ;
        mutex_unlock(__adminProcessingQueueMutex);
        
        event_set(__newAdminProcessingQueueEntry);
    } 
    else { //client mode
        mutex_lock(__clientProcessingQueueMutex);
        result = [__clientProcessingQueue enqueue:aNotif] ;
        if (result) increaseCurrentClientProcessingRequestCount() ;
        mutex_unlock(__clientProcessingQueueMutex);
        
        event_set(__newClientProcessingQueueEntry);
    }
    
    return result ;
}

MHNotification *MHProcessingDequeueNotification(BOOL admin)
{
    MHNotification *notif = nil ;
    
    if (admin) { //admin mode
        mutex_lock(__adminProcessingQueueMutex);
        if([__adminProcessingQueue count])
        {
            notif = (MHNotification *)[__adminProcessingQueue dequeue];
            if (notif) decreaseCurrentAdminProcessingRequestCount();
        }
        if([__adminProcessingQueue count]) event_set(__newAdminProcessingQueueEntry);
        mutex_unlock(__adminProcessingQueueMutex);
    } 
    else { //client mode
        mutex_lock(__clientProcessingQueueMutex);
        if([__clientProcessingQueue count])
        {
            notif = (MHNotification *)[__clientProcessingQueue dequeue];
            if (notif) decreaseCurrentClientProcessingRequestCount();
        }
        if([__clientProcessingQueue count]) event_set(__newClientProcessingQueueEntry);
        mutex_unlock(__clientProcessingQueueMutex);
    }
    
    return notif ;
}

void MHCancelAllProcessingNotificationsForClientSocket(SOCKET fd, BOOL isAdminNotification)
{
    MHNotification *notification = nil ;
    MSUInt count, i = 0 ;
    
    if (isAdminNotification) {
        mutex_lock(__adminProcessingQueueMutex);
        count = [__adminProcessingQueue count] ;
        if(count) {
            for (i=0; i<count; i++) {
                notification = (MHNotification *)[__adminProcessingQueue dequeue];
                if (notification) {
                    if ([notification waitingExternalSocket] == fd) {
                        [notification respondsToMessageWithBody:nil httpStatus:HTTPInternalError headers:nil closeSession:YES] ;
                        [notification end] ;

                        decreaseCurrentAdminProcessingRequestCount();
                    }
                    else {
                        [__adminProcessingQueue enqueue:notification] ;
                    }
                }
            }
        }
        mutex_unlock(__adminProcessingQueueMutex);
    }
    else {
        mutex_lock(__clientProcessingQueueMutex);
        count = [__clientProcessingQueue count] ;
        if(count) {
            for (i=0; i<count; i++) {
                notification = (MHNotification *)[__clientProcessingQueue dequeue];
                if (notification) {
                    if ([notification waitingExternalSocket] == fd) {
                        [notification respondsToMessageWithBody:nil httpStatus:HTTPInternalError headers:nil closeSession:YES] ;
                        [notification end] ;

                        decreaseCurrentClientProcessingRequestCount();
                    }
                    else {
                        [__clientProcessingQueue enqueue:notification] ;
                    }
                }
            }
        }
        mutex_unlock(__clientProcessingQueueMutex);
    }
}

void MHServerLogWithLevel(MHLogLevel level, NSString *log, ...)
{
    va_list list ;
    va_start (list, log) ;
    [__logger logWithLevel:level application:__serverName log:log args:list] ;
    va_end(list) ;
}

void MHServerSetLogMode(MHLogMode mode, BOOL enabled)
{
    [__logger setLogMode:mode enabled:enabled] ;
}

void MHServerSetLogLevel(MHLogLevel level)
{
    [__logger setLogLevel:level] ;
}
#ifdef WO451
@implementation MHThreadFakeLauncher
- (void)fakeLaunch:(id)parameters {}
@end
#endif


MHContext *MHCreateInitialContextAndSession(MHApplication *application, MHAppAuthentication authenticationType)
{
    MHSession *newSession = [MHSession newRetainedSessionWithApplication:application timeOut:[MHApplication defaultSessionInitTimeout] authenticationType:authenticationType] ;
    RELEASE(newSession) ; //already retained by the session map
    return [MHContext newRetainedContextWithRetainedSession:newSession] ;
}

void MHDestroySession(MHSession *session)
{
    NSEnumerator *e ;
    MHContext *context ;
    
    lock_sessions_mutex() ;
    lock_contexts_mutex() ;
    
    e = [[session contexts] objectEnumerator] ;
    while((context = [e nextObject])) {
        removeContextForKey([context contextID]) ;
        DESTROY(context) ;
    }
    removeSessionForKey([session sessionID]) ;
    
    unlock_contexts_mutex() ;
    unlock_sessions_mutex() ;
}

void MHSendSessionAndContext(MHSSLSocket *secureSocket, MHContext *context, BOOL isAdmin)
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary] ;
    
    [headers setObject:[context contextID] forKey:__header_mash_context_id] ;
    
    MHRespondToClientOnSocketWithAdditionalHeaders(secureSocket, nil, HTTPOK, isAdmin, headers, [context session], NO) ;
}

void MHValidateAuthentication(MHNotification *notification, BOOL isAuthenticated, MSBuffer *body)
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary] ;
    MHSession *session = [notification session] ;
    
    if(!isAuthenticated)
    {
        MHApplication *application = [session application] ;
        NSString *errorMessage ;
        MSBuffer *loginPage = nil ;
        
        [headers setObject:MHAUTH_HEADER_RESPONSE_FAIL forKey:MHAUTH_HEADER_RESPONSE] ;
        
        if([body length])
        {
            errorMessage = AUTORELEASE(MSCreateASCIIStringWithBytes((void *)[body bytes], [body length], YES, YES)) ;
        }
        else
        {
            errorMessage = @"Authentication failed" ;
        }
        
        if ([session authenticationType] == MHAuthSimpleGUIPasswordAndLogin)
        {
            loginPage = [(MHGUIApplication *)application loginInterfaceWithErrorMessage:errorMessage] ;
        } else
        {
            loginPage = AUTORELEASE(MSCreateBufferWithBytes((void *)[errorMessage UTF8String], [errorMessage length])) ;
        }
      
        MHRESPOND_TO_CLIENT_AND_CLOSE_SESSION(loginPage , HTTPUnauthorized, headers) ;
    }
    else //auth ok, send session_id context_id and auth_success
    {
        [headers setObject:MHAUTH_HEADER_RESPONSE_OK forKey:MHAUTH_HEADER_RESPONSE] ;
        [session changeStatus:MHSessionStatusAuthenticated] ;
        [headers setObject:[session cookieHeader] forKey:__header_mash_session_id] ;
        
        MHRESPOND_TO_CLIENT(body , HTTPOK, headers) ;
        
        //closes connection to client
        [[[notification message] clientSecureSocket] close] ;
    }
}

BOOL MHSendDataOnConnectedSocket(MSBuffer *aData, MSInt socket, NSString **anError)
{
    MSInt result = (MSInt)send(socket, [aData bytes], [aData length], 0) ;
    
    if (result == SOCKET_ERROR) {
        MSInt errcode = cerrno ;

#ifdef WIN32
        char *lpMsgBuf;
        
        lpMsgBuf = (LPVOID)"Unknown error";
        if (FormatMessageA(
                           FORMAT_MESSAGE_ALLOCATE_BUFFER |
                           FORMAT_MESSAGE_FROM_SYSTEM |
                           FORMAT_MESSAGE_IGNORE_INSERTS,
                           NULL, errcode,
                           MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                           (LPTSTR)&lpMsgBuf, 0, NULL))
        {
            if (anError) {
                *anError = [NSString stringWithFormat:@"%d: %s", errcode, lpMsgBuf] ;
                MHServerLogWithLevel(MHLogError, @"DATA NOT SENT ON SOCKET %u (KO) - %@", socket, *anError) ;
            }
            else {
                MHServerLogWithLevel(MHLogError, @"DATA NOT SENT ON SOCKET %u (KO) - Error %d: %s", socket, errcode, lpMsgBuf) ;
            }
            LocalFree(lpMsgBuf);
        }
        else {
            MHServerLogWithLevel(MHLogError, @"DATA NOT SENT ON SOCKET %u (KO) - Error %d", socket, errcode) ;
        }
#else
        MHServerLogWithLevel(MHLogError, @"DATA NOT SENT ON SOCKET %u (KO) (cerrno #%d: %s)", socket, errcode, strerror(errcode)) ;
#endif
    }
    
    return (result != SOCKET_ERROR) ;
}

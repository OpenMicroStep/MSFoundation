/*
 
 MHApplication.m
 
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
 
 A Special homage to Steve Jobs who permits the Objective-C technology
 to meet the world. Without him, this years-long work should not have
 been existing at all. Thank you Steve and rest in peace.
 
 */


#import "_MASHPrivate.h"

#define SESSION_DEFAULT_INIT_TIMEOUT 90
#define SESSION_DEFAULT_AUTHENTICATED_TIMEOUT 600

#define BUNDLE_AUTHENTICATED_RESOURCE_SUBDIRECTORY      @"authenticatedResources"
#define BUNDLE_PUBLIC_RESOURCE_SUBDIRECTORY             @"publicResources"

@implementation MHApplication

+ (id)applicationOnBaseURL:(NSString *)url instanceName:(NSString *)instanceName withLogger:(id)logger parameters:(NSDictionary *)parameters
{
    return [[[self alloc] initOnBaseURL:url instanceName:instanceName withLogger:logger parameters:parameters] autorelease] ;
}
- (id)initOnBaseURL:(NSString *)url instanceName:(NSString *)instanceName withLogger:(id)logger parameters:(NSDictionary *)parameters
{
    ASSIGN(_logger, logger) ;
    ASSIGN(_parameters, parameters) ;
    ASSIGN(_baseURL, url) ;
    ASSIGN(_instanceName, instanceName) ;
    return self ;
}

- (void)dealloc
{
    DESTROY(_logger) ;
    DESTROY(_parameters) ;
    DESTROY(_instanceName) ;
    
    DESTROY(_postProcessingURL) ;
    DESTROY(_authenticatedResourceURL) ;
    DESTROY(_publicResourceURL) ;
    DESTROY(_uncURL) ;
    
    [super dealloc] ;
}

- (id)parameterNamed:(NSString *)name
{
    return [_parameters objectForKey:name] ;
}

+ (MHApplication *)applicationForURL:(NSString *)url listeningPort:(MSInt)listeningPort baseUrlComponentsCount:(MSUInt)count
{
    NSString *urlWithoutQueryParams = [url containsString:@"?"] ? [url substringBeforeString:@"?"] : url ;
    NSArray *urlComponents = [urlWithoutQueryParams componentsSeparatedByString:@"/"] ;

    if ([urlComponents count] >= count) {
        
        switch(count)
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

- (MHSession *)hasValidSessionForID:(NSString *)aSessionID { 
    MHSession *session = sessionForKey(aSessionID) ;
    if (session && ([session application] == self)) {
       return session ;
    }
    return nil ; 
}
- (BOOL)mustRespondWithAuthentication { [self notImplemented:_cmd] ; return YES ; }

- (BOOL)canVerifyPeerCertificate { return NO ; }

+ (MSUInt)defaultSessionInitTimeout { return SESSION_DEFAULT_INIT_TIMEOUT ; }
- (BOOL)mustUpdateLastActivity { return YES ; }

- (SEL)_actionFromURL:(NSString *)URL
{
    NSString *baseURL = [self baseURL] ;
    NSString *subURL ;
    NSRange rangeOfSubstring = [URL rangeOfString:baseURL];
    
    //remove baseURL
    if(rangeOfSubstring.location == NSNotFound) { return NULL ; }
    subURL =  [URL substringFromIndex:rangeOfSubstring.location+rangeOfSubstring.length] ;
    
    //remove parameters
    rangeOfSubstring = [subURL rangeOfString:@"?"];
    if(rangeOfSubstring.location != NSNotFound) {
        subURL =  [subURL substringToIndex:rangeOfSubstring.location] ;
    }
    
    return NSSelectorFromString([subURL stringByAppendingString:@":"]) ;
}

- (void)awakeOnRequest:(MHNotification *)notification {
    
    SEL action = [self _actionFromURL:[[notification message] getHeader:MHHTTPUrl]] ;
    
    if(!action) {
        [self logWithLevel:MHAppError log:@"awakeOnRequest: cannot create action selector from URL : %@",[[notification message] getHeader:MHHTTPUrl]] ;
        MHRESPOND_TO_CLIENT_AND_CLOSE_SESSION(nil, HTTPBadRequest, nil) ;
    }
    else {
        if([self respondsToSelector:action])
        {
            [self logWithLevel:MHAppDebug log:@"awakeOnRequest: perform action on %@", NSStringFromSelector(action)] ;
            [self performSelector:action withObject:notification] ;
        } else
        {
            [self logWithLevel:MHAppError log:@"awakeOnRequest: action not supported : %@", NSStringFromSelector(action)] ;
            MHRESPOND_TO_CLIENT_AND_CLOSE_SESSION(nil, HTTPBadRequest, nil) ;
        }
    }
}

- (void)sessionWillExpire:(MHNotification *)notification { RELEASE(notification) ; }

- (void)clean {}

+ (NSString *)applicationName { [self notImplemented:_cmd] ; return nil ; }
+ (NSString *)applicationFullName { [self notImplemented:_cmd] ; return nil ; }
+ (BOOL)isAdminApplication { return NO ; }
- (NSString *)baseURL { return _baseURL ; }
- (NSString *)loginURL
{
    return [[self baseURL] length] ? [[self baseURL] stringByAppendingURLComponent:DEFAULT_LOGIN_URL_COMPONENT] : DEFAULT_LOGIN_URL_COMPONENT ;
}
- (NSString *)applicationName { return [[self class] applicationName] ; }
- (NSString *)applicationFullName { return [[self class] applicationFullName] ; }
- (NSString *)instanceName { return _instanceName ; }
- (BOOL)isAdminApplication {return NO ; }

- (NSString *)postProcessingURL { if(!_postProcessingURL) { ASSIGN(_postProcessingURL,[[self baseURL] stringByAppendingString:@"postproc"]) ; } return _postProcessingURL ; }

- (NSString *)authenticatedResourceURL {
    if(!_authenticatedResourceURL) {
        NSString *url = [NSString stringWithFormat:@"%@%@/", [self baseURL], [MHDownloadResource authenticatedResourceURLComponent]] ;
        ASSIGN(_authenticatedResourceURL, url) ;
    }
    return _authenticatedResourceURL ;
}

- (NSString *)publicResourceURL {
    if(!_publicResourceURL)
    {
        NSString *url = [NSString stringWithFormat:@"%@%@/", [self baseURL], [MHDownloadResource publicResourceURLComponent]] ;
        ASSIGN(_publicResourceURL, url) ;
    }
    return _publicResourceURL ;
}

- (NSString *)uncURL {
    NSString *url = [NSString stringWithFormat:@"%@%@/", [self baseURL], [MHDownloadResource resourceUNCURLComponent]] ;
    if(!_uncURL) {
        ASSIGN(_uncURL, url) ;
    }
    return _uncURL ;
}

- (void)setBundle:(NSBundle *)bundle
{
    _bundle = bundle ;
}

- (MHResource *)getResourceForURL:(NSString *)url
{
    return MHGetResourceFromCacheOrApplication(url, self, nil, 0) ;
}

- (NSString *)_getResourceSubDirectoryWithIsPublicResource:(BOOL)isPublicResource
{
    NSString *resourceSubDirectory = nil ;
    
    if ([self mustRespondWithAuthentication])
    {
        resourceSubDirectory = (isPublicResource) ? BUNDLE_PUBLIC_RESOURCE_SUBDIRECTORY : BUNDLE_AUTHENTICATED_RESOURCE_SUBDIRECTORY ;
    } else { //public application, any resource url points to the public resource subdirectory
        resourceSubDirectory = BUNDLE_PUBLIC_RESOURCE_SUBDIRECTORY ;
    }
    return resourceSubDirectory ;
}

// returns the content of the resource file or nil on error
- (MHResource *)getResourceFromBundleForURL:(NSString *)url mimeType:(NSString *)mimeType isPublicResource:(BOOL)isPublicResource
{
    MHResource *resource = nil ;
    
    if(_bundle)
    {
        NSRange range ;
        NSString *filePath ;
        NSString *shortURL  = url ;
        NSString *resourceURL = isPublicResource ? [self publicResourceURL] : [self authenticatedResourceURL] ;
        NSString *resourceSubDirectory = [self _getResourceSubDirectoryWithIsPublicResource:isPublicResource] ; // compute resourceURL and resourceSubDirectory according to the application type
        
        // removes everything after the interrogation mark
        range = [url rangeOfString:@"?"] ;
        if(range.location != NSNotFound)
        {
            shortURL = [url substringToIndex:range.location] ;
        }
        
        range = [shortURL rangeOfString:resourceURL] ;
        if(range.location == 0)
        {
            NSString *directory = [resourceSubDirectory stringByAppendingPathComponent:[[shortURL substringFromIndex:(range.location + range.length)] stringByDeletingLastPathComponent]] ;
            
            filePath = [_bundle pathForResource:[[shortURL lastPathComponent] stringByDeletingPathExtension]
                                         ofType:[[shortURL lastPathComponent] pathExtension]
                                    inDirectory:directory] ;
            resource = [MHDownloadResource resourceWithContentsOfFile:filePath name:[shortURL lastPathComponent] mimeType:mimeType forApplication:self] ;
        }
    }
    return resource;
}

- (BOOL)resourceExistsInCacheForURL:(NSString *)url
{
    return MHResourceExistsInCache(url) ;
}

- (NSString *)getUploadResourceURLForID:(NSString *)uploadID
{
    return MHGetUploadResourceURLForID(self, uploadID) ;
}

- (void)logWithLevel:(MHAppLogLevel)level log:(NSString *)log, ...
{
    va_list list ;
    va_start (list, log) ;
    
    [_logger logWithLevel:(MHLogLevel)level application:[ISA(self) applicationName] log:log args:list] ;

    va_end(list) ;
}

- (MHAppLogLevel)logLevel
{
    return [_logger logLevel] ;
}

- (NSDictionary *)parameterForKey:(NSString *)key
{
    NSString *bundleName = NSStringFromClass([_bundle principalClass]) ;
    NSMutableDictionary *params = [[MHBundlesConfig() objectForKey:bundleName] objectForKey:key] ;
    NSMutableDictionary *generalParams = [[MHBundlesConfig() objectForKey:@"general"] objectForKey:key] ;
    
    if(params) return params ;
    if (generalParams) return generalParams ;
    return [NSDictionary dictionary] ;
}

- (BOOL)hasUploadSupport { [self notImplemented:_cmd] ; return NO ; }

- (MSUInt)getKeepAliveTimeout { return [[self parameterNamed:@"keepAliveTimeout"] intValue] ; }
- (MSUInt)getKeepAliveInterval { return ([self getKeepAliveTimeout] / 3) ; }

- (NSString *)convertUncFromUrl:(NSString *)url
{
    NSArray *urlComponents = [url componentsSeparatedByString:@"/"] ;
    return [NSString stringWithFormat:@"\\\\%@", [urlComponents componentsJoinedByString:@"\\"]] ;
}

@end


@implementation MHPublicApplication

- (BOOL)mustRespondWithAuthentication { return NO ; }

@end

static MSUInt __authenticatedApplicationDefaultAuthenticationMethods = MHAuthNone ;

@implementation MHAuthenticatedApplication

- (id)initOnBaseURL:(NSString *)url instanceName:(NSString *)instanceName withLogger:(id)logger parameters:(NSDictionary *)parameters
{
    if ([super initOnBaseURL:url instanceName:instanceName withLogger:logger parameters:parameters])
    {
        ASSIGN(_tickets, [NSMutableDictionary dictionary]) ;
        ASSIGN(_ticketsMutex, [MSMutex mutex]) ;
        _authenticationMethods = [ISA(self) defaultAuthenticationMethods] ;
        
        return self ;
    }
    return nil ;
}

- (void)dealloc
{
    DESTROY(_loginInterface) ;
    DESTROY(_tickets) ;
    DESTROY(_ticketsMutex) ;
    
    [super dealloc] ;
}

- (BOOL)mustRespondWithAuthentication { return YES ; }

- (void)validateAuthentication:(MHNotification *)notification login:(NSString *)login password:(NSString *)password certificate:(MSCertificate *)certificate
{
    MHVALIDATE_AUTHENTICATION(NO, nil) ;
}

- (NSString *)generateChallengeForMessage:(MHHTTPMessage *)httpMessage plainStoredChallenge:(NSString **)plainChallenge additionalStoredObject:(id *)object
{
    NSString *retChallenge = nil ;
    MSBuffer *randBuff = nil ;
    MSBuffer *base64Buf = nil ;
    
    randBuff = MSCreateRandomBuffer(8) ;
    base64Buf = [randBuff encodedToBase64] ;
    
    retChallenge = AUTORELEASE(MSCreateASCIIStringWithBytes((void *)[base64Buf bytes], [base64Buf length], YES, YES)) ;
    *plainChallenge = retChallenge ;
    
    return retChallenge ;
}

#define SESSION_PARAM_CHALLENGE     @"__SESS_CHALLENGE__"
#define SESSION_PARAM_ADDED_OBJECT     @"__SESS_CHALLENGE_ADDED_OBJECT__"
- (NSString *)sessionChallengeMemberName { return SESSION_PARAM_CHALLENGE ; }
- (NSString *)sessionChallengeAdditionalObjectMemberName { return SESSION_PARAM_ADDED_OBJECT ; }

- (NSString *)_generateNewTicketID
{
    MSUInt newID = fabs(floor(GMTNow())) ;
    MSUInt addrID = (MSUInt)rand() ;
    return [NSString stringWithFormat:@"TKT%04X%08X%04X", addrID & 0x0000FFFF, newID, (addrID >> 16)  & 0x0000FFFF] ;
}

- (NSString *)_uniqueTicketID
{
    NSString *ticket = nil ;
    do {
        ticket = [self _generateNewTicketID] ;
    } while ([_tickets objectForKey:ticket]) ;
    
    return ticket ;
}

#define MHAPP_TICKET_VALIDITY      @"ticketValidity"
#define MHAPP_TICKET_PARAMETERS     @"ticketParameters"
- (void)validateAuthentication:(MHNotification *)notification ticket:(NSString *)ticket certificate:(MSCertificate *)certificate
{
    NSDictionary *ticketFound = [[self tickets] objectForKey:ticket] ;
    
    if (ticketFound)
    {
        MSTimeInterval ticketValidityEnd = [[ticketFound objectForKey:MHAPP_TICKET_VALIDITY] longLongValue] ;
        if (GMTNow() < ticketValidityEnd)
        {
            [self logWithLevel:MHAppDebug log:@"Ticket Authentication success"] ;
            MHVALIDATE_AUTHENTICATION(YES, nil) ;
        } else
        {
            [self logWithLevel:MHAppDebug log:@"Ticket Authentication failure : ticket expired"] ;
        }
    } else
    {
        [self logWithLevel:MHAppDebug log:@"Ticket Authentication failure : ticket not found"] ;
    }
    MHVALIDATE_AUTHENTICATION(NO, nil) ;
}

- (void)validateAuthentication:(MHNotification *)notification challenge:(NSString *)challenge certificate:(MSCertificate *)certificate
{
    if ([challenge length])
    {
        NSString *storedPlainChallenge = [notification memberNamedInSession:[self sessionChallengeMemberName]] ;
        
        if ([storedPlainChallenge length])
        {
            if ([challenge isEqualToString:storedPlainChallenge])
            {
                [self logWithLevel:MHAppDebug log:@"Challenge Authentication success"] ;
                MHVALIDATE_AUTHENTICATION(YES, nil) ;
            }
        } else
        {
            [self logWithLevel:MHAppDebug log:@"Challenge Authentication failure : stored challenge not found"] ;
            MHVALIDATE_AUTHENTICATION(NO, nil) ;
        }
    } else
    {
        [self logWithLevel:MHAppDebug log:@"Challenge Authentication failure : challenge not found"] ;
    }
    MHVALIDATE_AUTHENTICATION(NO, nil) ;
}

- (void)validateAuthentication:(MHNotification *)notification certificate:(MSCertificate *)certificate
{
    MHVALIDATE_AUTHENTICATION(NO, nil) ;
}

- (BOOL)canAuthenticateWithTicket { return NO ; }

- (MSBuffer *)loginInterfaceWithMessage:(MHHTTPMessage *)message errorMessage:(NSString *)error { [self notImplemented:_cmd] ; return nil ; }

- (MSBuffer *)firstPage:(MHNotification *)notification { return nil ; }

+ (MSUInt)authentifiedSessionTimeout { return SESSION_DEFAULT_AUTHENTICATED_TIMEOUT ; }

- (NSMutableDictionary *)tickets { return _tickets ; }

- (void)setTickets:(NSDictionary *)tickets { ASSIGN(_tickets, tickets) ; }


- (BOOL)canAuthenticateWithLoginPassword { return _authenticationMethods & MHAuthLoginPass ; }
- (BOOL)canAuthenticateWithLoginTicket { return _authenticationMethods & MHAuthTicket ; }
- (BOOL)canAuthenticateWithChallenge { return _authenticationMethods & MHAuthChallenge ; }
- (BOOL)canAuthenticateWithCustomAuthentication { return _authenticationMethods & MHAuthCustom ; }

+ (MSUInt)defaultAuthenticationMethods { return __authenticatedApplicationDefaultAuthenticationMethods ; }
- (MSUInt)authenticationMethods { return _authenticationMethods ; }

- (void)setAuthenticationMethods:(MSUInt)authenticationMethods { _authenticationMethods |= authenticationMethods ; }
- (void)setAuthentificationMethod:(MHAppAuthentication)authenticationMethod { _authenticationMethods |= authenticationMethod ; }
- (void)unsetAuthentificationMethod:(MHAppAuthentication)authenticationMethod { _authenticationMethods &= ~authenticationMethod ; }


- (NSString *)ticketForValidity:(MSTimeInterval)duration
{
    NSString *newTicket ;
    MSTimeInterval ticketEndValidity ;
    NSMutableDictionary *ticketDictionary ;
    
    [_ticketsMutex lock] ;
    
    newTicket = [self _uniqueTicketID] ;
    if(duration != 0){ 
        ticketEndValidity = GMTNow() + duration ;
    }
    else{ //validité permanente : duration = 0
        ticketEndValidity = 0 ;        
    }
    ticketDictionary = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithLongLong:ticketEndValidity] forKey:MHAPP_TICKET_VALIDITY] ;
    [_tickets setObject:ticketDictionary forKey:newTicket] ;
    
    [_ticketsMutex unlock] ;
    
    return newTicket ;
}

- (void)setObject:(id)object forTicket:(NSString *)ticket
{
    if ([ticket length])
    {
        NSMutableDictionary *ticketDictionary  = [_tickets objectForKey:ticket] ;
        
        if (ticketDictionary)
        {
            [ticketDictionary setObject:object forKey:MHAPP_TICKET_PARAMETERS] ;
        }
    }
}

- (id)_objectForTicket:(NSString *)ticket key:(NSString *)key
{
    id ret = nil ;
    
    if ([ticket length])
    {
        NSDictionary *ticketDictionary = [_tickets objectForKey:ticket] ;
        if (ticketDictionary)
        {
            ret = [ticketDictionary objectForKey:key] ;
        }
    }
    
    return ret ;
}

- (id)objectForTicket:(NSString *)ticket
{
    return [self _objectForTicket:ticket key:MHAPP_TICKET_PARAMETERS] ;
}

- (NSNumber *)validityForTicket:(NSString *)ticket
{
    return [self _objectForTicket:ticket key:MHAPP_TICKET_VALIDITY] ;
}

- (void)removeTicket:(NSString *)ticket
{
    [_ticketsMutex lock] ;
    if ([ticket length])
    {
        [_tickets removeObjectForKey:ticket] ;
    }
    [_ticketsMutex unlock] ;
}


- (void)_deleteExpiredTickets
{
    NSEnumerator *ticketEnum = [_tickets keyEnumerator] ;
    NSString *ticket = nil ;
    NSMutableArray *ticketsArray = [NSMutableArray array];
    
    while ((ticket = [ticketEnum nextObject]))
    {
        MSTimeInterval ticketValidityEnd = [[[_tickets objectForKey:ticket] objectForKey:MHAPP_TICKET_VALIDITY] longLongValue] ;
        if (GMTNow() > ticketValidityEnd)
        {
            if(ticketValidityEnd!=0){
                [ticketsArray addObject:ticket];
            }
        }
    }
    [_tickets removeObjectsForKeys:ticketsArray] ;
}

- (void)clean
{
    if ([self canAuthenticateWithTicket])
    {
        [self _deleteExpiredTickets] ;
    }
    
    [super clean] ;
}

#define MHAPP_DEFAULT_LOGIN_FIELD_NAME      @"mhuser"
#define MHAPP_DEFAULT_PASSWORD_FIELD_NAME   @"mhpass"
#define MHAPP_DEFAULT_CHALLENGE_FIELD_NAME  @"mhchallenge"

- (NSString *)loginFieldName { return MHAPP_DEFAULT_LOGIN_FIELD_NAME ; }
- (NSString *)passwordFieldName { return MHAPP_DEFAULT_PASSWORD_FIELD_NAME ; }
- (NSString *)challengeFieldName { return MHAPP_DEFAULT_CHALLENGE_FIELD_NAME ; }

@end

static MSUInt __guiAuthenticatedApplicationDefaultAuthenticationMethods = MHAuthLoginPass ;

@implementation MHGUIAuthenticatedApplication

- (id)initOnBaseURL:(NSString *)url instanceName:(NSString *)instanceName withLogger:(id)logger parameters:(NSDictionary *)parameters
{
    if ([super initOnBaseURL:url instanceName:instanceName withLogger:logger parameters:parameters])
    {
        ASSIGN(_tickets, [NSMutableDictionary dictionary]) ;
        ASSIGN(_ticketsMutex, [MSMutex mutex]) ;
        _authenticationMethods |= [ISA(self) defaultAuthenticationMethods] ;
        
        return self ;
    }
    return nil ;
}

+ (MSUInt)defaultAuthenticationMethods { return __guiAuthenticatedApplicationDefaultAuthenticationMethods ; }

- (MSBuffer *)loginInterfaceWithMessage:(MHHTTPMessage *)message errorMessage:(NSString *)error
{
    NSString *appName = nil ;
    NSString *file = nil ;
    NSString *fileName = @"application_login" ;
    BOOL isDir = NO ;
    MSBuffer *loginInterface = nil ;
    
    file = [[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:@"html"] ;
    
    if(!file) {
        file = [[NSBundle bundleForClass:[self class]] pathForResource:@"default_application_login" ofType:@"html"] ;
    }

    appName = ([[self instanceName] length]) ? [[self instanceName] htmlRepresentation] : [[self applicationFullName] htmlRepresentation] ;
    if (![appName length]) { appName = @"g&eacute;n&eacute;rale" ; }
    
    if (MSFileExistsAtPath(file, &isDir) && !isDir)
    {
        void *bytes ;
        NSMutableString *page = MHOpenFileForSubstitutions(file) ;
        
        page = [page replaceOccurrencesOfString:@"%__APPLICATION_NAME__%" withString:appName] ;
        page = [page replaceOccurrencesOfString:@"%__ERROR_MESSAGE__%" withString:[error length] ? error : @""] ;
        page = [page replaceOccurrencesOfString:@"%__ACTION_URL__%" withString:[NSString stringWithFormat:@"/%@",[self baseURL]]] ;
        
        bytes = (void *)[page UTF8String] ;
        loginInterface = AUTORELEASE(MSCreateBufferWithBytes(bytes, strlen(bytes))) ;
        
    } else
    {
        MSRaise(NSGenericException, @"MHGUIAuthenticatedApplication : cannot find interface templace at path '%@'", file) ;
    }
    
    return loginInterface ;
}

#define DEFAULT_PASSWORD    @"password"
#define DEFAULT_LOGIN       @"login"
#define DEFAULT_LOGIN_ERROR_MESSAGE "Wrong login or password"

- (void)validateAuthentication:(MHNotification *)notification login:(NSString *)login password:(NSString *)password certificate:(MSCertificate *)certificate
{
    if([DEFAULT_LOGIN isEqual:login] && [DEFAULT_PASSWORD isEqual:password])
    {
        MHVALIDATE_AUTHENTICATION(YES, nil) ;
    }
    else
    {
        MHVALIDATE_AUTHENTICATION(NO, MSCreateBufferWithBytesNoCopyNoFree(DEFAULT_LOGIN_ERROR_MESSAGE,strlen(DEFAULT_LOGIN_ERROR_MESSAGE))) ;
    }
    
}


@end

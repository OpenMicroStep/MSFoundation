/*
 
 _MHServerPrivate.h
 
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

@class MHApplication, MHSession, MHContext, MHResource, MHDownloadResource, MHNotification, MHHTTPMessage ;

#define BLACKLIST_SIZE 500
#define WHITELIST_SIZE 16 // 8 pairs of ipv4 addresses
#define NOT_AUTHENTIFIED_SESSION_TIMEOUT 100

#define MHBadPort		((MSUShort)-1)
#define MHBadAddress	((MSUInt)-1)

#define MH_LOG_ENTER(X) MHServerLogWithLevel(MHLogDevel, @"enters '%@'", X) ;
#define MH_LOG_LEAVE(X) MHServerLogWithLevel(MHLogDevel, @"leaves '%@'", X) ;

//admin application url
#define ADMIN_APPLICATION_URL   @"admin/"

//standard sub url components
#define RESOURCE_AUTHENTICATED_URL_COMPONENT            @"resources"
#define RESOURCE_PUBLIC_URL_COMPONENT                   @"publicResources"
#define RESOURCE_URL_UNC_COMPONENT                      @"unc"
#define RESOURCE_UPLOAD_URL_COMPONENT                   @"upload"

#define KEEP_ALIVE_URL_COMPONENT @"keepAlive"
#define GET_KEEP_ALIVE_INTERVAL_URL_COMPONENT @"getInterval"

#define BASE_URL_COMPONENT_COUNT_STATIC_MODE    1
#define BASE_URL_COMPONENT_COUNT_BUNDLE_MODE    3

typedef struct
{
    unsigned long ipv4;
    time_t timestamp;
} ip_log;

struct app_port_ctx_st {
    void *ssl_ctx ;
    void *applications ;
    BOOL twoWayAuth ;
} ;

typedef struct app_port_ctx_st APPLICATION_PORT_CTX;

typedef enum {
    NO_CHUNKS,
	CHUNK_SENDING_HEAD,
    CHUNK_SENDING_BODY,
    CHUNK_SENDING_TAIL,
} MHChunkSendingPart;

MSInt MHServerInitialize(NSArray *params, Class staticAppClassName) ;
MSInt MHMainThread(void) ;

NSMutableDictionary *MHBundlesConfig(void) ;

MSUInt maxClientProcessingRequests(void) ;
MSUInt currentClientProcessingRequestCount(void) ;
MSUShort maxClientReadingThreads(void) ;
MSUShort usedClientReadingThreads(void) ;
MSUShort maxClientProcessingThreads(void) ;
MSUShort usedClientProcessingThreads(void) ;
MSUShort maxClientWaitingThreads(void) ;
MSUShort usedClientWaitingThreads(void) ;

MSInt adminPort(void) ;
MSUInt maxAdminProcessingRequests(void) ;
MSUInt currentAdminProcessingRequestCount(void) ;
MSUShort maxAdminReadingThreads(void) ;
MSUShort usedAdminReadingThreads(void) ;
MSUShort maxAdminProcessingThreads(void) ;
MSUShort usedAdminProcessingThreads(void) ;
MSUShort maxAdminWaitingThreads(void) ;
MSUShort usedAdminWaitingThreads(void) ;

NSArray *allApplicationPorts(void) ;
NSArray *allApplicationsForPort(MSInt listeningPort) ;
void addApplicationPortCtxForPort(MSInt listeningPort, APPLICATION_PORT_CTX *appCtx) ;
APPLICATION_PORT_CTX *applicationCtxForPort(MSInt listeningPort) ;
MHApplication *applicationForPortAndKey(MSInt listeningPort, NSString *key) ;
void setApplicationForPortAndKey(MSInt listeningPort, MHApplication *application, NSString *key) ;
void removeApplicationForKeyAndPort(NSString *key) ;
MSCouple *listeningPortsSortedBySSLAuthMode(void) ;

NSArray *allSessions(void) ;
MHSession *sessionForKey(NSString *key) ;
MHSession *sessionWithKeyForApplication(NSString *key, MHApplication *application) ;
void setSessionForKey(MHSession *session, NSString *key) ;
void changeSessionIDForKey(MHSession *session, NSString *key, NSString *newKey) ;
void removeSessionForKey(NSString *key) ;
void lock_sessions_mutex(void) ;
void unlock_sessions_mutex(void) ;

MHContext *contextForKey(NSString *key) ;
void setContextForKey(MHContext *context, NSString *key) ;
void removeContextForKey(NSString *key) ;
void lock_contexts_mutex(void) ;
void unlock_contexts_mutex(void) ;

NSArray *allResources(void) ;
MHResource *resourceForKey(NSString *key) ;
void setResourceForKey(MHResource *resource, NSString *key) ;
void removeResourceForKey(NSString *key) ;
void lock_resources_mutex(void) ;
void unlock_resources_mutex(void) ;

//tickets
NSArray *allApplicationsTickets(void) ;
NSString *ticketForValidity(MHApplication *application, MSTimeInterval duration) ;
NSString *ticketForValidityAndLinkedSession(MHApplication *application, MSTimeInterval duration, NSString *linkedSessionID, BOOL useOnce, MHTicketFormatterCallback ticketFormatterCallback) ;
NSMutableDictionary *getTicket(MHApplication *application, NSString *ticket) ;
NSMutableDictionary *ticketsForApplication(MHApplication *application) ;
void setTicketsForApplication(MHApplication *application, NSDictionary *tickets) ;
id objectForTicket(MHApplication *application, NSString *ticket) ;
void setObjectForTicket(MHApplication *application, id object, NSString *ticket) ;
NSNumber *validityForTicket(MHApplication *application, NSString *ticket) ;
NSNumber *creationDateForTicket(MHApplication *application, NSString *ticket) ;
NSString *linkedSessionForTicket(MHApplication *application, NSString *ticket) ;
void removeTicket(MHApplication *application, NSString *ticket) ;
void lock_authentication_tickets_mutex(void) ;
void unlock_authentication_tickets_mutex(void) ;

void lock_blacklist_mutex(void) ;
void unlock_blacklist_mutex(void) ;
void delete_blacklist_mutex(void) ;
void qsort_iplist(void) ;
ip_log *iplistAtIndex(int index) ;

unsigned long *blacklistAtIndex(int index) ;
void blacklist_ip(unsigned long ip) ;
void removeFromBlacklist(unsigned long ip) ;

void MHUpdateStatsForClientIP(unsigned long ip) ;
void MHCleanStats(void) ;

void MHPutResourceInCache(MHResource *aResource) ;
BOOL MHPrepareAndCacheResource(MHDownloadResource *resource, NSArray *childrenResources, BOOL useOnce, MSULong lifetime, BOOL forceToDisk) ;
BOOL MHResourceExistsInCache(NSString *url) ;
MHDownloadResource *MHGetResourceFromCacheOrApplication(NSString *url, MHApplication *application, NSString *mimeType, MHNotificationType notificationType) ;
BOOL MHPostProcess(MHDownloadResource *input, MHDownloadResource *parameters, MHDownloadResource **output, MHDownloadResource **html, MHHTTPMessage *message) ;
void MHPreparePostProcess(MHHTTPMessage *message, BOOL isAdmin) ;
NSString *MHGetUploadResourceURLForID(MHApplication *application, NSString *uploadID) ;
BOOL MHRespondToClientOnSocket(MHSSLSocket *secureSocket, MSBuffer *body, MSUInt status, BOOL isAdmin) ;
BOOL MHRespondToClientOnSocketWithAdditionalHeaders(MHSSLSocket *secureSocket, MSBuffer *body, MSUInt status, BOOL isAdmin, NSDictionary *headers, MHSession *session, BOOL canCompress) ;
BOOL MHRespondToClientOnSocketWithAdditionalHeadersAndChunks(MHSSLSocket *secureSocket, MSBuffer *body, MSUInt status, BOOL isAdmin, NSDictionary *headers, MHSession *session, BOOL canCompress, BOOL sendChuncks, MHChunkSendingPart chunkPosition, MSLong totalLength) ;
void MHSendResourceOrHTTPNotModifiedToClientOnSocket(MHSSLSocket *secureSocket, MHDownloadResource *resource, BOOL isAdmin, MHSession *session, MHHTTPMessage *message, NSDictionary *headers) ;
BOOL MHSendResourceToClientOnSocket(MHSSLSocket *secureSocket, MHDownloadResource *resource, BOOL isAdmin, MHSession *session, MHHTTPMessage *message, NSDictionary *headers) ;
BOOL MHReplyWithNewUploadID(MHSSLSocket *secureSocket, MHApplication *application);
BOOL MHRedirectToURL(MHSSLSocket *secureSocket, NSString *URL, BOOL isPermanent) ;
BOOL MHCloseBrowserSession(MHSSLSocket *secureSocket, MHSession *session, MSUInt status) ;

void _fatal_error(const char *msg, int errcode) ;
MSUInt _MHIPAddressFromString(NSString *string) ;

BOOL MHSendDataOnConnectedSSLSocket(MSBuffer *aData, MHSSLSocket *secureSocket, NSString **anError) ;
MSLong MHReceiveDataOnConnectedSSLSocket(MHSSLSocket *secureSocket, void *buffer, MSInt length) ;

void MHEnqueueWaitingNotification(MHNotification *aNotif) ;
BOOL MHProcessingEnqueueNotification(MHNotification *aNotif) ; //to use to enqueue a new incoming request
BOOL MHProcessingRequeueNotification(MHNotification *aNotif) ; //to use to requeue a waiting request
MHNotification *MHProcessingDequeueNotification(BOOL admin) ; //to use to dequeue a new incoming request
void MHCancelAllProcessingNotificationsForClientSocket(SOCKET fd, BOOL isAdminNotification) ;

//login functions
MHContext *MHCreateInitialContextAndSession(MHApplication *application, MHAppAuthentication authenticationType) ;
void MHDestroySession(MHSession *session) ;
void MHSendSessionAndContext(MHSSLSocket *secureSocket, MHContext *context, BOOL isAdmin) ;
void MHValidateAuthentication(MHNotification *notification, BOOL isAuthenticated, MSBuffer *body) ;

//log functions
void MHServerLogWithLevel(MHLogLevel level, NSString *log, ...) ;
void MHServerSetLogMode(MHLogMode mode, BOOL enabled) ;
void MHServerSetLogLevel(MHLogLevel level) ;

//socket fonctions
BOOL MHSendDataOnConnectedSocket(MSBuffer *aData, MSInt socket, NSString **anError) ;

//temporary folders
BOOL MHMakeTemporaryDir(NSString *name) ;
NSString *MHMakeTemporaryName(void) ;
NSString *MHMakeTemporaryFileName(void) ;

//Notification macro
#define MHProcessingEnqueueNotificationOrSendError() if (!MHProcessingEnqueueNotification(notification)) { \
[notification end] ; \
_send_error_message(secureSocket, HTTP_503_RESPONSE); \
}

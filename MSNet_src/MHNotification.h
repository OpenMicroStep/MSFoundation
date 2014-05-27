/*
 
 MHNotification.h
 
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


@class MHHTTPMessage ;
//@class MHContext ;
@class MHSession ;
@class MHDownloadResource ;
@class MHSSLSocket ;

#define MH_FAILURE_REASON_NONE          0
#define MH_FAILURE_REASON_DISCONNECTED  1
#define MH_FAILURE_REASON_TIMEOUT       2
#define MH_FAILURE_REASON_DELAYED_SEND  3

#define DEFAULT_NOTIFICATION_READ_BUFFER_SIZE 256

typedef enum {
    MHStandardNotification = 1,
    MHAuthenticatedResourceDownload,
    MHPublicResourceDownload,
    MHUncResourceDownload,
    MHResourceUpload
} MHNotificationType ;

typedef enum {
    MHSocketSendingSucceeded = 0,
    MHSocketSendingFailed,
    MHSocketDelayedSending
} MHSocketSendingStatus ;

typedef enum {
    MHAuthUndefined      = 0,    //Authentification not defined yet
    MHAuthNone           = 1,    //No authentication
    MHAuthCustom         = 2,    //application defined authentication
    MHAuthLoginPass      = 4,    //MHGUIAuthenticatedApplication : mhlogin + mhpasword
    MHAuthTicket         = 16,   //ticket auth
    MHAuthChallenge      = 32    //challenge auth
} MHAppAuthentication ;

@interface MHNotification : MHBunchableObject
{
@private
    MHHTTPMessage *_message ;
//    MHContext *_context ;
    MHSession *_session ;
    id _originalTarget ; //must be a sub class of MHApplication (not released)
    id _target ;
    id<MHSocketReceiver> _receiverDelegate ;
    NSString *_action ;
    NSString *_finalAction ;
    NSMutableDictionary *_members ; //local variables to store between two notification treatments
    MSInt _fd ;
    MHSSLSocket *_secureSocket ;
    MSTimeInterval _expirationDate ;
    MSUInt _failureReason ;
    MSBuffer *_readBuffer ;
    MSBuffer *_delayedWriteBuffer ;
    BOOL _delayedSSLSocket ;
    MSUInt _delayedTimeOutInSeconds ;
    MHNotificationType _notificationType ;
    BOOL _isAdminNotification ;
}

/*+ (id)retainedNotificationWithMessage:(MHHTTPMessage *)message context:(MHContext *)context retainedTarget:(id)retainedTarget retainedAction:(NSString *)retainedAction isResourceRequest:(BOOL)isresource isAdminNotification:(BOOL)isAdmin;*/
+ (id)retainedNotificationWithMessage:(MHHTTPMessage *)message session:(MHSession *)session retainedTarget:(id)retainedTarget retainedAction:(NSString *)retainedAction notificationType:(MHNotificationType)notificationType isAdminNotification:(BOOL)isAdmin;

//method to call to connect on an external server socket
- (MSInt)newSocketOnServer:(NSString *)server port:(MSUInt)port isBlockingIO:(BOOL)isBlockingIO ;
- (MHSSLSocket *)newSSLSocketOnServer:(NSString *)server port:(MSUInt)port certificateFile:(NSString *)certPath keyFile:(NSString *)keyPath CAFile:(NSString *)CAPath sslOptions:(MSLong)sslOptions isBlockingIO:(BOOL)isBlockingIO ;
//method to call to send a non blocking message on a socket open to a external process
- (MHSocketSendingStatus)sendData:(MSBuffer *)data onSocket:(MSInt)fd retainedTarget:(id)target retainedReceiverDelegate:(id<MHSocketReceiver>)delegate action:(NSString *)action timeout:(MSUInt)seconds allowsDelayedSending:(BOOL)canDelay ;
- (MHSocketSendingStatus)sendData:(MSBuffer *)data onSSLSocket:(MHSSLSocket *)secureSocket retainedTarget:(id)target retainedReceiverDelegate:(id<MHSocketReceiver>)delegate action:(NSString *)action timeout:(MSUInt)seconds allowsDelayedSending:(BOOL)canDelay ;
- (MSLong)receiveWaitingData:(void *)buffer length:(MSInt)length ;
//method to call to wait more data from a previous reception on a socket open to a external process
- (void)waitForData ;
- (void)waitForNextDataRetainedTarget:(id)target retainedReceiverDelegate:(id<MHSocketReceiver>)delegate action:(NSString *)action timeout:(MSUInt)seconds ;
//method to call to continue notification processing after received all expected datas on a socket open to a external process
- (void)continueAfterEndReceiveData ;
- (BOOL)prepareAndCacheResource:(MHDownloadResource *)resource childrenResources:(NSArray *)childRes useOnce:(BOOL)useOnce lifetime:(MSULong)seconds forceToDisk:(BOOL)forceToDisk ;
- (BOOL)postProcessInput:(MHDownloadResource *)input withParameters:(MHDownloadResource *)parameters toOutputResource:(MHDownloadResource **)output andToOutputHTMLResource:(MHDownloadResource **)html usingValuesFromMessage:(MHHTTPMessage *)message ;
//method to call to redirect client to an url
- (BOOL)redirectToURL:(NSString *)url ;

//method to call to send an http response to client
- (BOOL)respondsToMessageWithBody:(MSBuffer *)body httpStatus:(MSUInt)status headers:(NSDictionary *)headers closeSession:(BOOL)closeSession ;
- (BOOL)respondsToMessageWithResource:(MHDownloadResource *)resource useOnce:(BOOL)useOnce lifetime:(MSULong)seconds forMessage:(MHHTTPMessage *)message ;
- (BOOL)respondsToMessageWithResource:(MHDownloadResource *)resource useOnce:(BOOL)useOnce lifetime:(MSULong)seconds forMessage:(MHHTTPMessage *)message additionalHeaders:(NSDictionary *)headers ;
//method to call to cache resources
- (BOOL)respondsToMessageWithResource:(MHDownloadResource *)resource childrenResources:(NSArray *)childrenResources useOnce:(BOOL)useOnce lifetime:(MSULong)seconds ;

- (void)validateAuthentication:(BOOL)isAuthenticated firstPageBody:(MSBuffer *)body ;

- (MSBuffer *)readBuffer ; //Will contains the incoming datas after calling sendData:onSocket:retainedReceiverTarget:action:timeout:allowsDelayedSending:
- (void)setReadBuffer:(MSBuffer *)buffer ; //replace and retain the buffer that will contains the incoming datas after calling sendData:onSocket:retainedReceiverTarget:action:timeout:allowsDelayedSending:
- (MSBuffer *)newReadBuffer ; //Create a new buffer that will contains the incoming datas after calling sendData:onSocket:retainedReceiverTarget:action:timeout:allowsDelayedSending:
- (MSBuffer *)newReadBufferWithSize:(MSUInt)size ; //Like newReadBuffer but specify a buffer size to optimize memory allocation

#define MHSEND_DATA(D, S, T, A, O, B) { \
BOOL res = [notification sendData:D onSocket:S retainedTarget:T retainedReceiverDelegate:nil action:A timeout:O allowsDelayedSending:B] ; \
if (res) MSRaise(NSGenericException, [NSString stringWithFormat:@"sendData:onSocket:retainedTarget:retainedReceiverDelegate:action:timeout:allowsDelayedSending: Error while sending message on socket %u [%s:%d]", S,__FILE__,__LINE__]) ; \
return ; \
}

#define MHSEND_DATA_WITH_DELEGATE(D, S, T, A, O, G, B) { \
BOOL res = [notification sendData:D onSocket:S retainedTarget:T retainedReceiverDelegate:G action:A timeout:O allowsDelayedSending:B] ; \
if (res) MSRaise(NSGenericException, [NSString stringWithFormat:@"sendData:onSocket:retainedTarget:retainedReceiverDelegate:action:timeout:allowsDelayedSending: Error while sending message on socket %u [%s:%d]", S,__FILE__,__LINE__]) ; \
return ; \
}

#define MHSECURE_SEND_DATA(D, S, T, A, O, B) { \
BOOL res ; \
if ([S isBlocking]) { MSRaise(NSGenericException, [NSString stringWithFormat:@"sendData:onSSLSocket:retainedTarget:retainedReceiverDelegate:action:timeout:allowsDelayedSending: Error while sending message, socket must be non blocking : %u [%s:%d]", [S socket],__FILE__,__LINE__]) ; } \
res = [notification sendData:D onSSLSocket:S retainedTarget:T retainedReceiverDelegate:nil action:A timeout:O allowsDelayedSending:B] ; \
if (res) MSRaise(NSGenericException, [NSString stringWithFormat:@"sendData:onSSLSocket:retainedTarget:retainedReceiverDelegate:action:timeout:allowsDelayedSending: Error while sending message on socket %u [%s:%d]", [S socket],__FILE__,__LINE__]) ; \
return ; \
}

#define MHSECURE_SEND_DATA_WITH_DELEGATE(D, S, T, A, O, G, B) { \
BOOL res \
if ([S isBlocking]) { MSRaise(NSGenericException, [NSString stringWithFormat:@"sendData:onSSLSocket:retainedTarget:retainedReceiverDelegate:action:timeout:allowsDelayedSending: Error while sending message, socket must be non blocking : %u [%s:%d]", [S socket],__FILE__,__LINE__]) ; } \
res = [notification sendData:D onSSLSocket:S retainedTarget:T retainedReceiverDelegate:G action:A timeout:O allowsDelayedSending:B] ; \
if (res) MSRaise(NSGenericException, [NSString stringWithFormat:@"sendData:onSSLSocket:retainedTarget:retainedReceiverDelegate:action:timeout:allowsDelayedSending: Error while sending message on socket %u [%s:%d]", [S socket],__FILE__,__LINE__]) ; \
return ; \
}

#define MHRECEIVE_WAITING_DATA(B, L) [notification receiveWaitingData:B length:L] ;

#define MHWAIT_FOR_MORE_DATA [notification waitForData] ; return ;

#define MHWAIT_FOR_NEXT_DATA(T, D, A, S) [notification waitForNextDataRetainedTarget:T retainedReceiverDelegate:D action:A timeout:S] ; return ;

#define MHCONTINUE_AFTER_RECEIVE_DATA [notification continueAfterEndReceiveData] ; return ;

#define MHPREPARE_AND_CACHE_RESOURCE(R,C,O,L,D)  { \
BOOL res = [notification prepareAndCacheResource:R childrenResources:C useOnce:O lifetime:L forceToDisk:D] ; \
[notification end] ; \
if (!res) MSRaise(NSGenericException, [NSString stringWithFormat:@"prepareAndCacheResource: Error while caching resource [%s:%d]",__FILE__,__LINE__]) ; \
}

#define MHPOSTPROCESS(IR, PR, OR, HR, MSG)  { \
BOOL res = [notification postProcessInput:IR withParameters:PR toOutputResource:OR andToOutputHTMLResource:HR usingValuesFromMessage:MSG] ; \
if (!res) MSRaise(NSGenericException, [NSString stringWithFormat:@"postprocess: Error while post processing [%s:%d]",__FILE__,__LINE__]) ; \
}

#define MHREDIRECT_TO_URL(U)  { \
BOOL res = [notification redirectToURL:U] ; \
[notification end] ; \
if (!res) MSRaise(NSGenericException, [NSString stringWithFormat:@"redirectToURL: Error while responding on client socket [%s:%d]",__FILE__,__LINE__]) ; \
} \
return ;

#define MHRESPOND_TO_CLIENT(B, S, H)  { \
BOOL res = [notification respondsToMessageWithBody:B httpStatus:S headers:H closeSession:NO] ; \
[notification end] ; \
if (!res) MSRaise(NSGenericException, [NSString stringWithFormat:@"respondsToMessageWithBody:httpStatus:headers:closeSession:NO Error while responding on client socket [%s:%d]",__FILE__,__LINE__]) ; \
} \
return ;

#define MHRESPOND_TO_CLIENT_AND_CLOSE_SESSION(B, S, H)  { \
BOOL res = [notification respondsToMessageWithBody:B httpStatus:S headers:H closeSession:YES] ; \
[notification end] ; \
if (!res) MSRaise(NSGenericException, [NSString stringWithFormat:@"respondsToMessageWithBody:httpStatus:headers:closeSession:YES Error while responding on client socket [%s:%d]",__FILE__,__LINE__]) ; \
} \
return ;

#define MHSEND_RESOURCE_TO_CLIENT_WITH_HEADERS(R,O,L,M,H)  { \
BOOL res = [notification respondsToMessageWithResource:R useOnce:O lifetime:L forMessage:M additionalHeaders:H] ; \
[notification end] ; \
if (!res) MSRaise(NSGenericException, [NSString stringWithFormat:@"respondsToMessageWithResource:useOnce:lifetime:forMessage:additionalHeaders: Error while responding on client socket [%s:%d]",__FILE__,__LINE__]) ; \
} \
return ;

#define MHSEND_RESOURCE_TO_CLIENT(R,O,L,M)  { \
BOOL res = [notification respondsToMessageWithResource:R useOnce:O lifetime:L forMessage:M] ; \
[notification end] ; \
if (!res) MSRaise(NSGenericException, [NSString stringWithFormat:@"respondsToMessageWithResource:useOnce:lifetime:forMessage: Error while responding on client socket [%s:%d]",__FILE__,__LINE__]) ; \
} \
return ;

#define MHVALIDATE_AUTHENTICATION(I, B) [notification validateAuthentication:I firstPageBody:B] ; \
return ;

- (void)storeMember:(id)o named:(NSString *)name ;
- (id)memberNamed:(NSString *)name ;
- (void)removeMemberNamed:(NSString *)name ;

#define SET_MEMBER(O, N) [notification storeMember:O named:N]
#define GET_MEMBER(N) [notification memberNamed:N]
#define REMOVE_MEMBER(N) [notification removeMemberNamed:N]

- (void)storeMemberInSession:(id)o named:(NSString *)name ;
- (id)memberNamedInSession:(NSString *)name ;
- (void)removeMemberNamedInSession:(NSString *)name ;

#define SET_SESSION_MEMBER(O, N) [notification storeMemberInSession:O named:N]
#define GET_SESSION_MEMBER(N) [notification memberNamedInSession:N]
#define REMOVE_SESSION_MEMBER(N) [notification removeMemberNamedInSession:N]

#define MHGET_PEER_CERTIFICATE() [notification getPeerCertificate]

- (void)changeSessionIDOnResponse ;
#define MHCHANGE_SESSION_ID_ON_RESPONSE() [notification changeSessionIDOnResponse] ;

- (BOOL)processingRequeue ;
#define MHREQUEUE_NOTIFICATION() [notification processingRequeue] ; \
return ;


- (void)performActionOnTarget ;
- (MSTimeInterval)expirationDate;

- (BOOL)isAdminNotification ;
- (MHHTTPMessage*)message;

- (MHNotificationType)notificationType ;
//- (MHContext *)context ;
- (MHSession *)session ;
- (MHAppAuthentication)sessionAuthenticationType ;

- (void)closeSession ;
- (void)end ;

#define MHCLOSE_SESSION() [notification closeSession] ;

- (MSUInt)failureReason ;

@end


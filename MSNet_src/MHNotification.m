/*
 
 MHNotification.m
 
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
#import "_MHNotificationPrivate.h"

@implementation MHNotification

- (void)dealloc 
{
    DESTROY(_secureSocket) ;
    DESTROY(_message) ;
//    DESTROY(_context) ;
    DESTROY(_session) ;
    DESTROY(_action) ;
    DESTROY(_finalAction) ;
    DESTROY(_members) ;
    DESTROY(_readBuffer) ;
    DESTROY(_delayedWriteBuffer) ;
    [super dealloc] ;
}

/*+ (id)retainedNotificationWithMessage:(MHHTTPMessage *)message context:(MHContext *)context retainedTarget:(id)retainedTarget retainedAction:(NSString *)retainedAction isResourceRequest:(BOOL)isResource isAdminNotification:(BOOL)isAdmin
{
    return (id)CNotificationCreate(retainedMessage, retainedContext, retainedTarget, retainedAction, isResource, isAdmin) ;
}*/
+ (id)retainedNotificationWithMessage:(MHHTTPMessage *)message session:(MHSession *)session retainedTarget:(id)retainedTarget retainedAction:(NSString *)retainedAction notificationType:(MHNotificationType)notificationType isAdminNotification:(BOOL)isAdmin
{
    MHNotification *notification = (MHNotification*)CNotificationCreate(message, session, retainedTarget, retainedAction, notificationType, isAdmin) ;
    //add notification to notifications array of the session
//    [session addNotification:notification] ;
    [session addNotification] ;
    return notification ;
}

- (MSInt)newSocketOnServer:(NSString *)server port:(MSUInt)port isBlockingIO:(BOOL)isBlockingIO
{
    NSString *error = nil ;
    MSInt result = MHNewSocketOnServerPort(server, port, isBlockingIO, &error) ;
    if (error) {
        MSRaise(NSInternalInconsistencyException, @"[MHNotification newSocketOnServer:port:] : Unable to connect on server %@ port %u (%@)", server, port, error) ;
    }
    return result ;
}

- (MHSSLSocket *)newSSLSocketOnServer:(NSString *)server port:(MSUInt)port certificateFile:(NSString *)certPath keyFile:(NSString *)keyPath CAFile:(NSString *)CAPath sslOptions:(MSLong)sslOptions isBlockingIO:(BOOL)isBlockingIO 
{
    MHSSLClientSocket *secureSocket = [MHSSLClientSocket sslSocketWithCertificateFile:certPath keyFile:keyPath CAFile:CAPath sslOptions:sslOptions isBlockingIO:isBlockingIO] ;
    
    if(! [secureSocket connectOnServer:server port:port])
    {
        return nil ;
    }
    
    return secureSocket ;
}


- (MHSocketSendingStatus)sendData:(MSBuffer *)data onSocket:(MSInt)fd retainedTarget:(id)target retainedReceiverDelegate:(id<MHSocketReceiver>)delegate action:(NSString *)action timeout:(MSUInt)seconds allowsDelayedSending:(BOOL)canDelay
{
    if (data && fd && target && action) {
        BOOL result ;
        NSString *error = nil ;
        MHNotification *waitingNotification =  nil ;
        
        _fd = fd ;
        _target = target ;
        _receiverDelegate = delegate ;
        ASSIGN(_action, action) ;
        ASSIGN(_finalAction, action) ;
        if (seconds) _expirationDate = GMTNow() + seconds ;
        else _expirationDate = 0 ;

        [self lockWaitingNotifications] ;
        waitingNotification = NSMapGet([self waitingNotifications], (const void *)(intptr_t)fd) ;

        if (waitingNotification) {
            //there is already a notification waiting on this socket! waiting...
            if (canDelay) {
                ASSIGN(_delayedWriteBuffer, data) ;
                _delayedSSLSocket = NO ;
                _delayedTimeOutInSeconds = seconds ;
                [self unlockWaitingNotifications] ;
                if ([self processingRequeue])  //we requeue this notification in order to send the data later...
                {
                    return MHSocketDelayedSending ;
                }
                else {
                    return MHSocketSendingFailed ;
                }
            }
            else {
                [self unlockWaitingNotifications] ;
                return MHSocketSendingFailed ;
            }
        }

        NSMapInsert([self waitingNotifications], (const void *)(intptr_t)fd, self) ;
        [self unlockWaitingNotifications] ;

        result = MHSendDataOnConnectedSocket(data, fd, &error) ;

        DESTROY(_delayedWriteBuffer) ;
        
        if (result) {
            MHEnqueueWaitingNotification(self) ;
            return MHSocketSendingSucceeded ;
        }
        else {
            [self lockWaitingNotifications] ;
            NSMapRemove([self waitingNotifications], (const void *)(intptr_t)fd) ;
            MHCancelAllProcessingNotificationsForClientSocket(fd, _isAdminNotification);
            [self unlockWaitingNotifications] ;
            if (error) {
                MHServerLogWithLevel(MHLogError, @"[MHNotification sendData:onSocket:retainedReceiverTarget:action:timeout:] : Unable to send data on socket (%@)", error) ;
            }
            else  {
                MHServerLogWithLevel(MHLogError, @"[MHNotification sendData:onSocket:retainedReceiverTarget:action:timeout:] : Unable to send data on socket") ;
            }
            return MHSocketSendingFailed ;
        }
    }
    return MHSocketSendingFailed ;
}

- (MHSocketSendingStatus)sendData:(MSBuffer *)data onSSLSocket:(MHSSLSocket *)secureSocket retainedTarget:(id)target retainedReceiverDelegate:(id<MHSocketReceiver>)delegate action:(NSString *)action timeout:(MSUInt)seconds allowsDelayedSending:(BOOL)canDelay
{
    if (data && secureSocket && target && action) {
        BOOL result ;
        NSString *error = nil ;
        MHNotification *waitingNotification = nil ;
                
        ASSIGN(_secureSocket, secureSocket) ;
        _fd = [_secureSocket socket] ;
        _target = target ;
        _receiverDelegate = delegate ;
        ASSIGN(_action, action) ;
        ASSIGN(_finalAction, action) ;
        if (seconds) _expirationDate = GMTNow() + seconds ;
        else _expirationDate = 0 ;

        [self lockWaitingNotifications] ;
        waitingNotification = NSMapGet([self waitingNotifications], (const void *)(intptr_t)_fd) ;
      
        if (waitingNotification) {
            //there is already a notification waiting on this socket! waiting...
            if (canDelay) {
                ASSIGN(_delayedWriteBuffer, data) ;
                _delayedSSLSocket = YES ;
                _delayedTimeOutInSeconds = seconds ;
                [self unlockWaitingNotifications] ;
                if ([self processingRequeue])  //we requeue this notification in order to send the data later...
                {
                    return MHSocketDelayedSending ;
                }
                else {
                    return MHSocketSendingFailed ;
                }
            }
            else {
                [self unlockWaitingNotifications] ;
                return MHSocketSendingFailed ;
            }
        }

        NSMapInsert([self waitingNotifications], (const void *)(intptr_t)_fd, self) ;
        [self unlockWaitingNotifications] ;

        result = MHSendDataOnConnectedSSLSocket(data, secureSocket, &error) ;

        DESTROY(_delayedWriteBuffer) ;

        if (result) {
            MHEnqueueWaitingNotification(self) ;
            return MHSocketSendingSucceeded ;
        }
        else {
            [self lockWaitingNotifications] ;
            NSMapRemove([self waitingNotifications], (const void *)(intptr_t)_fd) ;
            [self unlockWaitingNotifications] ;
            if (error) {
                MHServerLogWithLevel(MHLogError, @"[MHNotification sendData:onSSLSocket:retainedReceiverTarget:action:timeout:] : Unable to send data on ssl socket (%@)", error) ;
            }
            else  {
                MHServerLogWithLevel(MHLogError, @"[MHNotification sendData:onSSLSocket:retainedReceiverTarget:action:timeout:] : Unable to send data on ssl socket") ;
            }
            return MHSocketSendingFailed ;
        }
    }
    return MHSocketSendingFailed ;
}

- (MSLong)receiveWaitingData:(void *)buffer length:(MSInt)length
{
    if (_secureSocket) {
        return [_secureSocket singleNonBlockingReadIn:buffer length:length] ;
    } else {
        return recv(_fd, buffer, length, 0) ;
    }
}

- (void)waitForData
{
    MHEnqueueWaitingNotification(self) ;
}

- (void)waitForNextDataRetainedTarget:(id)target retainedReceiverDelegate:(id<MHSocketReceiver>)delegate action:(NSString *)action timeout:(MSUInt)seconds
{
    if (target && action) {
        _target = target ;
        _receiverDelegate = delegate ;
        ASSIGN(_action, action) ;
        ASSIGN(_finalAction, action) ;
        if (seconds) _expirationDate = GMTNow() + seconds ;
        else _expirationDate = 0 ;
        
        MHEnqueueWaitingNotification(self) ;
    }
    else {
        MSRaise(NSInternalInconsistencyException, @"[MHNotification waitForNextDataRetainedTarget:retainedReceiverDelegate:action:timeout:] : no target or no action specified") ;
    }
}

- (void)continueAfterEndReceiveData
{
    [self lockWaitingNotifications] ;
    if (_secureSocket) {
        NSMapRemove([self waitingNotifications], (const void *)(intptr_t)[_secureSocket socket]) ;
    }
    else {
        NSMapRemove([self waitingNotifications], (const void *)(intptr_t)_fd) ;
    }
    [self unlockWaitingNotifications] ;
    
    if (_target && [_finalAction length]) {
        SEL aSelector = NSSelectorFromString(_finalAction) ;
        if ([_target respondsToSelector:aSelector]) {
            ASSIGN(_action, _finalAction) ;
            DESTROY(_finalAction) ;
            _receiverDelegate = nil ;
            
            [_target performSelector:aSelector withObject:self] ;
        }
        else {
            MSRaise(NSInternalInconsistencyException, @"[MHNotification continueAfterEndReceiveData] : target '%@' does not respond to selector '%@'", _target, _finalAction) ;
        }
    }
    else {
        MSRaise(NSInternalInconsistencyException, @"[MHNotification continueAfterEndReceiveData] : no target or notification has no final action (_target = %@ / _finalAction = %@)", _target, _finalAction) ;
    }
}

- (BOOL)respondsToMessageWithBody:(MSBuffer *)body httpStatus:(MSUInt)status headers:(NSDictionary *)headers closeSession:(BOOL)closeSession
{
    BOOL result = NO ;
    if (closeSession) {
        result = MHCloseBrowserSession([_message clientSecureSocket], _session, status) ;
        [self closeSession] ;
    }
    else {
        NSMutableDictionary * hdrs = [NSMutableDictionary dictionaryWithDictionary:headers];

        if (! [headers objectForKey:@"Content-Type"]) { [hdrs setObject:[[self message] contentType] forKey:@"Content-Type"] ; }
        result = MHRespondToClientOnSocketWithAdditionalHeaders([_message clientSecureSocket], body, status, _isAdminNotification, hdrs, _session, NO) ;
    }
    
    return result ;
}

- (BOOL)prepareAndCacheResource:(MHDownloadResource *)resource childrenResources:(NSArray *)childRes useOnce:(BOOL)useOnce lifetime:(MSULong)seconds forceToDisk:(BOOL)forceTodisk
{
    return MHPrepareAndCacheResource(resource, childRes, useOnce, seconds, forceTodisk) ;
}

- (BOOL)postProcessInput:(MHDownloadResource *)input withParameters:(MHDownloadResource *)parameters toOutputResource:(MHDownloadResource **)output andToOutputHTMLResource:(MHDownloadResource **)html usingValuesFromMessage:(MHHTTPMessage *)message
{
    return MHPostProcess(input, parameters, output, html, message) ;
}

- (BOOL)redirectToURL:(NSString *)url isPermanent:(BOOL)isPermanent
{
    return MHRedirectToURL([[self message] clientSecureSocket], url, isPermanent) ;
}

- (BOOL)respondsToMessageWithResource:(MHDownloadResource *)resource useOnce:(BOOL)useOnce lifetime:(MSULong)seconds forMessage:(MHHTTPMessage *)message additionalHeaders:(NSDictionary *)headers
{
    MHServerLogWithLevel(MHLogDebug, @"respondsToMessageWithResource = %@", [resource name] ) ;
    //cache resources if needed
    if( !MHPrepareAndCacheResource(resource, nil, useOnce, seconds, NO))
    {
        MHServerLogWithLevel(MHLogError, @"respondsToMessageWithResource : cannot prepare and cache resource '%@' with children resources '%@' useOnce '%d' lifetime '%lu'", resource,  useOnce, seconds) ;
        return NO ;
    }
    
    //send main resource ton client
    return MHSendResourceToClientOnSocket([_message clientSecureSocket], resource, _isAdminNotification, _session, message, headers) ;
}

- (BOOL)respondsToMessageWithResource:(MHDownloadResource *)resource useOnce:(BOOL)useOnce lifetime:(MSULong)seconds forMessage:(MHHTTPMessage *)message
{
    return [self respondsToMessageWithResource:resource useOnce:useOnce lifetime:seconds forMessage:message additionalHeaders:nil] ;
}

- (BOOL)respondsToMessageWithResource:(MHDownloadResource *)resource childrenResources:(NSArray *)childrenResources useOnce:(BOOL)useOnce lifetime:(MSULong)seconds
{
    return MHPrepareAndCacheResource(resource, childrenResources, useOnce, seconds, NO) ;
}

- (void)validateAuthentication:(BOOL)isAuthenticated firstPageBody:(MSBuffer *)body
{
    MSBuffer *firstPage = body ;
    
    if (!firstPage)
    {
        MHSession *session = [self session] ;
        firstPage = [[session application] firstPage:self] ;
    }
    
    MHValidateAuthentication(self, isAuthenticated, firstPage) ;
}

- (MSBuffer *)readBuffer
{
    return _readBuffer ;
}

- (void)setReadBuffer:(MSBuffer *)buffer
{
    ASSIGN(_readBuffer, buffer) ;
}

- (MSBuffer *)newReadBuffer
{
    return [self newReadBufferWithSize:DEFAULT_NOTIFICATION_READ_BUFFER_SIZE] ;
}

- (MSBuffer *)newReadBufferWithSize:(MSUInt)size
{
    MSBuffer *newBuf = MSCreateBuffer(size) ;
    DESTROY(_readBuffer) ;
    _readBuffer = newBuf ;
    return _readBuffer ;
}

- (void)storeMember:(id)o named:(NSString *)name
{
    if (!_members) _members = [[NSMutableDictionary alloc] initWithCapacity:8] ;
    [_members setObject:o forKey:name] ;
}

- (id)memberNamed:(NSString *)name
{
    return [_members objectForKey:name] ;
}

- (void)removeMemberNamed:(NSString *)name
{
    [_members removeObjectForKey:name] ;
}

- (void)storeMemberInSession:(id)o named:(NSString *)name
{
//    [[_context session] storeMember:o named:name] ;
    [_session storeMember:o named:name] ;
}

- (id)memberNamedInSession:(NSString *)name
{
//    return [[_context session] memberNamed:name] ;   
    return [_session memberNamed:name] ;    
}

- (void)removeMemberNamedInSession:(NSString *)name
{
//    [[_context session] removeMemberNamed:name] ;
    [_session removeMemberNamed:name] ;
}

- (void)changeSessionIDOnResponse
{
    [_session setMustChangeSessionID:YES] ;
}

- (BOOL)processingRequeue
{
    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]]; //slows this thread
    return MHProcessingRequeueNotification(self) ;
}

- (void)performActionOnTarget
{
    if (_delayedWriteBuffer) {
        MHSocketSendingStatus sendResult ;
        if (_delayedSSLSocket) sendResult = [self sendData:_delayedWriteBuffer onSSLSocket:_secureSocket retainedTarget:_target retainedReceiverDelegate:_receiverDelegate action:_action timeout:_delayedTimeOutInSeconds allowsDelayedSending:YES] ;
        else sendResult = [self sendData:_delayedWriteBuffer onSocket:_fd retainedTarget:_target retainedReceiverDelegate:_receiverDelegate action:_action timeout:_delayedTimeOutInSeconds allowsDelayedSending:YES] ;
        
        if (sendResult == MHSocketSendingFailed) {
            [self changeActionToFailReceiveData:MH_FAILURE_REASON_DELAYED_SEND] ;
            [self performActionOnTarget] ;
            return ;
        }
        return ;
    }
    else if (_target && _action) {
        SEL aSelector = NSSelectorFromString(_action) ;

        if (((aSelector == NSSelectorFromString(@"receiveDataForNotification:")) || (aSelector == NSSelectorFromString(@"failReceiveDataForNotification:"))) && _receiverDelegate) {
            [_receiverDelegate performSelector:aSelector withObject:self] ;
            return ;
        }
        else if ([_target respondsToSelector:aSelector]) {
            [_target performSelector:aSelector withObject:self] ;
            return ;
        }
        else {
            MSRaise(NSInternalInconsistencyException, @"[MHNotification performActionOnTarget] : target '%@' does not respond to selector '%@'", _target, _action) ;
        }
    }
    if (!_target) MSRaise(NSInternalInconsistencyException, @"[MHNotification performActionOnTarget] : no target specified") ;
    MSRaise(NSInternalInconsistencyException, @"[MHNotification performActionOnTarget] : no action specified") ;
}

- (MSTimeInterval)expirationDate
{
    return _expirationDate;
}

- (BOOL)isAdminNotification { return _isAdminNotification ; }

- (NSString *)description
{
/*    return [NSString stringWithFormat:@"%@\n  _message=%@\n  _context=%@\n  _originalTarget=%@\n  _target=%@\n  _action=%@", 
            [super description], _message, _context, _originalTarget, _target, _action] ;*/
    return [NSString stringWithFormat:@"%@\n  _message=%@\n  _session=%@\n  _originalTarget=%@\n  _target=%@\n  _action=%@", 
            [super description], _message, _session, _originalTarget, _target, _action] ;
}

- (MHHTTPMessage*)message
{
    return _message;
}

- (MHNotificationType)notificationType
{
    return _notificationType ;
}

/*- (MHContext *)context
{
    return _context ;
}*/

- (MHSession *)session
{
    return _session ;
}

- (MHAppAuthentication)sessionAuthenticationType { return [_session authenticationType] ; }

- (void)closeSession
{
    lock_sessions_mutex() ;
    removeSessionForKey([_session sessionID]) ;
    unlock_sessions_mutex() ;
}

- (void)end
{
    [_session removeNotification] ;
}

- (MSUInt)failureReason { return _failureReason ; }

@end

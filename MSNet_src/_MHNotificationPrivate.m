/*
 
 _MHNotificationPrivate.m
 
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

static NSMapTable *__waitingNotifications = NULL ;
static mutex_t __waitingNotificationsMutex ;

@implementation MHNotification (Private)

+ (void)load {
    if (!__waitingNotifications) {
        __waitingNotifications = NSCreateMapTable(NSIntegerMapKeyCallBacks, NSObjectMapValueCallBacks, 64) ;
        mutex_init(__waitingNotificationsMutex) ;
    }
}

- (SOCKET)waitingExternalSocket { return _fd ; }

- (void)changeActionToReceiveData
{
    ASSIGN(_action, @"receiveDataForNotification:") ;
}

- (void)changeActionToFailReceiveData:(MSShort)failureReason
{
    ASSIGN(_action, @"failReceiveDataForNotification:") ;
    _failureReason = failureReason ;
    
    switch (failureReason) {
        case MH_FAILURE_REASON_DISCONNECTED :
            MHServerLogWithLevel(MHLogDebug, @"changeActionToFailReceiveData reason: socket %d disconnected!", _fd) ;
            break;
        case MH_FAILURE_REASON_TIMEOUT :
            MHServerLogWithLevel(MHLogDebug, @"changeActionToFailReceiveData reason: socket %d timeout!", _fd) ;
            break;
    }
    
    [self lockWaitingNotifications] ;
    if (_secureSocket) {
        NSMapRemove(__waitingNotifications, (const void *)(intptr_t)[_secureSocket socket]) ;
        
        [[_message clientSecureSocket] close] ;
        
        DESTROY(_secureSocket) ;
    }
    else {
        NSMapRemove(__waitingNotifications, (const void *)(intptr_t)_fd) ;

        MHCloseSocket(_fd) ;
    }
    [self unlockWaitingNotifications] ;
    
    _fd = 0 ;
}

- (MHSSLSocket *)clientSecureSocket { return [_message clientSecureSocket] ; }

- (NSMapTable *)waitingNotifications { return __waitingNotifications ; }
- (void)lockWaitingNotifications { mutex_lock(__waitingNotificationsMutex) ; }
- (void)unlockWaitingNotifications { mutex_unlock(__waitingNotificationsMutex) ; }

- (MSInt)applicationSocket
{
    return _fd;
}

- (MHSSLSocket *)applicationSecureSocket
{
    return _secureSocket ;
}

- (MHAppAuthentication)authenticationType { return [[self memberNamed:MHNOTIF_PARAM_MHAPP_AUTH_TYPE] intValue] ; }

- (void)storeAuthenticationLogin:(NSString *)login andPassword:(NSString *)password authType:(MHAppAuthentication)authType
{
    [self storeMember:[NSNumber numberWithInt:authType] named:MHNOTIF_PARAM_MHAPP_AUTH_TYPE] ;
    [self storeMember:login named:MHNOTIF_PARAM_MHLOGIN] ;
    [self storeMember:password ? password : @"" named:MHNOTIF_PARAM_MHPWD] ;
}

- (void)storeAuthenticationLogin:(NSString *)login andPassword:(NSString *)password andTarget:(NSString *)target
{
    [self storeAuthenticationLogin:login andPassword:password authType:MHAuthChallengedPasswordLoginOnTarget] ;
    [self storeMember:target named:MHNOTIF_PARAM_MHTARGET] ;
}

- (NSString *)storedAuthenticationLogin { return [self memberNamed:MHNOTIF_PARAM_MHLOGIN] ; }
- (NSString *)storedAuthenticationPassword { return [self memberNamed:MHNOTIF_PARAM_MHPWD] ; }
- (NSString *)storedAuthenticationTarget { return [self memberNamed:MHNOTIF_PARAM_MHTARGET] ; }

- (void)storeAuthenticationTicket:(NSString *)ticket
{
    [self storeMember:[NSNumber numberWithInt:MHAuthTicket] named:MHNOTIF_PARAM_MHAPP_AUTH_TYPE] ;
    [self storeMember:ticket named:MHNOTIF_PARAM_TICKET] ;
}

- (void)storeAuthenticationChallenge:(NSString *)challenge {
    [self storeMember:[NSNumber numberWithInt:MHAuthPKChallengeAndURN] named:MHNOTIF_PARAM_MHAPP_AUTH_TYPE] ;
    [self storeMember:challenge named:MHNOTIF_PARAM_CHALLENGE] ;
}

- (NSString *)storedAuthenticationChallenge { return [self memberNamed:MHNOTIF_PARAM_CHALLENGE] ; }

- (NSString *)storedAuthenticationTicket { return [self memberNamed:MHNOTIF_PARAM_TICKET] ; }

- (void)storeAuthenticationCustomMode { [self storeMember:[NSNumber numberWithInt:MHAuthCustom] named:MHNOTIF_PARAM_MHAPP_AUTH_TYPE] ; }

@end

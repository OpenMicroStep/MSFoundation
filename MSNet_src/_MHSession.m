/*
 
 MHSession.m
 
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

#import "MSNet_Private.h"

#define SESSION_ID_SIZE 32

static NSString *_generateNewSessionID(MSUShort size)
{
    MSBuffer *randBuff= AUTORELEASE(MSCreateRandomBuffer(size));
    return [MSString stringWithFormat:@"S%@", MSBytesToHexaString([randBuff bytes], [randBuff length], NO)];
}

static NSString *_getUniqueNewSessionID(MSUShort size)
{
    
    NSString *newSessionID = _generateNewSessionID(SESSION_ID_SIZE) ;
    while ((sessionForKey(newSessionID))) { //verify if sessionID already exists
        newSessionID = _generateNewSessionID(SESSION_ID_SIZE) ;
    }
    return newSessionID ;
}

@implementation MHSession

- (void)dealloc
{
    DESTROY(_sessionID) ;
    DESTROY(_userLogin) ;
    DESTROY(_contexts) ;
    DESTROY(_members) ;
    [super dealloc] ;
}

+ (id)newRetainedSessionWithApplication:(MHApplication *)anApplication timeOut:(MSUInt)seconds authenticationType:(MHAppAuthentication)authenticationType
{
    return [[self alloc] initWithApplication:anApplication timeOut:seconds authenticationType:authenticationType] ;
}

- (id)initWithApplication:(MHApplication *)anApplication timeOut:(MSUInt)seconds authenticationType:(MHAppAuthentication)authenticationType
{ 
    ASSIGN(_sessionID, _getUniqueNewSessionID(SESSION_ID_SIZE)) ;

    _application = anApplication ; //no retain on _application
    _userTimeOut = seconds ;
    _keepAliveTimeOut = (MSUInt)[anApplication getKeepAliveTimeout] ;
    _lastActivity = GMTNow() ;
    _lastKeepAlive = _lastActivity ;
    _contexts = [[NSMutableArray alloc ] initWithCapacity:2] ;
    _authenticationType = authenticationType ;
    [self changeStatus:MHSessionStatusInit] ;
    
    setSessionForKey(self, _sessionID) ;

    return self ;
}

- (void)changeSessionID
{
    NSString *nextSessionID ;
    
    lock_sessions_mutex() ;
    nextSessionID = _getUniqueNewSessionID(SESSION_ID_SIZE) ;
    changeSessionIDForKey(self, _sessionID, nextSessionID) ;
    unlock_sessions_mutex() ;
    
    ASSIGN(_sessionID, nextSessionID) ;
}

- (MHContext *)newContext
{
    MHContext *context = [MHContext newRetainedContextWithRetainedSession:self] ;
    if (!_contexts) _contexts = [[NSMutableArray alloc] initWithCapacity:2] ;
    [_contexts addObject:context] ;
    return context ;
}
- (void)addContext:(MHContext *)aContext { if (aContext) { [_contexts addObject:aContext] ; } }
- (MSLong)contextCount { return [_contexts count] ; }

- (void)_touch { if([_application mustUpdateLastActivity]) {_lastActivity = GMTNow() ; _lastKeepAlive = _lastActivity ; } }
- (void)changeStatus:(MHSessionStatus)aStatus
{ 
    _status = aStatus ; 
    [self _touch] ; 
    if (_status == MHSessionStatusAuthenticated)
    {
        _userTimeOut = [[_application class] authentifiedSessionTimeout] ;
    }
}

-(void)_checkExpired
{
    if (_userTimeOut) {
        if ((_lastActivity + _userTimeOut) < GMTNow()) {
            _status = MHSessionStatusExpired ;
            return ;
        }
    }
    
    if (_keepAliveTimeOut && ((_lastKeepAlive + _keepAliveTimeOut) < GMTNow())) {
        _status = MHSessionStatusExpired ;
        return ;
    }
}

- (MHSessionStatus)status { [self _checkExpired] ; [self _touch] ; return _status ; }
- (NSString *)statusDescription 
{
    switch (_status) {
        case MHSessionStatusInit:
            return @"Initialization" ;
            break;
        case MHSessionStatusLoginInterfaceSent:
            return @"Application authenticating, interface sent" ;
            break;
        case MHSessionStatusAuthenticated:
            return @"Authenticated" ;
            break;
        case MHSessionStatusExpired:
            return @"Expired" ;
            break;
        default:
            return @"Unknown" ;
            break;
    }
}
- (BOOL)isValid { [self _checkExpired] ; return (_status != MHSessionStatusExpired) ; }
- (void)keepAliveTouch { _lastKeepAlive = GMTNow(); }
- (NSString *)sessionID { return _sessionID ; }
- (MHApplication *)application { return _application ; }
- (void)setApplication:(MHApplication *)application { _application = application ; }
- (NSArray *)contexts { return _contexts ; }
- (MSTimeInterval)lastActivity { return _lastActivity ; }
- (MSTimeInterval)lastKeepAlive { return _lastKeepAlive ; }
- (NSString *)userLogin { return _userLogin ; }
- (void)setUserLogin:(NSString *)login { ASSIGN(_userLogin, login) ; }
- (NSString *)cookieHeader
{
    return [NSString stringWithFormat:@"SESS_%@=%@; Path=/%@; Expires=%@",
            [_application applicationName],
            _sessionID,
            [_application baseURL],
            GMTdescriptionRfc1123(_lastActivity + _userTimeOut)
            ];
}

- (BOOL)mustChangeSessionID { return _mustChangeSessionID ; }
- (void)setMustChangeSessionID:(BOOL)mustChangeSessionID { _mustChangeSessionID = mustChangeSessionID ; }
- (MHAppAuthentication)authenticationType { return _authenticationType ; }
- (void)setAuthenticationType:(MHAppAuthentication)authenticationType { _authenticationType = authenticationType ; }

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

- (void)addNotification
{
    _fastNotificationCount++ ;
}

- (void)removeNotification
{
    if (_fastNotificationCount) _fastNotificationCount-- ;
}

- (MSUInt)fastNotificationsCount
{
    return _fastNotificationCount ;
}

@end

/*
 
 _MHSession.h
 
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

typedef enum {
    MHSessionStatusInit = 0,
    MHSessionStatusLoginInterfaceSent,
    MHSessionStatusAuthenticated,
    MHSessionStatusExpired
} MHSessionStatus ;

@interface MHSession : NSObject
{
    NSString *_sessionID ;
    MHApplication *_application ; //must be a sub class of MHApplication (not released)
    NSString *_userLogin ;
    MHSessionStatus _status ;
    MSTimeInterval _lastActivity ;
    MSTimeInterval _lastKeepAlive ;
    MSUInt _userTimeOut ;
    MSUInt _keepAliveTimeOut ;
    NSMutableArray *_contexts ;
    NSMutableDictionary *_members ;
    MSUInt _fastNotificationCount ;
    BOOL _mustChangeSessionID ; //change session when responding
    MHAppAuthentication _authenticationType ;
}

+ (id)newRetainedSessionWithApplication:(MHApplication *)anApplication timeOut:(MSUInt)seconds authenticationType:(MHAppAuthentication)authenticationType ;
- (id)initWithApplication:(MHApplication *)anApplication timeOut:(MSUInt)seconds authenticationType:(MHAppAuthentication)authenticationType ;

- (MHContext *)newContext ;
- (void)addContext:(MHContext *)aContext ;
- (MSLong)contextCount ;
- (void)changeStatus:(MHSessionStatus)aStatus ;
- (MHSessionStatus)status ;
- (NSString *)statusDescription ;
- (BOOL)isValid ;
- (void)keepAliveTouch ;
- (NSString *)sessionID ;
- (MHApplication *)application ;
- (void)setApplication:(MHApplication *)application ;
- (NSArray *)contexts ;
- (MSTimeInterval)lastActivity ;
- (MSTimeInterval)lastKeepAlive ;
- (NSString *)userLogin ;
- (void)setUserLogin:(NSString *)login ;
- (NSString *)cookieHeader ;
- (BOOL)mustChangeSessionID ;
- (void)setMustChangeSessionID:(BOOL)mustChangeSessionID ;
- (MHAppAuthentication)authenticationType ;
- (void)setAuthenticationType:(MHAppAuthentication)authenticationType ;

- (void)storeMember:(id)o named:(NSString *)name ;
- (id)memberNamed:(NSString *)name ;
- (void)removeMemberNamed:(NSString *)name ;

- (void)addNotification ;
- (void)removeNotification ;
- (MSUInt)fastNotificationsCount ;

- (void)changeSessionID ;

@end

/*
 
 MHApplication.h
 
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
    MHAppDebug = 1,
    MHAppInfo,
    MHAppWarning,
    MHAppError
} MHAppLogLevel ;

#define DEFAULT_LOGIN_URL_COMPONENT @"login"

@class MHSession, MHResource ;

@interface MHApplication : NSObject <MHNotificationTargetAction>
{
    id _logger ;
    NSBundle * _bundle ;
    NSDictionary *_parameters ;
    NSString *_baseURL ;
    NSString *_instanceName ;
    
    //url singletons
    NSString *_postProcessingURL ;
    NSString *_authenticatedResourceURL ;
    NSString *_publicResourceURL ;
    NSString *_uncURL ;
}

+ (id)applicationOnBaseURL:(NSString *)url instanceName:(NSString *)instanceName withLogger:(id)logger parameters:(NSDictionary *)parameters ;
- (id)initOnBaseURL:(NSString *)url instanceName:(NSString *)instanceName withLogger:(id)logger parameters:(NSDictionary *)parameters ;

- (id)parameterNamed:(NSString *)name ;

- (MHSession *)hasValidSessionForID:(NSString *)aSessionID ;
- (BOOL)mustRespondWithAuthentication ; //must be overridden by sub classes
- (BOOL)canVerifyPeerCertificate ;

+ (MSUInt)defaultSessionInitTimeout ;
- (BOOL)mustUpdateLastActivity ;

- (void)awakeOnRequest:(MHNotification *)notification ; //must be overridden by sub classes
- (void)sessionWillExpire:(MHNotification *)notification ; //can be overridden by sub classes

- (void)clean ;

+ (MHApplication *)applicationForURL:(NSString *)url listeningPort:(MSInt)listeningPort baseUrlComponentsCount:(MSUInt)count;
+ (NSString *)applicationFullName ; //must be overridden by sub classes 
+ (BOOL)isAdminApplication ;
- (NSString *)baseURL ;
- (NSString *)loginURL ;
- (NSString *)postProcessingURL ; 
- (NSString *)authenticatedResourceURL ;
- (NSString *)publicResourceURL ;
- (NSString *)uncURL ;
- (NSString *)applicationName ;
- (NSString *)applicationFullName ;
- (NSString *)instanceName ;
- (BOOL)isAdminApplication ;
- (void)setBundle:(NSBundle *)bundle;
- (MHResource *)getResourceForURL:(NSString *)url ;
- (MHResource *)getResourceFromBundleForURL:(NSString *)url mimeType:(NSString *)mimeType isPublicResource:(BOOL)isPublicResource ;
- (BOOL)resourceExistsInCacheForURL:(NSString *)url ;
- (NSString *)getUploadResourceURLForID:(NSString *)uploadID ;
- (void)logWithLevel:(MHAppLogLevel)level log:(NSString *)log, ... ;
- (MHAppLogLevel)logLevel ;

//bundle configuration
- (NSDictionary *)parameterForKey:(NSString *)key ;

-(BOOL)hasUploadSupport ;

- (MSUInt)getKeepAliveTimeout ; //returns timout in seconds if application need keep alive requests to maintain session alive, else returns 0
- (MSUInt)getKeepAliveInterval ; //returns interval in seconds if application need keep alive requests to maintain session alive, else returns 0

- (NSString *)convertUncFromUrl:(NSString *)url ;

@end

@interface MHPublicApplication : MHApplication
@end

#define MHAUTHENTICATED_APP_QUERY_PARAM_TICKET  @"ticket"
#define MHAUTHENTICATED_CHALLENGE_ADDITIONAL_STORED_OBJECT  @"challengeAdditionalObject"

@interface MHAuthenticatedApplication : MHApplication
{
    MSUInt _authenticationMethods ;
    MSBuffer *_loginInterface ;
    NSMutableDictionary *_tickets ;
    MSMutex *_ticketsMutex ;
}

- (MSBuffer *)loginInterfaceWithMessage:(MHHTTPMessage *)message errorMessage:(NSString *)error ; //can be overriden by sub classes
- (MSBuffer *)firstPage:(MHNotification *)notification ;
+ (MSUInt)authentifiedSessionTimeout ; //can be overridden by subclasses

//authentication methods
- (BOOL)canAuthenticateWithLoginPassword ;
- (BOOL)canAuthenticateWithLoginTicket ;
- (BOOL)canAuthenticateWithChallenge ;
- (BOOL)canAuthenticateWithCustomAuthentication ;

+ (MSUInt)defaultAuthenticationMethods ;
- (MSUInt)authenticationMethods ;

- (void)setAuthenticationMethods:(MSUInt)authenticationMethods ;
- (void)setAuthentificationMethod:(MHAppAuthentication)authenticationMethod ;
- (void)unsetAuthentificationMethod:(MHAppAuthentication)authenticationMethod ;

- (void)validateAuthentication:(MHNotification *)notification login:(NSString *)login password:(NSString *)password certificate:(MSCertificate *)certificate ;
- (void)validateAuthentication:(MHNotification *)notification ticket:(NSString *)ticket certificate:(MSCertificate *)certificate ;
- (void)validateAuthentication:(MHNotification *)notification challenge:(NSString *)challenge certificate:(MSCertificate *)certificate ;
- (void)validateAuthentication:(MHNotification *)notification certificate:(MSCertificate *)certificate ;

//challenge generation
- (NSString *)generateChallengeForMessage:(MHHTTPMessage *)httpMessage plainStoredChallenge:(NSString **)plainChallenge additionalStoredObject:(id *)object ;
- (NSString *)sessionChallengeMemberName ;
- (NSString *)sessionChallengeAdditionalObjectMemberName ;

//tickets management
- (BOOL)canAuthenticateWithTicket ;
- (NSMutableDictionary *)tickets ;
- (void)setTickets:(NSDictionary *)tickets ;
- (NSString *)ticketForValidity:(MSTimeInterval)duration ;

- (void)setObject:(id)object forTicket:(NSString *)ticket ;
- (id)objectForTicket:(NSString *)ticket ;
- (NSNumber *)validityForTicket:(NSString *)ticket ;
  // TODO: Non c'est pas bien, si c'est une date, il faut retourner une date
- (void)removeTicket:(NSString *)ticket ;

//authentication posted parameters
- (NSString *)loginFieldName ;
- (NSString *)passwordFieldName ;
- (NSString *)challengeFieldName ;

@end

@interface MHGUIAuthenticatedApplication : MHAuthenticatedApplication

@end

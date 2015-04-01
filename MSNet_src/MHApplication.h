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

typedef enum {
    MHAuthUndefined                         = 0,   //Undefined
    MHAuthNone                              = 1,   //No auth
    MHAuthCustom                            = 2,   //Application defined auth
    MHAuthTicket                            = 4,   //Ticket auth
    MHAuthSimpleGUIPasswordAndLogin         = 8,   //GUI login password auth
    MHAuthChallengedPasswordLogin           = 16,  //Auth with challenged password for login
    MHAuthChallengedPasswordLoginOnTarget   = 32,  //Auth with challenged password for login on a specifig URN
    MHAuthPKChallengeAndURN                 = 64   //Challenge auth
} MHAppAuthentication ;

@class MHSession, MHResource ;

#define MHAUTH_QUERY_PARAM_TICKET   @"ticket"
#define MHAUTH_HEADER_RESPONSE      @"MASH-AUTH-RESPONSE"
#define MHAUTH_HEADER_RESPONSE_OK   @"SUCCESS"
#define MHAUTH_HEADER_RESPONSE_FAIL @"FAILURE"

NSString *MHChallengedPasswordHash(NSString *password, NSString *challenge) ;
NSString *MHAuthenticationNameForType(MHAppAuthentication authType) ;

typedef	NSString *(*MHTicketFormatterCallback) (MSUShort minTicketSize);

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
    NSString *_logoutURL ;
    
    //authentication members
    MSBuffer *_loginInterface ;
    MSUInt _authenticationMethods ;
    
    //repository connection dictionary
    NSDictionary *_netRepositoryServerParameters ;
}

+ (BOOL)requiresUniqueProcessingThread ; //can be overridden by sub classes
- (BOOL)requiresUniqueProcessingThread ; //can be overridden by sub classes

+ (id)applicationOnBaseURL:(NSString *)url instanceName:(NSString *)instanceName withLogger:(id)logger parameters:(NSDictionary *)parameters ;
- (id)initOnBaseURL:(NSString *)url instanceName:(NSString *)instanceName withLogger:(id)logger parameters:(NSDictionary *)parameters ;

- (void)setBundle:(NSBundle *)bundle;
- (MHAppLogLevel)logLevel ;
- (void)logWithLevel:(MHAppLogLevel)level log:(NSString *)log, ... ;

- (NSString *)baseURL ;
- (NSString *)postProcessingURL ;
- (NSString *)authenticatedResourceURL ;
- (NSString *)publicResourceURL ;
- (NSString *)uncURL ;
- (NSString *)logoutURL ;

+ (NSString *)applicationFullName ; //must be overridden by sub classes
- (NSString *)applicationFullName ;
- (NSString *)applicationName ;
- (NSString *)instanceName ;

- (BOOL)hasUploadSupport ;
- (BOOL)canVerifyPeerCertificate ;
- (id)parameterNamed:(NSString *)name ;

//resource management
- (MHResource *)getResourceForURL:(NSString *)url ;
- (MHResource *)getResourceFromBundleForURL:(NSString *)url mimeType:(NSString *)mimeType isPublicResource:(BOOL)isPublicResource ; //GEO TODO PRIVATE
- (BOOL)resourceExistsInCacheForURL:(NSString *)url ;
//- (NSString *)getUploadResourceURLForID:(NSString *)uploadID ;
- (NSString *)convertUncFromUrl:(NSString *)url ;

//bundle configuration
- (NSDictionary *)bundleParameterForKey:(NSString *)key ; // GEO TODO PRIVATE ?

//timeout and keepAlive managements
+ (MSUInt)defaultSessionInitTimeout ;
+ (MSUInt)authentifiedSessionTimeout ; //can be overridden by subclasses
- (BOOL)mustUpdateLastActivity ;
- (MSUInt)getKeepAliveTimeout ; //returns timout in seconds if application need keep alive requests to maintain session alive, else returns 0
- (MSUInt)getKeepAliveInterval ; //returns interval in seconds if application need keep alive requests to maintain session alive, else returns 0
- (void)sessionWillExpire:(MHNotification *)notification ; //can be overridden by sub classes

//application methods to override
- (void)awakeOnRequest:(MHNotification *)notification ; //must be overridden by sub classes
- (void)clean ;

- (MSBuffer *)firstPage:(MHNotification *)notification ;

//authentication methods
+ (MSUInt)defaultAuthenticationMethods ;
- (MSUInt)authenticationMethods ;

- (BOOL)canHaveNoAuthentication ;
- (BOOL)canAuthenticateWithSimpleGUILoginPassword ;
- (BOOL)canAuthenticateWithChallengedPasswordLogin ;
- (BOOL)canAuthenticateWithChallengedPasswordLoginOnTarget ;
- (BOOL)canAuthenticateWithTicket ;
- (BOOL)canAuthenticateWithPKChallenge ;
- (BOOL)canAuthenticateWithCustomAuthentication ;

- (void)setAuthenticationMethods:(MSUInt)authenticationMethods ;
- (void)setAuthenticationMethod:(MHAppAuthentication)authenticationMethod ;
- (void)unsetAuthenticationMethod:(MHAppAuthentication)authenticationMethod ;

- (void)validateAuthentication:(MHNotification *)notification
                     challenge:(NSString *)challenge
              sessionChallenge:(NSString *)storedChallenge
                           urn:(NSString *)urn
                   certificate:(MSCertificate *)certificate ;

- (void)validateAuthentication:(MHNotification *)notification
                         login:(NSString *)login
            challengedPassword:(NSString *)challengedPassword
              sessionChallenge:(NSString *)storedChallenge
                   certificate:(MSCertificate *)certificate ;

- (void)validateAuthentication:(MHNotification *)notification
                         login:(NSString *)login
            challengedPassword:(NSString *)challengedPassword
              sessionChallenge:(NSString *)storedChallenge
                        target:(NSString *)target
                   certificate:(MSCertificate *)certificate ;

- (void)validateAuthentication:(MHNotification *)notification ticket:(NSString *)ticket certificate:(MSCertificate *)certificate ;
- (void)validateAuthentication:(MHNotification *)notification certificate:(MSCertificate *)certificate ;

//challenge generation
- (NSString *)publicKeyForURN:(NSString *)urn ; //can be overridden, not implemented
- (NSString *)generateChallengeInfoForLogin:(NSString *)login withSession:(MHSession*)session ;
- (NSString *)generatePKChallengeURN:(NSString *)urn storedPlainChallenge:(NSString **)plainChallenge ;

//tickets management
- (NSString *)ticketForValidity:(MSTimeInterval)duration ;
- (NSString *)ticketForValidity:(MSTimeInterval)duration withCurrentSessionInNotification:(MHNotification *)notification useOnce:(BOOL)useOnce ;
- (NSString *)ticketForValidity:(MSTimeInterval)duration withCurrentSessionInNotification:(MHNotification *)notification useOnce:(BOOL)useOnce ticketFormatterCallback:(MHTicketFormatterCallback)ticketFormatterCallback;
- (NSMutableDictionary *)tickets ;
- (void)setTickets:(NSDictionary *)tickets ;
- (id)objectForTicket:(NSString *)ticket ;
- (void)setObject:(id)object forTicket:(NSString *)ticket ;
- (NSNumber *)validityForTicket:(NSString *)ticket ;
- (NSNumber *)creationDateForTicket:(NSString *)ticket ;
- (void)removeTicket:(NSString *)ticket ;
 
// net repository parameters
- (NSDictionary *)netRepositoryConnectionDictionary ;
- (NSDictionary *)netRepositoryParameters ;

@end

#define MHGUI_AUTH_FORM_LOGIN       @"MH-LOGIN"
#define MHGUI_AUTH_FORM_PASSWORD    @"MH-PASSWORD"

@interface MHGUIApplication : MHApplication
{
    NSString *_loginURL ;
}

- (NSString *)loginURL ;
- (MSBuffer *)loginInterfaceWithErrorMessage:(NSString *)errorMessage ;
- (void)validateSimpleGUIAuthentication:(MHNotification *)notification login:(NSString *)login password:(NSString *)password certificate:(MSCertificate *)certificate ;

@end

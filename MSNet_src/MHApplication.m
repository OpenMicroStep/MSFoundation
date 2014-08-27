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


#import "MSNet_Private.h"

NSString *MHAuthenticationNameForType(MHAppAuthentication authType)
{
    NSString *authName = nil ;
    
    switch (authType) {
        case MHAuthUndefined:
            authName = @"MHAuthUndefined" ;
            break;
        case MHAuthCustom:
            authName = @"MHAuthCustom" ;
            break;
        case MHAuthTicket:
            authName = @"MHAuthTicket" ;
            break;
        case MHAuthSimpleGUIPasswordAndLogin:
            authName = @"MHAuthSimpleGUIPasswordAndLogin" ;
            break;
        case MHAuthChallengedPasswordLogin:
            authName = @"MHAuthChallengedPasswordLogin" ;
            break;
        case MHAuthChallengedPasswordLoginOnTarget:
            authName = @"MHAuthChallengedPasswordLoginOnTarget" ;
            break ;
        case MHAuthPKChallengeAndURN:
            authName = @"MHAuthPKChallengeAndURN" ;
            break;
        default:
            authName = @"Not Supported" ;
            break;
    }
    return authName ;
}

#define SESSION_DEFAULT_INIT_TIMEOUT 90
#define SESSION_DEFAULT_AUTHENTICATED_TIMEOUT 600

#define BUNDLE_AUTHENTICATED_RESOURCE_SUBDIRECTORY      @"authenticatedResources"
#define BUNDLE_PUBLIC_RESOURCE_SUBDIRECTORY             @"publicResources"

#define DEFAULT_PASSWORD    @"password"
#define DEFAULT_LOGIN       @"login"
#define DEFAULT_LOGIN_ERROR_MESSAGE "Wrong login or password"

static MSUInt __authenticatedApplicationDefaultAuthenticationMethods = MHAuthNone ;

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
    ASSIGN(_netRepositoryServerParameters, [parameters objectForKey:@"netRepository"]) ;
    
    _authenticationMethods = [ISA(self) defaultAuthenticationMethods] ;
    
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
    DESTROY(_logoutURL) ;
    
    DESTROY(_loginInterface) ;
    DESTROY(_netRepositoryServerParameters) ;
    
    [super dealloc] ;
}

- (id)parameterNamed:(NSString *)name
{
    return [_parameters objectForKey:name] ;
}

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
- (NSString *)baseURL { return _baseURL ; }

- (NSString *)applicationName { return [[self class] applicationName] ; }
- (NSString *)applicationFullName { return [[self class] applicationFullName] ; }
- (NSString *)instanceName { return _instanceName ; }

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

#define DEFAULT_LOGOUT_URL_COMPONENT    @"logout"

- (NSString *)logoutURL
{
    if(!_logoutURL) {
        NSString *baseURL = [self baseURL] ;
        NSString *logoutURL = [baseURL length] ? [baseURL stringByAppendingURLComponent:DEFAULT_LOGOUT_URL_COMPONENT] : DEFAULT_LOGOUT_URL_COMPONENT ;
        
        ASSIGN(_logoutURL, logoutURL) ;
    }
    return _logoutURL ;
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
    return (isPublicResource) ? BUNDLE_PUBLIC_RESOURCE_SUBDIRECTORY : BUNDLE_AUTHENTICATED_RESOURCE_SUBDIRECTORY ;
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

/*- (NSString *)getUploadResourceURLForID:(NSString *)uploadID
{
    return MHGetUploadResourceURLForID(self, uploadID) ;
}*/

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

- (NSDictionary *)bundleParameterForKey:(NSString *)key
{
    NSString *bundleName = NSStringFromClass([_bundle principalClass]) ;
    NSMutableDictionary *params = nil ;
    NSMutableDictionary *generalParams = nil ;
    
    params = [[MHBundlesConfig() objectForKey:bundleName] objectForKey:key] ;
    if(params) return params ;
    
    generalParams = [[MHBundlesConfig() objectForKey:@"general"] objectForKey:key] ;
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

- (void)validateSimpleGUIAuthentication:(MHNotification *)notification login:(NSString *)login password:(NSString *)password certificate:(MSCertificate *)certificate
{
    MHVALIDATE_AUTHENTICATION(NO, nil) ;
}

- (void)validateAuthentication:(MHNotification *)notification
                         login:(NSString *)login
            challengedPassword:(NSString *)challengedPassword
              sessionChallenge:(NSString *)storedChallenge
                   certificate:(MSCertificate *)certificate
{
    if ([storedChallenge length] && [login length])
    {
        NSString *challengedPasswordHash = MHChallengedPasswordHash(DEFAULT_PASSWORD, storedChallenge) ;
        
        if([DEFAULT_LOGIN isEqual:login] && [challengedPasswordHash isEqual:challengedPassword])
        {
            [self logWithLevel:MHAppDebug log:@"Challenge Authentication success for login '%@'", login] ;
            MHVALIDATE_AUTHENTICATION(YES, nil) ;
        }
        else
        {
            [self logWithLevel:MHAppDebug log:@"Challenge Authentication failure for login '%@'", login] ;
            MHVALIDATE_AUTHENTICATION(NO, AUTORELEASE(MSCreateBufferWithBytesNoCopyNoFree(DEFAULT_LOGIN_ERROR_MESSAGE,strlen(DEFAULT_LOGIN_ERROR_MESSAGE)))) ;
        }
    } else {
        MHVALIDATE_AUTHENTICATION(NO, AUTORELEASE(MSCreateBufferWithBytesNoCopyNoFree(DEFAULT_LOGIN_ERROR_MESSAGE,strlen(DEFAULT_LOGIN_ERROR_MESSAGE)))) ;
    }
}

- (void)validateAuthentication:(MHNotification *)notification
                         login:(NSString *)login
            challengedPassword:(NSString *)challengedPassword
              sessionChallenge:(NSString *)storedChallenge
                        target:(NSString *)target
                   certificate:(MSCertificate *)certificate
{
    [self notImplemented:_cmd] ;
}

- (NSString *)publicKeyForURN:(NSString *)urn { [self notImplemented:_cmd] ; return nil ; }

- (NSString *)generatePKChallengeURN:(NSString *)urn storedPlainChallenge:(NSString **)plainChallenge
{
    NSData *encryptedChallengeData = nil ;
    NSString *encryptedChallenge = nil ;
    NSString *challenge = [self generatePlainChallengeWithParameters:nil storeInSession:nil] ;
    MSBuffer *base64Buf = nil ;
    
    if ([challenge length])
    {
        NSString *publicKey = [self publicKeyForURN:urn] ;
        
        if ([publicKey length])
        {
            NSData *challengeData = nil ;
            MSCipher *cypher = nil ;
            MSBuffer *pkBuf = AUTORELEASE(MSCreateBufferWithBytesNoCopyNoFree((void *)[publicKey UTF8String], [publicKey length])) ;
            
            //convert challenge to data
            challengeData = [NSData dataWithBytes:(void *)[challenge UTF8String] length:[challenge length]] ;
            
            //encrypt challenge
            cypher = [MSCipher cipherWithKey:pkBuf type:RSAEncoder] ;
            encryptedChallengeData = [cypher encryptData:challengeData] ;
            
            *plainChallenge = challenge ; //store plain challenge
        }
        else // do not store challenge
        {
            *plainChallenge = nil ;
            encryptedChallengeData = [challenge dataUsingEncoding:NSUTF8StringEncoding] ;
        }
    } else
    {
        MSRaise(NSInternalInconsistencyException, @"generatePKChallengeURN : Challenge generation failed") ;
    }

    //always return a challenge, even is no public key was found
    base64Buf = [[MSBuffer bufferWithBytesNoCopyNoFree:(void*)[encryptedChallengeData bytes] length:[encryptedChallengeData length]] encodedToBase64] ;
    encryptedChallenge = AUTORELEASE(MSCreateASCIIStringWithBytes((void *)[base64Buf bytes], [base64Buf length], YES, YES)) ;
    
    return encryptedChallenge ;
}

- (NSString *)generatePlainChallengeWithParameters:(NSDictionary *)challengeParameters storeInSession:(NSDictionary **)sessionParameters
{
    MSBuffer *randBuff = AUTORELEASE(MSCreateRandomBuffer(8)) ;
    MSBuffer *b64Buf = [randBuff encodedToBase64] ;
    
    return AUTORELEASE(MSCreateASCIIStringWithBytes((void *)[b64Buf bytes], [b64Buf length], YES, YES)) ;
}

- (void)validateAuthentication:(MHNotification *)notification ticket:(NSString *)ticket certificate:(MSCertificate *)certificate
{
    NSMutableDictionary *tickets = [self tickets] ;
    NSDictionary *ticketFound = [tickets objectForKey:ticket] ;
    
    if (ticketFound)
    {
        MSTimeInterval ticketValidityEnd = [[ticketFound objectForKey:MHAPP_TICKET_VALIDITY] longLongValue] ;
        BOOL useOnce = [[ticketFound objectForKey:MHAPP_TICKET_USE_ONCE] boolValue] ;

        //ticketValidityEnd == 0 means unlimited validity
        if (!ticketValidityEnd || GMTNow() < ticketValidityEnd)
        {
            [self logWithLevel:MHAppDebug log:@"Ticket Authentication success"] ;
            if (useOnce) { [self removeTicket:ticket] ; }
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

- (void)validateAuthentication:(MHNotification *)notification
                     challenge:(NSString *)challenge
              sessionChallenge:(NSString *)storedChallenge
                           urn:(NSString *)urn
                   certificate:(MSCertificate *)certificate
{
    if ([challenge length] && [storedChallenge length] && [challenge isEqualToString:storedChallenge])
    {
        [self logWithLevel:MHAppDebug log:@"Challenge Authentication success for URN '%@'",urn] ;
        MHVALIDATE_AUTHENTICATION(YES, nil) ;
    }
    
    [self logWithLevel:MHAppDebug log:@"Challenge Authentication failure for URN '%@' : stored challenge not found", urn] ;
    MHVALIDATE_AUTHENTICATION(NO, nil) ;
}

- (void)validateAuthentication:(MHNotification *)notification certificate:(MSCertificate *)certificate
{
    MHVALIDATE_AUTHENTICATION(NO, nil) ;
}

- (MSBuffer *)firstPage:(MHNotification *)notification { return nil ; }

+ (MSUInt)authentifiedSessionTimeout { return SESSION_DEFAULT_AUTHENTICATED_TIMEOUT ; }

- (BOOL)canHaveNoAuthentication { return _authenticationMethods & MHAuthNone ; }
- (BOOL)canAuthenticateWithSimpleGUILoginPassword { return _authenticationMethods & MHAuthSimpleGUIPasswordAndLogin ; }
- (BOOL)canAuthenticateWithChallengedPasswordLogin { return _authenticationMethods & MHAuthChallengedPasswordLogin ; }
- (BOOL)canAuthenticateWithChallengedPasswordLoginOnTarget { return _authenticationMethods & MHAuthChallengedPasswordLoginOnTarget ; }
- (BOOL)canAuthenticateWithTicket { return _authenticationMethods & MHAuthTicket ; }
- (BOOL)canAuthenticateWithPKChallenge { return _authenticationMethods & MHAuthPKChallengeAndURN ; }
- (BOOL)canAuthenticateWithCustomAuthentication { return _authenticationMethods & MHAuthCustom ; }

+ (MSUInt)defaultAuthenticationMethods { return __authenticatedApplicationDefaultAuthenticationMethods ; }
- (MSUInt)authenticationMethods { return _authenticationMethods ; }

- (void)setAuthenticationMethods:(MSUInt)authenticationMethods { _authenticationMethods |= authenticationMethods ; }
- (void)setAuthenticationMethod:(MHAppAuthentication)authenticationMethod { _authenticationMethods |= authenticationMethod ; }
- (void)unsetAuthenticationMethod:(MHAppAuthentication)authenticationMethod { _authenticationMethods &= ~authenticationMethod ; }

- (NSString *)ticketForValidity:(MSTimeInterval)duration { return ticketForValidity(self, duration) ; }
- (NSString *)ticketForValidity:(MSTimeInterval)duration withCurrentSessionInNotification:(MHNotification *)notification useOnce:(BOOL)useOnce
{
    return ticketForValidityAndLinkedSession(self, duration, [[notification session] sessionID], useOnce, NULL) ;
}
- (NSString *)ticketForValidity:(MSTimeInterval)duration withCurrentSessionInNotification:(MHNotification *)notification useOnce:(BOOL)useOnce ticketFormatterCallback:(MHTicketFormatterCallback)ticketFormatterCallback
{
  return ticketForValidityAndLinkedSession(self, duration, [[notification session] sessionID], useOnce, ticketFormatterCallback) ;
}

- (NSMutableDictionary *)tickets { return ticketsForApplication(self) ; }
- (void)setTickets:(NSDictionary *)tickets { setTicketsForApplication(self, tickets) ; }
- (id)objectForTicket:(NSString *)ticket { return objectForTicket(self, ticket) ; }
- (void)setObject:(id)object forTicket:(NSString *)ticket { setObjectForTicket(self, object, ticket) ; }
- (NSNumber *)validityForTicket:(NSString *)ticket { return validityForTicket(self, ticket) ; }
- (NSNumber *)creationDateForTicket:(NSString *)ticket { return creationDateForTicket(self, ticket) ; }
- (void)removeTicket:(NSString *)ticket { removeTicket(self, ticket) ; }

- (NSDictionary *)netRepositoryConnectionDictionary
{
    return [[self netRepositoryParameters] objectForKey:@"netRepositories"] ;
}

- (NSDictionary *)netRepositoryParameters
{
    return _netRepositoryServerParameters ;
}

@end



#define DEFAULT_LOGIN_URL_COMPONENT     @"login"

@implementation MHGUIApplication

+ (MSUInt)defaultAuthenticationMethods { return 0 ; }

- (NSString *)loginURL
{
    if(!_loginURL) {
        NSString *baseURL = [self baseURL] ;
        NSString *loginURL = [baseURL length] ? [baseURL stringByAppendingURLComponent:DEFAULT_LOGIN_URL_COMPONENT] : DEFAULT_LOGIN_URL_COMPONENT ;
        
        ASSIGN(_loginURL, loginURL) ;
    }
    return _loginURL ;
}

- (MSBuffer *)loginInterfaceWithErrorMessage:(NSString *)errorMessage
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
        NSMutableString *page = MHOpenFileForSubstitutions(file) ;
        
        page = [page replaceOccurrencesOfString:@"%__APPLICATION_NAME__%" withString:appName] ;
        page = [page replaceOccurrencesOfString:@"%__ERROR_MESSAGE__%" withString:[errorMessage length] ? errorMessage : @""] ;
        page = [page replaceOccurrencesOfString:@"%__ACTION_URL__%" withString:[NSString stringWithFormat:@"/%@",[self baseURL]]] ;
        
        loginInterface = AUTORELEASE(MSCreateBufferWithBytes((void *)[page UTF8String], [page length])) ;
        
    } else
    {
        MSRaise(NSGenericException, @"MHGUIApplication : cannot find interface template at path '%@'", file) ;
    }
    
    return loginInterface ;
}

- (void)validateSimpleGUIAuthentication:(MHNotification *)notification login:(NSString *)login password:(NSString *)password certificate:(MSCertificate *)certificate
{
    if([DEFAULT_LOGIN isEqual:login] && [DEFAULT_PASSWORD isEqual:password])
    {
        MHVALIDATE_AUTHENTICATION(YES, nil) ;
    }
    else
    {
        MHVALIDATE_AUTHENTICATION(NO, AUTORELEASE(MSCreateBufferWithBytesNoCopyNoFree(DEFAULT_LOGIN_ERROR_MESSAGE,strlen(DEFAULT_LOGIN_ERROR_MESSAGE)))) ;
    }
}

- (void)dealloc
{
    DESTROY(_loginURL) ;

    [super dealloc] ;
}

@end


NSString *MHChallengedPasswordHash(NSString *password, NSString *challenge)
{
    NSString *challengedPassword = nil ;
    NSString *hashesdPassword = @"" ;
    NSString *tmp = nil ;

    if (![challenge length])
    {
        MSRaise(NSInternalInconsistencyException, @"MHChallengedPassword error : empty challenge provided") ;
    }
    
    if ([password length])
    {
        hashesdPassword = MSDigestData(MS_SHA512, (void *)[password UTF8String], [password length]) ;
    }

    tmp = [challenge stringByAppendingString:hashesdPassword] ;
    challengedPassword = MSDigestData(MS_SHA512, (void *)[tmp UTF8String], [tmp length]) ;
    
    return challengedPassword ;
}

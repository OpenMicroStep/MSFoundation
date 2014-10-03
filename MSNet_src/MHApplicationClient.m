//
//  MHApplicationClient.m
//
//
//  Created by Geoffrey Guilbon on 29/10/13.
//  Copyright (c) 2013 Geoffrey Guilbon. All rights reserved.
//

#import "MSNet_Private.h"

#define BUFF_SIZE 2048

typedef enum
{
    appNotAuthenticated = 0, //
    appChallengeRequest,
    appAuthenticating,
	appAuthenticated,
    appClosing,
    appAuthFailStop
} MHAppClientAuthStatus ;

@implementation MHApplicationClient

+ (id)clientWithServerParameters:(NSDictionary *)parameters
{
    return [[[self alloc] initWithServerParameters:parameters] autorelease] ;
}

+ (id)clientWithServerParameters:(NSDictionary *)parameters sessionID:(NSString *)sessionID
{
  return [[[self alloc] initWithServerParameters:parameters sessionID:sessionID] autorelease] ;
}

+ (id)clientWithServerParameters:(NSDictionary *)parameters
                          ticket:(NSString *)ticket
{
    return [[[self alloc] initWithServerParameters:parameters ticket:ticket] autorelease] ;
}

+ (id)clientWithServerParameters:(NSDictionary *)parameters
                  simplePassword:(NSString *)password
                           login:(NSString *)login
{
    return [[[self alloc] initWithServerParameters:parameters simplePassword:password login:login] autorelease] ;
}

+ (id)clientWithServerParameters:(NSDictionary *)parameters
              challengedPassword:(NSString *)password
                           login:(NSString *)login
{
    return [[[self alloc] initWithServerParameters:parameters challengedPassword:password login:login] autorelease] ;
}

+ (id)clientWithServerParameters:(NSDictionary *)parameters
              challengedPassword:(NSString *)password
                           login:(NSString *)login
                          target:(NSString *)target
{
    return [[[self alloc] initWithServerParameters:parameters challengedPassword:password login:login target:target] autorelease] ;
}

+ (id)clientWithServerParameters:(NSDictionary *)parameters
                             urn:(NSString *)urn
                       secretKey:(NSData *)sk ;
{
    return [[[self alloc] initWithServerParameters:parameters urn:urn secretKey:sk] autorelease] ;
}

- (id)init
{
  ASSIGN(_requestLock, [MSMutex mutex]) ;
  return [super init] ;
}

- (id)initWithServerParameters:(NSDictionary *)parameters sessionID:(NSString *)sessionID
{
    ASSIGN(_sessionID, sessionID) ;
    return [self initWithServerParameters:parameters] ;
}

- (id)initWithServerParameters:(NSDictionary *)parameters
{
    BOOL isDirectory = YES ;
    NSString *serverAddress = [parameters objectForKey:@"serverAddress"] ;
    MSInt serverPort = [[parameters objectForKey:@"serverPort"] intValue] ;
    NSString *CAFile = [parameters objectForKey:@"CAFile"] ;
    NSString *applicationBaseURL = [parameters objectForKey:@"url"] ;
    
    if (! [serverAddress length]) { MSRaise(NSGenericException, @"empty server string") ; }
    if (! serverPort) { MSRaise(NSGenericException, @"null server port") ; }
    if (! MSFileExistsAtPath(CAFile, &isDirectory) || isDirectory) MSRaise(NSGenericException, @"cannot find CAFile file") ;
    
    ASSIGN(_server, serverAddress) ;
    _port = serverPort ;
    ASSIGN(_CAFile, CAFile) ;
    ASSIGN(_baseURL, applicationBaseURL) ;
    
    _authenticationType = MHAuthNone ;
    
    return [self init];
}

- (id)initWithServerParameters:(NSDictionary *)parameters
                        ticket:(NSString *)ticket
{
    if ([self initWithServerParameters:parameters])
    {
        ASSIGN(_ticket, ticket) ;
        _authenticationType = MHAuthTicket ;
        return self ;
    }
    
    return nil ;
}

- (id)initWithServerParameters:(NSDictionary *)parameters
                simplePassword:(NSString *)password
                         login:(NSString *)login
{
    return nil ;
}

- (id)initWithServerParameters:(NSDictionary *)parameters
            challengedPassword:(NSString *)password
                         login:(NSString *)login
{
    if ([self initWithServerParameters:parameters])
    {
        ASSIGN(_login, login) ;
        ASSIGN(_password, password) ;
        _authenticationType = MHAuthChallengedPasswordLogin ;
        return self ;
    }
    return nil ;
}

- (id)initWithServerParameters:(NSDictionary *)parameters
            challengedPassword:(NSString *)password
                         login:(NSString *)login
                        target:(NSString *)target
{
    if ([self initWithServerParameters:parameters])
    {
        ASSIGN(_login, login) ;
        ASSIGN(_password, password) ;
        ASSIGN(_target, target) ;
        _authenticationType = MHAuthChallengedPasswordLoginOnTarget ;
        return self ;
    }
    return nil ;
}

- (id)initWithServerParameters:(NSDictionary *)parameters
                           urn:(NSString *)urn
                     secretKey:(NSData *)sk
{
    if ([self initWithServerParameters:parameters])
    {
        ASSIGN(_sk, sk) ;
        ASSIGN(_urn, urn) ;
        _authenticationType = MHAuthPKChallengeAndURN ;
        return self ;
    }
    return nil ;
}

- (void)dealloc
{
    DESTROY(_CAFile) ;
    DESTROY(_server) ;
    DESTROY(_baseURL) ;
    DESTROY(_sessionID) ;
    
    DESTROY(_sk) ;
    DESTROY(_urn) ;
    
    DESTROY(_login) ;
    DESTROY(_password) ;
    DESTROY(_target) ;
    
    DESTROY(_ticket) ;
    DESTROY(_requestLock) ;
    
    [super dealloc] ;
}

- (void)setSessionID:(NSString *)sessionID { ASSIGN(_sessionID, sessionID) ; }

- (MSHTTPResponse *)challengeResponse { return _challengeResponse ; }

- (MSHTTPRequest *)request:(MSHTTPMethod)method onSubURL:(NSString *)subURL
{
    NSString *url = (subURL) ? [_baseURL stringByAppendingURLComponent:subURL] : _baseURL ;
    
    return [MSHTTPRequest requestWithMethod:method toHost:_server url:url] ;
}

- (MSHTTPResponse *)_performRequest:(MSHTTPRequest *)request errorString:(NSString **)error
{
    MHSSLClientSocket *sslSocket = nil ;
    MSHTTPResponse *response = nil ;
    
    if (request)
    {
        //if previous response had a session cookie, add session cookie to request
        if ([_sessionID length]) { [request addAdditionalHeaderValue:_sessionID forKey:@"Cookie"] ; }
        
        sslSocket = [MHSSLClientSocket sslSocketWithCertificateFile:nil
                                                            keyFile:nil
                                                             CAFile:_CAFile
                                                         sslOptions:0
                                                       isBlockingIO:YES] ;
        
        if ([sslSocket connectOnServer:_server port:_port]) {
            
            MSBuffer *queryBuf = [request buffer] ;
            
            if ([sslSocket writeBytes:[queryBuf bytes] length:(MSUInt)[queryBuf length]]) //send query
            {
                MSInt nbRead = 0 ;
                char data[BUFF_SIZE] ;
                MSBuffer *buffer = MSCreateBuffer(BUFF_SIZE) ;
                
                while ((nbRead = [sslSocket readIn:data length:BUFF_SIZE])) { CBufferAppendBytes((CBuffer *)buffer, data, nbRead) ; }
                
                //parse response into MSHTTPResponse
                response = [MSHTTPResponse httpResponseFromBytes:(void *)[buffer bytes] length:(MSUInt)[buffer length]] ;
                
                if(!response && error) { *error = AUTORELEASE(MSCreateASCIIStringWithBytes(data, nbRead, YES, YES)) ; }
                RELEASE(buffer) ;
                
                if (error) { *error = nil ; }
            } else
            {
                if (error) { *error = [NSString stringWithFormat:@"write failed on ssl socket on %@:%d",_server, _port] ; }
            }
        } else
        {
            if (error) { *error = [NSString stringWithFormat:@"could not connect ssl socket on %@:%d",_server, _port] ; }
        }
        
        //get session id
        if (response)
        {
            [self setSessionID:[response mashSessionID]] ;
        }
    }
    return response ;
}

- (MSHTTPResponse *)performRequest:(MSHTTPRequest *)request errorString:(NSString **)error
{
    MSHTTPResponse *response = nil ;
    NSString **errorString = (error) ? error : NULL ;
    [_requestLock lock] ;
  
    if (_authenticationType == MHAuthTicket && ![_sessionID length])
    {
        [request addQueryParameter:_ticket forKey:MHAUTH_QUERY_PARAM_TICKET] ;
    }
    
    // performs athenticated request, if it fails, tries authentcating 3 times... and performs request again
    response = [self _performRequest:request errorString:errorString] ;
    
    if (errorString && !*errorString && [response HTTPStatus] == HTTPUnauthorized)
    {
        BOOL auth = NO ;
        int i ;
        response = nil ;

        if ([self authenticationLevel] == AUTH_0_STEP) {
             response = [self _performRequest:request errorString:errorString] ;
        }
        else
        {
          for (i=0; i<3; i++)
          {
            if ((auth = [self authenticate]))
            {
              response = [self _performRequest:request errorString:errorString] ;
              if ([response HTTPStatus] == HTTPUnauthorized) { response = nil ; }
              break ;
            }
          }
          if (!auth && error) { *errorString = @"performRequest : failed to authentcate trice" ; }
        }
    }

  [_requestLock unlock] ;
  return response ;
}

- (BOOL)_performSimpleAuthentication
{
    //GEO TODO simple auth
    [self notImplemented:_cmd] ;
    return NO ;
}

- (MSHTTPRequest *)_challengeRequest
{
    MSHTTPRequest *request = [self request:GET onSubURL:nil] ;
    
    switch (_authenticationType) {
        case MHAuthPKChallengeAndURN:
        {
            [request addAdditionalHeaderValue:_urn forKey:@"MH-URN"] ;
            break;
        }
            
        case MHAuthChallengedPasswordLogin:
        {
            [request addAdditionalHeaderValue:_login forKey:@"MH-LOGIN"] ;
            break;
        }
            
        case MHAuthChallengedPasswordLoginOnTarget:
        {
            [request addAdditionalHeaderValue:_login forKey:@"MH-LOGIN"] ;
            [request addAdditionalHeaderValue:_target forKey:@"MH-TARGET"] ;
            break;
        }
            
        default:
            request = nil ;
            break;
    }
    return request ;
}

- (NSString *)_decryptRSAChallenge:(NSString *)challenge
{
    const void *challengeBytes = NULL ;
    MSBuffer *challengeBuf = nil ;   //b64 decode
    MSCipher *decoder = nil ;
    NSData *decryptedData = nil ;
    NSString *decodedChallenge = nil ;

    challengeBytes = [challenge UTF8String] ;
    challengeBuf = [[MSBuffer bufferWithBytesNoCopyNoFree:(void*)challengeBytes length:strlen(challengeBytes)] encodedToBase64] ;
    decoder = [MSCipher cipherWithKey:_sk type:RSADecoder] ;
    decryptedData = [decoder decryptData:challengeBuf] ;

    decodedChallenge = AUTORELEASE(MSCreateASCIIStringWithBytes((void *)[decryptedData bytes],
                                                                [decryptedData length],
                                                                NO, NO)) ;
    
    return decodedChallenge ;
}

- (MSHTTPRequest *)_challengeAuthenticationRequestWithChallenge:(NSString *)challenge
{
    MSHTTPRequest *request = [self request:GET onSubURL:nil] ;
    NSString *outgoingChallenge = nil ;
    
    switch (_authenticationType)
    {
        case MHAuthPKChallengeAndURN:
        {
            outgoingChallenge = [self _decryptRSAChallenge:challenge] ;
            [request addAdditionalHeaderValue:outgoingChallenge forKey:@"MH-CHALLENGE"] ;
            break ;
        }
            
        case MHAuthChallengedPasswordLogin :
        case MHAuthChallengedPasswordLoginOnTarget:
        {
            outgoingChallenge = MHChallengedPasswordHash(_password, challenge) ;
            [request addAdditionalHeaderValue:outgoingChallenge forKey:@"MH-PASSWORD"] ;
            break ;
        }
            
        default:
            request = nil ;
    }
    
    return request ;
}

- (BOOL)_authenticateWithChallenge:(NSString *)challenge
{
    BOOL auth = NO ;
    MSHTTPRequest *challengeAuth;
    MSHTTPResponse *challengeAuthResponse;
    [_requestLock lock] ;

    challengeAuth = [self _challengeAuthenticationRequestWithChallenge:challenge] ;
    challengeAuthResponse = [self _performRequest:challengeAuth errorString:NULL] ;
    
    if ([challengeAuthResponse HTTPStatus] == HTTPOK &&
        [MHAUTH_HEADER_RESPONSE_OK isEqualToString:[challengeAuthResponse headerValueForKey:MHAUTH_HEADER_RESPONSE]])
    {
        auth = YES ;
    }
    
    [_requestLock unlock] ;
    return auth ;
}

- (BOOL)_performChallengedAuthentication
{
    BOOL auth = NO ;
    MSHTTPRequest *challengeRequest = nil ;
    MSHTTPResponse *challengeResponse = nil ;

    [_requestLock lock] ;
    challengeRequest = [self _challengeRequest] ;
    challengeResponse = [self _performRequest:challengeRequest errorString:NULL] ;

    if ([challengeResponse HTTPStatus] == HTTPOK && [[challengeResponse content] length])
    {
        MSBuffer *contentBuf = [challengeResponse content] ;
        NSString *challenge = AUTORELEASE(MSCreateASCIIStringWithBytes((void *)[contentBuf bytes], [contentBuf length], NO, NO)) ;
        
        [_requestLock unlock] ;
        auth = [self _authenticateWithChallenge:challenge] ;
    }
    else {
        [_requestLock unlock] ;
    }
    return auth ;
}

- (BOOL)authenticate
{
    BOOL auth = NO ;
    MHInitSSL();

    [self setSessionID:nil] ;
    
    switch ([self authenticationLevel]) {
        case AUTH_0_STEP:
            auth = YES ;
            break ;
        case AUTH_1_STEP:
            auth = [self _performSimpleAuthentication] ;
            break;
            
        case AUTH_2_STEPS:
            auth = [self _performChallengedAuthentication] ;
            break ;
            
        default:
            MSRaise(NSInternalInconsistencyException, @"Authentication level not supported yet : %d", [self authenticationLevel]) ;
            break;
    }
    return auth ;
}

- (oneway void)close
{
    MSHTTPRequest *request = [self request:GET onSubURL:@"close"] ;
    [self performRequest:request errorString:NULL] ;
}


@end

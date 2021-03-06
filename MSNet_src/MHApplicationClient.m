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
    if ((self= [self initWithServerParameters:parameters]))
    {
        ASSIGN(_ticket, ticket) ;
        _authenticationType = MHAuthTicket ;
    }
    return self ;
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
    if ((self= [self initWithServerParameters:parameters]))
    {
        ASSIGN(_login, login) ;
        ASSIGN(_password, password) ;
        _authenticationType = MHAuthChallengedPasswordLogin ;
    }
    return self ;
}

- (id)initWithServerParameters:(NSDictionary *)parameters
            challengedPassword:(NSString *)password
                         login:(NSString *)login
                        target:(NSString *)target
{
    if ((self= [self initWithServerParameters:parameters]))
    {
        ASSIGN(_login, login) ;
        ASSIGN(_password, password) ;
        ASSIGN(_target, target) ;
        _authenticationType = MHAuthChallengedPasswordLoginOnTarget ;
    }
    return self ;
}

- (id)initWithServerParameters:(NSDictionary *)parameters
                           urn:(NSString *)urn
                     secretKey:(NSData *)sk
{
    if ((self= [self initWithServerParameters:parameters]))
    {
        ASSIGN(_sk, sk) ;
        ASSIGN(_urn, urn) ;
        _authenticationType = MHAuthPKChallengeAndURN ;
    }
    return self ;
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
        _isAuthenticated = NO;

        if ([self authenticationLevel] != AUTH_0_STEP)
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
          if (!auth && error) { *errorString = @"performRequest : failed to authenticate" ; }
        }
    }

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

- (NSString *)_signChallenge:(NSString *)challenge
{
    MSCipher *cipher = [MSCipher cipherWithKey:_sk type:RSADecoder] ;
    NSData *signature = [cipher sign:[challenge dataUsingEncoding:NSUTF8StringEncoding]] ;
    MSBuffer *signatureInB64 = [[MSBuffer bufferWithData:signature] encodedToBase64];
    return [MSASCIIString stringWithBuffer:signatureInB64] ;
}

- (MSHTTPRequest *)_challengeAuthenticationRequestWithChallenge:(NSString *)challenge
{
    MSHTTPRequest *request = [self request:GET onSubURL:nil] ;
    NSString *outgoingChallenge = nil ;
    
    switch (_authenticationType)
    {
        case MHAuthPKChallengeAndURN:
        {
            outgoingChallenge = [self _signChallenge:challenge] ;
            [request addAdditionalHeaderValue:outgoingChallenge forKey:@"MH-CHALLENGE"] ;
            break ;
        }
            
        case MHAuthChallengedPasswordLogin :
        case MHAuthChallengedPasswordLoginOnTarget:
        {
            outgoingChallenge = [MSSecureHash challengeResultFor:_password withChallengeInfo:challenge];
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
    MSHTTPRequest *challengeAuth;
    MSHTTPResponse *challengeAuthResponse;

    challengeAuth = [self _challengeAuthenticationRequestWithChallenge:challenge] ;
    challengeAuthResponse = [self _performRequest:challengeAuth errorString:NULL] ;
    
    return [challengeAuthResponse HTTPStatus] == HTTPOK
        && [MHAUTH_HEADER_RESPONSE_OK isEqualToString:[challengeAuthResponse headerValueForKey:MHAUTH_HEADER_RESPONSE]] ;
}

- (BOOL)_performChallengedAuthentication
{
    BOOL auth = NO ;
    MSHTTPRequest *challengeRequest = nil ;
    MSHTTPResponse *challengeResponse = nil ;

    challengeRequest = [self _challengeRequest] ;
    challengeResponse = [self _performRequest:challengeRequest errorString:NULL] ;

    if ([challengeResponse HTTPStatus] == HTTPOK && [[challengeResponse content] length])
    {
        MSBuffer *contentBuf = [challengeResponse content] ;
        NSString *challenge = AUTORELEASE(MSCreateASCIIStringWithBytes((void *)[contentBuf bytes], [contentBuf length], NO, NO)) ;
        
        auth = [self _authenticateWithChallenge:challenge] ;
    }
    return auth ;
}

- (NSString*)authenticationChallengeForLogin:(NSString *)login
{
    NSString *error = nil ;
    MSHTTPResponse *response ;
    MSHTTPRequest *request = [self request:GET onSubURL:nil] ;
    MSBuffer *responseContent ;
    
    [request addAdditionalHeaderValue:login forKey:@"MH-LOGIN"] ;
    response = [self _performRequest:request errorString:&error] ;
    responseContent = [response content] ;
    if ([response HTTPStatus] == HTTPOK && !error && [responseContent length] && [_sessionID length]) {
        return AUTORELEASE(MSCreateASCIIStringWithBytes((void *)[responseContent bytes], [responseContent length], YES, YES)) ;
    }
    
    return nil ;
}

- (BOOL)authenticationWithChallengedPassword:(NSString *)password
{
    MSHTTPResponse *response  ;
    MSHTTPRequest *request = [self request:GET onSubURL:nil] ;
    NSString *error ;
    
    [request addAdditionalHeaderValue:password forKey:@"MH-PASSWORD"] ;
    response = [self _performRequest:request errorString:&error] ;
    _isAuthenticated = [response HTTPStatus] == HTTPOK
                    && [MHAUTH_HEADER_RESPONSE_OK isEqualToString:[response headerValueForKey:MHAUTH_HEADER_RESPONSE]] ;
    return _isAuthenticated;
}

- (BOOL)authenticate
{
    [self setSessionID:nil] ;
    
    switch ([self authenticationLevel]) {
        case AUTH_0_STEP:
            _isAuthenticated = YES ;
            break ;
        case AUTH_1_STEP:
            _isAuthenticated = [self _performSimpleAuthentication] ;
            break;
            
        case AUTH_2_STEPS:
            _isAuthenticated = [self _performChallengedAuthentication] ;
            break ;
            
        default:
            MSRaise(NSInternalInconsistencyException, @"Authentication level not supported yet : %d", [self authenticationLevel]) ;
            break;
    }
    return _isAuthenticated;
}


- (BOOL)isAuthenticated
{
  return _isAuthenticated;
}

- (oneway void)close
{
    MSHTTPRequest *request = [self request:GET onSubURL:@"close"] ;
    [self performRequest:request errorString:NULL] ;
}


@end

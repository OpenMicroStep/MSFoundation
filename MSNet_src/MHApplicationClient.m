//
//  MHApplicationClient.m
//
//
//  Created by Geoffrey Guilbon on 29/10/13.
//  Copyright (c) 2013 Geoffrey Guilbon. All rights reserved.
//

#import "_MASHPrivate.h"
#import "MHApplicationClient.h"

#define BUFF_SIZE 2048

typedef enum
{
    appNotAuthenticated = 0,
    appChallengeRequest,
    appAuthenticating,
	appAuthenticated,
    appClosing,
    appAuthFailStop
} MHAppClientAuthStatus ;

@implementation MHApplicationClient

+ (id)clientWithCertificateFile:(NSString *)certificateFile
                        keyFile:(NSString *)keyFile
                         CAFile:(NSString *)CAFile
                       onServer:(NSString *)server
                        baseURL:(NSString *)baseURL
                           port:(MSUInt)port
{
    return [[[self alloc] initWithCertificateFile:certificateFile
                                          keyFile:keyFile
                                           CAFile:CAFile
                                         onServer:server
                                          baseURL:baseURL
                                             port:port] autorelease];
}

- (id)initWithCertificateFile:(NSString *)certificateFile
                      keyFile:(NSString *)keyFile
                       CAFile:(NSString *)CAFile
                     onServer:(NSString *)server
                      baseURL:(NSString *)baseURL
                         port:(MSUInt)port
{
    BOOL isDirectory = YES ;
    
    if ([certificateFile length] && (! MSFileExistsAtPath(certificateFile, &isDirectory) || isDirectory)) MSRaise(NSGenericException, @"cannot find certificate file") ;
    if ([certificateFile length] && (! MSFileExistsAtPath(keyFile, &isDirectory) || isDirectory)) MSRaise(NSGenericException, @"cannot find key file") ;
    if (! MSFileExistsAtPath(CAFile, &isDirectory) || isDirectory) MSRaise(NSGenericException, @"cannot find CAFile file") ;
    if (! [server length]) MSRaise(NSGenericException, @"empty server string") ;
    
    [self setCertificateFile:certificateFile] ;
    [self setKeyFile:keyFile] ;
    [self setCAFile:CAFile] ;
    [self setServer:server] ;
    [self setBaseURL:baseURL] ;
    [self setPort:port] ;
    
    _authenticationStatus = appNotAuthenticated ;
    
    return self ;
}

- (void)dealloc
{
    DESTROY(_certificateFile) ;
    DESTROY(_keyFile) ;
    DESTROY(_CAFile) ;
    DESTROY(_server) ;
    DESTROY(_baseURL) ;
    DESTROY(_sessionID) ;
    
    [super dealloc] ;
}

- (NSString *)certificateFile { return _certificateFile ; }
- (void)setCertificateFile:(NSString *)certificateFile { ASSIGN(_certificateFile, certificateFile) ; }
- (NSString *)keyFile { return _keyFile ; }
- (void)setKeyFile:(NSString *)keyFile { ASSIGN(_keyFile, keyFile) ; }
- (NSString *)CAFile { return _CAFile ; }
- (void)setCAFile:(NSString *)CAFile { ASSIGN(_CAFile, CAFile) ; }
- (NSString *)server { return _server ; }
- (void)setServer :(NSString *)server { ASSIGN(_server, server) ; }
- (NSString *)baseURL { return _baseURL ; }
- (void)setBaseURL:(NSString *)baseURL { ASSIGN(_baseURL, baseURL) ; }
- (MSUInt)port { return _port ; }
- (void)setPort:(MSUInt)port { _port = port ; }
- (NSString *)sessionID { return _sessionID ; }
- (void)setSessionID:(NSString *)sessionID { ASSIGN(_sessionID, sessionID) ; }
- (BOOL)isAuthenticated { return _authenticationStatus == appAuthenticated ; }

- (BOOL)isChallengeAuthentication { return _isChallengeAuthentication ; }
- (void)setChallengeAuthentication:(BOOL)challengeAuthentication { _isChallengeAuthentication = challengeAuthentication ; }
- (MSHTTPResponse *)challengeResponse { return _challengeResponse ; }

- (NSString *)_sessionIDFromHTTPResponseCookie:(MSHTTPResponse *)response
{
    NSString *sessionID = nil ;
    NSString *setCookieLine = [response headerValueForKey:@"Set-Cookie"] ;
    
    if([setCookieLine length] && ![setCookieLine containsString:@"deleted"])
    {
        sessionID = [[setCookieLine componentsSeparatedByString:@";"] objectAtIndex:0] ;
    }
    return sessionID ;
}

- (void)_readResponse:(MSHTTPResponse *)response errorBuffer:(MSBuffer *)errorBuffer
{
    MSUInt status = [response HTTPStatus] ;
    [self setSessionID:[self _sessionIDFromHTTPResponseCookie:response]] ;
    
    //NSLog(@"HTTP Status : %d", status) ;
    //NSLog(@"New sessionID = %@",_sessionID) ;
    
    if (_authenticationStatus == appAuthenticating)
    {
        NSString *successHeader = [response headerValueForKey:@"MASH_AUTH_RESPONSE"] ;
        
        if(status == 200 && [successHeader isEqualToString:@"SUCCESS"])
        {
            _authenticationStatus = appAuthenticated ; //authentication ok.
        } else
        {
            _authenticationStatus = appAuthFailStop ; //could not authenticate. Stop.
        }
    } else if (_authenticationStatus == appChallengeRequest) //challenge authentication
    {
        if (status == 200 && [[response headerValueForKey:@"MASH_AUTH_REQUIRED"] length])
        {
            _authenticationStatus = appAuthenticating ; //challenge received, keep authenticating
        } else
        {
            _authenticationStatus = appAuthFailStop ; //challenge not received. Stop.
        }
    }
    else if(status == 403) //session expired must authenticate again
    {
        if (_authenticationStatus == appAuthenticating)
        {
            _authenticationStatus = appAuthFailStop ; //could not authenticate. Stop.
        } else
        {
            _authenticationStatus = appNotAuthenticated ;
        }
    }
    
    /*if(status != 200)
    {
        if(errorBuffer) {
            void *bytes = (void *)[errorBuffer bytes] ;
            MSBuffer *buf = AUTORELEASE(MSCreateBufferWithBytes(bytes, strlen(bytes), YES, YES)) ;
            NSLog(@"Error Buffer : %@",[[NSString alloc] initWithData:buf encoding:NSUTF8StringEncoding]) ;
        }
    }*/
}

- (MSHTTPResponse *)performRequest:(MSHTTPRequest *)request errorBuffer:(MSBuffer **)errorBuffer
{
    MHSSLClientSocket *sslSocket = nil ;
    MSHTTPResponse *response = nil ;
    
    if (request)
    {
        if ([_sessionID length])
        {
            [request addAdditionalHeaderValue:_sessionID forKey:@"Cookie"] ;
        }
        
        sslSocket = [MHSSLClientSocket sslSocketWithCertificateFile:[self certificateFile]
                                                            keyFile:[self keyFile]
                                                             CAFile:[self CAFile]
                                                         sslOptions:0
                                                       isBlockingIO:YES] ;
        
        if ([sslSocket connectOnServer:_server port:_port]) {
            
            MSBuffer *queryBuf = [request buffer] ;
            //NS?Log(@"request=%s",[queryBuf bytes]) ;
            
            if ([sslSocket writeBytes:[queryBuf bytes] length:(MSUInt)[queryBuf length]]) //send query
            {
                MSInt nbRead = 0 ;
                char data[BUFF_SIZE] ;
                MSBuffer *buffer = MSCreateBuffer(BUFF_SIZE) ;
                
                while ((nbRead = [sslSocket readIn:data length:BUFF_SIZE]))
                {
                    CBufferAppendBytes((CBuffer *)buffer, data, nbRead) ;
                }
                
                response = [MSHTTPResponse httpResponseFromBytes:(void *)[buffer bytes] length:(MSUInt)[buffer length]] ;
                
                if(!response && errorBuffer) {
                    *errorBuffer = AUTORELEASE(MSCreateBufferWithBytes(data, nbRead)) ;
                }
                RELEASE(buffer) ;
            }
        }
        
        if (response) {
            [self _readResponse:response errorBuffer:errorBuffer ? *errorBuffer : NULL] ;
            //no session, authenticate again, then perform query
            if (_authenticationStatus == appNotAuthenticated)
            {
                if ([self authenticate])
                {
                    response = [self performRequest:request errorBuffer:errorBuffer] ; //retry request if reauth succeedeed
                }
            }
        }
    }
    
    return response ;
}

- (MSHTTPRequest *)challengeRequest { [self notImplemented:_cmd] ; return nil ; }
- (MSHTTPRequest *)authenticationRequest { [self notImplemented:_cmd] ; return nil ; }
- (MSHTTPRequest *)closeRequest
{
    MSHTTPRequest *request = nil ;
    
    request = [MSHTTPRequest requestWithMethod:GET toHost:[self server] url:[[self baseURL] stringByAppendingURLComponent:DEFAULT_LOGIN_URL_COMPONENT]] ;
    
    return request ;
}

- (void)_performAuthentication
{
    MSHTTPResponse *response = nil ;
    MSHTTPRequest *request = [self authenticationRequest] ;
    
    response = [self performRequest:request errorBuffer:NULL] ;
}

- (void)_authenticate
{
    if (_isChallengeAuthentication)
    {
        MSHTTPRequest *challengeRequest = nil ;
        MSHTTPResponse *challengeResponse = nil ;
        
        _authenticationStatus = appChallengeRequest ;
        
        challengeRequest = [self challengeRequest] ;
        challengeResponse = [self performRequest:challengeRequest errorBuffer:NULL] ;
        
        ASSIGN(_challengeResponse, challengeResponse) ;
        
        if([challengeResponse HTTPStatus] == 200 && [[challengeResponse headerValueForKey:@"MASH_AUTH_REQUIRED"] length])
        {
            //NSLog(@"Challenge received, perform authentication...") ;
            [self _performAuthentication] ;
        }
        
    } else
    {
        [self _performAuthentication] ;
    }
}

- (BOOL)authenticate
{    
    _authenticationStatus = appAuthenticating ;
    
    [self _authenticate] ;
    
    return (_authenticationStatus == appAuthenticated) ;
}

- (oneway void)close
{
    MSHTTPResponse *response = nil ;
    MSHTTPRequest *request = [self closeRequest] ;
    _authenticationStatus = appClosing ;
    
    response = [self performRequest:request errorBuffer:NULL] ;
}


@end

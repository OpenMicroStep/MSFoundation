//
//  MHApplicationClient.h
//
//
//  Created by Geoffrey Guilbon on 29/10/13.
//  Copyright (c) 2013 Geoffrey Guilbon. All rights reserved.
//

@interface MHApplicationClient : NSObject
{
    NSString *_certificateFile ;
    NSString *_keyFile ;
    NSString *_CAFile ;
    NSString *_server ;
    NSString *_baseURL ;
    MSUInt _port;
    NSString *_sessionID ;
    MSUInt _authenticationStatus ;
    BOOL _isChallengeAuthentication ;
    MSHTTPResponse *_challengeResponse ;
}

+ (id)clientWithCertificateFile:(NSString *)certificateFile
                        keyFile:(NSString *)keyFile
                         CAFile:(NSString *)CAFile
                       onServer:(NSString *)server
                        baseURL:(NSString *)baseURL
                           port:(MSUInt)port ;

- (id)initWithCertificateFile:(NSString *)certificateFile
                      keyFile:(NSString *)keyFile
                       CAFile:(NSString *)CAFile
                     onServer:(NSString *)server
                      baseURL:(NSString *)baseURL
                         port:(MSUInt)port ;

- (NSString *)certificateFile ;
- (void)setCertificateFile:(NSString *)certificateFile ;
- (NSString *)keyFile ;
- (void)setKeyFile:(NSString *)keyFile ;
- (NSString *)CAFile ;
- (void)setCAFile:(NSString *)CAFile ;
- (NSString *)server ;
- (void)setServer :(NSString *)server ;
- (NSString *)baseURL ;
- (void)setBaseURL:(NSString *)baseURL ;
- (MSUInt)port ;
- (void)setPort :(MSUInt)port ;
- (NSString *)sessionID ;
- (void)setSessionID:(NSString *)sessionID ;
- (BOOL)isAuthenticated ;

- (BOOL)isChallengeAuthentication ;
- (void)setChallengeAuthentication:(BOOL)challengeAuthentication ;
- (MSHTTPResponse *)challengeResponse ;

- (BOOL)authenticate ;
- (oneway void)close ;

- (MSHTTPRequest *)challengeRequest ;
- (MSHTTPRequest *)authenticationRequest ;
- (MSHTTPRequest *)closeRequest ;
- (MSHTTPResponse *)performRequest:(MSHTTPRequest *)request errorBuffer:(MSBuffer **)errorBuffer ;

@end

//
//  MHApplicationClient.h
//
//
//  Created by Geoffrey Guilbon on 29/10/13.
//  Copyright (c) 2013 Geoffrey Guilbon. All rights reserved.
//

@interface MHApplicationClient : NSObject
{
    NSString *_server ;
    MSUInt _port;
    NSString *_CAFile ;
    NSString *_baseURL ;

    NSString *_sessionID ;
    MSHTTPResponse *_challengeResponse ;
    
    MHAppAuthentication _authenticationType ;
    
    NSString *_urn ;
    NSData *_sk ;
    
    NSString *_login ;
    NSString *_password ;
    NSString *_target ;
    
    NSString *_ticket ;
}

+ (id)clientWithServerParameters:(NSDictionary *)parameters ;
- (id)initWithServerParameters:(NSDictionary *)parameters ;

+ (id)clientWithServerParameters:(NSDictionary *)parameters
                       sessionID:(NSString *)sessionID ;
- (id)initWithServerParameters:(NSDictionary *)parameters
                     sessionID:(NSString *)sessionID ;

+ (id)clientWithServerParameters:(NSDictionary *)parameters
                          ticket:(NSString *)ticket ;
- (id)initWithServerParameters:(NSDictionary *)parameters
                        ticket:(NSString *)ticket ;

+ (id)clientWithServerParameters:(NSDictionary *)parameters
              challengedPassword:(NSString *)password
                           login:(NSString *)login ;

- (id)initWithServerParameters:(NSDictionary *)parameters
            challengedPassword:(NSString *)password
                         login:(NSString *)login ;


+ (id)clientWithServerParameters:(NSDictionary *)parameters
              challengedPassword:(NSString *)password
                           login:(NSString *)login
                          target:(NSString *)target ;

- (id)initWithServerParameters:(NSDictionary *)parameters
            challengedPassword:(NSString *)password
                         login:(NSString *)login
                        target:(NSString *)target ;

+ (id)clientWithServerParameters:(NSDictionary *)parameters
                             urn:(NSString *)urn
                       secretKey:(NSData *)sk ;

- (id)initWithServerParameters:(NSDictionary *)parameters
                           urn:(NSString *)urn
                     secretKey:(NSData *)sk ;

- (BOOL)authenticate ;
- (oneway void)close ;
- (MSHTTPResponse *)performRequest:(MSHTTPRequest *)request errorString:(NSString **)error ;

//tools
- (MSHTTPRequest *)request:(MSHTTPMethod)method onSubURL:(NSString *)subURL ;

@end

//
//  MHRepositoryClient.m
//  testRepository
//
//  Created by Geoffrey Guilbon on 25/10/13.
//  Copyright (c) 2013 Geoffrey Guilbon. All rights reserved.
//

//#import <MASH/MASH.h>
#import "_MASHPrivate.h"
#import "MHNetRepositoryClient.h"
#import "MHNetRepositoryApplication.h"

#define CRLF @"\r\n"

@implementation MHNetRepositoryClient

- (NSString *)publicKeyForURN:(NSString *)urn
{
    //GEO TODO #define hard-coded values
    NSString *publicKey = nil ;
    MSHTTPResponse *response = nil ;
    MSHTTPRequest *request = nil ;
    MSBuffer *responseContent = nil ;
    NSString *error = nil ;
    
    request = [self request:GET onSubURL:@"getPublicKey"] ;
    [request addAdditionalHeaderValue:urn forKey:@"MH-URN"] ;
    response = [self performRequest:request errorString:&error] ;
    responseContent = [response content] ;
    
    if (!error && [response HTTPStatus] == HTTPOK && [responseContent length])
    {
        publicKey = AUTORELEASE(MSCreateASCIIStringWithBytes((void *)[responseContent bytes], [responseContent length], YES, YES)) ;
    }
    
    return publicKey ;
}


- (BOOL)verifyChallengedPassword:(NSString *)password
                        forLogin:(NSString *)login
                    andChallenge:(NSString *)challenge
{
    //GEO TODO #define hard-coded values
    MSHTTPResponse *response = nil ;
    MSHTTPRequest *request = nil ;
    NSString *authResponseStr = nil ;
    BOOL auth = NO ;
    NSString *error ;

    request = [self request:GET onSubURL:@"verifyChallenge"] ;
    [request addAdditionalHeaderValue:login forKey:@"MH-LOGIN"] ;
    [request addAdditionalHeaderValue:password forKey:@"MH-PASSWORD"] ;
    [request addAdditionalHeaderValue:challenge forKey:@"MH-CHALLENGE"] ;
    
    response = [self performRequest:request errorString:&error] ;

    if (response && !error)
    {
        authResponseStr = [response headerValueForKey:MHAUTH_HEADER_RESPONSE] ;
        
        if ([response HTTPStatus] == HTTPOK &&
            [MHAUTH_HEADER_RESPONSE_OK isEqualToString:authResponseStr])
        {
            auth = YES ;
        }
    }
    
    return auth ;
}

@end

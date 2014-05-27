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

#define CRLF @"\r\n"

@implementation MHNetRepositoryClient

- (MSHTTPRequest *)authenticationRequest
{
    MSHTTPRequest *request = nil ;
    char *content = "DUMMY" ;
    
    request = [MSHTTPRequest requestWithMethod:POST toHost:[self server] url:[self baseURL]] ;
    [request addBytes:(void *)content length:strlen(content)] ;
    [request setContentType:@"text/xml; charset=utf-8"] ;
    
    return request ;
}

- (TID *)identifierForUrn:(NSString *)urn
{
    TID *tid = nil ;
    MSHTTPRequest *request = nil ;
    MSHTTPResponse *response = nil ;
    
    request = [MSHTTPRequest requestWithMethod:GET toHost:[self server] url:[[self baseURL] stringByAppendingURLComponent:MHNR_SUB_URL_ID_FOR_URN]] ;
    [request addQueryParameter:urn forKey:MHNR_QUERY_PARAM_URN] ;
    
    response = [self performRequest:request errorBuffer:NULL] ;
    
    if(response)
    {
        void *bytes = (void *)[[response content] bytes] ;
                
        if(bytes)
        {
            NSString *str = AUTORELEASE(MSCreateASCIIStringWithBytes(bytes, strlen(bytes), YES, YES)) ;
            tid = [[str componentsSeparatedByString:CRLF] objectAtIndex:0] ;
        }
    }
    
    return tid ;
}

- (NSDictionary *)_parseInformationResponse:(MSHTTPResponse *)response
{
    NSDictionary *dic = nil ;
    void *bytes = (void *)[[response content] bytes] ;
    
    if (bytes)
    {
        dic = [[[NSString alloc] initWithData:[response content] encoding:NSUTF8StringEncoding] dictionaryValue];
    }
        
    return dic ;
}

- (NSDictionary *)getPublicInformationsForKeys:(NSArray *)keys inTree:(NSString *)tree underIdentifier:(TID *)identifier
{
    MSHTTPRequest *request = nil ;
    MSHTTPResponse *response = nil ;
    NSString *splittedKeys = [keys componentsJoinedByString:MHNR_QUERY_PARAM_SEPARATOR] ;
    
    request = [MSHTTPRequest requestWithMethod:GET toHost:[self server] url:[[self baseURL] stringByAppendingURLComponent:MHNR_SUB_URL_GET_PUB_INFOS]] ;
    [request addQueryParameter:splittedKeys forKey:MHNR_QUERY_PARAM_KEY] ;
    [request addQueryParameter:identifier forKey:MHNR_QUERY_PARAM_UNDER_ID] ;
    [request addQueryParameter:tree forKey:MHNR_QUERY_PARAM_IN_TREE] ;
    
    response = [self performRequest:request errorBuffer:NULL] ;
    
    return [self _parseInformationResponse:response] ;
}

@end

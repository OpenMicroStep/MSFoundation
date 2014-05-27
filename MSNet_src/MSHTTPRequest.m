//
//  MSHTTPRequest.m
//
//
//  Created by Geoffrey Guilbon on 20/08/13.
//  Copyright (c) 2013 Geoffrey Guilbon. All rights reserved.
//

#import "MSNet_Private.h"
//#import "_MSFoundationPrivate.h"
//#import "MSStringAdditions.h"
//#import "MSHTTPRequest.h"

#define HTTP_METHOD_POST @"POST"
#define HTTP_METHOD_GET  @"GET"

#define DEFAULT_HTTP_VERSION @"HTTP/1.1"
#define CRLF @"\r\n"

@implementation MSHTTPRequest

+ (id)requestWithMethod:(MSHTTPMethod)method toHost:(NSString *)host url:(NSString*)url
{
    return [[[self alloc] initWithMethod:method toHost:host url:url] autorelease] ;
}

- (id)initWithMethod:(MSHTTPMethod)method toHost:(NSString *)host url:(NSString*)url
{
    ASSIGN(_additionalHeaders, [NSMutableDictionary dictionary]) ;
    ASSIGN(_queryParameters, [NSMutableDictionary dictionary]) ;
    ASSIGN(_content, MSCreateBuffer(0)) ;
    
    [self setMethod:method] ;
    [self setHost:host] ;
    [self setURL:url] ;
    
    ASSIGN(_HTTPVersion, DEFAULT_HTTP_VERSION);
    
    return self ;
}

- (void)dealloc
{
    DESTROY(_additionalHeaders) ;
    DESTROY(_content) ;
    DESTROY(_host) ;
    DESTROY(_HTTPVersion) ;
    DESTROY(_contentType) ;
    DESTROY(_queryParameters) ;
    
    [super dealloc] ;
}

- (MSHTTPMethod)method { return _method ; }
- (void)setMethod:(MSHTTPMethod)method { _method = method ; }

- (NSString *)host { return _host ; }
- (void)setHost:(NSString *)host { ASSIGN(_host, host) ; }

- (NSString *)url { return _url ; }
- (void)setURL:(NSString *)url { ASSIGN(_url, url) ;}

- (NSString *)HTTPVersion  { return _HTTPVersion ; }
- (void)setHTTPVersion:(NSString *)HTTPVersion { ASSIGN(_HTTPVersion, HTTPVersion) ; }

- (NSString *)contentType { return _contentType ; }
- (void)setContentType:(NSString *)contentType { ASSIGN(_contentType, contentType) ; }

- (MSBuffer *)content { return _content ; }
- (void)addBytes:(void *)bytes length:(MSULong)length { if(bytes && length) CBufferAppendBytes((CBuffer *)_content, bytes, length) ; }

- (NSDictionary *)additionalHeaders { return _additionalHeaders ; }
- (void)addAdditionalHeaderValue:(id)value forKey:(NSString *)key { if(value && [key length]) [_additionalHeaders setObject:value forKey:key] ; }

- (NSDictionary *)queryParameters { return _queryParameters ; }
- (void)addQueryParameter:(id)value forKey:(NSString *)key { if(value && [key length]) [_queryParameters setObject:value forKey:key] ; }

- (MSBuffer *)buffer
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:[_additionalHeaders copy]] ;
    NSString *method = (_method == GET) ? HTTP_METHOD_GET : HTTP_METHOD_POST ;
    NSString *request = @"" ;
    NSString *key, *tmp ;
    NSEnumerator *keyEnum ;
    MSBuffer *result = AUTORELEASE(MSCreateBuffer(256)) ;
    NSString *queryString = [_url stringWithURLEncoding];
    
    if([_queryParameters count])
    {
        BOOL once = YES ;
        NSString *format ;
        
        keyEnum = [_queryParameters keyEnumerator] ;
        queryString = [queryString stringByAppendingString:@"?"] ;
        
        while ((key = [keyEnum nextObject])) {
            id value = [[_queryParameters objectForKey:key] description] ;
            
            format = (once) ? @"%@=%@" : @"&%@=%@" ;
        
            queryString = [queryString stringByAppendingString:[NSString stringWithFormat:format,key,[value stringWithURLEncoding]]] ;
            if(once) once = NO ;
        }
    }
    
    request = [request stringByAppendingString:[NSString stringWithFormat:@"%@ %@ %@\r\n",method, queryString, _HTTPVersion]] ;

    [headers setObject:_host forKey:@"Host"] ; //set host
    
    if(_method == POST && [_content length] && [_contentType length])
    {
        [headers setObject:_contentType forKey:@"Content-Type"] ;
        [headers setObject:[[NSNumber numberWithUnsignedLong:[_content length]] stringValue] forKey:@"Content-Length"] ;
    }
    
    //write headers into request
    keyEnum = [headers keyEnumerator] ;
    while((key = [keyEnum nextObject]))
    {
        tmp =[NSString stringWithFormat:@"%@: %@%@",key, [headers objectForKey:key], CRLF] ;
        request = [request stringByAppendingString:tmp] ;
    }
    request = [request stringByAppendingString:CRLF] ;
    
    CBufferAppendCString((CBuffer *)result, (char *)[request asciiCString]) ;
    
    if([_content length])
    {
        CBufferAppendBuffer((CBuffer *)result, (CBuffer *)_content) ;
    }
    
    
    return result ;
}

@end

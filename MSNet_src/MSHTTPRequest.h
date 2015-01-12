//
//  MSHTTPRequest.h
//
//
//  Created by Geoffrey Guilbon on 20/08/13.
//  Copyright (c) 2013 Geoffrey Guilbon. All rights reserved.
//

typedef enum
{
    GET = 0,
	POST
} MSHTTPMethod ;

@interface MSHTTPRequest : NSObject
{
    MSHTTPMethod _method ;
    NSString *_host ;
    NSString *_url ;
    NSString *_HTTPVersion ;
    NSString *_contentType ;
    MSBuffer *_content ;
    NSMutableDictionary *_additionalHeaders ;
    NSMutableDictionary *_queryParameters ;
}

+ (id)requestWithMethod:(MSHTTPMethod)method toHost:(NSString *)host url:(NSString*)url ;
- (id)initWithMethod:(MSHTTPMethod)method toHost:(NSString *)host url:(NSString*)url ;

- (MSHTTPMethod)method ;
- (void)setMethod:(MSHTTPMethod)method ;

- (NSString *)host ;
- (void)setHost:(NSString *)host ;

- (NSString *)url ;
- (void)setURL:(NSString *)url ;

- (NSString *)HTTPVersion ;
- (void)setHTTPVersion:(NSString *)HTTPVersion ;

- (NSString *)contentType ;
- (void)setContentType:(NSString *)contentType ;

- (MSBuffer *)content ;
- (void)addBytes:(const void *)bytes length:(MSULong)length ;

- (NSDictionary *)additionalHeaders ;
- (void)addAdditionalHeaderValue:(id)value forKey:(NSString *)key ;

- (NSDictionary *)queryParameters ;
- (void)addQueryParameter:(id)value forKey:(NSString *)key ;

- (MSBuffer *)buffer ;

@end

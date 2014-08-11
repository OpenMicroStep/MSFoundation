//
//  MSHTTPResponse.h
//
//
//  Created by Geoffrey Guilbon on 20/08/13.
//  Copyright (c) 2013 Geoffrey Guilbon. All rights reserved.
//

@interface MSHTTPResponse : NSObject
{
    NSString *_HTTPVersion ;
    MSUInt _HTTPStatus ;
    NSString *_HTTPStatusString ;
    NSMutableDictionary *_headers ;
    NSString *_contentType ;
    MSBuffer *_content ;
}

+ (id)httpResponseFromBytes:(void *)bytes length:(MSUInt)length ;
- (id)initFromBytes:(void *)bytes length:(MSUInt)length ;

- (NSString *)HTTPVersion ;
- (void)setHTTPVersion:(NSString *)HTTPVersion ;

- (MSUInt)HTTPStatus ;
- (void)setHTTPStatus:(MSUInt)status ;

- (NSString *)HTTPStatusString ;
- (void)setHTTPStatusString:(NSString *)HTTPStatusString ;

- (NSString *)headerValueForKey:(NSString *)header ;
- (void)setHeader:(NSString *)value forKey:(NSString *)header ;
- (NSDictionary *)headers ;

- (NSString *)contentType ;
- (void)setContentType:(NSString *)contentType ;

- (MSBuffer *)content ;
- (void)addBytes:(void *)bytes length:(MSUInt)length ;

@end

@interface MSHTTPResponse (MASHAdditions)

- (NSString *)mashSessionID ;

@end


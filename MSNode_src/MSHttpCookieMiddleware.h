@class MSHttpCookie;

@interface MSHttpCookieMiddleware : NSObject <MSHttpMiddleware>
+ (instancetype)cookieMiddleware;
@end

@interface MSHttpTransaction (MSHttpCookieMiddleware)
- (MSHttpCookie *)cookieForName:(NSString *)name;
- (NSString *)cookieValueForName:(NSString *)name;
- (void)setCookie:(MSHttpCookie *)value forName:(NSString *)name;
@end

@interface MSHttpCookie : NSObject {
  NSString *_value, *_path, *_domain;
  NSDate *_expires;
  BOOL _secure, _notOnlyHttp, _sent;
}
+ (instancetype)cookieWithValue:(NSString *)value;
- (NSString *)value;
- (NSDate *)expires;
- (NSString *)path;
- (NSString *)domain;
- (BOOL)secure;
- (BOOL)httpOnly;
- (BOOL)sent;
- (void)setValue:(NSString *)value;
- (void)setExpires:(NSDate *)expires;
- (void)setPath:(NSString *)path;
- (void)setDomain:(NSString *)domain;
- (void)setSecure:(BOOL)secure;
- (void)setHttpOnly:(BOOL)httpOnly;
- (void)setSent:(BOOL)sent;
@end
@interface MSHttpCookieManager : NSObject {
  CDictionary *_cookies;
}
- (void)updateWithTransaction:(MSHttpTransaction *)tr;
- (void)sendOnTransaction:(MSHttpTransaction *)tr;
- (void)updateWithClientResponse:(MSHttpClientResponse *)response;
- (void)sendOnClientRequest:(MSHttpClientRequest *)request;
- (NSString *)cookieValueForName:(NSString *)name;
- (MSHttpCookie *)cookieForName:(NSString *)name;
- (void)setCookie:(MSHttpCookie *)cookie forName:(NSString *)name;
@end

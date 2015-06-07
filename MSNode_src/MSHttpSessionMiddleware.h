
// Try to authenticate the transaction associated with the given session.
@protocol MSHttpSessionAuthenticator
- (void)authenticate:(MSHttpTransaction *)tr next:(id <MSHttpNextMiddleware>)next;
@end

@interface MSHttpSession : NSObject {
  id _key, _instigator;
  void *_uv_timer;
}
+ (NSString *)generateSessionKey;
- (NSString *)key;
- (BOOL)isAuthenticated;

- (NSTimeInterval)lifetime;
- (instancetype)update;
- (void)kill;
@end

@interface MSHttpSessionMiddleware : NSObject <MSHttpMiddleware> {
  NSString *_cookieName;
  Class _sessionClass;
  CDictionary *_sessions;
  id <MSHttpSessionAuthenticator> _authenticator;
}
- (instancetype)initWithCookieName:(NSString *)name;
- (instancetype)initWithCookieName:(NSString *)name sessionClass:(Class)cls;

- (void)setAuthenticator:(id <MSHttpSessionAuthenticator>)authenticator;
@end

@interface MSHttpTransaction (MSHttpSessionMiddleware)
- (id)session;
@end

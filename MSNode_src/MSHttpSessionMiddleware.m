#import "MSNode_Private.h"

@interface MSHttpSessionMiddleware (Private)
- (void)_removeSession:(MSHttpSession *)session;
@end

@implementation MSHttpSession
+ (NSString *)generateSessionKey
{
  MSBuffer *rnd= MSCreateRandomBuffer(16);
  NSString *ret= MSBytesToHexaString([rnd bytes], [rnd length], NO);
  [rnd release];
  return ret;
}

+ (instancetype)sessionWithKey:(id)key withInstigator:(id)m
{
  return [[[self alloc] initWithKey:key withInstigator:m] autorelease];
}

- (instancetype)initWithKey:(id)key withInstigator:(id)m
{
  if (!key)
    key= [[self class] generateSessionKey];
  _key= [key retain];
  _instigator= [m retain];
  //NSLog(@"Session %p created", self);
  return [self init];
}
- (void)dealloc
{
  //if (_uv_timer)
  //  NSLog(@"Session %p destroyed without killing it first", self);
  [self kill];
  DESTROY(_key);
  DESTROY(_instigator);
  //NSLog(@"Session %p destroyed", self);
  [super dealloc];
}

static void _sessionTimeout(MSHttpSession* self)
{
  NSLog(@"Session %p timed out", self);
  [self kill];
}
- (instancetype)update {
  MSNodeClearTimeout(_uv_timer);
  _uv_timer= MSNodeSetTimeout((void (*)(void*))_sessionTimeout, [self lifetime] * 1000, self);
  return self;
}
- (BOOL)isAuthenticated    { return NO; }
- (NSTimeInterval)lifetime { return [self isAuthenticated] ? 86400 : 3600; }
- (NSString *)key          { return _key; }
- (void)kill
{
  if (_uv_timer) {
    NSLog(@"Session %p killed %d", self, (int)[self retainCount]);
    MSNodeClearTimeout(_uv_timer);
    _uv_timer=NULL;
    [_instigator _removeSession:self];}
}
@end
@implementation MSHttpSessionMiddleware
- (instancetype)initWithCookieName:(NSString *)name
{ return [self initWithCookieName:name sessionClass:[MSHttpSession class]]; }
- (instancetype)initWithCookieName:(NSString *)name sessionClass:(Class)cls
{
  _cookieName= [name copy];
  _sessionClass= cls;
  _sessions= CCreateDictionary(0);
  return self;
}
- (void)dealloc
{
  RELEASE(_authenticator);
  RELEASE(_cookieName);
  RELEASE(_sessions);
  [super dealloc];
}

- (void)setAuthenticator:(id <MSHttpSessionAuthenticator>)authenticator
{ ASSIGN(_authenticator, authenticator); }
- (void)_removeSession:(MSHttpSession *)session
{
  CDictionarySetObjectForKey(_sessions, nil, [session key]);
}

- (void)onTransaction:(MSHttpTransaction *)tr
{
  NSString *sessionKey; MSHttpSession *session; MSHttpCookie *cookie;
  sessionKey= [tr cookieValueForName:_cookieName];
  session= CDictionaryObjectForKey(_sessions, sessionKey);
  if (!session) {
    sessionKey= [_sessionClass generateSessionKey];
    cookie= [MSHttpCookie cookieWithValue:sessionKey];
    [cookie setPath:[tr urlRouted]];
    [tr setCookie:cookie forName:_cookieName];
    session= [[ALLOC(_sessionClass) initWithKey:sessionKey withInstigator:self] autorelease];
    CDictionarySetObjectForKey(_sessions, session, sessionKey);}
  session= [session update];
  [tr setObject:session forKey:@"MSHttpSessionMiddleware"];
  if([session isAuthenticated]) {
    [tr nextRoute];}
  else {
    [_authenticator authenticate:tr];}
}
@end

@implementation MSHttpTransaction (MSHttpSessionMiddleware)
- (id)session
{ return [self objectForKey:@"MSHttpSessionMiddleware"]; }
@end

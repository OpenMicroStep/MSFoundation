#import "MSNode_Private.h"

@interface MSHttpSessionMiddleware (Private)
- (void)_removeSession:(MSHttpSession *)session;
@end

@interface MSHttpSession (Private)
- (instancetype)_initWithKey:(id)key withInstigator:(id)m;
@end

@implementation MSHttpSession
+ (NSString *)generateSessionKey
{
  MSBuffer *rnd= MSCreateRandomBuffer(16);
  NSString *ret= MSBytesToHexaString([rnd bytes], [rnd length], NO);
  [rnd release];
  return ret;
}
- (instancetype)_initWithKey:(id)key withInstigator:(id)m
{
  _key= [key retain];
  _instigator= [m retain];
  _uv_timer= (uv_timer_t*)MSMallocFatal(sizeof(uv_timer_t) + sizeof(id), "MSHttpSession uv_timer_t");
  ((uv_timer_t*)_uv_timer)->data= self;
  uv_timer_init(uv_default_loop(), _uv_timer);
  return [self init];
}
// no dealloc because dealloc is only fired if kill is sent, and kill cleanup things
static void _sessionTimeout(uv_timer_t* handle)
{
  [(MSHttpSession *)handle->data kill];
}
static void _sessionTimerClose(uv_handle_t* handle)
{
  MSFree(handle, "MSHttpSession uv_timer_t");
}
- (instancetype)update {
  uv_timer_stop((uv_timer_t*)_uv_timer);
  uv_timer_start((uv_timer_t*)_uv_timer, _sessionTimeout, ((uint64_t)[self lifetime]) * 1000, 0);
  return self;
}
- (BOOL)isAuthenticated    { return NO; }
- (NSTimeInterval)lifetime { return [self isAuthenticated] ? 86400 : 3600; }
- (NSString *)key          { return _key; }
- (void)kill
{ 
  if(_uv_timer) {
    [_instigator _removeSession:self];
    uv_timer_stop((uv_timer_t*)_uv_timer);
    uv_close((uv_handle_t*)_uv_timer, _sessionTimerClose);
    _uv_timer=NULL;
    DESTROY(_key);
    DESTROY(_instigator);
    [self release];
  }
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

- (void)onTransaction:(MSHttpTransaction *)tr next:(id <MSHttpNextMiddleware>)next
{
  NSString *sessionKey; MSHttpSession *session;
  sessionKey= [tr cookieValueForName:_cookieName];
  session= CDictionaryObjectForKey(_sessions, sessionKey);
  printf("Session key:%s\n", [sessionKey UTF8String]);
  if (!session) {
    sessionKey= [_sessionClass generateSessionKey];
    [tr setCookie:[MSHttpCookie cookieWithValue:sessionKey] forName:_cookieName];
    session= [ALLOC(_sessionClass) _initWithKey:sessionKey withInstigator:self];
    CDictionarySetObjectForKey(_sessions, session, sessionKey);}
  session= [session update];
  [tr setObject:session forKey:@"MSHttpSessionMiddleware"];
  if([session isAuthenticated]) {
    [next nextMiddleware];}
  else {
    [_authenticator authenticate:tr next:next];}
}
@end

@implementation MSHttpTransaction (MSHttpSessionMiddleware)
- (id)session
{ return [self objectForKey:@"MSHttpSessionMiddleware"]; }
@end

#import "MSNode_Private.h"

@interface MSHttpRoute : NSObject {
@public
  NSString *_path;
  int _method;
  SEL _sel;
  id _targetOrMiddleware;
}
- (instancetype)initWithPath:(NSString *)p method:(int)method target:(id)t sel:(SEL)s;
@end

@interface MSHttpRouteApplicator : NSObject <MSHttpNextMiddleware> {
  MSHttpRouter *_router;
  MSHttpTransaction *_tr;
  NSString *_path; 
  CString *_route;
  int _method;
  NSUInteger _idx;
}
- (instancetype)initWithRouter:(MSHttpRouter *)router transaction:(MSHttpTransaction*)tr;
@end

@implementation MSHttpRouter
- (instancetype)init {
  if ((self= [super init])) {
    _routes= CCreateArray(0);
  }
  return self;
}
- (void)dealloc
{
  RELEASE(_baseURL);
  RELEASE(_routes);
  [super dealloc];
}

- (NSString *)baseURL
{ return _baseURL; }
- (void)setBaseURL:(NSString *)baseURL
{ ASSIGN(_baseURL, baseURL); }

static inline void _addRoute(CArray *routes, NSString *path, int method, id target, SEL sel) {
  MSHttpRoute *route;
  route= [ALLOC(MSHttpRoute) initWithPath:path method:method target:target sel:sel];
  CArrayAddObject(routes, route);
  [route release];
}
- (void)addRoute:(NSString *)path toRouter:(MSHttpRouter*)router
{ _addRoute(_routes, path, MSHttpMethodALL, router, @selector(route:)); }
- (void)addRouteToMiddleware:(id <MSHttpMiddleware>)middleware
{ _addRoute(_routes, nil ,MSHttpMethodALL, middleware, @selector(onTransaction:next:)); }
- (void)addRoute:(NSString *)path method:(int)method toMiddleware:(id <MSHttpMiddleware>)middleware
{ _addRoute(_routes, path ,method, middleware, @selector(onTransaction:next:)); }
- (void)addRoute:(NSString *)path method:(int)method toTarget:(id)target selector:(SEL)sel
{ _addRoute(_routes, path, method, target, sel); }
- (void)route:(MSHttpTransaction*)tr
{ AUTORELEASE([ALLOC(MSHttpRouteApplicator) initWithRouter:self transaction:tr]); }
- (void)onTransactionLost:(MSHttpTransaction*)tr
{
  [tr write:MSHttpCodeNotFound];
}
- (CArray *)_routes
{ return _routes; }

- (void)onServerListening:(MSHttpServer*)server
{ [server onServerListening:server]; }
- (void)onServer:(MSHttpServer*)server transaction:(MSHttpTransaction *)tr
{ [self route:tr]; }
- (void)onServerClose:(MSHttpServer*)server
{ [server onServerClose:server]; }
- (void)onServer:(MSHttpServer*)server error:(NSString*)err
{ [server onServer:server error:err]; }
- (void)onServer:(MSHttpServer*)server clientError:(NSString*)err
{ [server onServer:server clientError:err]; }
@end

@implementation MSHttpRoute
- (instancetype)initWithPath:(NSString *)p method:(int)method target:(id)t sel:(SEL)s
{
  _path= [p retain];
  _method= method;
  _targetOrMiddleware= [t retain];
  _sel= s;
  return self;
}
- (void)dealloc
{
  [_path release];
  [_targetOrMiddleware release];
  [super dealloc];
}
@end

@implementation MSHttpRouteApplicator
- (instancetype)initWithRouter:(MSHttpRouter *)router transaction:(MSHttpTransaction*)tr
{
  _route= CCreateString(0);
  _path= [[tr urlPath] retain];
  _tr= tr; // self = tr lifetime
  [tr setObject:self forKey:@"MSHttpRouteApplicator"];
  _method= [tr method];
  [self setRouter:router path:[router baseURL] checked:NO];
  if(!_path) {
    [_tr write:MSHttpCodeNotFound];}
  else {
    [self nextMiddleware];}
  //printf("MSHttpRouteApplicator %p init, path=%s\n", self, [_path UTF8String]);
  return self;
}
- (void)dealloc
{
  //printf("MSHttpRouteApplicator %p dealloc\n", self);
  RELEASE(_route);
  RELEASE(_router);
  RELEASE(_path);
  [super dealloc];
}
- (void)setRouter:(MSHttpRouter *)router path:(NSString *)path checked:(BOOL)checked
{ 
  ASSIGN(_router, router);
  if (checked || !path || [self hasPathPrefix:path]) {
    CStringAppendSES(_route, SESFromString(path));
    ASSIGN(_path, [_path substringFromIndex:[path length]]);}
  else {
    DESTROY(_path);}
  _idx= 0; 
}
- (BOOL)hasPathPrefix:(NSString *)prefix
{
  BOOL ret= NO; NSUInteger i;
  SES path= SESFromString(_path);
  SES sesPrefix= SESFromString(prefix);
  SES fd;
  if (SESOK(path) && SESOK(sesPrefix) && SESOK(fd= SESCommonPrefix(path, sesPrefix))) {
    ret= (i= SESEnd(fd)) == SESEnd(path) || SESIndexN(path, &i) == (unichar)'/';}
  return ret;
}
- (void)nextMiddleware
{
  BOOL fd= NO; CArray * routes= [_router _routes];
  while (!fd && _idx < CArrayCount(routes)) {
    MSHttpRoute *route= CArrayObjectAtIndex(routes, _idx++);
    if ((route->_method & _method) > 0 && (!route->_path || [self hasPathPrefix:route->_path])) {
      if (route->_sel) {
        if (route->_sel == @selector(onTransaction:next:)) {
          [route->_targetOrMiddleware performSelector:route->_sel withObject:_tr withObject:self];}
        else {
          [route->_targetOrMiddleware performSelector:route->_sel withObject:_tr];}
        fd= YES;}
      else {
        [self setRouter:route->_targetOrMiddleware path:route->_path checked:YES];
        routes= [_router _routes];}}}
  if (!fd) {
    [_tr write:MSHttpCodeNotFound];}
}

- (NSString *)routeUrl
{ return _path; }
- (NSString *)route
{ return (id)_route; }
- (MSHttpTransaction *)transaction
{ return _tr; }
@end

#import "MSNode_Private.h"

#define MSHttpRouteInfoStackSize 16
typedef struct {
  CArray *routes;
  NSUInteger index;
  NSUInteger length;
} _MSHttpRouteInfoStack;


@interface _MSHttpRouteInfo : NSObject {
  _MSHttpRouteInfoStack _stack[MSHttpRouteInfoStackSize];
  MSString *_url, *_routeUrl;
  NSUInteger _urlPos, _stackCount;
}
- (NSString *)urlAfterRouting;
- (NSString *)urlRouted;
- (void)nextRouteForTransaction:(MSHttpTransaction *)tr;
@end

@implementation MSHttpTransaction (MSNetRouting)
- (NSString *)urlAfterRouting
{
  return [[self objectForKey:@"_MSHttpRouteInfo"] urlAfterRouting];
}
- (NSString *)urlRouted
{
  return [[self objectForKey:@"_MSHttpRouteInfo"] urlRouted];
}
- (void)nextRoute
{
  [[self objectForKey:@"_MSHttpRouteInfo"] nextRouteForTransaction:self];
}
@end

@implementation _MSHttpRouteInfo
+ (void)routeTransaction:(MSHttpTransaction *)tr withRootRoute:(MSHttpRoute *)route
{
  [ALLOC(self) initWithTransaction:tr withRootRoute:route];
}
- (instancetype)initWithTransaction:(MSHttpTransaction *)tr withRootRoute:(MSHttpRoute *)route
{
  SES urlPath; CString *path; NSUInteger i, e; unichar u;
  urlPath= SESFromString([tr urlPath]);
  path= CCreateString(SESLength(urlPath));
  // fast removal of ./ and //
  for (i= SESStart(urlPath), e= SESEnd(urlPath); i < e;) {
    u= SESIndexN(urlPath, &i);
    if (u == '/') {
      CStringAppendCharacter(path, u);
      while (i < e && (u= SESIndexN(urlPath, &i)) == '/') {}
    }
    if (u == '.') {
      if (i == e || (u= SESIndexN(urlPath, &i)) != '/') {
        CStringAppendCharacter(path, '.');
        CStringAppendCharacter(path, u);
      }
    }
    else {
      CStringAppendCharacter(path, u);
    }
  }
  _url= (id)path;
  _routeUrl= RETAIN(_url);
  [tr setObject:self forKey:@"_MSHttpRouteInfo"];
  if (![self tryWithRoute:route forTransaction:tr])
   [tr write:MSHttpCodeNotFound];
  RELEASE(self);
  return nil;
}
- (void)dealloc
{
  while (_stackCount > 0) {
    RELEASE(_stack[--_stackCount].routes);
  }
  RELEASE(_url);
  RELEASE(_routeUrl);
  [super dealloc];
}

- (NSString *)urlAfterRouting
{
  return _routeUrl;
}
- (NSString *)urlRouted
{
  return [_url substringToIndex:_urlPos];
}

- (BOOL)tryWithRoute:(MSHttpRoute *)route forTransaction:(MSHttpTransaction *)tr
{
  BOOL ret; NSUInteger length;

  if ((ret= (length= [route tryWithPath:_routeUrl forTransaction:tr]) != NSNotFound)) {
    // Route matched, pushing it to the stack
    _stack[_stackCount].length= length;
    _stack[_stackCount].index= 0;
    _stack[_stackCount].routes= (CArray*)RETAIN([route routes]);
    ++_stackCount;

    if (length > 0) {
      _urlPos+= length;
      ASSIGN(_routeUrl, [_url substringFromIndex:_urlPos]);
    }
    //NSLog(@"push '%@'%@' to %@", [self urlRouted], [self urlAfterRouting], route);
    [route applyWithTransaction:tr];
  }
  return ret;
}

- (void)nextRouteForTransaction:(MSHttpTransaction *)tr
{
  NSUInteger idx, len; MSHttpRoute *route; BOOL found= NO;

  while(!found && _stackCount > 0) {
    idx= _stackCount - 1;
    len= CArrayCount(_stack[idx].routes);
    while (!found && _stack[idx].index < len) {
      route= CArrayObjectAtIndex(_stack[idx].routes, _stack[idx].index++);
      found= [self tryWithRoute:route forTransaction:tr];
      //NSLog(@"try  '%@'%@' to %@ -> %d", [self urlRouted], [self urlAfterRouting], route, (int)found);
    }
    if (!found) {
      RELEASE(_stack[idx].routes);
      _urlPos -= _stack[idx].length;
      ASSIGN(_routeUrl, [_url substringFromIndex:_urlPos]);
      --_stackCount;
      //NSLog(@"pop  '%@'%@'", [self urlRouted], [self urlAfterRouting]);
    }
  }

  if (!found)
   [tr write:MSHttpCodeNotFound];
}

@end

@implementation MSHttpRoute
- (instancetype)initWithPath:(NSString *)path method:(int)method
{
  if ((self= [self init])) {
    if (path) {
      SES ses;
      ses= SESFromString(path);
      if (SESOK(ses)) {
        NSUInteger s= SESStart(ses), e= SESEnd(ses);
        unichar first= SESIndexN(ses, &s);
        if (first != '/' || s < e) {
          _path= CCreateString(SESLength(ses));
          if (first != '/')
            CStringAppendCharacter(_path, '/');
          CStringAppendSES(_path, ses);
        }
      }
    }
    _method= method;
    _routes= CCreateArray(0);
  }
  return self;
}
- (instancetype)initWithPath:(NSString *)path method:(int)method target:(id)target selector:(SEL)sel
{
  if ((self= [self initWithPath:path method:method])) {
    _sel= sel;
    _target= [target retain];
  }
  return self;
}
- (instancetype)initWithPath:(NSString *)path method:(int)method middleware:(id <MSHttpMiddleware>)middleware
{
  return [self initWithPath:path method:method target:middleware selector:@selector(onTransaction:)];
}
- (void)dealloc
{
  RELEASE(_routes);
  RELEASE(_path);
  RELEASE(_target);
  [super dealloc];
}

- (NSString *)description
{
  return FMT(@"{path=%@, target=[%@ %@]}", _path, NSStringFromClass([_target class]), NSStringFromSelector(_sel));
}

- (MSArray *)routes
{
  return (id)_routes;
}
- (void)insertRoute:(MSHttpRoute *)route at:(NSUInteger)idx
{
  CArrayInsertObjectAtIndex(_routes, route, idx);
}

- (void)addRoute:(MSHttpRoute *)route
{
  CArrayAddObject(_routes, route);
}

- (void)addRouteToMiddleware:(id <MSHttpMiddleware>)middleware
{
  MSHttpRoute *route;
  route= [ALLOC(MSHttpRoute) initWithPath:nil method:MSHttpMethodALL middleware:middleware];
  [self addRoute:route];
  RELEASE(route);
}
- (void)addRoute:(NSString *)path method:(int)method toMiddleware:(id <MSHttpMiddleware>)middleware
{
  MSHttpRoute *route;
  route= [ALLOC(MSHttpRoute) initWithPath:path method:method middleware:middleware];
  [self addRoute:route];
  RELEASE(route);
}
- (void)addRoute:(NSString *)path method:(int)method toTarget:(id)target selector:(SEL)sel
{
  MSHttpRoute *route;
  route= [ALLOC(MSHttpRoute) initWithPath:path method:method target:target selector:sel];
  [self addRoute:route];
  RELEASE(route);
}

- (BOOL)isPathPrefixOf:(NSString *)urlPath
{
  BOOL ret= CStringLength(_path) == 0;
  if (!ret) {
    NSUInteger i;
    SES sesPrefix= CStringSES(_path);
    SES sesPath= SESFromString(urlPath);
    SES fd;
    ret = SESOK(fd= SESCommonPrefix(sesPath, sesPrefix));
    ret= ret && ( (i= SESEnd(fd)) == SESEnd(sesPath) || SESIndexN(sesPath, &i) == (unichar)'/' );
  }
  //NSLog(@"%@ [%@ isPathPrefixOf:%@] -> %@", _target, _path, urlPath, ret ? @"true": @"false");
  return ret;
}

- (void)startRoutingTransaction:(MSHttpTransaction *)tr
{
  [_MSHttpRouteInfo routeTransaction:tr withRootRoute:self];
}
- (void)applyWithTransaction:(MSHttpTransaction *)tr
{
  if (_sel && _target) {
    //NSLog(@"applyWithTransaction %@ [%@ %s]", [tr urlAfterRouting], _target, sel_getName(_sel));
    [_target performSelector:_sel withObject:tr];
  }
  else {
    [tr nextRoute];
  }
}

- (NSUInteger)tryWithPath:(MSString *)path forTransaction:(MSHttpTransaction *)tr
{
  NSUInteger ret= NSNotFound;
  if (([tr method] & _method) > 0 && [self isPathPrefixOf:path]) {
    ret= CStringLength(_path);
  }
  //NSLog(@"%@ %d & %d [%@ tryWithPath:%@] -> %d", _target, (int)[tr method], (int)_method, _path, path, ret != NSNotFound ? (int)ret: (int)-1);
  return ret;
}

- (void)onServerListening:(MSHttpServer*)server
{ [server onServerListening:server]; }
- (void)onServer:(MSHttpServer*)server transaction:(MSHttpTransaction *)tr
{ [self startRoutingTransaction:tr]; }
- (void)onServerClose:(MSHttpServer*)server
{ [server onServerClose:server]; }
- (void)onServer:(MSHttpServer*)server error:(NSString*)err
{ [server onServer:server error:err]; }
- (void)onServer:(MSHttpServer*)server clientError:(NSString*)err
{ [server onServer:server clientError:err]; }

@end






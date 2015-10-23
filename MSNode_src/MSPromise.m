#import "MSNode_Private.h"

typedef struct {
  char type;
  MSPromise *promise;
} MSPromiseHandlerReserved;

enum MSPromiseUnionType {
  MSPromiseUnionFirst = 0,
  MSPromiseUnionAllInstant = 1,
  MSPromiseUnionAllWait = 2,
  MSPromiseUnionAllWaitRejected = 3,
};

@interface _MSPromiseUnion : MSPromise {
  int _barrier;
  enum MSPromiseUnionType _type;
}
- (instancetype)initWithPromises:(NSArray *)promises type:(enum MSPromiseUnionType)type;
- (void)addPromise:(MSPromise *)promise;
- (void)promiseFullfilled:(MSPromise *)promise result:(id)result;
- (void)promiseRejected:(MSPromise *)promise reason:(id)reason;
@end

@implementation MSPromise
static inline void _fireHandler(MSPromise *self, MSHandler *h, MSPromiseState state, id value) {
  MSPromiseHandlerReserved *res;
  res= (MSPromiseHandlerReserved *)MSHandlerReserved(h);
  if (res->type == MSPromiseFulfilled) {
    if (state == MSPromiseFulfilled) {
      ((MSPromiseSuccessHandler)h->fn)(self, res->promise, value, MSHandlerArgs(h, sizeof(MSPromiseHandlerReserved)));
      [res->promise release]; }
    else if(state == MSPromiseRejected) {
      [res->promise reject:value];
      [res->promise release]; }
    }
  else if (res->type == MSPromiseRejected && state == MSPromiseRejected) {
    ((MSPromiseRejectHandler)h->fn)(self, value, MSHandlerArgs(h, sizeof(MSPromiseHandlerReserved))); }
}
static inline MSPromise *_makeHandler(MSHandler *h, MSPromise *p, MSPromiseState type)
{
  MSPromiseHandlerReserved *res;
  res= (MSPromiseHandlerReserved *)MSHandlerReserved(h);
  res->type= type;
  res->promise= [p retain];
  return p;
}
+ (MSPromise *)promise
{
  return AUTORELEASE([ALLOC(MSPromise) init]);
}
+ (MSPromise *)promiseWithAllResolvedOf:(NSArray *)promises waitForAll:(BOOL)waitForAll
{
  return AUTORELEASE([ALLOC(_MSPromiseUnion) initWithPromises:promises type:waitForAll ? MSPromiseUnionAllWait : MSPromiseUnionAllInstant]);
}
+ (MSPromise *)promiseWithFirstResultOf:(NSArray *)promises
{
  return AUTORELEASE([ALLOC(_MSPromiseUnion) initWithPromises:promises type:MSPromiseUnionFirst]);
}
- (void)dealloc
{
  MSHandlerListFreeInside(&_listeners);
  RELEASE(_res);
  [super dealloc];
}
- (MSPromise *)chainableThen:(MSPromiseSuccessHandler)handler args:(int)argc, ...
{
  MSHandler*h; MSPromise *p;
  h= MSHandlerListAddEx(&_listeners, handler, sizeof(MSPromiseHandlerReserved), argc, argc);
  p= _makeHandler(h, [MSPromise promise], MSPromiseFulfilled);
  _fireHandler(self, h, [self state], _res);
  return p;
}
- (void)then:(MSPromiseSuccessHandler)handler args:(int)argc, ...
{
  MSHandler *h;
  h= MSHandlerListAddEx(&_listeners, handler, sizeof(MSPromiseHandlerReserved), argc, argc);
  _makeHandler(h, nil, MSPromiseFulfilled);
  _fireHandler(self, h, [self state], _res);
}
- (void)catch:(MSPromiseRejectHandler)handler args:(int)argc, ...
{
  MSHandler *h;
  h= MSHandlerListAddEx(&_listeners, handler, sizeof(MSPromiseHandlerReserved), argc, argc);
  _makeHandler(h, nil, MSPromiseRejected);
  _fireHandler(self, h, [self state], _res);
}

- (BOOL)isFulfilled { return _state == MSPromiseFulfilled; }
- (BOOL)isRejected  { return _state == MSPromiseRejected; }
- (BOOL)isPending   { return _state == MSPromisePending; }
- (MSPromiseState)state { return _state; }

- (void)resolve:(id)result
{
  MSHandlerListEnumerator e; MSHandler *h;
  if (_state == MSPromisePending) {
    ASSIGN(_res, result);
    _state= MSPromiseFulfilled;
    e= MSMakeHandlerEnumerator(&_listeners);
    while ((h= MSHandlerEnumeratorNext(&e))) {
      _fireHandler(self, h, MSPromiseFulfilled, result);}}
}

- (void)reject:(id)reason
{
  MSHandlerListEnumerator e; MSHandler *h;
  if (_state == MSPromisePending) {
    ASSIGN(_res, reason);
    _state= MSPromiseRejected;
    e= MSMakeHandlerEnumerator(&_listeners);
    while ((h= MSHandlerEnumeratorNext(&e))) {
      _fireHandler(self, h, MSPromiseRejected, reason);}}
}
static void _forwardSuccessHandler(MSPromise *instigator, MSPromise *next, id result, MSHandlerArg *args)
{
  [args[0].id resolve:result];
  [args[0].id release];
}
static void _forwardRejectHandler(MSPromise *instigator, id reason, MSHandlerArg *args)
{
  [args[0].id reject:reason];
  [args[0].id release];
}
- (void)resolveWithPromise:(MSPromise *)result
{
  [self retain];
  [result then:_forwardSuccessHandler args:1, MSMakeHandlerArg(self)];
  [result catch:_forwardRejectHandler args:1, MSMakeHandlerArg(self)];
}
@end

@implementation _MSPromiseUnion
- (instancetype)initWithPromises:(NSArray *)promises type:(enum MSPromiseUnionType)type
{
  NSEnumerator *e; MSPromise *p;
  if ((self= [self init])) {
    _type= type;
    if (type == MSPromiseUnionAllInstant || type == MSPromiseUnionAllWait) {
      _res= [MSArray new];}
    for(e= [promises objectEnumerator]; p= [e nextObject];) {
      [self addPromise:p];}}
  return self;
}
static void _unionSuccessHandler(MSPromise *instigator, MSPromise *next, id result, MSHandlerArg *args)
{
  _MSPromiseUnion *self= args[0].id;
  if ([self isPending])
    [self promiseFullfilled:instigator result:result];
  [self release];
}
static void _unionRejectHandler(MSPromise *instigator, id reason, MSHandlerArg *args)
{
  _MSPromiseUnion *self= args[0].id;
  if ([self isPending])
    [self promiseRejected:instigator reason:reason];
  [self release];
}
- (void)addPromise:(MSPromise *)promise
{
  ++_barrier;
  [self retain];
  [promise then:_unionSuccessHandler args:1, MSMakeHandlerArg(self)];
  [promise catch:_unionRejectHandler args:1, MSMakeHandlerArg(self)];
}
- (void)promiseFullfilled:(MSPromise *)promise result:(id)result
{
  if (_type == MSPromiseUnionFirst) {
    [self resolve:result];}
  else {
    if (!result) {
      result= MSNull;}
    if (_type != MSPromiseUnionAllWaitRejected) {
      [(MSArray *)_res addObject:result]; }
    if (--_barrier == 0) {
      if (_type == MSPromiseUnionAllWaitRejected) {
        [self reject:_res];}
      else {
        [self resolve:_res];}}}
}
- (void)promiseRejected:(MSPromise *)promise reason:(id)reason
{
  if (_type < MSPromiseUnionAllWait) {
    [self reject:reason];}
  else {
    if (_type == MSPromiseUnionAllWait) {
      ASSIGN(_res, reason);
      _type= MSPromiseUnionAllWaitRejected;}
    if (--_barrier == 0) {
      [self reject:_res];}}
}
@end

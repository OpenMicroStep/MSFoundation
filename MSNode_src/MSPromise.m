#import "MSNode_Private.h"

typedef struct {
  char type;
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
- (void)promiseFullfilled:(id)result;
- (void)promiseRejected:(id)reason;
@end

@implementation MSPromise

+ (MSPromise *)promise
{
  return AUTORELEASE([ALLOC(MSPromise) init]);
}

+ (MSPromise *)promiseResolved:(id)result
{
  MSPromise *p= AUTORELEASE([ALLOC(MSPromise) init]);
  [p resolve:result];
  return p;
}
+ (MSPromise *)promiseRejected:(id)reason
{
  MSPromise *p= AUTORELEASE([ALLOC(MSPromise) init]);
  [p reject:reason];
  return p;
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
- (MSPromise *)then:(MSPromiseSuccessHandler)handler args:(int)argc, ...
{
  va_list ap;
  va_start(ap, argc);
  self= [self _addHandler:handler argc:argc args:ap type:MSPromiseFulfilled];
  va_end(ap);
  return self;
}
- (MSPromise *)catch:(MSPromiseRejectHandler)handler args:(int)argc, ...
{
  va_list ap;
  va_start(ap, argc);
  self= [self _addHandler:handler argc:argc args:ap type:MSPromiseRejected];
  va_end(ap);
  return self;
}
- (void)finally:(MSPromiseFinallyHandler)handler args:(int)argc, ...
{
  va_list ap;
  va_start(ap, argc);
  [self _addHandler:handler argc:argc args:ap type:MSPromisePending];
  va_end(ap);
}
static void _finallyReleaseObject(MSHandlerArg *args)
{
  [args[0].id release];
}
static void _finallyRelease2Object(MSHandlerArg *args)
{
  [args[0].id release];
  [args[1].id release];
}
static MSPromise* _forwardToObject(id r, MSHandlerArg *args)
{
  return [args[0].id performSelector:args[1].sel withObject:r withObject:args[2].id];
}
- (MSPromise *)catch:(id)target action:(SEL)sel context:(id)object
{
  MSHandlerArg t, s, o; MSPromise *r;
  t.id= [target retain];
  s.sel= sel;
  o.id= [object retain];
  r= [self catch:_forwardToObject args:3, t, s, o];
  [self finally:_finallyRelease2Object args:2, t, o];
  return r;
}
- (MSPromise *)then:(id)target action:(SEL)sel context:(id)object
{
  MSHandlerArg t, s, o; MSPromise *r;
  t.id= [target retain];
  s.sel= sel;
  o.id= [object retain];
  r= [self then:_forwardToObject args:3, t, s, o];
  [self finally:_finallyRelease2Object args:2, t, o];
  return r;
}
- (void)keepObjectAlive:(id)object
{
  [self finally:_finallyReleaseObject args:1, MSMakeHandlerArg([object retain])];
}

- (BOOL)isFulfilled { return _state == MSPromiseFulfilled; }
- (BOOL)isRejected  { return _state == MSPromiseRejected; }
- (BOOL)isPending   { return _state == MSPromisePending; }
- (MSPromiseState)state { return _state; }

static inline void _fireHandlers(MSPromise *self, MSHandlerList *listeners, MSPromiseState state, id value) {
  MSPromise *r= nil; MSHandlerListEnumerator e; MSHandler *h, *l; BOOL c= YES;
  e= MSMakeHandlerEnumerator(listeners);
  while (c && (h= MSHandlerEnumeratorNext(&e))) {
    r= _fireHandler(self, h, state, value);
    if (r && r != self) {
      h= h->next;
      if (h->next != (MSHandler*)listeners) { // h is not the last handler
        l= listeners->last;
        MSHandlerDetach(h, l, NO);
        [r _attach:h :l];
      }
      c= NO;
    }
  }
  MSHandlerDetach(listeners->first, listeners->last, YES);
}
static inline MSPromise* _fireHandler(MSPromise *self, MSHandler *h, MSPromiseState state, id value) {
  MSPromiseHandlerReserved *res;
  res= (MSPromiseHandlerReserved *)MSHandlerReserved(h);
  if (res->type == MSPromiseFulfilled && state == MSPromiseFulfilled) {
    self= ((MSPromiseSuccessHandler)h->fn)(value, MSHandlerArgs(h, sizeof(MSPromiseHandlerReserved)));}
  else if (res->type == MSPromiseRejected && state == MSPromiseRejected) {
    self= ((MSPromiseRejectHandler)h->fn)(value, MSHandlerArgs(h, sizeof(MSPromiseHandlerReserved))); }
  else if (res->type == MSPromisePending && state != MSPromisePending) {
    ((MSPromiseFinallyHandler)h->fn)(MSHandlerArgs(h, sizeof(MSPromiseHandlerReserved))); }
  return self;
}

- (MSPromise *)_addHandler:(void *)handler argc:(int)argc args:(va_list)ap type:(MSPromiseState)type
{
  MSPromiseState state= [self state];
  if (state == MSPromisePending) {
    MSHandler *h; char *typep;
    h= MSCreateHandlerWithArguments(handler, sizeof(char), argc, ap);
    MSHandlerAttach((MSHandler*)&_listeners, h, h);
    typep= (char *)MSHandlerReserved(h);
    *typep= type;
  }
  else if (state == type) {
    MSHandlerArg args[argc];
    MSHandlerFillArguments(args, argc, ap);
    self= ((MSPromiseSuccessHandler)handler)(_res, args);
  }
  else if (type == MSPromisePending) {
    MSHandlerArg args[argc];
    MSHandlerFillArguments(args, argc, ap);
    ((MSPromiseFinallyHandler)handler)(args);
  }
  return self;
}
- (void)resolve:(id)result
{
  if (_state == MSPromisePending) {
    ASSIGN(_res, result);
    _state= MSPromiseFulfilled;
    _fireHandlers(self, &_listeners, MSPromiseFulfilled, result);}
}

- (void)reject:(id)reason
{
  if (_state == MSPromisePending) {
    ASSIGN(_res, reason);
    _state= MSPromiseRejected;
    _fireHandlers(self, &_listeners, MSPromiseRejected, reason);}
}
- (void)_attach:(MSHandler *)first :(MSHandler *)last
{
  MSPromiseState state;
  MSHandlerAttach((MSHandler*)&_listeners, first, last);
  state= [self state];
  if (state != MSPromisePending) {
    _fireHandlers(self, &_listeners, state, _res);}
}

static MSPromise *_forwardSuccessHandler(id result, MSHandlerArg *args)
{
  [args[0].id resolve:result];
  [args[0].id release];
  return nil;
}
static MSPromise *_forwardRejectHandler(id reason, MSHandlerArg *args)
{
  [args[0].id reject:reason];
  [args[0].id release];
  return nil;
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
static MSPromise* _unionSuccessHandler(id result, MSHandlerArg *args)
{
  _MSPromiseUnion *self= args[0].id;
  if ([self isPending])
    [self promiseFullfilled:result];
  [self release];
  return nil;
}
static MSPromise* _unionRejectHandler(id reason, MSHandlerArg *args)
{
  _MSPromiseUnion *self= args[0].id;
  if ([self isPending])
    [self promiseRejected:reason];
  [self release];
  return nil;
}
- (void)addPromise:(MSPromise *)promise
{
  ++_barrier;
  [self retain];
  [promise then:_unionSuccessHandler args:1, MSMakeHandlerArg(self)];
  [promise catch:_unionRejectHandler args:1, MSMakeHandlerArg(self)];
}
- (void)promiseFullfilled:(id)result
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
- (void)promiseRejected:(id)reason
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

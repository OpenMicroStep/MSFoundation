#import "MSFoundation_Private.h"

@interface MSAsyncFlux : MSAsync {
  MSAsyncElement *_then;
  MSByte _stack;
  MSAsyncState _state;
}
+ (instancetype)runFluxWithContext:(mutable MSDictionary *)context elements:(CArray *)elements then:(MSAsyncElement *)then;
@end

@interface MSAsync (Private)
- (void)_run:(mutable MSDictionary *)context then:(MSAsyncElement *)element;
@end

@interface _MSAsyncElementAction : MSAsyncElement {
@public
  union {
    struct {
        MSAsyncAction a;
    } action; // 0
    struct {
      MSAsyncSuperAction a;
      id o;
    } superAction; // 1
    struct {
      id t;
      SEL s; // 2
      id o;  // 3
    } targetAction;
    struct {
      MSAsyncCondition c;
      id e;
    } _while; // 4
    struct {
      MSAsyncCondition c;
      id t;
      id e;
    } _if; // 5
  } _u;
  MSByte _type;
}
@end
@implementation _MSAsyncElementAction
- (void)dealloc {
  switch(_type) {
  case 1: RELEASE(_u.superAction.o); break;
  case 2: RELEASE(_u.targetAction.t); break;
  case 3: RELEASE(_u.targetAction.t); RELEASE(_u.targetAction.o); break;
  case 4: RELEASE(_u._while.e); break;
  case 5: RELEASE(_u._if.t); RELEASE(_u._if.e); break;
  }
  [super dealloc];
}
- (void)action:(MSAsync *)flux
{
  switch(_type) {
  case 0: _u.action.a(flux); break;
  case 1: _u.superAction.a(flux, _u.superAction.o); break;
  case 2: {
    IMP imp= objc_msg_lookup(_u.targetAction.t, _u.targetAction.s);
    ((void(*)(id,SEL,id))imp)(_u.targetAction.t, _u.targetAction.s, flux);
    break;}
  case 3: {
    IMP imp= objc_msg_lookup(_u.targetAction.t, _u.targetAction.s);
    ((void(*)(id,SEL,id, id))imp)(_u.targetAction.t, _u.targetAction.s, flux, _u.targetAction.o);
    break;}
  case 4: {
    if (_u._while.c(flux)) {
      [flux setFirstElements:self];
      [flux setFirstElements:_u._while.e];}
    [flux continue];
    break;}
  case 5: {
    if (_u._if.c(flux))
      [flux setFirstElements:_u._if.t];
    else
      [flux setFirstElements:_u._if.e];
    [flux continue];
    break;}
  }
}
@end

@interface _MSAsyncElementParallelBarrier : MSAsyncElement {
@public
  MSAsync *_flux;
  NSUInteger _barrier;
}
@end
@implementation _MSAsyncElementParallelBarrier
- (void)action:(MSAsync *)flux
{
  if (--_barrier == 0)
    [_flux continue];
}
- (void)dealloc {
  RELEASE(_flux);
  [super dealloc];
}
@end

@interface _MSAsyncElementParallel : MSAsyncElement {
@public
  NSArray *_elements;
  NSArray *_contexts;
}
@end
@implementation _MSAsyncElementParallel
- (void)dealloc {
  RELEASE(_elements);
  RELEASE(_contexts);
  [super dealloc];
}
- (void)action:(MSAsync *)flux
{
  NSUInteger i, count, ctxcount; MSAsync *p, *t; mutable MSDictionary *c, *def;
  _MSAsyncElementParallelBarrier *barrier;
  count= [_elements count];
  ctxcount= [_contexts count];
  barrier= [_MSAsyncElementParallelBarrier new];
  barrier->_flux= [flux retain];
  barrier->_barrier= count + 1;
  def= ctxcount != count ? [flux context] : nil;
  for (i= 0; i < count; ++i) {
    p= [_elements objectAtIndex:i];
    c= i < ctxcount ? [_contexts objectAtIndex:i] : def;
    if ([p isKindOfClass:[MSAsync class]]) {
      [p _run:c then:barrier];}
    else {
      t= [MSAsyncFlux runFluxWithContext:c elements:NULL then:barrier];
      [t setFirstElements:p];
      [t continue];}}
  [barrier action:nil];
  [barrier release];
}
@end

@interface _MSAsyncElementOnce : MSAsyncElement {
@public
  id _elements;
  id _context;
  id _tokey;
  CArray *_obs;
  BOOL _done;
}
@end
@implementation _MSAsyncElementOnce
- (void)dealloc {
  RELEASE(_elements);
  RELEASE(_context);
  RELEASE(_tokey);
  RELEASE(_obs);
  [super dealloc];
}
static void _MSAsyncElementOnce_Then(MSAsync *p, _MSAsyncElementOnce *self)
{
  CArray *obs= self->_obs;
  self->_obs= NULL;
  self->_done= YES;
  for (NSUInteger i= 0, count= CArrayCount(obs); i < count; i++) {
    MSAsync *f= (MSAsync*)CArrayObjectAtIndex(obs, i);
    if (self->_tokey)
      CDictionarySetObjectForKey((CDictionary *)[f context], self->_context, self->_tokey);
    [f continue];}
  RELEASE(obs);
}
- (void)action:(MSAsync *)flux
{
  MSAsync *t; MSAsyncElement *then;
  if (_done) {
    if (_tokey)
      CDictionarySetObjectForKey((CDictionary *)[flux context], _context, _tokey);
    [flux continue];}
  else if (!_obs) {
    _obs= CCreateArray(0);
    CArrayAddObject(_obs, flux);
    if (!_context)
      _context= (id)CCreateDictionary(0);
    then= [MSAsyncElement asyncSuperAction:_MSAsyncElementOnce_Then withObject:self];
    t= [MSAsyncFlux runFluxWithContext:_context elements:NULL then:then];
    [t setFirstElements:_elements];
    [t continue];}
  else {
    CArrayAddObject(_obs, flux);}
}
@end

@implementation MSAsyncElement
- (void)action:(MSAsync *)flux
{ [self notImplemented:_cmd]; }
@end

@implementation MSAsyncElement (CreateAsyncElements)
+ (MSAsyncElement *)asyncAction:(MSAsyncAction)action
{
  _MSAsyncElementAction* ret= [[_MSAsyncElementAction new] autorelease];
  ret->_u.action.a= action;
  ret->_type= 0;
  return ret;
}
+ (MSAsyncElement *)asyncSuperAction:(MSAsyncSuperAction)superAction withObject:(id)object
{
  _MSAsyncElementAction* ret= [[_MSAsyncElementAction new] autorelease];
  ret->_u.superAction.a= superAction;
  ret->_u.superAction.o= [object retain];
  ret->_type= 1;
  return ret;
}
+ (MSAsyncElement *)asyncTarget:(id)target action:(SEL)action
{
  _MSAsyncElementAction* ret= [[_MSAsyncElementAction new] autorelease];
  ret->_u.targetAction.t= [target retain];
  ret->_u.targetAction.s= action;
  ret->_type= 2;
  return ret;
}
+ (MSAsyncElement *)asyncTarget:(id)target action:(SEL)action withObject:(id)object
{
  _MSAsyncElementAction* ret= [[_MSAsyncElementAction new] autorelease];
  ret->_u.targetAction.t= [target retain];
  ret->_u.targetAction.s= action;
  ret->_u.targetAction.o= [object retain];
  ret->_type= 3;
  return ret;
}
+ (MSAsyncElement *)asyncWhile:(MSAsyncCondition)condition do:(id)elements
{
  _MSAsyncElementAction* ret= [[_MSAsyncElementAction new] autorelease];
  ret->_u._while.c= condition;
  ret->_u._while.e= [elements retain];
  ret->_type= 4;
  return ret;
}
+ (MSAsyncElement *)asyncIf:(MSAsyncCondition)condition then:(id)thenElements
{
  return [self asyncIf:condition then:thenElements else:nil];
}
+ (MSAsyncElement *)asyncIf:(MSAsyncCondition)condition then:(id)thenElements else:(id)elseElements
{
  _MSAsyncElementAction* ret= [[_MSAsyncElementAction new] autorelease];
  ret->_u._if.c= condition;
  ret->_u._if.t= [thenElements retain];
  ret->_u._if.e= [elseElements retain];
  ret->_type= 5;
  return ret;
}
+ (MSAsyncElement *)asyncWithParallelElements:(NSArray *)elements
{
  return [self asyncWithParallelElements:elements contexts:nil];
}
+ (MSAsyncElement *)asyncWithParallelElements:(NSArray *)elements contexts:(NSArray *)contexts
{
  _MSAsyncElementParallel* ret= [[_MSAsyncElementParallel new] autorelease];
  ret->_elements= [elements retain];
  ret->_contexts= [contexts retain];
  return ret;
}
+ (MSAsyncElement *)asyncOnce:(id)elements context:(mutable MSDictionary *)context
{
  return [self asyncOnce:elements context:context forKey:nil];
}

+ (MSAsyncElement *)asyncOnce:(id)elements context:(mutable MSDictionary *)context forKey:(id)key
{
  _MSAsyncElementOnce* ret= [[_MSAsyncElementOnce new] autorelease];
  ret->_elements= [elements retain];
  ret->_context= [context retain];
  ret->_tokey= [key retain];
  return ret;
}
@end

@implementation MSAsync {
@protected
 CArray *_elements;
 CDictionary *_context;
}

static MSAsyncElement* __callContinue;
static void _callContinue(MSAsync *flux) {
  [flux continue];
}
+ (void)initialize
{
  if (self==[MSAsync class]) {
    __callContinue= [MSAsyncElement asyncAction:_callContinue];}
}

+ (instancetype)runWithContext:(mutable MSDictionary *)context elements:(NSArray *)elements;
{
  MSAsync *flux;
  flux= [MSAsyncFlux runFluxWithContext:context elements:NULL then:nil];
  [flux setFirstElements:elements];
  [flux continue];
  return flux;
}

+ (instancetype)async
{
  return AUTORELEASE([ALLOC(self) init]);
}
- (instancetype)init
{
  return [self initWithContext:nil elements:nil];
}

+ (instancetype)asyncWithContext:(mutable MSDictionary *)context elements:(id)elements
{
  return AUTORELEASE([ALLOC(self) initWithContext:context elements:elements]);
}
- (instancetype)initWithContext:(mutable MSDictionary *)context elements:(id)elements {
  if ((self= [self _initWithContext:context elements:NULL]))
    if (elements)
      [self setFirstElements:elements];
  return self;
}

- (instancetype)_initWithContext:(mutable MSDictionary *)context elements:(CArray *)elements {
  if ((self= [super init])) {
    _context= context ? (CDictionary *)[context retain] : CCreateDictionary(0);
    _elements= elements ? (CArray *)CArrayCopy((id)elements) : CCreateArray(0);
  }
  return self;
}
- (void)dealloc
{
  RELEASE(_context);
  RELEASE(_elements);
  [super dealloc];
}

- (mutable MSDictionary*)context
{
  return (mutable MSDictionary *)_context;
}

- (MSAsyncState)state
{
  return MSAsyncDefining;
}

- (void)setFirstElements:(id)elements
{
  if ([elements isKindOfClass:[NSArray class]]) {
    NSUInteger count= [elements count];
    while (count > 0) {
      id element= [elements objectAtIndex:--count];
      if ([element isKindOfClass:[NSArray class]])
        CArrayAddObject(_elements, [MSAsync asyncWithParallelElements:element]);
      else if ([element isKindOfClass:[MSAsyncElement class]]) {
        CArrayAddObject(_elements, element);}
    }}
  else if ([elements isKindOfClass:[MSAsyncElement class]]) {
    CArrayAddObject(_elements, elements);}
}

- (void)action:(MSAsync *)flux
{
  [[MSAsyncFlux runFluxWithContext:(id)_context elements:_elements then:__callContinue] continue];
}
- (void)_run:(mutable MSDictionary *)context then:(MSAsyncElement *)element
{
  [[MSAsyncFlux runFluxWithContext:context elements:_elements then:element] continue];
}
- (void)continue
{
  [[MSAsyncFlux runFluxWithContext:(id)_context elements:_elements then:nil] continue];
}

@end

@implementation MSAsyncFlux
+ (instancetype)runFluxWithContext:(mutable MSDictionary *)context elements:(CArray *)elements then:(MSAsyncElement *)then
{
  MSAsyncFlux *s= [ALLOC(MSAsyncFlux) _initWithContext:context elements:elements];
  s->_then= RETAIN(then);
  s->_stack= 0;
  s->_state= MSAsyncStarted;
  return AUTORELEASE(s);
}
- (void)dealloc
{
  RELEASE(_then);
  [super dealloc];
}
- (MSAsyncState)state
{
  return _state;
}

- (void)continue
{
  if (_stack == 1) {
    _stack= 2;
    return;}

  do {
      _stack= 1;
      // On reste finishing dès qu'on a touché la dernière action, même si celle-ci rajoute des actions au pool.
      if ((_state == MSAsyncStarted || _state == MSAsyncFinishing) && CArrayCount(_elements) > 0) {
        MSAsyncElement *element= RETAIN(CArrayLastObject(_elements));
        CArrayRemoveLastObject(_elements);
        if (CArrayCount(_elements) == 0) _state= MSAsyncFinishing;
        RETAIN(self);
        [element action:self];
        RELEASE(self);
        RELEASE(element);}
      else if (_state != MSAsyncAborted || _state != MSAsyncTerminated) {
        if (_state != MSAsyncAborted)
          _state= MSAsyncTerminated;
        [_then action:self];}
    } while (_stack == 2);
    _stack= 0;
}

@end

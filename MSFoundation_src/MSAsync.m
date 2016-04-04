#import "MSFoundation_Private.h"

@interface MSAsyncFlux : MSAsync {
  MSAsyncElement *_then;
  MSByte _stack;
  MSAsyncState _state;
}
+ (instancetype)runFluxWithContext:(CDictionary *)context elements:(CArray *)elements then:(MSAsyncElement *)then;
@end

@interface MSAsync (Private)
- (void)_run:(mutable MSDictionary *)context then:(MSAsyncElement *)element;
@end

@interface _MSAsyncElementAction : MSAsyncElement {
@public
  MSAsyncAction _action;
}
@end
@implementation _MSAsyncElementAction
- (void)action:(MSAsync *)flux
{ _action(flux); }
@end

@interface _MSAsyncElementSuperAction : MSAsyncElement {
@public
  MSAsyncSuperAction _superAction;
  id _object;
}
@end
@implementation _MSAsyncElementSuperAction
- (void)dealloc {
  RELEASE(_object);
  [super dealloc];
}
- (void)action:(MSAsync *)flux
{ _superAction(flux, _object); }
@end

@interface _MSAsyncElementWhile : MSAsyncElement {
@public
  MSAsyncCondition _condition;
  id _elements;
}
@end
@implementation _MSAsyncElementWhile
- (void)dealloc {
  RELEASE(_elements);
  [super dealloc];
}
- (void)action:(MSAsync *)flux
{
  if (_condition(flux)) {
    [flux setFirstElements:self];
    [flux setFirstElements:_elements];
  }
  [flux continue];
}
@end

@interface _MSAsyncElementIf : MSAsyncElement {
@public
  MSAsyncCondition _condition;
  id _then;
  id _else;
}
@end
@implementation _MSAsyncElementIf
- (void)dealloc {
  RELEASE(_then);
  RELEASE(_else);
  [super dealloc];
}
- (void)action:(MSAsync *)flux
{
  if (_condition(flux))
    [flux setFirstElements:_then];
  else
    [flux setFirstElements:_else];
  [flux continue];
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
      t= [MSAsyncFlux runFluxWithContext:(CDictionary*)c elements:NULL then:barrier];
      [t setFirstElements:p];
      [t continue];}}
  [barrier action:nil];
  [barrier release];
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
  ret->_action= action;
  return ret;
}
+ (MSAsyncElement *)asyncSuperAction:(MSAsyncSuperAction)superAction withObject:(id)object
{
  _MSAsyncElementSuperAction* ret= [[_MSAsyncElementSuperAction new] autorelease];
  ret->_superAction= superAction;
  ret->_object= [object retain];
  return ret;
}
+ (MSAsyncElement *)asyncWhile:(MSAsyncCondition)condition do:(id)elements
{
  _MSAsyncElementWhile* ret= [[_MSAsyncElementWhile new] autorelease];
  ret->_condition= condition;
  ret->_elements= [elements retain];
  return ret;
}
+ (MSAsyncElement *)asyncIf:(MSAsyncCondition)condition then:(id)thenElements
{
  return [self asyncIf:condition then:thenElements else:nil];
}
+ (MSAsyncElement *)asyncIf:(MSAsyncCondition)condition then:(id)thenElements else:(id)elseElements
{
  _MSAsyncElementIf* ret= [[_MSAsyncElementIf new] autorelease];
  ret->_condition= condition;
  ret->_then= [thenElements retain];
  ret->_else= [elseElements retain];
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
  flux= [MSAsyncFlux runFluxWithContext:(CDictionary*)context elements:NULL then:nil];
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
  if ((self= [super init])) {
    _context= context ? (CDictionary *)[context retain] : CCreateDictionary(0);
    _elements= CCreateArray(0);
    if (elements)
      [self setFirstElements:elements];
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
  [[MSAsyncFlux runFluxWithContext:_context elements:_elements then:__callContinue] continue];
}
- (void)_run:(mutable MSDictionary *)context then:(MSAsyncElement *)element
{
  [[MSAsyncFlux runFluxWithContext:(CDictionary*)context elements:_elements then:element] continue];
}
- (void)continue
{
  [[MSAsyncFlux runFluxWithContext:_context elements:_elements then:nil] continue];
}

@end

@implementation MSAsyncFlux
+ (instancetype)runFluxWithContext:(CDictionary *)context elements:(CArray *)elements then:(MSAsyncElement *)then
{
  MSAsyncFlux *s= [[MSAsyncFlux new] autorelease];
  s->_context= (CDictionary *)RETAIN(context);
  s->_elements= elements ? (CArray *)CArrayCopy((id)elements) : CCreateArray(0);
  s->_then= RETAIN(then);
  s->_stack= 0;
  s->_state= MSAsyncStarted;
  return s;
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
        MSAsyncElement *element= CArrayLastObject(_elements);
        CArrayRemoveLastObject(_elements);
        if (CArrayCount(_elements) == 0) _state= MSAsyncFinishing;
        [element action:self];}
      else if (_state != MSAsyncAborted || _state != MSAsyncTerminated) {
        if (_state != MSAsyncAborted)
          _state= MSAsyncTerminated;
        [_then action:self];}
    } while (_stack == 2);
    _stack= 0;
}

@end

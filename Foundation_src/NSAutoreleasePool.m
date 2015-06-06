#import "FoundationCompatibility_Private.h"

@interface NSAutoreleasePool (Private)
- (void)_drainTree;
@end

void __currentPool_dtor(void *pool) {
  if(pool) {
    fprintf(stderr, "An autorelease pool was still present at the end of the current thread");
    [(NSAutoreleasePool*)pool _drainTree];
  }
}
MS_DECLARE_THREAD_LOCAL(__currentPool, __currentPool_dtor);

static inline void addObject(CArray *objects, id object)
{
  CArrayAddObject(objects, object);
}

static inline void drain(CArray *objects)
{
  objects->flags.noRetainRelease = NO;
  CArrayRemoveAllObjects(objects);
  objects->flags.noRetainRelease = YES;
}

@implementation NSAutoreleasePool
+(void)addObject:(id)object
{
  NSAutoreleasePool *pool= tss_get(__currentPool);
  if(!pool) {
    printf("no autorelease pool, leaking (%s*)%p\n", object_getClassName(object), object);
    abort();
    return;
  }
  addObject(pool->_objects, object);
}

-(instancetype)init
{
  NSAutoreleasePool *pool= tss_get(__currentPool);
  if(pool) {
    _parent= pool;
  }
  _objects= CCreateArrayWithOptions(0, YES, NO);
  tss_set(__currentPool, self);
  return self;
}

-(void)addObject:(id)object
{
  addObject(_objects, object);
}

-(void)dealloc
{
  drain(_objects);
  RELEASE(_objects);
  tss_set(__currentPool, _parent);
  [super dealloc];
}

-(void)drain
{
  drain(_objects);
}

-(void)_drainTree
{
  drain(_objects);
  [_parent _drainTree];
}

- (instancetype)retain
{
  MSRaise(@"NSAutoreleasePool", @"retain is not allowed on NSAutoreleasePool");
  return nil;
}

- (instancetype)autorelease
{
  MSRaise(@"NSAutoreleasePool", @"autorelease is not allowed on NSAutoreleasePool");
  return nil;
}
@end

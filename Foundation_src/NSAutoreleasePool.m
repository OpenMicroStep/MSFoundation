
#import "FoundationCompatibility_Private.h"

#warning Write tests for NSAutoreleasePool

@interface NSAutoreleasePool (Private)
- (void)_drainTree;
@end

static pthread_key_t __currentPool_key;

static void __currentPool_key_free(void *pool)
{
  if(pool) {
    fprintf(stderr, "An autorelease pool was still present at the end of the current thread");
    [(NSAutoreleasePool*)pool _drainTree];
  }
}

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
+ (void)load
{
  pthread_key_create(&__currentPool_key, __currentPool_key_free);
}

+(void)addObject:(id)object
{
  NSAutoreleasePool *pool= pthread_getspecific(__currentPool_key);
  if(!pool) {
    printf("no autorelease pool, leaking (%s*)%p\n", object_getClassName(object), object);
    abort();
    return;
  }
  addObject(pool->_objects, object);
}

-(instancetype)init
{
  NSAutoreleasePool *pool= pthread_getspecific(__currentPool_key);
  if(pool) {
    _parent= pool;
  }
  _objects= CCreateArrayWithOptions(0, YES, NO);
  pthread_setspecific(__currentPool_key, self);
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
  pthread_setspecific(__currentPool_key, _parent);
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

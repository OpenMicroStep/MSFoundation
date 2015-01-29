
#import "Foundation_Private.h"

#warning Write tests for NSAutoreleasePool

// Both GCC & CLang support ThreadLocalStorage at variable declaration
static __thread NSAutoreleasePool *__currentPool = nil;

static inline void addObject(CArray *objects, id object)
{
    CArrayAddObject(objects, object);
}

static inline void drain(CArray *objects)
{
    objects->flag.noRetainRelease = NO;
    CArrayRemoveAllObjects(objects);
    objects->flag.noRetainRelease = YES;
}

@implementation NSAutoreleasePool

+(void)addObject:(id)object
{
    NSAutoreleasePool *pool= __currentPool;
    if(!pool) {
        printf("no autorelease pool, leaking (%s*)%p", object_getClassName(object), object);
        return;
    }
    addObject(pool->_objects, object);
}

-(instancetype)init
{
    NSAutoreleasePool *pool= __currentPool;
    if(pool) {
        pool->_parent = self;
    }
    _objects= CCreateArrayWithOptions(0, YES, NO);
    __currentPool = self;
    return self;
}

-(void)addObject:(id)object
{
    addObject(_objects, object);
}

-(void)dealloc
{
    drain(_objects);
    [super dealloc];
}

-(void)drain
{
    drain(_objects);
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

@implementation NSObject (NSAutoreleasePool)

- (instancetype)autorelease
{
    [__currentPool addObject:self];
    return self;
}

@end

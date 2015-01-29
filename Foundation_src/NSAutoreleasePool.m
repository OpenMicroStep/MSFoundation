
#import "FoundationCompatibility_Private.h"

#warning Write tests for NSAutoreleasePool

static pthread_key_t __currentPool_key;

static void __currentPool_key_free(void *pool)
{
    [(NSAutoreleasePool *)pool release];
}

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
+ (void)load
{
    pthread_key_create(&__currentPool_key, __currentPool_key_free);
}

+(void)addObject:(id)object
{
    NSAutoreleasePool *pool= pthread_getspecific(__currentPool_key);
    if(!pool) {
        printf("no autorelease pool, leaking (%s*)%p", object_getClassName(object), object);
        return;
    }
    addObject(pool->_objects, object);
}

-(instancetype)init
{
    NSAutoreleasePool *pool= pthread_getspecific(__currentPool_key);
    if(pool) {
        pool->_parent = self;
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
    [(NSAutoreleasePool*)pthread_getspecific(__currentPool_key) addObject:self];
    return self;
}

@end

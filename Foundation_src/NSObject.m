#import "Foundation_Private.h"

@implementation NSObject

+ (instancetype)new
{
    return [[self alloc] init];
}

+ (instancetype)alloc
{
    return NSAllocateObject(self, 0, NULL);
}

- (instancetype)init
{
    return self;
}

- (instancetype)retain
{
    atomic_int32_increment(&_retainCount);
    return self;
}

- (oneway void)release
{
    if(atomic_int32_decrement(&_retainCount)) {
        [self dealloc];
    }
}

// See NSAutoreleasePool.m - (instancetype)autorelease;
- (NSUInteger)retainCount
{
    return atomic_int32_fetch(&_retainCount);
}

- (void)dealloc
{
    NSDeallocateObject(self);
}

- (BOOL)isEqual:(id)object
{
    return self == object;
}

- (NSUInteger)hash
{
    return (NSUInteger)self;
}

- (instancetype)self
{
    return self;
}
- (Class)superclass
{
    return class_getSuperclass(isa);
}

- (Class)class
{
    return isa;
}

- (BOOL)isKindOfClass:(Class)aClass
{
    Class selfClass= isa;
    while (selfClass && selfClass != aClass) {
        selfClass= class_getSuperclass(selfClass);
    }
    return selfClass == aClass;
}

- (BOOL)isMemberOfClass:(Class)aClass
{
    return isa == aClass;
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    return class_conformsToProtocol(isa, aProtocol);
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return class_respondsToSelector(isa, aSelector);
}

- (id)performSelector:(SEL)aSelector
{
    IMP imp= objc_msg_lookup(self, aSelector);
    return imp(self, aSelector);
}

- (id)performSelector:(SEL)aSelector withObject:(id)object
{
    IMP imp= objc_msg_lookup(self, aSelector);
    return imp(self, aSelector, object);
}

- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2
{
    IMP imp= objc_msg_lookup(self, aSelector);
    return imp(self, aSelector, object1, object2);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p>", [self class], self];
}

- (NSString *)debugDescription
{
    return [self description];
}

- (BOOL)isProxy
{
    return NO;
}

@end

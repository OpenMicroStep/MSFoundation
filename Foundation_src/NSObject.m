#import "FoundationCompatibility_Private.h"

@implementation NSObject

+ (instancetype)new
{
    return [[self alloc] init];
}

+ (instancetype)alloc
{
    return [self allocWithZone:nil];
}

+ (instancetype)allocWithZone:(NSZone *)zone
{
    return NSAllocateObject(self, 0, NULL);
}

- (NSZone *)zone
{
  return nil;
}

- (instancetype)init
{
    return self;
}

- (instancetype)retain
{
    __sync_add_and_fetch(&_retainCount, 1);
    return self;
}

- (oneway void)release
{
    if(__sync_sub_and_fetch(&_retainCount, 1) == -1) {
        [self dealloc];
    }
}

- (instancetype)autorelease {
  [NSAutoreleasePool addObject:self];
  return self;
}

- (NSUInteger)retainCount
{
    return _retainCount + 1;
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

+ (Class)superclass
{
    return class_getSuperclass(self);
}

+ (Class)class
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
    return [NSString stringWithFormat:@"<%s %p>", object_getClassName(self), self];
}

- (NSString *)debugDescription
{
    return [self description];
}

- (BOOL)isProxy
{
    return NO;
}

- (id)copy
{
  if([self respondsToSelector:@selector(copyWithZone:)])
    return [(id <NSCopying>)self copyWithZone:nil];
  MSRaise(@"NSObject", @"copyWithZone not implemented");
  return nil;
}

- (id)mutableCopy
{
  if([self respondsToSelector:@selector(mutableCopyWithZone:)])
    return [(id <NSMutableCopying>)self mutableCopyWithZone:nil];
  MSRaise(@"NSObject", @"mutableCopyWithZone not implemented");
  return nil;
}
@end

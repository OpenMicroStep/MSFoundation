@class NSString, NSMethodSignature, NSInvocation;

@protocol NSObject

- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

- (instancetype)self;
- (Class)superclass;
- (Class)class;

- (BOOL)isKindOfClass:(Class)aClass;
- (BOOL)isMemberOfClass:(Class)aClass;
- (BOOL)conformsToProtocol:(Protocol *)aProtocol;

- (BOOL)respondsToSelector:(SEL)aSelector;
- (id)performSelector:(SEL)aSelector;
- (id)performSelector:(SEL)aSelector withObject:(id)object;
- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2;

- (instancetype)retain;
- (oneway void)release;
- (instancetype)autorelease;
- (NSUInteger)retainCount;

- (NSString *)description;
- (NSString *)debugDescription;

- (BOOL)isProxy;

@end

@interface NSObject <NSObject> {
    Class isa;
    atomic_int32_t _retainCount;
}

- (void)dealloc;
@end

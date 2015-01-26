@class NSString, NSMethodSignature, NSInvocation;

@protocol NSObject

- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

- (Class)superclass;
- (Class)class;

- (instancetype)self;

- (id)performSelector:(SEL)aSelector;
- (id)performSelector:(SEL)aSelector withObject:(id)object;
- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2;

- (BOOL)isProxy;

- (BOOL)isKindOfClass:(Class)aClass;
- (BOOL)isMemberOfClass:(Class)aClass;
- (BOOL)conformsToProtocol:(Protocol *)aProtocol;

- (BOOL)respondsToSelector:(SEL)aSelector;

- (instancetype)retain;
- (oneway void)release;
- (instancetype)autorelease;
- (NSUInteger)retainCount;

- (NSString *)description;
- (NSString *)debugDescription;

@end

@interface NSObject <NSObject>

@end

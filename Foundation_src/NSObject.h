@class NSString, NSMethodSignature, NSInvocation, NSZone;

@protocol NSCopying
- (id)copyWithZone:(NSZone *)zone;
@end

@protocol NSMutableCopying
- (id)mutableCopyWithZone:(NSZone *)zone;
@end

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
- (NSZone *)zone;

@end

NS_ROOT_CLASS
@interface NSObject <NSObject> {
    Class isa;
    int32_t _retainCount;
}

+ (Class)superclass;
+ (Class)class;

- (BOOL)isEqual:(id)object;

+ (instancetype)new;
+ (instancetype)alloc;
+ (instancetype)allocWithZone:(NSZone *)zone;
- (instancetype)init;
- (void)dealloc;

- (id)copy;
- (id)mutableCopy;

- (void)doesNotRecognizeSelector:(SEL)aSelector;
- (void)forwardInvocation:(NSInvocation *)anInvocation;
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;

@end


@interface NSMethodSignature : NSObject
+ (NSMethodSignature *)signatureWithObjCTypes:(const char *)types;
- (BOOL)isOneway;

- (NSUInteger)frameLength;
- (NSUInteger)numberOfArguments;
- (const char *)getArgumentTypeAtIndex:(NSUInteger)index;

- (const char *)methodReturnType;
- (NSUInteger)methodReturnLength;
@end

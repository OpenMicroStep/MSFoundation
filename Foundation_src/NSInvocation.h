
@interface NSInvocation : NSObject
+ (NSInvocation *)invocationWithMethodSignature:(NSMethodSignature *)signature;

- (NSMethodSignature *)methodSignature;

- (SEL)selector;
- (void)setSelector:(SEL)selector;

- (id)target;
- (void)setTarget:(id)target;

- (BOOL)argumentsRetained;
- (void)setArgumentsRetained:(BOOL)argumentsRetained;

- (void)getArgument:(void *)buffer atIndex:(NSInteger)index;
- (void)setArgument:(void *)buffer atIndex:(NSInteger)index;

- (void)setReturnValue:(void *)buffer;
- (void)getReturnValue:(void *)buffer;

- (void)invoke;
- (void)invokeWithTarget:(id)target;
@end

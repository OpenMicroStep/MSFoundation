
@interface NSMethodSignature : NSObject {
  CBuffer *_types; // type string separated by \0
  CArray *_typesIndexes;
}
+ (NSMethodSignature *)signatureWithObjCTypes:(const char *)types;
- (BOOL)isOneway;

- (NSUInteger)frameLength;
- (NSUInteger)numberOfArguments;
- (const char *)getArgumentTypeAtIndex:(NSUInteger)index;

- (const char *)methodReturnType;
- (NSUInteger)methodReturnLength;
@end

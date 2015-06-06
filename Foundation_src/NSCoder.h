
@interface NSObject (NSCoderMethods)
+ (NSInteger)version;
+ (void)setVersion:(NSInteger)aVersion;
- (Class)classForCoder;
- (id)replacementObjectForCoder:(NSCoder *)aCoder;
- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder;
@end

@interface NSCoder : NSObject

- (void)encodeValueOfObjCType:(const char *)type at:(const void *)addr;
- (void)decodeValueOfObjCType:(const char *)type at:(void *)data;
- (void)encodeDataObject:(NSData *)data;
- (NSData *)decodeDataObject;
- (NSInteger)versionForClassName:(NSString *)className;

@end

@interface NSCoder (NSExtendedCoder)
    
- (void)encodeObject:(id)object;
- (void)encodeRootObject:(id)rootObject;
- (void)encodeBycopyObject:(id)anObject;
- (void)encodeByrefObject:(id)anObject;
- (void)encodeConditionalObject:(id)object;
- (id)decodeObject;


- (void)encodeArrayOfObjCType:(const char *)type count:(NSUInteger)count at:(const void *)array;
- (void)decodeArrayOfObjCType:(const char *)itemType count:(NSUInteger)count at:(void *)array;

@end


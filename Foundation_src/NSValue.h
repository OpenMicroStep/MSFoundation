
@interface NSValue : NSObject <NSCopying, NSSecureCoding> {
@protected
  const char *_objctype;
  union {
    void *ptr;
    MSLong i8;
    MSULong u8;
    double dbl;
  } value;
}

- (void)getValue:(void *)value;
- (const char *)objCType;

@end

@interface NSValue (NSValueCreation)

- (id)initWithBytes:(const void *)value objCType:(const char *)type;
+ (NSValue *)valueWithBytes:(const void *)value objCType:(const char *)type;
+ (NSValue *)value:(const void *)value withObjCType:(const char *)type;

@end

@interface NSValue (NSValueExtensionMethods)

+ (NSValue *)valueWithNonretainedObject:(id)anObject;
- (id)nonretainedObjectValue;

+ (NSValue *)valueWithPointer:(const void *)pointer;
- (void *)pointerValue;

- (BOOL)isEqualToValue:(NSValue *)value;

@end

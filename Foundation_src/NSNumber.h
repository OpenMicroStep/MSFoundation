
@interface NSNumber : NSValue {
  
}

- (char)charValue;
- (unsigned char)unsignedCharValue;
- (short)shortValue;
- (unsigned short)unsignedShortValue;
- (int)intValue;
- (unsigned int)unsignedIntValue;
- (long)longValue;
- (unsigned long)unsignedLongValue;
- (long long)longLongValue;
- (unsigned long long)unsignedLongLongValue;
- (float)floatValue;
- (double)doubleValue;
- (BOOL)boolValue;
- (NSString *)stringValue;

@end

@interface NSNumber (NSNumberCreation)

+ (NSNumber *)numberWithChar:(char)value;
+ (NSNumber *)numberWithUnsignedChar:(unsigned char)value;
+ (NSNumber *)numberWithShort:(short)value;
+ (NSNumber *)numberWithUnsignedShort:(unsigned short)value;
+ (NSNumber *)numberWithInt:(int)value;
+ (NSNumber *)numberWithUnsignedInt:(unsigned int)value;
+ (NSNumber *)numberWithLong:(long)value;
+ (NSNumber *)numberWithUnsignedLong:(unsigned long)value;
+ (NSNumber *)numberWithLongLong:(long long)value;
+ (NSNumber *)numberWithUnsignedLongLong:(unsigned long long)value;
+ (NSNumber *)numberWithFloat:(float)value;
+ (NSNumber *)numberWithDouble:(double)value;
+ (NSNumber *)numberWithBool:(BOOL)value;
+ (NSNumber *)numberWithInteger:(NSInteger)value;
+ (NSNumber *)numberWithUnsignedInteger:(NSUInteger)value;

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (NSNumber *)initWithChar:(char)value;
- (NSNumber *)initWithUnsignedChar:(unsigned char)value;
- (NSNumber *)initWithShort:(short)value;
- (NSNumber *)initWithUnsignedShort:(unsigned short)value;
- (NSNumber *)initWithInt:(int)value;
- (NSNumber *)initWithUnsignedInt:(unsigned int)value;
- (NSNumber *)initWithLong:(long)value;
- (NSNumber *)initWithUnsignedLong:(unsigned long)value;
- (NSNumber *)initWithLongLong:(long long)value;
- (NSNumber *)initWithUnsignedLongLong:(unsigned long long)value;
- (NSNumber *)initWithFloat:(float)value;
- (NSNumber *)initWithDouble:(double)value;
- (NSNumber *)initWithBool:(BOOL)value;
- (NSNumber *)initWithInteger:(NSInteger)value;
- (NSNumber *)initWithUnsignedInteger:(NSUInteger)value;

@end



@interface NSScanner : NSObject {
@private
  NSString *_string;
  SES _ses; NSUInteger _i;
  BOOL _caseInsensitive;
  NSCharacterSet *_charactersToBeSkipped;
}
+ (instancetype)scannerWithString:(NSString *)aString;
- (instancetype)initWithString:(NSString *)aString;
- (BOOL)caseSensitive;
- (void)setCaseSensitive:(BOOL)flag;

- (NSCharacterSet *)charactersToBeSkipped;
- (void)setCharactersToBeSkipped:(NSCharacterSet *)skipSet;

- (NSUInteger)scanLocation;
- (void)setScanLocation:(NSUInteger)index;
- (NSString *)string;
- (BOOL)isAtEnd;
- (BOOL)scanCharactersFromSet:(NSCharacterSet *)scanSet intoString:(NSString **)stringValue;
//- (BOOL)scanDecimal:(NSDecimal *)decimalValue;
- (BOOL)scanDouble:(double *)doubleValue;
- (BOOL)scanFloat:(float *)floatValue;
- (BOOL)scanHexInt:(unsigned int *)intValue;
- (BOOL)scanInt:(int *)intValue;
- (BOOL)scanLongLong:(long long *)longLongValue;
- (BOOL)scanString:(NSString *)string intoString:(NSString **)stringValue;
- (BOOL)scanUpToCharactersFromSet:(NSCharacterSet *)stopSet intoString:(NSString **)stringValue;
- (BOOL)scanUpToString:(NSString *)stopString intoString:(NSString **)stringValue;

@end

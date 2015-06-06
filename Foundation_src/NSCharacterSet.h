@interface NSCharacterSet : NSObject <NSCopying, NSMutableCopying, NSCoding>

+ (NSCharacterSet *)controlCharacterSet;
+ (NSCharacterSet *)whitespaceCharacterSet;
+ (NSCharacterSet *)whitespaceAndNewlineCharacterSet;
+ (NSCharacterSet *)decimalDigitCharacterSet;
+ (NSCharacterSet *)letterCharacterSet;
+ (NSCharacterSet *)lowercaseLetterCharacterSet;
+ (NSCharacterSet *)uppercaseLetterCharacterSet;
+ (NSCharacterSet *)nonBaseCharacterSet;
+ (NSCharacterSet *)alphanumericCharacterSet;
+ (NSCharacterSet *)decomposableCharacterSet;
+ (NSCharacterSet *)illegalCharacterSet;
+ (NSCharacterSet *)punctuationCharacterSet;
+ (NSCharacterSet *)capitalizedLetterCharacterSet;
+ (NSCharacterSet *)symbolCharacterSet;

+ (NSCharacterSet *)characterSetWithCharactersInString:(NSString *)aString;

- (BOOL)characterIsMember:(unichar)aCharacter;
- (NSData *)bitmapRepresentation;
- (NSCharacterSet *)invertedSet;

@end

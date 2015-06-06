@class NSLocale, NSData;

typedef uint16_t unichar;

typedef NS_OPTIONS(NSUInteger, NSStringCompareOptions) {
    NSCaseInsensitiveSearch = 1,
    NSLiteralSearch = 2,		/* Exact character-by-character equivalence */
    NSBackwardsSearch = 4,		/* Search from end of source string */
    NSAnchoredSearch = 8,		/* Search is limited to start (or end, if NSBackwardsSearch) of source string */
    NSNumericSearch = 64,		/* Added in 10.2; Numbers within strings are compared using numeric value, that is, Foo2.txt < Foo7.txt < Foo25.txt; only applies to compare methods, not find */
    NSDiacriticInsensitiveSearch = 128, /* If specified, ignores diacritics (o-umlaut == o) */
    NSWidthInsensitiveSearch = 256, /* If specified, ignores width differences ('a' == UFF41) */
    NSForcedOrderingSearch = 512, /* If specified, comparisons are forced to return either NSOrderedAscending or NSOrderedDescending if the strings are equivalent but not strictly equal, for stability when sorting (e.g. "aaa" > "AAA" with NSCaseInsensitiveSearch specified) */
    NSRegularExpressionSearch = 1024    /* Applies to rangeOfString:..., stringByReplacingOccurrencesOfString:..., and replaceOccurrencesOfString:... methods only; the search string is treated as an ICU-compatible regular expression; if set, no other options can apply except NSCaseInsensitiveSearch and NSAnchoredSearch */
};

@interface NSString : NSObject <NSCopying, NSMutableCopying, NSSecureCoding>

- (NSUInteger)length;			
- (unichar)characterAtIndex:(NSUInteger)index;

@end

@interface NSString (NSStringCreation)

- (instancetype)initWithCharactersNoCopy:(unichar *)characters length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer;	/* "NoCopy" is a hint */
- (instancetype)initWithCharacters:(const unichar *)characters length:(NSUInteger)length;
- (instancetype)initWithUTF8String:(const char *)nullTerminatedCString;
- (instancetype)initWithString:(NSString *)aString;
- (instancetype)initWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (instancetype)initWithFormat:(NSString *)format arguments:(va_list)argList NS_FORMAT_FUNCTION(1,0);
- (instancetype)initWithFormat:(NSString *)format locale:(id)locale, ... NS_FORMAT_FUNCTION(1,3);
- (instancetype)initWithFormat:(NSString *)format locale:(id)locale arguments:(va_list)argList NS_FORMAT_FUNCTION(1,0);
- (instancetype)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding;
- (instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding;
- (instancetype)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer;	/* "NoCopy" is a hint */
- (instancetype)initWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding;

+ (instancetype)string;
+ (instancetype)stringWithString:(NSString *)string;
+ (instancetype)stringWithCharacters:(const unichar *)characters length:(NSUInteger)length;
+ (instancetype)stringWithUTF8String:(const char *)nullTerminatedCString;
+ (instancetype)stringWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
+ (instancetype)localizedStringWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
+ (instancetype)stringWithCString:(const char *)cString encoding:(NSStringEncoding)enc;
@end

@interface NSString (NSStringExtensionMethods)
- (BOOL)isEqualToString:(NSString*)s;

- (NSRange)rangeOfString:(NSString *)aString;
- (NSRange)rangeOfString:(NSString *)aString options:(NSStringCompareOptions)mask;
- (NSRange)rangeOfString:(NSString *)aString options:(NSStringCompareOptions)mask range:(NSRange)searchRange;
- (NSRange)rangeOfString:(NSString *)aString options:(NSStringCompareOptions)mask range:(NSRange)searchRange locale:(NSLocale *)locale;

- (NSString *)uppercaseString;
- (NSString *)lowercaseString;
- (NSString *)capitalizedString;
@end

@interface NSString (NSStringCompareExtension)
- (NSComparisonResult)caseInsensitiveCompare:(NSString *)aString;
- (NSComparisonResult)compare:(NSString *)aString;
- (BOOL)hasPrefix:(NSString *)aString;
- (BOOL)hasSuffix:(NSString *)aString;
@end

@interface NSString (NSStringDividingExtension)
- (NSArray *)componentsSeparatedByString:(NSString *)separator;
- (NSString *)substringFromIndex:(NSUInteger)anIndex;
- (NSString *)substringToIndex:(NSUInteger)anIndex;
- (NSString *)substringWithRange:(NSRange)aRange;
@end

@interface NSString (NSStringCombineExtension)
- (NSString *)stringByAppendingFormat:(NSString *)format, ...;
- (NSString *)stringByAppendingString:(NSString *)aString;
- (NSString *)stringByPaddingToLength:(NSUInteger)newLength withString:(NSString *)padString startingAtIndex:(NSUInteger)padIndex;
@end

@interface NSString (NSStringPathExtension)
+ (NSString *)pathWithComponents:(NSArray *)components;
- (const char *)fileSystemRepresentation;
- (NSArray *)pathComponents;
- (BOOL)isAbsolutePath;
- (NSString *)lastPathComponent;
- (NSString *)pathExtension;
- (NSString *)stringByAppendingPathComponent:(NSString *)aString;
- (NSString *)stringByAppendingPathExtension:(NSString *)ext;
- (NSString *)stringByDeletingLastPathComponent ;
- (NSString *)stringByDeletingPathExtension;
- (NSArray *)stringsByAppendingPaths:(NSArray *)paths;
@end

@interface NSMutableString : NSString
@end

@interface NSConstantString : NSString
@end


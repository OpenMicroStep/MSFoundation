@class NSLocale;

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

@interface NSString : NSObject

- (NSUInteger)length;			
- (unichar)characterAtIndex:(NSUInteger)index;

@end

@interface NSString (NSStringExtensionMethods)
- (NSRange)rangeOfString:(NSString *)aString;
- (NSRange)rangeOfString:(NSString *)aString options:(NSStringCompareOptions)mask;
- (NSRange)rangeOfString:(NSString *)aString options:(NSStringCompareOptions)mask range:(NSRange)searchRange;
- (NSRange)rangeOfString:(NSString *)aString options:(NSStringCompareOptions)mask range:(NSRange)searchRange locale:(NSLocale *)locale;
@end

@interface NSMutableString : NSString

@end

@interface NSConstantString : NSString {
    void    *_bytes;
    uint32_t _length;
}
@end


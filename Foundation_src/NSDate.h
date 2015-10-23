
#define NSTimeIntervalSince1970  978307200.0

@interface NSDate : NSObject <NSCopying>

- (NSTimeInterval)timeIntervalSince1970;
- (NSTimeInterval)timeIntervalSinceReferenceDate;
@end

@interface NSDate (NSDateCreation)

- (instancetype)init;
- (instancetype)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)ti;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

+ (instancetype)date;
+ (instancetype)dateWithTimeIntervalSinceNow:(NSTimeInterval)secs;
+ (instancetype)dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)ti;
+ (instancetype)dateWithTimeIntervalSince1970:(NSTimeInterval)secs;
+ (instancetype)dateWithTimeInterval:(NSTimeInterval)secsToBeAdded sinceDate:(NSDate *)date;

+ (id /* NSDate* */)distantFuture;
+ (id /* NSDate* */)distantPast;

- (instancetype)initWithTimeIntervalSinceNow:(NSTimeInterval)secs;
- (instancetype)initWithTimeIntervalSince1970:(NSTimeInterval)secs;
- (instancetype)initWithTimeInterval:(NSTimeInterval)secsToBeAdded sinceDate:(NSDate *)date;

@end

@interface NSDate (NSDateExtendedMethods)

- (NSTimeInterval)timeIntervalSinceNow;
- (NSTimeInterval)timeIntervalSinceDate:(NSDate *)anotherDate;

- (instancetype)dateByAddingTimeInterval:(NSTimeInterval)seconds;

- (NSComparisonResult)compare:(NSDate *)anotherDate;
- (BOOL)isEqualToDate:(NSDate *)anotherDate;
- (NSDate *)earlierDate:(NSDate *)anotherDate;
- (NSDate *)laterDate:(NSDate *)anotherDate;
@end

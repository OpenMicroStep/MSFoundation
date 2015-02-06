
@interface NSDate : NSObject

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

+ (id /* NSDate * */)distantFuture;
+ (id /* NSDate * */)distantPast;

- (instancetype)initWithTimeIntervalSinceNow:(NSTimeInterval)secs;
- (instancetype)initWithTimeIntervalSince1970:(NSTimeInterval)secs;
- (instancetype)initWithTimeInterval:(NSTimeInterval)secsToBeAdded sinceDate:(NSDate *)date;

@end

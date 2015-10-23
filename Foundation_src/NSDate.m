#import "FoundationCompatibility_Private.h"

@interface _NSDate : NSDate {
  NSTimeInterval _interval;
}
@end

static inline NSTimeInterval _now()
{
  return ((NSTimeInterval)ms_gmt_now_micro()) / 1000000;
}
static NSDate *__distantPast, *__distantFuture;

@implementation NSDate
+ (void)initialize
{
  if (self==[NSDate class]) {
    __distantPast= [[_NSDate allocWithZone:NULL] initWithTimeIntervalSinceReferenceDate:-DBL_MAX];
    __distantFuture= [[_NSDate allocWithZone:NULL] initWithTimeIntervalSinceReferenceDate:DBL_MAX];}
}

#pragma mark Create & Init


+ (instancetype)allocWithZone:(NSZone *)zone
{
  return (self==[NSDate class]) ? [_NSDate allocWithZone:zone] : [super allocWithZone:zone];
}

+ (id)distantPast
{ return __distantPast; }
+ (id)distantFuture
{ return __distantFuture; }

+ (instancetype)date
{ return AUTORELEASE([[self alloc] init]); }
+ (instancetype)dateWithTimeIntervalSinceNow:(NSTimeInterval)secs
{ return AUTORELEASE([[self alloc] initWithTimeIntervalSinceNow:secs]); }
+ (instancetype)dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)ti
{ return AUTORELEASE([[self alloc] initWithTimeIntervalSinceReferenceDate:ti]); }
+ (instancetype)dateWithTimeIntervalSince1970:(NSTimeInterval)secs
{ return AUTORELEASE([[self alloc] initWithTimeIntervalSince1970:secs]); }
+ (instancetype)dateWithTimeInterval:(NSTimeInterval)secsToBeAdded sinceDate:(NSDate *)date
{ return AUTORELEASE([[self alloc] initWithTimeInterval:secsToBeAdded sinceDate:date]); }

- (id)copyWithZone:(NSZone *)zone
{
  return [self retain];
}
- (BOOL)isEqual:(id)o
{
  if (o == self) return YES;
  return [o isKindOfClass:[NSDate class]] ? [self isEqualToDate:o] : NO;
}

#pragma mark Time intervals

- (NSTimeInterval)timeIntervalSince1970
{
  return [self timeIntervalSinceReferenceDate] + NSTimeIntervalSince1970;
}
- (NSTimeInterval)timeIntervalSinceNow
{
  return [self timeIntervalSinceReferenceDate] - _now();
}
- (NSTimeInterval)timeIntervalSinceDate:(NSDate *)d
{
  return [self timeIntervalSinceReferenceDate] - [d timeIntervalSinceReferenceDate];
}
- (instancetype)dateByAddingTimeInterval:(NSTimeInterval)seconds
{
  return [NSDate dateWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate] + seconds];
}

#pragma mark Comparison

- (NSComparisonResult)compare:(NSDate *)d
{
  NSComparisonResult ret; NSTimeInterval diff;

  diff= [self timeIntervalSinceReferenceDate] - [d timeIntervalSinceReferenceDate];
  if (diff == 0) {
    ret= NSOrderedSame;}
  else if (diff > 0) { // self is later in time than d
    ret= NSOrderedDescending;}
  else { // self is earlier in time than d
    ret= NSOrderedAscending;}

  return ret;
}
- (NSDate *)earlierDate:(NSDate *)d
{
  return [self compare:d] == NSOrderedDescending ? d : self;
}
- (NSDate *)laterDate:(NSDate *)d
{
  return [self compare:d] == NSOrderedAscending ? d : self;
}
- (BOOL)isEqualToDate:(NSDate*)d
{
  return [self compare:d] == NSOrderedSame;
}
@end

@implementation _NSDate

- (instancetype)init
{
  _interval= _now();
  return self;
}
- (id)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)ti
{
  _interval= ti;
  return self;
}

- (instancetype)initWithTimeIntervalSinceNow:(NSTimeInterval)secs
{
  _interval= _now() + secs;
  return self;
}

- (instancetype)initWithTimeIntervalSince1970:(NSTimeInterval)secs
{
  _interval= secs - NSTimeIntervalSince1970;
  return self;
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)secsToBeAdded sinceDate:(NSDate *)date
{
  _interval= [date timeIntervalSinceReferenceDate] + secsToBeAdded;
  return self;
}

- (NSTimeInterval)timeIntervalSinceReferenceDate
{
  return _interval;
}

// TODO: surcharger les init de MSDate qui sont en local time
// Raise sur les init de MS. Ou réécriture à partir de CDate ?
// TODO: test NSDate
- (NSString*)descriptionWithCalendarFormat:(NSString*)format timeZone:(NSTimeZone*)aTimeZone
  locale:(id)locale
  {
  return @"(Description Not Implemented)";
  }

- (NSString *)description
{
  CDate date;
  date.interval = (MSTimeInterval)(_interval + 0.5);
  return FMT(@"%04u-%02u-%02u %02u:%02u:%02u +0000",
    CDateYearOfCommonEra(&date), CDateMonthOfYear(&date), CDateDayOfMonth(&date),
    CDateHourOfDay(&date), CDateMinuteOfHour(&date), CDateSecondOfMinute(&date));
}
@end

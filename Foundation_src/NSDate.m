#import "FoundationCompatibility_Private.h"

@interface _NSDate : MSDate
@end

@implementation NSDate
+ (void)load{ MSFinishLoadingAddClass(self); }
+ (void)finishLoading
{
  if (self==[NSDate class]) {
    FoundationCompatibilityExtendClass('+', self, 0, [MSDate class], @selector(date));
    FoundationCompatibilityExtendClass('+', self, 0, [MSDate class], @selector(dateWithTimeIntervalSinceNow:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSDate class], @selector(dateWithTimeIntervalSince1970:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSDate class], @selector(dateWithTimeInterval:sinceDate:));}
}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  return (self==[NSDate class]) ? [_NSDate allocWithZone:zone] : [super allocWithZone:zone];
}

+ (instancetype)dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)ti
{
  return AUTORELEASE([[self alloc] initWithTimeIntervalSinceReferenceDate:ti]);
}

@end

@implementation _NSDate

- (id)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)ti
{
  ((CDate*)self)->interval= ti;
  return self;
}

// TODO: surcharger les init de MSDate qui sont en local time
// Raise sur les init de MS. Ou réécriture à partir de CDate ?
// TODO: test NSDate

- (NSString*)descriptionWithCalendarFormat:(NSString*)format timeZone:(NSTimeZone*)aTimeZone
  locale:(id)locale
  {
  return @"(Description Not Implemented)";
  }

@end

#import "FoundationCompatibility_Private.h"

@implementation NSDate
+ (void)load{ MSFinishLoadingAddClass(self); }
+ (void)finishLoading
{
  if (self==[NSDate class]) {
    FoundationCompatibilityExtendClass('+', self, 0, [MSDate class], @selector(date));
    FoundationCompatibilityExtendClass('+', self, 0, [MSDate class], @selector(dateWithTimeIntervalSinceNow:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSDate class], @selector(dateWithTimeIntervalSinceReferenceDate:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSDate class], @selector(dateWithTimeIntervalSince1970:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSDate class], @selector(dateWithTimeInterval:sinceDate:));}
}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  return (self==[NSDate class]) ? [MSDate allocWithZone:zone] : [super allocWithZone:zone];
}
@end

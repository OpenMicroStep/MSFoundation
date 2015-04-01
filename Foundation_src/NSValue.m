#import "FoundationCompatibility_Private.h"

@implementation NSValue

- (id)initWithBytes:(const void *)value objCType:(const char *)type
{
  return nil;
}

+ (NSValue *)valueWithBytes:(const void *)value objCType:(const char *)type
{
  return AUTORELEASE([ALLOC(self) initWithBytes:value objCType:type]);
}

+ (NSValue *)value:(const void *)value withObjCType:(const char *)type;
{
  return AUTORELEASE([ALLOC(self) initWithBytes:value objCType:type]);
}

@end

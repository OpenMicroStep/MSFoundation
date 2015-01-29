#import "FoundationCompatibility_Private.h"

@implementation NSString

@end

@implementation NSMutableString

@end

@implementation NSConstantString
- (const char*)UTF8String
{
    return (const char *)_bytes;
}
@end
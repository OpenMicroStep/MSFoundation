#import "FoundationCompatibility_Private.h"

NSZone *NSDefaultMallocZone(void)
{
   return nil;
}

@implementation NSZone

@end

#import "FoundationCompatibility_Private.h"

NSZone *NSDefaultMallocZone(void)
{
   return NULL;
}

@implementation NSZone

@end

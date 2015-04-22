#import "FoundationCompatibility_Private.h"

NSString *NSStringFromRange(NSRange range)
{
   return FMT(@"{%lu, %lu}", (unsigned long)range.location, (unsigned long)range.length);
}

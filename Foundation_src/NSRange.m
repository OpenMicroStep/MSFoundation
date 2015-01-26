#import "Foundation_Private.h"

NSString *NSStringFromRange(NSRange range)
{
   return FMT(@"{%u, %u}", range.location, range.length);
}

// msdb_validate.h, ecb, 140101

#import <MSDatabase/MSDatabase.h>
#include "MSTests.h"

@interface MSDBTestsContext : NSObject {
@public
  MSArray *retained;
  NSArray *adaptors;
  NSUInteger idx;
}
@end

extern testdef_t msdb_adaptor[];
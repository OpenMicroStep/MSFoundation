#if   defined(MSFOUNDATION_TESTS)
#import <MSFoundation/MSFoundation.h>
#elif defined(MSFOUNDATIONFORCOCOA_TESTS)
#import <MSFoundationForCocoa/MSFoundation.h>
#else
#error MSFOUNDATION_TESTS or MSFOUNDATIONFORCOCOA_TESTS must be defined
#endif
#import "MSTests.h"

TEST_FCT_DECLARE(NSObject);
TEST_FCT_DECLARE(NSAutoreleasePool);
TEST_FCT_DECLARE(NSString);
TEST_FCT_DECLARE(NSArray);
TEST_FCT_DECLARE(NSDictionary);
TEST_FCT_DECLARE(NSData);
TEST_FCT_DECLARE(NSNull);
// OR LIBEXPORT int testNSObject();

TEST_FCT_DECLARE(Foundation);

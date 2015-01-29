#if   defined(MSFOUNDATION_TESTS)
#import <MSFoundation/MSFoundation.h>
#elif defined(MSFOUNDATIONFORCOCOA_TESTS)
#import <MSFoundationForCocoa/MSFoundation.h>
#else
#error MSFOUNDATION_TESTS or MSFOUNDATIONFORCOCOA_TESTS must be defined
#endif
#import "MSTests.h"

TEST_FCT_DECLARE(NSObject);
// OR LIBEXPORT int testNSObject();

TEST_FCT_DECLARE(Foundation);

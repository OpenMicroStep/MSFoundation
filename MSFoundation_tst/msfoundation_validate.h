// msfoundation_validate.h, ecb, 130911
#import "foundation_validate.h"
#import "mscore_validate.h"
#if   defined(MSFOUNDATION_TESTS)
#import <MSFoundation/MSFoundation.h>
#elif defined(MSFOUNDATIONFORCOCOA_TESTS)
#import <MSFoundationForCocoa/MSFoundation.h>
#else
#error MSFOUNDATION_TESTS or MSFOUNDATIONFORCOCOA_TESTS are required -D flags
#endif

#import "MSTests.h"

TEST_FCT_DECLARE(MSArray);
TEST_FCT_DECLARE(MSBuffer);
TEST_FCT_DECLARE(MSColor);
TEST_FCT_DECLARE(MSCouple);
TEST_FCT_DECLARE(MSDate);
TEST_FCT_DECLARE(MSDecimal);
TEST_FCT_DECLARE(MSDictionary);
TEST_FCT_DECLARE(MSString);
int msfoundation_mste_validate      (void);

TEST_FCT_DECLARE(MSFoundation);

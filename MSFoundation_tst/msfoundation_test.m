// msfoundation_test.m, ecb, 130904

#import "msfoundation_validate.h"

EXPORT_TESTS_BASE

TESTS_MAIN_BEGIN
    NSAutoreleasePool *pool= [NSAutoreleasePool new];
    TEST_FCT(MSCore);
    TEST_FCT(Foundation);
    TEST_FCT(MSFoundation);
    [pool release];
TESTS_MAIN_END

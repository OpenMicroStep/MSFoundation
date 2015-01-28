// msfoundation_test.m, ecb, 130904

#import "msfoundation_validate.h"

EXPORT_TESTS_BASE

TESTS_MAIN_BEGIN
    NSAutoreleasePool *pool= [NSAutoreleasePool new];
    MSSystemInitialize(0, NULL);
    TEST_FCT(MSCore);
    TEST_FCT(Foundation);
    TEST_FCT(MSFoundation);
TESTS_MAIN_END

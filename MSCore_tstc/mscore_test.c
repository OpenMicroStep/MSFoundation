// mscore_test.c, ecb, 130904

#include "mscore_validate.h"

EXPORT_TESTS_BASE

TESTS_MAIN_BEGIN
    MSSystemInitialize(0, NULL);
    TEST_FCT(MSCore);
TESTS_MAIN_END

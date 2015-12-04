// mscore_test.c, ecb, 130904

#include "mscore_validate.h"

EXTERN_TESTS_BASE

static void testOn(test_t *test)
{
#ifdef WO451
  MSFinishLoadingCore();
#endif
}
static void testOff(test_t *test)
{
}

testdef_t RootTests[]= {
  {"_"     ,NULL       ,testOn },
  {"MSCore",MSCoreTests,NULL   },
  {"_"     ,NULL       ,testOff},
  {NULL}};

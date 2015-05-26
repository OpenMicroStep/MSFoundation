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

LIBEXPORT test_t RootTests[]= {
  {"_"     ,NULL       ,testOn ,INTITIALIZE_TEST_T_END},
  {"MSCore",MSCoreTests,NULL   ,INTITIALIZE_TEST_T_END},
  {"_"     ,NULL       ,testOff,INTITIALIZE_TEST_T_END},
  {NULL}};

// mscore_test.c, ecb, 130904

#include "mscore_validate.h"

EXTERN_TESTS_BASE

static int testOn()
{
#ifdef WO451
  MSFinishLoadingCore();
#endif
  return 0;
}
static int testOff()
{
  return 0;
}

test_t RootTests[]= {
  {"_"     ,NULL       ,testOn,INTITIALIZE_TEST_T_END},
  {"MSCore",MSCoreTests,NULL  ,INTITIALIZE_TEST_T_END},
  {NULL}
  };

// msfoundation_test.m, ecb, 130904

#import "msfoundation_validate.h"

EXTERN_TESTS_BASE

static id _mainPool= nil;
static void testOff()
{
  RELEAZEN(_mainPool);
}
static void testOn()
{
#ifdef WO451
  MSFinishLoadingCore();
#endif
  if (_mainPool) testOff();
  _mainPool= [[NSAutoreleasePool alloc] init];
}

test_t MSFoundationCompleteTests[]= {
  {"MSCore"      ,MSCoreTests      ,NULL,INTITIALIZE_TEST_T_END},
  {"Foundation"  ,FoundationTests  ,NULL,INTITIALIZE_TEST_T_END},
  {"MSFoundation",MSFoundationTests,NULL,INTITIALIZE_TEST_T_END},
  {NULL}};

LIBEXPORT test_t RootTests[]= {
  {"_",NULL,testOn ,INTITIALIZE_TEST_T_END},
  {"MSFoundationComplete",MSFoundationCompleteTests,NULL,INTITIALIZE_TEST_T_END},
  {"_",NULL,testOff,INTITIALIZE_TEST_T_END},
  {NULL}};

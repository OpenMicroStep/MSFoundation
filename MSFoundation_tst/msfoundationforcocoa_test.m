// msfoundation_test.m, ecb, 130904

#import "msfoundation_validate.h"

EXTERN_TESTS_BASE

static id _mainPool= nil;
static int testOff()
{
  RELEAZEN(_mainPool);
  return 0;
}
static int testOn()
{
#ifdef WO451
  MSFinishLoadingCore();
#endif
  if (_mainPool) testOff();
  _mainPool= [[NSAutoreleasePool alloc] init];
  return 0;
}

test_t MSFoundationForCocoaComplete[]= {
  {"MSCore"      ,MSCoreTests      ,NULL,INTITIALIZE_TEST_T_END},
  {"Foundation"  ,FoundationTests  ,NULL,INTITIALIZE_TEST_T_END},
  {"MSFoundation",MSFoundationTests,NULL,INTITIALIZE_TEST_T_END},
  {NULL}};

test_t RootTests[]= {
  {"_",NULL,testOn ,INTITIALIZE_TEST_T_END},
  {"MSFoundationForCocoaComplete",MSFoundationForCocoaComplete,NULL,INTITIALIZE_TEST_T_END},
  {"_",NULL,testOff,INTITIALIZE_TEST_T_END},
  {NULL}};

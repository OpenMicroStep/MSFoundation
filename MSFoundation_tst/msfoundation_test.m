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

testdef_t MSFoundationCompleteTests[]= {
  {"MSCore"      ,MSCoreTests      ,NULL},
  {"Foundation"  ,FoundationTests  ,NULL},
  {"MSFoundation",MSFoundationTests,NULL},
  {NULL}};

testdef_t RootTests[]= {
  {"_",NULL,testOn },
#if defined(MSFOUNDATION_FORCOCOA)
  {"MSFoundationForCocoaComplete",MSFoundationCompleteTests,NULL},
#else
  {"MSFoundationComplete",MSFoundationCompleteTests,NULL},
#endif
  {"_",NULL,testOff},
  {NULL}};

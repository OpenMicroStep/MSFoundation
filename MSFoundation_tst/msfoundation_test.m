// msfoundation_test.m, ecb, 130904

#import "msfoundation_validate.h"

EXTERN_TESTS_BASE

LIBEXPORT void TRun(test_t *t, void (*testfn)(test_t*), void *context)
{
  NEW_POOL;
  testfn(t);
  KILL_POOL;
}

testdef_t MSFoundationCompleteTests[]= {
  {"MSCore"      ,MSCoreTests      ,NULL},
  {"Foundation"  ,FoundationTests  ,NULL},
  {"MSFoundation",MSFoundationTests,NULL},
  {NULL}};

testdef_t RootTests[]= {
#if defined(MSFOUNDATION_FORCOCOA)
  {"MSFoundationForCocoaComplete",MSFoundationCompleteTests,NULL},
#else
  {"MSFoundationComplete",MSFoundationCompleteTests,NULL},
#endif
  {NULL}};

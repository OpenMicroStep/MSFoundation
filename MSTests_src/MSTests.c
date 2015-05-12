//
//  MSTests.c
//
//  Created by Vincent Rouillé on 27/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#include <MSCore/MSCore.h>
#include "MSTests.h"

EXTERN_TESTS_BASE

mutex_t __mutex;

CString* CMessageTest;
CString* TTag1, *TTag2;
CArray*  TTags;

mutable CDictionary *imp_TCtx(test_t *t, const char *assert,
  const char *file, int line, const char *function, const char *method)
  {
  mutable CDictionary* ctx= CCreateCtx(file, line, function, method, TTags);
  CString *a=  CSCreate((char*)assert);
  CDictionarySetObjectForKey(ctx, (id)a, (id)KAssert);
  RELEASE(a);
  if (t) {
    mutex_lock(__mutex);
    if (!t->errCtxs) t->errCtxs= CCreateArray(0);
    CArrayAddObject(t->errCtxs, (id)ctx);
    t->err++;
    mutex_unlock(__mutex);}
  return ctx;
  }
void imp_TAdvise(mutable CDictionary* ctx, const char *msgFmt, ...)
{
  va_list vp;
  va_start(vp, msgFmt);
  CMessageAdvisev(CMessageTest, ctx, msgFmt, vp);
  va_end(vp);
}

// L'erreur retournée est la somme des erreurs survenues
static int test_(test_t *tests)
{
  int err= 0;
  test_t *test;
  if (tests) for (test= tests; test->name; test++) {
    test->c0= clock();
    test->t0= _GMTMicro();
    test->err+= test_(test->subTests);
    if (test->leafFunction) test->leafFunction(test); // in TAssert test->err++;
    err+= test->err;
    test->c1= clock();
    test->t1= _GMTMicro();}
  return err;
}

static void test_print(int level,test_t *tests)
{
  static const int __testPadding= 28;
  test_t *test;
  double clocks,seconds; int subs,levelMax;
  levelMax= 0;
  if (tests) for (test= tests; test->name; test++) {
    if (strcmp(test->name, "_") && (level<=levelMax || test->err)) {
      clocks= (double)(test->c1-test->c0)/CLOCKS_PER_SEC;
      seconds= (double)(test->t1-test->t0)/1000000.;
      subs= (test->subTests) ? 1 : 0;
      fprintf(stdout, "%-*s%s%-*s validate: %s clock:%.3f s time:%.3f s\n",
        level*2, "", (subs?"+ ":". "), __testPadding - level*2, test->name,
        test->err ? "FAIL" : "PASS", clocks, seconds);
      if (test->errCtxs) {
        NSUInteger n,i; CString *s; CBuffer *b; CDictionary *ctx; int space;
        s= CCreateString(0); space= level*2 + 2;
        for (n= CArrayCount(test->errCtxs), i= 0; i<n; i++) {
          ctx= (CDictionary*)CArrayObjectAtIndex(test->errCtxs, i);
          CStringAppendFormat(s, "\n%-*s assertion: ", space, "");
          CStringAppendString(s, (const CString*)CDictionaryObjectForKey(ctx, (id)KAssert));
          CStringAppendFormat(s, "\n");
          CStringAppendFormat(s, "%-*s at       : ", space, "");
          CStringAppendContextWhere(s, ctx);
          CStringAppendFormat(s, "\n");
          CStringAppendFormat(s, "%-*s reason   : ", space, "");
          CStringAppendString(s, (const CString*)CDictionaryObjectForKey(ctx, (id)KMessage));
///////// CBuffer *ts= CCreateUTF8BufferWithObjectDescription(CDictionaryObjectForKey(ctx, (id)KTags));
///////// CStringAppendFormat(s, "\ntags: %s", CBufferCString(ts));
///////// RELEASE(ts);
          CStringAppendFormat(s, "\n");}
        b= CCreateBufferWithString(s, NSUTF8StringEncoding);
        fprintf(stdout, "%s\n", CBufferCString(b));
        RELEASE(b);
        RELEASE(s);}
      test_print(level+1,test->subTests);}}
}

static int bindFct(dl_handle_t handle, const char *name, void * imp)
{
  void *fct;
  if (!(fct= dlsym(handle, name)))
    fprintf(stderr, "Unable to find symbol %s", name);
  else *(void **)fct= imp;
  return fct != 0;
}

static int test_module(const char *module, const char *prefix, const char *suffix)
{
  int err= 0, e;
  test_t *tests;
  dl_handle_t testLib;
  char path[strlen(prefix) + strlen(module) + strlen(suffix)];
  strcpy(path, prefix);
  strcpy(path + strlen(prefix), module);
  strcpy(path + strlen(prefix) + strlen(module), suffix);
//printf("Loading tests for %s (%s)\n", module, path);
  
  testLib= dlopen(path, RTLD_LAZY);
  tests= NULL;
  if (!testLib) {
    printf("Unable to load lib %s\n", path);
    err++;}
  if (!err) {
    tests= dlsym(testLib, "RootTests");
    if (!tests) {
      printf("Unable to find 'RootTests' in %s\n", path);
      err++;}}
  if (!err) {
    if (!bindFct(testLib, "TCtx", imp_TCtx)) {
      printf("Unable to find 'TCtx' in %s\n", path);
      err++;}}
  if (!err) {
    if (!bindFct(testLib, "TAdvise", imp_TAdvise)) {
      printf("Unable to find 'TAdvise' in %s\n", path);
      err++;}}
  if (!err) {
    printf("********** Test of %-42s **********\n", module);
    e= test_(tests);
    test_print(0,tests);
    if (!e) printf("********** ALL THE TESTS ARE SUCCESSFUL !!!                   **********\n\n");
    else    printf("********** FAIL *** FAIL *** FAIL *** FAIL *** FAIL *** FAIL  **********\n\n");
    dlclose(testLib);}
  return err;
}

#ifndef _WIN32
const char *__prefix= "../tests/lib";
const char *__suffix= "Tests.dylib";
#else
const char *__prefix= "";
const char *__suffix= "Tests.dll";
#endif

static void CBehaviorTest(CDictionary* ctx, CString* msg)
  {
  CDictionarySetObjectForKey(ctx, (id)msg, (id)KMessage);
  }

int main(int argc, const char * argv[])
{
  int err= 0, argi;
  mutex_init(__mutex);
  CMessageTest= CSCreate("CMessageTest");
  TTag1= CSCreate("tag 1");
  TTag2= CSCreate("tag 2");
  TTags= CCreateArrayWithObject((id)TTag1);
  CArrayAddObject(TTags, (id)TTag2);
  CMessageAddBehaviorForType(CBehaviorTest, CMessageTest);
  for (argi= 1; argi < argc; ++argi)
    err += test_module(argv[argi], __prefix, __suffix);
//ASSERTF(0 == 1, "%d != %d",0,1);
//BOOL on= CMessageDebugOn;
//CMessageDebugOn= YES;
//CMESSAGEDEBUG(imp_TCtx(NULL, NULL, CTX_FCT), "Debug");
//CMessageDebugOn= on;
  RELEASE(CMessageTest);
  RELEASE(TTag1); RELEASE(TTag2); RELEASE(TTags);
  mutex_delete(__mutex);
  return err;
}

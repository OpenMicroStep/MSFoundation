//
//  MSTests.c
//
//  Created by Vincent Rouillé on 27/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#include <MSCore/MSCore.h>
#include "MSTests.h"

EXTERN_TESTS_BASE

mtx_t __mutex;

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
    mtx_lock(&__mutex);
    if (!t->errCtxs) t->errCtxs= CCreateArray(0);
    CArrayAddObject(t->errCtxs, (id)ctx);
    t->err++;
    mtx_unlock(&__mutex);}
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

#define SESITERATE(SES_VALUE, UNICHAR_VARNAME, STATEMENT) {                    \
    SES __sesiterate_ses= SES_VALUE;                                           \
    if (SESOK(__sesiterate_ses)) {                                             \
      NSUInteger __sesiterate_start, __sesiterate_end;unichar UNICHAR_VARNAME; \
      __sesiterate_start= SESStart(__sesiterate_ses);                          \
      __sesiterate_end= SESEnd(__sesiterate_ses);                              \
      while (__sesiterate_start < __sesiterate_end) {                          \
        UNICHAR_VARNAME= SESIndexN(__sesiterate_ses, &__sesiterate_start);     \
        STATEMENT                                                              \
      }                                                                        \
    }                                                                          \
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
        NSUInteger n,i; CString *s; const CString *msg; CBuffer *b; CDictionary *ctx; int space;
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
          msg= (const CString*)CDictionaryObjectForKey(ctx, (id)KMessage);
          SESITERATE(CStringSES(msg), u, {
            if (u == (unichar)'\n') {
              CStringAppendFormat(s, "\n%-*s", space + 12, "");}
            else {
              CStringAppendCharacter(s, u);}
          });
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

static int bindFct(ms_shared_object_t handle, const char *name, void * imp)
{
  void *fct;
  if (!(fct= ms_shared_object_symbol(handle, name)))
    fprintf(stderr, "Unable to find symbol %s", name);
  else *(void **)fct= imp;
  return fct != 0;
}

static int test_module(const char *module, const char *prefix, const char *suffix)
{
  int err= 0, e;
  test_t *tests;
  ms_shared_object_t testLib;
  char path[strlen(prefix) + strlen(module) + strlen(suffix) + 1];
  strcpy(path, prefix);
  strcpy(path + strlen(prefix), module);
  strcpy(path + strlen(prefix) + strlen(module), suffix);

#ifdef WIN32
  char *sepPos = MAX(strrchr(module, '/'), strrchr(module, '\\'));
  if(sepPos) {
    int len = sepPos - module;
    char dir[len + 1];
    memcpy(dir, module, len);
    dir[len] = '\0';
    SetDllDirectoryA(dir);
  }
#endif

//printf("Loading tests for %s (%s)\n", module, path);
  
  testLib= ms_shared_object_open(path);
  tests= NULL;
  if (!testLib) {
    printf("Unable to load lib %s\n", path);
    err++;}
  if (!err) {
    tests= ms_shared_object_symbol(testLib, "RootTests");
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
    ms_shared_object_close(testLib);}
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
  mtx_init(&__mutex, mtx_recursive);
  CMessageTest= CSCreate("CMessageTest");
  TTag1= CSCreate("tag 1");
  TTag2= CSCreate("tag 2");
  TTags= CCreateArrayWithObject((id)TTag1);
  CArrayAddObject(TTags, (id)TTag2);
  CMessageAddBehaviorForType(CBehaviorTest, CMessageTest);
  for (argi= 1; argi < argc; ++argi) {
    err += test_module(argv[argi], "", "");
  }
//ASSERTF(0 == 1, "%d != %d",0,1);
//BOOL on= CMessageDebugOn;
//CMessageDebugOn= YES;
//CMESSAGEDEBUG(imp_TCtx(NULL, NULL, CTX_FCT), "Debug");
//CMessageDebugOn= on;
  RELEASE(CMessageTest);
  RELEASE(TTag1); RELEASE(TTag2); RELEASE(TTags);
  mtx_destroy(&__mutex);
  return err;
}

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

typedef struct  {
  const char *path;
  testPrepare_f prepareHook;
  testRun_f runHook;
  testFree_f freeHook;
  void *sharedContext;
} testctx_t;

struct struct_test {
  const char *name;
  test_t *subTests;
  void (*leafFunction)(test_t*);
  clock_t c0,c1;
  long    t0,t1;
  int err;
  CArray *errCtxs;
  CArray *allocs;
  testctx_t *ctx;
};


void imp_TSharedCtx(test_t *t, void **getcontext, void **setcontext)
{
  if (setcontext)
    t->ctx->sharedContext= *setcontext;
  if (getcontext)
    *getcontext= t->ctx->sharedContext;
}

const char * imp_TFile(test_t *t, const char *relativePath)
{
  const char *ret= NULL; char *end; CString *path; CBuffer *b;
  if (t->ctx->path && relativePath) {
    end= (char *)(t->ctx->path + strlen(t->ctx->path));
    while ((--end >= t->ctx->path) && *end != '/' && *end != '\\');
    path= CCreateString(0);
    CStringAppendBytes(path, NSUTF8StringEncoding, t->ctx->path, end - t->ctx->path);
    CStringAppendLiteral(path, "/Resources/");
    CStringAppendBytes(path, NSUTF8StringEncoding, relativePath, strlen(relativePath));
    b= CCreateBufferWithString(path, NSUTF8StringEncoding);
    CArrayAddObject(t->allocs, (id)b);
    ret= (const char *)CBufferCString(b);
    RELEASE(path);
    RELEASE(b);
  }
  return ret;
}

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

static void test_free(test_t *tsts);
static void test_free_one(test_t *tst);
static void test_print(int level,test_t *tests);
static test_t* test_prepare(testdef_t *testdefs, testctx_t *ctx);
static inline void test_run_begin(test_t *test);
static inline void test_run_end(test_t *test);
static void test_hook_begin(test_t *t, testctx_t *ctx, const char *name);
static int test_hook_end(test_t *t);

static test_t* test_prepare(testdef_t *testdefs, testctx_t *ctx)
{
  test_t *tsts= NULL, *tst; testdef_t *def; int n= 0;
  if (testdefs && testdefs->name) {
    for (def= testdefs; def->name; def++) n++;
    tsts= (test_t*)calloc(1, sizeof(test_t) * (n + 1));
    tst= tsts;def= testdefs;
    while (def->name) {
      tst->name= def->name;
      tst->leafFunction= def->leafFunction;
      tst->subTests= test_prepare(def->subTests, ctx);
      tst->ctx= ctx;
      tst->allocs= CCreateArray(0);
      def++;tst++;
    }
    tst->name= NULL;
  }
  return tsts;
}

static inline void test_run_begin(test_t *test)
{
  test->c0= clock();
  test->t0= _GMTMicro();
}
static inline void test_run_end(test_t *test)
{
  test->c1= clock();
  test->t1= _GMTMicro();
}
static void test_hook_begin(test_t *t, testctx_t *ctx, const char *name)
{
  memset(t, 0, sizeof(test_t));
  t->name= name;
  t->ctx= ctx;
  t->allocs= CCreateArray(0);
  test_run_begin(t);
}
static int test_hook_end(test_t *t)
{
  int err;
  test_run_end(t);
  if ((err= t->err)) {
    test_t tests[2] = {*t};
    test_print(0, tests);
  }
  test_free_one(t);
  return err;
}

// L'erreur retournée est la somme des erreurs survenues
static int test_run(test_t *tests)
{
  test_t *test;
  int err= 0;
  if (tests) for (test= tests; test->name; test++) {
    test_run_begin(test);
    test->err+= test_run(test->subTests);
    if (test->leafFunction) {
      if (test->ctx->runHook)
        test->ctx->runHook(test, test->leafFunction, test->ctx->sharedContext);
      else
        test->leafFunction(test); // in TAssert test->err++;
    }
    err+= test->err;
    test_run_end(test);}
  return err;
}

static void test_free_one(test_t *tst) {
  RELEASE(tst->allocs);
  RELEASE(tst->errCtxs);
  test_free(tst->subTests);
}

static void test_free(test_t *tsts) {
  test_t *tst; NSUInteger i, l;
  if (tsts) {
    for (tst= tsts; tst->name; tst++) {
      test_free_one(tst);
    }
    free(tsts);
  }
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
      clocks= (double)(test->c1 - test->c0)/CLOCKS_PER_SEC;
      seconds= (double)(test->t1 - test->t0)/1000000.;
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
  return fct == 0;
}
const char *dlerror();
static int test_module(const char *module, const char *prefix, const char *suffix)
{
  int err= 0, e= 0;
  testctx_t ctx;
  testdef_t *testdefs;
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
  testdefs= NULL;
  if (!testLib) {
#ifdef WIN32
    printf("Unable to load lib %s: %u\n", path, GetLastError());
#else
    printf("Unable to load lib %s: %s\n", path, dlerror());
#endif
    err++;}
  if (!err) {
    testdefs= ms_shared_object_symbol(testLib, "RootTests");
    if (!testdefs) {
      printf("Unable to find 'RootTests' in %s\n", path);
      err++;}}
  if (!err) err += bindFct(testLib, "TCtx", imp_TCtx);
  if (!err) err += bindFct(testLib, "TFile", imp_TFile);
  if (!err) err += bindFct(testLib, "TAdvise", imp_TAdvise);
  if (!err) err += bindFct(testLib, "TSharedCtx", imp_TSharedCtx);
  if (!err) {
    ctx.path= path;
    ctx.prepareHook= (testPrepare_f)ms_shared_object_symbol(testLib, "TPrepare");
    ctx.runHook= (testRun_f)ms_shared_object_symbol(testLib, "TRun");
    ctx.freeHook= (testFree_f)ms_shared_object_symbol(testLib, "TFree");
    printf("********** Test of %-42s **********\n", module);
    if (ctx.prepareHook) {
      test_t t;
      test_hook_begin(&t, &ctx, "prepare hook");
      testdefs= ctx.prepareHook(&t, testdefs, &ctx.sharedContext);
      e= test_hook_end(&t);}
    if (!e) {
      tests= test_prepare(testdefs, &ctx);
      e= test_run(tests);
      test_print(0,tests);
      test_free(tests);
      if (ctx.freeHook) {
        test_t t;
        test_hook_begin(&t, &ctx, "free hook");
        ctx.freeHook(&t, testdefs, ctx.sharedContext);
        test_hook_end(&t);}}
    if (!e) printf("********** ALL THE TESTS ARE SUCCESSFUL !!!                   **********\n\n");
    else    printf("********** FAIL *** FAIL *** FAIL *** FAIL *** FAIL *** FAIL  **********\n\n");
    ms_shared_object_close(testLib);}
  return err + e;
}

static void CBehaviorTest(CDictionary* ctx, CString* msg)
  {
  CDictionarySetObjectForKey(ctx, (id)msg, (id)KMessage);
  }

int main(int argc, const char * argv[])
{
#ifdef WIN32
  SetErrorMode(0);
#endif
  int err= 0, argi;
  mtx_init(&__mutex, mtx_recursive);
  CMessageTest= CSCreate("CMessageTest");
  TTag1= CSCreate("tag 1");
  TTag2= CSCreate("tag 2");
  TTags= CCreateArrayWithObject((id)TTag1);
  CArrayAddObject(TTags, (id)TTag2);
  CMessageAddBehaviorForType(CBehaviorTest, CMessageTest);
  for (argi= 1; argi < argc; ++argi) {
    if (strcmp(argv[argi], "--keepalive") == 0)
      sleep(100000);
    else
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

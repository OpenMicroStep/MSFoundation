//
//  MSTests.c
//
//  Created by Vincent Rouillé on 27/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#include "MSCorePlatform.h"
#include "MSTests.h"
#include <signal.h>

static const int __testPadding= 28;

#ifndef WO451
const char *__prefix = "../tests/lib";
const char *__suffix = "Tests.dylib";
#else
const char *__prefix = "";
const char *__suffix = "Tests.dll";
#endif

test_t *__currentTest= NULL;
pthread_mutex_t __mutex= PTHREAD_MUTEX_INITIALIZER;

static inline const char *_basename(const char *path)
{
  const char* basename;
  basename= strrchr(path, '/');
  return basename ? basename + 1 : path;
}

int imp_testAssert(int result, const char *assert, const char *file, int line, const char *msg, ...)
{
  if (!result) {
    va_list ap;int spaces;const char *name;
    mutex_lock(__mutex);
    name= __currentTest ? __currentTest->name : "NO CONTEXT";
    spaces= 0;
    fprintf(stderr, "%-*sX %s\n", spaces, "", name);
    fprintf(stderr, "%-*sX  assertion: %s\n", spaces, "", assert);
    fprintf(stderr, "%-*sX         at: %s:%d\n", spaces, "", _basename(file), line);
    fprintf(stderr, "%-*sX     reason: ", spaces, "");
    va_start (ap, msg);
    vfprintf(stderr, msg, ap);
    va_end(ap);
    fprintf(stderr, "\n");
    mutex_unlock(__mutex);
  }
  return !result ? 1 : 0;
}

#include <sys/time.h> // for gettimeofday
static long _GMTMicro(void)
{
  long t;
  struct timeval tv;
  gettimeofday(&tv,NULL);
  t= (tv.tv_sec)*1000000 + tv.tv_usec;
  return t;
}

int bindFct(dl_handle_t handle, const char *name, void * imp)
{
  void *fct;
  if (!(fct= dlsym(handle, name))) {
    fprintf(stderr, "Unable to find symbol %s", name);
  }
  else {
    *(void **)fct= imp;
  }
  return fct != 0;
}

///////////////////////////////////////////

// L'erreur retournée est la somme des erreurs survenues
int test_(test_t *tests)
{
  int err= 0, testErr;
  test_t *test;
  if (tests) for (test= tests; test->name; test++) {
    __currentTest= test;
    testErr= 0;
    test->c0= clock();
    test->t0= _GMTMicro();
    testErr+= test_(test->subTests);
    if (test->leafFunction) testErr+= test->leafFunction();
    err+= test->err= testErr;
    test->c1= clock();
    test->t1= _GMTMicro();}
  return err;
}

void test_print(int level,test_t *tests)
{
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
      test_print(level+1,test->subTests);
      }}
}

int test_module(const char *module, const char *prefix, const char *suffix)
{
  int err= 0;
  test_t *tests;
  dl_handle_t testLib;
  char path[strlen(prefix) + strlen(module) + strlen(suffix)];
  strcpy(path, prefix);
  strcpy(path + strlen(prefix), module);
  strcpy(path + strlen(prefix) + strlen(module), suffix);
//printf("Loading tests for %s (%s)\n", module, path);
  
  testLib = dlopen(path, RTLD_LAZY);
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
    if (!bindFct(testLib, "testAssert", imp_testAssert)) {
      printf("Unable to find 'RootTests' in %s\n", path);
      err++;}}
  if (!err) {
    int e= test_(tests);
    printf("********** Test of %-42s **********\n", module);
    test_print(0,tests);
    if (!e) printf("********** ALL THE TESTS ARE SUCCESSFUL !!!                   **********\n\n");
    else    printf("********** FAIL *** FAIL *** FAIL *** FAIL *** FAIL *** FAIL  **********\n\n");
    dlclose(testLib);}
  return err;
}

int test(int argc, const char * argv[])
{
  int err= 0, argi;
  for (argi= 1; argi < argc; ++argi)
    err += test_module(argv[argi], __prefix, __suffix);
  return err;
}

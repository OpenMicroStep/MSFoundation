//
//  MSTests.c
//
//  Created by Vincent Rouillé on 27/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#include "MSCorePlatform.h"
#include <signal.h>

static const int __testPadding = 20;

typedef int(*runtests_fct_t)(int, const char **);
#ifndef WO451
const char *__prefix = "../tests/lib";
const char *__suffix = "Tests.dylib";
#else
const char *__prefix = "";
const char *__suffix = "Tests.dll";
#endif

typedef struct _test_context_t {
    int err;
    clock_t t0;
    const char *name;
    struct _test_context_t *parent;
    uint8_t printed;
} test_context_t;

static struct {
    int err;
    int level;
    test_context_t *current;
    mutex_t mutex;
} __context = {0, 0, NULL, };

static void imp_testsStart(const char *module)
{
    printf("********** Test of %-28s **********\n", module);
}

static int imp_testsFinish(const char *module)
{
    int ret;
    mutex_lock(__context.mutex);
    ret= __context.err;
    if (!ret)
      printf("********** ALL THE TESTS ARE SUCCESSFUL !!!     **********\n\n");
    else
      printf("**** FAIL *** FAIL *** FAIL *** FAIL *** FAIL *** FAIL ***\n\n");
    mutex_unlock(__context.mutex);
    return ret;
}

static void imp_testRaiseError()
{
  (void)0;
}

static inline const char *_basename(const char *path)
{
    const char* basename;
    basename= strrchr(path, '/');
    return basename ? basename + 1 : path;
}

int imp_testAssert(int result, const char *assert, const char *file, int line, const char *msg, ...)
{
    if(!result) {
        va_list ap;int spaces;const char *name;
        mutex_lock(__context.mutex);
        name= __context.current ? __context.current->name : "NO CONTEXT";
        if(__context.current)
            ++__context.current->err;
        ++__context.err;
        spaces= (__context.level - 1) * 2;
        fprintf(stderr, "%-*sX %s\n", spaces, "", name);
        fprintf(stderr, "%-*sX  assertion: %s\n", spaces, "", assert);
        fprintf(stderr, "%-*sX         at: %s:%d\n", spaces, "", _basename(file), line);
        fprintf(stderr, "%-*sX     reason: ", spaces, "");
        va_start (ap, msg);
        vfprintf(stderr, msg, ap);
        va_end(ap);
        fprintf(stderr, "\n");
        mutex_unlock(__context.mutex);
        imp_testRaiseError();
    }
    return result;
}

static void imp_testBegin(const char *name)
{
    test_context_t *context;
    mutex_lock(__context.mutex);
    context= calloc(1, sizeof(test_context_t));
    context->parent= __context.current;
    context->name= name;
    context->t0= clock();
    
    if(__context.current && !__context.current->printed) {
        fprintf(stdout, "%-*s+ %s\n", (__context.level - 1) * 2, "", __context.current->name);
        __context.current->printed = 1;
    }
    __context.current = context;
    ++__context.level;
    mutex_unlock(__context.mutex);
}

static void imp_testError(int err)
{
    if(!err) return;
    mutex_lock(__context.mutex);
    if(__context.current)
        __context.current->err += err;
    __context.err += err;
    mutex_unlock(__context.mutex);
    imp_testRaiseError();
}

static int imp_testEnd(const char *name)
{
    int err; test_context_t *context;
    mutex_lock(__context.mutex);
    context= __context.current;
    if(!context) {
        fprintf(stderr, "Trying to exit test context while none are open\n");
        err= 1; }
    else if(strcmp(name, context->name)) {
        fprintf(stderr, "Trying to exit %s, while the exit of %s were expected\n", name, context->name);
        err= 1; }
    else {
        double seconds;
        __context.current= context->parent;
        if(__context.current)
            __context.current->err += context->err;
        --__context.level;
        seconds= (double)(clock()-context->t0)/CLOCKS_PER_SEC;
        err= context->err;
        fprintf(stdout, "%-*s- %-*s validate: %s (%.3f s)\n", __context.level * 2, "", __testPadding - __context.level * 2, name, err ? "FAIL" : "PASS", seconds);
        free(context);
    }
    mutex_unlock(__context.mutex);
    return err;
}

static int imp_testRun(const char *name, void *test)
{
    imp_testBegin(name);
    imp_testError(((int(*)())test)());
    return imp_testEnd(name);
}

int bindFct(dl_handle_t handle, const char *name, void * imp)
{
    void *fct;
    if(!(fct= dlsym(handle, name))) {
        fprintf(stderr, "Unable to find symbol %s", name);
    }
    else {
        *(void **)fct= imp;
    }
    return fct != 0;
}

int testModule(const char * module, int argc, const char * argv[])
{
    int err= 0; dl_handle_t testLib;
    char path[strlen(__prefix) + strlen(module) + strlen(__suffix)];
    strcpy(path, __prefix);
    strcpy(path + strlen(__prefix), module);
    strcpy(path + strlen(__prefix) + strlen(module), __suffix);
    printf("Loading tests for %s (%s)\n", module, path);
    
    testLib = dlopen(path, RTLD_LAZY);
    if(!testLib) {
        printf("Unable to load lib %s\n", path);
        ++err;
    }
    else {
        if(bindFct(testLib, "testBegin",  imp_testBegin)
           && bindFct(testLib, "testEnd",    imp_testEnd)
           && bindFct(testLib, "testAssert", imp_testAssert)
           && bindFct(testLib, "testRun",    imp_testRun)) {
            void *runTests, *dependencies;
            if((runTests= dlsym(testLib, "runTests"))) {
                imp_testsStart(module);
                if((dependencies= dlsym(testLib, "testDependencies"))) {
                    const char **dependency;
                    for(dependency= dependencies; *dependency; ++dependency) {
                        testModule(*dependency, argc, argv);
                    }
                }
                imp_testBegin(module);
                ((runtests_fct_t)runTests)(argc, argv);
                imp_testEnd(module);
                err+= imp_testsFinish(module);
            }
        }
        else {
            ++err;
        }
        dlclose(testLib);
    }
    return err;
}

int test(int argc, const char * argv[]) {
    int err= 0, argi;
    mutex_init(__context.mutex);
    for(argi= 1; argi < argc; ++argi) {
        err += testModule(argv[argi], argc, argv);
    }
    mutex_delete(__context.mutex);
    return err;
}

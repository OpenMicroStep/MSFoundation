//
//  MSTests.h
//  MSFoundation
//
//  Created by Vincent Rouillé on 27/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#ifndef MSFoundation_MSTests_h
#define MSFoundation_MSTests_h

typedef int test_result_t;
typedef test_result_t(test_method_t)();

typedef const struct {
    char *name;
    test_method_t *test;
} test_t;

typedef const struct {
    char *name;
    test_t tests[];
} test_suite_t;

// Define dependencies
//   BEGIN_DEPENDENCIES
//     ADD_DEPENDENCY(MODULE_NAME)
//     ...
//   END_DEPENDENCIES
#define BEGIN_DEPENDENCIES \
const char* parentTestsList[] = {

#define ADD_DEPENDENCY(NAME) \
    # NAME,

#define END_DEPENDENCIES \
    0 \
};

// Define test suites
//   BEGIN_TESTSUITES
//     ADD_TESTSUITE(SUITENAME)
//     ...
//   END_TESTSUITES
#define BEGIN_TESTSUITES \
const test_suite_t* testSuitesList[] = {

#define ADD_TESTSUITE(NAME) \
    &testSuite ## NAME,

#define END_TESTSUITES \
    0 \
};

// Define test suite
//   BEGIN_TESTSUITE(NAME)
//     ADD_TEST(TESTNAME)
//     ...
//   END_TESTSUITE
#define BEGIN_TESTSUITE(NAME) \
test_suite_t testSuite ## NAME = { \
    #NAME, \
    { 

#define ADD_TEST(NAME) \
        {#NAME, test_ ## NAME },

#define END_TESTSUITE \
        0 \
    } \
};

// Implement a new test:
//   BEGIN_TEST(NAME)
//     ...
//   END_TEST
#define BEGIN_TEST(NAME) \
static test_result_t test_ ## NAME () {

#define END_TEST \
    return 0; \
}

// Declare tests (.h)
#define DECLARE_TESTEXPORTS \
    LIBEXPORT const test_suite_t** testSuites(); \
    LIBEXPORT const char** parentTests(); \
    extern const test_suite_t* testSuitesList[]; \
    extern const char* parentTestsList[];

#define DECLARE_TESTSUITE(NAME) \
    extern test_suite_t testSuite ## NAME;
#endif

// Exports tests (.c)
#define EXPORT_TESTS \
    const test_suite_t **testSuites() { return testSuitesList; } \
    const char** parentTests()       { return parentTestsList; }

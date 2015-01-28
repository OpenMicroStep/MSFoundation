/*!md

# MSTests

## Usages

### Implement a new test

`TEST_FCT_BEGIN(NAME)` create the entry point of a new function `int test##NAME()`.
Once you have defined your test, you must finish the function by `TEST_FCT_END(NAME)`.
You can use `TEST_FCT(NAME)` to get the function name.
You can directly use return without expecting any breakage of test context tree.

`TEST_INL_BEGIN(NAME)` start a new test context in an inline approch, so you can use it inside a function. 
As for `TEST_FCT_BEGIN` you must use `TEST_INL_END(NAME)` to quit this context.
You can't use return inside such context, as it would break test context tree.

Example with inlining of test contexts

    TEST_FCT_BEGIN(NSObject)
      TEST_INL_BEGIN(init)
        ASSERT_EQUALS([obj init], obj, "NSObject init must return itself: %p != %p");
        ASSERT_EQUALS([obj retainCount], 1, "NSObject new object must have a retain count of %2$d, got %1$d");
      TEST_INL_END(init)
      TEST_INL_BEGIN(retain)
        ASSERT_EQUALS([obj retain], obj, "NSObject retain must return itself: %p != %p");
        ASSERT_EQUALS([obj retainCount], 2, "NSObject new object + retain must have a retain count of %2$d, got %1$d");
      TEST_INL_END(retain)
    TEST_FCT_END(NSObject)

Same example without inlining of test contexts

    TEST_FCT_BEGIN(init)
      ASSERT_EQUALS([obj init], obj, "NSObject init must return itself: %p != %p");
      ASSERT_EQUALS([obj retainCount], 1, "NSObject new object must have a retain count of %2$d, got %1$d");
    TEST_FCT_END(init)
 
    TEST_FCT_BEGIN(retain)
      ASSERT_EQUALS([obj retain], obj, "NSObject retain must return itself: %p != %p");
      ASSERT_EQUALS([obj retainCount], 2, "NSObject new object + retain must have a retain count of %2$d, got %1$d");
    TEST_FCT_END(retain)
 
    TEST_FCT_BEGIN(NSObject)
      TEST_FCT(init);
      TEST_FCT(retain);
    TEST_FCT_END(NSObject)

 
### Define dependencies
    
    BEGIN_DEPENDENCIES
      ADD_DEPENDENCY(MSFoundation)
    END_DEPENDENCIES
 
### Assertions


*/

#ifndef MSFoundation_MSTests_h
#define MSFoundation_MSTests_h

// Write tests
#define TEST_FCT(NAME) test ## NAME()
#define TEST_FCT_DECLARE(NAME) int TEST_FCT(NAME)

#define TEST_FCT_BEGIN(NAME) \
    static int imp_test ## NAME() {

#define TEST_FCT_END(NAME) \
        return 0; \
    } \
    int TEST_FCT(NAME) { \
        return testRun(#NAME, imp_test ## NAME); \
    }

#define TEST_INL_BEGIN(NAME) { testBegin(#NAME); {
#define TEST_INL_END(NAME) } testEnd(#NAME); }

// Exports tests
#define BEGIN_DEPENDENCIES \
    LIBEXPORT const char* testDependencies[] = {
#define ADD_DEPENDENCY(NAME) \
        # NAME,
#define END_DEPENDENCIES \
        0 \
    };

#define EXPORT_TESTS_BASE \
    testAssert_t testAssert = 0; \
    testBegin_t testBegin = 0; \
    testEnd_t testEnd = 0; \
    testRun_t testRun = 0;

#define TESTS_MAIN_BEGIN \
    LIBEXPORT int runTests(int argc, char *argv[]) \
    {

#define TESTS_MAIN_END \
        return 0; \
    }

// Tests
#define ASSERT(TEST, MSG, ...)           testAssert((TEST), #TEST, __FILE__, __LINE__, MSG, ## __VA_ARGS__)
#define ASSERT_OP(A, OP, B, MSG, ...)    ({ __typeof__(A) __a= (A); __typeof__(B) __b= (B); testAssert((__a OP __b), #A " " #OP " " #B, __FILE__, __LINE__, MSG, ## __VA_ARGS__, __a, __b); })
#define ASSERT_SEL0(A, SEL, MSG, ...)    ({ __typeof__(A) __a= (A); testAssert(([__a SEL], [#A " " #SEL], __FILE__, __LINE__, MSG, ## __VA_ARGS__, __a); })
#define ASSERT_SEL1(A, SEL, B, MSG, ...) ({ __typeof__(A) __a= (A); __typeof__(B) __b= (B); testAssert(([__a SEL: __b], [#A " " #SEL ": " #B], __FILE__, __LINE__, MSG, ## __VA_ARGS__, __a, __b); })
#define ASSERT_EQUALS(A, B, MSG, ...)    ASSERT_OP(A, == ,B, MSG, ## __VA_ARGS__)
#define ASSERT_ISEQUAL(A, B, MSG, ...)   ASSERT_SEL1(A, isEqual, B, MSG, ## __VA_ARGS__)

typedef int (*testAssert_t)(int result, const char *assert, const char *file, int line, const char *msg, ...);
typedef void (*testBegin_t)(const char *name);
typedef int (*testEnd_t)(const char *name);
typedef int (*testRun_t)(const char *name, void *test);

LIBEXPORT testAssert_t testAssert;
LIBEXPORT testBegin_t testBegin;
LIBEXPORT testEnd_t testEnd;
LIBEXPORT testRun_t testRun;

#endif

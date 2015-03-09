/*!md

# MSTests

## Usages

### Implement a new test

### Define dependencies
    
### Assertions

*/

#ifndef MSFoundation_MSTests_h
#define MSFoundation_MSTests_h

#define EXTERN_TESTS_BASE \
  testAssert_t testAssert= 0;

// Tests
#define _ASSERT_STRING(x) #x
#define ASSERT(TEST, MSG...)            testAssert(!!(TEST), _ASSERT_STRING(TEST), __FILE__, __LINE__, MSG)
#define ASSERT_OP(A, OP, B, MSG...)     ({ __typeof__(A) __a= (A); __typeof__(B) __b= (B); testAssert((__a OP __b), #A " " #OP " " #B, __FILE__, __LINE__, MSG, __a, __b); })
#define ASSERT_SEL0(A, SEL, MSG...)     ({ __typeof__(A) __a= (A); testAssert([__a SEL], [#A " " #SEL], __FILE__, __LINE__, MSG, __a); })
#define ASSERT_SEL1(A, SEL, B, MSG...)  ({ __typeof__(A) __a= (A); __typeof__(B) __b= (B); testAssert([__a SEL: __b], [#A " " #SEL ": " #B], __FILE__, __LINE__, MSG, __a, __b); })
#define ASSERT_ISEQUAL(A, B, MSG...)    ({ __typeof__(A) __a= (A); __typeof__(B) __b= (B); testAssert(ISEQUAL(__a, __b), "ISEQUAL("#A", "#B") => " _ASSERT_STRING(ISEQUAL(A, B)), __FILE__, __LINE__, MSG, __a, __b); })
#define ASSERT_ISNOTEQUAL(A, B, MSG...) ({ __typeof__(A) __a= (A); __typeof__(B) __b= (B); testAssert(!ISEQUAL(__a, __b), "!ISEQUAL("#A", "#B") => " _ASSERT_STRING(!ISEQUAL(A, B)), __FILE__, __LINE__, MSG, __a, __b); })
#define ASSERT_EQUALS(A, B, MSG...)     ASSERT_OP(A, == ,B, ## MSG)

typedef int (*testAssert_t)(int result, const char *assert, const char *file, int line, const char *msg, ...);

LIBEXPORT testAssert_t testAssert;

typedef struct struct_test {
  char *name;
  struct struct_test *subTests;
  int (*leafFunction)(void);
  int err;
  clock_t c0,c1;
  long    t0,t1;
  }
test_t;
#define INTITIALIZE_TEST_T_END 0,0,0,0,0

int test(int argc, const char * argv[]);

#endif

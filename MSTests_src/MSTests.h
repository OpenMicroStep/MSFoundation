/*!md

# MSTests

## Usages

### Implement a new test

### Define dependencies
    
### Assertions

*/

#ifndef MSFoundation_MSTests_h
#define MSFoundation_MSTests_h

#define EXTERN_TESTS_BASE testCtx_f TCtx= 0; testAdvise_f TAdvise= 0;

#define __TCTX(where, assert) TCtx(where,assert,CTX_FCT)
#define __TASSERT(where, test, assert, msg...) (!!(test) ? 1 : (TAdvise(__TCTX(where,assert), msg), 0))

#define TASSERT(W, TEST, MSG...) ({ __typeof__(TEST) __t= (TEST); __TASSERT(W, __t, #TEST, MSG, __t); })

#define TASSERT_OP(W, A, OP, B, MSG...) ({ __typeof__(A) __a= (A); __typeof__(B) __b= (B); \
  __TASSERT(W, (__a OP __b), #A" "#OP" "#B,    MSG, __a, __b); })
#define TASSERT_F( W,  F, A, B, MSG...) ({ __typeof__(A) __a= (A); __typeof__(B) __b= (B); \
  __TASSERT(W, F(__a, __b) , #F"("#A", "#B")", MSG, __a, __b); })
#define TASSERT_S( W,  A, S, B, MSG...) ({ __typeof__(A) __a= (A); __typeof__(B) __b= (B); \
  __TASSERT(W, [__a S __b] , "["#A" "#S" "#B"]", MSG, __a, __b); })

#define TASSERT_EQUALS(    W, A, B, MSG...) TASSERT_OP(W, A, == ,B, MSG)

#define TASSERT_ISEQUAL(   W, A, B, MSG...) TASSERT_F(W,  ISEQUAL, A, B, MSG)
#define TASSERT_ISNOTEQUAL(W, A, B, MSG...) TASSERT_F(W, !ISEQUAL, A, B, MSG)

typedef struct struct_test test_t;
struct struct_test {
  char *name;
  test_t *subTests;
  void (*leafFunction)(test_t*);
  clock_t c0,c1;
  long    t0,t1;
  int err;
  CArray *errCtxs;
  };
#define INTITIALIZE_TEST_T_END 0,0,0,0,0,NULL

typedef CDictionary* (*testCtx_f)(test_t *t, const char *assert,
  const char *file, int line, const char *function, const char *method);
typedef CDictionary* (*testAdvise_f)(mutable CDictionary* ctx, const char *msgFmt, ...);

LIBEXPORT testCtx_f    TCtx;
LIBEXPORT testAdvise_f TAdvise;

#endif

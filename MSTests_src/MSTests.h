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

#define TASSERT_OP_STR(W, A, OP, B) TASSERT_OP(W, A, OP ,B, "!(%s "#OP" %s)")
#define TASSERT_OP_PTR(W, A, OP, B) TASSERT_OP(W, A, OP ,B, "!(%p "#OP" %p)")
#define TASSERT_OP_LLD(W, A, OP, B) TASSERT_OP(W, A, OP ,B, "!(%lld "#OP" %lld)", (long long)__a, (long long)__b)
#define TASSERT_OP_LLU(W, A, OP, B) TASSERT_OP(W, A, OP ,B, "!(%llu "#OP" %llu)", (unsigned long long)__a, (unsigned long long)__b)
#define TASSERT_OP_OBJ(W, A, OP, B) TASSERT_OP(W, A, OP, B, "!(%s "#OP" %s)", [[__a description] UTF8String],[[__b description] UTF8String])
#define TASSERT_EQUALS_STR(   W, A, B) TASSERT_F(W, 0 == strcmp,A,B, "\"%s\" != \"%s\"", __a, __b)
#define TASSERT_EQUALS_PTR(   W, A, B) TASSERT_OP(W, A, == ,B, "%p != %p")
#define TASSERT_EQUALS_DBL(   W, A, B) TASSERT_OP(W, A, == ,B, "%f != %f", (double)__a, (double)__b)
#define TASSERT_EQUALS_LLD(   W, A, B) TASSERT_OP(W, A, == ,B, "%lld != %lld", (long long)__a, (long long)__b)
#define TASSERT_EQUALS_LLU(   W, A, B) TASSERT_OP(W, A, == ,B, "%llu != %llu", (unsigned long long)__a, (unsigned long long)__b)
#define TASSERT_EQUALS_OBJ(   W, A, B) TASSERT_F( W, ISEQUAL,A,B, "![%s isEqual:%s]",[[__a description] UTF8String],[[__b description] UTF8String])
#define TASSERT_NOTEQUALS_STR(W, A, B) TASSERT_F(W, 0 != strcmp,A,B, "\"%s\" != \"%s\"", __a, __b)
#define TASSERT_NOTEQUALS_PTR(W, A, B) TASSERT_OP(W, A, != ,B, "%p == %p")
#define TASSERT_NOTEQUALS_DBL(W, A, B) TASSERT_OP(W, A, != ,B, "%f == %f", (double)__a, (double)__b)
#define TASSERT_NOTEQUALS_LLD(W, A, B) TASSERT_OP(W, A, != ,B, "%lld == %lld", (long long)__a, (long long)__b)
#define TASSERT_NOTEQUALS_LLU(W, A, B) TASSERT_OP(W, A, != ,B, "%llu == %llu", (unsigned long long)__a, (unsigned long long)__b)
#define TASSERT_NOTEQUALS_OBJ(W, A, B) TASSERT_F( W,!ISEQUAL,A,B, "[%s isEqual:%s]",[[__a description] UTF8String],[[__b description] UTF8String])
#define TASSERT_NEAR_DBL(     W, A, B, L) ({ double __a= (A); double __b= (B); double __d= __a - __b; \
  __TASSERT(W, -L < __d && __d < L, #A" ~= "#B, "!(%f ~= %f), diff=abs(%f) > %f", __a, __b, __d, (double)L); })
#define TASSERT_NOTNEAR_DBL(  W, A, B, L) ({ double __a= (A); double __b= (B); double __d= __a - __b; \
  __TASSERT(W, __d > L || __d < -L, #A" !~= "#B, "%f ~= %f, diff=abs(%f) < %f", __a, __b, __d, (double)L); })

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

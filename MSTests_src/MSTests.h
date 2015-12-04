#ifndef MSFoundation_MSTests_h
#define MSFoundation_MSTests_h

#define EXTERN_TESTS_BASE          \
  testFile_f TFile= 0;             \
  testCtx_f TCtx= 0;               \
  testAdvise_f TAdvise= 0;         \
  testSharedCtx_f TSharedCtx= 0;   \
  LIBEXPORT testdef_t RootTests[];

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
#define TASSERT_NIL_OBJ(   W, A) TASSERT_OP( W, A, ==, nil, "%s == nil",[[__a description] UTF8String])

#define _TASSERT_EQUALS_STR_S(   W, A, B, S, ...) TASSERT_F(W, 0 == strcmp,A,B, "\"%s\" != \"%s\"" S, __a, __b, ##__VA_ARGS__)
#define _TASSERT_EQUALS_PTR_S(   W, A, B, S, ...) TASSERT_OP(W, A, == ,B, "%p != %p" S, ##__VA_ARGS__)
#define _TASSERT_EQUALS_DBL_S(   W, A, B, S, ...) TASSERT_OP(W, A, == ,B, "%f != %f" S, (double)__a, (double)__b, ##__VA_ARGS__)
#define _TASSERT_EQUALS_LLD_S(   W, A, B, S, ...) TASSERT_OP(W, A, == ,B, "%lld != %lld" S, (long long)__a, (long long)__b, ##__VA_ARGS__)
#define _TASSERT_EQUALS_LLU_S(   W, A, B, S, ...) TASSERT_OP(W, A, == ,B, "%llu != %llu" S, (unsigned long long)__a, (unsigned long long)__b, ##__VA_ARGS__)
#define _TASSERT_EQUALS_OBJ_S(   W, A, B, S, ...) TASSERT_F( W, ISEQUAL,A,B, "![%s isEqual:%s]" S,[[__a description] UTF8String],[[__b description] UTF8String], ##__VA_ARGS__)
#define _TASSERT_EQUALS_SEL_S(   W, A, B, S, ...) TASSERT_F( W, sel_isEqual,A,B, "@selector(%s) != @selector(%s)" S, sel_getName(__a), sel_getName(__b), ##__VA_ARGS__)
#define _TASSERT_NOTEQUALS_STR_S(W, A, B, S, ...) TASSERT_F(W, 0 != strcmp,A,B, "\"%s\" == \"%s\"" S, __a, __b, ##__VA_ARGS__)
#define _TASSERT_NOTEQUALS_PTR_S(W, A, B, S, ...) TASSERT_OP(W, A, != ,B, "%p == %p" S, ##__VA_ARGS__)
#define _TASSERT_NOTEQUALS_DBL_S(W, A, B, S, ...) TASSERT_OP(W, A, != ,B, "%f == %f" S, (double)__a, (double)__b, ##__VA_ARGS__)
#define _TASSERT_NOTEQUALS_LLD_S(W, A, B, S, ...) TASSERT_OP(W, A, != ,B, "%lld == %lld" S, (long long)__a, (long long)__b, ##__VA_ARGS__)
#define _TASSERT_NOTEQUALS_LLU_S(W, A, B, S, ...) TASSERT_OP(W, A, != ,B, "%llu == %llu" S, (unsigned long long)__a, (unsigned long long)__b, ##__VA_ARGS__)
#define _TASSERT_NOTEQUALS_OBJ_S(W, A, B, S, ...) TASSERT_F( W,!ISEQUAL,A,B, "[%s isEqual:%s]" S,[[__a description] UTF8String],[[__b description] UTF8String], ##__VA_ARGS__)
#define _TASSERT_NOTEQUALS_SEL_S(W, A, B, S, ...) TASSERT_F( W,!sel_isEqual,A,B, "@selector(%s) == @selector(%s)" S, sel_getName(__a), sel_getName(__b), ##__VA_ARGS__)

#define TASSERT_EQUALS_STR_S(   W, A, B, MSG...) _TASSERT_EQUALS_STR_S(   W, A, B, ": " MSG)
#define TASSERT_EQUALS_PTR_S(   W, A, B, MSG...) _TASSERT_EQUALS_PTR_S(   W, A, B, ": " MSG)
#define TASSERT_EQUALS_DBL_S(   W, A, B, MSG...) _TASSERT_EQUALS_DBL_S(   W, A, B, ": " MSG)
#define TASSERT_EQUALS_LLD_S(   W, A, B, MSG...) _TASSERT_EQUALS_LLD_S(   W, A, B, ": " MSG)
#define TASSERT_EQUALS_LLU_S(   W, A, B, MSG...) _TASSERT_EQUALS_LLU_S(   W, A, B, ": " MSG)
#define TASSERT_EQUALS_OBJ_S(   W, A, B, MSG...) _TASSERT_EQUALS_OBJ_S(   W, A, B, ": " MSG)
#define TASSERT_EQUALS_SEL_S(   W, A, B, MSG...) _TASSERT_EQUALS_SEL_S(   W, A, B, ": " MSG)
#define TASSERT_NOTEQUALS_STR_S(W, A, B, MSG...) _TASSERT_NOTEQUALS_STR_S(W, A, B, ": " MSG)
#define TASSERT_NOTEQUALS_PTR_S(W, A, B, MSG...) _TASSERT_NOTEQUALS_PTR_S(W, A, B, ": " MSG)
#define TASSERT_NOTEQUALS_DBL_S(W, A, B, MSG...) _TASSERT_NOTEQUALS_DBL_S(W, A, B, ": " MSG)
#define TASSERT_NOTEQUALS_LLD_S(W, A, B, MSG...) _TASSERT_NOTEQUALS_LLD_S(W, A, B, ": " MSG)
#define TASSERT_NOTEQUALS_LLU_S(W, A, B, MSG...) _TASSERT_NOTEQUALS_LLU_S(W, A, B, ": " MSG)
#define TASSERT_NOTEQUALS_OBJ_S(W, A, B, MSG...) _TASSERT_NOTEQUALS_OBJ_S(W, A, B, ": " MSG)
#define TASSERT_NOTEQUALS_SEL_S(W, A, B, MSG...) _TASSERT_NOTEQUALS_SEL_S(W, A, B, ": " MSG)

#define TASSERT_EQUALS_STR(   W, A, B) _TASSERT_EQUALS_STR_S(   W, A, B, "")
#define TASSERT_EQUALS_PTR(   W, A, B) _TASSERT_EQUALS_PTR_S(   W, A, B, "")
#define TASSERT_EQUALS_DBL(   W, A, B) _TASSERT_EQUALS_DBL_S(   W, A, B, "")
#define TASSERT_EQUALS_LLD(   W, A, B) _TASSERT_EQUALS_LLD_S(   W, A, B, "")
#define TASSERT_EQUALS_LLU(   W, A, B) _TASSERT_EQUALS_LLU_S(   W, A, B, "")
#define TASSERT_EQUALS_OBJ(   W, A, B) _TASSERT_EQUALS_OBJ_S(   W, A, B, "")
#define TASSERT_EQUALS_SEL(   W, A, B) _TASSERT_EQUALS_SEL_S(   W, A, B, "")
#define TASSERT_NOTEQUALS_STR(W, A, B) _TASSERT_NOTEQUALS_STR_S(W, A, B, "")
#define TASSERT_NOTEQUALS_PTR(W, A, B) _TASSERT_NOTEQUALS_PTR_S(W, A, B, "")
#define TASSERT_NOTEQUALS_DBL(W, A, B) _TASSERT_NOTEQUALS_DBL_S(W, A, B, "")
#define TASSERT_NOTEQUALS_LLD(W, A, B) _TASSERT_NOTEQUALS_LLD_S(W, A, B, "")
#define TASSERT_NOTEQUALS_LLU(W, A, B) _TASSERT_NOTEQUALS_LLU_S(W, A, B, "")
#define TASSERT_NOTEQUALS_OBJ(W, A, B) _TASSERT_NOTEQUALS_OBJ_S(W, A, B, "")
#define TASSERT_NOTEQUALS_SEL(W, A, B) _TASSERT_NOTEQUALS_SEL_S(W, A, B, "")
#define TASSERT_NEAR_DBL(     W, A, B, L) ({ double __a= (A); double __b= (B); double __d= __a - __b; \
  __TASSERT(W, -L < __d && __d < L, #A" ~= "#B, "!(%f ~= %f), diff=abs(%f) > %f", __a, __b, __d, (double)L); })
#define TASSERT_NOTNEAR_DBL(  W, A, B, L) ({ double __a= (A); double __b= (B); double __d= __a - __b; \
  __TASSERT(W, __d > L || __d < -L, #A" !~= "#B, "%f ~= %f, diff=abs(%f) < %f", __a, __b, __d, (double)L); })

#define TFILE_PATH(W, PATH) TFile(W, PATH);
#define TFILE_NSPATH(W, NSPATH) [NSString stringWithUTF8String:TFile(W, [(NSPATH) UTF8String])]

#define TSHAREDCONTEXT_GET(W) ({ void *context; TSharedCtx(W, &context, NULL); context; })
#define TSHAREDCONTEXT_SET(W, V) ({ void *context= (V); TSharedCtx(W, NULL, &context); })

typedef struct struct_test test_t;
typedef struct struct_testdef testdef_t;
struct struct_testdef {
  char *name;
  testdef_t *subTests;
  void (*leafFunction)(test_t*);
  void (*prepareFunction)(test_t*);
  void (*freeFunction)(test_t*);
};

typedef CDictionary* (*testCtx_f)(test_t *t, const char *assert,
  const char *file, int line, const char *function, const char *method);
typedef CDictionary* (*testAdvise_f)(mutable CDictionary* ctx, const char *msgFmt, ...);
typedef const char * (*testFile_f)(test_t *t, const char *relativePath);
typedef void (*testSharedCtx_f)(test_t *t, void **getcontext, void **setcontext);
typedef testdef_t* (*testPrepare_f)(test_t *t, testdef_t *definitions, void **context);
typedef void (*testRun_f)(test_t *t, void (*testfn)(test_t*), void *context);
typedef void (*testFree_f)(test_t *t, testdef_t *definitions, void *context);

LIBEXPORT testFile_f      TFile;
LIBEXPORT testSharedCtx_f TSharedCtx;
LIBEXPORT testCtx_f       TCtx;
LIBEXPORT testAdvise_f    TAdvise;

// Hooks:
// LIBEXPORT testdef_t* TPrepare(test_t *t, testdef_t *definitions) { return definitions; }
// LIBEXPORT void TRun(test_t *t, void (*testfn)(test_t*)) { }
// LIBEXPORT void TFree(test_t *t, testdef_t *definitions) { }

#endif

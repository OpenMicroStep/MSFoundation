// mscore_ctraverse_validate.c, ecb, 150505

#include "mscore_validate.h"

static void traverse(test_t *test)
  {
  CArray *a; CDictionary *ctx, *all, *d, *dd; NSUInteger n;
  const CString *s,*x; CBuffer *b;
  a= CCreateArray(1);
  CArrayAddObject(a, (id)a);
  ctx= CCreateDictionary(0);
  CTraversePrepare((id)a, SUBS, ctx);
  all= (CDictionary*)CDictionaryObjectForKey(ctx, (id)KAll);
  s= CDictionaryRetainedDescription((id)CDictionaryObjectForKey(all,(id)KRoot));
  b= CCreateBufferWithString(s, NSUTF8StringEncoding);
  TASSERT_EQUALS(test, CDictionaryCount(all), 1, "%s", CBufferCString(b));
  RELEASE(b); RELEASE(s);
  n= (NSUInteger)CDictionaryObjectForKey(all, (id)test);
  TASSERT_EQUALS(test, n, 0, "%llu", n);
  n= (NSUInteger)CDictionaryObjectForKey(all, (id)a);
  TASSERT_EQUALS(test, n, 2, "%llu", n);

  x= CSCreate("1:: (<<1>>)");
  s= CCreateString(0);
  CDescribe((id)a, (id)s, 0, ctx);
  b= CCreateBufferWithString(s, NSUTF8StringEncoding);
  TASSERT_ISEQUAL(test, s, x, "%s", CBufferCString(b));
  RELEASE(x); RELEASE(b); RELEAZEN(s); RELEAZEN(ctx);

  x= CSCreate("1:: (2:: {\n    all: <<1>>;\n    done: <<2>>;})");
  d= CCreateDictionary(2);
  CDictionarySetObjectForKey(d, (id)a, (id)KAll);
  CDictionarySetObjectForKey(d, (id)d, (id)KDone);
  CArrayReplaceObjectAtIndex(a, (id)d, 0);
  s= CCreateDescription((id)a);
  b= CCreateBufferWithString(s, NSUTF8StringEncoding);
  TASSERT_ISEQUAL(test, s, x, "%s", CBufferCString(b));
  RELEASE(x); RELEASE(b); RELEAZEN(s);

  x= CSCreate("1:: (2:: {\n    all: {\n      indice: <<1>>;};\n    done: <<2>>;})");
  dd= CCreateDictionary(1);
  CDictionarySetObjectForKey(dd, (id)a , (id)KIndice);
  CDictionarySetObjectForKey(d , (id)dd, (id)KAll);
  s= CCreateDescription((id)a);
  b= CCreateBufferWithString(s, NSUTF8StringEncoding);
  TASSERT_ISEQUAL(test, s, x, "%s", CBufferCString(b));
  RELEASE(x); RELEASE(b); RELEAZEN(s);
  RELEASE(d); RELEASE(dd);

  RELEASE(a);
  }

testdef_t mscore_ctraverse[]= {
  {"traverse",NULL,traverse},
  {NULL}
};

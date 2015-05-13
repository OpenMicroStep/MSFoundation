// mscore_cdictionary_validate.c, ecb, 130911

#include "mscore_validate.h"

static void cdictionary_create(test_t *test)
  {
  CDictionary *c,*d,*m; id k,o,x; int i;
  // c= {}, d= {}
  c= (CDictionary*)MSCreateObjectWithClassIndex(CDictionaryClassIndex);
  d= CCreateDictionary(0);
  TASSERT_EQUALS(test, RETAINCOUNT(c), 1, "A1-Bad retain count: %lu != %lu");
  TASSERT_EQUALS(test, RETAINCOUNT(d), 1, "A2-Bad retain count: %lu != %lu");
  TASSERT(test, CDictionaryEquals(c, d), "A3 c & d are not equals");
  RELEASE(d);
  // c= {key1: obj1}, d= {key1: key1}
  k= (id)CCreateBufferWithBytes("key1", 4);
  o= (id)CCreateBufferWithBytes("obj1", 4);
  CDictionarySetObjectForKey(c, o, k);
  TASSERT_EQUALS(test, RETAINCOUNT(k), 1, "A10-Bad retain count: %lu != %lu");
  TASSERT_EQUALS(test, RETAINCOUNT(o), 2, "A11-Bad retain count: %lu != %lu");
  d= CCreateDictionaryWithObjectsAndKeys(&k, &k, 1);
  TASSERT_EQUALS(test, RETAINCOUNT(d), 1, "A12-Bad retain count: %lu != %lu");
  TASSERT_EQUALS(test, RETAINCOUNT(k), 2, "A13-Bad retain count: %lu != %lu");
  TASSERT(test, !CDictionaryEquals(c, d), "A14 c & d are equals");
  // c= {key1: obj1}, d= {key1: obj1}
  CDictionarySetObjectForKey(d, o, k);
  TASSERT_EQUALS(test, RETAINCOUNT(k), 1, "A15-Bad retain count: %lu != %lu");
  TASSERT_EQUALS(test, RETAINCOUNT(o), 3, "A16-Bad retain count: %lu != %lu");
  TASSERT(test, CDictionaryEquals(c, d), "A17 c & d are not equals");
  m= CCreateDictionaryWithDictionaryCopyItems(c, NO);
  RELEASE(d); d= m;
  x= (id)CCreateBufferWithBytes("a key", 5);
  CDictionarySetObjectForKey(d, o, x);
  TASSERT_EQUALS(test, CDictionaryCount(d), 2, "A20-Bad count: %lu != %lu");
  TASSERT(test, !CDictionaryEquals(c, d), "A21 c & d are equals");
  CDictionarySetObjectForKey(d, nil, x);
  TASSERT(test, CDictionaryEquals(c, d), "A22 c & d are not equals");
  for (i= 0; i<100; i++) {
    CBufferAppendByte((CBuffer*)x, (MSByte)i);
    CDictionarySetObjectForKey(d, o, x);}
  TASSERT_EQUALS(test, RETAINCOUNT(o), 103, "A23-Bad count: %lu != %lu");
  RELEASE(x);
  RELEASE(c);
  TASSERT_EQUALS(test, RETAINCOUNT(d), 1, "A41-Bad count: %lu != %lu");
  RELEASE(d);
  TASSERT_EQUALS(test, RETAINCOUNT(k), 1, "A42-Bad count: %lu != %lu");
  TASSERT_EQUALS(test, RETAINCOUNT(o), 1, "A43-Bad count: %lu != %lu");
  RELEASE(k);
  RELEASE(o);
  }

static void cdictionary_enum(test_t *test)
  {
  CDictionary *c,*d; id ks[1000],os[1000],k,o; int i,n,fd; CDictionaryEnumerator de;
  k= (id)CCreateBufferWithBytes("a key", 5);
  o= (id)CCreateBufferWithBytes("an object", 9);
  for (i=0; i<1000; i++) {
    CBufferAppendByte((CBuffer*)k, (MSByte)i); ks[i]= COPY(k);
    CBufferAppendByte((CBuffer*)o, (MSByte)i); os[i]= COPY(o);}
  RELEASE(k);
  RELEASE(o);
  d= CCreateDictionaryWithObjectsAndKeys(os, ks, 1000);
  TASSERT_EQUALS(test, CDictionaryCount(d), 1000, "B1 Bad count: %lu",WLU(CDictionaryCount(d)));

  c= (CDictionary*)COPY((id)d);
  RELEASE(d);
  d= (CDictionary*)CDictionaryCopy((id)c);
  RELEASE(c);

  de= CMakeDictionaryEnumerator(d);
  TASSERT_EQUALS(test, de.dictionary, d, "Error");
  for (n= 0, fd= 0; (o= CDictionaryEnumeratorNextObject(&de)); n++) {
    k= CDictionaryEnumeratorCurrentKey(de);
    for (i= 0; i<1000; i++) {
      if (ISEQUAL(k, ks[i])) fd++;}
    TASSERT_EQUALS(test, fd, n+1, "B2 Bad fd: %lu %lu",WLI(fd),WLI(n));}
  TASSERT_EQUALS(test, n, 1000, "B3 Bad n: %lu",WLI(n));
  de= CMakeDictionaryEnumerator(d);
  for (n= 0, fd= 0; (k= (id)CDictionaryEnumeratorNextKey(&de)); n++) {
    o= CDictionaryEnumeratorCurrentObject(de);
    for (i= 0; i<1000; i++) {
      if (ISEQUAL(o, os[i])) fd++;}
    TASSERT_EQUALS(test, fd, n+1, "B4 Bad fd: %lu %lu",WLI(fd),WLI(n));}
  TASSERT_EQUALS(test, n, 1000, "B5 Bad n: %lu",WLI(n));
  for (i= 0; i<1000; i++) {
    RELEASE(ks[i]); RELEASE(os[i]);}
  RELEASE(d);
  }

static void cdictionary_ptrs(test_t *test)
  {
  }

static id hndl(void* arg)
  {return (id)3000;}
static void cdictionary_naturalsOrNotZero(test_t *test, BOOL notZero)
  {
  CDictionary *c; long i; CDictionaryEnumerator de; CArray *a;
  int type= notZero ? CDictionaryNaturalNotZero : CDictionaryNatural;
  NSUInteger first=      notZero ? 1 : 0;
  NSUInteger notAMarker= notZero ? 0 : NSNotFound;
  BOOL added; NSUInteger n;
  c= CCreateDictionaryWithOptions(100, type, type);
  CDictionarySetObjectForKey(c, (id)first, (id)first);
  TASSERT_EQUALS(test, CDictionaryObjectForKey(c, (id)first), (id)first, "bad natural 1 %lu %lu");
  for (i= 0; i<=1000; i++) CDictionarySetObjectForKey(c, (id)(first+1000-i), (id)(first+i));
  TASSERT_EQUALS(test, CDictionaryObjectForKey(c, (id)(first+0))   , (id)(first+1000), "bad natural 2 %lu %lu");
  TASSERT_EQUALS(test, CDictionaryObjectForKey(c, (id)(first+1))   , (id)(first+999) , "bad natural 3 %lu %lu");
  TASSERT_EQUALS(test, CDictionaryObjectForKey(c, (id)(first+200)) , (id)(first+800) , "bad natural 4 %lu %lu");
  TASSERT_EQUALS(test, CDictionaryObjectForKey(c, (id)(first+999)) , (id)(first+1)   , "bad natural 5 %lu %lu");
  TASSERT_EQUALS(test, CDictionaryObjectForKey(c, (id)(first+1000)), (id)(first+0)   , "bad natural 6 %lu %lu");
  TASSERT_EQUALS(test, CDictionaryObjectForKey(c, (id)(first+2000)), (id)notAMarker  , "bad natural 7 %lu %lu");
  de= CMakeDictionaryEnumerator(c);
  for (i= 0; CDictionaryEnumeratorNextKey(&de)!=(id)notAMarker; i++);
  TASSERT_EQUALS(test, i, 1001, "bad natural enumeration %lu != %lu");
  CDictionarySetObjectForKey(c, (id)notAMarker, (id)10);
  TASSERT_EQUALS(test, CDictionaryCount(c), 1000, "bad count %lu != %lu");
  // Test IfAbsent !added
  n= (NSUInteger)CDictionarySetObjectIfKeyAbsent(c, (id)2000, (id)(first+100), &added);
  TASSERT_EQUALS(test, n, first+900, "bad %lu != %lu");
  TASSERT_EQUALS(test, added,    NO, "bad %c != %c");
  TASSERT_EQUALS(test, CDictionaryCount(c), 1000, "bad count %lu != %lu");
  // Test IfAbsent added
  n= (NSUInteger)CDictionarySetObjectIfKeyAbsent(c, (id)2000, (id)2000, &added);
  TASSERT_EQUALS(test, n,    2000, "bad %lu != %lu");
  TASSERT_EQUALS(test, added, YES, "bad %c != %c");
  TASSERT_EQUALS(test, CDictionaryCount(c), 1001, "bad count %lu != %lu");
  // Test IfAbsent FromHandler !added
  n= (NSUInteger)CDictionarySetObjectFromHandlerIfKeyAbsent(c, hndl, NULL, (id)2000, &added);
  TASSERT_EQUALS(test, n,    2000, "bad %lu != %lu");
  TASSERT_EQUALS(test, added,  NO, "bad %c != %c");
  TASSERT_EQUALS(test, CDictionaryCount(c), 1001, "bad count %lu != %lu");
  // Test IfAbsent FromHandler added
  n= (NSUInteger)CDictionarySetObjectFromHandlerIfKeyAbsent(c, hndl, NULL, (id)3000, &added);
  TASSERT_EQUALS(test, n,    3000, "bad %lu != %lu");
  TASSERT_EQUALS(test, added, YES, "bad %c != %c");
  TASSERT_EQUALS(test, CDictionaryCount(c), 1002, "bad count %lu != %lu");
  // Test arrays
  a= CCreateArrayOfDictionaryKeys(c);
  TASSERT_EQUALS(test, CArrayCount(a), 1002, "bad count %lu != %lu");
  RELEASE(a);
  a= CCreateArrayOfDictionaryObjects(c);
  TASSERT_EQUALS(test, CArrayCount(a), 1002, "bad count %lu != %lu");
  RELEASE(a);
  RELEASE(c);
  }

static void cdictionary_naturals(test_t *test)        {return cdictionary_naturalsOrNotZero(test, 0);}
static void cdictionary_naturalsNotZero(test_t *test) {return cdictionary_naturalsOrNotZero(test, 1);}

test_t mscore_cdictionary[]= {
  {"create"  ,NULL,cdictionary_create         ,INTITIALIZE_TEST_T_END},
  {"enum"    ,NULL,cdictionary_enum           ,INTITIALIZE_TEST_T_END},
  {"ptrs"    ,NULL,cdictionary_ptrs           ,INTITIALIZE_TEST_T_END},
  {"naturals",NULL,cdictionary_naturals       ,INTITIALIZE_TEST_T_END},
  {"naturals",NULL,cdictionary_naturalsNotZero,INTITIALIZE_TEST_T_END},
  {NULL}
};

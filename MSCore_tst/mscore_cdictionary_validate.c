// mscore_cdictionary_validate.c, ecb, 130911

#include "mscore_validate.h"
/*
static inline void cdictionary_print(CDictionary *d)
  {
  fprintf(stdout, "%lu\n",WLU(CDictionaryCount(d)));
  }
*/
static int cdictionary_create(void)
  {
  int err= 0;
  CDictionary *c,*d,*m; id k,o,x; int i;
  c= (CDictionary*)MSCreateObjectWithClassIndex(CDictionaryClassIndex);
  d= CCreateDictionary(0);
  err+= ASSERT_EQUALS(RETAINCOUNT(c), 1, "A1-Bad retain count: %lu != %lu");
  err+= ASSERT_EQUALS(RETAINCOUNT(d), 1, "A2-Bad retain count: %lu != %lu");
  err+= ASSERT(CDictionaryEquals(c, d), "A3 c & d are not equals");
  RELEASE(d);
  k= (id)CCreateBufferWithBytes("key1", 4);
  o= (id)CCreateBufferWithBytes("obj1", 4);
  CDictionarySetObjectForKey(c, o, k);
  err+= ASSERT_EQUALS(RETAINCOUNT(k), 1, "A10-Bad retain count: %lu != %lu");
  err+= ASSERT_EQUALS(RETAINCOUNT(o), 2, "A11-Bad retain count: %lu != %lu");
  d= CCreateDictionaryWithObjectsAndKeys(&k, &k, 1);
  err+= ASSERT_EQUALS(RETAINCOUNT(d), 1, "A12-Bad retain count: %lu != %lu");
  err+= ASSERT_EQUALS(RETAINCOUNT(k), 2, "A13-Bad retain count: %lu != %lu");
  err+= ASSERT(!CDictionaryEquals(c, d), "A14 c & d are equals");
  CDictionarySetObjectForKey(d, o, k);
  err+= ASSERT_EQUALS(RETAINCOUNT(k), 1, "A15-Bad retain count: %lu != %lu");
  err+= ASSERT_EQUALS(RETAINCOUNT(o), 3, "A16-Bad retain count: %lu != %lu");
  err+= ASSERT(CDictionaryEquals(c, d), "A17 c & d are not equals");
  m= CCreateDictionaryWithDictionaryCopyItems(c, NO);
  RELEASE(d); d= m;
  x= (id)CCreateBufferWithBytes("a key", 5);
  CDictionarySetObjectForKey(d, o, x);
  err+= ASSERT_EQUALS(CDictionaryCount(d), 2, "A20-Bad count: %lu != %lu");
  err+= ASSERT(!CDictionaryEquals(c, d), "A21 c & d are equals");
  CDictionarySetObjectForKey(d, nil, x);
  err+= ASSERT(CDictionaryEquals(c, d), "A22 c & d are not equals");
  for (i= 0; i<100; i++) {
    CBufferAppendByte((CBuffer*)x, (MSByte)i);
    CDictionarySetObjectForKey(d, o, x);}
  err+= ASSERT_EQUALS(RETAINCOUNT(o), 103, "A23-Bad count: %lu != %lu");
  RELEASE(x);
  RELEASE(c);
  err+= ASSERT_EQUALS(RETAINCOUNT(d), 1, "A41-Bad count: %lu != %lu");
  RELEASE(d);
  err+= ASSERT_EQUALS(RETAINCOUNT(k), 1, "A42-Bad count: %lu != %lu");
  err+= ASSERT_EQUALS(RETAINCOUNT(o), 1, "A43-Bad count: %lu != %lu");
  RELEASE(k);
  RELEASE(o);
  return err;
  }

static inline int cdictionary_enum(void)
  {
  int err= 0;
  CDictionary *c,*d; id ks[1000],os[1000],k,o; int i,n,fd; CDictionaryEnumerator *de;
  k= (id)CCreateBufferWithBytes("a key", 5);
  o= (id)CCreateBufferWithBytes("an object", 9);
  for (i=0; i<1000; i++) {
    CBufferAppendByte((CBuffer*)k, (MSByte)i); ks[i]= COPY(k);
    CBufferAppendByte((CBuffer*)o, (MSByte)i); os[i]= COPY(o);}
  RELEASE(k);
  RELEASE(o);
  d= CCreateDictionaryWithObjectsAndKeys(os, ks, 1000);
  if (CDictionaryCount(d)!=1000) {
    fprintf(stdout, "B1 Bad count: %lu\n",WLU(CDictionaryCount(d))); err++;}

  c= (CDictionary*)COPY((id)d);
  RELEASE(d);
  d= (CDictionary*)CDictionaryCopy((id)c);
  RELEASE(c);

  de= CDictionaryEnumeratorAlloc(d);
  for (n= 0, fd= 0; (o= (id)CDictionaryEnumeratorNextObject(de)); n++) {
    k= CDictionaryEnumeratorCurrentKey(de);
    for (i= 0; i<1000; i++) {
      if (ISEQUAL(k, ks[i])) fd++;}
    if (fd!=n+1) {
      fprintf(stdout, "B2 Bad fd: %lu %lu\n",WLI(fd),WLI(n)); err++;}}
  if (n!=1000) {
    fprintf(stdout, "B3 Bad n: %lu\n",WLI(n)); err++;}
  CDictionaryEnumeratorFree(de);
  de= CDictionaryEnumeratorAlloc(d);
  for (n= 0, fd= 0; (k= (id)CDictionaryEnumeratorNextKey(de)); n++) {
    o= CDictionaryEnumeratorCurrentObject(de);
    for (i= 0; i<1000; i++) {
      if (ISEQUAL(o, os[i])) fd++;}
    if (fd!=n+1) {
      fprintf(stdout, "B4 Bad fd: %lu %lu\n",WLI(fd),WLI(n)); err++;}}
  if (n!=1000) {
    fprintf(stdout, "B5 Bad n: %lu\n",WLI(n)); err++;}
  CDictionaryEnumeratorFree(de);
  for (i= 0; i<1000; i++) {
    RELEASE(ks[i]); RELEASE(os[i]);}
  RELEASE(d);
  return err;
  }

static int cdictionary_ptrs(void)
  {
  int err= 0;
  return err;
  }

static int cdictionary_naturals(void)
  {
  int err= 0;
  CDictionary *c; long i; CDictionaryEnumerator *de; CArray *a;
  c= CCreateDictionaryWithOptions(100, CDictionaryNatural, CDictionaryNatural);
  CDictionarySetObjectForKey(c, (id)0, (id)0);
  err+= ASSERT_EQUALS(CDictionaryObjectForKey(c, (id)0)   , (id)0   , "bad natural 1 %lu %lu");
  for (i= 0; i<=1000; i++) CDictionarySetObjectForKey(c, (id)(1000-i), (id)i);
  err+= ASSERT_EQUALS(CDictionaryObjectForKey(c, (id)0)   , (id)1000, "bad natural 2 %lu %lu");
  err+= ASSERT_EQUALS(CDictionaryObjectForKey(c, (id)1)   , (id)999 , "bad natural 3 %lu %lu");
  err+= ASSERT_EQUALS(CDictionaryObjectForKey(c, (id)200) , (id)800 , "bad natural 4 %lu %lu");
  err+= ASSERT_EQUALS(CDictionaryObjectForKey(c, (id)999) , (id)1   , "bad natural 5 %lu %lu");
  err+= ASSERT_EQUALS(CDictionaryObjectForKey(c, (id)1000), (id)0   , "bad natural 6 %lu %lu");
  err+= ASSERT_EQUALS(CDictionaryObjectForKey(c, (id)2000), (id)NSNotFound, "bad natural 7 %lu %lu");
  de= CDictionaryEnumeratorAlloc(c);
  for (i= 0; CDictionaryEnumeratorNextKey(de)!=(id)NSNotFound; i++);
  CDictionaryEnumeratorFree(de);
  err+= ASSERT_EQUALS(i, 1001, "bad natural enumeration %lu != %lu");
  CDictionarySetObjectForKey(c, (id)NSNotFound, (id)10);
  err+= ASSERT_EQUALS(CDictionaryCount(c), 1000, "bad count %lu != %lu");
  a= CCreateArrayOfDictionaryKeys(c);
  err+= ASSERT_EQUALS(CArrayCount(a), 1000, "bad count %lu != %lu");
  RELEASE(a);
  a= CCreateArrayOfDictionaryObjects(c);
  err+= ASSERT_EQUALS(CArrayCount(a), 1000, "bad count %lu != %lu");
  RELEASE(a);
  RELEASE(c);
  return err;
  }

test_t mscore_cdictionary[]= {
  {"create"  ,NULL,cdictionary_create  ,INTITIALIZE_TEST_T_END},
  {"enum"    ,NULL,cdictionary_enum    ,INTITIALIZE_TEST_T_END},
  {"ptrs"    ,NULL,cdictionary_ptrs    ,INTITIALIZE_TEST_T_END},
  {"naturals",NULL,cdictionary_naturals,INTITIALIZE_TEST_T_END},
  {NULL}
};

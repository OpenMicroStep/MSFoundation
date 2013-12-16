// mscore_cdictionary_validate.c, ecb, 130911

#include "MSCorePrivate_.h"
#include "mscore_validate.h"

static inline void cdictionary_print(CDictionary *d)
  {
  fprintf(stdout, "%lu\n",WLU(CDictionaryCount(d)));
  }

static inline int cdictionary_create(void)
  {
  int err= 0;
  CDictionary *c,*d,*m; id k,o,x; int i;
  c= (CDictionary*)MSCreateObjectWithClassIndex(CDictionaryClassIndex);
  d= CCreateDictionary(0);
  if (RETAINCOUNT(c)!=1) {
    fprintf(stdout, "A1 Bad retain count: %lu\n",WLU(RETAINCOUNT(c))); err++;}
  if (RETAINCOUNT(d)!=1) {
    fprintf(stdout, "A2 Bad retain count: %lu\n",WLU(RETAINCOUNT(d))); err++;}
  if (!CDictionaryEquals(c, d)) {
    fprintf(stdout, "A3 c & d are not equals\n"); err++;}
  RELEASE(d);
  k= (id)CCreateBufferWithBytes("key1", 4);
  o= (id)CCreateBufferWithBytes("obj1", 4);
  CDictionarySetObjectForKey(c, o, k);
  if (RETAINCOUNT(k)!=1) {
    fprintf(stdout, "A10 Bad retain count: %lu\n",WLU(RETAINCOUNT(k))); err++;}
  if (RETAINCOUNT(o)!=2) {
    fprintf(stdout, "A11 Bad retain count: %lu\n",WLU(RETAINCOUNT(o))); err++;}
  d= CCreateDictionaryWithObjectsAndKeys(&k, &k, 1);
  if (RETAINCOUNT(d)!=1) {
    fprintf(stdout, "A12 Bad retain count: %lu\n",WLU(RETAINCOUNT(d))); err++;}
  if (RETAINCOUNT(k)!=2) {
    fprintf(stdout, "A13 Bad retain count: %lu\n",WLU(RETAINCOUNT(k))); err++;}
  if (CDictionaryEquals(c, d)) {
    fprintf(stdout, "A14 c & d are equals\n"); err++;}
  CDictionarySetObjectForKey(d, o, k);
  if (RETAINCOUNT(k)!=1) {
    fprintf(stdout, "A15 Bad retain count: %lu\n",WLU(RETAINCOUNT(k))); err++;}
  if (RETAINCOUNT(o)!=3) {
    fprintf(stdout, "A16 Bad retain count: %lu\n",WLU(RETAINCOUNT(o))); err++;}
  if (!CDictionaryEquals(c, d)) {
    fprintf(stdout, "A17 c & d are not equals\n"); err++;}
  m= (CDictionary*)COPY(d);
  RELEASE(d); d= m;
  x= (id)CCreateBufferWithBytes("a key", 5);
  CDictionarySetObjectForKey(d, o, x);
  if (CDictionaryCount(d)!=2) {
    fprintf(stdout, "A20 Bad count: %lu\n",WLU(CDictionaryCount(d))); err++;}
  if (CDictionaryEquals(c, d)) {
    fprintf(stdout, "A21 c & d are equals\n"); err++;}
  CDictionarySetObjectForKey(d, nil, x);
  if (!CDictionaryEquals(c, d)) {
    fprintf(stdout, "A22 c & d are not equals\n"); err++;}
  for (i= 0; i<100; i++) {
    CBufferAppendByte((CBuffer*)x, (MSByte)i);
    CDictionarySetObjectForKey(d, o, x);}
  if (RETAINCOUNT(o)!=103) {
    fprintf(stdout, "A23 Bad retain count: %lu\n",WLU(RETAINCOUNT(o))); err++;}
//printf("1\n");
  RELEASE(x);
  RELEASE(c);
  if (RETAINCOUNT(d)!=1) {
    fprintf(stdout, "A41 Bad retain count: %lu\n",WLU(RETAINCOUNT(d))); err++;}
  RELEASE(d);
  if (RETAINCOUNT(k)!=1) {
    fprintf(stdout, "A42 Bad retain count: %lu\n",WLU(RETAINCOUNT(k))); err++;}
  if (RETAINCOUNT(o)!=1) {
    fprintf(stdout, "A43 Bad retain count: %lu\n",WLU(RETAINCOUNT(o))); err++;}
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

int mscore_cdictionary_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  err+= cdictionary_create();
  err+= cdictionary_enum();

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","CDictionary",(err?"FAIL":"PASS"),seconds);
  return err;
  }

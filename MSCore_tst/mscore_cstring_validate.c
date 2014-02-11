// mscore_cstring_validate.c, ecb, 130911

#include "MSCore_Private.h"
#include "mscore_validate.h"

static inline void cstring_print(CString *d)
  {
  fprintf(stdout, "%lu\n",WLU(CStringLength(d)));
  }

static inline int cstring_create(void)
  {
  int err= 0;
  CString *c,*d,*m; id k,o,x; int i;
  unsigned char cs[10];
  c= (CString*)MSCreateObjectWithClassIndex(CStringClassIndex);
  d= CCreateString(0);
  if (RETAINCOUNT(c)!=1) {
    fprintf(stdout, "A1 Bad retain count: %lu\n",WLU(RETAINCOUNT(c))); err++;}
  if (RETAINCOUNT(d)!=1) {
    fprintf(stdout, "A2 Bad retain count: %lu\n",WLU(RETAINCOUNT(d))); err++;}
  if (!CStringEquals(c, d)) {
    fprintf(stdout, "A3 c & d are not equals\n"); err++;}
printf("A5\n");
  CStringAppendCharacter(c, 60);
  CStringAppendCharacterSuite(d, 60, 1);
  if (!CStringEquals(c, d)) {
    fprintf(stdout, "A4 c & d are not equals\n"); err++;}
  CStringAppendCharacterSuite(c, 161, 2);
printf("A6\n");
  cs[0]= cs[1]= 193; // 0xC1 ¡
  CStringAppendBytes(d, cs, 2, NSMacOSRomanStringEncoding);
  if (!CStringEquals(c, d)) {
    fprintf(stdout, "A5 c & d are not equals\n"); err++;}
printf("A1\n");
  RELEASE(d);
/*
  if (RETAINCOUNT(k)!=1) {
    fprintf(stdout, "A10 Bad retain count: %lu\n",WLU(RETAINCOUNT(k))); err++;}
  if (RETAINCOUNT(o)!=2) {
    fprintf(stdout, "A11 Bad retain count: %lu\n",WLU(RETAINCOUNT(o))); err++;}
  d= CCreateStringWithObjectsAndKeys(&k, &k, 1);
  if (RETAINCOUNT(d)!=1) {
    fprintf(stdout, "A12 Bad retain count: %lu\n",WLU(RETAINCOUNT(d))); err++;}
  if (RETAINCOUNT(k)!=2) {
    fprintf(stdout, "A13 Bad retain count: %lu\n",WLU(RETAINCOUNT(k))); err++;}
  if (CStringEquals(c, d)) {
    fprintf(stdout, "A14 c & d are equals\n"); err++;}
  CStringSetObjectForKey(d, o, k);
  if (RETAINCOUNT(k)!=1) {
    fprintf(stdout, "A15 Bad retain count: %lu\n",WLU(RETAINCOUNT(k))); err++;}
  if (RETAINCOUNT(o)!=3) {
    fprintf(stdout, "A16 Bad retain count: %lu\n",WLU(RETAINCOUNT(o))); err++;}
  if (!CStringEquals(c, d)) {
    fprintf(stdout, "A17 c & d are not equals\n"); err++;}
  m= (CString*)COPY(d);
  RELEASE(d); d= m;
  x= (id)CCreateBufferWithBytes("a key", 5);
  CStringSetObjectForKey(d, o, x);
  if (CStringLength(d)!=2) {
    fprintf(stdout, "A20 Bad count: %lu\n",WLU(CStringLength(d))); err++;}
  if (CStringEquals(c, d)) {
    fprintf(stdout, "A21 c & d are equals\n"); err++;}
  CStringSetObjectForKey(d, nil, x);
  if (!CStringEquals(c, d)) {
    fprintf(stdout, "A22 c & d are not equals\n"); err++;}
  for (i= 0; i<100; i++) {
    CBufferAppendByte((CBuffer*)x, (MSByte)i);
    CStringSetObjectForKey(d, o, x);}
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
*/
  RELEASE(c);
  return err;
  }

static inline int cstring_enum(void)
  {
  int err= 0;
/*
  CString *c,*d; id ks[1000],os[1000],k,o; int i,n,fd; CStringEnumerator *de;
  k= (id)CCreateBufferWithBytes("a key", 5);
  o= (id)CCreateBufferWithBytes("an object", 9);
  for (i=0; i<1000; i++) {
    CBufferAppendByte((CBuffer*)k, (MSByte)i); ks[i]= COPY(k);
    CBufferAppendByte((CBuffer*)o, (MSByte)i); os[i]= COPY(o);}
  RELEASE(k);
  RELEASE(o);
  d= CCreateStringWithObjectsAndKeys(os, ks, 1000);
  if (CStringLength(d)!=1000) {
    fprintf(stdout, "B1 Bad count: %lu\n",WLU(CStringLength(d))); err++;}

  c= (CString*)COPY((id)d);
  RELEASE(d);
  d= (CString*)CStringCopy((id)c);
  RELEASE(c);

  de= CStringEnumeratorAlloc(d);
  for (n= 0, fd= 0; (o= (id)CStringEnumeratorNextObject(de)); n++) {
    k= CStringEnumeratorCurrentKey(de);
    for (i= 0; i<1000; i++) {
      if (ISEQUAL(k, ks[i])) fd++;}
    if (fd!=n+1) {
      fprintf(stdout, "B2 Bad fd: %lu %lu\n",WLI(fd),WLI(n)); err++;}}
  if (n!=1000) {
    fprintf(stdout, "B3 Bad n: %lu\n",WLI(n)); err++;}
  CStringEnumeratorFree(de);
  de= CStringEnumeratorAlloc(d);
  for (n= 0, fd= 0; (k= (id)CStringEnumeratorNextKey(de)); n++) {
    o= CStringEnumeratorCurrentObject(de);
    for (i= 0; i<1000; i++) {
      if (ISEQUAL(o, os[i])) fd++;}
    if (fd!=n+1) {
      fprintf(stdout, "B4 Bad fd: %lu %lu\n",WLI(fd),WLI(n)); err++;}}
  if (n!=1000) {
    fprintf(stdout, "B5 Bad n: %lu\n",WLI(n)); err++;}
  CStringEnumeratorFree(de);
  for (i= 0; i<1000; i++) {
    RELEASE(ks[i]); RELEASE(os[i]);}
  RELEASE(d);
*/
  return err;
  }

int mscore_cstring_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  err+= cstring_create();
  err+= cstring_enum();

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","CString",(err?"FAIL":"PASS"),seconds);
  return err;
  }

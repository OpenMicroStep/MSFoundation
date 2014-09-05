// mscore_carray_validate.c, ecb, 130911

#include "mscore_validate.h"

static inline int carray_create(void)
  {
  int err= 0;
  NSUInteger i,j;
  CArray *a,*x,*b;
  a= CCreateArray(10);
  x= CCreateArrayWithOptions(0,YES,NO);
  for (i=0; i<10; i++) {
    b= CCreateArray(i+1);
    for (j=0; j<i+1; j++) CArrayAddObject(b, (id)x);
    CArrayAddObject(a, (id)b);
    RELEASE(b);}
  if (RETAINCOUNT(x)!=56) {
    fprintf(stdout, "Bad retain count(1): %lu\n",WLU(RETAINCOUNT(x)));
    err++;}
  RELEASE(a);
  if (RETAINCOUNT(x)!=1) {
    fprintf(stdout, "Bad retain count(2): %lu\n",WLU(RETAINCOUNT(x)));
    err++;}
  RELEASE(x);
  return err;
  }

static inline int carray_ptr(void)
  {
  int err= 0;
  NSUInteger i, p[200], *q[100], *x;
  CArray *a;
  a= CCreateArrayWithOptions(0,YES,YES);
  for (i=0; i<100; i++) p[i]= 2*i;
  // Array of int
  CArrayAddObjects(a, (id*)p, 100, NO);
  i= CArrayIndexOfIdenticalObject(a, (id)(p[77]), 0, 100);
  if (i!=77 || p[i]!=154) {
    fprintf(stdout, "Bad index(3): %lu\n",WLU(i));
    err++;}
  CArrayRemoveAllObjects(a);
  // Array of int*
  for (i=0; i<100; i++) q[i]= p+i;
  CArrayAddObjects(a, (id*)q, 100, NO);
  i= CArrayIndexOfIdenticalObject(a, (id)(p+13), 0, 100);
  if (i!=13 || p[i]!=26 || q[i]!=p+i) {
    fprintf(stdout, "Bad index(4): %lu\n",WLU(i));
    err++;}
  // insert
  // p: 0 2 .. 198 1 3 .. 199
  // a: 0 1 .. .. .. 198 199
  for (i=0; i<100; i++) {p[100+i]= 2*i+1; q[i]= p+100+i;}
  for (i=0; i<100; i++) CArrayInsertObjectAtIndex(a, (id)q[i], 2*i+1);
//for (i=0; i<200; i++) fprintf(stdout, " %ld",*((NSInteger*)a->pointers[i]));
//fprintf(stdout, "\n");
  i= CArrayIndexOfIdenticalObject(a, (id)q[97], 0, 200);
  if (i!=195 || *((NSInteger*)a->pointers[i])!=195 || q[97]!=p+197) {
    fprintf(stdout, "Bad index(5): %lu\n",WLU(i));
    err++;}
  // remove
  CArrayRemoveObjectsInRange(a, NSMakeRange(10, 20));
  if (CArrayCount(a)!=180) {
    fprintf(stdout, "Bad count(6): %lu\n",WLU(i));
    err++;}
  x= (NSUInteger*)CArrayObjectAtIndex(a, 10);
  if (*x!=30) {
    fprintf(stdout, "Bad int (7): %lu\n",WLU(*x));
    err++;}
  i= CArrayIndexOfIdenticalObject(a, (id)x, 0, CArrayCount(a));
  if (i!=10) {
    fprintf(stdout, "Bad index(8): %lu\n",WLU(i));
    err++;}
  // replace
  // 0 .. 9 30 .. 199 => 0 1 .. 8 9 1 3 .. 17 19 40 .. 199 
  CArrayReplaceObjectsInRange(a, (id*)q, NSMakeRange(10,10), NO);
  i= CArrayRemoveIdenticalObject(a, (id)q[3]); // 7
  if (i!=2) {
    fprintf(stdout, "Bad remove identical(9): %lu\n",WLU(i));
    err++;}
  i= CArrayIndexOfIdenticalObject(a, (id)q[4], 0, CArrayCount(a)); // 9
  if (i!=8) {
    fprintf(stdout, "Bad index(10): %lu\n",WLU(i));
    err++;}
  i= CArrayIndexOfIdenticalObject(a, (id)q[50], 0, CArrayCount(a)); // 101
  if (i!=101-20-2) {
    fprintf(stdout, "Bad index(11): %lu\n",WLU(i));
    err++;}
  RELEASE(a);
  return err;
  }

static inline int carray_subarray(void)
  {
  int err= 0;
  NSUInteger i,j, n= 2*3*256;
  CArray *a,*b,*c; id o;
  a= CCreateArray(n);
  o= (id)CCreateArrayWithOptions(0,YES,YES);
  CArrayAddObject((CArray*)o, nil);
  if (((CArray*)o)->count!=1) {
    fprintf(stdout, "Bad count(30): %lu\n",WLU(((CArray*)o)->count));
    err++;}
  for (i=0; i<n; i++) {
    b= CCreateArray(i+1);
    for (j=0; j<i+1; j++) CArrayAddObject(b, o);
    CArrayAddObject(a, (id)b);
    RELEASE(b);}
  RELEASE(o);
  if (RETAINCOUNT(o)!=n*(n+1)/2) {
    fprintf(stdout, "Bad retain count(31): %lu\n",WLU(RETAINCOUNT(o)));
    err++;}
  b= CCreateSubArrayWithRange(a, NSMakeRange(n/2, n/3));
  if (b->count!=n/3) {
    fprintf(stdout, "Bad count(32): %lu\n",WLU(b->count));
    err++;}
  if (RETAINCOUNT(o)!=n*(n+1)/2) {
    fprintf(stdout, "Bad retain count(33): %lu\n",WLU(RETAINCOUNT(o)));
    err++;}
  c= CCreateArray(n/3);
  CArrayAddArray(c, b, YES);
  if (RETAINCOUNT(o)!=n*(n+1)/2+(4*n+3)*n/18) {
    fprintf(stdout, "Bad retain count(34): %lu\n",WLU(RETAINCOUNT(o)));
    err++;}
  RETAIN(o);
  RELEASE(a);
  RELEASE(b);
  RELEASE(c);
  if (RETAINCOUNT(o)!=1) {
    fprintf(stdout, "Bad retain count(35): %lu\n",WLU(RETAINCOUNT(o)));
    err++;}
  RELEASE(o);
  return err;
  }

static inline int carray_retainrelease(void)
  {
  int err= 0;
  CArray *a; id o,oo;
  a= CCreateArrayWithOptions(0,YES,NO);
  // o is a retained object.
  o= (id)CCreateArrayWithOptions(0,YES,YES);
  if (RETAINCOUNT(o)!=1) {
    fprintf(stdout, "Bad retain count(41): %lu\n",WLU(RETAINCOUNT(o)));
    err++;}
  CArrayAddObject(a, o);
  if (RETAINCOUNT(o)!=1) {
    fprintf(stdout, "Bad retain count(42): %lu\n",WLU(RETAINCOUNT(o)));
    err++;}
  CArraySetRetainReleaseOptionAndRetainAllObjects(a, NO);
  if (RETAINCOUNT(o)!=1) {
    fprintf(stdout, "Bad retain count(43): %lu\n",WLU(RETAINCOUNT(o)));
    err++;}
  oo= (id)CCreateArrayWithOptions(0,YES,YES); // 1
  CArrayAddObject(a, oo);                     // 2
  CArraySetRetainReleaseOptionAndRetainAllObjects(a, YES);
  if (RETAINCOUNT(o)!=2) {
    fprintf(stdout, "Bad retain count(44): %lu\n",WLU(RETAINCOUNT(o)));
    err++;}
  if (RETAINCOUNT(oo)!=3) {
    fprintf(stdout, "Bad retain count(45): %lu\n",WLU(RETAINCOUNT(oo)));
    err++;}
  CArrayUnsetRetainReleaseOptionAndReleaseAllObjects(a, YES);
  if (RETAINCOUNT(o)!=1) {
    fprintf(stdout, "Bad retain count(46): %lu\n",WLU(RETAINCOUNT(o)));
    err++;}
  if (RETAINCOUNT(oo)!=2) {
    fprintf(stdout, "Bad retain count(47): %lu\n",WLU(RETAINCOUNT(oo)));
    err++;}
  CArrayRemoveObjectAtIndex(a, 0);
  if (RETAINCOUNT(o)!=1) {
    fprintf(stdout, "Bad retain count(48): %lu\n",WLU(RETAINCOUNT(o)));
    err++;}
  RELEASE(o);
  CArrayUnsetRetainReleaseOptionAndReleaseAllObjects(a, YES);
  if (RETAINCOUNT(oo)!=1) {
    fprintf(stdout, "Bad retain count(49): %lu\n",WLU(RETAINCOUNT(oo)));
    err++;}
  CArraySetRetainReleaseOptionAndRetainAllObjects(a, NO);
  if (RETAINCOUNT(oo)!=1) {
    fprintf(stdout, "Bad retain count(50): %lu\n",WLU(RETAINCOUNT(oo)));
    err++;}
  RETAIN(oo);
  RELEASE(a);
  if (RETAINCOUNT(oo)!=1) {
    fprintf(stdout, "Bad retain count(51): %lu\n",WLU(RETAINCOUNT(oo)));
    err++;}
  RELEASE(oo);
  return err;
  }

int mscore_carray_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  err+= carray_create();
  err+= carray_ptr();
  err+= carray_subarray();
  err+= carray_retainrelease();

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","CArray",(err?"FAIL":"PASS"),seconds);
  return err;
  }

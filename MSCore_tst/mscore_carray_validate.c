// mscore_carray_validate.c, ecb, 130911

#include "mscore_validate.h"

static inline int carray_create(void)
  {
  int err= 0;
  NSUInteger i,j;
  CArray *a,*x,*b;
  a= CCreateArray(10);
  x= CCreateArrayWithOptions(0,YES,NO);
  for (i= 0; i<10; i++) {
    b= CCreateArray(i+1);
    for (j= 0; j<i+1; j++) CArrayAddObject(b, (id)x);
    CArrayAddObject(a, (id)b);
    RELEASE(b);}
  ASSERT_EQUALS(RETAINCOUNT(x), 56, "Bad retain count(1): %lu");
  RELEASE(a);
  ASSERT_EQUALS(RETAINCOUNT(x), 1, "Bad retain count(2): %lu");
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
  ASSERT(i == 77 && p[i] == 154, "Bad index(3): %lu");
  CArrayRemoveAllObjects(a);
  // Array of int*
  for (i=0; i<100; i++) q[i]= p+i;
  CArrayAddObjects(a, (id*)q, 100, NO);
  i= CArrayIndexOfIdenticalObject(a, (id)(p+13), 0, 100);
  ASSERT(i==13 && p[i]==26 && q[i]==p+i, "Bad index(4): %lu");
  // insert
  // p: 0 2 .. 198 1 3 .. 199
  // a: 0 1 .. .. .. 198 199
  for (i=0; i<100; i++) {p[100+i]= 2*i+1; q[i]= p+100+i;}
  for (i=0; i<100; i++) CArrayInsertObjectAtIndex(a, (id)q[i], 2*i+1);
//for (i=0; i<200; i++) fprintf(stdout, " %ld",*((NSInteger*)a->pointers[i]));
//fprintf(stdout, "\n");
  i= CArrayIndexOfIdenticalObject(a, (id)q[97], 0, 200);
  ASSERT(i==195 && *((NSInteger*)a->pointers[i])==195 && q[97]==p+197, "Bad index(5): %lu");
  // remove
  CArrayRemoveObjectsInRange(a, NSMakeRange(10, 20));
  ASSERT_EQUALS(CArrayCount(a), 180, "Bad count(6): %lu");
  x= (NSUInteger*)CArrayObjectAtIndex(a, 10);
  ASSERT_EQUALS(*x, 30, "Bad int (7): %lu");
  i= CArrayIndexOfIdenticalObject(a, (id)x, 0, CArrayCount(a));
  ASSERT_EQUALS(i, 10, "Bad index(8): %lu");
  // replace
  // 0 .. 9 30 .. 199 => 0 1 .. 8 9 1 3 .. 17 19 40 .. 199 
  CArrayReplaceObjectsInRange(a, (id*)q, NSMakeRange(10,10), NO);
  i= CArrayRemoveIdenticalObject(a, (id)q[3]); // 7
  ASSERT_EQUALS(i, 2, "Bad remove identical(9): %lu");
  i= CArrayIndexOfIdenticalObject(a, (id)q[4], 0, CArrayCount(a)); // 9
  ASSERT_EQUALS(i, 8, "Bad index(10): %lu");
  i= CArrayIndexOfIdenticalObject(a, (id)q[50], 0, CArrayCount(a)); // 101
  ASSERT_EQUALS(i, 101-20-2, "Bad index(11): %lu");
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
  ASSERT_EQUALS(((CArray*)o)->count, 1, "Bad count(30): %lu");
  for (i=0; i<n; i++) {
    b= CCreateArray(i+1);
    for (j=0; j<i+1; j++) CArrayAddObject(b, o);
    CArrayAddObject(a, (id)b);
    RELEASE(b);}
  RELEASE(o);
  ASSERT_EQUALS(RETAINCOUNT(o), n*(n+1)/2, "Bad retain count(31): %lu");
  b= CCreateSubArrayWithRange(a, NSMakeRange(n/2, n/3));
  ASSERT_EQUALS(b->count, n/3, "Bad count(32): %lu");
  ASSERT_EQUALS(RETAINCOUNT(o), n*(n+1)/2, "Bad retain count(33): %lu");
  c= CCreateArray(n/3);
  CArrayAddArray(c, b, YES);
  ASSERT_EQUALS(RETAINCOUNT(o), n*(n+1)/2+(4*n+3)*n/18, "Bad retain count(34): %lu");
  RETAIN(o);
  RELEASE(a);
  RELEASE(b);
  RELEASE(c);
  ASSERT_EQUALS(RETAINCOUNT(o), 1, "Bad retain count(35): %lu");
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

static inline int carray_immutable(void)
  {
  int err= 0;
  CArray *a; id o;
  o= (id)CCreateArray(0);
  a= CCreateArrayWithObject(o);
  CGrowSetForeverImmutable((id)a);
  if (!CGrowIsForeverImmutable((id)a)) {
    fprintf(stdout, "array is mutable\n");
    err++;}
//CArrayAddObject(a, o);               // -> crash
//CArrayReplaceObjectAtIndex(a, o, 0); // -> crash
//CArrayRemoveLastObject(a);           // -> crash
  RELEASE(o);
  RELEASE(a);
  return err;
  }

int mscore_carray_validate(void)
  {
  int err= 0;
  err+= carray_create();
  err+= carray_ptr();
  err+= carray_subarray();
  err+= carray_retainrelease();
  err+= carray_immutable();
  return err;
  }

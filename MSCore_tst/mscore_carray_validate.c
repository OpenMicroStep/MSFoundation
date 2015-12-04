// mscore_carray_validate.c, ecb, 130911

#include "mscore_validate.h"

static void carray_create(test_t *test)
  {
  NSUInteger i,j;
  CArray *a,*x,*b;
  a= CCreateArray(10);
  x= CCreateArrayWithOptions(0,YES,NO);
  for (i= 0; i<10; i++) {
    b= CCreateArray(i+1);
    for (j= 0; j<i+1; j++) CArrayAddObject(b, (id)x);
    CArrayAddObject(a, (id)b);
    RELEASE(b);}
  TASSERT_EQUALS(test, RETAINCOUNT(x), 56, "Bad retain count(1): %lu");
  RELEASE(a);
  TASSERT_EQUALS(test, RETAINCOUNT(x), 1, "Bad retain count(2): %lu");
  RELEASE(x);
  }

static void carray_ptr(test_t *test)
  {
  NSUInteger i, p[200], *q[100], *x;
  CArray *a;
  a= CCreateArrayWithOptions(0,YES,YES);
  for (i=0; i<100; i++) p[i]= 2*i;
  // Array of int
  CArrayAddObjects(a, (id*)p, 100, NO);
  i= CArrayIndexOfIdenticalObject(a, (id)(p[77]), 0, 100);
  TASSERT(test, i == 77 && p[i] == 154, "Bad index(3): %lu");
  CArrayRemoveAllObjects(a);
  // Array of int*
  for (i=0; i<100; i++) q[i]= p+i;
  CArrayAddObjects(a, (id*)q, 100, NO);
  i= CArrayIndexOfIdenticalObject(a, (id)(p+13), 0, 100);
  TASSERT(test, i==13 && p[i]==26 && q[i]==p+i, "Bad index(4): %lu");
  // insert
  // p: 0 2 .. 198 1 3 .. 199
  // a: 0 1 .. .. .. 198 199
  for (i=0; i<100; i++) {p[100+i]= 2*i+1; q[i]= p+100+i;}
  for (i=0; i<100; i++) CArrayInsertObjectAtIndex(a, (id)q[i], 2*i+1);
//for (i=0; i<200; i++) fprintf(stdout, " %ld",*((NSInteger*)a->pointers[i]));
//fprintf(stdout, "\n");
  i= CArrayIndexOfIdenticalObject(a, (id)q[97], 0, 200);
  TASSERT(test, i==195 && *((NSInteger*)a->pointers[i])==195 && q[97]==p+197, "Bad index(5): %lu");
  // remove
  CArrayRemoveObjectsInRange(a, NSMakeRange(10, 20));
  TASSERT_EQUALS(test, CArrayCount(a), 180, "Bad count(6): %lu");
  x= (NSUInteger*)CArrayObjectAtIndex(a, 10);
  TASSERT_EQUALS(test, *x, 30, "Bad int (7): %lu");
  i= CArrayIndexOfIdenticalObject(a, (id)x, 0, CArrayCount(a));
  TASSERT_EQUALS(test, i, 10, "Bad index(8): %lu");
  // replace
  // 0 .. 9 30 .. 199 => 0 1 .. 8 9 1 3 .. 17 19 40 .. 199
  CArrayReplaceObjectsInRange(a, (id*)q, NSMakeRange(10,10), NO);
  i= CArrayRemoveIdenticalObject(a, (id)q[3]); // 7
  TASSERT_EQUALS(test, i, 2, "Bad remove identical(9): %lu");
  i= CArrayIndexOfIdenticalObject(a, (id)q[4], 0, CArrayCount(a)); // 9
  TASSERT_EQUALS(test, i, 8, "Bad index(10): %lu");
  i= CArrayIndexOfIdenticalObject(a, (id)q[50], 0, CArrayCount(a)); // 101
  TASSERT_EQUALS(test, i, 101-20-2, "Bad index(11): %lu");
  RELEASE(a);
  }

static void carray_subarray(test_t *test)
  {
  NSUInteger i,j, n= 2*3*256;
  CArray *a,*b,*c; id o;
  a= CCreateArray(n);
  o= (id)CCreateArrayWithOptions(0,YES,YES);
  CArrayAddObject((CArray*)o, nil);
  TASSERT_EQUALS(test, ((CArray*)o)->count, 1, "Bad count(30): %lu");
  for (i=0; i<n; i++) {
    b= CCreateArray(i+1);
    for (j=0; j<i+1; j++) CArrayAddObject(b, o);
    CArrayAddObject(a, (id)b);
    RELEASE(b);}
  RELEASE(o);
  TASSERT_EQUALS(test, RETAINCOUNT(o), n*(n+1)/2, "Bad retain count(31): %lu");
  b= CCreateSubArrayWithRange(a, NSMakeRange(n/2, n/3));
  TASSERT_EQUALS(test, b->count, n/3, "Bad count(32): %lu");
  TASSERT_EQUALS(test, RETAINCOUNT(o), n*(n+1)/2, "Bad retain count(33): %lu");
  c= CCreateArray(n/3);
  CArrayAddArray(c, b, YES);
  TASSERT_EQUALS(test, RETAINCOUNT(o), n*(n+1)/2+(4*n+3)*n/18, "Bad retain count(34): %lu");
  RETAIN(o);
  RELEASE(a);
  RELEASE(b);
  RELEASE(c);
  TASSERT_EQUALS(test, RETAINCOUNT(o), 1, "Bad retain count(35): %lu");
  RELEASE(o);
  }

static void carray_retainrelease(test_t *test)
  {
  CArray *a; id o,oo;
  a= CCreateArrayWithOptions(0,YES,NO);
  // o is a retained object.
  o= (id)CCreateArrayWithOptions(0,YES,YES);
  TASSERT_OP(test, RETAINCOUNT(o), ==, 1, "Bad retain count(41): %lu",WLU(RETAINCOUNT(o)));
  CArrayAddObject(a, o);
  TASSERT_OP(test, RETAINCOUNT(o), ==, 1, "Bad retain count(42): %lu",WLU(RETAINCOUNT(o)));
  CArraySetRetainReleaseOptionAndRetainAllObjects(a, NO);
  TASSERT_OP(test, RETAINCOUNT(o), ==, 1, "Bad retain count(43): %lu",WLU(RETAINCOUNT(o)));
  oo= (id)CCreateArrayWithOptions(0,YES,YES); // 1
  CArrayAddObject(a, oo);                     // 2
  CArraySetRetainReleaseOptionAndRetainAllObjects(a, YES);
  TASSERT_OP(test, RETAINCOUNT(o), ==, 2, "Bad retain count(44): %lu",WLU(RETAINCOUNT(o)));
  TASSERT_OP(test, RETAINCOUNT(oo), ==, 3, "Bad retain count(45): %lu",WLU(RETAINCOUNT(oo)));
  CArrayUnsetRetainReleaseOptionAndReleaseAllObjects(a, YES);
  TASSERT_OP(test, RETAINCOUNT(o), ==, 1, "Bad retain count(46): %lu",WLU(RETAINCOUNT(o)));
  TASSERT_OP(test, RETAINCOUNT(oo), ==, 2, "Bad retain count(47): %lu",WLU(RETAINCOUNT(oo)));
  CArrayRemoveObjectAtIndex(a, 0);
  TASSERT_OP(test, RETAINCOUNT(o), ==, 1, "Bad retain count(48): %lu",WLU(RETAINCOUNT(o)));
  RELEASE(o);
  CArrayUnsetRetainReleaseOptionAndReleaseAllObjects(a, YES);
  TASSERT_OP(test, RETAINCOUNT(oo), ==, 1, "Bad retain count(49): %lu",WLU(RETAINCOUNT(oo)));
  CArraySetRetainReleaseOptionAndRetainAllObjects(a, NO);
  TASSERT_OP(test, RETAINCOUNT(oo), ==, 1, "Bad retain count(50): %lu",WLU(RETAINCOUNT(oo)));
  RETAIN(oo);
  RELEASE(a);
  TASSERT_OP(test, RETAINCOUNT(oo), ==, 1, "Bad retain count(51): %lu",WLU(RETAINCOUNT(oo)));
  RELEASE(oo);
  }

static void carray_immutable(test_t *test)
  {
  CArray *a; id o;
  o= (id)CCreateArray(0);
  a= CCreateArrayWithObject(o);
  CGrowSetForeverImmutable((id)a);
  TASSERT(test, CGrowIsForeverImmutable((id)a), "array is mutable");
//CArrayAddObject(a, o);               // -> crash
//CArrayReplaceObjectAtIndex(a, o, 0); // -> crash
//CArrayRemoveLastObject(a);           // -> crash
  RELEASE(o);
  RELEASE(a);
  }

testdef_t mscore_carray[]= {
  {"create"       ,NULL,carray_create       },
  {"ptr"          ,NULL,carray_ptr          },
  {"subarray"     ,NULL,carray_subarray     },
  {"retainrelease",NULL,carray_retainrelease},
  {"immutable"    ,NULL,carray_immutable    },
  {NULL}
};

// msfoundation_array_validate.m, ecb, 130911

#include "msfoundation_validate.h"

static void array_create(test_t *test)
  {
  NSUInteger i,j;
  MSArray *x;
  MSArray *a,*b;
  a= [[MSArray alloc] mutableInit];
  x= [[MSArray alloc] init];
  for (i=0; i<10; i++) {
    b= [[MSArray alloc] mutableInitWithCapacity:i+1];
    for (j=0; j<i+1; j++) [b addObject:x];
    [a addObject:b];
    RELEASE(b);}
  TASSERT_EQUALS(test, RETAINCOUNT(x), 56, "Bad retain count(1): %lu",WLU(RETAINCOUNT(x)));
  RELEASE(a);
  TASSERT_EQUALS(test, RETAINCOUNT(x), 1, "Bad retain count(2): %lu",WLU(RETAINCOUNT(x)));
  RELEASE(x);
  }

static void carray_ptr(test_t *test)
  {
  NSUInteger i, p[200], *q[100], *x;
  MSArray *a;
  a= [[MSArray alloc] mutableInitWithCapacity:0 noRetainRelease:YES nilItems:YES];
  for (i=0; i<100; i++) p[i]= 2*i;
  // Array of int
  [a addObjects:(id*)p count:100 copyItems:NO];
  i= [a indexOfObjectIdenticalTo:(id)(p[77]) inRange:NSMakeRange(0, 100)];
  TASSERT(test, i==77 && p[i]==154, "Bad index(3): %lu",WLU(i));
  [a removeAllObjects];
  // Array of int*
  for (i=0; i<100; i++) q[i]= p+i;
  [a addObjects:(id*)q count:100 copyItems:NO];
  i= [a indexOfObjectIdenticalTo:(id)(p+13) inRange:NSMakeRange(0, 100)];
  TASSERT(test, i==13 && p[i]==26 && q[i]==p+i, "Bad index(4): %lu",WLU(i));
  // insert
  // p: 0 2 .. 198 1 3 .. 199
  // a: 0 1 .. .. .. 198 199
  for (i=0; i<100; i++) {p[100+i]= 2*i+1; q[i]= p+100+i;}
  for (i=0; i<100; i++) [a insertObject:(id)q[i] atIndex:2*i+1];
//for (i=0; i<200; i++) fprintf(stdout, " %ld",*((NSInteger*)a->pointers[i]));
//fprintf(stdout, "\n");
  i= [a indexOfObjectIdenticalTo:(id)q[97] inRange:NSMakeRange(0, 200)];
  TASSERT(test, i==195 && *((NSInteger*)[a objectAtIndex:i])==195 && q[97]==p+197, "Bad index(5): %lu",WLU(i));
  // remove
  [a removeObjectsInRange:NSMakeRange(10, 20)];
  TASSERT_EQUALS(test, [a count], 180, "Bad count(6): %lu",WLU(i));
  x= (NSUInteger*)[a objectAtIndex:10];
  TASSERT_EQUALS(test, *x, 30, "Bad int (7): %lu",WLU(*x));
  i= [a indexOfObjectIdenticalTo:(id)x inRange:NSMakeRange(0, [a count])];
  TASSERT_EQUALS(test, i, 10, "Bad index(8): %lu",WLU(i));
  // replace
  // 0 .. 9 30 .. 199 => 0 1 .. 8 9 1 3 .. 17 19 40 .. 199
  [a replaceObjectsInRange:NSMakeRange(10,10) withObjects:(id*)q copyItems:NO];
  i= CArrayRemoveIdenticalObject((CArray*)a, (id)q[3]); // 7
  TASSERT_EQUALS(test, i, 2, "Bad remove identical(9): %lu",WLU(i));
  i= [a indexOfObjectIdenticalTo:(id)q[4] inRange:NSMakeRange(0, [a count])];
  TASSERT_EQUALS(test, i, 8, "Bad index(10): %lu",WLU(i));
  i= [a indexOfObjectIdenticalTo:(id)q[50] inRange:NSMakeRange(0, [a count])];
  TASSERT_EQUALS(test, i, 101-20-2, "Bad index(11): %lu",WLU(i));
  RELEASE(a);
  }

static void carray_subarray(test_t *test)
  {
  NSUInteger i,j, n= 2*3*256;
  MSArray *a,*b,*d;
  NSArray *c;
  id o;
  a= [[MSArray alloc] mutableInitWithCapacity:n];
  o= [[MSArray alloc] mutableInitWithCapacity:0 noRetainRelease:YES nilItems:YES];
  [o addObject:nil];
  TASSERT_EQUALS(test, [o count], 1, "Bad count(30): %lu",WLU(((CArray*)o)->count));
  for (i=0; i<n; i++) {
    b= [[MSArray alloc] mutableInitWithCapacity:i+1];
    for (j=0; j<i+1; j++) [b addObject:o];
    [a addObject:b];
    RELEASE(b);}
  RELEASE(o);
  TASSERT_EQUALS(test, RETAINCOUNT(o), n*(n+1)/2, "Bad retain count(31): %lu",WLU(RETAINCOUNT(o)));
  c= [a subarrayWithRange:NSMakeRange(n/2, n/3)];
  TASSERT_EQUALS(test, [c count], n/3, "Bad count(32): %lu %lu",WLU([c count]),n/3);
  TASSERT_EQUALS(test, RETAINCOUNT(o), n*(n+1)/2, "Bad retain count(33): %lu %lu",WLU(RETAINCOUNT(o)),n*(n+1)/2);
  d= [[MSArray alloc] mutableInitWithCapacity:n/3];
  CArrayAddArray((CArray*)d, (CArray*)c, YES);
  TASSERT_EQUALS(test, RETAINCOUNT(o), n*(n+1)/2+(4*n+3)*n/18, "Bad retain count(34): %lu %lu",WLU(RETAINCOUNT(o)),n*(n+1)/2+(4*n+3)*n/18);
  RETAIN(o);
  RELEASE(a);
  //RELEASE(c); // Autorelease so NOT clean
  CArrayFreeInside(c);
  RELEASE(d);
  TASSERT_EQUALS(test, RETAINCOUNT(o), 1, "Bad retain count(35): %lu",WLU(RETAINCOUNT(o)));
  RELEASE(o);
  }

test_t msfoundation_array[]= {
  {"create"  ,NULL,array_create   ,INTITIALIZE_TEST_T_END},
  {"ptr"     ,NULL,carray_ptr     ,INTITIALIZE_TEST_T_END},
  {"subarray",NULL,carray_subarray,INTITIALIZE_TEST_T_END},
  {NULL}
};

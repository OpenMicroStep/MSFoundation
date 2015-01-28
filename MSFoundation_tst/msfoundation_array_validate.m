// msfoundation_array_validate.m, ecb, 130911

#include "msfoundation_validate.h"

static inline int array_create(void)
  {
  int err= 0;
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
  MSArray *a;
  a= [[MSArray alloc] mutableInitWithCapacity:0 noRetainRelease:YES nilItems:YES];
  for (i=0; i<100; i++) p[i]= 2*i;
  // Array of int
  [a addObjects:(id*)p count:100 copyItems:NO];
  i= [a indexOfObjectIdenticalTo:(id)(p[77]) inRange:NSMakeRange(0, 100)];
  if (i!=77 || p[i]!=154) {
    fprintf(stdout, "Bad index(3): %lu\n",WLU(i));
    err++;}
  [a removeAllObjects];
  // Array of int*
  for (i=0; i<100; i++) q[i]= p+i;
  [a addObjects:(id*)q count:100 copyItems:NO];
  i= [a indexOfObjectIdenticalTo:(id)(p+13) inRange:NSMakeRange(0, 100)];
  if (i!=13 || p[i]!=26 || q[i]!=p+i) {
    fprintf(stdout, "Bad index(4): %lu\n",WLU(i));
    err++;}
  // insert
  // p: 0 2 .. 198 1 3 .. 199
  // a: 0 1 .. .. .. 198 199
  for (i=0; i<100; i++) {p[100+i]= 2*i+1; q[i]= p+100+i;}
  for (i=0; i<100; i++) [a insertObject:(id)q[i] atIndex:2*i+1];
//for (i=0; i<200; i++) fprintf(stdout, " %ld",*((NSInteger*)a->pointers[i]));
//fprintf(stdout, "\n");
  i= [a indexOfObjectIdenticalTo:(id)q[97] inRange:NSMakeRange(0, 200)];
  if (i!=195 || *((NSInteger*)[a objectAtIndex:i])!=195 || q[97]!=p+197) {
    fprintf(stdout, "Bad index(5): %lu\n",WLU(i));
    err++;}
  // remove
  [a removeObjectsInRange:NSMakeRange(10, 20)];
  if ([a count]!=180) {
    fprintf(stdout, "Bad count(6): %lu\n",WLU(i));
    err++;}
  x= (NSUInteger*)[a objectAtIndex:10];
  if (*x!=30) {
    fprintf(stdout, "Bad int (7): %lu\n",WLU(*x));
    err++;}
  i= [a indexOfObjectIdenticalTo:(id)x inRange:NSMakeRange(0, [a count])];
  if (i!=10) {
    fprintf(stdout, "Bad index(8): %lu\n",WLU(i));
    err++;}
  // replace
  // 0 .. 9 30 .. 199 => 0 1 .. 8 9 1 3 .. 17 19 40 .. 199
  [a replaceObjectsInRange:NSMakeRange(10,10) withObjects:(id*)q copyItems:NO];
  i= CArrayRemoveIdenticalObject((CArray*)a, (id)q[3]); // 7
  if (i!=2) {
    fprintf(stdout, "Bad remove identical(9): %lu\n",WLU(i));
    err++;}
  i= [a indexOfObjectIdenticalTo:(id)q[4] inRange:NSMakeRange(0, [a count])];
  if (i!=8) {
    fprintf(stdout, "Bad index(10): %lu\n",WLU(i));
    err++;}
  i= [a indexOfObjectIdenticalTo:(id)q[50] inRange:NSMakeRange(0, [a count])];
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
  MSArray *a,*b,*d;
  NSArray *c;
  id o;
  a= [[MSArray alloc] mutableInitWithCapacity:n];
  o= [[MSArray alloc] mutableInitWithCapacity:0 noRetainRelease:YES nilItems:YES];
  [o addObject:nil];
  if ([o count]!=1) {
    fprintf(stdout, "Bad count(30): %lu\n",WLU(((CArray*)o)->count));
    err++;}
  for (i=0; i<n; i++) {
    b= [[MSArray alloc] mutableInitWithCapacity:i+1];
    for (j=0; j<i+1; j++) [b addObject:o];
    [a addObject:b];
    RELEASE(b);}
  RELEASE(o);
  if (RETAINCOUNT(o)!=n*(n+1)/2) {
    fprintf(stdout, "Bad retain count(31): %lu\n",WLU(RETAINCOUNT(o)));
    err++;}
  c= [a subarrayWithRange:NSMakeRange(n/2, n/3)];
  if ([c count]!=n/3) {
    fprintf(stdout, "Bad count(32): %lu %lu\n",WLU([c count]),n/3);
    err++;}
  if (RETAINCOUNT(o)!=n*(n+1)/2) {
    fprintf(stdout, "Bad retain count(33): %lu %lu\n",WLU(RETAINCOUNT(o)),n*(n+1)/2);
    err++;}
  d= [[MSArray alloc] mutableInitWithCapacity:n/3];
  CArrayAddArray((CArray*)d, (CArray*)c, YES);
  if (RETAINCOUNT(o)!=n*(n+1)/2+(4*n+3)*n/18) {
    fprintf(stdout, "Bad retain count(34): %lu %lu\n",WLU(RETAINCOUNT(o)),n*(n+1)/2+(4*n+3)*n/18);
    err++;}
  RETAIN(o);
  RELEASE(a);
  //RELEASE(c); // Autorelease so NOT clean
  CArrayFreeInside(c);
  RELEASE(d);
  if (RETAINCOUNT(o)!=1) {
    fprintf(stdout, "Bad retain count(35): %lu\n",WLU(RETAINCOUNT(o)));
    err++;}
  RELEASE(o);
  return err;
  }

TEST_FCT_BEGIN(MSArray)
    int err= 0;
    err+= array_create();
    err+= carray_ptr();
    err+= carray_subarray();
    return err;
TEST_FCT_END(MSArray)

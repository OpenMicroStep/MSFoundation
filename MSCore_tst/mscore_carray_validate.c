// mscore_carray_validate.c, ecb, 11/09/13

#import "MSCore.h"
#import "mscore_validate.h"

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

int mscore_carray_validate(void)
  {
  int err= 0;

  fprintf(stdout, "\n");

  err+= carray_create();
  err+= carray_ptr();

  fprintf(stdout, "=> CArray validate: %s\n",(err?"FAIL":"PASS"));
  return err;
  }


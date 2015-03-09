//
//  NSObject_test.m
//  MSFoundation
//
//  Created by Vincent Rouillé on 26/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#import "foundation_validate.h"

static int array_create(void)
{
  int err= 0;
  NSUInteger i,j, n= 20;
  NSArray *x; NSMutableArray *a,*b;
  a= [[NSMutableArray alloc] init];
  x= [[NSArray alloc] initWithObjects:@"test", nil];
  
  err+= ASSERT([a isKindOfClass:[NSMutableArray class]], "NSMutableArray is king of itself");
  err+= ASSERT_EQUALS([x retainCount], 1, "x retain count should be %2$d, got %1$d");
  for (i=0; i<n; i++) {
    b= [NSMutableArray alloc];
    b= [b initWithCapacity:i+1];
    for (j=0; j<i+1; j++) [b addObject:x];
    [a addObject:b];
    RELEASE(b);}
  err+= ASSERT_EQUALS([a count], n, "a has %2$d items, got %1$d");
  err+= ASSERT_EQUALS([x retainCount], 1+ ((n+1)*n)/2, "x retain count should be %2$d, got %1$d");
  RELEASE(a);
  err+= ASSERT_EQUALS([x retainCount], 1, "x retain count should be %2$d, got %1$d");
  RELEASE(x);
  return err;
}

static int array_mutate(void)
{
  int err= 0;
  NSUInteger i;
  id p[100];
  NSMutableArray *a, *b;
  a= [[NSMutableArray alloc] initWithCapacity:0];
  b= [[NSMutableArray alloc] initWithCapacity:0];
  for (i=0; i<100; i++) {
    p[i]= [[NSString alloc] initWithFormat:@"azertyuiop %d qsdfghjklm", (int)i];
    [a addObject:p[i]];}
  for (i=0; i<100; i++) {
    err+= ASSERT_EQUALS([p[i] retainCount], 2, "Item %1$d retain count should be %3$d, got %2$d", i);}
  [b addObjectsFromArray:a];
  err+= ASSERT_EQUALS([a count], 100, "Item inserted %2$d times, got %1$d");
  err+= ASSERT_EQUALS([b count], 100, "Item inserted %2$d times, got %1$d");
  i= [a indexOfObjectIdenticalTo:p[77] inRange:NSMakeRange(0, 100)];
  err+= ASSERT_EQUALS(i, 77, "Item is at index %2$d, got %1$d");
  [a removeAllObjects];
  err+= ASSERT_EQUALS([a count], 0, "All item were removed, got %1$d remaining");
  err+= ASSERT_EQUALS([b count], 100, "Untouched array with %2$d item, got %1$d");
  [b removeObjectsInRange:NSMakeRange(10, 20)];
  err+= ASSERT_EQUALS([b count], 80, "Array with 20 removed items, expected %2$d items, got %1$d");
  i= [b indexOfObjectIdenticalTo:p[21]];
  err+= ASSERT_EQUALS(i, NSNotFound, "Item at 21 is removed, NSNotFound(=%2$d) expected, got %1$d");
  i= [b indexOfObject:p[22]];
  err+= ASSERT_EQUALS(i, NSNotFound, "Item at 22 is removed, NSNotFound(=%2$d) expected, got %1$d");
  i= [b indexOfObjectIdenticalTo:p[30]];
  err+= ASSERT_EQUALS(i, 10, "Item is at index %2$d, got %1$d");
  i= [b indexOfObjectIdenticalTo:p[35]];
  err+= ASSERT_EQUALS(i, 15, "Item is at index %2$d, got %1$d");
  i= [b indexOfObjectIdenticalTo:p[79]];
  err+= ASSERT_EQUALS(i, 59, "Item is at index %2$d, got %1$d");
  i= [b indexOfObjectIdenticalTo:p[9]];
  err+= ASSERT_EQUALS(i, 9, "Item is at index %2$d, got %1$d");
  RELEASE(b);
  RELEASE(a);
  for (i=0; i<100; i++) {
    err+= ASSERT_EQUALS([p[i] retainCount], 1, "Item %1$d retain count should be %3$d, got %2$d", i);
    [p[i] release]; }
  return err;
}

static int array_subarray(void)
{
  int err= 0;
  NSUInteger i,j, n= 2*3*256;
  NSMutableArray *a,*b;
  NSArray *c;
  id o;
  NEW_POOL;
  a= [[NSMutableArray alloc] initWithCapacity:n];
  o= [[NSMutableArray alloc] initWithCapacity:0];
  for (i=0; i<n; i++) {
    b= [[NSMutableArray alloc] initWithCapacity:i+1];
    for (j=0; j<i+1; j++) [b addObject:o];
    [a addObject:b];
    RELEASE(b);}
  RELEASE(o);
  err+= ASSERT_EQUALS([o retainCount], n*(n+1)/2, "retain count, expected %2$d, got %1$d");
  c= [a subarrayWithRange:NSMakeRange(n/2, n/3)];
  err+= ASSERT_EQUALS([c count], n/3, "count, expected %2$d, got %1$d");
  RETAIN(o);
  RELEASE(a);
  KILL_POOL;
  err+= ASSERT_EQUALS([o retainCount], 1, "retain count, expected %2$d, got %1$d");
  RELEASE(o);
  return err;
}

test_t foundation_array[]= {
  {"create"    ,NULL,array_create  ,INTITIALIZE_TEST_T_END},
  {"mutability",NULL,array_mutate  ,INTITIALIZE_TEST_T_END},
  {"subarray"  ,NULL,array_subarray,INTITIALIZE_TEST_T_END},
  {NULL}
  };

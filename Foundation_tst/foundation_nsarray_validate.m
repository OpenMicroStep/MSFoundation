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
  NSUInteger i,j, n= 20;
  NSArray *x; NSMutableArray *a,*b;
  a= [[NSMutableArray alloc] init];
  x= [[NSArray alloc] initWithObjects:@"test", nil];
  
  ASSERT([a isKindOfClass:[NSMutableArray class]], "NSMutableArray is king of itself");
  ASSERT_EQUALS([x retainCount], 1, "x retain count should be %2$d, got %1$d");
  for (i=0; i<n; i++) {
    b= [[NSMutableArray alloc] initWithCapacity:i+1];
    for (j=0; j<i+1; j++) [b addObject:x];
    [a addObject:b];
    RELEASE(b);}
  ASSERT_EQUALS([a count], n, "a has %2$d items, got %1$d");
  ASSERT_EQUALS([x retainCount], 1+ ((n+1)*n)/2, "x retain count should be %2$d, got %1$d");
  RELEASE(a);
  ASSERT_EQUALS([x retainCount], 1, "x retain count should be %2$d, got %1$d");
  RELEASE(x);
  return 0;
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
    ASSERT_EQUALS([p[i] retainCount], 2, "Item %1$d retain count should be %3$d, got %2$d", i);}
  [b addObjectsFromArray:a];
  ASSERT_EQUALS([a count], 100, "Item inserted %2$d times, got %1$d");
  ASSERT_EQUALS([b count], 100, "Item inserted %2$d times, got %1$d");
  i= [a indexOfObjectIdenticalTo:p[77] inRange:NSMakeRange(0, 100)];
  ASSERT_EQUALS(i, 77, "Item is at index %2$d, got %1$d");
  [a removeAllObjects];
  ASSERT_EQUALS([a count], 0, "All item were removed, got %1$d remaining");
  ASSERT_EQUALS([b count], 100, "Untouched array with %2$d item, got %1$d");
  [b removeObjectsInRange:NSMakeRange(10, 20)];
  ASSERT_EQUALS([b count], 80, "Array with 20 removed items, expected %2$d items, got %1$d");
  i= [b indexOfObjectIdenticalTo:p[21]];
  ASSERT_EQUALS(i, NSNotFound, "Item at 21 is removed, NSNotFound(=%2$d) expected, got %1$d");
  i= [b indexOfObject:p[22]];
  ASSERT_EQUALS(i, NSNotFound, "Item at 22 is removed, NSNotFound(=%2$d) expected, got %1$d");
  i= [b indexOfObjectIdenticalTo:p[30]];
  ASSERT_EQUALS(i, 10, "Item is at index %2$d, got %1$d");
  i= [b indexOfObjectIdenticalTo:p[35]];
  ASSERT_EQUALS(i, 15, "Item is at index %2$d, got %1$d");
  i= [b indexOfObjectIdenticalTo:p[79]];
  ASSERT_EQUALS(i, 59, "Item is at index %2$d, got %1$d");
  i= [b indexOfObjectIdenticalTo:p[9]];
  ASSERT_EQUALS(i, 9, "Item is at index %2$d, got %1$d");
  RELEASE(b);
  RELEASE(a);
  for (i=0; i<100; i++) {
    ASSERT_EQUALS([p[i] retainCount], 1, "Item %1$d retain count should be %3$d, got %2$d", i);
    [p[i] release]; }
  return err;
}

static inline int array_subarray(void)
{
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
  ASSERT_EQUALS([o retainCount], n*(n+1)/2, "retain count, expected %2$d, got %1$d");
  c= [a subarrayWithRange:NSMakeRange(n/2, n/3)];
  ASSERT_EQUALS([c count], n/3, "count, expected %2$d, got %1$d");
  RETAIN(o);
  RELEASE(a);
  KILL_POOL;
  ASSERT_EQUALS([o retainCount], 1, "retain count, expected %2$d, got %1$d");
  RELEASE(o);
  return 0;
}

TEST_FCT_BEGIN(NSArray)
  testRun("create", array_create);
  testRun("mutability", array_mutate);
  testRun("subarray", array_subarray);
TEST_FCT_END(NSArray)

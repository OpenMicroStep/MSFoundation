//
//  NSObject_test.m
//  MSFoundation
//
//  Created by Vincent Rouillé on 26/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#import "foundation_validate.h"

static void array_create(test_t *test)
{
  NSUInteger i,j, n= 20;
  NSArray *x; NSMutableArray *a,*b;
  a= [[NSMutableArray alloc] init];
  x= [[NSArray alloc] initWithObjects:@"test", nil];
  
  TASSERT(test, [a isKindOfClass:[NSMutableArray class]], "NSMutableArray is king of itself");
  TASSERT_EQUALS(test, [x retainCount], 1, "x retain count should be %2$d, got %1$d");
  for (i=0; i<n; i++) {
    b= [NSMutableArray alloc];
    b= [b initWithCapacity:i+1];
    for (j=0; j<i+1; j++) [b addObject:x];
    [a addObject:b];
    RELEASE(b);}
  TASSERT_EQUALS(test, [a count], n, "a has %2$d items, got %1$d");
  TASSERT_EQUALS(test, [x retainCount], 1+ ((n+1)*n)/2, "x retain count should be %2$d, got %1$d");
  RELEASE(a);
  TASSERT_EQUALS(test, [x retainCount], 1, "x retain count should be %2$d, got %1$d");
  RELEASE(x);
}

static void array_mutate(test_t *test)
{
  NSUInteger i;
  id p[100];
  NSMutableArray *a, *b;
  a= [[NSMutableArray alloc] initWithCapacity:0];
  b= [[NSMutableArray alloc] initWithCapacity:0];
  for (i=0; i<100; i++) {
    p[i]= [[NSString alloc] initWithFormat:@"azertyuiop %d qsdfghjklm", (int)i];
    [a addObject:p[i]];}
  for (i=0; i<100; i++) {
    TASSERT_EQUALS(test, [p[i] retainCount], 2, "Item %1$d retain count should be %3$d, got %2$d", i);}
  [b addObjectsFromArray:a];
  TASSERT_EQUALS(test, [a count], 100, "Item inserted %2$d times, got %1$d");
  TASSERT_EQUALS(test, [b count], 100, "Item inserted %2$d times, got %1$d");
  i= [a indexOfObjectIdenticalTo:p[77] inRange:NSMakeRange(0, 100)];
  TASSERT_EQUALS(test, i, 77, "Item is at index %2$d, got %1$d");
  [a removeAllObjects];
  TASSERT_EQUALS(test, [a count], 0, "All item were removed, got %1$d remaining");
  TASSERT_EQUALS(test, [b count], 100, "Untouched array with %2$d item, got %1$d");
  [b removeObjectsInRange:NSMakeRange(10, 20)];
  TASSERT_EQUALS(test, [b count], 80, "Array with 20 removed items, expected %2$d items, got %1$d");
  i= [b indexOfObjectIdenticalTo:p[21]];
  TASSERT_EQUALS(test, i, NSNotFound, "Item at 21 is removed, NSNotFound(=%2$d) expected, got %1$d");
  i= [b indexOfObject:p[22]];
  TASSERT_EQUALS(test, i, NSNotFound, "Item at 22 is removed, NSNotFound(=%2$d) expected, got %1$d");
  i= [b indexOfObjectIdenticalTo:p[30]];
  TASSERT_EQUALS(test, i, 10, "Item is at index %2$d, got %1$d");
  i= [b indexOfObjectIdenticalTo:p[35]];
  TASSERT_EQUALS(test, i, 15, "Item is at index %2$d, got %1$d");
  i= [b indexOfObjectIdenticalTo:p[79]];
  TASSERT_EQUALS(test, i, 59, "Item is at index %2$d, got %1$d");
  i= [b indexOfObjectIdenticalTo:p[9]];
  TASSERT_EQUALS(test, i, 9, "Item is at index %2$d, got %1$d");
  RELEASE(b);
  RELEASE(a);
  for (i=0; i<100; i++) {
    TASSERT_EQUALS(test, [p[i] retainCount], 1, "Item %1$d retain count should be %3$d, got %2$d", i);
    [p[i] release]; }
}

static void array_subarray(test_t *test)
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
  TASSERT_EQUALS(test, [o retainCount], n*(n+1)/2, "retain count, expected %2$d, got %1$d");
  c= [a subarrayWithRange:NSMakeRange(n/2, n/3)];
  TASSERT_EQUALS(test, [c count], n/3, "count, expected %2$d, got %1$d");
  RETAIN(o);
  RELEASE(a);
  KILL_POOL;
  TASSERT_EQUALS(test, [o retainCount], 1, "retain count, expected %2$d, got %1$d");
  RELEASE(o);
}

static void array_enum(test_t *test)
{
  id a,e,o,o0,o1,oi; NSUInteger i;
  o0= @"1"; o1= @"2";
  a= [NSArray arrayWithObjects:o0, o1, nil];
  e= [a objectEnumerator];
  for (i= 0 ; (o= [e nextObject]); i++) {
    oi= (i==0?o0:o1);
    TASSERT_ISEQUAL(test, o, oi, "%s != %s",[o UTF8String],[oi UTF8String]);}
  e= [a reverseObjectEnumerator];
  for (i= 0 ; (o= [e nextObject]); i++) {
    oi= (i==0?o1:o0);
    TASSERT_ISEQUAL(test, o, oi, "%s != %s",[o UTF8String],[oi UTF8String]);}
}

test_t foundation_array[]= {
  {"create"     ,NULL,array_create  ,INTITIALIZE_TEST_T_END},
  {"mutability" ,NULL,array_mutate  ,INTITIALIZE_TEST_T_END},
  {"subarray"   ,NULL,array_subarray,INTITIALIZE_TEST_T_END},
  {"enumeration",NULL,array_enum    ,INTITIALIZE_TEST_T_END},
  {NULL}};

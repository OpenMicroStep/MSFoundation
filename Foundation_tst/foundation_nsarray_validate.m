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
  NEW_POOL;
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
  KILL_POOL;
}

static void array_mutate(test_t *test)
{
  NEW_POOL;
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
  KILL_POOL;
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
  NEW_POOL;
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
  KILL_POOL;
}

#pragma mark Subclass

@interface MyArray : NSArray
@end

id _o1= @"first object";
id _o2= @"second object";
@implementation MyArray
- (NSUInteger)count
{
  return 2;
}
- (id)objectAtIndex:(NSUInteger)index
{
  return index==0 ? _o1 : index==1 ? _o2 : nil;
}
@end

@interface MyFastArray : NSArray
@end

static NSUInteger _MyFastArrayCount(id array)
{
  return 2;
}
static id _MyFastArrayObjectAtIndex(id array, NSUInteger index)
{
  return index==0 ? _o1 : index==1 ? _o2 : nil;
}
const static struct garray_pfs_s MyFastArrayPfs= {
  _MyFastArrayCount,
  _MyFastArrayObjectAtIndex
};

// Sans les primitives méthodes pour être sûr de bien passer par les fonctions.
@implementation MyFastArray
- (garray_pfs_t)_garray_pfs
{
  return &MyFastArrayPfs;
}
#ifdef MSFOUNDATION_FORCOCOA // Sinon, en COCOA makeObjectsPerformSelector va demander count sur MyFastArray
- (NSUInteger)count
{ return _MyFastArrayCount(self); }
- (id)objectAtIndex:(NSUInteger)index
{ return _MyFastArrayObjectAtIndex(self, index); }
#endif
@end

static void _array_subclass(test_t *test, Class cl)
{
  NEW_POOL;
  id o,d,e,x,y,os[2]; int i;
  o= [[cl alloc] init];
  if (cl==[MyArray class]) TASSERT_EQUALS(test, [o count], 2, "count is %llu, expected %llu");
  d= [o description];
  x= @"(\n    \"first object\",\n    \"second object\"\n)"; // Cocoa
  y= @"(first object, second object)";
  TASSERT(test, [d isEqual:x] || [d isEqual:y], "%s",[d UTF8String]);
  TASSERT_ISEQUAL(test, [o firstObject], _o1, "%s != %s",[[o firstObject] UTF8String],"first object");
  TASSERT_ISEQUAL(test, [o lastObject], _o2, "%s != %s",[[o lastObject] UTF8String],"second object");
  TASSERT(test, [o containsObject:_o1], "%d");
  TASSERT(test, [o containsObjectIdenticalTo:_o2], "%d");
  TASSERT_EQUALS(test, [o indexOfObject:_o1], 0, "%llu != %llu");
  TASSERT_EQUALS(test, [o indexOfObject:_o1 inRange:((NSRange){0,1})],          0, "%llu != %llu");
  TASSERT_EQUALS(test, [o indexOfObject:_o1 inRange:((NSRange){1,1})], NSNotFound, "%llu != %llu");
  TASSERT_EQUALS(test, [o indexOfObject:_o2], 1, "%llu != %llu");
  TASSERT_EQUALS(test, [o indexOfObject:_o2 inRange:((NSRange){0,1})], NSNotFound, "%llu != %llu");
  TASSERT_EQUALS(test, [o indexOfObject:_o2 inRange:((NSRange){1,1})],          1, "%llu != %llu");
  TASSERT_EQUALS(test, [o indexOfObjectIdenticalTo:_o1], 0, "%llu != %llu");
  TASSERT_EQUALS(test, [o indexOfObjectIdenticalTo:_o2 inRange:((NSRange){1,1})],1, "%llu != %llu");
  e= [o objectEnumerator];
  for (i= 0; (x= [e nextObject]); i++) {
    TASSERT_ISEQUAL(test, x, (i==0?_o1:_o2), "%s %d",[x UTF8String],i);}
  TASSERT_EQUALS(test, i, 2, "count is %llu, expected %llu");
  e= [o reverseObjectEnumerator];
  for (i= 0; (x= [e nextObject]); i++) {
    TASSERT_ISEQUAL(test, x, (i==0?_o2:_o1), "%s %d",[x UTF8String],i);}
  TASSERT_EQUALS(test, i, 2, "count is %llu, expected %llu");
  [o makeObjectsPerformSelector:@selector(length)];
  [o getObjects:os];
  TASSERT_ISEQUAL(test, os[0], _o1, "%s != %s",[os[0] UTF8String],"first object");
  TASSERT_ISEQUAL(test, os[1], _o2, "%s != %s",[os[1] UTF8String],"second object");
  RELEASE(o);
  KILL_POOL;
}

static void array_subclass(test_t *test)
{
  _array_subclass(test, [MyArray class]);
}

static void array_fast_subclass(test_t *test)
{
  _array_subclass(test, [MyFastArray class]);
}

@implementation NSArray (NSArrayTestsCategory)
- (NSString *)myCustomSelectorOnNSArray
{
  return @"SelectorOnNSArray";
}
@end
@implementation NSMutableArray (NSArrayTestsCategory)
- (NSString *)myCustomSelectorOnNSMutableArray
{
  return @"SelectorOnNSMutableArray";
}
@end
static void array_category(test_t *test)
{
  NEW_POOL;
  NSArray *arrStatic= [[NSArray arrayWithObjects:_o1, _o2, nil] copy];
  NSMutableArray *arrMutable= [arrStatic mutableCopy];

  TASSERT_EQUALS_OBJ(test, [arrStatic myCustomSelectorOnNSArray], @"SelectorOnNSArray");
  TASSERT_EQUALS_OBJ(test, [arrMutable myCustomSelectorOnNSArray], @"SelectorOnNSArray");
  TASSERT_EQUALS_OBJ(test, [arrMutable myCustomSelectorOnNSMutableArray], @"SelectorOnNSMutableArray");

  RELEASE(arrStatic);
  RELEASE(arrMutable);
  KILL_POOL;
}

test_t foundation_array[]= {
  {"create"       ,NULL,array_create       ,INTITIALIZE_TEST_T_END},
  {"mutability"   ,NULL,array_mutate       ,INTITIALIZE_TEST_T_END},
  {"subarray"     ,NULL,array_subarray     ,INTITIALIZE_TEST_T_END},
  {"enumeration"  ,NULL,array_enum         ,INTITIALIZE_TEST_T_END},
  {"subclass"     ,NULL,array_subclass     ,INTITIALIZE_TEST_T_END},
  {"fast subclass",NULL,array_fast_subclass,INTITIALIZE_TEST_T_END},
  {"category"     ,NULL,array_category     ,INTITIALIZE_TEST_T_END},
  {NULL}};

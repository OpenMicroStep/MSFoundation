#import "foundation_validate.h"

struct NSInvocation_TestStruct {
  int8_t _i1;
  int16_t _i2;
  int32_t _i4;
  int64_t _i8;
  char test[1024];
};
struct NSInvocation_TestStruct2 {
  int64_t _i8;
  int16_t _i2;
  char test[1024];
  int8_t _i1;
  int32_t _i4;
};
@interface NSInvocation_TestClass : NSObject {
@public
  int8_t _i1;
  int16_t _i2;
  int32_t _i4;
  int64_t _i8;
}
- (int32_t)returnTypeTest;
@end

@implementation NSInvocation_TestClass
- (int32_t)returnTypeTest { return INT_MAX; }
- (void)paramsTypeTest:(int8_t)i1 i2:(int16_t)i2 i4:(int32_t)i4 i8:(int64_t)i8
{
  _i1= i1;
  _i2= i2;
  _i4= i4;
  _i8= i8;
}
- (struct NSInvocation_TestStruct)complex1:(int8_t)i1 i2:(int16_t)i2 i4:(int32_t)i4 i8:(int64_t)i8
{
  struct NSInvocation_TestStruct s;
  s._i1= i1;
  s._i2= i2;
  s._i4= i4;
  s._i8= i8;
  return s;
}
- (struct NSInvocation_TestStruct2)complex2:(struct NSInvocation_TestStruct)s2
{
  struct NSInvocation_TestStruct2 s;
  s._i1= s2._i1;
  s._i2= s2._i2;
  s._i4= s2._i4;
  s._i8= s2._i8;
  memcpy(s.test, s2.test, 1024);
  return s;
}
- (int64_t)complex3:(int64_t[4])in
{
  return in[0] + in[1] + in[2] + in[3];
}
- (id)fwdObjectAtIndex:(NSUInteger)idx
{
  return FMT(@"forwarded result: %lld", (MSLong)idx);
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
  if (sel_isEqual(aSelector, @selector(objectAtIndex:)))
    aSelector= @selector(fwdObjectAtIndex:);
  return [super methodSignatureForSelector:aSelector];
}
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
  if(sel_isEqual([anInvocation selector], @selector(objectAtIndex:))) {
    [anInvocation setSelector:@selector(fwdObjectAtIndex:)];
    [anInvocation invoke];
  }
  else {
    [super forwardInvocation:anInvocation];
  }
}
@end

static void invocation_simple(test_t *test)
{
  NSUInteger retainCountBefore;
  NSMethodSignature *s; NSInvocation *i; id o;
  o= [NSInvocation_TestClass new];
  retainCountBefore= [o retainCount];
  s= [o methodSignatureForSelector:@selector(retain)];
  i= [NSInvocation invocationWithMethodSignature:s];
  TASSERT_EQUALS_OBJ(test, [i methodSignature], s);
  [i setTarget:o];
  TASSERT_EQUALS_OBJ(test, [i target], o);
  [i setSelector:@selector(retain)];
  TASSERT_EQUALS_OBJ(test, [i target], o);
  TASSERT_EQUALS_PTR(test, [i selector], @selector(retain));
  [i invoke];
  TASSERT_EQUALS_LLU(test, [o retainCount], retainCountBefore + 1);
  [o release];
}

static void invocation_return(test_t *test)
{
  int32_t r; int ret_int; char ret_char; double ret_flt; id ret_id;
  NSMethodSignature *s; NSInvocation *i; id o;
  o= [[NSInvocation_TestClass new] autorelease];

  s= [o methodSignatureForSelector:@selector(returnTypeTest)];
  i= [NSInvocation invocationWithMethodSignature:s];
  [i setTarget:o];
  TASSERT_EQUALS_OBJ(test, [i target], o);
  [i setSelector:@selector(returnTypeTest)];
  TASSERT_EQUALS_OBJ(test, [i target], o);
  TASSERT_EQUALS_SEL(test, [i selector], @selector(returnTypeTest));
  [i invoke];
  [i getReturnValue:&r];
  TASSERT_EQUALS_LLD(test, r, INT_MAX);

  o= [NSNumber numberWithDouble:272.2];
  i= [NSInvocation invocationWithMethodSignature:[o methodSignatureForSelector:@selector(intValue)]];
  [i setTarget:o];
  [i setSelector:@selector(intValue)];
  [i invoke];
  [i getReturnValue:&ret_int];
  TASSERT_EQUALS_LLD(test, ret_int, 272);
#ifndef MSFOUNDATION_FORCOCOA
  i= [NSInvocation invocationWithMethodSignature:[o methodSignatureForSelector:@selector(charValue)]];
  [i setTarget:o];
  [i setSelector:@selector(charValue)];
  [i invoke];
  [i getReturnValue:&ret_char];
  TASSERT_EQUALS_LLD(test, ret_char, 127);
#endif
  i= [NSInvocation invocationWithMethodSignature:[o methodSignatureForSelector:@selector(doubleValue)]];
  [i setTarget:o];
  [i setSelector:@selector(doubleValue)];
  [i invoke];
  [i getReturnValue:&ret_flt];
  TASSERT_EQUALS_DBL(test, ret_flt, 272.2);
}

static void invocation_complex(test_t *test)
{
  struct NSInvocation_TestStruct obs, st, st2, st3;
  struct NSInvocation_TestStruct2 s2t;
  int64_t arr_arg[4], *arr_chk, *arr_ptr, arr_ret;
  NSMethodSignature *s; NSInvocation *i; NSInvocation_TestClass *o;
  o= [[NSInvocation_TestClass new] autorelease];

  s= [o methodSignatureForSelector:@selector(paramsTypeTest:i2:i4:i8:)];
  i= [NSInvocation invocationWithMethodSignature:s];
  [i setTarget:o];
  [i setSelector:@selector(paramsTypeTest:i2:i4:i8:)];
  st._i1= 101;
  st._i2= 3402;
  st._i4= 133404;
  st._i8= ((MSLong)INT_MAX) * 2;
  memcpy(&obs, &st, sizeof(obs));
  [i setArgument:&st._i1 atIndex:2];
  [i setArgument:&st._i2 atIndex:3];
  [i setArgument:&st._i4 atIndex:4];
  [i setArgument:&st._i8 atIndex:5];
  TASSERT_EQUALS_OBJ(test, [i target], o);
  TASSERT_EQUALS_SEL(test, [i selector], @selector(paramsTypeTest:i2:i4:i8:));
  memset(&st2, 0, sizeof(st2));
  [i getArgument:&st2._i1 atIndex:2];
  [i getArgument:&st2._i2 atIndex:3];
  [i getArgument:&st2._i4 atIndex:4];
  [i getArgument:&st2._i8 atIndex:5];
  TASSERT_EQUALS_LLD(test, st2._i1, st._i1);
  TASSERT_EQUALS_LLD(test, st2._i2, st._i2);
  TASSERT_EQUALS_LLD(test, st2._i4, st._i4);
  TASSERT_EQUALS_LLD(test, st2._i8, st._i8);
  [i invoke];
  TASSERT_EQUALS_LLD(test, o->_i1, st._i1);
  TASSERT_EQUALS_LLD(test, o->_i2, st._i2);
  TASSERT_EQUALS_LLD(test, o->_i4, st._i4);
  TASSERT_EQUALS_LLD(test, o->_i8, st._i8);
  TASSERT_EQUALS_LLD(test, memcmp(&st, &obs, sizeof(obs)), 0);

  s= [o methodSignatureForSelector:@selector(complex1:i2:i4:i8:)];
  i= [NSInvocation invocationWithMethodSignature:s];
  [i setTarget:o];
  [i setSelector:@selector(complex1:i2:i4:i8:)];
  st._i1= 105;
  st._i2= 3402;
  st._i4= 13504;
  st._i8= ((MSLong)INT_MAX) * 3;
  memcpy(&obs, &st, sizeof(obs));
  [i setArgument:&st._i1 atIndex:2];
  [i setArgument:&st._i2 atIndex:3];
  [i setArgument:&st._i4 atIndex:4];
  [i setArgument:&st._i8 atIndex:5];
  TASSERT_EQUALS_OBJ(test, [i target], o);
  TASSERT_EQUALS_SEL(test, [i selector], @selector(complex1:i2:i4:i8:));
  memset(&st2, 0, sizeof(st2));
  [i getArgument:&st2._i1 atIndex:2];
  [i getArgument:&st2._i2 atIndex:3];
  [i getArgument:&st2._i4 atIndex:4];
  [i getArgument:&st2._i8 atIndex:5];
  TASSERT_EQUALS_LLD(test, st2._i1, st._i1);
  TASSERT_EQUALS_LLD(test, st2._i2, st._i2);
  TASSERT_EQUALS_LLD(test, st2._i4, st._i4);
  TASSERT_EQUALS_LLD(test, st2._i8, st._i8);
  [i invoke];
  memset(&st3, 0, sizeof(st3));
  [i getReturnValue:&st3];
  TASSERT_EQUALS_LLD(test, st3._i1, st._i1);
  TASSERT_EQUALS_LLD(test, st3._i2, st._i2);
  TASSERT_EQUALS_LLD(test, st3._i4, st._i4);
  TASSERT_EQUALS_LLD(test, st3._i8, st._i8);
  TASSERT_EQUALS_LLD(test, memcmp(&st, &obs, sizeof(obs)), 0);

  s= [o methodSignatureForSelector:@selector(complex2:)];
  i= [NSInvocation invocationWithMethodSignature:s];
  [i setTarget:o];
  [i setSelector:@selector(complex2:)];
  st._i1= 105;
  st._i2= 3402;
  st._i4= 13504;
  st._i8= ((MSLong)INT_MAX) * 3;
  memcpy(st.test, "0123456789", 10);
  memcpy(&obs, &st, sizeof(obs));
  [i setArgument:&st atIndex:2];
  TASSERT_EQUALS_OBJ(test, [i target], o);
  TASSERT_EQUALS_SEL(test, [i selector], @selector(complex2:));
  memset(&st2, 0, sizeof(st2));
  [i getArgument:&st2 atIndex:2];
  TASSERT_EQUALS_LLD(test, st2._i1, st._i1);
  TASSERT_EQUALS_LLD(test, st2._i2, st._i2);
  TASSERT_EQUALS_LLD(test, st2._i4, st._i4);
  TASSERT_EQUALS_LLD(test, st2._i8, st._i8);
  TASSERT_EQUALS_LLD(test, memcmp(st2.test, st.test, sizeof(st3.test)), 0);
  [i invoke];
  memset(&s2t, 0, sizeof(s2t));
  [i getReturnValue:&s2t];
  TASSERT_EQUALS_LLD(test, s2t._i1, st._i1);
  TASSERT_EQUALS_LLD(test, s2t._i2, st._i2);
  TASSERT_EQUALS_LLD(test, s2t._i4, st._i4);
  TASSERT_EQUALS_LLD(test, s2t._i8, st._i8);
  TASSERT_EQUALS_LLD(test, memcmp(s2t.test, st.test, sizeof(s2t.test)), 0);
  TASSERT_EQUALS_LLD(test, memcmp(&st, &obs, sizeof(obs)), 0);

  s= [o methodSignatureForSelector:@selector(complex3:)];
  i= [NSInvocation invocationWithMethodSignature:s];
  [i setTarget:o];
  [i setSelector:@selector(complex3:)];
  arr_arg[0]= ((MSLong)INT_MAX) * 2LL;
  arr_arg[1]= ((MSLong)INT_MAX) * -3LL;
  arr_arg[2]= ((MSLong)INT_MAX) * 4LL;
  arr_arg[3]= ((MSLong)INT_MAX) * -5LL;
  arr_ptr= arr_arg;
  [i setArgument:&arr_ptr atIndex:2];
  TASSERT_EQUALS_OBJ(test, [i target], o);
  TASSERT_EQUALS_SEL(test, [i selector], @selector(complex3:));
  memset(&arr_chk, 0, sizeof(arr_chk));
  [i getArgument:&arr_chk atIndex:2];
  TASSERT_EQUALS_LLD(test, arr_chk[0], ((MSLong)INT_MAX) * 2LL);
  TASSERT_EQUALS_LLD(test, arr_chk[1], ((MSLong)INT_MAX) * -3LL);
  TASSERT_EQUALS_LLD(test, arr_chk[2], ((MSLong)INT_MAX) * 4LL);
  TASSERT_EQUALS_LLD(test, arr_chk[3], ((MSLong)INT_MAX) * -5LL);
  [i invoke];
  [i getReturnValue:&arr_ret];
  TASSERT_EQUALS_LLD(test, arr_ret, arr_arg[0] + arr_arg[1] + arr_arg[2] + arr_arg[3]);
}


static void invocation_forward(test_t *test)
{
  NSMethodSignature *s; NSInvocation *i; id o;
  o= [NSInvocation_TestClass new];
  TASSERT_EQUALS_OBJ(test, [o objectAtIndex:0], @"forwarded result: 0");
}

testdef_t foundation_invocation[]= {
  {"simple",NULL,invocation_simple},
  {"return types",NULL,invocation_return},
  {"complex call",NULL,invocation_complex},
  {"forwarding",NULL,invocation_forward},
  {NULL}};

#import "foundation_validate.h"

struct NSMethodSignature_TestStruct {
  int8_t _i1;
  int16_t _i2;
  int32_t _i4;
  int64_t _i8;
  char test[1024];
};
struct NSMethodSignature_TestStruct2 {
  int64_t _i8;
  int16_t _i2;
  int32_t _i4;
  int8_t _i1;
  char test[1024];
};
@interface NSMethodSignature_TestClass : NSObject {
@public
  int8_t _i1;
  int16_t _i2;
  int32_t _i4;
  int64_t _i8;
}
- (int32_t)returnTypeTest;
@end

@implementation NSMethodSignature_TestClass
- (int32_t)returnTypeTest { return INT_MAX; }
- (void)paramsTypeTest:(int8_t)i1 i2:(int16_t)i2 i4:(int32_t)i4 i8:(int64_t)i8
{
  _i1= i1;
  _i2= i2;
  _i4= i4;
  _i8= i8;
}
- (struct NSMethodSignature_TestStruct)complex1:(int8_t)i1 i2:(int16_t)i2 i4:(int32_t)i4 i8:(int64_t)i8
{
  struct NSMethodSignature_TestStruct s;
  s._i1= i1;
  s._i2= i2;
  s._i4= i4;
  s._i8= i8;
  return s;
}
- (struct NSMethodSignature_TestStruct)complex2:(struct NSMethodSignature_TestStruct2)s2
{
  struct NSMethodSignature_TestStruct s;
  s._i1= s2._i1;
  s._i2= s2._i2;
  s._i4= s2._i4;
  s._i8= s2._i8;
  memcpy(s.test, s2.test, 1024);
  return s;
}
@end

static void methodsignature_new(test_t *test)
{
  NSMethodSignature_TestClass *o;
  NSMethodSignature *s;

  o= [NSMethodSignature_TestClass new];

  s= [o methodSignatureForSelector:@selector(retain)];
  TASSERT(test, s, "signature of retain must exists");
  TASSERT_EQUALS_LLU(test, [s numberOfArguments], 2); // self, _cmd
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:0], "@");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:1], ":");
  TASSERT_EQUALS_STR(test, [s methodReturnType], "@");
  TASSERT_EQUALS_LLD(test, [s isOneway], 0);

  s= [o methodSignatureForSelector:@selector(release)];
  TASSERT(test, s, "signature of release must exists");
  TASSERT_EQUALS_LLU(test, [s numberOfArguments], 2); // self, _cmd
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:0], "@");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:1], ":");
  TASSERT_EQUALS_STR(test, [s methodReturnType], "Vv");
  TASSERT_EQUALS_LLD(test, [s isOneway], 1);

  s= [o methodSignatureForSelector:@selector(returnTypeTest)];
  TASSERT(test, s, "signature of returnTypeTest must exists");
  TASSERT_EQUALS_LLU(test, [s numberOfArguments], 2); // self, _cmd
  TASSERT_EQUALS_LLU(test, [s methodReturnLength], 4);
  TASSERT_EQUALS_STR(test, [s methodReturnType], "i");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:0], "@");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:1], ":");

  s= [o methodSignatureForSelector:@selector(paramsTypeTest:i2:i4:i8:)];
  TASSERT(test, s, "signature of paramsTypeTest:i2:i4:i8: must exists");
  TASSERT_EQUALS_LLU(test, [s numberOfArguments], 2 + 4); // self, _cmd
  TASSERT_EQUALS_LLU(test, [s methodReturnLength], 0);
  TASSERT_EQUALS_STR(test, [s methodReturnType], "v");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:0], "@");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:1], ":");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:2], "c");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:3], "s");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:4], "i");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:5], "q");

  s= [o methodSignatureForSelector:@selector(complex1:i2:i4:i8:)];
  TASSERT(test, s, "signature of complex1:i2:i4:i8: must exists");
  TASSERT_EQUALS_LLU(test, [s numberOfArguments], 2 + 4); // self, _cmd
  TASSERT_EQUALS_LLU(test, [s methodReturnLength], 1040);
  TASSERT_EQUALS_STR(test, [s methodReturnType], "{NSMethodSignature_TestStruct=csiq[1024c]}");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:0], "@");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:1], ":");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:2], "c");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:3], "s");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:4], "i");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:5], "q");

  s= [o methodSignatureForSelector:@selector(complex2:)];
  TASSERT(test, s, "signature of complex1:i2:i4:i8: must exists");
  TASSERT_EQUALS_LLU(test, [s numberOfArguments], 3); // self, _cmd
  TASSERT_EQUALS_LLU(test, [s methodReturnLength], 1040);
  TASSERT_EQUALS_STR(test, [s methodReturnType], "{NSMethodSignature_TestStruct=csiq[1024c]}");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:0], "@");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:1], ":");
  TASSERT_EQUALS_STR(test, [s getArgumentTypeAtIndex:2], "{NSMethodSignature_TestStruct2=qsic[1024c]}");

  RELEASE(o);
}


testdef_t foundation_methodsign[]= {
  {"methodsignature_new",NULL,methodsignature_new},
  {NULL}};

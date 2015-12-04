#import "foundation_validate.h"

static void objcruntime_selector(test_t *test)
{
  NEW_POOL;
  SEL sel; NSString *str;

  sel= NSSelectorFromString(@"initWith:test:");
  TASSERT(test, sel, "selector must be created");
  str= NSStringFromSelector(sel);
  TASSERT_EQUALS_OBJ(test, str, @"initWith:test:");

  TASSERT(test, !NSSelectorFromString(nil), "NSSelectorFromString should return nil if string is nil");

  KILL_POOL;
}

static void objcruntime_class(test_t *test)
{
  NEW_POOL;
  Class cls; NSString *str;

  cls= NSClassFromString(@"NSObject");
  TASSERT(test, cls, "NSObject class exists");
  str= NSStringFromClass(cls);
  TASSERT_EQUALS_OBJ(test, str, @"NSObject");

  TASSERT(test, !NSClassFromString(@"azertyuiop"), "NSClassFromString should return nil if class doesn't exists");
  TASSERT(test, !NSClassFromString(nil), "NSClassFromString should return nil if string is nil");

  KILL_POOL;
}

static void objcruntime_protocol(test_t *test)
{
  NEW_POOL;
  Protocol *protocol; NSString *str;

  protocol= NSProtocolFromString(@"NSObject");
  TASSERT(test, protocol, "NSObject protocol exists");
  str= NSStringFromProtocol(protocol);
  TASSERT_EQUALS_OBJ(test, str, @"NSObject");

  TASSERT(test, !NSProtocolFromString(@"azertyuiop"), "NSProtocolFromString should return nil if protocol doesn't exists");
  TASSERT(test, !NSProtocolFromString(nil), "NSProtocolFromString should return nil if string is nil");

  KILL_POOL;
}

static void objcruntime_alloc(test_t *test)
{
  NEW_POOL;
  id a;

  a= NSAllocateObject([NSObject class], 0, NULL);
  TASSERT(test, a, "object not allocated");
  TASSERT(test, ISA(a) == [NSObject class], "class differ");
  NSDeallocateObject(a);

  KILL_POOL;
}

struct _objctype_test
{
  int8_t i1;
  int16_t i2;
  int32_t i3;
  int64_t i4;
  char str[5];
};
const char *type_i4 = @encode(int32_t);
const char *type_u8 = @encode(uint64_t);
const char *type_struct = @encode(struct _objctype_test);

#define TASSERT_EQUALS_TYPEEND(W, A, B) TASSERT_EQUALS(W, A, B, "\"%s\"@%p != \"%s\"@%p", __a, __a, __b, __b)

static void objcruntime_types(test_t *test)
{
  NEW_POOL;
  NSUInteger size, align; const char *next;

  next= NSGetSizeAndAlignment(type_i4, &size, &align);
  TASSERT_EQUALS_TYPEEND(test, next, type_i4 + 1);
  TASSERT_EQUALS_LLU(test, size, 4);

  next= NSGetSizeAndAlignment(type_u8, &size, &align);
  TASSERT_EQUALS_TYPEEND(test, next, type_u8 + 1);
  TASSERT_EQUALS_LLU(test, size, 8);

  next= NSGetSizeAndAlignment(type_struct, &size, &align);
  TASSERT_EQUALS_TYPEEND(test, next, type_struct + 25);
  TASSERT_EQUALS_LLU(test, size, 24);

  KILL_POOL;
}

testdef_t foundation_objcruntime[]= {
  {"selector <-> string"  ,NULL,objcruntime_selector},
  {"class <-> string"     ,NULL,objcruntime_class},
  {"protocol <-> string"  ,NULL,objcruntime_protocol},
  {"alloc/dealloc"        ,NULL,objcruntime_alloc},
  {"objc type size/align" ,NULL,objcruntime_types},
  {NULL}};

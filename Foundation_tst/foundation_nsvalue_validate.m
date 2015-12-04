#import "foundation_validate.h"

struct _TestType {
  char a;
  int b;
  long long c;
  double d;
};

static void value_mixed(test_t *test)
{
  NEW_POOL;
  NSValue *v0, *v1, *v2;
  MSULong llu0, llu1;
  struct _TestType t0, t1;

  llu1= 0; llu0= ((MSLong)INT_MAX) * 5LL;
  t1.a= 0; t0.a= 1;
  t1.b= 0; t0.b= 123456;
  t1.c= 0; t0.c= ((MSLong)INT_MAX) * 4LL;
  t1.d= 0; t0.d= 123456789.987654;

  v0= [NSValue valueWithBytes:&t0 objCType:@encode(struct _TestType)];
  [v0 getValue:&t1];
  v1= AUTORELEASE([ALLOC(NSValue) initWithBytes:&t0 objCType:@encode(struct _TestType)]);
  v2= [NSValue valueWithBytes:&llu0 objCType:@encode(MSULong)];
  [v2 getValue:&llu1];

  TASSERT_EQUALS_OBJ(test, v0, v1);
  TASSERT_EQUALS_OBJ(test, v1, v0);
  TASSERT_NOTEQUALS_OBJ(test, v1, v2);
  TASSERT_NOTEQUALS_OBJ(test, v2, v0);

  TASSERT_EQUALS_STR(test, [v0 objCType], "{_TestType=ciqd}");
  TASSERT_EQUALS_STR(test, [v1 objCType], "{_TestType=ciqd}");
  TASSERT_EQUALS_STR(test, [v2 objCType], "Q");
  TASSERT_EQUALS_LLD(test, t0.a, t1.a);
  TASSERT_EQUALS_LLD(test, t0.b, t1.b);
  TASSERT_EQUALS_LLD(test, t0.c, t1.c);
  TASSERT_EQUALS_LLD(test, t0.d, t1.d);
  TASSERT(test, memcmp(&t0, &t1, sizeof(struct _TestType)) == 0, "retrieved value differ of stored value");
  TASSERT_EQUALS_LLD(test, llu0, llu1);

  KILL_POOL;
}

testdef_t foundation_value[]= {
  {"mixed"   ,NULL,value_mixed    },
  {NULL}};

#import "foundation_validate.h"

static void null_equal(test_t *test)
{
  NSNull *n1, *n2, *n3, *n4;
  NSObject *o;
  n1= [NSNull new];
  n2= [NSNull null];
  n3= [[NSNull alloc] init];
  n4= [n1 copy];
  o=  [NSObject new];
  TASSERT_EQUALS    (test, n1, n2, "NSNull address must be the same");
  TASSERT_EQUALS    (test, n1, n3, "NSNull address must be the same");
  TASSERT_EQUALS    (test, n1, n4, "NSNull address must be the same");
  TASSERT_ISEQUAL   (test, n1, n2, "NSNull are equals");
  TASSERT_ISEQUAL   (test, n1, n3, "NSNull are equals");
  TASSERT_ISEQUAL   (test, n1, n4, "NSNull are equals");
  TASSERT_ISNOTEQUAL(test, n1,  o, "NSNull != NSObject");
  RELEASE(o);
  RELEASE(n1);
  RELEASE(n3);
  RELEASE(n4);
}

test_t foundation_null[]= {
  {"equal",NULL,null_equal,INTITIALIZE_TEST_T_END},
  {NULL}};

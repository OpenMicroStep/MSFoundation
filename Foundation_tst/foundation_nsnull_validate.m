#import "foundation_validate.h"

TEST_FCT_BEGIN(NSNull)
  NSNull *n1, *n2, *n3, *n4;
  NSObject *o;
  n1= [NSNull new];
  n2= [NSNull null];
  n3= [[NSNull alloc] init];
  n4= [n1 copy];
  o= [NSObject new];
  ASSERT_EQUALS(n1, n2, "NSNull address must be the same");
  ASSERT_EQUALS(n1, n3, "NSNull address must be the same");
  ASSERT_EQUALS(n1, n4, "NSNull address must be the same");
  ASSERT_ISEQUAL(n1, n2, "NSNull are equals");
  ASSERT_ISEQUAL(n1, n3, "NSNull are equals");
  ASSERT_ISEQUAL(n1, n4, "NSNull are equals");
  ASSERT_ISNOTEQUAL(n1, o, "NSNull != NSObject");
  RELEASE(o);
  RELEASE(n1);
  RELEASE(n3);
  RELEASE(n4);
TEST_FCT_END(NSNull)
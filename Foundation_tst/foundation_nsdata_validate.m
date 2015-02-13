#import "foundation_validate.h"

static inline int nsbuffer(void)
{
  const char str[]= "123456789 123456789 123456789 123456789 123456789 123456789 ";
  char buffer[60];
  const NSUInteger strLen= 60;
  NSMutableData *d, *d2;
  NSData *cd;
  d= [NSMutableData new];
  ASSERT([d isKindOfClass:[NSMutableData class]], "NSMutableData objects expected");
  ASSERT([d isKindOfClass:[NSData class]], "NSData objects expected");
  [d appendBytes:str length:strLen];
  [d appendData:d];
  ASSERT_EQUALS([d length], strLen * 2, "data length must be %2$d, got %1$d");
  ASSERT(memcmp([d bytes], str, strLen) == 0, "the %d first bytes must match", strLen);
  ASSERT(memcmp([d bytes] + strLen, str, strLen) == 0, "the %d first bytes must match", strLen);
  [d getBytes:buffer length:20];
  ASSERT(memcmp(buffer, str, 20) == 0, "the %d first bytes must match", 20);
  [d getBytes:buffer range:NSMakeRange(21, 14)];
  ASSERT(memcmp(buffer, str + 21, 14) == 0, "bytes must match");
  d2= [d copy];
  ASSERT_ISEQUAL(d, d2, "d & d2 are equals");
  ASSERT([d isEqualToData:d2], "d & d2 are equals");
  [d appendBytes:"TEST" length:4];
  ASSERT_ISNOTEQUAL(d, d2, "d & d2 aren't equals anymore");
  ASSERT(![d isEqualToData:d2], "d & d2 aren't equals anymore");
  RELEASE(d2);
  cd= [d subdataWithRange:NSMakeRange(21, 14)];
  ASSERT(memcmp([cd bytes], buffer, 14) == 0, "bytes must match");
  d2= [[NSData data] mutableCopy];
  ASSERT_EQUALS([d2 length], 0, "data length must be %2$d, got %1$d");
  [d2 appendBytes:"1234" length:4];
  ASSERT_EQUALS([d2 length], 4, "data length must be %2$d, got %1$d");
  ASSERT_ISNOTEQUAL(d, d2, "d & d2 aren't equals anymore");
  [d setData:d2];
  ASSERT_ISEQUAL(d, d2, "d & d2 are equals");
  RELEASE(d2);
  RELEASE(d);
  d= [[NSMutableData alloc] initWithCapacity:10];
  RELEASE(d);
  d= [NSMutableData dataWithCapacity:20];
  d= [[NSMutableData alloc] initWithLength:10];
  RELEASE(d);
  d= [NSMutableData dataWithLength:20];
  return 0;
}

TEST_FCT_BEGIN(NSData)
	NEW_POOL;
	nsbuffer();
	KILL_POOL;
	return 0;
TEST_FCT_END(NSData)

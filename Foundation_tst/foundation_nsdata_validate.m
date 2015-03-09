#import "foundation_validate.h"

static int data_buffer()
{
  int err= 0;
  const char str[]= "123456789 123456789 123456789 123456789 123456789 123456789 ";
  char buffer[60];
  const NSUInteger strLen= 60;
  NSMutableData *d, *d2;
  NSData *cd;
	NEW_POOL;
  d= [NSMutableData new];
  err+= ASSERT([d isKindOfClass:[NSMutableData class]], "NSMutableData objects expected");
  err+= ASSERT([d isKindOfClass:[NSData class]], "NSData objects expected");
  [d appendBytes:str length:strLen];
  [d appendData:d];
  err+= ASSERT_EQUALS([d length], strLen * 2, "data length must be %2$d, got %1$d");
  err+= ASSERT(memcmp([d bytes], str, strLen) == 0, "the %d first bytes must match", strLen);
  err+= ASSERT(memcmp([d bytes] + strLen, str, strLen) == 0, "the %d first bytes must match", strLen);
  [d getBytes:buffer length:20];
  err+= ASSERT(memcmp(buffer, str, 20) == 0, "the %d first bytes must match", 20);
  [d getBytes:buffer range:NSMakeRange(21, 14)];
  err+= ASSERT(memcmp(buffer, str + 21, 14) == 0, "bytes must match");
  d2= [d copy];
  err+= ASSERT_ISEQUAL(d, d2, "d & d2 are equals");
  err+= ASSERT([d isEqualToData:d2], "d & d2 are equals");
  [d appendBytes:"TEST" length:4];
  err+= ASSERT_ISNOTEQUAL(d, d2, "d & d2 aren't equals anymore");
  err+= ASSERT(![d isEqualToData:d2], "d & d2 aren't equals anymore");
  RELEASE(d2);
  cd= [d subdataWithRange:NSMakeRange(21, 14)];
  err+= ASSERT(memcmp([cd bytes], buffer, 14) == 0, "bytes must match");
  d2= [[NSData data] mutableCopy];
  err+= ASSERT_EQUALS([d2 length], 0, "data length must be %2$d, got %1$d");
  [d2 appendBytes:"1234" length:4];
  err+= ASSERT_EQUALS([d2 length], 4, "data length must be %2$d, got %1$d");
  err+= ASSERT_ISNOTEQUAL(d, d2, "d & d2 aren't equals anymore");
  [d setData:d2];
  err+= ASSERT_ISEQUAL(d, d2, "d & d2 are equals");
  RELEASE(d2);
  RELEASE(d);
  d= [[NSMutableData alloc] initWithCapacity:10];
  RELEASE(d);
  d= [NSMutableData dataWithCapacity:20];
  d= [[NSMutableData alloc] initWithLength:10];
  RELEASE(d);
  d= [NSMutableData dataWithLength:20];
	KILL_POOL;
  return err;
}

test_t foundation_data[]= {
  {"create"    ,NULL,data_buffer,INTITIALIZE_TEST_T_END},
  {NULL}};

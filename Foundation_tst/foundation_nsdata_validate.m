#import "foundation_validate.h"

static void data_buffer(test_t *test)
{
  const char str[]= "123456789 123456789 123456789 123456789 123456789 123456789 ";
  char buffer[60];
  const NSUInteger strLen= 60;
  NSMutableData *d, *d2;
  NSData *cd;
	NEW_POOL;
  d= [NSMutableData new];
  TASSERT(test, [d isKindOfClass:[NSMutableData class]], "NSMutableData objects expected");
  TASSERT(test, [d isKindOfClass:[NSData class]], "NSData objects expected");
  [d appendBytes:str length:strLen];
  [d appendData:d];
  TASSERT_EQUALS(test, [d length], strLen * 2, "data length must be %2$d, got %1$d");
  TASSERT(test, memcmp([d bytes], str, strLen) == 0, "the %d first bytes must match", strLen);
  TASSERT(test, memcmp([d bytes] + strLen, str, strLen) == 0, "the %d first bytes must match", strLen);
  [d getBytes:buffer length:20];
  TASSERT(test, memcmp(buffer, str, 20) == 0, "the %d first bytes must match", 20);
  [d getBytes:buffer range:NSMakeRange(21, 14)];
  TASSERT(test, memcmp(buffer, str + 21, 14) == 0, "bytes must match");
  d2= [d copy];
  TASSERT_ISEQUAL(test, d, d2, "d & d2 are equals");
  TASSERT(test, [d isEqualToData:d2], "d & d2 are equals");
  [d appendBytes:"TEST" length:4];
  TASSERT_ISNOTEQUAL(test, d, d2, "d & d2 aren't equals anymore");
  TASSERT(test, ![d isEqualToData:d2], "d & d2 aren't equals anymore");
  RELEASE(d2);
  cd= [d subdataWithRange:NSMakeRange(21, 14)];
  TASSERT(test, memcmp([cd bytes], buffer, 14) == 0, "bytes must match");
  d2= [[NSData data] mutableCopy];
  TASSERT_EQUALS(test, [d2 length], 0, "data length must be %2$d, got %1$d");
  [d2 appendBytes:"1234" length:4];
  TASSERT_EQUALS(test, [d2 length], 4, "data length must be %2$d, got %1$d");
  TASSERT_ISNOTEQUAL(test, d, d2, "d & d2 aren't equals anymore");
  [d setData:d2];
  TASSERT_ISEQUAL(test, d, d2, "d & d2 are equals");
  RELEASE(d2);
  RELEASE(d);
  d= [[NSMutableData alloc] initWithCapacity:10];
  RELEASE(d);
  d= [NSMutableData dataWithCapacity:20];
  d= [[NSMutableData alloc] initWithLength:10];
  RELEASE(d);
  d= [NSMutableData dataWithLength:20];
	KILL_POOL;
}

test_t foundation_data[]= {
  {"create"    ,NULL,data_buffer,INTITIALIZE_TEST_T_END},
  {NULL}};

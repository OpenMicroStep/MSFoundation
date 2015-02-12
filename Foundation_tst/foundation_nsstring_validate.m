//
//  NSObject_test.m
//  MSFoundation
//
//  Created by Vincent Rouillé on 26/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#import "foundation_validate.h"

static inline int ns_eq(void)
  {
  int err= 0;
  NSString *ns,*ms;
  ns= ms= nil;
  ASSIGN(ns, @"");
  ASSIGN(ms, [NSString stringWithCString:"" encoding:NSUTF8StringEncoding]);
  if (!ISEQUAL(ns, ms)) {
    NSLog(@"A20 not equal %@ != %@",ns,ms); err++;}
  if (!ISEQUAL(ms, ns)) {
    NSLog(@"A21 not equal %@ != %@",ms,ns); err++;}
  ASSIGN(ms, [NSString stringWithCString:"a string" encoding:NSUTF8StringEncoding]);
  if (ISEQUAL(ns, ms)) {
    NSLog(@"A22 equal %@ == %@",ns,ms); err++;}
  if (ISEQUAL(ms, ns)) {
    NSLog(@"A23 equal %@ == %@",ms,ns); err++;}
  ASSIGN(ns, @"a string");
  if (!ISEQUAL(ns, ms)) {
    NSLog(@"A24 not equal %@ != %@",ns,ms); err++;}
  if (!ISEQUAL(ms, ns)) {
    NSLog(@"A25 not equal %@ != %@",ms,ns); err++;}
  ASSIGN(ms, [NSString stringWithCString:"" encoding:NSUTF8StringEncoding]);
  if (ISEQUAL(ns, ms)) {
    NSLog(@"A26 equal %@ == %@",ns,ms); err++;}
  if (ISEQUAL(ms, ns)) {
    NSLog(@"A27 equal %@ == %@",ms,ns); err++;}
  RELEASE(ns);
  RELEASE(ms);
  return err;
  }

static inline int ns_cast(void)
{
  int err= 0;
  int intValue;
  NSInteger integerValue;
  long long longLongValue;
  
  // intValue test
  intValue = [@"123456789" intValue];
  if(intValue != 123456789) {
    NSLog(@"A28 not equal %d != %d",intValue, 123456789); err++;}
  
  intValue = [@"-123456789" intValue];
  if(intValue != -123456789) {
    NSLog(@"A29 not equal %d != %d",intValue, -123456789); err++;}
  
  intValue = [@"123456789123456789" intValue];
  if(intValue != INT_MAX) {
    NSLog(@"A30 not equal %d != %d",intValue, INT_MAX); err++;}
  
  intValue = [@"-123456789123456789" intValue];
  if(intValue != INT_MIN) {
    NSLog(@"A31 not equal %d != %d",intValue, INT_MIN); err++;}
  
  intValue = [@"Not an int" intValue];
  if(intValue != 0) {
    NSLog(@"A32 not equal %d != %d",intValue, 0); err++;}
  
  // longLongValue test
  longLongValue = [@"123456789123456789" longLongValue];
  if(longLongValue != 123456789123456789LL) {
    NSLog(@"A33 not equal %lld != %lld",longLongValue, 123456789123456789LL); err++;}
  
  longLongValue = [@"-123456789123456789" longLongValue];
  if(longLongValue != -123456789123456789LL) {
    NSLog(@"A34 not equal %lld != %lld",longLongValue, -123456789123456789LL); err++;}
  
  longLongValue = [@"123456789123456789123456789" longLongValue];
  if(longLongValue != LLONG_MAX) {
    NSLog(@"A35 not equal %lld != %lld",longLongValue, LLONG_MAX); err++;}
  
  longLongValue = [@"-123456789123456789123456789" longLongValue];
  if(longLongValue != LLONG_MIN) {
    NSLog(@"A36 not equal %lld != %lld",longLongValue, LLONG_MIN); err++;}
  
  longLongValue = [@"Not an long long" longLongValue];
  if(longLongValue != 0) {
    NSLog(@"A37 not equal %lld != %lld",longLongValue, 0LL); err++;}
  
  // integerValue test
  integerValue = [@"123456789" integerValue];
  if(integerValue != 123456789) {
    NSLog(@"A38 not equal %ld != %d",integerValue, 123456789); err++;}
  
  integerValue = [@"-123456789" integerValue];
  if(integerValue != -123456789) {
    NSLog(@"A39 not equal %ld != %d",integerValue, -123456789); err++;}
  
  integerValue = [@"Not an integer" integerValue];
  if(integerValue != 0) {
    NSLog(@"A40 not equal %ld != %d",integerValue, 0); err++;}
  
  return err;
}

#define ASSERT_FORMAT(EXPECT, FORMAT, ...) ({\
  NSString *__f= [ALLOC(NSString) initWithFormat:@FORMAT, ##__VA_ARGS__]; \
  int __n= snprintf(NULL, 0, FORMAT, ##__VA_ARGS__); \
  char __b[__n + 1]; \
  snprintf(__b, __n + 1, FORMAT, ##__VA_ARGS__); \
  ASSERT(strcasecmp(EXPECT, __b) == 0, "expected: '%s', got: '%s'", EXPECT, __b); \
  ASSERT([@EXPECT isEqual:__f], "expected: '%s', got: '%s'", EXPECT, [__f UTF8String]); \
  RELEASE(__f); })

#define ASSERT_NSFORMAT(EXPECT, FORMAT, ...) ({ \
  NSString *__f= [ALLOC(NSString) initWithFormat:FORMAT, ##__VA_ARGS__]; \
  ASSERT([EXPECT isEqual:__f], "expected: '%s', got: '%s'", [EXPECT UTF8String], [__f UTF8String]); \
  RELEASE(__f); })

static inline int ns_format(void)
{
  int intValue = 2;
  long long max = LLONG_MAX;
  long long min = LLONG_MIN;
  long long negvalue1 = -1LL;
  long long posvalue1 = 1LL;
  long long negvalue2 = -2332036854779808LL;
  long long posvalue2 = 22337236854775808LL;
  unsigned long long umax = ULLONG_MAX;
  unsigned long long uposvalue1 = 1ULL;
  unsigned long long uposvalue2 = 22337236854775808ULL;
  
  // Test signed decimals
  ASSERT_FORMAT("%hhd: min=-127 max=+127 mid=52",
                "%%hhd: min=%hhd max=%+hhd mid=%hhd", (char)-127, (char)+127, (char)52);
  ASSERT_FORMAT("%hd: min=-32767 max=+32767 mid=12345",
                "%%hd: min=%hd max=%+hd mid=%hd", (short)-32767, (short)+32767, (short)12345);
  ASSERT_FORMAT("%d: min=-2147483647 max=+2147483647 mid=1234567890",
                "%%d: min=%d max=%+d mid=%d", (int)-2147483647, (int)+2147483647, (int)1234567890);
  ASSERT_FORMAT("%ld: min=-2147483647 max=+2147483647 mid=1234567890",
                "%%ld: min=%ld max=%+ld mid=%ld", (long)-2147483647, (long)+2147483647, (long)1234567890);
  ASSERT_FORMAT("%lld: min=-9223372036854775807 max=+9223372036854775807 mid=123456789012345",
                "%%lld: min=%lld max=%+lld mid=%lld", (long long)-9223372036854775807LL, (long long)+9223372036854775807LL, (long long)123456789012345LL);
  
  // Test unsigned decimals
  ASSERT_FORMAT("%hhu: max=255 mid=52",
                "%%hhu: max=%hhu mid=%hhu", (unsigned char)255U, (unsigned char)52);
  ASSERT_FORMAT("%hu: max=65535 mid=12345",
                "%%hu: max=%hu mid=%hu", (unsigned short)65535U, (unsigned short)12345);
  ASSERT_FORMAT("%u: max=4294967295 mid=1234567890",
                "%%u: max=%u mid=%u", (unsigned int)4294967295, (unsigned int)1234567890);
  ASSERT_FORMAT("%lu: max=4294967295 mid=1234567890",
                "%%lu: max=%lu mid=%lu", (unsigned long)4294967295, (unsigned long)1234567890);
  ASSERT_FORMAT("%llu: max=18446744073709551615 mid=123456789012345",
                "%%llu: max=%llu mid=%llu", 18446744073709551615ULL, 123456789012345ULL);
  
  // Test unsigned octals
  ASSERT_FORMAT("%hho: max=377 mid=64",
                "%%hho: max=%hho mid=%hho", (unsigned char)255U, (unsigned char)52);
  ASSERT_FORMAT("%ho: max=177777 mid=30071",
                "%%ho: max=%ho mid=%ho", (unsigned short)65535U, (unsigned short)12345);
  ASSERT_FORMAT("%o: max=37777777777 mid=11145401322",
                "%%o: max=%o mid=%o", (unsigned int)4294967295, (unsigned int)1234567890);
  ASSERT_FORMAT("%lo: max=37777777777 mid=11145401322",
                "%%lo: max=%lo mid=%lo", (unsigned long)4294967295, (unsigned long)1234567890);
  ASSERT_FORMAT("%llo: max=1777777777777777777777 mid=3404420603357571",
                "%%llo: max=%llo mid=%llo", 18446744073709551615ULL, 123456789012345ULL);
  
  // Test unsigned hex
  ASSERT_FORMAT("%hhx: max=ff mid=34",
                "%%hhx: max=%hhx mid=%hhX", (unsigned char)255U, (unsigned char)52);
  ASSERT_FORMAT("%hx: max=ffff mid=3039",
                "%%hx: max=%hx mid=%hX", (unsigned short)65535U, (unsigned short)12345);
  ASSERT_FORMAT("%x: max=ffffffff mid=499602D2",
                "%%x: max=%x mid=%X", (unsigned int)4294967295, (unsigned int)1234567890);
  ASSERT_FORMAT("%lx: max=ffffffff mid=499602D2",
                "%%lx: max=%lx mid=%lX", (unsigned long)4294967295, (unsigned long)1234567890);
  ASSERT_FORMAT("%llx: max=ffffffffffffffff mid=7048860DDF79",
                "%%llx: max=%llx mid=%llX", 18446744073709551615ULL, 123456789012345ULL);
  
  // Test float
  ASSERT_FORMAT("float: %f=1234.500000 %e=1.234500e+01 %E=1.234500E+04 %g=0.12345 %G=1.2345 %a=0x1.edccccccccccdp+6 %A=0X1.81C8P+13",
                "float: %%f=%5$f %%e=%3$e %%E=%7$E %%g=%1$g %%G=%2$G %%a=%4$a %%A=%6$A", 0.12345, 1.23450, 12.3450, 123.450, 1234.50, 12345.00, 12345.0);
  ASSERT_FORMAT("float: %f=+500000000000000022442856339037958392774656.000000 %e=5.00200e-03 %E= 1.268715E+04 %g=465.64999999999997726 %G=65432.19999999999709 %a=  0x1.176592e000p+38 %A=0X1.0C6F7A0B5ED8DP-20",
                "float: %%f=%3$+010.6f %%e=%7$.5e %%E=%5$ 010E %%g=%1$.20g %%G=%2$10.20G %%a=%4$20.10a %%A=%6$15A", 465.650, 65432.20, 50e40, 30e10, 12687.15, 0.000001, 0.005002);
  
  // Test pointers
#ifdef __LP64__
  ASSERT_FORMAT("%p: min=0x8000000000000000 max=0x7fffffffffffffff mid=0x7048860ddf79",
                "%%p: min=%p max=%p mid=%p", (void*)INTPTR_MIN, (void*)INTPTR_MAX, (void*)123456789012345ULL);
#else
  ASSERT_FORMAT("%p: min=0x80000000 max=0x7fffffff mid=0xbc614e",
                "%%p: min=%p max=%p mid=%p", (void*)INTPTR_MIN, (void*)INTPTR_MAX, (void*)12345678ULL);
#endif

  
  // Test flags, width, precision
  ASSERT_FORMAT("sign: 545 +5641675  5124136",
                "sign: %d %+d % d", 545, 5641675, 5124136);
  ASSERT_FORMAT("width:       1461 13541           +7984      +6706 +450      ",
                "width: %10d %-10d %+10d %+10d %+-10d", 1461, 13541 ,7984, 6706, 450);
  ASSERT_FORMAT("width:       1461 13541            7984       6706 450       ",
                "width: %10u %-10u %10u %10u %-10u", 1461, 13541 ,7984, 6706, 450);
  ASSERT_FORMAT("0pad: %010d=0000001461 %-10d=13541      %+010d=+000007984 %+010d=+000006706 %+-10d=+450      ",
                "0pad: %%010d=%010d %%-10d=%-10d %%+010d=%+010d %%+010d=%+010d %%+-10d=%+-10d", 1461, 13541 ,7984, 6706, 450);
  ASSERT_FORMAT("0pad: %010u=0000001461 %-10u=13541      %010u=0000007984 %010u=0000006706 %-10u=450       ",
                "0pad: %%010u=%010u %%-10u=%-10u %%010u=%010u %%010u=%010u %%-10u=%-10u", 1461, 13541 ,7984, 6706, 450);
  ASSERT_FORMAT("prec: %*.*d=0000020 %*.*d=    0013 %0*.*d=      013",
                "prec: %%*.*d=%*.*d %%*.*d=%*.*d %%0*.*d=%0*.*d", 5, 7, 20, 8, 4, 13, 9, 3, 13);
  ASSERT_FORMAT("prec: %.10d=0000001461 %.11d=00000013541 %13.10d=   0000007984 %10.12d=000000006706 %*.*d=0000020 %*.*d=    0013",
                "prec: %%.10d=%.10d %%.11d=%.11d %%13.10d=%13.10d %%10.12d=%10.12d %%*.*d=%*.*d %%*.*d=%*.*d", 1461, 13541 ,7984, 6706, 5, 7, 20, 8, 4, 13);
  
  // ObjC
  ASSERT_NSFORMAT(@"objc: test", @"objc: %@", @"test");
  
  // Old Tests
  ASSERT_FORMAT("22337236854775808",
                "%lld", posvalue2);
  ASSERT_FORMAT("start -9223372036854775808 -2332036854779808 -1",
                "%s %lld %lld %lld", "start", min, negvalue2, negvalue1);
  ASSERT_FORMAT("start -9223372036854775808 -2332036854779808 -1 2 1 22337236854775808 9223372036854775807 end",
                "%s %lld %lld %lld %d %lld %lld %lld %s", "start", min, negvalue2, negvalue1, intValue, posvalue1, posvalue2, max, "end");
  ASSERT_FORMAT("22337236854775808",
                "%llu", (unsigned long long)posvalue2);
  ASSERT_FORMAT("start 18446744073709551615 22337236854775808 1",
                "%s %llu %llu %llu", "start", umax, uposvalue2, uposvalue1);
  ASSERT_FORMAT("start 18446744073709551615 2 1 22337236854775808 end",
                "%s %llu %d %llu %llu %s", "start", umax, intValue, uposvalue1, uposvalue2, "end");
  
  return 0;
}

TEST_FCT_BEGIN(NSString)
  int err= 0;
  err+= ns_eq();
  err+= ns_cast();
  err+= ns_format();
  return err;
TEST_FCT_END(NSString)
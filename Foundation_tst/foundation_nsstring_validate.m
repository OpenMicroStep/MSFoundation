//
//  NSObject_test.m
//  MSFoundation
//
//  Created by Vincent Rouillé on 26/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#import "foundation_validate.h"

static void string_eq(test_t *test)
  {
  NSString *ns,*ms;
  ns= ms= nil;
  ASSIGN(ns, @"");
  ASSIGN(ms, [NSString stringWithCString:"" encoding:NSUTF8StringEncoding]);
  TASSERT_ISEQUAL(   test, ns, ms, "%s != %s",[ns UTF8String],[ms UTF8String]);
  TASSERT_ISEQUAL(   test, ms, ns, "%s != %s",[ms UTF8String],[ns UTF8String]);
  ASSIGN(ms, [NSString stringWithCString:"a string" encoding:NSUTF8StringEncoding]);
  TASSERT_ISNOTEQUAL(test, ns, ms, "%s == %s",[ns UTF8String],[ms UTF8String]);
  TASSERT_ISNOTEQUAL(test, ms, ns, "%s == %s",[ms UTF8String],[ns UTF8String]);
  ASSIGN(ns, @"a string");
  TASSERT_ISEQUAL(   test, ns, ms, "%s != %s",[ns UTF8String],[ms UTF8String]);
  TASSERT_ISEQUAL(   test, ms, ns, "%s != %s",[ms UTF8String],[ns UTF8String]);
  ASSIGN(ms, [NSString stringWithCString:"" encoding:NSUTF8StringEncoding]);
  TASSERT_ISNOTEQUAL(test, ns, ms, "%s == %s",[ns UTF8String],[ms UTF8String]);
  TASSERT_ISNOTEQUAL(test, ms, ns, "%s == %s",[ms UTF8String],[ns UTF8String]);
  RELEASE(ns);
  RELEASE(ms);
  }

#define TASSERT_STRING_EQUALS(FMT, T, A, M, B, E) TASSERT_STRING_EQUALS_OPT(FMT, T, A, M, B, , E)
#define TASSERT_STRING_EQUALS_OPT(FMT, T, A, M, B, M2, E) \
  TASSERT_EQUALS_ ## FMT(T, [@A M: @B M2], E); \
  TASSERT_EQUALS_ ## FMT(T, [[NSString stringWithUTF8String:A] M:[NSString stringWithUTF8String:B] M2], E); \
  TASSERT_EQUALS_ ## FMT(T, [@A M:[NSString stringWithUTF8String:B] M2], E); \
  TASSERT_EQUALS_ ## FMT(T, [[NSString stringWithUTF8String:A] M:@B M2], E)

static void string_compare(test_t *test)
{
  NEW_POOL;
  TASSERT_STRING_EQUALS(LLD, test, ""    , compare, ""    , NSOrderedSame);
  TASSERT_STRING_EQUALS(LLD, test, ""    , compare, "a"   , NSOrderedAscending);
  TASSERT_STRING_EQUALS(LLD, test, "a"   , compare, ""    , NSOrderedDescending);
  TASSERT_STRING_EQUALS(LLD, test, "a"   , compare, "a"   , NSOrderedSame);
  TASSERT_STRING_EQUALS(LLD, test, "a"   , compare, "aa"  , NSOrderedAscending);
  TASSERT_STRING_EQUALS(LLD, test, "aa"  , compare, "a"   , NSOrderedDescending);
  TASSERT_STRING_EQUALS(LLD, test, "abc" , compare, "abc" , NSOrderedSame);
  TASSERT_STRING_EQUALS(LLD, test, "abca", compare, "abcb", NSOrderedAscending);
  TASSERT_STRING_EQUALS(LLD, test, "abcd", compare, "abcb", NSOrderedDescending);
  TASSERT_STRING_EQUALS(LLD, test, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", compare, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", NSOrderedSame);
  TASSERT_STRING_EQUALS(LLD, test, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", compare, "éèàô¡®œ±ĀϿḀ⓿⣿㊿", NSOrderedDescending);
  TASSERT_STRING_EQUALS(LLD, test, "éèàô¡®œ±ĀϿḀ⓿⣿㊿", compare, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", NSOrderedAscending);

  TASSERT_STRING_EQUALS(LLD, test, ""    , caseInsensitiveCompare, ""    , NSOrderedSame);
  TASSERT_STRING_EQUALS(LLD, test, ""    , caseInsensitiveCompare, "a"   , NSOrderedAscending);
  TASSERT_STRING_EQUALS(LLD, test, "a"   , caseInsensitiveCompare, ""    , NSOrderedDescending);
  TASSERT_STRING_EQUALS(LLD, test, "a"   , caseInsensitiveCompare, "a"   , NSOrderedSame);
  TASSERT_STRING_EQUALS(LLD, test, "a"   , caseInsensitiveCompare, "aa"  , NSOrderedAscending);
  TASSERT_STRING_EQUALS(LLD, test, "aa"  , caseInsensitiveCompare, "a"   , NSOrderedDescending);
  TASSERT_STRING_EQUALS(LLD, test, "abc" , caseInsensitiveCompare, "abc" , NSOrderedSame);
  TASSERT_STRING_EQUALS(LLD, test, "abca", caseInsensitiveCompare, "abcb", NSOrderedAscending);
  TASSERT_STRING_EQUALS(LLD, test, "abcd", caseInsensitiveCompare, "abcb", NSOrderedDescending);
  TASSERT_STRING_EQUALS(LLD, test, "a"   , caseInsensitiveCompare, "A"   , NSOrderedSame);
  TASSERT_STRING_EQUALS(LLD, test, "abc" , caseInsensitiveCompare, "AbC" , NSOrderedSame);
  TASSERT_STRING_EQUALS(LLD, test, "abca", caseInsensitiveCompare, "ABCB", NSOrderedAscending);
  TASSERT_STRING_EQUALS(LLD, test, "ABCB", caseInsensitiveCompare, "abca", NSOrderedDescending);
  TASSERT_STRING_EQUALS(LLD, test, "abcd", caseInsensitiveCompare, "ABCB", NSOrderedDescending);
  TASSERT_STRING_EQUALS(LLD, test, "ABCB", caseInsensitiveCompare, "abcd", NSOrderedAscending);
  TASSERT_STRING_EQUALS(LLD, test, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", caseInsensitiveCompare, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", NSOrderedSame);
  TASSERT_STRING_EQUALS(LLD, test, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", caseInsensitiveCompare, "éèàô¡®œ±ĀϿḀ⓿⣿㊿", NSOrderedDescending);
  TASSERT_STRING_EQUALS(LLD, test, "éèàô¡®œ±ĀϿḀ⓿⣿㊿", caseInsensitiveCompare, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", NSOrderedAscending);

  TASSERT_STRING_EQUALS(LLD, test, "abcde",hasPrefix, "abc" ,YES);
  TASSERT_STRING_EQUALS(LLD, test, ""    , hasPrefix, ""    , NO);
  TASSERT_STRING_EQUALS(LLD, test, ""    , hasPrefix, "a"   , NO);
  TASSERT_STRING_EQUALS(LLD, test, "a"   , hasPrefix, ""    , NO);
  TASSERT_STRING_EQUALS(LLD, test, "a"   , hasPrefix, "a"   ,YES);
  TASSERT_STRING_EQUALS(LLD, test, "a"   , hasPrefix, "aa"  , NO);
  TASSERT_STRING_EQUALS(LLD, test, "aa"  , hasPrefix, "a"   ,YES);
  TASSERT_STRING_EQUALS(LLD, test, "abc" , hasPrefix, "abc" ,YES);
  TASSERT_STRING_EQUALS(LLD, test, "abca", hasPrefix, "abcb", NO);
  TASSERT_STRING_EQUALS(LLD, test, "abcd", hasPrefix, "abcb", NO);
  TASSERT_STRING_EQUALS(LLD, test, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", hasPrefix, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", YES);
  TASSERT_STRING_EQUALS(LLD, test, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", hasPrefix, "éèàô¡®œ±ĀϿḀ⓿⣿㊿", YES);
  TASSERT_STRING_EQUALS(LLD, test, "éèàô¡®œ±ĀϿḀ⓿⣿㊿", hasPrefix, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", NO);

  TASSERT_STRING_EQUALS(LLD, test, "abcde",hasSuffix, "cde" ,YES);
  TASSERT_STRING_EQUALS(LLD, test, ""    , hasSuffix, ""    , NO);
  TASSERT_STRING_EQUALS(LLD, test, ""    , hasSuffix, "a"   , NO);
  TASSERT_STRING_EQUALS(LLD, test, "a"   , hasSuffix, ""    , NO);
  TASSERT_STRING_EQUALS(LLD, test, "a"   , hasSuffix, "a"   ,YES);
  TASSERT_STRING_EQUALS(LLD, test, "a"   , hasSuffix, "aa"  , NO);
  TASSERT_STRING_EQUALS(LLD, test, "aa"  , hasSuffix, "a"   ,YES);
  TASSERT_STRING_EQUALS(LLD, test, "abc" , hasSuffix, "abc" ,YES);
  TASSERT_STRING_EQUALS(LLD, test, "abca", hasSuffix, "abcb", NO);
  TASSERT_STRING_EQUALS(LLD, test, "abcd", hasSuffix, "abcb", NO);
  TASSERT_STRING_EQUALS(LLD, test, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", hasSuffix, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", YES);
  TASSERT_STRING_EQUALS(LLD, test, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", hasSuffix, "èàô¡®œ±ĀϿḀ⓿⣿㊿﹫", YES);
  TASSERT_STRING_EQUALS(LLD, test, "èàô¡®œ±ĀϿḀ⓿⣿㊿﹫", hasSuffix, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", NO);
  KILL_POOL;
}
static void string_cast(test_t *test)
{
  int intValue;
  NSInteger integerValue;
  long long longLongValue;
  
  // intValue test
  intValue= [@"123456789" intValue];
  TASSERT_EQUALS(test, intValue, 123456789, "%d != %d");
  
  intValue= [@"-123456789" intValue];
  TASSERT_EQUALS(test, intValue, -123456789, "%d != %d");
  
  intValue= [@"123456789123456789" intValue];
  TASSERT_EQUALS(test, intValue, INT_MAX, "%d != %d");
  
  intValue= [@"-123456789123456789" intValue];
  TASSERT_EQUALS(test, intValue, INT_MIN, "%d != %d");
  
  intValue= [@"Not an int" intValue];
  TASSERT_EQUALS(test, intValue, 0, "%d != %d");
  
  // longLongValue test
  longLongValue= [@"123456789123456789" longLongValue];
  TASSERT_EQUALS(test, longLongValue, 123456789123456789LL, "%lld != %lld");
  
  longLongValue= [@"-123456789123456789" longLongValue];
  TASSERT_EQUALS(test, longLongValue, -123456789123456789LL, "%lld != %lld");
  
  longLongValue= [@"123456789123456789123456789" longLongValue];
  TASSERT_EQUALS(test, longLongValue, LLONG_MAX, "%lld != %lld");
  
  longLongValue= [@"-123456789123456789123456789" longLongValue];
  TASSERT_EQUALS(test, longLongValue, LLONG_MIN, "%lld != %lld");
  
  longLongValue= [@"Not an long long" longLongValue];
  TASSERT_EQUALS(test, longLongValue, 0, "%lld != %lld");
  
  // integerValue test
  integerValue= [@"123456789" integerValue];
  TASSERT_EQUALS(test, integerValue, 123456789, "%ld != %ld");
  
  integerValue= [@"-123456789" integerValue];
  TASSERT_EQUALS(test, integerValue, -123456789, "%ld != %ld");
  
  integerValue= [@"Not an integer" integerValue];
  TASSERT_EQUALS(test, integerValue, 0, "%ld != %ld");
}

#ifndef WO451
#define TASSERT_FORMAT(TEST, EXPECT, FORMAT, ...) ({\
  NSString *__f= [ALLOC(NSString) initWithFormat:@FORMAT, ## __VA_ARGS__]; \
  TASSERT(TEST, [@EXPECT isEqual:__f], "expected: '%s', got: '%s'", EXPECT, [__f UTF8String]); \
  RELEASE(__f);})
#else
#define TASSERT_FORMAT(TEST, EXPECT, FORMAT...) ({\
  NSString *__f= [ALLOC(NSString) initWithFormat:@ ## FORMAT]; \
  TASSERT(TEST, [@ ## EXPECT isEqual:__f], "expected: '%s', got: '%s'", EXPECT, [__f UTF8String]); \
  RELEASE(__f);})
#endif

#define TASSERT_NSFORMAT(TEST, EXPECT, FORMAT...) ({ \
  NSString *__f= [ALLOC(NSString) initWithFormat:FORMAT]; \
  TASSERT(TEST, [EXPECT isEqual:__f], "expected: '%s', got: '%s'", [EXPECT UTF8String], [__f UTF8String]); \
  RELEASE(__f);})

static void string_format(test_t *test)
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
  TASSERT_FORMAT(test,"%hhd: min=-127 max=+127 mid=52",
                "%%hhd: min=%hhd max=%+hhd mid=%hhd", (char)-127, (char)+127, (char)52);
  TASSERT_FORMAT(test,"%hd: min=-32767 max=+32767 mid=12345",
                "%%hd: min=%hd max=%+hd mid=%hd", (short)-32767, (short)+32767, (short)12345);
  TASSERT_FORMAT(test,"%d: min=-2147483647 max=+2147483647 mid=1234567890",
                "%%d: min=%d max=%+d mid=%d", (int)-2147483647, (int)+2147483647, (int)1234567890);
  TASSERT_FORMAT(test,"%ld: min=-2147483647 max=+2147483647 mid=1234567890",
                "%%ld: min=%ld max=%+ld mid=%ld", (long)-2147483647, (long)+2147483647, (long)1234567890);
  TASSERT_FORMAT(test,"%lld: min=-9223372036854775807 max=+9223372036854775807 mid=123456789012345",
                "%%lld: min=%lld max=%+lld mid=%lld", (long long)-9223372036854775807LL, (long long)+9223372036854775807LL, (long long)123456789012345LL);
  
  // Test unsigned decimals
  TASSERT_FORMAT(test,"%hhu: max=255 mid=52",
                "%%hhu: max=%hhu mid=%hhu", (unsigned char)255U, (unsigned char)52);
  TASSERT_FORMAT(test,"%hu: max=65535 mid=12345",
                "%%hu: max=%hu mid=%hu", (unsigned short)65535U, (unsigned short)12345U);
  TASSERT_FORMAT(test,"%u: max=4294967295 mid=1234567890",
                "%%u: max=%u mid=%u", (unsigned int)4294967295U, (unsigned int)1234567890U);
  TASSERT_FORMAT(test,"%lu: max=4294967295 mid=1234567890",
                "%%lu: max=%lu mid=%lu", (unsigned long)4294967295UL, (unsigned long)1234567890UL);
  TASSERT_FORMAT(test,"%llu: max=18446744073709551615 mid=123456789012345",
                "%%llu: max=%llu mid=%llu", 18446744073709551615ULL, 123456789012345ULL);
  
  // Test unsigned octals
  TASSERT_FORMAT(test,"%hho: max=377 mid=64",
                "%%hho: max=%hho mid=%hho", (unsigned char)255U, (unsigned char)52);
  TASSERT_FORMAT(test,"%ho: max=177777 mid=30071",
                "%%ho: max=%ho mid=%ho", (unsigned short)65535U, (unsigned short)12345U);
  TASSERT_FORMAT(test,"%o: max=37777777777 mid=11145401322",
                "%%o: max=%o mid=%o", (unsigned int)4294967295U, (unsigned int)1234567890U);
  TASSERT_FORMAT(test,"%lo: max=37777777777 mid=11145401322",
                "%%lo: max=%lo mid=%lo", (unsigned long)4294967295UL, (unsigned long)1234567890UL);
  TASSERT_FORMAT(test,"%llo: max=1777777777777777777777 mid=3404420603357571",
                "%%llo: max=%llo mid=%llo", 18446744073709551615ULL, 123456789012345ULL);
  
  // Test unsigned hex
  TASSERT_FORMAT(test,"%hhx: max=ff mid=34",
                "%%hhx: max=%hhx mid=%hhX", (unsigned char)255U, (unsigned char)52);
  TASSERT_FORMAT(test,"%hx: max=ffff mid=3039",
                "%%hx: max=%hx mid=%hX", (unsigned short)65535U, (unsigned short)12345U);
  TASSERT_FORMAT(test,"%x: max=ffffffff mid=499602D2",
                "%%x: max=%x mid=%X", (unsigned int)4294967295U, (unsigned int)1234567890U);
  TASSERT_FORMAT(test,"%lx: max=ffffffff mid=499602D2",
                "%%lx: max=%lx mid=%lX", (unsigned long)4294967295UL, (unsigned long)1234567890UL);
  TASSERT_FORMAT(test,"%llx: max=ffffffffffffffff mid=7048860DDF79",
                "%%llx: max=%llx mid=%llX", 18446744073709551615ULL, 123456789012345ULL);
  
  // Test float
  TASSERT_FORMAT(test,
    "float: %f=1234.500000 %e=1.234500e+01 %E=1.234500E+04 %g=0.12345 %G=1.2345 %a=0x1.edccccccccccdp+6 %A=0X1.81C8P+13",
    "float: %%f=%5$f %%e=%3$e %%E=%7$E %%g=%1$g %%G=%2$G %%a=%4$a %%A=%6$A", 0.12345, 1.23450, 12.3450, 123.450, 1234.50, 12345.00, 12345.0);
  TASSERT_FORMAT(test,
    "float: %f=+500000000000000022442856339037958392774656.000000 %e=5.00200e-03 %E= 1.268715E+04 %g=465.64999999999997726 %G=65432.19999999999709 %a=  0x1.176592e000p+38 %A=0X1.0C6F7A0B5ED8DP-20",
    "float: %%f=%3$+010.6f %%e=%7$.5e %%E=%5$ 010E %%g=%1$.20g %%G=%2$10.20G %%a=%4$20.10a %%A=%6$15A", 465.650, 65432.20, 50e40, 30e10, 12687.15, 0.000001, 0.005002);
  
  // Test pointers
#ifdef __LP64__
  TASSERT_FORMAT(test,"%p: min=0x8000000000000000 max=0x7fffffffffffffff mid=0x7048860ddf79",
                     "%%p: min=%p max=%p mid=%p", (void*)INTPTR_MIN, (void*)INTPTR_MAX, (void*)123456789012345ULL);
#else
  TASSERT_FORMAT(test,"%p: min=0x80000000 max=0x7fffffff mid=0xbc614e",
                     "%%p: min=%p max=%p mid=%p", (void*)INTPTR_MIN, (void*)INTPTR_MAX, (void*)12345678ULL);
#endif

  
  // Test flags, width, precision
  TASSERT_FORMAT(test,"sign: 545 +5641675  5124136",
                     "sign: %d %+d % d", 545, 5641675, 5124136);
  TASSERT_FORMAT(test,"width:       1461 13541           +7984      +6706 +450      ",
                     "width: %10d %-10d %+10d %+10d %+-10d", 1461, 13541 ,7984, 6706, 450);
  TASSERT_FORMAT(test,"width:       1461 13541            7984       6706 450       ",
                     "width: %10u %-10u %10u %10u %-10u", 1461, 13541 ,7984, 6706, 450);
  TASSERT_FORMAT(test,"0pad: %010d=0000001461 %-10d=13541      %+010d=+000007984 %+010d=+000006706 %+-10d=+450      ",
                     "0pad: %%010d=%010d %%-10d=%-10d %%+010d=%+010d %%+010d=%+010d %%+-10d=%+-10d", 1461, 13541 ,7984, 6706, 450);
  TASSERT_FORMAT(test,"0pad: %010u=0000001461 %-10u=13541      %010u=0000007984 %010u=0000006706 %-10u=450       ",
                     "0pad: %%010u=%010u %%-10u=%-10u %%010u=%010u %%010u=%010u %%-10u=%-10u", 1461, 13541 ,7984, 6706, 450);
  TASSERT_FORMAT(test,"prec: %*.*d=0000020 %*.*d=    0013 %0*.*d=      013",
                     "prec: %%*.*d=%*.*d %%*.*d=%*.*d %%0*.*d=%0*.*d", 5, 7, 20, 8, 4, 13, 9, 3, 13);
  TASSERT_FORMAT(test,"prec: %.10d=0000001461 %.11d=00000013541 %13.10d=   0000007984 %10.12d=000000006706 %*.*d=0000020 %*.*d=    0013",
                     "prec: %%.10d=%.10d %%.11d=%.11d %%13.10d=%13.10d %%10.12d=%10.12d %%*.*d=%*.*d %%*.*d=%*.*d", 1461, 13541 ,7984, 6706, 5, 7, 20, 8, 4, 13);
  
  // ObjC
  TASSERT_NSFORMAT(test, @"objc: test", @"objc: %@", @"test");
  
  // Found bug tests
  TASSERT_FORMAT(test,"bug print decimal when decimal is 0: expected:0, got:0",
                     "bug print decimal when decimal is 0: expected:0, got:%d", 0);
  
  // Old Tests
  TASSERT_FORMAT(test,"22337236854775808",
    "%lld", posvalue2);
  TASSERT_FORMAT(test,    "start -9223372036854775808 -2332036854779808 -1",
    "%s %lld %lld %lld", "start", min, negvalue2, negvalue1);
  TASSERT_FORMAT(test, "start -9223372036854775808 -2332036854779808 -1 2 1 22337236854775808 9223372036854775807 end",
    "%s %lld %lld %lld %d %lld %lld %lld %s", "start", min, negvalue2, negvalue1, intValue, posvalue1, posvalue2, max, "end");
  TASSERT_FORMAT(test,"22337236854775808",
    "%llu", (unsigned long long)posvalue2);
  TASSERT_FORMAT(test,"start 18446744073709551615 22337236854775808 1",
    "%s %llu %llu %llu", "start", umax, uposvalue2, uposvalue1);
  TASSERT_FORMAT(test,"start 18446744073709551615 2 1 22337236854775808 end",
    "%s %llu %d %llu %llu %s", "start", umax, intValue, uposvalue1, uposvalue2, "end");
  
}

static void string_path(test_t *test)
{
  NSArray *components, *expect;
  NEW_POOL;

  // pathWithComponents
  components= [NSArray arrayWithObjects:@"/", @"a", @"b", @"cd", nil];
  TASSERT_EQUALS_OBJ(test, [NSString pathWithComponents:components], @"/a/b/cd");

  components= [NSArray arrayWithObjects:@"c", @"b", @"ad", nil];
  TASSERT_EQUALS_OBJ(test, [NSString pathWithComponents:components], @"c/b/ad");

  // pathComponents
  TASSERT_EQUALS_OBJ(test, [@"tmp/scratch"  pathComponents], ([NSArray arrayWithObjects:@"tmp", @"scratch", nil]));
  TASSERT_EQUALS_OBJ(test, [@"/tmp/scratch" pathComponents], ([NSArray arrayWithObjects:@"/", @"tmp", @"scratch", nil]));

  // lastPathComponent
  TASSERT_EQUALS_OBJ(test, [@"/tmp/scratch.tiff" lastPathComponent], @"scratch.tiff");
  TASSERT_EQUALS_OBJ(test, [@"/tmp/scratch"      lastPathComponent], @"scratch");
  TASSERT_EQUALS_OBJ(test, [@"/tmp/"             lastPathComponent], @"tmp");
  TASSERT_EQUALS_OBJ(test, [@"scratch///"        lastPathComponent], @"scratch");
  TASSERT_EQUALS_OBJ(test, [@"/"                 lastPathComponent], @"/");

  // pathExtension
  TASSERT_EQUALS_OBJ(test, [@"/tmp/scratch.tiff"  pathExtension], @"tiff");
  TASSERT_EQUALS_OBJ(test, [@".scratch.tiff"      pathExtension], @"tiff");
  TASSERT_EQUALS_OBJ(test, [@"/tmp/scratch"       pathExtension], @"");
  TASSERT_EQUALS_OBJ(test, [@"/tmp/"              pathExtension], @"");
  TASSERT_EQUALS_OBJ(test, [@"/tmp/scratch..tiff" pathExtension], @"tiff");

  // stringByAppendingPathComponenta
  TASSERT_EQUALS_OBJ(test, [@"/tmp"  stringByAppendingPathComponent:@"scratch.tiff"], @"/tmp/scratch.tiff");
  TASSERT_EQUALS_OBJ(test, [@"/tmp/" stringByAppendingPathComponent:@"scratch.tiff"], @"/tmp/scratch.tiff");
  TASSERT_EQUALS_OBJ(test, [@"/"     stringByAppendingPathComponent:@"scratch.tiff"], @"/scratch.tiff");
  TASSERT_EQUALS_OBJ(test, [@""      stringByAppendingPathComponent:@"scratch.tiff"], @"scratch.tiff");

  // stringsByAppendingPaths
  components= [NSArray arrayWithObjects:@"a/b", @"c", @"/d" , nil];
  expect= [NSArray arrayWithObjects:@"/tmp/a/b", @"/tmp/c", @"/tmp/d", nil];
  TASSERT_EQUALS_OBJ(test, [@"/tmp" stringsByAppendingPaths:components], expect);
  TASSERT_EQUALS_OBJ(test, [@"/tmp/" stringsByAppendingPaths:components], expect);
  TASSERT_EQUALS_OBJ(test, [@"/tmp//" stringsByAppendingPaths:components], expect);

  // stringByAppendingPathExtension
  TASSERT_EQUALS_OBJ(test, [@"/tmp/scratch.old" stringByAppendingPathExtension:@"tiff"], @"/tmp/scratch.old.tiff");
  TASSERT_EQUALS_OBJ(test, [@"/tmp/scratch."    stringByAppendingPathExtension:@"tiff"], @"/tmp/scratch..tiff");
  TASSERT_EQUALS_OBJ(test, [@"/tmp/"            stringByAppendingPathExtension:@"tiff"], @"/tmp.tiff");
  TASSERT_EQUALS_OBJ(test, [@"scratch"          stringByAppendingPathExtension:@"tiff"], @"scratch.tiff");
  TASSERT_EQUALS_OBJ(test, [@"1"                stringByAppendingPathExtension:@"sql" ], @"1.sql");

  // stringByDeletingLastPathComponent
  TASSERT_EQUALS_OBJ(test, [@"/tmp/scratch.tiff" stringByDeletingLastPathComponent], @"/tmp");
  TASSERT_EQUALS_OBJ(test, [@"/tmp/lock/"        stringByDeletingLastPathComponent], @"/tmp");
  TASSERT_EQUALS_OBJ(test, [@"/tmp/"             stringByDeletingLastPathComponent], @"/");
  TASSERT_EQUALS_OBJ(test, [@"/tmp"              stringByDeletingLastPathComponent], @"/");
  TASSERT_EQUALS_OBJ(test, [@"/"                 stringByDeletingLastPathComponent], @"/");
  TASSERT_EQUALS_OBJ(test, [@"scratch.tiff"      stringByDeletingLastPathComponent], @"");

  // stringByDeletingPathExtension
  TASSERT_EQUALS_OBJ(test, [@"/tmp/scratch.tiff" stringByDeletingPathExtension], @"/tmp/scratch");
  TASSERT_EQUALS_OBJ(test, [@"/tmp/"             stringByDeletingPathExtension], @"/tmp");
  TASSERT_EQUALS_OBJ(test, [@"scratch.bundle/"   stringByDeletingPathExtension], @"scratch");
  TASSERT_EQUALS_OBJ(test, [@"scratch..tiff"     stringByDeletingPathExtension], @"scratch.");
  TASSERT_EQUALS_OBJ(test, [@".tiff"             stringByDeletingPathExtension], @".tiff");
  TASSERT_EQUALS_OBJ(test, [@"/"                 stringByDeletingPathExtension], @"/");

  KILL_POOL;
}

test_t foundation_string[]= {
  {"equal" ,NULL,string_eq    ,INTITIALIZE_TEST_T_END},
  {"compare" ,NULL,string_compare,INTITIALIZE_TEST_T_END},
  {"cast"  ,NULL,string_cast  ,INTITIALIZE_TEST_T_END},
  {"format",NULL,string_format,INTITIALIZE_TEST_T_END},
  {"path"  ,NULL,string_path  ,INTITIALIZE_TEST_T_END},
  {NULL}};

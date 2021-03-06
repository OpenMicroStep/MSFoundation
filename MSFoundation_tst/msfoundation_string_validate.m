// msfoundation_string_validate.m, ecb, 130911

#include "msfoundation_validate.h"

static void string_ns(test_t *test)
  {
  NSString *s,*sl1,*sl2;
  s= MSCreateString("MSString");
  sl1= [(MSString*)s lowercaseString];
  sl2= MSCreateString("msstring");
  TASSERT_ISEQUAL(test, sl1, sl2, "%s != %s",[sl1 UTF8String],[sl2 UTF8String]);
  RELEASE(s); RELEASE(sl2);
  }

static void string_trim(test_t *test)
  {
  NSString *s,*st1,*st2;
  s=   MSCreateString(" MSString ");
  st1= MSCreateString( "MSString" );
  st2= [(MSString*)s trim];
  TASSERT_ISEQUAL(test, st1, st2, "%s != %s",[st1 UTF8String],[st2 UTF8String]);
  RELEASE(s); RELEASE(st1);
  }

static void string_toNs(test_t *test)
  {
  NSString *s1,*s2;
  s1= @"/opt/microstep/darwin/support/MASHRepositoryServer/MHNetRepositoryServer.config";
  s2= MSCreateString("/opt/microstep/darwin/support/MASHRepositoryServer/MHNetRepositoryServer.config");
#ifndef MSFOUNDATION_FORCOCOA
#warning Disabled test ms_toNs
#else
  {
  id x1,x2;
  NSFileManager *fileManager; NSDirectoryEnumerator *e1,*e2; NSString *f1,*f2; BOOL end;
  x1= [NSDictionary dictionaryWithContentsOfFile:s1];
  x2= [NSDictionary dictionaryWithContentsOfFile:s2];
  TASSERT(test, x1, "empty %s",[[x1 description] UTF8String]);
  TASSERT_ISEQUAL(test, x1, x2, "not equal\nAvec NS\n%s\nAvec MS\n%s",
    [[x1 description] UTF8String],[[x2 description] UTF8String]);
  ASSIGN(s1, [s1 stringByDeletingLastPathComponent]);
  ASSIGN(s2, [MSString stringWithString:[s2 stringByDeletingLastPathComponent]]);
  TASSERT(test, [s2 isKindOfClass:[MSString class]], "s2 not a MSString %s %s",
    [[[s2 class] description] UTF8String],[[s2 description] UTF8String]);
  fileManager= [[[NSFileManager alloc] init] autorelease];
  e1= [fileManager enumeratorAtPath:s1];
  e2= [fileManager enumeratorAtPath:s2];
  for (end= NO; !end; end= !f1 || !f2) {
    f1= [e1 nextObject]; f2= [e2 nextObject];
    TASSERT_ISEQUAL(test, f1, f2, "not equal %s != %s",[f1 UTF8String],[f2 UTF8String]);}
  }
#endif
  RELEASE(s1);
  RELEASE(s2);
  }

static void string_eq(test_t *test)
  {
  NSString *ns,*ms;
  ns= ms= nil;
  ASSIGN(ns, @"");
  ASSIGN(ms, [MSString stringWithCString:"" encoding:NSUTF8StringEncoding]);
  TASSERT_ISEQUAL(   test, ns, ms, "%s != %s",[ns UTF8String],[ms UTF8String]);
  TASSERT_ISEQUAL(   test, ms, ns, "%s != %s",[ms UTF8String],[ns UTF8String]);
  ASSIGN(ms, [MSString stringWithCString:"a string" encoding:NSUTF8StringEncoding]);
  TASSERT_ISNOTEQUAL(test, ns, ms, "%s == %s",[ns UTF8String],[ms UTF8String]);
  TASSERT_ISNOTEQUAL(test, ms, ns, "%s == %s",[ms UTF8String],[ns UTF8String]);
  ASSIGN(ns, @"a string");
  TASSERT_ISEQUAL(   test, ns, ms, "%s != %s",[ns UTF8String],[ms UTF8String]);
  TASSERT_ISEQUAL(   test, ms, ns, "%s != %s",[ms UTF8String],[ns UTF8String]);
  ASSIGN(ms, [MSString stringWithCString:"" encoding:NSUTF8StringEncoding]);
  TASSERT_ISNOTEQUAL(test, ns, ms, "%s == %s",[ns UTF8String],[ms UTF8String]);
  TASSERT_ISNOTEQUAL(test, ms, ns, "%s == %s",[ms UTF8String],[ns UTF8String]);
  RELEASE(ns);
  RELEASE(ms);
  }

#define TASSERT_NSSTRINGINIT(TEST, INIT, EXPECT) TASSERT_EQUALS_OBJ(test, [[[MSString alloc] INIT] autorelease], EXPECT)
#define TASSERT_NSSTRINGCLSI(TEST, INIT, EXPECT) TASSERT_EQUALS_OBJ(test, [MSString INIT], EXPECT)

static void string_init(test_t *test)
{
  unichar *characters; NSData *data;
  TASSERT_NSSTRINGINIT(test, init, @"");
  TASSERT_NSSTRINGINIT(test, initWithCharacters:u"abcéèàô¡®œ±ĀϿḀ⓿⣿㊿﹫" length:18, @"abcéèàô¡®œ±ĀϿḀ⓿⣿㊿﹫");
  TASSERT_NSSTRINGINIT(test, initWithCharactersNoCopy:u"céèàô¡®œ±ĀϿḀ⓿⣿㊿﹫" length:16 freeWhenDone:NO , @"céèàô¡®œ±ĀϿḀ⓿⣿㊿﹫");
  characters= malloc(sizeof(unichar) * 16);
  memcpy(characters, u"déèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", sizeof(unichar) * 16);
  TASSERT_NSSTRINGINIT(test, initWithCharactersNoCopy:characters length:16 freeWhenDone:YES, @"déèàô¡®œ±ĀϿḀ⓿⣿㊿﹫");
  TASSERT_NSSTRINGINIT(test, initWithUTF8String:"eéèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", @"eéèàô¡®œ±ĀϿḀ⓿⣿㊿﹫");
  TASSERT_NSSTRINGINIT(test, initWithString:@"¡®œ±ĀϿḀ⓿⣿㊿﹫", @"¡®œ±ĀϿḀ⓿⣿㊿﹫");
  data= [NSData dataWithBytes:"abcd" length:4];
  TASSERT_NSSTRINGINIT(test, initWithData:data encoding:NSUTF8StringEncoding, @"abcd");
  data= [NSData dataWithBytes:u"abcd" length:8];
  TASSERT_NSSTRINGINIT(test, initWithData:data encoding:NSUTF16StringEncoding, @"abcd");
  TASSERT_NSSTRINGINIT(test, initWithBytes:"abcde" length:5 encoding:NSUTF8StringEncoding, @"abcde");
  TASSERT_NSSTRINGINIT(test, initWithBytesNoCopy:"abcdef" length:6 encoding:NSUTF8StringEncoding freeWhenDone:NO, @"abcdef");
  TASSERT_NSSTRINGINIT(test, initWithBytes:u"abcde" length:10 encoding:NSUTF16StringEncoding, @"abcde");
  TASSERT_NSSTRINGINIT(test, initWithBytesNoCopy:u"abcdef" length:12 encoding:NSUTF16StringEncoding freeWhenDone:NO, @"abcdef");
  characters= malloc(sizeof(unichar) * 5);
  memcpy(characters, u"fghyt", sizeof(unichar) * 5);
  TASSERT_NSSTRINGINIT(test, initWithBytesNoCopy:characters length:10 encoding:NSUTF16StringEncoding freeWhenDone:YES, @"fghyt");


  TASSERT_NSSTRINGCLSI(test, string, @"");
  TASSERT_NSSTRINGCLSI(test, stringWithString:@"¡®œ±ĀϿḀ⓿⣿㊿﹫", @"¡®œ±ĀϿḀ⓿⣿㊿﹫");
  TASSERT_NSSTRINGCLSI(test, stringWithCharacters:u"abcéèàô¡®œ±ĀϿḀ⓿⣿㊿﹫" length:18, @"abcéèàô¡®œ±ĀϿḀ⓿⣿㊿﹫");
  TASSERT_NSSTRINGCLSI(test, stringWithUTF8String:"eéèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", @"eéèàô¡®œ±ĀϿḀ⓿⣿㊿﹫");

  TASSERT_NSSTRINGINIT(test, initWithCString:"eéèàô¡®œ±ĀϿḀ⓿⣿㊿﹫" encoding:NSUTF8StringEncoding, @"eéèàô¡®œ±ĀϿḀ⓿⣿㊿﹫");
  TASSERT_NSSTRINGCLSI(test, stringWithCString:"eéèàô¡®œ±ĀϿḀ⓿⣿㊿﹫" encoding:NSUTF8StringEncoding, @"eéèàô¡®œ±ĀϿḀ⓿⣿㊿﹫");

  // TODO: initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error;
  // TODO: stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error;
  // TODO: initWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error;
  // TODO: stringWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error;
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
  TASSERT_EQUALS_OBJ(TEST, ([[[MSString alloc] initWithFormat:@FORMAT, ## __VA_ARGS__] autorelease]), @EXPECT); \
  TASSERT_EQUALS_OBJ(TEST, ([MSString stringWithFormat:@FORMAT, ## __VA_ARGS__]), @EXPECT); })
#else
#define TASSERT_FORMAT(TEST, EXPECT, FORMAT...) ({\
  TASSERT_EQUALS_OBJ(TEST, ([[[MSString alloc] initWithFormat:@ ## FORMAT] autorelease]), @ ## EXPECT); \
  TASSERT_EQUALS_OBJ(TEST, ([MSString stringWithFormat:@ ## FORMAT]), @ ## EXPECT); })
#endif

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


  TASSERT_FORMAT(test,"bug decimal 0 0 0 0 0 0 0 0 0 0",
                "bug decimal %hhd %hd %d %ld %lld %hhu %hu %u %lu %llu", (char)0, (short)0, 0, 0L, 0LL, (unsigned char)0, (unsigned short)0, 0U, 0UL, 0ULL);

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
  TASSERT_FORMAT(test, "objc: test", "objc: %@", @"test");

  // Found bug tests
  TASSERT_FORMAT(test,"bug print decimal when decimal is 0: expected:0, got:0",
                     "bug print decimal when decimal is 0: expected:0, got:%d", 0);
  TASSERT_FORMAT(test,"bug print string with precision: 0'' 2'ab' *'bcd' 'cdef'",
                      "bug print string with precision: 0'%.0s' 2'%.2s' *'%.*s' '%s'", "not printed", "ab__", 3, "bcd___", "cdef");

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

@interface NSString (HashPrivate)
- (NSUInteger)hash:(unsigned)depth;
@end

static void string_hash(test_t *test)
{
  NSString *nsStr;
  MSString *msStr;
  NSUInteger nsHash, msHash;

  nsStr = [[NSString alloc] initWithString:@"AgentVerbalisateur"];
  msStr = [[MSString alloc] initWithString:@"AgentVerbalisateur"];
  nsHash = [nsStr hash:0];
  msHash = [msStr hash:0];
  TASSERT_EQUALS(test, nsHash, msHash, "%lu != %lu");
  RELEASE(nsStr);
  RELEASE(msStr);

  nsStr = [[NSString alloc] initWithString:@"CasInfraction"];
  msStr = [[MSString alloc] initWithString:@"CasInfraction"];
  nsHash = [nsStr hash:0];
  msHash = [msStr hash:0];
  TASSERT_EQUALS(test, nsHash, msHash, "%lu != %lu");
  RELEASE(nsStr);
  RELEASE(msStr);
}

static void string_ascii(test_t *test)
{
  const char *ascii, *expected;
  NSString *expectedStr;
  MSASCIIString *asciiStr;
  NEW_POOL;
  expected= "test";
  ascii= [@"test" asciiCString];
  TASSERT(test, strcmp(expected, ascii) == 0, "ascii string '%s' not equals to '%s'",ascii, expected);
  ascii= [[MSString stringWithString:@"test"] asciiCString];
  TASSERT(test, strcmp(expected, ascii) == 0, "ascii string '%s' not equals to '%s'",ascii, expected);

  expected= "teste\"'(e!ca";
  ascii= [@"testé\"'(§è!çà" asciiCString];
  TASSERT(test, strcmp(expected, ascii) == 0, "ascii string '%s' not equals to '%s'",ascii, expected);
  ascii= [[MSString stringWithString:@"testé\"'(§è!çà"] asciiCString];
  TASSERT(test, strcmp(expected, ascii) == 0, "ascii string '%s' not equals to '%s'",ascii, expected);

  expectedStr= @"test";
  expected= "test";
  asciiStr= [MSASCIIString stringWithBytes:expected length:strlen(expected)];
  TASSERT(test, [expectedStr isEqual:asciiStr],
    "ascii string '%s' not equals to '%s'",[asciiStr UTF8String], [expectedStr UTF8String]);

  expectedStr= asciiStr;
  asciiStr= [expectedStr copy];
  TASSERT(test, [expectedStr isEqual:asciiStr],
    "ascii string '%s' not equals to '%s'",[asciiStr UTF8String], [expectedStr UTF8String]);

  KILL_POOL;
}

static void string_plist(test_t *test)
{
  NSString *s; NSArray* a, *e; CBuffer *b;
  b= CCreateBuffer(0);
  CBufferAppendByte(b, 0xff);
  CBufferAppendByte(b, 0x00);
  CBufferAppendByte(b, 0xab);
  CBufferAppendByte(b, 0xcd);
  CBufferAppendByte(b, 0xab);
  CBufferAppendByte(b, 0xcd);
  s= @"( /** 1 **/ { /**/ thread = \"-\\\"re\n\"; /* 3 */ // tests \n/* 4 */ \"modelVersion\" = 1;\"diffExpirationInDay\" = 30;}, AZERTY_azerty_0123456789/*f*/, <ff 00 abcd AB CD>)";
  e= [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                @"-\"re\n", @"thread",
                                @"1", @"modelVersion",
                                @"30", @"diffExpirationInDay",
                                nil], @"AZERTY_azerty_0123456789", (MSBuffer *)b, nil];
  RELEASE((id)b);
  a= [s arrayValue];
  TASSERT(test, a, "parsing plist string '%s' to array failed",[s UTF8String]);
  TASSERT_ISEQUAL(test, e, a, "parsing plist string '%s' to array failed,\n%s\nnot equals to\n%s",
    [s UTF8String],[[e description] UTF8String],[[a description] UTF8String]);
}
static void string_uuid(test_t *test)
{
  MSString *uuid1, *uuid2;

  uuid1 = [MSString UUIDString];
  uuid2 = [MSString UUIDString];
  TASSERT_EQUALS(test, [uuid1 length], 36, "uuid1 string length must be 36");
  TASSERT_EQUALS(test, [uuid2 length], 36, "uuid2 string length must be 36");
  TASSERT_ISNOTEQUAL(test, uuid1, uuid2, "uuid must not be equals ever");
}

testdef_t msfoundation_string[]= {
  {"ns"    ,NULL,string_ns    },
  {"trim"  ,NULL,string_trim  },
  {"toNs"  ,NULL,string_toNs  },
  {"equal" ,NULL,string_eq    },
  {"init"  ,NULL,string_init  },
  {"cast"  ,NULL,string_cast  },
  {"format",NULL,string_format},
  {"hash"  ,NULL,string_hash  },
  {"ascii" ,NULL,string_ascii },
  {"plist" ,NULL,string_plist },
  {"uuid"  ,NULL,string_uuid  },
  {NULL}
};

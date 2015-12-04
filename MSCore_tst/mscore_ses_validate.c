#include "mscore_validate.h"

static void ses_index(test_t *test)
{
  CString *c= CCreateStringWithBytes(NSUTF8StringEncoding,"abcdef",6);
  SES a= CStringSES(c);
  NSUInteger p, i= SESStart(a);
  NSUInteger end= SESEnd(a);
  TASSERT(test, i < end, "There is still chars to tests");
  TASSERT(test, SESIndexN(a, &i) == (unichar)'a', "There is still chars to tests");
  TASSERT(test, i < end, "There is still chars to tests");
  TASSERT(test, SESIndexP(a, &i) == (unichar)'a', "There is still chars to tests");
  TASSERT(test, i == SESStart(a), "There is still chars to tests");
  TASSERT(test, SESIndexN(a, &i) == (unichar)'a', "There is still chars to tests");
  TASSERT(test, i < end, "There is still chars to tests");
  p= i;
  TASSERT(test, SESIndexN(a, &i) == (unichar)'b', "There is still chars to tests");
  TASSERT(test, i < end, "There is still chars to tests");
  TASSERT(test, SESIndexP(a, &i) == (unichar)'b', "There is still chars to tests");
  TASSERT(test, i == p, "There is still chars to tests");
  TASSERT(test, SESIndexP(a, &i) == (unichar)'a', "There is still chars to tests");
  TASSERT(test, i < end, "There is still chars to tests");
  TASSERT(test, SESIndexN(a, &i) == (unichar)'a', "There is still chars to tests");
  TASSERT(test, i == p, "There is still chars to tests");
  TASSERT(test, SESIndexN(a, &i) == (unichar)'b', "There is still chars to tests");
  TASSERT(test, i < end, "There is still chars to tests");
  TASSERT(test, SESIndexN(a, &i) == (unichar)'c', "There is still chars to tests");
  TASSERT(test, i < end, "There is still chars to tests");
  TASSERT(test, SESIndexN(a, &i) == (unichar)'d', "There is still chars to tests");
  TASSERT(test, i < end, "There is still chars to tests");
  TASSERT(test, SESIndexN(a, &i) == (unichar)'e', "There is still chars to tests");
  TASSERT(test, i < end, "There is still chars to tests");
  p= i;
  TASSERT(test, SESIndexN(a, &i) == (unichar)'f', "There is still chars to tests");
  TASSERT(test, i == end, "There is no more chars to tests");
  TASSERT(test, SESIndexP(a, &i) == (unichar)'f', "There is still chars to tests");
  TASSERT(test, i == p, "There is still chars to tests");
  TASSERT(test, SESIndexN(a, &i) == (unichar)'f', "There is still chars to tests");
  TASSERT(test, i == end, "There is no more chars to tests");
  RELEASE(c);
}

static void ses_utf8(test_t *test)
{
  unichar u1, u2; NSUInteger i;
  const unichar u2s[]= {233, 232, 224, 244, 161, 174, 339, 177, 256, 1023, 7680, 9471, 10495, 12991, 65131, 0};
  const char u1s[]= "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫";
  NSUInteger u2l= (sizeof(u2s)/sizeof(unichar))-1;
  NSUInteger u1l= (sizeof(u1s)/sizeof(char))-1;
  SES s1= MSMakeSESWithBytes(u1s, u1l, NSUTF8StringEncoding);
  SES s2= MSMakeSESWithBytes(u2s, u2l, NSUnicodeStringEncoding);
  NSUInteger i1= SESStart(s1), e1= SESEnd(s1);
  NSUInteger i2= SESStart(s2), e2= SESEnd(s2);

  TASSERT(test, e1 > e2, "utf8 contains multibyte characters, %d > %d", (int)e1, (int)e2);
  TASSERT(test, u1l == 35, "there is 35 bytes to tests, %d > %d", (int)u2l, (int)35);
  TASSERT(test, u2l == 15, "there is 15 characters to tests, %d > %d", (int)u2l, (int)15);

  for (i= 0; i < 15; ++i) {
    TASSERT(test, i1 < e1 && i2 < e2, "There is still chars to tests");
    TASSERT(test, (u1= SESIndexN(s1, &i1)) == (u2= SESIndexN(s2, &i2)), "utf8=%d must equal utf16=%d", (int)u1, (int)u2);
    TASSERT(test, u1 == u2s[i]                                        , "utf8=%d must equal utf16=%d", (int)u1, (int)u2s[i]);
    TASSERT(test, (u1= SESIndexP(s1, &i1)) == (u2= SESIndexP(s2, &i2)), "utf8=%d must equal utf16=%d", (int)u1, (int)u2);
    TASSERT(test, u1 == u2s[i]                                        , "utf8=%d must equal utf16=%d", (int)u1, (int)u2s[i]);
    TASSERT(test, (u1= SESIndexN(s1, &i1)) == (u2= SESIndexN(s2, &i2)), "utf8=%d must equal utf16=%d", (int)u1, (int)u2);
    TASSERT(test, u1 == u2s[i]                                        , "utf8=%d must equal utf16=%d", (int)u1, (int)u2s[i]);
  }
  TASSERT(test, i1 == e1, "There is no more utf8 chars to tests");
  TASSERT(test, i2 == e2, "There is no more utf16 chars to tests");
}

static void ses_equals(test_t *test)
{
  NSUInteger i= 0;
  CString *cla, *clb, *cua, *csa;
  SES la, lb, ua, sa;
  cla= CCreateStringWithBytes(NSUTF8StringEncoding,"abcdef",6);
  clb= CCreateStringWithBytes(NSUTF8StringEncoding,"ABCDEF",6);
  cua= CCreateStringWithBytes(NSUTF8StringEncoding,"bcdef",5);
  csa= CCreateStringWithBytes(NSUTF8StringEncoding,"0abcdef",7);
  la= CStringSES(cla);
  ua= CStringSES(clb);
  lb= CStringSES(cua);
  sa= CStringSES(csa);
  TASSERT(test, SESEquals(la, la), "must be equals to itself");
  TASSERT(test, !SESEquals(la, ua), "case differs");
  TASSERT(test, !SESEquals(la, lb), "ses differs");
  TASSERT(test, SESInsensitiveEquals(la, ua), "must be equals");
  TASSERT(test, !SESEquals(la, sa), "sa is prefixed by '0'");
  SESIndexN(sa, &i);
  sa.length-= i - sa.start;
  sa.start= i;
  TASSERT(test, SESEquals(la, sa), "sa is start after '0'");
  RELEASE(cla); RELEASE(clb); RELEASE(cua); RELEASE(csa);
}


// We could use the compiler to compute the length, but the readability of the test would be horrible without horrible tricks
static SES SESFromUTF8(const char *utf8)
{ return MSMakeSESWithBytes(utf8, strlen(utf8), NSUTF8StringEncoding); }
static SES SESFromUTF16(const unichar *utf16)
{
  const unichar *end;
  for (end= utf16; *end; ++end) {}
  return MSMakeSESWithBytes(utf16, (NSUInteger)(end - utf16), NSUnicodeStringEncoding);
}

// It's good to tests SES with different source type (UTF8 & UTF16)
#define TASSERT_SES_EQUALS(FMT, T, F, A, B, E) TASSERT_SES_EQUALS_OPT(FMT, T, F, A, B, , E)
#define TASSERT_SES_EQUALS_OPT(FMT, T, F, A, B, O, E) \
  TASSERT_EQUALS_ ## FMT(T, F(SESFromUTF8(A), SESFromUTF8(B) O), E); \
  TASSERT_EQUALS_ ## FMT(T, F(SESFromUTF16(u ## A), SESFromUTF16(u ## B) O), E); \
  TASSERT_EQUALS_ ## FMT(T, F(SESFromUTF8(A), SESFromUTF16(u ## B) O), E); \
  TASSERT_EQUALS_ ## FMT(T, F(SESFromUTF16(u ## A), SESFromUTF8(B) O), E)

static void ses_compare(test_t *test)
{
  TASSERT_SES_EQUALS(LLD, test, SESCompare, ""    , ""    , NSOrderedSame);
  TASSERT_SES_EQUALS(LLD, test, SESCompare, ""    , "a"   , NSOrderedAscending);
  TASSERT_SES_EQUALS(LLD, test, SESCompare, "a"   , ""    , NSOrderedDescending);
  TASSERT_SES_EQUALS(LLD, test, SESCompare, "a"   , "a"   , NSOrderedSame);
  TASSERT_SES_EQUALS(LLD, test, SESCompare, "a"   , "aa"  , NSOrderedAscending);
  TASSERT_SES_EQUALS(LLD, test, SESCompare, "aa"  , "a"   , NSOrderedDescending);
  TASSERT_SES_EQUALS(LLD, test, SESCompare, "abc" , "abc" , NSOrderedSame);
  TASSERT_SES_EQUALS(LLD, test, SESCompare, "abca", "abcb", NSOrderedAscending);
  TASSERT_SES_EQUALS(LLD, test, SESCompare, "abcd", "abcb", NSOrderedDescending);
  TASSERT_SES_EQUALS(LLD, test, SESCompare, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", NSOrderedSame);
  TASSERT_SES_EQUALS(LLD, test, SESCompare, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", "éèàô¡®œ±ĀϿḀ⓿⣿㊿", NSOrderedDescending);
  TASSERT_SES_EQUALS(LLD, test, SESCompare, "éèàô¡®œ±ĀϿḀ⓿⣿㊿", "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", NSOrderedAscending);

  TASSERT_SES_EQUALS(LLD, test, SESInsensitiveCompare, ""    , ""    , NSOrderedSame);
  TASSERT_SES_EQUALS(LLD, test, SESInsensitiveCompare, ""    , "a"   , NSOrderedAscending);
  TASSERT_SES_EQUALS(LLD, test, SESInsensitiveCompare, "a"   , ""    , NSOrderedDescending);
  TASSERT_SES_EQUALS(LLD, test, SESInsensitiveCompare, "a"   , "a"   , NSOrderedSame);
  TASSERT_SES_EQUALS(LLD, test, SESInsensitiveCompare, "a"   , "aa"  , NSOrderedAscending);
  TASSERT_SES_EQUALS(LLD, test, SESInsensitiveCompare, "aa"  , "a"   , NSOrderedDescending);
  TASSERT_SES_EQUALS(LLD, test, SESInsensitiveCompare, "abc" , "abc" , NSOrderedSame);
  TASSERT_SES_EQUALS(LLD, test, SESInsensitiveCompare, "abca", "abcb", NSOrderedAscending);
  TASSERT_SES_EQUALS(LLD, test, SESInsensitiveCompare, "abcd", "abcb", NSOrderedDescending);
  TASSERT_SES_EQUALS(LLD, test, SESInsensitiveCompare, "a"   , "A"   , NSOrderedSame);
  TASSERT_SES_EQUALS(LLD, test, SESInsensitiveCompare, "abc" , "AbC" , NSOrderedSame);
  TASSERT_SES_EQUALS(LLD, test, SESInsensitiveCompare, "abca", "ABCB", NSOrderedAscending);
  TASSERT_SES_EQUALS(LLD, test, SESInsensitiveCompare, "ABCB", "abca", NSOrderedDescending);
  TASSERT_SES_EQUALS(LLD, test, SESInsensitiveCompare, "abcd", "ABCB", NSOrderedDescending);
  TASSERT_SES_EQUALS(LLD, test, SESInsensitiveCompare, "ABCB", "abcd", NSOrderedAscending);
  TASSERT_SES_EQUALS(LLD, test, SESInsensitiveCompare, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", NSOrderedSame);
  TASSERT_SES_EQUALS(LLD, test, SESInsensitiveCompare, "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", "éèàô¡®œ±ĀϿḀ⓿⣿㊿", NSOrderedDescending);
  TASSERT_SES_EQUALS(LLD, test, SESInsensitiveCompare, "éèàô¡®œ±ĀϿḀ⓿⣿㊿", "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫", NSOrderedAscending);
}
static BOOL ses_extract_test1(unichar c)
{ return (unichar)'b' <= c && c <= (unichar)'f'; }
static BOOL ses_extract_test2(unichar c)
{ return (unichar)'B' <= c && c <= (unichar)'F'; }

static void ses_check(test_t *test, SES a, SES e, NSUInteger start, NSUInteger length, int line)
{
  TASSERT(test, SESOK(e), ":%d must extract something",line);
  if (SESOK(e)) {
    TASSERT_EQUALS(test, e.start, start, ":%d start must matches %lu != %lu",line);
    TASSERT_EQUALS(test, e.length, length, ":%d length must matches  %lu != %lu",line);
    TASSERT_EQUALS(test, e.source, a.source, ":%d source must matches %p != %p",line);
    TASSERT_EQUALS(test, e.encoding, a.encoding, ":%d encoding must matches %d != %d",line);
    TASSERT_EQUALS(test, e.chai, a.chai, ":%d chai must matches %p != %p :%d",line);}
}
static void ses_extract(test_t *test)
{
  CString *ca;
  SES a, b, e, e2;
  ca= CCreateStringWithBytes(NSUTF8StringEncoding,"abcdefghijklmnopqrstuvwxyz",26);
  a= CStringSES(ca);
  b= MSMakeSESWithBytes("abcdefghijklmnopqrstuvwxyz", 26, NSUTF8StringEncoding);
  TASSERT(test, SESEquals(a, b), "must be equals");

  e= SESExtractPart(a, ses_extract_test1);
  ses_check(test, a, e, 1, 5, __LINE__);

  e2= SESExtractPart(a, ses_extract_test2);
  TASSERT(test, !SESOK(e2), "Extract part test2 must extract nothing");

  e= SESWildcardsExtractPart(a, "nopqrst");
  ses_check(test, a, e, 13, 7, __LINE__);

  e= SESInsensitiveWildcardsExtractPart(a, "a");
  ses_check(test, a, e, 0, 1, __LINE__);

  e= SESInsensitiveWildcardsExtractPart(a, "z");
  ses_check(test, a, e, 25, 1, __LINE__);

  e2= SESWildcardsExtractPart(a, "CDEF");
  TASSERT(test, !SESOK(e2), "SESWildcardsExtractPart must extract nothing");
  e= SESInsensitiveWildcardsExtractPart(a, "CDEF");
  ses_check(test, a, e, 2, 4, __LINE__);
  e= SESInsensitiveWildcardsExtractPart(b, "CDEF");
  ses_check(test, b, e, 2, 4, __LINE__);

  e= SESWildcardsExtractPart(a, "?o??r??");
  ses_check(test, a, e, 13, 7, __LINE__);

  e= SESWildcardsExtractPart(a, "?o*r??");
  ses_check(test, a, e, 13, 7, __LINE__);

  e= SESInsensitiveWildcardsExtractPart(a, "B*?D");
  ses_check(test, a, e, 1, 3, __LINE__);

  e= SESInsensitiveWildcardsExtractPart(a, "D*");
  ses_check(test, a, e, 3, 23, __LINE__);

  e2= SESWildcardsExtractPart(a, "abcc");
  TASSERT(test, !SESOK(e2), "SESWildcardsExtractPart must extract nothing");

  e2= SESWildcardsExtractPart(a, "abc*c");
  TASSERT(test, !SESOK(e2), "SESWildcardsExtractPart must extract nothing");

  e2= SESWildcardsExtractPart(a, "abc?c");
  TASSERT(test, !SESOK(e2), "SESWildcardsExtractPart must extract nothing");

  RELEASE(ca);
}

testdef_t mscore_ses[]= {
  {"index"  ,NULL,ses_index  },
  {"equals" ,NULL,ses_equals },
  {"compare",NULL,ses_compare},
  {"extract",NULL,ses_extract},
  {"utf8"   ,NULL,ses_utf8   },
  {NULL}
};

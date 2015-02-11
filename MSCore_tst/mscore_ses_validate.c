#include "mscore_validate.h"

BOOL ses_extract_test1(unichar c)
{ return (unichar)'b' <= c && c <= (unichar)'f'; }
BOOL ses_extract_test2(unichar c)
{ return (unichar)'B' <= c && c <= (unichar)'F'; }

void ses_check(SES a, SES e, NSUInteger start, NSUInteger length)
{
  ASSERT(SESOK(e), "must extract something");
  ASSERT_EQUALS(e.start, start, "start must be %2$d, got %1$d");
  ASSERT_EQUALS(e.length, length, "length must be %2$d, got %1$d");
  ASSERT_EQUALS(e.source, a.source, "source must matches %p != %p");
  ASSERT_EQUALS(e.encoding, a.encoding, "encoding must matches %d != %d");
  ASSERT_EQUALS(e.chai, a.chai, "chai must matches %p != %p");
}

int ses_literals(void)
{
  SES a= SESFromLiteral("abcdef");
  NSUInteger i= SESStart(a);
  NSUInteger end= SESEnd(a);
  ASSERT(i < end, "There is still chars to tests");
  ASSERT(SESIndexN(a, &i) == (unichar)'a', "There is still chars to tests");
  ASSERT(i < end, "There is still chars to tests");
  ASSERT(SESIndexN(a, &i) == (unichar)'b', "There is still chars to tests");
  ASSERT(i < end, "There is still chars to tests");
  ASSERT(SESIndexN(a, &i) == (unichar)'c', "There is still chars to tests");
  ASSERT(i < end, "There is still chars to tests");
  ASSERT(SESIndexN(a, &i) == (unichar)'d', "There is still chars to tests");
  ASSERT(i < end, "There is still chars to tests");
  ASSERT(SESIndexN(a, &i) == (unichar)'e', "There is still chars to tests");
  ASSERT(i < end, "There is still chars to tests");
  ASSERT(SESIndexN(a, &i) == (unichar)'f', "There is still chars to tests");
  ASSERT(i == end, "There is no more chars to tests");
  return 0;
}

int ses_equals(void)
{
  NSUInteger i= 0;
  SES la, lb, ua, sa;
  la= SESFromLiteral("abcdef");
  ua= SESFromLiteral("ABCDEF");
  lb= SESFromLiteral("bcdef");
  sa= SESFromLiteral("0abcdef");
  ASSERT(SESEquals(la, la), "must be equals to itself");
  ASSERT(!SESEquals(la, ua), "case differs");
  ASSERT(!SESEquals(la, lb), "ses differs");
  ASSERT(SESInsensitiveEquals(la, ua), "must be equals");
  ASSERT(!SESEquals(la, sa), "sa is prefixed by '0'");
  SESIndexN(sa, &i);
  sa.length-= i - sa.start;
  sa.start= i;
  ASSERT(SESEquals(la, sa), "sa is start after '0'");
  return 0;
}

int ses_extract(void)
{
  SES a, w, e, e2;
  a= SESFromLiteral("abcdefghijklmnopqrstuvwxyz");
  e= SESExtractPart(a, ses_extract_test1);
  ses_check(a, e, 1, 5);
  
  e2= SESExtractPart(a, ses_extract_test2);
  ASSERT(!SESOK(e2), "Extract part test2 must extract nothing");
  
  w= SESFromLiteral("nopqrst");
  e= SESWildcardsExtractPart(a, w);
  ses_check(a, e, 13, 7);
  
  w= SESFromLiteral("CDEF");
  e2= SESWildcardsExtractPart(a, w);
  ASSERT(!SESOK(e2), "SESWildcardsExtractPart must extract nothing");
  e= SESInsensitiveWildcardsExtractPart(a, w);
  ses_check(a, e, 2, 4);
  
  w= SESFromLiteral("?o??r??");
  e= SESWildcardsExtractPart(a, w);
  ses_check(a, e, 13, 7);
  
  w= SESFromLiteral("?o*r??");
  e= SESWildcardsExtractPart(a, w);
  ses_check(a, e, 13, 7);
  
  w= SESFromLiteral("B*?D");
  e= SESInsensitiveWildcardsExtractPart(a, w);
  ses_check(a, e, 1, 3);
  
  w= SESFromLiteral("D*");
  e= SESInsensitiveWildcardsExtractPart(a, w);
  ses_check(a, e, 3, 23);
  
  w= SESFromLiteral("abcc");
  e2= SESWildcardsExtractPart(a, w);
  ASSERT(!SESOK(e2), "SESWildcardsExtractPart must extract nothing");
  w= SESFromLiteral("abc*c");
  e2= SESWildcardsExtractPart(a, w);
  ASSERT(!SESOK(e2), "SESWildcardsExtractPart must extract nothing");
  w= SESFromLiteral("abc?c");
  e2= SESWildcardsExtractPart(a, w);
  ASSERT(!SESOK(e2), "SESWildcardsExtractPart must extract nothing");
  
  return 0;
}

int mscore_ses_validate(void)
{
  testRun("literals", ses_literals);
  testRun("equals", ses_equals);
  testRun("extract", ses_extract);
  return 0;
}

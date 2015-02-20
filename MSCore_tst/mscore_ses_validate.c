#include "mscore_validate.h"

int ses_index(void)
{
  CString *c= CCreateStringWithBytes(NSUTF8StringEncoding,"abcdef",6);
  SES a= CStringSES(c);
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
  RELEASE(c);
  return 0;
}

int ses_equals(void)
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
  ASSERT(SESEquals(la, la), "must be equals to itself");
  ASSERT(!SESEquals(la, ua), "case differs");
  ASSERT(!SESEquals(la, lb), "ses differs");
  ASSERT(SESInsensitiveEquals(la, ua), "must be equals");
  ASSERT(!SESEquals(la, sa), "sa is prefixed by '0'");
  SESIndexN(sa, &i);
  sa.length-= i - sa.start;
  sa.start= i;
  ASSERT(SESEquals(la, sa), "sa is start after '0'");
  RELEASE(cla); RELEASE(clb); RELEASE(cua); RELEASE(csa);
  return 0;
}

BOOL ses_extract_test1(unichar c)
{ return (unichar)'b' <= c && c <= (unichar)'f'; }
BOOL ses_extract_test2(unichar c)
{ return (unichar)'B' <= c && c <= (unichar)'F'; }

void ses_check(SES a, SES e, NSUInteger start, NSUInteger length, int line)
{
  ASSERT(SESOK(e), ":%d must extract something",line);
  ASSERT_EQUALS(e.start, start, ":%d start must be %2$d, got %1$d",line);
  ASSERT_EQUALS(e.length, length, ":%d length must be %2$d, got %1$d",line);
  ASSERT_EQUALS(e.source, a.source, ":%d source must matches %p != %p",line);
  ASSERT_EQUALS(e.encoding, a.encoding, ":%d encoding must matches %d != %d",line);
  ASSERT_EQUALS(e.chai, a.chai, ":%d chai must matches %p != %p :%d",line);
}
int ses_extract(void)
{
  CString *ca;
  SES a, b, e, e2;
  ca= CCreateStringWithBytes(NSUTF8StringEncoding,"abcdefghijklmnopqrstuvwxyz",26);
  a= CStringSES(ca);
  b= MSMakeSESWithBytes("abcdefghijklmnopqrstuvwxyz", 26, NSUTF8StringEncoding);
  ASSERT(SESEquals(a, b), "must be equals");
  
  e= SESExtractPart(a, ses_extract_test1);
  ses_check(a, e, 1, 5, __LINE__);
  
  e2= SESExtractPart(a, ses_extract_test2);
  ASSERT(!SESOK(e2), "Extract part test2 must extract nothing");
  
  e= SESWildcardsExtractPart(a, "nopqrst");
  ses_check(a, e, 13, 7, __LINE__);
  
  e2= SESWildcardsExtractPart(a, "CDEF");
  ASSERT(!SESOK(e2), "SESWildcardsExtractPart must extract nothing");
  e= SESInsensitiveWildcardsExtractPart(a, "CDEF");
  ses_check(a, e, 2, 4, __LINE__);
  e= SESInsensitiveWildcardsExtractPart(b, "CDEF");
  ses_check(b, e, 2, 4, __LINE__);
  
  e= SESWildcardsExtractPart(a, "?o??r??");
  ses_check(a, e, 13, 7, __LINE__);
  
  e= SESWildcardsExtractPart(a, "?o*r??");
  ses_check(a, e, 13, 7, __LINE__);
  
  e= SESInsensitiveWildcardsExtractPart(a, "B*?D");
  ses_check(a, e, 1, 3, __LINE__);
  
  e= SESInsensitiveWildcardsExtractPart(a, "D*");
  ses_check(a, e, 3, 23, __LINE__);
  
  e2= SESWildcardsExtractPart(a, "abcc");
  ASSERT(!SESOK(e2), "SESWildcardsExtractPart must extract nothing");

  e2= SESWildcardsExtractPart(a, "abc*c");
  ASSERT(!SESOK(e2), "SESWildcardsExtractPart must extract nothing");

  e2= SESWildcardsExtractPart(a, "abc?c");
  ASSERT(!SESOK(e2), "SESWildcardsExtractPart must extract nothing");
  
  RELEASE(ca);
  return 0;
}

int mscore_ses_validate(void)
{
  testRun("index", ses_index);
  testRun("equals", ses_equals);
  testRun("extract", ses_extract);
  return 0;
}

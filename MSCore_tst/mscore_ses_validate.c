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

test_t mscore_ses[]= {
  {"index"  ,NULL,ses_index  ,INTITIALIZE_TEST_T_END},
  {"equals" ,NULL,ses_equals ,INTITIALIZE_TEST_T_END},
  {"extract",NULL,ses_extract,INTITIALIZE_TEST_T_END},
  {NULL}
};

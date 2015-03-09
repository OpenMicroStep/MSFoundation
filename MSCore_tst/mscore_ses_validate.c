#include "mscore_validate.h"

static int ses_index(void)
{
  int err= 0;
  CString *c= CCreateStringWithBytes(NSUTF8StringEncoding,"abcdef",6);
  SES a= CStringSES(c);
  NSUInteger i= SESStart(a);
  NSUInteger end= SESEnd(a);
  err+= ASSERT(i < end, "There is still chars to tests");
  err+= ASSERT(SESIndexN(a, &i) == (unichar)'a', "There is still chars to tests");
  err+= ASSERT(i < end, "There is still chars to tests");
  err+= ASSERT(SESIndexN(a, &i) == (unichar)'b', "There is still chars to tests");
  err+= ASSERT(i < end, "There is still chars to tests");
  err+= ASSERT(SESIndexN(a, &i) == (unichar)'c', "There is still chars to tests");
  err+= ASSERT(i < end, "There is still chars to tests");
  err+= ASSERT(SESIndexN(a, &i) == (unichar)'d', "There is still chars to tests");
  err+= ASSERT(i < end, "There is still chars to tests");
  err+= ASSERT(SESIndexN(a, &i) == (unichar)'e', "There is still chars to tests");
  err+= ASSERT(i < end, "There is still chars to tests");
  err+= ASSERT(SESIndexN(a, &i) == (unichar)'f', "There is still chars to tests");
  err+= ASSERT(i == end, "There is no more chars to tests");
  RELEASE(c);
  return err;
}

static int ses_equals(void)
{
  int err= 0;
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
  err+= ASSERT(SESEquals(la, la), "must be equals to itself");
  err+= ASSERT(!SESEquals(la, ua), "case differs");
  err+= ASSERT(!SESEquals(la, lb), "ses differs");
  err+= ASSERT(SESInsensitiveEquals(la, ua), "must be equals");
  err+= ASSERT(!SESEquals(la, sa), "sa is prefixed by '0'");
  SESIndexN(sa, &i);
  sa.length-= i - sa.start;
  sa.start= i;
  err+= ASSERT(SESEquals(la, sa), "sa is start after '0'");
  RELEASE(cla); RELEASE(clb); RELEASE(cua); RELEASE(csa);
  return err;
}

static BOOL ses_extract_test1(unichar c)
{ return (unichar)'b' <= c && c <= (unichar)'f'; }
static BOOL ses_extract_test2(unichar c)
{ return (unichar)'B' <= c && c <= (unichar)'F'; }

static int ses_check(SES a, SES e, NSUInteger start, NSUInteger length, int line)
{
  int err= 0;
  err+= ASSERT(SESOK(e), ":%d must extract something",line);
  if (SESOK(e)) {
    err+= ASSERT_EQUALS(e.start, start, ":%d start must matches %lu != %lu",line);
    err+= ASSERT_EQUALS(e.length, length, ":%d length must matches  %lu != %lu",line);
    err+= ASSERT_EQUALS(e.source, a.source, ":%d source must matches %p != %p",line);
    err+= ASSERT_EQUALS(e.encoding, a.encoding, ":%d encoding must matches %d != %d",line);
    err+= ASSERT_EQUALS(e.chai, a.chai, ":%d chai must matches %p != %p :%d",line);}
  return err;
}
static int ses_extract(void)
{
  int err= 0;
  CString *ca;
  SES a, b, e, e2;
  ca= CCreateStringWithBytes(NSUTF8StringEncoding,"abcdefghijklmnopqrstuvwxyz",26);
  a= CStringSES(ca);
  b= MSMakeSESWithBytes("abcdefghijklmnopqrstuvwxyz", 26, NSUTF8StringEncoding);
  err+= ASSERT(SESEquals(a, b), "must be equals");
  
  e= SESExtractPart(a, ses_extract_test1);
  err+= ses_check(a, e, 1, 5, __LINE__);
  
  e2= SESExtractPart(a, ses_extract_test2);
  err+= ASSERT(!SESOK(e2), "Extract part test2 must extract nothing");
  
  e= SESWildcardsExtractPart(a, "nopqrst");
  err+= ses_check(a, e, 13, 7, __LINE__);
  
  e= SESInsensitiveWildcardsExtractPart(a, "a");
  err+= ses_check(a, e, 0, 1, __LINE__);
  
  e= SESInsensitiveWildcardsExtractPart(a, "z");
  err+= ses_check(a, e, 25, 1, __LINE__);
  
  e2= SESWildcardsExtractPart(a, "CDEF");
  err+= ASSERT(!SESOK(e2), "SESWildcardsExtractPart must extract nothing");
  e= SESInsensitiveWildcardsExtractPart(a, "CDEF");
  err+= ses_check(a, e, 2, 4, __LINE__);
  e= SESInsensitiveWildcardsExtractPart(b, "CDEF");
  err+= ses_check(b, e, 2, 4, __LINE__);
  
  e= SESWildcardsExtractPart(a, "?o??r??");
  err+= ses_check(a, e, 13, 7, __LINE__);
  
  e= SESWildcardsExtractPart(a, "?o*r??");
  err+= ses_check(a, e, 13, 7, __LINE__);
  
  e= SESInsensitiveWildcardsExtractPart(a, "B*?D");
  err+= ses_check(a, e, 1, 3, __LINE__);
  
  e= SESInsensitiveWildcardsExtractPart(a, "D*");
  err+= ses_check(a, e, 3, 23, __LINE__);
  
  e2= SESWildcardsExtractPart(a, "abcc");
  err+= ASSERT(!SESOK(e2), "SESWildcardsExtractPart must extract nothing");

  e2= SESWildcardsExtractPart(a, "abc*c");
  err+= ASSERT(!SESOK(e2), "SESWildcardsExtractPart must extract nothing");

  e2= SESWildcardsExtractPart(a, "abc?c");
  err+= ASSERT(!SESOK(e2), "SESWildcardsExtractPart must extract nothing");

  
  RELEASE(ca);
  return err;
}

test_t mscore_ses[]= {
  {"index"  ,NULL,ses_index  ,INTITIALIZE_TEST_T_END},
  {"equals" ,NULL,ses_equals ,INTITIALIZE_TEST_T_END},
  {"extract",NULL,ses_extract,INTITIALIZE_TEST_T_END},
  {NULL}
};

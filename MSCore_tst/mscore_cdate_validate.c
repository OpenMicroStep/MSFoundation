// mscore_cdate_validate.c, ecb, 130911

#include "mscore_validate.h"

static void cdate_constants(test_t *test)
{
  TASSERT(test, CDateDistantPast  , "No distantPast");
  TASSERT(test, CDateDistantFuture, "No distantFuture");
  TASSERT(test, CDate19700101     , "No 19700101");
  TASSERT(test, CDate20010101     , "No 20010101");
}

static void cdate_create(test_t *test)
  {
  CDate *c,*d,*e,*f,*g;
  c= CCreateDateNow();
  d= CCreateDayDate(c);
  e= CCreateDateToday();
  TASSERT_EQUALS(test, RETAINCOUNT(c), 1, "Bad retain count: %lu",WLU(RETAINCOUNT(c)));
  TASSERT_EQUALS(test, RETAINCOUNT(d), 1, "Bad retain count: %lu",WLU(RETAINCOUNT(d)));
  TASSERT_EQUALS(test, RETAINCOUNT(e), 1, "Bad retain count: %lu",WLU(RETAINCOUNT(e)));
  TASSERT(test, !CDateEquals(c, d), "c & d are equals");
  TASSERT(test,  CDateEquals(d, e), "d & e are not equals");
  RELEASE(c);
  RELEASE(d);
  RELEASE(e);
  TASSERT(test, !CVerifyYMD(   0, 1, 1), "1/1/0 is valid !");
  TASSERT(test, !CVerifyYMD(  10,13,13), "13/13/10 is valid !");
  TASSERT(test, !CVerifyYMD(2001, 2,29), "29/2/2001 is valid !");
  c= CCreateDateWithYMD(1, 1, 1);
  d= CCreateDateWithYMD(1, 2, 28);
  f= CCreateDateWithYMDHMS(2000, 12, 31, 23,59,50);
  e= CCreateDayDate(f);
  g= (CDate*)MSCreateObjectWithClassIndex(CDateClassIndex);
//fprintf(stdout, "1/1/1-0:0 %lld %lld %lld\n",d->interval,d->interval/86400,(d->interval/730485)*730485);
  TASSERT_EQUALS(test, c->interval, -63113904000LL, "%lld != %lld");
  TASSERT_EQUALS(test, d->interval, -63113904000LL+(31LL+28LL-1LL)*86400LL, "%lld != %lld");
  TASSERT_EQUALS(test, e->interval,       -86400LL, "%lld != %lld");
  TASSERT_EQUALS(test, f->interval,          -10LL, "%lld != %lld");
  TASSERT_EQUALS(test, g->interval,            0LL, "%lld != %lld");

  TASSERT_EQUALS(test, CDateDayOfWeek(c), 0, "%u != %u");
  TASSERT_EQUALS(test, CDateDayOfWeek(d), 2, "%u != %u");
  TASSERT_EQUALS(test, CDateDayOfWeek(e), 6, "%u != %u");
  TASSERT_EQUALS(test, CDateDayOfWeek(f), 6, "%u != %u");
  TASSERT_EQUALS(test, CDateDayOfWeek(g), 0, "%u != %u");

  TASSERT_EQUALS(test, CDateDayOfMonth(c),  1, "%u != %u");
  TASSERT_EQUALS(test, CDateDayOfMonth(d), 28, "%u != %u");
  TASSERT_EQUALS(test, CDateDayOfMonth(e), 31, "%u != %u");
  TASSERT_EQUALS(test, CDateDayOfMonth(f), 31, "%u != %u");
  TASSERT_EQUALS(test, CDateDayOfMonth(g),  1, "%u != %u");

  TASSERT_EQUALS(test, CDateDayOfYear(c),     1, "%u != %u");
  TASSERT_EQUALS(test, CDateDayOfYear(d), 31+28, "%u != %u");
  TASSERT_EQUALS(test, CDateDayOfYear(e),   366, "%u != %u");
  TASSERT_EQUALS(test, CDateDayOfYear(f),   366, "%u != %u");
  TASSERT_EQUALS(test, CDateDayOfYear(g),     1, "%u != %u");

  TASSERT_EQUALS(test, CDateDayOfCommonEra(c),     1, "%u != %u");
  TASSERT_EQUALS(test, CDateDayOfCommonEra(d), 31+28, "%u != %u");
  TASSERT_EQUALS(test, (int)CDateDayOfCommonEra(e), CDateDaysBetweenDates(c,e,NO)+1, "%u != %d");
  TASSERT_EQUALS(test, (int)CDateDayOfCommonEra(f), CDateDaysBetweenDates(c,f,NO)+1, "%u != %d");
  TASSERT_EQUALS(test, (int)CDateDayOfCommonEra(g), CDateDaysBetweenDates(c,g,NO)+1, "%u != %d");
   

  TASSERT_EQUALS(test, CDateWeekOfYear(c),  1, "%u != %u");
  TASSERT_EQUALS(test, CDateWeekOfYear(d),  9, "%u != %u");
  TASSERT_EQUALS(test, CDateWeekOfYear(e), 52, "%u != %u");
  TASSERT_EQUALS(test, CDateWeekOfYear(f), 52, "%u != %u");
  TASSERT_EQUALS(test, CDateWeekOfYear(g),  1, "%u != %u");

  TASSERT_EQUALS(test, CDateMonthOfYear(c),  1, "%u != %u");
  TASSERT_EQUALS(test, CDateMonthOfYear(d),  2, "%u != %u");
  TASSERT_EQUALS(test, CDateMonthOfYear(e), 12, "%u != %u");
  TASSERT_EQUALS(test, CDateMonthOfYear(f), 12, "%u != %u");
  TASSERT_EQUALS(test, CDateMonthOfYear(g),  1, "%u != %u");

  TASSERT_EQUALS(test, CDateYearOfCommonEra(c),    1, "%u != %u");
  TASSERT_EQUALS(test, CDateYearOfCommonEra(d),    1, "%u != %u");
  TASSERT_EQUALS(test, CDateYearOfCommonEra(e), 2000, "%u != %u");
  TASSERT_EQUALS(test, CDateYearOfCommonEra(f), 2000, "%u != %u");
  TASSERT_EQUALS(test, CDateYearOfCommonEra(g), 2001, "%u != %u");

  TASSERT(test, !CDateIsLeapYear(c), "%d");
  TASSERT(test, !CDateIsLeapYear(d), "%d");
  TASSERT(test,  CDateIsLeapYear(e), "%d");
  TASSERT(test,  CDateIsLeapYear(f), "%d");
  TASSERT(test, !CDateIsLeapYear(g), "%d");

  RELEASE(c);
  RELEASE(d);
  RELEASE(e);
  RELEASE(f);
  RELEASE(g);
  c= CCreateDateWithYMD(2013, 10, 25);
  TASSERT_EQUALS(test, CDateDayOfWeek(c) ,  4, "A70-%u != %u");
  TASSERT_EQUALS(test, CDateWeekOfYear(c), 43, "A71-%u != %u");
  RELEASE(c);
  }

#define M1 10000
static void cdate_create2(test_t *test)
  {
  int i;
  MSTimeInterval t;
  CDate *c[M1],*d,*e; // last date: 3432/07/11-02:51:40
  CString *s; CBuffer *b;
  
  for (t= -63113904000LL, i= 0; i<M1; i++) { //-63113904000LL
    c[i]= (CDate*)MSCreateObjectWithClassIndex(CDateClassIndex);
    t= t +
       ((i % 3600LL) / 60LL)*86400LL +
       (i % 60LL)*3600LL +
       i +
       i*(i/4);
    c[i]->interval= t;}
  for (i= 0; i<M1; i++) {
    s= CCreateString(0);
    CStringAppendFormat(s, "%@", c[i]);
    b= CCreateBufferWithString(s, NSUTF8StringEncoding);
    if (TASSERT(test, CVerifyYMD(CDateYearOfCommonEra(c[i]), CDateMonthOfYear(c[i]), CDateDayOfMonth(c[i])),
                "%d-bad date %s",i, CBufferCString(b))) {
      d= CCreateDateWithYMD(CDateYearOfCommonEra(c[i]), CDateMonthOfYear(c[i]), CDateDayOfMonth(c[i]));
      e= CCreateDayDate(c[i]);
      CStringAppendFormat(s, " %@ %@", d, e);
      RELEASE(b); b= CCreateBufferWithString(s, NSUTF8StringEncoding);
      TASSERT(test, CDateEquals(d, e), "%d-d & e are not equals %lld %lld %lld %s",
              i,d->interval,e->interval,d->interval-e->interval,CBufferCString(b));
      RELEASE(d); RELEASE(e);}
    RELEASE(b); RELEASE(s);}
  for (i= 0; i<M1; i++) RELEASE(c[i]);
  }

#define M2 200000 // last date: 3834/01/27
static void cdate_week(test_t *test)
  {
  int i; unsigned w;
  MSTimeInterval t;
  CDate *c,*d; CBuffer *b;
  
  c= CCreateDateWithYMD(1, 1, 1);
  d= CCreateDateWithYMD(1, 1, 1);
  while (CDateDayOfWeek(c)!=0) {c->interval+= 86400LL; d->interval+= 86400LL;}
  w= CDateDayOfMonth(c)<=4 ? 1 : 2;
  for (t= c->interval, i= 0; i<M2; i++) {
    d->interval= c->interval+7LL*86400LL-1LL;
    b= CCreateUTF8BufferWithObjectDescription((id)d);
    TASSERT_EQUALS(test, CDateWeekOfYear(d), w, "%d-%s bad week %d expected %d ",i,CBufferCString(b));
    RELEASE(b);
    d->interval= c->interval+2LL*(7LL*86400LL);
    if (4 < CDateDayOfYear(d) && CDateDayOfYear(d) <= 11) w= 1;
    else w+= 1;
    c->interval+= 7LL*86400LL;
    b= CCreateUTF8BufferWithObjectDescription((id)d);
    TASSERT_EQUALS(test, CDateWeekOfYear(c), w, "%d-%s bad week %d expected %d ",i,CBufferCString(b));
    RELEASE(b);}
  RELEASE(c); RELEASE(d);
  }

test_t mscore_cdate[]= {
  {"constants",NULL,cdate_constants,INTITIALIZE_TEST_T_END},
  {"create"   ,NULL,cdate_create   ,INTITIALIZE_TEST_T_END},
  {"create2"  ,NULL,cdate_create2  ,INTITIALIZE_TEST_T_END},
  {"week"     ,NULL,cdate_week     ,INTITIALIZE_TEST_T_END},
  {NULL}
};

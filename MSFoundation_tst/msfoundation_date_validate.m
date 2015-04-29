// msfoundation_date_validate.m, ecb, 130911

#include "msfoundation_validate.h"

static void date_create(test_t *test)
  {
  MSDate *c,*d,*e,*f,*g;
  c= RETAIN([MSDate now]);
  d= RETAIN([c dateWithoutTime]);
  e= RETAIN([MSDate today]);
  TASSERT_EQUALS(test, RETAINCOUNT(c), 2, "A1-Bad retain count: %lu",WLU(RETAINCOUNT(c)));
  TASSERT_EQUALS(test, RETAINCOUNT(d), 2, "A2-Bad retain count: %lu",WLU(RETAINCOUNT(d)));
  TASSERT_EQUALS(test, RETAINCOUNT(e), 2, "A3-Bad retain count: %lu",WLU(RETAINCOUNT(e)));
  TASSERT_ISNOTEQUAL(test, c, d, "A4-c & d are equals");
  TASSERT(test, [d isEqualToDate:e], "A5-d & e are not equals");
  RELEASE(c);
  RELEASE(d);
  RELEASE(e);
  TASSERT(test, ![MSDate verifyYear:0 month:1 day:1], "A10-1/1/0 is valid !");
  TASSERT(test, ![MSDate verifyYear:10 month:13 day:13], "A11-13/13/10 is valid !");
  TASSERT(test, ![MSDate verifyYear:2001 month:2 day:29], "A12-29/2/2001 is valid !");
  c= RETAIN(YMD(1,1, 1));
  d= RETAIN(YMD(1,2,28));
  f= RETAIN(YMDHMS(2000, 12, 31, 23,59,50));
  e= RETAIN([f dateWithoutTime]);
  g= MSCreateObjectWithClassIndex(CDateClassIndex);
//fprintf(stdout, "1/1/1-0:0 %lld %lld %lld\n",d->interval,d->interval/86400,(d->interval/730485)*730485);
  TASSERT_EQUALS(test, [c secondsSinceLocalReferenceDate], -63113904000LL, "A21-%lld",[c secondsSinceLocalReferenceDate]);
  TASSERT_EQUALS(test, [d secondsSinceLocalReferenceDate], -63113904000LL+(31LL+28LL-1LL)*86400LL, "A22-%lld",[d secondsSinceLocalReferenceDate]);
  TASSERT_EQUALS(test, [e secondsSinceLocalReferenceDate], -86400LL, "A23-%lld",[e secondsSinceLocalReferenceDate]);
  TASSERT_EQUALS(test, [f secondsSinceLocalReferenceDate], -10LL, "A24-%lld",[f secondsSinceLocalReferenceDate]);
  TASSERT_EQUALS(test, [g secondsSinceLocalReferenceDate], 0LL, "A25-%lld",[g secondsSinceLocalReferenceDate]);

  TASSERT_EQUALS(test, [c dayOfWeek], 0, "A26-%u",[c dayOfWeek]);
  TASSERT_EQUALS(test, [d dayOfWeek], 2, "A27-%u",[d dayOfWeek]);
  TASSERT_EQUALS(test, [e dayOfWeek], 6, "A28-%u",[e dayOfWeek]);
  TASSERT_EQUALS(test, [f dayOfWeek], 6, "A29-%u",[f dayOfWeek]);
  TASSERT_EQUALS(test, [g dayOfWeek], 0, "A30-%u",[g dayOfWeek]);

  TASSERT_EQUALS(test, [c dayOfMonth], 1, "A31-%u",[c dayOfMonth]);
  TASSERT_EQUALS(test, [d dayOfMonth], 28, "A32-%u",[d dayOfMonth]);
  TASSERT_EQUALS(test, [e dayOfMonth], 31, "A33-%u",[e dayOfMonth]);
  TASSERT_EQUALS(test, [f dayOfMonth], 31, "A34-%u",[f dayOfMonth]);
  TASSERT_EQUALS(test, [g dayOfMonth], 1, "A35-%u",[g dayOfMonth]);

  TASSERT_EQUALS(test, [c dayOfYear], 1, "A36-%u",[c dayOfYear]);
  TASSERT_EQUALS(test, [d dayOfYear], 31+28, "A37-%u",[d dayOfYear]);
  TASSERT_EQUALS(test, [e dayOfYear], 366, "A38-%u",[e dayOfYear]);
  TASSERT_EQUALS(test, [f dayOfYear], 366, "A39-%u",[f dayOfYear]);
  TASSERT_EQUALS(test, [g dayOfYear], 1, "A40-%u",[g dayOfYear]);

  TASSERT_EQUALS(test, [c dayOfCommonEra], 1, "A41-%u",[c dayOfCommonEra]);
  TASSERT_EQUALS(test, [d dayOfCommonEra], 31+28, "A42-%u",[d dayOfCommonEra]);
  TASSERT_EQUALS(test, (int)[e dayOfCommonEra], [e daysSinceDate:c usesTime:NO]+1, "A43-%u %d",[e dayOfCommonEra],[e daysSinceDate:c usesTime:NO]);
   
  TASSERT_EQUALS(test, (int)[f dayOfCommonEra], [f daysSinceDate:c usesTime:NO]+1, "A44-%u %d",[f dayOfCommonEra],[f daysSinceDate:c usesTime:NO]);
   
  TASSERT_EQUALS(test, (int)[g dayOfCommonEra], [g daysSinceDate:c usesTime:NO]+1, "A45-%u %d",[g dayOfCommonEra],[g daysSinceDate:c usesTime:NO]);
   

  TASSERT_EQUALS(test, [c weekOfYear], 1, "A46-%u",[c weekOfYear]);
  TASSERT_EQUALS(test, [d weekOfYear], 9, "A47-%u",[d weekOfYear]);
  TASSERT_EQUALS(test, [e weekOfYear], 52, "A48-%u",[e weekOfYear]);
  TASSERT_EQUALS(test, [f weekOfYear], 52, "A49-%u",[f weekOfYear]);
  TASSERT_EQUALS(test, [g weekOfYear], 1, "A50-%u",[g weekOfYear]);

  TASSERT_EQUALS(test, [c monthOfYear], 1, "A51-%u",[c monthOfYear]);
  TASSERT_EQUALS(test, [d monthOfYear], 2, "A52-%u",[d monthOfYear]);
  TASSERT_EQUALS(test, [e monthOfYear], 12, "A53-%u",[e monthOfYear]);
  TASSERT_EQUALS(test, [f monthOfYear], 12, "A54-%u",[f monthOfYear]);
  TASSERT_EQUALS(test, [g monthOfYear], 1, "A55-%u",[g monthOfYear]);

  TASSERT_EQUALS(test, [c yearOfCommonEra], 1, "A56-%u",[c yearOfCommonEra]);
  TASSERT_EQUALS(test, [d yearOfCommonEra], 1, "A57-%u",[d yearOfCommonEra]);
  TASSERT_EQUALS(test, [e yearOfCommonEra], 2000, "A58-%u",[e yearOfCommonEra]);
  TASSERT_EQUALS(test, [f yearOfCommonEra], 2000, "A59-%u",[f yearOfCommonEra]);
  TASSERT_EQUALS(test, [g yearOfCommonEra], 2001, "A60-%u",[g yearOfCommonEra]);

  TASSERT(test, ![c isLeapYear], "A61-%d",[c isLeapYear]);
  TASSERT(test, ![d isLeapYear], "A62-%d",[d isLeapYear]);
  TASSERT(test, [e isLeapYear], "A63-%d",[e isLeapYear]);
  TASSERT(test, [f isLeapYear], "A64-%d",[f isLeapYear]);
  TASSERT(test, ![g isLeapYear], "A65-%d",[g isLeapYear]);

  RELEASE(c);
  RELEASE(d);
  RELEASE(e);
  RELEASE(f);
  RELEASE(g);
  c= RETAIN(YMD(2013, 10, 25));
  TASSERT_EQUALS(test, [c dayOfWeek], 4, "A70-%u",[c dayOfWeek]);
  TASSERT_EQUALS(test, [c weekOfYear], 43, "A71-%u",[c weekOfYear]);
  RELEASE(c);
  }

#define M1 10000
static void date_create2(test_t *test)
  {
  int i;
  MSTimeInterval t;
  MSDate *c[M1],*d= nil,*e= nil; // last date: 3432/07/11-02:51:40
  
  for (t= -63113904000LL, i= 0; i<M1; i++) { //-63113904000LL
    c[i]= MSCreateObjectWithClassIndex(CDateClassIndex);
    t= t +
       ((i % 3600LL) / 60LL)*86400LL +
       (i % 60LL)*3600LL +
       i +
       i*(i/4);
    ((CDate*)c[i])->interval= t;}
//cdate_print(c[M1-1]);
  for (i= 0; i<M1; i++) {
    if (TASSERT(test,
          [MSDate verifyYear:[c[i] yearOfCommonEra] month:[c[i] monthOfYear] day:[c[i] dayOfMonth]
            hour:[c[i] hourOfDay] minute:[c[i] minuteOfHour] second:[c[i] secondOfMinute]],
          "B1-%d-bad date %s",i,[[c[i] description] UTF8String])) {
      d= RETAIN(YMD([c[i] yearOfCommonEra], [c[i] monthOfYear], [c[i] dayOfMonth]));
      e= RETAIN([c[i] dateWithoutTime]);
      TASSERT(test, [d isEqualToDate:e],
        "B2-%d-d & e are not equals %lld %lld %lld %s %s %s",i,
        [d secondsSinceLocalReferenceDate],[e secondsSinceLocalReferenceDate],[d secondsSinceLocalReferenceDate]-[e secondsSinceLocalReferenceDate],
        [[c[i] description] UTF8String],[[d description] UTF8String],[[e description] UTF8String]);}
    RELEASE(d); RELEASE(e);}
    for (i= 0; i<M1; i++) RELEASE(c[i]);
  }

#define M2 200000 // last date: 3834/01/27
static void date_week(test_t *test)
  {
  int i; unsigned w;
  MSTimeInterval t;
  MSDate *c,*d;
  
  c= RETAIN(YMD(1, 1, 1));
  d= RETAIN(YMD(1, 1, 1));
  while ([c dayOfWeek]!=0) {
    ASSIGN(c, [c dateByAddingYears:0 months:0 days:1]);
    ASSIGN(d, [d dateByAddingYears:0 months:0 days:1]);}
  w= [c dayOfMonth]<=4 ? 1 : 2;
  for (t= [c secondsSinceLocalReferenceDate], i= 0; i<M2; i++) {
    ASSIGN(d, [c dateByAddingHours:0 minutes:0 seconds:7*86400-1]);
    TASSERT_EQUALS(test, [d weekOfYear], w, "C1-%d-bad week %d expected %d %s",i,[d weekOfYear],w,[[d description] UTF8String]);
    ASSIGN(d, [c dateByAddingHours:0 minutes:0 seconds:2*7*86400]);
    if (4 < [d dayOfYear] && [d dayOfYear] <= 11) w= 1;
    else w+= 1;
    ASSIGN(c, [c dateByAddingYears:0 months:0 days:7]);
    TASSERT_EQUALS(test, [c weekOfYear], w, "C2-%d-bad week %d expected %d %s",i,[c weekOfYear],w,[[c description] UTF8String]);}
  RELEASE(c); RELEASE(d);
  }

static void date_firstLast(test_t *test)
  {
  MSDate *d,*e,*f;

  d= [MSDate now];
  e= [d dateOfFirstDayOfYear];
  f= [[d dateWithoutTime] dateByAddingYears:0 months:0 days:-(int)[d dayOfYear]+1];
  TASSERT(test, [e isEqualToDate:f], "D1-bad fisrt day of year %s %s",[[e description] UTF8String],[[f description] UTF8String]);
  e= [d dateOfLastDayOfYear];
  f= [[d dateWithoutTime] dateByAddingYears:0 months:0 days:365+([d isLeapYear]?1:0)-(int)[d dayOfYear]];
  TASSERT(test, [e isEqualToDate:f], "D2-bad last day of year %s %s",[[e description] UTF8String],[[f description] UTF8String]);

  e= [d dateOfFirstDayOfMonth];
  f= [[d dateWithoutTime] dateByAddingYears:0 months:0 days:-(int)[d dayOfMonth]+1];
  TASSERT(test, [e isEqualToDate:f], "D3-bad fisrt day of month %s %s",[[e description] UTF8String],[[f description] UTF8String]);
  e= [d dateOfLastDayOfMonth];
  f= [[d dateWithoutTime] dateByAddingYears:0 months:0 days:(int)[d lastDayOfMonth]-(int)[d dayOfMonth]];
  TASSERT(test, [e isEqualToDate:f], "D4-bad last day of month %s %s",[[e description] UTF8String],[[f description] UTF8String]);

  e= [d dateOfFirstDayOfWeek];
  f= [[d dateWithoutTime] dateByAddingYears:0 months:0 days:-(int)[d dayOfWeek]];
  TASSERT(test, [e isEqualToDate:f], "D5-bad fisrt day of week %s %s",[[e description] UTF8String],[[f description] UTF8String]);
  e= [d dateOfLastDayOfWeek];
  f= [[d dateWithoutTime] dateByAddingYears:0 months:0 days:6-(int)[d dayOfWeek]];
  TASSERT(test, [e isEqualToDate:f], "D6-bad last day of week %s %s",[[e description] UTF8String],[[f description] UTF8String]);
  }

static void date_replacing(test_t *test)
  {
  MSDate *d,*e,*f; unsigned j;

  d= YMDHMS(777, 7, 7, 7, 7, 7);
  e= [d dateByReplacingYear:0 month:0 day:1];
  f= [d dateByAddingYears:0 months:0 days:-6];
  TASSERT(test, [e isEqualToDate:f], "E1-bad replacing %s %s",[[e description] UTF8String],[[f description] UTF8String]);
  e= [d dateByReplacingYear:1 month:1 day:1];
  f= YMD(1, 1, 1);
  TASSERT(test, [[e dateWithoutTime] isEqualToDate:f], "E2-bad replacing %s %s",[[e description] UTF8String],[[f description] UTF8String]);
  e= [d dateByReplacingWeek:2];
  j= [d dayOfWeek];
  f= YMDHMS(777, 1, 1, 7, 7, 7);
  while ([f dayOfWeek]!=j || [f weekOfYear]!=2) {
    f= [f dateByAddingYears:0 months:0 days:1];}
  TASSERT(test, [e isEqualToDate:f], "E3-bad replacing %s %s",[[e description] UTF8String],[[f description] UTF8String]);
  e= [d dateByReplacingHour:2 minute:1 second:0];
  f= [d dateByAddingHours:-5 minutes:-6 seconds:-7];
  TASSERT(test, [e isEqualToDate:f], "E4-bad replacing %s %s",[[e description] UTF8String],[[f description] UTF8String]);
  }

static void date_now(test_t *test)
  {
  MSDate *d1,*d2m; NSDate *d2; MSTimeInterval dt1m,dt2m; NSTimeInterval dt1n,dt2n;

  d1= [MSDate now];
  d2= [NSDate date];
  dt1m= [d1 secondsSinceLocalReferenceDate];
  dt2m= [d2 secondsSinceLocalReferenceDate];
  dt1n= [d1 timeIntervalSinceReferenceDate];
  dt2n= [d2 timeIntervalSinceReferenceDate];
  d2m= [MSDate dateWithSecondsSinceLocalReferenceDate:dt2m];
  TASSERT(test, ABS(dt1m-dt2m)<=1, "F1-bad now %s %s",[[d1 description] UTF8String],[[d2m description] UTF8String]);
  TASSERT(test, ABS(dt1n-dt2n)<=1, "F2-bad now %f %f %f %lld %lld %lld %s %s %s %s",
    dt1n,dt2n,dt1n-dt2n,dt1m,dt2m,dt1m-dt2m,
    [[d1 descriptionRfc1123] UTF8String],
    [[d1 descriptionWithCalendarFormat:@"%a, %d %b %Y %H:%M:%S"] UTF8String],
    [[d1 description] UTF8String],[[d2m description] UTF8String]);
  }

test_t msfoundation_date[]= {
  {"create"    ,NULL,date_create   ,INTITIALIZE_TEST_T_END},
  {"create2"   ,NULL,date_create2  ,INTITIALIZE_TEST_T_END},
  {"week"      ,NULL,date_week     ,INTITIALIZE_TEST_T_END},
  {"first/last",NULL,date_firstLast,INTITIALIZE_TEST_T_END},
  {"replacing" ,NULL,date_replacing,INTITIALIZE_TEST_T_END},
  {"now"       ,NULL,date_now      ,INTITIALIZE_TEST_T_END},
  {NULL}
};

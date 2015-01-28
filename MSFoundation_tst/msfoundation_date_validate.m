// msfoundation_date_validate.m, ecb, 130911

#include "msfoundation_validate.h"

static inline void date_print(MSDate *d)
  {
  fprintf(stdout, "%u-%02u-%02u %02u:%02u:%02d %lld\n",[d yearOfCommonEra], [d monthOfYear], [d dayOfMonth], [d hourOfDay], [d minuteOfHour], [d secondOfMinute],[d secondsSinceLocalReferenceDate]);
  }

static inline int date_create(void)
  {
  int err= 0;
  MSDate *c,*d,*e,*f,*g;
  c= RETAIN([MSDate now]);
  d= RETAIN([c dateWithoutTime]);
  e= RETAIN([MSDate today]);
  if (RETAINCOUNT(c)!=2) {
    fprintf(stdout, "A1-Bad retain count: %lu\n",WLU(RETAINCOUNT(c))); err++;}
  if (RETAINCOUNT(d)!=2) {
    fprintf(stdout, "A2-Bad retain count: %lu\n",WLU(RETAINCOUNT(d))); err++;}
  if (RETAINCOUNT(e)!=2) {
    fprintf(stdout, "A3-Bad retain count: %lu\n",WLU(RETAINCOUNT(e))); err++;}
  if ([c isEqual:d]) {
    fprintf(stdout, "A4-c & d are equals\n");     err++;}
  if (![d isEqualToDate:e]) {
    fprintf(stdout, "A5-d & e are not equals\n"); err++;}
  RELEASE(c);
  RELEASE(d);
  RELEASE(e);
  if ([MSDate verifyYear:0 month:1 day:1]) {
    fprintf(stdout, "A10-1/1/0 is valid !\n");     err++;}
  if ([MSDate verifyYear:10 month:13 day:13]) {
    fprintf(stdout, "A11-13/13/10 is valid !\n");  err++;}
  if ([MSDate verifyYear:2001 month:2 day:29]) {
    fprintf(stdout, "A12-29/2/2001 is valid !\n"); err++;}
  c= RETAIN(YMD(1,1, 1));
  d= RETAIN(YMD(1,2,28));
  f= RETAIN(YMDHMS(2000, 12, 31, 23,59,50));
  e= RETAIN([f dateWithoutTime]);
  g= MSCreateObjectWithClassIndex(CDateClassIndex);
//fprintf(stdout, "1/1/1-0:0 %lld %lld %lld\n",d->interval,d->interval/86400,(d->interval/730485)*730485);
  if ([c secondsSinceLocalReferenceDate]!=-63113904000LL) {
    fprintf(stdout, "A21-%lld\n",[c secondsSinceLocalReferenceDate]); err++;}
  if ([d secondsSinceLocalReferenceDate]!=-63113904000LL+(31LL+28LL-1LL)*86400LL) {
    fprintf(stdout, "A22-%lld\n",[d secondsSinceLocalReferenceDate]); err++;}
  if ([e secondsSinceLocalReferenceDate]!=-86400LL) {
    fprintf(stdout, "A23-%lld\n",[e secondsSinceLocalReferenceDate]); err++;}
  if ([f secondsSinceLocalReferenceDate]!=-10LL) {
    fprintf(stdout, "A24-%lld\n",[f secondsSinceLocalReferenceDate]); err++;}
  if ([g secondsSinceLocalReferenceDate]!=0LL) {
    fprintf(stdout, "A25-%lld\n",[g secondsSinceLocalReferenceDate]); err++;}

  if ([c dayOfWeek]!=0) {
    fprintf(stdout, "A26-%u\n",[c dayOfWeek]); err++;}
  if ([d dayOfWeek]!=2) {
    fprintf(stdout, "A27-%u\n",[d dayOfWeek]); err++;}
  if ([e dayOfWeek]!=6) {
    fprintf(stdout, "A28-%u\n",[e dayOfWeek]); err++;}
  if ([f dayOfWeek]!=6) {
    fprintf(stdout, "A29-%u\n",[f dayOfWeek]); err++;}
  if ([g dayOfWeek]!=0) {
    fprintf(stdout, "A30-%u\n",[g dayOfWeek]); err++;}

  if ([c dayOfMonth]!=1) {
    fprintf(stdout, "A31-%u\n",[c dayOfMonth]); err++;}
  if ([d dayOfMonth]!=28) {
    fprintf(stdout, "A32-%u\n",[d dayOfMonth]); err++;}
  if ([e dayOfMonth]!=31) {
    fprintf(stdout, "A33-%u\n",[e dayOfMonth]); err++;}
  if ([f dayOfMonth]!=31) {
    fprintf(stdout, "A34-%u\n",[f dayOfMonth]); err++;}
  if ([g dayOfMonth]!=1) {
    fprintf(stdout, "A35-%u\n",[g dayOfMonth]); err++;}

  if ([c dayOfYear]!=1) {
    fprintf(stdout, "A36-%u\n",[c dayOfYear]); err++;}
  if ([d dayOfYear]!=31+28) {
    fprintf(stdout, "A37-%u\n",[d dayOfYear]); err++;}
  if ([e dayOfYear]!=366) {
    fprintf(stdout, "A38-%u\n",[e dayOfYear]); err++;}
  if ([f dayOfYear]!=366) {
    fprintf(stdout, "A39-%u\n",[f dayOfYear]); err++;}
  if ([g dayOfYear]!=1) {
    fprintf(stdout, "A40-%u\n",[g dayOfYear]); err++;}

  if ([c dayOfCommonEra]!=1) {
    fprintf(stdout, "A41-%u\n",[c dayOfCommonEra]); err++;}
  if ([d dayOfCommonEra]!=31+28) {
    fprintf(stdout, "A42-%u\n",[d dayOfCommonEra]); err++;}
  if ((int)[e dayOfCommonEra]!=[e daysSinceDate:c usesTime:NO]+1) {
    fprintf(stdout, "A43-%u %d\n",[e dayOfCommonEra],[e daysSinceDate:c usesTime:NO]);
    err++;}
  if ((int)[f dayOfCommonEra]!=[f daysSinceDate:c usesTime:NO]+1) {
    fprintf(stdout, "A44-%u %d\n",[f dayOfCommonEra],[f daysSinceDate:c usesTime:NO]);
    err++;}
  if ((int)[g dayOfCommonEra]!=[g daysSinceDate:c usesTime:NO]+1) {
    fprintf(stdout, "A45-%u %d\n",[g dayOfCommonEra],[g daysSinceDate:c usesTime:NO]);
    err++;}

  if ([c weekOfYear]!=1) {
    fprintf(stdout, "A46-%u\n",[c weekOfYear]); err++;}
  if ([d weekOfYear]!=9) {
    fprintf(stdout, "A47-%u\n",[d weekOfYear]); err++;}
  if ([e weekOfYear]!=52) {
    fprintf(stdout, "A48-%u\n",[e weekOfYear]); err++;}
  if ([f weekOfYear]!=52) {
    fprintf(stdout, "A49-%u\n",[f weekOfYear]); err++;}
  if ([g weekOfYear]!=1) {
    fprintf(stdout, "A50-%u\n",[g weekOfYear]); err++;}

  if ([c monthOfYear]!=1) {
    fprintf(stdout, "A51-%u\n",[c monthOfYear]); err++;}
  if ([d monthOfYear]!=2) {
    fprintf(stdout, "A52-%u\n",[d monthOfYear]); err++;}
  if ([e monthOfYear]!=12) {
    fprintf(stdout, "A53-%u\n",[e monthOfYear]); err++;}
  if ([f monthOfYear]!=12) {
    fprintf(stdout, "A54-%u\n",[f monthOfYear]); err++;}
  if ([g monthOfYear]!=1) {
    fprintf(stdout, "A55-%u\n",[g monthOfYear]); err++;}

  if ([c yearOfCommonEra]!=1) {
    fprintf(stdout, "A56-%u\n",[c yearOfCommonEra]); err++;}
  if ([d yearOfCommonEra]!=1) {
    fprintf(stdout, "A57-%u\n",[d yearOfCommonEra]); err++;}
  if ([e yearOfCommonEra]!=2000) {
    fprintf(stdout, "A58-%u\n",[e yearOfCommonEra]); err++;}
  if ([f yearOfCommonEra]!=2000) {
    fprintf(stdout, "A59-%u\n",[f yearOfCommonEra]); err++;}
  if ([g yearOfCommonEra]!=2001) {
    fprintf(stdout, "A60-%u\n",[g yearOfCommonEra]); err++;}

  if ([c isLeapYear]) {
    fprintf(stdout, "A61-%d\n",[c isLeapYear]); err++;}
  if ([d isLeapYear]) {
    fprintf(stdout, "A62-%d\n",[d isLeapYear]); err++;}
  if (![e isLeapYear]) {
    fprintf(stdout, "A63-%d\n",[e isLeapYear]); err++;}
  if (![f isLeapYear]) {
    fprintf(stdout, "A64-%d\n",[f isLeapYear]); err++;}
  if ([g isLeapYear]) {
    fprintf(stdout, "A65-%d\n",[g isLeapYear]); err++;}

  RELEASE(c);
  RELEASE(d);
  RELEASE(e);
  RELEASE(f);
  RELEASE(g);
  c= RETAIN(YMD(2013, 10, 25));
  if ([c dayOfWeek]!=4) {
    fprintf(stdout, "A70-%u\n",[c dayOfWeek]); err++;}
  if ([c weekOfYear]!=43) {
    fprintf(stdout, "A71-%u\n",[c weekOfYear]); err++;}
  RELEASE(c);
  return err;
  }

#define M1 10000
static inline int date_create2(void)
  {
  int err= 0,i;
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
    if (![MSDate verifyYear:[c[i] yearOfCommonEra] month:[c[i] monthOfYear] day:[c[i] dayOfMonth] hour:[c[i] hourOfDay] minute:[c[i] minuteOfHour] second:[c[i] secondOfMinute]]) {
      fprintf(stdout, "B1-%d-bad date ",i);
      date_print(c[i]);
      err++;}
    else {
      d= RETAIN(YMD([c[i] yearOfCommonEra], [c[i] monthOfYear], [c[i] dayOfMonth]));
      e= RETAIN([c[i] dateWithoutTime]);
      if (![d isEqualToDate:e]) {
        fprintf(stdout, "B2-%d-d & e are not equals %lld %lld %lld\n",i,[d secondsSinceLocalReferenceDate],[e secondsSinceLocalReferenceDate],[d secondsSinceLocalReferenceDate]-[e secondsSinceLocalReferenceDate]);
        date_print(c[i]);
        date_print(d);
        date_print(e);
        err++;}}
    RELEASE(d); RELEASE(e);}
    for (i= 0; i<M1; i++) {
        RELEASE(c[i]);
    }
  return err;
  }

#define M2 200000 // last date: 3834/01/27
static inline int date_week(void)
  {
  int err= 0,i; unsigned w;
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
    if ([d weekOfYear]!=w) {
      fprintf(stdout, "C1-%d-bad week %d expected %d ",i,[d weekOfYear],w); date_print(d);
      err++;}
    ASSIGN(d, [c dateByAddingHours:0 minutes:0 seconds:2*7*86400]);
    if (4 < [d dayOfYear] && [d dayOfYear] <= 11) w= 1;
    else w+= 1;
    ASSIGN(c, [c dateByAddingYears:0 months:0 days:7]);
    if ([c weekOfYear]!=w) {
      fprintf(stdout, "C2-%d-bad week %d expected %d ",i,[c weekOfYear],w); date_print(c);
      err++;}}
//date_print(c);
  RELEASE(c); RELEASE(d);
  return err;
  }

static inline int date_firstLast(void)
  {
  int err= 0;
  MSDate *d,*e,*f;

  d= [MSDate now];
  e= [d dateOfFirstDayOfYear];
  f= [[d dateWithoutTime] dateByAddingYears:0 months:0 days:-(int)[d dayOfYear]+1];
  if (![e isEqualToDate:f]) {
    fprintf(stdout, "D1-bad fisrt day of year\n");
    date_print(e); date_print(f); err++;}
  e= [d dateOfLastDayOfYear];
  f= [[d dateWithoutTime] dateByAddingYears:0 months:0 days:365+([d isLeapYear]?1:0)-(int)[d dayOfYear]];
  if (![e isEqualToDate:f]) {
    fprintf(stdout, "D2-bad last day of year\n");
    date_print(e); date_print(f); err++;}

  e= [d dateOfFirstDayOfMonth];
  f= [[d dateWithoutTime] dateByAddingYears:0 months:0 days:-(int)[d dayOfMonth]+1];
  if (![e isEqualToDate:f]) {
    fprintf(stdout, "D3-bad fisrt day of month\n");
    date_print(e); date_print(f); err++;}
  e= [d dateOfLastDayOfMonth];
  f= [[d dateWithoutTime] dateByAddingYears:0 months:0 days:(int)[d lastDayOfMonth]-(int)[d dayOfMonth]];
  if (![e isEqualToDate:f]) {
    fprintf(stdout, "D4-bad last day of month\n");
    date_print(e); date_print(f); err++;}

  e= [d dateOfFirstDayOfWeek];
  f= [[d dateWithoutTime] dateByAddingYears:0 months:0 days:-(int)[d dayOfWeek]];
  if (![e isEqualToDate:f]) {
    fprintf(stdout, "D5-bad fisrt day of week\n");
    date_print(e); date_print(f); err++;}
  e= [d dateOfLastDayOfWeek];
  f= [[d dateWithoutTime] dateByAddingYears:0 months:0 days:6-(int)[d dayOfWeek]];
  if (![e isEqualToDate:f]) {
    fprintf(stdout, "D6-bad last day of week\n");
    date_print(e); date_print(f); err++;}

  return err;
  }

static inline int date_replacing(void)
  {
  int err= 0;
  MSDate *d,*e,*f; unsigned j;

  d= YMDHMS(777, 7, 7, 7, 7, 7);
  e= [d dateByReplacingYear:0 month:0 day:1];
  f= [d dateByAddingYears:0 months:0 days:-6];
  if (![e isEqualToDate:f]) {
    fprintf(stdout, "E1-bad replacing\n");
    date_print(e); date_print(f); err++;}
  e= [d dateByReplacingYear:1 month:1 day:1];
  f= YMD(1, 1, 1);
  if (![[e dateWithoutTime] isEqualToDate:f]) {
    fprintf(stdout, "E2-bad replacing\n");
    date_print(e); date_print(f); err++;}
  e= [d dateByReplacingWeek:2];
  j= [d dayOfWeek];
  f= YMDHMS(777, 1, 1, 7, 7, 7);
  while ([f dayOfWeek]!=j || [f weekOfYear]!=2) {
    f= [f dateByAddingYears:0 months:0 days:1];}
  if (![e isEqualToDate:f]) {
    fprintf(stdout, "E3-bad replacing\n");
    date_print(e); date_print(f); err++;}
  e= [d dateByReplacingHour:2 minute:1 second:0];
  f= [d dateByAddingHours:-5 minutes:-6 seconds:-7];
  if (![e isEqualToDate:f]) {
    fprintf(stdout, "E4-bad replacing\n");
    date_print(e); date_print(f); err++;}
  return err;
  }

static inline int date_now(void)
  {
  int err= 0;
  MSDate *d1,*d2m; NSDate *d2; MSTimeInterval dt1m,dt2m; NSTimeInterval dt1n,dt2n;

  d1= [MSDate now];
  d2= [NSDate date];
  dt1m= [d1 secondsSinceLocalReferenceDate];
  dt2m= [d2 secondsSinceLocalReferenceDate];
  dt1n= [d1 timeIntervalSinceReferenceDate];
  dt2n= [d2 timeIntervalSinceReferenceDate];
  d2m= [MSDate dateWithSecondsSinceLocalReferenceDate:dt2m];
  if (ABS(dt1m-dt2m)>1) {
    fprintf(stdout, "F1-bad now\n");
    date_print(d1);
    date_print(d2m);
    err++;}
  if (ABS(dt1n-dt2n)>1) {
    fprintf(stdout, "F2-bad now %f %f %f %lld %lld %lld\n",dt1n,dt2n,dt1n-dt2n,dt1m,dt2m,dt1m-dt2m);
    NSLog(@"%@ %@ %@",d2,[d2 descriptionWithCalendarFormat:@"%Y/%m/%d-%H:%M:%S" timeZone:nil locale:nil],[NSCalendarDate calendarDate]);
    NSLog(@"%@ %@",[d1 descriptionRfc1123],[d1 descriptionWithCalendarFormat:@"%a, %d %b %Y %H:%M:%S"]);
    //NSLog(@"%@",[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    date_print(d1);
    date_print(d2m);
    err++;}
  return err;
  }

TEST_FCT_BEGIN(MSDate)
  int err= 0;
  err+= date_create();
  err+= date_create2();
  err+= date_week();
  err+= date_firstLast();
  err+= date_replacing();
  err+= date_now();
  return err;
TEST_FCT_END(MSDate)

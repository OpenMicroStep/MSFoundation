// mscore_cdate_validate.c, ecb, 130911

#include "mscore_validate.h"

static inline void cdate_print(CDate *d)
  {
  fprintf(stdout, "%u/%02u/%02u-%02u:%02u:%02d %lld\n",CDateYearOfCommonEra(d), CDateMonthOfYear(d), CDateDayOfMonth(d), CDateHourOfDay(d), CDateMinuteOfHour(d), CDateSecondOfMinute(d),d->interval);
  }

static int cdate_constants(void)
{
  int err= 0;
  if (!CDateDistantPast) {
    fprintf(stdout, "D1-No distantPast\n"); err++;}
  if (!CDateDistantFuture) {
    fprintf(stdout, "D2-No distantFuture\n"); err++;}
  if (!CDate19700101) {
    fprintf(stdout, "D3-No 19700101\n"); err++;}
  if (!CDate20010101) {
    fprintf(stdout, "D4-No 20010101\n"); err++;}
  return err;
}

static int cdate_create(void)
  {
  int err= 0;
  CDate *c,*d,*e,*f,*g;
  c= CCreateDateNow();
  d= CCreateDayDate(c);
  e= CCreateDateToday();
  if (RETAINCOUNT(c)!=1) {
    fprintf(stdout, "A1-Bad retain count: %lu\n",WLU(RETAINCOUNT(c))); err++;}
  if (RETAINCOUNT(d)!=1) {
    fprintf(stdout, "A2-Bad retain count: %lu\n",WLU(RETAINCOUNT(d))); err++;}
  if (RETAINCOUNT(e)!=1) {
    fprintf(stdout, "A3-Bad retain count: %lu\n",WLU(RETAINCOUNT(e))); err++;}
  if (CDateEquals(c, d)) {
    fprintf(stdout, "A4-c & d are equals\n");     err++;}
  if (!CDateEquals(d, e)) {
    fprintf(stdout, "A5-d & e are not equals\n"); err++;}
  RELEASE(c);
  RELEASE(d);
  RELEASE(e);
  if (CVerifyYMD(0,1,1)) {
    fprintf(stdout, "A10-1/1/0 is valid !\n");     err++;}
  if (CVerifyYMD(10,13,13)) {
    fprintf(stdout, "A11-13/13/10 is valid !\n");  err++;}
  if (CVerifyYMD(2001,2,29)) {
    fprintf(stdout, "A12-29/2/2001 is valid !\n"); err++;}
  c= CCreateDateWithYMD(1, 1, 1);
  d= CCreateDateWithYMD(1, 2, 28);
  f= CCreateDateWithYMDHMS(2000, 12, 31, 23,59,50);
  e= CCreateDayDate(f);
  g= (CDate*)MSCreateObjectWithClassIndex(CDateClassIndex);
//fprintf(stdout, "1/1/1-0:0 %lld %lld %lld\n",d->interval,d->interval/86400,(d->interval/730485)*730485);
  if (c->interval!=-63113904000LL) {
    fprintf(stdout, "A21-%lld\n",c->interval); err++;}
  if (d->interval!=-63113904000LL+(31LL+28LL-1LL)*86400LL) {
    fprintf(stdout, "A22-%lld\n",d->interval); err++;}
  if (e->interval!=-86400LL) {
    fprintf(stdout, "A23-%lld\n",e->interval); err++;}
  if (f->interval!=-10LL) {
    fprintf(stdout, "A24-%lld\n",f->interval); err++;}
  if (g->interval!=0LL) {
    fprintf(stdout, "A25-%lld\n",g->interval); err++;}

  if (CDateDayOfWeek(c)!=0) {
    fprintf(stdout, "A26-%u\n",CDateDayOfWeek(c)); err++;}
  if (CDateDayOfWeek(d)!=2) {
    fprintf(stdout, "A27-%u\n",CDateDayOfWeek(d)); err++;}
  if (CDateDayOfWeek(e)!=6) {
    fprintf(stdout, "A28-%u\n",CDateDayOfWeek(e)); err++;}
  if (CDateDayOfWeek(f)!=6) {
    fprintf(stdout, "A29-%u\n",CDateDayOfWeek(f)); err++;}
  if (CDateDayOfWeek(g)!=0) {
    fprintf(stdout, "A30-%u\n",CDateDayOfWeek(g)); err++;}

  if (CDateDayOfMonth(c)!=1) {
    fprintf(stdout, "A31-%u\n",CDateDayOfMonth(c)); err++;}
  if (CDateDayOfMonth(d)!=28) {
    fprintf(stdout, "A32-%u\n",CDateDayOfMonth(d)); err++;}
  if (CDateDayOfMonth(e)!=31) {
    fprintf(stdout, "A33-%u\n",CDateDayOfMonth(e)); err++;}
  if (CDateDayOfMonth(f)!=31) {
    fprintf(stdout, "A34-%u\n",CDateDayOfMonth(f)); err++;}
  if (CDateDayOfMonth(g)!=1) {
    fprintf(stdout, "A35-%u\n",CDateDayOfMonth(g)); err++;}

  if (CDateDayOfYear(c)!=1) {
    fprintf(stdout, "A36-%u\n",CDateDayOfYear(c)); err++;}
  if (CDateDayOfYear(d)!=31+28) {
    fprintf(stdout, "A37-%u\n",CDateDayOfYear(d)); err++;}
  if (CDateDayOfYear(e)!=366) {
    fprintf(stdout, "A38-%u\n",CDateDayOfYear(e)); err++;}
  if (CDateDayOfYear(f)!=366) {
    fprintf(stdout, "A39-%u\n",CDateDayOfYear(f)); err++;}
  if (CDateDayOfYear(g)!=1) {
    fprintf(stdout, "A40-%u\n",CDateDayOfYear(g)); err++;}

  if (CDateDayOfCommonEra(c)!=1) {
    fprintf(stdout, "A41-%u\n",CDateDayOfCommonEra(c)); err++;}
  if (CDateDayOfCommonEra(d)!=31+28) {
    fprintf(stdout, "A42-%u\n",CDateDayOfCommonEra(d)); err++;}
  if ((int)CDateDayOfCommonEra(e)!=CDateDaysBetweenDates(c,e,NO)+1) {
    fprintf(stdout, "A43-%u %d\n",CDateDayOfCommonEra(e),CDateDaysBetweenDates(c,e,NO));
    err++;}
  if ((int)CDateDayOfCommonEra(f)!=CDateDaysBetweenDates(c,f,NO)+1) {
    fprintf(stdout, "A44-%u %d\n",CDateDayOfCommonEra(f),CDateDaysBetweenDates(c,f,NO));
    err++;}
  if ((int)CDateDayOfCommonEra(g)!=CDateDaysBetweenDates(c,g,NO)+1) {
    fprintf(stdout, "A45-%u %d\n",CDateDayOfCommonEra(g),CDateDaysBetweenDates(c,g,NO));
    err++;}

  if (CDateWeekOfYear(c)!=1) {
    fprintf(stdout, "A46-%u\n",CDateWeekOfYear(c)); err++;}
  if (CDateWeekOfYear(d)!=9) {
    fprintf(stdout, "A47-%u\n",CDateWeekOfYear(d)); err++;}
  if (CDateWeekOfYear(e)!=52) {
    fprintf(stdout, "A48-%u\n",CDateWeekOfYear(e)); err++;}
  if (CDateWeekOfYear(f)!=52) {
    fprintf(stdout, "A49-%u\n",CDateWeekOfYear(f)); err++;}
  if (CDateWeekOfYear(g)!=1) {
    fprintf(stdout, "A50-%u\n",CDateWeekOfYear(g)); err++;}

  if (CDateMonthOfYear(c)!=1) {
    fprintf(stdout, "A51-%u\n",CDateMonthOfYear(c)); err++;}
  if (CDateMonthOfYear(d)!=2) {
    fprintf(stdout, "A52-%u\n",CDateMonthOfYear(d)); err++;}
  if (CDateMonthOfYear(e)!=12) {
    fprintf(stdout, "A53-%u\n",CDateMonthOfYear(e)); err++;}
  if (CDateMonthOfYear(f)!=12) {
    fprintf(stdout, "A54-%u\n",CDateMonthOfYear(f)); err++;}
  if (CDateMonthOfYear(g)!=1) {
    fprintf(stdout, "A55-%u\n",CDateMonthOfYear(g)); err++;}

  if (CDateYearOfCommonEra(c)!=1) {
    fprintf(stdout, "A56-%u\n",CDateYearOfCommonEra(c)); err++;}
  if (CDateYearOfCommonEra(d)!=1) {
    fprintf(stdout, "A57-%u\n",CDateYearOfCommonEra(d)); err++;}
  if (CDateYearOfCommonEra(e)!=2000) {
    fprintf(stdout, "A58-%u\n",CDateYearOfCommonEra(e)); err++;}
  if (CDateYearOfCommonEra(f)!=2000) {
    fprintf(stdout, "A59-%u\n",CDateYearOfCommonEra(f)); err++;}
  if (CDateYearOfCommonEra(g)!=2001) {
    fprintf(stdout, "A60-%u\n",CDateYearOfCommonEra(g)); err++;}

  if (CDateIsLeapYear(c)) {
    fprintf(stdout, "A61-%d\n",CDateIsLeapYear(c)); err++;}
  if (CDateIsLeapYear(d)) {
    fprintf(stdout, "A62-%d\n",CDateIsLeapYear(d)); err++;}
  if (!CDateIsLeapYear(e)) {
    fprintf(stdout, "A63-%d\n",CDateIsLeapYear(e)); err++;}
  if (!CDateIsLeapYear(f)) {
    fprintf(stdout, "A64-%d\n",CDateIsLeapYear(f)); err++;}
  if (CDateIsLeapYear(g)) {
    fprintf(stdout, "A65-%d\n",CDateIsLeapYear(g)); err++;}

  RELEASE(c);
  RELEASE(d);
  RELEASE(e);
  RELEASE(f);
  RELEASE(g);
  c= CCreateDateWithYMD(2013, 10, 25);
  if (CDateDayOfWeek(c)!=4) {
    fprintf(stdout, "A70-%u\n",CDateDayOfWeek (c)); err++;}
  if (CDateWeekOfYear(c)!=43) {
    fprintf(stdout, "A71-%u\n",CDateWeekOfYear(c)); err++;}
  RELEASE(c);
  return err;
  }

#define M1 10000
static int cdate_create2(void)
  {
  int err= 0,i;
  MSTimeInterval t;
  CDate *c[M1],*d,*e; // last date: 3432/07/11-02:51:40
  
  for (t= -63113904000LL, i= 0; i<M1; i++) { //-63113904000LL
    c[i]= (CDate*)MSCreateObjectWithClassIndex(CDateClassIndex);
    t= t +
       ((i % 3600LL) / 60LL)*86400LL +
       (i % 60LL)*3600LL +
       i +
       i*(i/4);
    c[i]->interval= t;}
//cdate_print(c[M1-1]);
  for (i= 0; i<M1; i++) {
    if (!CVerifyYMD(CDateYearOfCommonEra(c[i]), CDateMonthOfYear(c[i]), CDateDayOfMonth(c[i]))) {
      fprintf(stdout, "B1-%d-bad date ",i);
      cdate_print(c[i]);
      err++;}
    else {
      d= CCreateDateWithYMD(CDateYearOfCommonEra(c[i]), CDateMonthOfYear(c[i]), CDateDayOfMonth(c[i]));
      e= CCreateDayDate(c[i]);
      if (!CDateEquals(d, e)) {
        fprintf(stdout, "B2-%d-d & e are not equals %lld %lld %lld\n",i,d->interval,e->interval,d->interval-e->interval);
        cdate_print(c[i]);
        cdate_print(d);
        cdate_print(e);
        err++;}
      RELEASE(d); RELEASE(e);}}
  for (i= 0; i<M1; i++) {
    RELEASE(c[i]);
  }
  return err;
  }

#define M2 200000 // last date: 3834/01/27
static int cdate_week(void)
  {
  int err= 0,i; unsigned w;
  MSTimeInterval t;
  CDate *c,*d;
  
  c= CCreateDateWithYMD(1, 1, 1);
  d= CCreateDateWithYMD(1, 1, 1);
  while (CDateDayOfWeek(c)!=0) {c->interval+= 86400LL; d->interval+= 86400LL;}
  w= CDateDayOfMonth(c)<=4 ? 1 : 2;
  for (t= c->interval, i= 0; i<M2; i++) {
    d->interval= c->interval+7LL*86400LL-1LL;
    if (CDateWeekOfYear(d)!=w) {
      fprintf(stdout, "C1-%d-bad week %d expected %d ",i,CDateWeekOfYear(d),w); cdate_print(d);
      err++;}
    d->interval= c->interval+2LL*(7LL*86400LL);
    if (4 < CDateDayOfYear(d) && CDateDayOfYear(d) <= 11) w= 1;
    else w+= 1;
    c->interval+= 7LL*86400LL;
    if (CDateWeekOfYear(c)!=w) {
      fprintf(stdout, "C2-%d-bad week %d expected %d ",i,CDateWeekOfYear(c),w); cdate_print(c);
      err++;}}
//cdate_print(c);
  RELEASE(c); RELEASE(d);
  return err;
  }

int mscore_cdate_validate(void)
  {
  int err= 0;
  err+= cdate_constants();
  err+= cdate_create();
  err+= cdate_create2();
  err+= cdate_week();
  return err;
  }

test_t mscore_cdate[]= {
  {"constants",NULL,cdate_constants,INTITIALIZE_TEST_T_END},
  {"create"   ,NULL,cdate_create   ,INTITIALIZE_TEST_T_END},
  {"create2"  ,NULL,cdate_create2  ,INTITIALIZE_TEST_T_END},
  {"week"     ,NULL,cdate_week     ,INTITIALIZE_TEST_T_END},
  {NULL}
};

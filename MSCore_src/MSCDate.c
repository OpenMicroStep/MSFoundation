/* MSCDate.c
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
 
 
 This software is a computer program whose purpose is to [describe
 functionalities and technical features of your software].
 
 This software is governed by the CeCILL-C license under French law and
 abiding by the rules of distribution of free software.  You can  use,
 modify and/ or redistribute the software under the terms of the CeCILL-C
 license as circulated by CEA, CNRS and INRIA at the following URL
 "http://www.cecill.info".
 
 As a counterpart to the access to the source code and  rights to copy,
 modify and redistribute granted by the license, users are provided only
 with a limited warranty  and the software's author,  the holder of the
 economic rights,  and the successive licensors  have only  limited
 liability.
 
 In this respect, the user's attention is drawn to the risks associated
 with loading,  using,  modifying and/or developing or reproducing the
 software by the user in light of its specific status of free software,
 that may mean  that it is complicated to manipulate,  and  that  also
 therefore means  that it is reserved for developers  and  experienced
 professionals having in-depth computer knowledge. Users are therefore
 encouraged to load and test the software's suitability as regards their
 requirements in conditions enabling the security of their systems and/or
 data to be ensured and,  more generally, to use and operate it in the
 same conditions as regards security.
 
 The fact that you are presently reading this means that you have had
 knowledge of the CeCILL-C license and that you accept its terms.
 
 */

#include "MSCore_Private.h"

#pragma mark initialize

CDate *CDateDistantPast;
CDate *CDateDistantFuture;
CDate *CDate19700101;
CDate *CDate20010101;
MSTimeInterval CDateSecondsFrom19700101To20010101;

void _CDateInitialize(void); // used in MSSystemInitialize
void _CDateInitialize()
{
  CDateDistantPast= (CDate*)MSCreateObjectWithClassIndex(CDateClassIndex);
  CDateDistantPast->interval= MSLongMin;
  CDateDistantFuture= (CDate*)MSCreateObjectWithClassIndex(CDateClassIndex);
  CDateDistantFuture->interval= MSLongMax;
  CDate19700101= CCreateDateWithYMD(1970, 1, 1);
  CDate20010101= (CDate*)MSCreateObjectWithClassIndex(CDateClassIndex);
  CDateSecondsFrom19700101To20010101= CDateSecondsBetweenDates(CDate19700101, CDate20010101);
//printf("CDateSecondsFrom19700101To20010101 %lld",CDateSecondsFrom19700101To20010101);
}

#pragma mark date function declarations

static BOOL _verifyYMD(unsigned year, unsigned month, unsigned day,
  BOOL canRaise);
static BOOL _verifyHMS(unsigned hour, unsigned minute, unsigned second,
  BOOL canRaise);

#define DaysFrom00000229To20010101 730792LL
#define DaysFrom00010101To20010101 730485
#define SecsFrom00010101To20010101 63113904000LL

static inline BOOL _isLeap(unsigned y)
  {
  return (y % 4)==0 && ((y % 100)!=0 || (y % 400)==0);
  }
static unsigned __daysInMonth[13]= {
  0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
static MSTimeInterval __daysInPreviousMonths[15]= {
  0, 0, 0, 0, 31, 61, 92, 122, 153, 184, 214, 245, 275, 306, 337 };

// not protected : use carefully
static inline unsigned _lastDayOfMonth(unsigned year, unsigned month)
{
  return (month == 2 && _isLeap(year)) ? 29 : __daysInMonth[month];
}

#pragma mark _dtm declarations

typedef struct _dtmStruct {
#ifdef __BIG_ENDIAN__
  unsigned long long year:32;
  unsigned long long month:4;
  unsigned long long day:5;
  unsigned long long hour:5;
  unsigned long long minute:6;
  unsigned long long second:6;
  unsigned long long dayOfWeek:3;
  unsigned long long _pad:3;
#else
  unsigned long long _pad:3;
  unsigned long long dayOfWeek:3;
  unsigned long long second:6;
  unsigned long long minute:6;
  unsigned long long hour:5;
  unsigned long long day:5;
  unsigned long long month:4;
  unsigned long long year:32;
#endif
  }
_dtm;

static _dtm _dtmCast(MSTimeInterval ref);

#pragma mark _tm declarations

// Algorithm used is a modification of Rata Die algorithm described by Peter
// Baum on is web site. More information at http://vsg.cape.com/~pbaum
static inline MSTimeInterval _tmFromYMD(
  unsigned year, unsigned month, unsigned day)
{
  int y; MSTimeInterval leaps; double x;
  y= (int)year;
  if (month < 3) {month += 12; y--;}
  if (y>=0) leaps= y/4-y/100+y/400;
  else {x= y; leaps= (MSTimeInterval)(floor(x/4.)-floor(x/100.)+floor(x/400.));}
  return ( (MSTimeInterval)day
         + __daysInPreviousMonths[month]
         + 365LL*y
         + leaps
         - DaysFrom00000229To20010101
         )
         * ((MSTimeInterval)86400);
}

static inline MSTimeInterval _tmFromYMDHMS(
  unsigned year, unsigned month , unsigned day,
  unsigned hour, unsigned minute, unsigned seconds)
{
  return _tmFromYMD(year, month, day)
    + ((MSTimeInterval)3600) * ((MSTimeInterval)hour  )
    + ((MSTimeInterval)60  ) * ((MSTimeInterval)minute)
    +                           (MSTimeInterval)seconds;
}

static inline MSTimeInterval _tmFromDtm(_dtm d)
{ return _tmFromYMDHMS(d.year,d.month,d.day, d.hour,d.minute,d.second); }

static inline unsigned _tmSecond(MSTimeInterval t)
{ return (unsigned)( (t+SecsFrom00010101To20010101) %    60LL); }
static inline unsigned _tmMinute(MSTimeInterval t)
{ return (unsigned)(((t+SecsFrom00010101To20010101) %  3600LL)/  60LL); }
static inline unsigned _tmHour  (MSTimeInterval t)
{ return (unsigned)(((t+SecsFrom00010101To20010101) % 86400LL)/3600LL); }
static inline MSTimeInterval _tmTime(MSTimeInterval t)
{ return (t+SecsFrom00010101To20010101) % 86400LL; }
static inline MSTimeInterval _tmWithoutTime(MSTimeInterval t)
{ return t - _tmTime(t); }
static inline MSTimeInterval _tmDay(MSTimeInterval t)
{ return (t - _tmTime(t))/86400LL; }

#pragma mark Error declarations

#define MSInvalidYearError  -1
#define MSInvalidMonthError -2
#define MSInvalidWeekError  -3
#define MSInvalidDayError   -4
#define MSInvalidTimeError  -5

#pragma mark c-like class methods

void CDateFreeInside(id self)
{
  if (self) {}
}
void CDateFree(id self)
{
  CDateFreeInside(self);
  MSFree(self, "CDateFree() [self]");
}

BOOL CDateIsEqual(id self, id other)
{
  return _CClassIsEqual(self,other,(CObjectEq)CDateEquals);
}

NSUInteger CDateHash(id self, unsigned depth)
{
  return self ? (NSUInteger)((((CDate*)self)->interval) & 0xffffffff) : 0;
  MSUnused(depth);
}

id CDateCopy(id self)
{
  CDate *newDate;
  if (!self) return nil;
  newDate= (CDate*)MSCreateObjectWithClassIndex(CDateClassIndex);
  if (newDate) {
    newDate->interval= ((CDate*)self)->interval;}
  return (id)newDate;
}

#pragma mark Equality

BOOL CDateEquals(const CDate *self, const CDate *other)
{
  if (self == other) return YES;
  if (self && other) {
    return  self->interval == other->interval;}
  return NO;
}

#pragma mark Creation

BOOL CVerifyYMD(unsigned year, unsigned month, unsigned day)
{
  return _verifyYMD(year, month, day, NO);
}
BOOL CVerifyHMS(unsigned hour, unsigned minute, unsigned second)
{
  return _verifyHMS(hour, minute, second, NO);
}

CDate *CCreateDateWithYMD(unsigned year, unsigned month, unsigned day)
{
  CDate *d;
  (void)_verifyYMD(year, month, day, YES);
  d= (CDate*)MSCreateObjectWithClassIndex(CDateClassIndex);
  d->interval= _tmFromYMD(year, month, day);
  return d;
}
CDate *CCreateDateWithYMDHMS(unsigned year, unsigned month, unsigned day,
  unsigned hour, unsigned minute, unsigned second)
{
  CDate *d;
  (void)_verifyYMD(year, month, day, YES);
  (void)_verifyHMS(hour, minute, second, YES);
  d= (CDate*)MSCreateObjectWithClassIndex(CDateClassIndex);
  d->interval= _tmFromYMDHMS(year, month, day, hour, minute, second);
  return d;
}

CDate *CCreateDateWithSecondsFrom20010101(MSTimeInterval s)
{
  CDate *d;
  d= (CDate*)MSCreateObjectWithClassIndex(CDateClassIndex);
  d->interval= s;
  return d;
}


#ifdef WIN32
// this **!@** structure count by 100 nanoseconds steps since 1st january 1601
#define _MSTimeIntervalSince1601 12622780800ull

static inline void FileTimeToMSTimeInterval(FILETIME ft, MSTimeInterval *t)
{
  MSULong d;
  d = (((MSULong) ft.dwHighDateTime) << 32) + ft.dwLowDateTime;
  d /= 10000000;
  *t = (MSTimeInterval)(d) - _MSTimeIntervalSince1601;
}

static inline void MSTimeIntervalToFileTime(MSTimeInterval t, FILETIME * ft)
{
  MSULong d;
  d = t + _MSTimeIntervalSince1601;
  d *= 10000000;
  ft->dwLowDateTime  = (MSUInt) (d & 0xFFFFFFFF );
  ft->dwHighDateTime = (MSUInt) (d >> 32 );
}
#endif

#ifdef WO451 
// Apple System headers doesn't provide this method because it was introduced in WinXP/WinServer2003
// Linking with Apple won't work either, one workaround is to link with a newer version of libKernel32.a
// A version compatible with the old wo451 linker can be found in the MinGW package.
// The name of the lib for linker can't be Kernel32 due to linker not looking at libKernel32.a with such name.
BOOL WINAPI TzSpecificLocalTimeToSystemTime(void* lpTimeZoneInformation,void* lpLocalTime,void* lpUniversalTime);
#endif

static MSTimeInterval _GMTNow(void)
{
  MSTimeInterval t;
#ifdef WIN32
  FILETIME fts;
  GetSystemTimeAsFileTime(&fts);
  FileTimeToMSTimeInterval(fts, &t);
#else
  time_t timet= time(NULL);
  t= (MSTimeInterval)timet - CDateSecondsFrom19700101To20010101;
#endif
  return t;
}
static MSTimeInterval _GMTToLocal(MSTimeInterval tIn)
{
  MSTimeInterval tOut;
#ifdef WIN32
  FILETIME fts, ftl;
  SYSTEMTIME sts, stl;
  MSTimeIntervalToFileTime(tIn, &fts);
  if (FileTimeToSystemTime(&fts, &sts) && // According to MSDN, this is a necessary conversion to take daylight into account
      SystemTimeToTzSpecificLocalTime(NULL /* uses the currently active time zone */, &sts, &stl) &&
      SystemTimeToFileTime(&stl, &ftl))
    FileTimeToMSTimeInterval(ftl, &tOut);
  else tOut = tIn;
#else
  struct tm tm;
  time_t timet= tIn + CDateSecondsFrom19700101To20010101;
  (void)localtime_r(&timet, &tm);
  tOut= (MSTimeInterval)timet - CDateSecondsFrom19700101To20010101 + (MSTimeInterval)(tm.tm_gmtoff);
//printf("%ld %lld %lld %lld %lld\n",tm.tm_gmtoff,t,rt,GMTFromLocal(rt),t-rt);
#endif
  return tOut;
}

NSTimeInterval GMTNow(void)
{
  return (NSTimeInterval)_GMTNow();
}
NSTimeInterval GMTFromLocal(MSTimeInterval t)
{
#ifdef WIN32
  FILETIME fts, ftl;
  SYSTEMTIME sts, stl;
  MSTimeIntervalToFileTime(t, &ftl);
  if (FileTimeToSystemTime(&ftl, &stl) && // According to MSDN, this is a necessary conversion to take daylight into account
      TzSpecificLocalTimeToSystemTime(NULL /* uses the currently active time zone */, &stl, &sts) &&
      SystemTimeToFileTime(&sts, &fts))
    FileTimeToMSTimeInterval(fts, &t);
#else
  _dtm dtm= _dtmCast(t);
  struct tm tm= {dtm.second,dtm.minute,dtm.hour,
                 dtm.day,dtm.month-1,(int)(dtm.year-1900),0,0,-1,0,NULL};
  time_t timet= mktime(&tm);
  t= (MSTimeInterval)timet-CDateSecondsFrom19700101To20010101;
#endif
  return (NSTimeInterval)t;
}

NSTimeInterval GMTWithYMDHMS(
  unsigned year, unsigned month,  unsigned day,
  unsigned hour, unsigned minute, unsigned second)
{
  return (NSTimeInterval)_tmFromYMDHMS(year, month, day, hour, minute, second);
}

MSTimeInterval GMTToLocal(NSTimeInterval t)
{
  return _GMTToLocal((MSTimeInterval)(t>=0 ? t+.5 :  t-.5));
}
static MSTimeInterval _CDateSecondsOfNow(void)
// NO needs to be public
{
  return _GMTToLocal(_GMTNow());
}

CDate *CCreateDateNow()
{
  CDate *d;
  d= (CDate*)MSCreateObjectWithClassIndex(CDateClassIndex);
  d->interval= _CDateSecondsOfNow();
  return d;
}

CDate *CCreateDateToday()
{
  CDate *d;
  d= CCreateDateNow();
  if (d) d->interval= _tmWithoutTime(d->interval);
  return d;
}

CDate *CCreateDayDate(CDate *self)
{
  CDate *d;
  d= (CDate*)CDateCopy((id)self);
  if (d) d->interval= _tmWithoutTime(d->interval);
  return d;
}

#pragma mark Informations

static inline unsigned _tmDayOfWeek(MSTimeInterval t, unsigned offset)
{
  return ((unsigned)_tmDay(t)+DaysFrom00010101To20010101 + 7-(offset % 7)) % 7;
}

// In order to follow ISO 8601 week begins on monday and must have at
// least 4 days (i.e. it must includes thursday)
static inline MSTimeInterval _yearRef(unsigned y, unsigned offset)
{
  MSTimeInterval firstDayOfYear,d;
  firstDayOfYear= _tmFromYMD(y, 1, 1);
  d= (MSTimeInterval)_tmDayOfWeek(firstDayOfYear, offset);
  d= (d<=3?-d:7-d); // Day of the first week
  return firstDayOfYear + d*86400LL;
}
static inline unsigned _tmWeekOfYear(MSTimeInterval t, unsigned offset)
{
  MSTimeInterval reference; unsigned w;
  _dtm dt= _dtmCast(t);
  offset %= 7;
  
  reference= _yearRef(dt.year, offset);
  if (t < reference) { // De l'année d'avant
    reference= _yearRef(dt.year-1, offset);
    w= (unsigned)((t - reference) / (86400LL*7LL)) + 1;}
  else {
    w= (unsigned)((t - reference) / (86400LL*7LL)) + 1;
    if (w==53) {
      reference+= 52LL*7LL*86400LL;
      if (_dtmCast(reference).day>=29) w= 1;}} // De l'année d'après
  return w;
}

unsigned CDateDayOfWeek(CDate *self)
{return !self ? 0 : _tmDayOfWeek (self->interval, 0);}
unsigned CDateWeekOfYear(CDate *self)
{return !self ? 0 : _tmWeekOfYear(self->interval, 0);}
//unsigned CDateDayOfWeekWithOffset(CDate *self, unsigned offset)
//{return !self ? 0 : _tmDayOfWeek (self->interval, offset);}
//unsigned CDateWeekOfYearWithOffset(CDate *self, unsigned offset)
//{return !self ? 0 : _tmWeekOfYear(self->interval, offset);}

unsigned CDateDayOfMonth(CDate *self)
{return !self ? 0 : _dtmCast(self->interval).day;}

unsigned CDateLastDayOfMonth (CDate *self)
{
  _dtm dt;
  if (!self) return 0;
  dt= _dtmCast(self->interval);
  return _lastDayOfMonth(dt.year, dt.month);
}

unsigned CDateDayOfYear(CDate *self)
{
  _dtm dt;
  MSTimeInterval firstDayOfYearReference;
  if (!self) return 0;
  dt= _dtmCast(self->interval);
  firstDayOfYearReference=  _tmFromYMD(dt.year, 1, 1);
  return (unsigned)((self->interval - firstDayOfYearReference)/86400LL) + 1;
}

unsigned CDateDayOfCommonEra(CDate *self)
{
  return !self ? 0 :
    (unsigned)((self->interval + SecsFrom00010101To20010101)/86400LL) + 1;
}

unsigned CDateMonthOfYear(CDate *self)
{return !self ? 0 : _dtmCast(self->interval).month;}

unsigned CDateYearOfCommonEra(CDate *self)
{return !self ? 0 : _dtmCast(self->interval).year;}

BOOL CDateIsLeapYear(CDate *self)
{return !self ? 0 : _isLeap(_dtmCast(self->interval).year);}

unsigned CDateHourOfDay(CDate *self)
{ return !self ? 0 : _tmHour  (self->interval);}
unsigned CDateMinuteOfHour(CDate *self)
{ return !self ? 0 : _tmMinute(self->interval);}
unsigned CDateSecondOfMinute(CDate *self)
{ return !self ? 0 : _tmSecond(self->interval);}
unsigned CDateSecondOfDay(CDate *self)
{ return !self ? 0 : (unsigned)_tmTime(self->interval);}

int CDateYearsBetweenDates(CDate *first, CDate *last, BOOL usesTime)
{
  return CDateMonthsBetweenDates(first, last, usesTime) / 12;
}

int CDateMonthsBetweenDates(CDate *first, CDate *last, BOOL usesTime)
{
  CDate *x; _dtm dta, dtb;
  int sgn,ret;
  if ((sgn= first->interval < last ->interval ? 1 : -1) == -1) {
    x= last; last= first; first= x;}
  dta= _dtmCast(first->interval);
  dtb= _dtmCast(last ->interval);
  
  ret= ((int)dtb.year - (int)dta.year) * 12 + ((int)dtb.month - (int)dta.month);
  if (dtb.day < dta.day) ret--;
  else if (usesTime && dtb.day == dta.day) {
    if (_tmTime(last->interval) < _tmTime(first->interval)) ret--;}
  return sgn * ret;
}

int CDateDaysBetweenDates(CDate *first, CDate *last, BOOL usesTime)
{
  CDate *x; MSTimeInterval ta,tb;
  int sgn;
  if ((sgn= first->interval < last ->interval ? 1 : -1) == -1) {
    x= last; last= first; first= x;}
  ta= first->interval; tb= last->interval;
  if (!usesTime) {ta= _tmWithoutTime(ta); tb= _tmWithoutTime(tb);}
  return sgn*(int)((tb - ta)/86400LL);
}

MSTimeInterval CDateSecondsBetweenDates(CDate *first, CDate *last)
{
  return last->interval - first->interval;
}

#pragma mark Setters

static MSTimeInterval _tmFromYMDAddingYearsAndMonths(CDate *date, int years, int months)
{
  _dtm dt; int newYear, newMonth; unsigned lastDayOfMonth;

  if (!years && !months) return date->interval;

  dt= _dtmCast(date->interval);
  // normelizing month & years
  years+= months / 12;
  months= (months < 0 ? -((-months) % 12) : months % 12);
  newYear=  (int)dt.year  + years;
  newMonth= (int)dt.month + months;
  
  if      (newMonth > 12) { newMonth -= 12; newYear++; }
  else if (newMonth < 1 ) { newMonth += 12; newYear--; }

  if (newYear < 1) {
    MSReportError(MSMiscalculationError, MSFatalError, MSInvalidYearError,
      "Underflow error during date calculation, years cannot be nul neither negative");
    dt.year= dt.month= 1;}
  else {
    dt.year=  (unsigned)newYear;
    dt.month= (unsigned)newMonth;
    if (dt.day > (lastDayOfMonth= _lastDayOfMonth(dt.year, dt.month))) {
      dt.day= lastDayOfMonth;}}
  
  return _tmFromDtm(dt);
}

void CDateAddYMD(CDate *self, int years, int months, int days)
{
  if (self) self->interval=
    _tmFromYMDAddingYearsAndMonths(self, years, months) +
    ((MSTimeInterval)days)*86400LL;
}

void CDateAddYMDHMS(CDate *self, int years, int months , int days,
                                 int hours, int minutes, int seconds)
{
  if (self) self->interval=
    _tmFromYMDAddingYearsAndMonths(self, years, months) +
    ((MSTimeInterval)days   )*86400LL +
    ((MSTimeInterval)hours  )* 3600LL +
    ((MSTimeInterval)minutes)*   60LL +
    ((MSTimeInterval)seconds);
}

void CDateSetYMDHMS(CDate *self, unsigned year, unsigned month , unsigned day,
                                 unsigned hour, unsigned minute, unsigned sec)
{
  (void)_verifyYMD(year, month, day, YES);
  (void)_verifyHMS(hour, minute, sec, YES);
  self->interval= _tmFromYMDHMS(year, month, day, hour, minute, sec);
}

void CDateSetYear(CDate *self, unsigned year)
{
  if (self) {
    int y= (int)CDateYearOfCommonEra(self);
    if ((int)year != y) {
      self->interval= _tmFromYMDAddingYearsAndMonths(self, (int)year-y, 0);}}
}

void CDateSetMonth(CDate *self, unsigned month)
{
  if (self) {
    if (month > 0 && month < 13) {
      int m= (int)CDateMonthOfYear(self);
      if ((int)month != m) {
        self->interval= _tmFromYMDAddingYearsAndMonths(self,0,(int)month-m);}}
    else MSReportError(MSRangeError, MSFatalError, MSInvalidMonthError,
      "Impossible to set month to %u", month);}
}

void CDateSetWeek(CDate *self, unsigned week)
{
  BOOL err= YES;
  if (self) {
    if (0 < week && week < 54) {
      int w= (int)CDateWeekOfYear(self);
      if ((int)week == w) err= NO;
      else {
        self->interval+= ((int)week-w)*7LL*86400LL;
        // An eror may occur on week 53 if this year it not exists.
        if (week == CDateWeekOfYear(self)) err= NO;}}}
  if (err) MSReportError(MSRangeError, MSFatalError, MSInvalidWeekError,
    "Impossible to set week to %u", week);
}

void CDateSetDay(CDate *self, unsigned day)
{
  if (self) {
    _dtm dt= _dtmCast(self->interval);
    if (0 < day && day <= _lastDayOfMonth(dt.year, dt.month)) {
      dt.day= day;
      self->interval= _tmFromDtm(dt);}
    else MSReportError(MSRangeError, MSFatalError, MSInvalidDayError,
      "Impossible to set day of month to %u (last: %u)",
      day, _lastDayOfMonth(dt.year, dt.month));}
}

void CDateSetDayOfYear(CDate *self, unsigned doy)
{
  if (self) {
    unsigned y= CDateYearOfCommonEra(self);
    if (doy > 0 && (doy < 366 || (doy == 367 && _isLeap(y)))) {
      self->interval= _tmFromYMD(y,1,1) +
                      ((MSTimeInterval)(doy-1))*86400LL +
                      _tmTime(self->interval);}
    else MSReportError(MSRangeError, MSFatalError, MSInvalidDayError,
      "Impossible to set day of year %u to %u",y, doy);}
}

#pragma mark date functions

static BOOL _verifyYMD(unsigned year, unsigned month, unsigned day, BOOL canRaise)
{
  if (year == 0) {
    if (canRaise) MSReportError(MSRangeError, MSFatalError, MSInvalidMonthError,
      "Year %u is not valid", year);
    return NO;}
  if (month == 0 || month > 12) {
    if (canRaise) MSReportError(MSRangeError, MSFatalError, MSInvalidMonthError,
      "Month %u is not valid", month);
    return NO;}
  if (day == 0 || day > _lastDayOfMonth(year, month)) {
    if (canRaise) MSReportError(MSRangeError, MSFatalError, MSInvalidDayError,
      "Day %u is not a valid one", day);
    return NO;}
  return YES;
}

static inline BOOL _verifyHMS(unsigned hour, unsigned minute, unsigned second, BOOL canRaise)
{
  if (hour > 23 || minute > 59 || second > 59) {
    if (canRaise) MSReportError(MSRangeError, MSFatalError, MSInvalidTimeError,
      "Time %u:%u:%u is not valid", hour, minute, second);
    return NO;}
  return YES;
}

#pragma mark _dtm functions

// Inverse algorithm in order to get back our date information from our
// reference time
static _dtm _dtmCast(MSTimeInterval t)
{
  _dtm dt;
  int Z,CENTURY,CENTURY_MQUART,Y,Y365,DAYS_IN_Y,MONTH_IN_Y;
  double gg,ALLDAYS;

  Z=              (int)(_tmDay(t)+DaysFrom00000229To20010101);
  gg=             (double)Z-.25;
  CENTURY=        (int)floor(gg/36524.25);
  CENTURY_MQUART= CENTURY - (int)floor((double)CENTURY/4.);
  ALLDAYS=        (double)CENTURY_MQUART + gg;
  Y=              (int)floor(ALLDAYS / 365.25);
  Y365=           (int)floor(Y * 365.25);
  DAYS_IN_Y=      CENTURY_MQUART + Z - Y365;
  MONTH_IN_Y=     (5 * DAYS_IN_Y + 456) / 153;

  dt.day= (unsigned)(DAYS_IN_Y - ((153*MONTH_IN_Y - 457) / 5));
  if (MONTH_IN_Y > 12) {
    dt.month= (unsigned)MONTH_IN_Y - 12;
    dt.year=  (unsigned)(Y+1);}
  else {
    dt.month= (unsigned)MONTH_IN_Y;
    dt.year=  (unsigned)Y;
  }
  dt.hour=      _tmHour(t);
  dt.minute=    _tmMinute(t);
  dt.second=    _tmSecond(t);
  dt.dayOfWeek= (Z + 2) % 7;
  return dt;
}

#pragma mark Some time intervals useful ?
/*
MSTimeInterval timeIntervalForFirstDayOfMonth(MSTimeInterval timeInterval)
{
  _dtm dt= _dtmCast(timeInterval);
  if (dt.day == 1) return _tmWithoutTime(timeInterval);
  return _tmFromYMD(dt.year, dt.month, 1);
}

MSTimeInterval timeIntervalForLastDayOfMonth(MSTimeInterval timeInterval)
{
  _dtm dt;
  unsigned day;
  dt= _dtmCast(timeInterval);
  day= _lastDayOfMonth(dt.year, dt.month);
  if (dt.day == day) return _tmWithoutTime(timeInterval);
  return _tmFromYMD(dt.year, dt.month, day);
}

MSTimeInterval timeIntervalForFirstDayOfYear(MSTimeInterval timeInterval)
{
  _dtm dt= _dtmCast(timeInterval);
  if (dt.day == 1 && dt.month == 1) return _tmWithoutTime(timeInterval);
  return _tmFromYMD(dt.year, 1, 1);
}

MSTimeInterval timeIntervalForLastDayOfYear(MSTimeInterval timeInterval)
{
  _dtm dt= _dtmCast(timeInterval);
  if (dt.day == 31 && dt.month == 12) return _tmWithoutTime(timeInterval);
  return _tmFromYMD(dt.year, 12, 31);
}
*/
#pragma mark Description

CString *CCreateDateDescription(CDate *self)
{
  _dtm dt= _dtmCast(self->interval);
  char buf[20];
  CString *s= CCreateString(20);
  sprintf(buf, "%04u-%02u-%02u %02u:%02u:%02u",
    (dt.year   % 10000),
    (dt.month  % 100),
    (dt.day    % 100),
    (dt.hour   % 100),
    (dt.minute % 100),
    (dt.second % 100));
  CStringAppendSES(s, MSMakeSESWithBytes(buf, 19, NSASCIIStringEncoding));
  return s;
}
// TODO: !!!
/*
NSString *timeIntervalDescription(MSTimeInterval timeInterval, NSString *format)
{
  _dtm dt= _dtmCast(timeInterval);
  return _MSDateTimeRefDescription(&dt, format, MSCurrentLanguage());
}

NSString *timeIntervalDescriptionForLanguage(MSTimeInterval timeInterval, NSString *format, MSLanguage language)
{
  _dtm dt= _dtmCast(timeInterval);
  return _MSDateTimeRefDescription(&dt, format, language);
}
*/

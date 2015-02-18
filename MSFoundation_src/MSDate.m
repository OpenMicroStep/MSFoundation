/* MSDate.m
 
 This implementation file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
 Eric Baradat :  k18rt@free.fr
 
 
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

#import "MSFoundation_Private.h"

#define MS_DATE_LAST_VERSION 301

#pragma mark Create functions

MSDate *MSCreateYMD(unsigned year,  unsigned month,   unsigned day)
{
  return (MSDate*)CCreateDateWithYMD(year, month, day);
}
MSDate *MSCreateYMDHMS(unsigned year,  unsigned month,   unsigned day,
                       unsigned h,     unsigned mn,      unsigned sec)
{
  return (MSDate*)CCreateDateWithYMDHMS(year, month, day, h, mn, sec);
}

@implementation MSDate
+ (void)load          {MSFinishLoadingAddClass(self);}
+ (void)finishLoading {[MSDate setVersion:MS_DATE_LAST_VERSION];}

#pragma mark Initialisation

+ (id)alloc                       {return ALLOC(self);}
+ (id)new                         {return ALLOC(self);}

+ (BOOL)verifyYear:(unsigned)year month:(unsigned)month day:(unsigned)day
{
  return CVerifyYMD(year, month, day);
}
+ (BOOL)verifyYear:(unsigned)year month: (unsigned)month day:   (unsigned)day
            hour:(unsigned)h    minute:(unsigned)mn    second:(unsigned)sec
{
  return CVerifyYMD(year, month, day) && CVerifyHMS(h, mn, sec);
}

+ (id)dateWithYear:(unsigned)year month:(unsigned)month day:(unsigned)day
{
  return YMD(year, month, day);
}
+ (id)dateWithYear:(unsigned)year month: (unsigned)month day:   (unsigned)day
              hour:(unsigned)h    minute:(unsigned)mn    second:(unsigned)sec
{
  return YMDHMS(year, month, day, h, mn, sec);
}

+ (id)dateWithSecondsSinceLocalReferenceDate:(MSTimeInterval)secsToBeAdded
{
  return AUTORELEASE([[self alloc] initWithSecondsSinceLocalReferenceDate:secsToBeAdded]);
}

+ (id)date
{
  return AUTORELEASE([ALLOC(self) init]);
}

+ (id)now
{
  return AUTORELEASE((id)CCreateDateNow());
}
+ (id)today
{
  return AUTORELEASE((id)CCreateDateToday());
}

- (id)init
{
  return (id)CDateInitNow((CDate*)self);
}
- (id)initWithYear:(unsigned)year month:(unsigned)month day:(unsigned)day
{
  return [self initWithYear:year month:month day:day hour:0 minute:0 second:0];
}
- (id)initWithYear:(unsigned)year month: (unsigned)month day:   (unsigned)day
              hour:(unsigned)h    minute:(unsigned)mn    second:(unsigned)sec
{
  CDateSetYMDHMS((CDate*)self, year, month, day, h, mn, sec);
  return self;
}

- (id)initWithSecondsSinceNow:(MSTimeInterval)secsToBeAddedToNow
{
  CDate *d;
  d= CDateInitNow((CDate*)self);
  d->interval+= secsToBeAddedToNow;
  return (id)d;
}
- (id)initWithSeconds:(MSTimeInterval)secs sinceDate:(NSDate*)d
{
  self->_interval= [d secondsSinceLocalReferenceDate]+secs;
  return self;
}

- (id)initWithSecondsSinceLocalReferenceDate:(MSTimeInterval)secsToBeAdded
{
  self->_interval= secsToBeAdded;
  return self;
}

/* Intentionnellement non implémentée car pour l'utilisateur, il n'est pas clair
   si le NSTimeInterval doit être exprimé en GMT ou en Local.
- (id)initWithTimeIntervalSince1970:(NSTimeInterval)secs
{
  [self initWithSeconds:(MSTimeInterval)secs sinceDate:[MSDate dateWithYear:1970 month:1 day:1]] ;
  return self;
}
*/

- (void)dealloc
{
  CDateFreeInside(self);
  [super dealloc];
}

#pragma mark Copying

- (id)copyWithZone:(NSZone*)zone
{
  return !zone || zone == [self zone] ? RETAIN(self) : CDateCopy(self);
}

#pragma mark Standard methods

- (BOOL)isEqual:(id)o
{
  if (o == self) return YES;
  return [o isKindOfClass:[NSDate class]] ?
      _interval==[o secondsSinceLocalReferenceDate]:
      NO;
}

- (BOOL)isEqualToDate:(NSDate*)o
{
  if (o == self) return YES;
  if (!o) return NO;
  return _interval==[o secondsSinceLocalReferenceDate];
}

// TODO: Voir avec MSString
- (NSString *)toString
{
  return AUTORELEASE((MSString*)CDateRetainedDescription(self));
}

- (NSString *)description
{
  return AUTORELEASE((MSString*)CDateRetainedDescription(self));
}
- (NSString *)descriptionWithLocale:(id)locale
{
  return AUTORELEASE((MSString*)CDateRetainedDescription(self));
  locale= nil;
}
- (NSString *)displayString
{
  return nil;
}

#pragma mark Super methods

- (NSTimeInterval)timeIntervalSinceReferenceDate
{
  return GMTFromLocal(_interval);
}

#pragma mark Informations

- (double)doubleValue      {return (double)_interval;}
- (long long)longLongValue {return _interval;}

- (unsigned)dayOfWeek       {return CDateDayOfWeek      ((CDate*)self);}
- (unsigned)dayOfMonth      {return CDateDayOfMonth     ((CDate*)self);}
- (unsigned)lastDayOfMonth  {return CDateLastDayOfMonth ((CDate*)self);}
- (unsigned)dayOfYear       {return CDateDayOfYear      ((CDate*)self);}
- (unsigned)dayOfCommonEra  {return CDateDayOfCommonEra ((CDate*)self);}
- (unsigned)weekOfYear      {return CDateWeekOfYear     ((CDate*)self);}
- (unsigned)monthOfYear     {return CDateMonthOfYear    ((CDate*)self);}
- (unsigned)yearOfCommonEra {return CDateYearOfCommonEra((CDate*)self);}
- (BOOL)    isLeapYear      {return CDateIsLeapYear     ((CDate*)self);}
- (unsigned)hourOfDay       {return CDateHourOfDay      ((CDate*)self);}
- (unsigned)minuteOfHour    {return CDateMinuteOfHour   ((CDate*)self);}
- (unsigned)secondOfMinute  {return CDateSecondOfMinute ((CDate*)self);}
- (unsigned)secondOfDay     {return CDateSecondOfDay    ((CDate*)self);}

#pragma mark Calculation

- (int)yearsSinceDate:(MSDate*)d usesTime:(BOOL)usesTime
{
  return CDateYearsBetweenDates((CDate*)d, (CDate*)self, usesTime);
}
- (int)monthsSinceDate:(MSDate*)d usesTime:(BOOL)usesTime
{
  return CDateMonthsBetweenDates((CDate*)d, (CDate*)self, usesTime);
}
- (int)daysSinceDate:(MSDate*)d usesTime:(BOOL)usesTime
{
  return CDateDaysBetweenDates((CDate*)d, (CDate*)self, usesTime);
}

- (MSTimeInterval)secondsSinceNow
{
  CDate *now= CCreateDateNow();
  MSTimeInterval r= CDateSecondsBetweenDates(now, (CDate*)self);
  CDateFree((id)now);
  return r;
}

- (MSTimeInterval)secondsSinceLocalReferenceDate
{
  return _interval;
}

- (MSTimeInterval)secondsSinceDate:(MSDate*)d
{
  return CDateSecondsBetweenDates((CDate*)d, (CDate*)self);
}

#pragma mark Obtaining other dates

- (id)dateByAddingYears:(int)years  months:(int)months days:(int)days
{
  MSDate *d;
  d= CDateCopy(self);
  CDateAddYMD((CDate*)d, years, months, days);
  return AUTORELEASE(d);
}
- (id)dateByAddingWeeks:(int)weeks
{
  MSDate *d;
  d= CDateCopy(self);
  CDateAddYMD((CDate*)d, 0, 0, 7*weeks);
  return AUTORELEASE(d);
}
- (id)dateByAddingHours:(int)hours minutes:(int)minutes seconds:(int)seconds
{
  MSDate *d;
  d= CDateCopy(self);
  CDateAddYMDHMS((CDate*)d, 0, 0, 0, hours, minutes, seconds);
  return AUTORELEASE(d);
}

// Set 0 for no change
- (id)dateByReplacingYear:(unsigned)y month:(unsigned)m day:(unsigned)a
{
  MSDate *d;
  d= CDateCopy(self);
  if (y) CDateSetYear ((CDate*)d, y);
  if (m) CDateSetMonth((CDate*)d, m);
  if (a) CDateSetDay  ((CDate*)d, a);
  return AUTORELEASE(d);
}
- (id)dateByReplacingWeek:(unsigned)w
{
  MSDate *d;
  d= CDateCopy(self);
  if (w) CDateSetWeek((CDate*)d, w);
  return AUTORELEASE(d);
}
- (id)dateByReplacingHour:(unsigned)h minute:(unsigned)m second:(unsigned)s
{
  MSDate *d; int dh,dm,ds;
  d= CDateCopy(self);
  dh= ((int)h - (int)CDateHourOfDay     ((CDate*)self));
  dm= ((int)m - (int)CDateMinuteOfHour  ((CDate*)self));
  ds= ((int)s - (int)CDateSecondOfMinute((CDate*)self));
  CDateAddYMDHMS((CDate*)d, 0, 0, 0, dh, dm, ds);
  return AUTORELEASE(d);
}

- (id)dateOfFirstDayOfYear
{
  return [[self class] dateWithYear:[self yearOfCommonEra] month:1 day:1];
}
- (id)dateOfLastDayOfYear
{
  return [[self class] dateWithYear:[self yearOfCommonEra] month:12 day:31];
}
- (id)dateOfFirstDayOfMonth
{
  unsigned y= [self yearOfCommonEra];
  unsigned m= [self monthOfYear];
  return [[self class] dateWithYear:y month:m day:1];
}
- (id)dateOfLastDayOfMonth
{
  unsigned y= [self yearOfCommonEra];
  unsigned m= [self monthOfYear];
  unsigned d= [self lastDayOfMonth];
  return [[self class] dateWithYear:y month:m day:d];
}
- (id)dateOfFirstDayOfWeek
{
  MSDate *d; int dw;
  d= [self dateWithoutTime];
  dw= (int)[d dayOfWeek];
  if (dw) CDateAddYMD((CDate*)d, 0, 0, -dw);
  return d;
}
- (id)dateOfLastDayOfWeek
{
  MSDate *d; int dw;
  d= [self dateWithoutTime];
  dw= (int)[d dayOfWeek];
  if (dw!=6) CDateAddYMD((CDate*)d, 0, 0, 6-dw);
  return d;
}
- (id)dateWithoutTime
{
  return AUTORELEASE((id)CCreateDayDate((CDate*)self));
}

#pragma mark description

- (NSString*)descriptionWithCalendarFormat:(NSString*)fmt
{
  NSTimeInterval t= GMTFromLocal(_interval);
  id d= [NSDate dateWithTimeIntervalSinceReferenceDate:t];
  return [d descriptionWithCalendarFormat:fmt timeZone:nil locale:nil];
}

NSString *GMTdescriptionRfc1123(NSTimeInterval t)
// http://tools.ietf.org/html/rfc2616 3.3 Date/Time Formats
// TODO: Normalement il n'y a pas de tirets pour la date
// ou alors rfc 850 mais le weekday est long
{
  static NSDictionary *localeDict;
  id d;
  if (!localeDict) localeDict= [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSArray arrayWithObjects:@"Sun",@"Mon",@"Tue",@"Wed",@"Thu",@"Fri",@"Sat", nil],
    @"NSShortWeekDayNameArray",
    [NSArray arrayWithObjects:@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",
      @"Aug",@"Sep",@"Oct",@"Nov",@"Dec", nil],
    @"NSShortMonthNameArray",nil];
  d= [NSDate dateWithTimeIntervalSinceReferenceDate:t];
  return [d descriptionWithCalendarFormat:@"%a, %d-%b-%Y %H:%M:%S GMT"
    timeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]
    locale:localeDict];
}
- (NSString*)descriptionRfc1123
{
  return GMTdescriptionRfc1123(GMTFromLocal(_interval));
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aCoder
{
  if ([aCoder allowsKeyedCoding]) {
    _interval= (MSTimeInterval)[aCoder decodeInt64ForKey:@"seconds"];}
  else {
    [aCoder decodeValueOfObjCType:@encode(MSTimeInterval) at:&_interval];}
  return self;
}

- (id)replacementObjectForPortCoder:(NSPortCoder *)encoder
{
  if ([encoder isBycopy]) return self;
  return [super replacementObjectForPortCoder:encoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  if ([aCoder allowsKeyedCoding]) {
    [aCoder encodeInt64:_interval forKey:@"seconds"];}
  else {
    [aCoder encodeValueOfObjCType:@encode(MSTimeInterval) at:&_interval];}
}

@end

@implementation NSDate (MSDateAddendum)
- (MSTimeInterval)secondsSinceLocalReferenceDate
{
  NSTimeInterval t= [self timeIntervalSinceReferenceDate];
  return GMTToLocal(t>=0 ? t+.5 :  t-.5);
}
- (NSString*)descriptionRfc1123
{
  return GMTdescriptionRfc1123([self timeIntervalSinceReferenceDate]);
}
@end

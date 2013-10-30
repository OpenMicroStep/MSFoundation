/* MSDate.h
 
 This header file is is a part of the MicroStep Framework.
 
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

 WARNING : this header file cannot be included alone, please direclty
 include <MSFoundation/MSFoundation.h>
 
 */


@interface NSDate (MSDateAddendum)
- (MSTimeInterval)secondsSinceReferenceDate;
@end

@interface MSDate : NSDate
{
@private
  MSTimeInterval _interval;
}

+ (BOOL)verifyYear:(unsigned)year month: (unsigned)month day:   (unsigned)day;
+ (BOOL)verifyYear:(unsigned)year month: (unsigned)month day:   (unsigned)day
              hour:(unsigned)h    minute:(unsigned)mn    second:(unsigned)sec;

+ (id)dateWithYear:(unsigned)year month: (unsigned)month day:   (unsigned)day;
+ (id)dateWithYear:(unsigned)year month: (unsigned)month day:   (unsigned)day
              hour:(unsigned)h    minute:(unsigned)mn    second:(unsigned)sec;

+ (id)now;
+ (id)today;

- (id)initWithYear:(unsigned)year month: (unsigned)month day:   (unsigned)day;
- (id)initWithYear:(unsigned)year month: (unsigned)month day:   (unsigned)day
              hour:(unsigned)h    minute:(unsigned)mn    second:(unsigned)sec;
- (id)initWithSecondsSinceNow:(int)secsToBeAddedToNow;
- (id)initWithSeconds:(int)secs sinceDate:(NSDate*)d;

- (double)doubleValue;
- (long long)longLongValue;

- (unsigned)dayOfWeek;
- (unsigned)dayOfMonth;
- (unsigned)lastDayOfMonth;
- (unsigned)dayOfYear;
- (unsigned)dayOfCommonEra;
- (unsigned)weekOfYear;
- (unsigned)monthOfYear;
- (unsigned)yearOfCommonEra;
- (BOOL)    isLeapYear;
- (unsigned)hourOfDay;
- (unsigned)minuteOfHour;
- (unsigned)secondOfMinute;
- (unsigned)secondOfDay;

- (int)yearsSinceDate: (MSDate*)d usesTime:(BOOL)usesTime;
- (int)monthsSinceDate:(MSDate*)d usesTime:(BOOL)usesTime;
- (int)daysSinceDate:  (MSDate*)d usesTime:(BOOL)usesTime;
- (MSTimeInterval)secondsSinceNow;
- (MSTimeInterval)secondsSinceReferenceDate;
- (MSTimeInterval)secondsSinceDate:(MSDate*)d;

- (id)dateByAddingYears:(int)years  months:(int)months days:(int)days;
- (id)dateByAddingWeeks:(int)weeks;
- (id)dateByAddingHours:(int)hours minutes:(int)minutes seconds:(int)seconds;

// Set 0 for no change
- (id)dateByReplacingYear:(unsigned)y month:(unsigned)m day:(unsigned)d;
- (id)dateByReplacingWeek:(unsigned)w;
- (id)dateByReplacingHour:(unsigned)h minutes:(unsigned)m seconds:(unsigned)s;

- (id)dateOfFirstDayOfYear;
- (id)dateOfLastDayOfYear;
- (id)dateOfFirstDayOfMonth;
- (id)dateOfLastDayOfMonth;
- (id)dateOfFirstDayOfWeek;
- (id)dateOfLastDayOfWeek;
- (id)dateWithoutTime;

@end

MSExport MSDate *MSCreateYMD   (unsigned year, unsigned month, unsigned day);
MSExport MSDate *MSCreateYMDHMS(unsigned year, unsigned month, unsigned day,
                                unsigned h,    unsigned mn,    unsigned sec);

#define YMD(Y,M,D)          AUTORELEASE(MSCreateYMD   ((Y),(M),(D)))
#define YMDHMS(Y,M,D,H,N,S) AUTORELEASE(MSCreateYMDHMS((Y),(M),(D),(H),(N),(S)))

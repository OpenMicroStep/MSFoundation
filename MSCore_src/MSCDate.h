/* MSCDate.h
 
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
 
 WARNING : outside the MSFoundation framework or the MSCore library,
 this header file cannot be included alone, please direclty include
 MSCore.h or MSFoundation.h
 
 */

// MSDate sont exprimées dans le referentiel LOCAL.
// First valid date is 1/1/1

#ifndef MSCORE_DATE_H
#define MSCORE_DATE_H

struct CDateStruct {
  MSCORE_NSOBJECT_ATTRIBUTES
  MSTimeInterval interval;};


// Constants
MSCoreExtern CDate *CDateDistantPast;
MSCoreExtern CDate *CDateDistantFuture;
MSCoreExtern CDate *CDate19700101;
MSCoreExtern CDate *CDate20010101;
MSCoreExtern MSTimeInterval CDateSecondsFrom19700101To20010101; // 978307200

  MSCoreExtern void CDateFreeInside(id self);
//Already defined in MSCObject.h
//MSCoreExtern void       CDateFree(id self);
//MSCoreExtern BOOL       CDateIsEqual(id self, id other);
//MSCoreExtern NSUInteger CDateHash(id self, unsigned depth);
//MSCoreExtern id         CDateCopy(id self);

MSCoreExtern BOOL CDateEquals(const CDate *self, const CDate *other);

#pragma mark Creation

MSCoreExtern BOOL CVerifyYMD(unsigned year, unsigned month , unsigned day   );
MSCoreExtern BOOL CVerifyHMS(unsigned hour, unsigned minute, unsigned second);
MSCoreExtern CDate *CCreateDateWithYMD(
  unsigned year, unsigned month,  unsigned day);
MSCoreExtern CDate *CCreateDateWithYMDHMS(
  unsigned year, unsigned month,  unsigned day,
  unsigned hour, unsigned minute, unsigned second);
MSCoreExtern CDate *CCreateDateWithSecondsFrom20010101(MSTimeInterval s);

MSCoreExtern CDate* CDateInitNow    (CDate* self);
MSCoreExtern CDate *CCreateDateNow  (void);        // With time
MSCoreExtern CDate *CCreateDateToday(void);        // No time
MSCoreExtern CDate *CCreateDayDate  (CDate *self); // No time

#pragma mark Informations

MSCoreExtern unsigned CDateDayOfWeek      (CDate *self);
MSCoreExtern unsigned CDateDayOfMonth     (CDate *self);
MSCoreExtern unsigned CDateLastDayOfMonth (CDate *self);
MSCoreExtern unsigned CDateDayOfYear      (CDate *self);
MSCoreExtern unsigned CDateDayOfCommonEra (CDate *self); // 1/1/1 is day 1
MSCoreExtern unsigned CDateWeekOfYear     (CDate *self);
MSCoreExtern unsigned CDateMonthOfYear    (CDate *self);
MSCoreExtern unsigned CDateYearOfCommonEra(CDate *self);
MSCoreExtern BOOL     CDateIsLeapYear     (CDate *self);

// If week not begins on monday. See again offset values with #defines.
//MSCoreExtern unsigned CDateDayOfWeekWithOffset (CDate *self, unsigned offset);
//MSCoreExtern unsigned CDateWeekOfYearWithOffset(CDate *self, unsigned offset);

MSCoreExtern unsigned CDateHourOfDay     (CDate *self);
MSCoreExtern unsigned CDateMinuteOfHour  (CDate *self);
MSCoreExtern unsigned CDateSecondOfMinute(CDate *self);
MSCoreExtern unsigned CDateSecondOfDay   (CDate *self);

MSCoreExtern int CDateYearsBetweenDates (CDate *first, CDate *last, BOOL usesTime);
MSCoreExtern int CDateMonthsBetweenDates(CDate *first, CDate *last, BOOL usesTime);
MSCoreExtern int CDateDaysBetweenDates  (CDate *first, CDate *last, BOOL usesTime);
MSCoreExtern MSTimeInterval CDateSecondsBetweenDates(CDate *first, CDate *last);

#pragma mark Setters

MSCoreExtern void CDateAddYMD      (CDate *self, int years, int months , int days);
MSCoreExtern void CDateAddYMDHMS   (CDate *self, int years, int months , int days,
                                             int hours, int minutes, int secs);
MSCoreExtern void CDateSetYMDHMS   (CDate *self, unsigned y,unsigned m,unsigned d,
                                             unsigned h,unsigned n,unsigned s);
MSCoreExtern void CDateSetYear     (CDate *self, unsigned year);
MSCoreExtern void CDateSetMonth    (CDate *self, unsigned month);
MSCoreExtern void CDateSetWeek     (CDate *self, unsigned week);
MSCoreExtern void CDateSetDay      (CDate *self, unsigned day);
MSCoreExtern void CDateSetDayOfYear(CDate *self, unsigned doy);

// GMT
MSCoreExtern MSLong _GMTMicro(void);
MSCoreExtern NSTimeInterval GMTNow(void);
MSCoreExtern NSTimeInterval GMTWithYMDHMS(
  unsigned year, unsigned month,  unsigned day,
  unsigned hour, unsigned minute, unsigned second);
  // The date is supposed valid. If you're not sure, use the CVerify... fcts.
  // YMDHMS are expressed in GMT.
  // If YMDHMS are in Local, use:
  //   CDate *d= CCreateDateWithYMDHMS();
  //   NSTimeInterval dgmt;
  //   dgmt= GMTFromLocal(CDateSecondsBetweenDates(CDate20010101,d));
  //   or
  //   dgmt= GMTFromLocal(d->interval);
// Changement de référentiel Local <-> GMT
MSCoreExtern NSTimeInterval GMTFromLocal(MSTimeInterval t); // TODO: How on windows ?
MSCoreExtern MSTimeInterval GMTToLocal(NSTimeInterval t);

#endif

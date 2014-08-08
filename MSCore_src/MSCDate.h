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

typedef struct CDateStruct {
  Class isa;
#ifdef MSCORE_STANDALONE
  NSUInteger refCount;
#endif
  MSTimeInterval interval;}
CDate;


// Constants
MSCoreExport CDate *CDateDistantPast;
MSCoreExport CDate *CDateDistantFuture;
MSCoreExport CDate *CDate19700101;
MSCoreExport CDate *CDate20010101;
MSCoreExport MSTimeInterval CDateSecondsFrom19700101To20010101; // 978307200

  MSCoreExport void CDateFreeInside(id self);
//Already defined in MSCObject.h
//MSCoreExport void       CDateFree(id self);
//MSCoreExport BOOL       CDateIsEqual(id self, id other);
//MSCoreExport NSUInteger CDateHash(id self, unsigned depth);
//MSCoreExport id         CDateCopy(id self);

MSCoreExport BOOL CDateEquals(const CDate *self, const CDate *other);

#pragma mark Creation

MSCoreExport BOOL CVerifyYMD(unsigned year, unsigned month , unsigned day   );
MSCoreExport BOOL CVerifyHMS(unsigned hour, unsigned minute, unsigned second);
MSCoreExport CDate *CCreateDateFromYMD(
  unsigned year, unsigned month,  unsigned day);
MSCoreExport CDate *CCreateDateFromYMDHMS(
  unsigned year, unsigned month,  unsigned day,
  unsigned hour, unsigned minute, unsigned second);
MSCoreExport CDate *CCreateDateWithSecondsFrom20010101(MSTimeInterval s);

MSCoreExport CDate *CCreateDateNow  (void);        // With time
MSCoreExport CDate *CCreateDateToday(void);        // No time
MSCoreExport CDate *CCreateDayDate  (CDate *self); // No time

#pragma mark Informations

MSCoreExport unsigned CDateDayOfWeek      (CDate *self);
MSCoreExport unsigned CDateDayOfMonth     (CDate *self);
MSCoreExport unsigned CDateLastDayOfMonth (CDate *self);
MSCoreExport unsigned CDateDayOfYear      (CDate *self);
MSCoreExport unsigned CDateDayOfCommonEra (CDate *self); // 1/1/1 is day 1
MSCoreExport unsigned CDateWeekOfYear     (CDate *self);
MSCoreExport unsigned CDateMonthOfYear    (CDate *self);
MSCoreExport unsigned CDateYearOfCommonEra(CDate *self);
MSCoreExport BOOL     CDateIsLeapYear     (CDate *self);

// If week not begins on monday. See again offset values with #defines.
//MSCoreExport unsigned CDateDayOfWeekWithOffset (CDate *self, unsigned offset);
//MSCoreExport unsigned CDateWeekOfYearWithOffset(CDate *self, unsigned offset);

MSCoreExport unsigned CDateHourOfDay     (CDate *self);
MSCoreExport unsigned CDateMinuteOfHour  (CDate *self);
MSCoreExport unsigned CDateSecondOfMinute(CDate *self);
MSCoreExport unsigned CDateSecondOfDay   (CDate *self);

MSCoreExport int CDateYearsBetweenDates (CDate *first, CDate *last, BOOL usesTime);
MSCoreExport int CDateMonthsBetweenDates(CDate *first, CDate *last, BOOL usesTime);
MSCoreExport int CDateDaysBetweenDates  (CDate *first, CDate *last, BOOL usesTime);
MSCoreExport MSTimeInterval CDateSecondsBetweenDates(CDate *first, CDate *last);

#pragma mark Setters

MSCoreExport void CDateAddYMD      (CDate *self, int years, int months , int days);
MSCoreExport void CDateAddYMDHMS   (CDate *self, int years, int months , int days,
                                             int hours, int minutes, int secs);
MSCoreExport void CDateSetYMDHMS   (CDate *self, unsigned y,unsigned m,unsigned d,
                                             unsigned h,unsigned n,unsigned s);
MSCoreExport void CDateSetYear     (CDate *self, unsigned year);
MSCoreExport void CDateSetMonth    (CDate *self, unsigned month);
MSCoreExport void CDateSetWeek     (CDate *self, unsigned week);
MSCoreExport void CDateSetDay      (CDate *self, unsigned day);
MSCoreExport void CDateSetDayOfYear(CDate *self, unsigned doy);

// GMT
MSCoreExport NSTimeInterval GMTNow(void);
MSCoreExport NSTimeInterval GMTFromYMDHMS(
  unsigned year, unsigned month,  unsigned day,
  unsigned hour, unsigned minute, unsigned second);
  // The date is supposed valid. If you're not sure, use the CVerify... fcts.
  // YMDHMS are expressed in GMT.
  // If YMDHMS are in Local, use:
  //   CDate *d= CCreateDateFromYMDHMS();
  //   NSTimeInterval dgmt;
  //   dgmt= GMTFromLocal(CDateSecondsBetweenDates(CDate20010101,d));
  //   or
  //   dgmt= GMTFromLocal(d->interval);
// Changement de référentiel Local <-> GMT
MSCoreExport NSTimeInterval GMTFromLocal(MSTimeInterval t); // TODO: How on windows ?
MSCoreExport MSTimeInterval GMTToLocal(NSTimeInterval t);

// TODO: description functions
MSCoreExport CString *CCreateDateDescription(CDate *self); // %Y/%m/%d-%H:%M:%S

#endif

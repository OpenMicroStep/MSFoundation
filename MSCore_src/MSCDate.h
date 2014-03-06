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
MSExport CDate *CDateDistantPast;
MSExport CDate *CDateDistantFuture;
MSExport CDate *CDate19700101;
MSExport CDate *CDate20010101;
MSExport MSTimeInterval CDateSecondsFrom19700101To20010101; // 978307200

  MSExport void CDateFreeInside(id self);
//Already defined in MSCObject.h
//MSExport void       CDateFree(id self);
//MSExport BOOL       CDateIsEqual(id self, id other);
//MSExport NSUInteger CDateHash(id self, unsigned depth);
//MSExport id         CDateCopy(id self);

MSExport BOOL CDateEquals(const CDate *self, const CDate *other);

#pragma mark Creation

MSExport BOOL CVerifyYMD(unsigned year, unsigned month , unsigned day   );
MSExport BOOL CVerifyHMS(unsigned hour, unsigned minute, unsigned second);
MSExport CDate *CCreateDateFromYMD(
  unsigned year, unsigned month,  unsigned day);
MSExport CDate *CCreateDateFromYMDHMS(
  unsigned year, unsigned month,  unsigned day,
  unsigned hour, unsigned minute, unsigned second);
MSExport CDate *CCreateDateWithSecondsFrom20010101(MSTimeInterval s);

//CDate *CCreateDateNowGMT(); // Useful ????
MSExport CDate *CCreateDateNow  (void);        // With time
MSExport CDate *CCreateDateToday(void);        // No time
MSExport CDate *CCreateDayDate  (CDate *self); // No time

#pragma mark Informations

MSExport unsigned CDateDayOfWeek      (CDate *self);
MSExport unsigned CDateDayOfMonth     (CDate *self);
MSExport unsigned CDateLastDayOfMonth (CDate *self);
MSExport unsigned CDateDayOfYear      (CDate *self);
MSExport unsigned CDateDayOfCommonEra (CDate *self); // 1/1/1 is day 1
MSExport unsigned CDateWeekOfYear     (CDate *self);
MSExport unsigned CDateMonthOfYear    (CDate *self);
MSExport unsigned CDateYearOfCommonEra(CDate *self);
MSExport BOOL     CDateIsLeapYear     (CDate *self);

// If week not begins on monday. See again offset values with #defines.
//MSExport unsigned CDateDayOfWeekWithOffset (CDate *self, unsigned offset);
//MSExport unsigned CDateWeekOfYearWithOffset(CDate *self, unsigned offset);

MSExport unsigned CDateHourOfDay     (CDate *self);
MSExport unsigned CDateMinuteOfHour  (CDate *self);
MSExport unsigned CDateSecondOfMinute(CDate *self);
MSExport unsigned CDateSecondOfDay   (CDate *self);

MSExport int CDateYearsBetweenDates (CDate *first, CDate *last, BOOL usesTime);
MSExport int CDateMonthsBetweenDates(CDate *first, CDate *last, BOOL usesTime);
MSExport int CDateDaysBetweenDates  (CDate *first, CDate *last, BOOL usesTime);
MSExport MSTimeInterval CDateSecondsBetweenDates(CDate *first, CDate *last);

#pragma mark Setters

MSExport void CDateAddYMD      (CDate *self, int years, int months , int days);
MSExport void CDateAddYMDHMS   (CDate *self, int years, int months , int days,
                                             int hours, int minutes, int secs);
MSExport void CDateSetYMDHMS   (CDate *self, unsigned y,unsigned m,unsigned d,
                                             unsigned h,unsigned n,unsigned s);
MSExport void CDateSetYear     (CDate *self, unsigned year);
MSExport void CDateSetMonth    (CDate *self, unsigned month);
MSExport void CDateSetWeek     (CDate *self, unsigned week);
MSExport void CDateSetDay      (CDate *self, unsigned day);
MSExport void CDateSetDayOfYear(CDate *self, unsigned doy);

// TODO: description functions

#endif

/* MSCDecimal.h
 
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

#ifndef MSCORE_DECIMAL_H
#define MSCORE_DECIMAL_H

typedef struct CDecimalStruct {
  Class isa;
#ifdef MSCORE_STANDALONE
  NSUInteger refCount;
#endif
  unsigned char *m_apm_data;
  long m_apm_id;
  int  m_apm_malloclength;
  int  m_apm_datalength;
  int  m_apm_exponent;
  int  m_apm_sign;}
CDecimal;


  MSExport void CDecimalFreeInside(id self);
//Already defined in MSCObject.h
//MSExport void       CDecimalFree(id self);
//MSExport BOOL       CDecimalIsEqual(id self, id other);
//MSExport NSUInteger CDecimalHash(id self, unsigned depth);
//MSExport id         CDecimalCopy(id self);

MSExport BOOL CDecimalEquals(const CDecimal *self, const CDecimal *other);

#pragma mark Creation

//TODO: MSExport CDecimal *CCreateDecimalFromString(MSString *x);
MSExport CDecimal *CCreateDecimalFromUTF8String(const char *x);
MSExport CDecimal *CCreateDecimalFromDouble(double x);
MSExport CDecimal *CCreateDecimalFromLong  (long   x);
MSExport CDecimal *CCreateDecimalFromMantissaExponentSign(
  unsigned long long mm, int exponent, int sign);

#pragma mark Calculation

MSExport CDecimal *CDecimalFloor   (CDecimal *a);
MSExport CDecimal *CDecimalCeil    (CDecimal *a);
MSExport CDecimal *CDecimalAdd     (CDecimal *a, CDecimal *b);
MSExport CDecimal *CDecimalSubtract(CDecimal *a, CDecimal *b);
MSExport CDecimal *CDecimalMultiply(CDecimal *a, CDecimal *b);
MSExport CDecimal *CDecimalDivide  (CDecimal *a, CDecimal *b,int decimalPlaces);

// TODO: description functions

#endif

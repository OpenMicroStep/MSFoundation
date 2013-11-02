/* MSCDecimal.c
 
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

#include "MSCorePrivate_.h"

#pragma mark c-like class methods

void CDecimalFreeInside(id self)
{
  if (self) {m_apm_deallocate((CDecimal*)self);}
}
void CDecimalFree(id self)
{
  CDecimalFreeInside(self);
  MSFree(self, "CDecimalFree() [self]");
}

BOOL CDecimalIsEqual(id self, id other)
{
  return _CClassIsEqual(self,other,(CObjectEq)CDecimalEquals);
}

NSUInteger CDecimalHash(id self, unsigned depth)
{
  // TODO:
  // a correct hash code from this decimal number
  // may be try to get 3 digits, the number of digits and try to mix all of this
  
  // THIS VALUE IS BAD : MUST BE DONE CORRECTLY BEFORE TO BE USED IN CDICTIONARIES
  return self ? (NSUInteger)self : 0;
  depth= 0; // unused parameter
}

id CDecimalCopy(id self)
{
  CDecimal *newDecimal;
  if (!self) return nil;
  newDecimal= (CDecimal*)MSCreateObjectWithClassIndex(CDecimalClassIndex);
  newDecimal= m_apm_init(newDecimal);
  if (newDecimal) m_apm_copy(newDecimal, (CDecimal*)self);
  return (id)newDecimal;
}

#pragma mark Equality

BOOL CDecimalEquals(const CDecimal *self, const CDecimal *other)
{
  if (self == other) return YES;
  if (self && other) {
    return m_apm_compare((M_APM)self, (M_APM)other) == 0 ? YES : NO ;}
  return NO;
}

#pragma mark Creation

CDecimal *CCreateDecimalFromUTF8String(const char *x)
{
  CDecimal *d= m_apm_new();
  m_apm_set_string(d, x);
  return d;
}

CDecimal *CCreateDecimalFromDouble(double x)
{
  CDecimal *d= m_apm_new();
  m_apm_set_double(d, x);
  return d;
}

CDecimal *CCreateDecimalFromLong(long x)
{
  CDecimal *d= m_apm_new();
  m_apm_set_long(d, x);
  return d;
}

CDecimal *CCreateDecimalFromMantissaExponentSign(
  unsigned long long mm, int exponent, int sign)
{
  CDecimal *d= m_apm_new();
  set_mantissa_exponent_sign(d, mm, exponent, sign);
  return d;
}

#pragma mark Calculation

CDecimal *CDecimalFloor(CDecimal *a)
{CDecimal *d= m_apm_new(); m_apm_floor(d, a); return d;}

CDecimal *CDecimalCeil(CDecimal *a)
{CDecimal *d= m_apm_new(); m_apm_ceil(d, a); return d;}

CDecimal *CDecimalAdd(CDecimal *a, CDecimal *b)
{CDecimal *d= m_apm_new(); m_apm_add(d, a, b); return d;}

CDecimal *CDecimalSubtract(CDecimal *a, CDecimal *b)
{CDecimal *d= m_apm_new(); m_apm_subtract(d, a, b); return d;}

CDecimal *CDecimalMultiply(CDecimal *a, CDecimal *b)
{CDecimal *d= m_apm_new(); m_apm_multiply(d, a, b); return d;}

CDecimal *CDecimalDivide(CDecimal *a, CDecimal *b, int decimalPlaces)
{CDecimal *d= m_apm_new(); m_apm_divide(d, decimalPlaces, a, b); return d;}

#pragma mark Description

// TODO: !!!
/*
NSString *timeIntervalDescription(MSTimeInterval timeInterval, NSString *format)
{
  _dtm dt= _dtmCast(timeInterval);
  return _MSDecimalTimeRefDescription(&dt, format, MSCurrentLanguage());
}

NSString *timeIntervalDescriptionForLanguage(MSTimeInterval timeInterval, NSString *format, MSLanguage language)
{
  _dtm dt= _dtmCast(timeInterval);
  return _MSDecimalTimeRefDescription(&dt, format, language);
}
*/

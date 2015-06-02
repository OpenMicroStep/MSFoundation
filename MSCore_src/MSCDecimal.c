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

#include "MSCore_Private.h"

#pragma mark c-like class methods

void CDecimalFreeInside(id self)
{
  if (self) {m_apm_deallocate((CDecimal*)self);}
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
  MSUnused(depth); // unused parameter
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

void CDecimalDescribe(id self, id result, int level, mutable CDictionary *ctx)
{
}

const CString* CDecimalRetainedDescription(id self)
{
  if (!self) return nil;
  else {
    CDecimal *d= (CDecimal *)self;
    int exp=   abs(d->m_apm_exponent - 1);
    int expLg= exp==0 ? 1 : (int)(log(exp)+1.);
    int rLg= d->m_apm_datalength+5+expLg+1; // 5 pour -.E± ou 0.0E+
    char r[rLg];
    m_apm_to_string(r,-1,d);
    if ((int)strlen(r)+1>rLg) fprintf(stderr, "Error CCreateDecimalDescription"
                                      " longueur attendue: %d réelle:%lu\n",rLg,strlen(r));
    return CCreateStringWithBytes(NSASCIIStringEncoding, r, strlen(r));}
}

#pragma mark Equality

BOOL CDecimalEquals(const CDecimal *self, const CDecimal *other)
{
  if (self == other) return YES;
  if (self && other) {
    return m_apm_compare((M_APM)self, (M_APM)other) == 0 ? YES : NO;}
  return NO;
}

#pragma mark Creation

static inline NSUInteger _move(SES src, NSUInteger *start, NSUInteger end, unichar u1, unichar u2)
// on avance d'un u1 ou u2 si présent (alors start avance de 1) et de tous les chiffres qui suivent
// retourne l'index de fin
{
  NSUInteger idx,x; unichar u='r';
  x= idx= *start;
  if (x < end && ((u= SESIndexN(src, &x)) == u1 || (u2 && u == u2))) {*start= idx= x;}
  for (x= idx; x < end && '0' <= (u= SESIndexN(src, &x)) && u <= '9';) idx= x;
  return idx;
}
CDecimal *CCreateDecimalWithSES(SES src, BOOL intOnly, CUnicharChecker leftSpaces, SES *rSes)
// Calcule le SES du nombre trouvé et le retourne par référence si rSes!=NULL.
// Si le nombre est bien formé, retourne le décimal correspondant. Sinon NULL;
{
  SES ret= MSInvalidSES; CDecimal *d= NULL;
  if (SESOK(src)) {
    NSUInteger end= SESEnd(src), num0, num, pt0, pt, exp0, exp, idx, x, i; BOOL err= NO;
    if (!leftSpaces) leftSpaces= CUnicharIsSpace;
    for (x= idx= SESStart(src); x < end && leftSpaces(SESIndexN(src, &x));) idx= x;
    num0= num= idx; idx= _move(src, &num, end, '+', '-');
    if (!intOnly) { //.xxxE±yyy
      pt0= pt= idx; idx= _move(src, &pt, end, '.', 0);
      if (pt > pt0 && idx-num == pt-pt0) err=YES; // un point sans chiffre devant ou derrière
      else if (idx > num) { // il faut quelque chose avant le e
        exp0= exp= idx; idx= _move(src, &exp, end, 'e', 'E');
        if (exp > exp0 && idx == exp) {
          idx= _move(src, &exp, end, '+', '-');
          if (idx == exp) err= YES;}}} // rien après le e
    if (!err && idx == num) err= YES; // pas de chiffres
    ret= src;
    ret.start= num0;
    ret.length= idx-num0;
    if (!err && idx > num0) {
      char txt[idx-num0+1];
      for (i=0, x= num0; x<idx; i++) txt[i]= (char)SESIndexN(src, &x);
      txt[i]= 0x00;
      d= CCreateDecimalWithUTF8String(txt);}}
  if (rSes) *rSes= ret;
  return d;
}

MSLong CStrToLongLong(const char *restrict str, char **restrict endptr)
{
  MSLong ret; SES src,rSes; CDecimal *d;
  src= MSMakeSESWithBytes(str, strlen(str), NSUTF8StringEncoding);
  d= CCreateDecimalWithSES(src, YES, NULL, &rSes);
  if (endptr) *endptr= (char*)str+SESEnd(rSes);
  ret= CDecimalLongValue(d);
  RELEAZEN(d);
  return ret;
}

MSULong CStrToULongLong(const char *restrict str, char **restrict endptr)
{
  MSULong ret; SES src,rSes; CDecimal *d;
  src= MSMakeSESWithBytes(str, strlen(str), NSUTF8StringEncoding);
  d= CCreateDecimalWithSES(src, YES, NULL, &rSes);
  if (endptr) *endptr= (char*)str+SESEnd(rSes);
  ret= CDecimalULongValue(d);
  RELEAZEN(d);
  return ret;
}

CDecimal *CCreateDecimalWithString(CString *x)
{
  return CCreateDecimalWithSES(CStringSES(x), NO, NULL, NULL);
}

CDecimal *CCreateDecimalWithUTF8String(const char *x)
{
  CDecimal *d= m_apm_new();
  m_apm_set_string(d, x);
  return d;
}

CDecimal *CCreateDecimalWithDouble(double x)
{
  CDecimal *d= m_apm_new();
  m_apm_set_double(d, x);
  return d;
}

CDecimal *CCreateDecimalWithLongLong(MSLong x)
{
  CDecimal *d= m_apm_new();
  m_apm_set_long(d, x);
  return d;
}

CDecimal *CCreateDecimalWithULongLong(MSULong x)
{
  CDecimal *d= m_apm_new();
  m_apm_set_ulong(d, x);
  return d;
}

CDecimal *CCreateDecimalWithMantissaExponentSign(MSULong mm, MSInt exponent, int sign)
{
  CDecimal *d= m_apm_new();
  m_apm_set_mantissa_exponent_sign(d, mm, exponent, sign);
  return d;
}

#pragma mark Calculation

CDecimal *CCreateDecimalFloor(CDecimal *a)
{CDecimal *d= m_apm_new(); m_apm_floor(d, a); return d;}

CDecimal *CCreateDecimalCeil(CDecimal *a)
{CDecimal *d= m_apm_new(); m_apm_ceil(d, a); return d;}

CDecimal *CCreateDecimalAdd(CDecimal *a, CDecimal *b)
{CDecimal *d= m_apm_new(); m_apm_add(d, a, b); return d;}

CDecimal *CCreateDecimalSubtract(CDecimal *a, CDecimal *b)
{CDecimal *d= m_apm_new(); m_apm_subtract(d, a, b); return d;}

CDecimal *CCreateDecimalMultiply(CDecimal *a, CDecimal *b)
{CDecimal *d= m_apm_new(); m_apm_multiply(d, a, b); return d;}

CDecimal *CCreateDecimalDivide(CDecimal *a, CDecimal *b, int decimalPlaces)
{CDecimal *d= m_apm_new(); m_apm_divide(d, decimalPlaces, a, b); return d;}

#pragma mark Value

MSChar     CDecimalCharValue(    CDecimal *a) {return !a?0:m_apm_to_char(a);}
MSByte     CDecimalByteValue(    CDecimal *a) {return !a?0:m_apm_to_byte(a);}
MSShort    CDecimalShortValue(   CDecimal *a) {return !a?0:m_apm_to_short(a);}
MSUShort   CDecimalUShortValue(  CDecimal *a) {return !a?0:m_apm_to_ushort(a);}
MSInt      CDecimalIntValue(     CDecimal *a) {return !a?0:m_apm_to_int(a);}
MSUInt     CDecimalUIntValue(    CDecimal *a) {return !a?0:m_apm_to_uint(a);}
MSLong     CDecimalLongValue(    CDecimal *a) {return !a?0:m_apm_to_long(a);}
MSULong    CDecimalULongValue(   CDecimal *a) {return !a?0:m_apm_to_ulong(a);}
NSInteger  CDecimalIntegerValue( CDecimal *a) {return !a?0:m_apm_to_integer(a);}
NSUInteger CDecimalUIntegerValue(CDecimal *a) {return !a?0:m_apm_to_uinteger(a);}

// TODO: Revoir si inférieur à float min ou supérieur à float max
float CDecimalFloatValue(CDecimal *d)
{
  return (float)CDecimalDoubleValue(d);
}

// TODO: Ne pas passer par strtod
double CDecimalDoubleValue(CDecimal *a)
{
  double ret= 0.0;
  if (a) {
    char *ascii;
    ascii= m_apm_to_fixpt_stringexp(-1, a, '.', 0, 0);
    ret= strtod(ascii, NULL);
    free(ascii);}
  return ret;
}

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

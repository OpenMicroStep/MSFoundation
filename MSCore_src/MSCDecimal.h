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


  MSCoreExport void CDecimalFreeInside(id self);
//Already defined in MSCObject.h
//MSCoreExport void       CDecimalFree(id self);
//MSCoreExport BOOL       CDecimalIsEqual(id self, id other);
//MSCoreExport NSUInteger CDecimalHash(id self, unsigned depth);
//MSCoreExport id         CDecimalCopy(id self);

MSCoreExport BOOL CDecimalEquals(const CDecimal *self, const CDecimal *other);

#pragma mark Creation

// Extrait un décimal, ou juste sa partie entière si intOnly=YES.
// Le SES rSes retourné par référence est la chaine contenant le nombre sans les leftSpaces.
// Si le nombre est bien formé, le décimal correspondant est créé et retourné.
// Si le nombre est mal formé (par ex: " +.", nil est retourné mais rSes contient néanmoins ce qui a été lu
// (dans l'exemple, SESStart(*rSes)==1, SESLength(*rSes)==1 si intOnly, 2 sinon)
MSCoreExport CDecimal *CCreateDecimalWithSES(SES src, BOOL intOnly, CUnicharChecker leftSpaces, SES *rSes);

MSCoreExport CDecimal *CCreateDecimalWithString(CString *x);
MSCoreExport CDecimal *CCreateDecimalWithUTF8String(const char *x);
MSCoreExport CDecimal *CCreateDecimalWithDouble(double x);
MSCoreExport CDecimal *CCreateDecimalWithLong  (MSLong x);
MSCoreExport CDecimal *CCreateDecimalWithULong (MSULong x);
MSCoreExport CDecimal *CCreateDecimalWithMantissaExponentSign(MSULong mm, MSInt exponent, int sign);

#pragma mark Calculation

MSCoreExport CDecimal *CCreateDecimalFloor   (CDecimal *a);
MSCoreExport CDecimal *CCreateDecimalCeil    (CDecimal *a);
MSCoreExport CDecimal *CCreateDecimalAdd     (CDecimal *a, CDecimal *b);
MSCoreExport CDecimal *CCreateDecimalSubtract(CDecimal *a, CDecimal *b);
MSCoreExport CDecimal *CCreateDecimalMultiply(CDecimal *a, CDecimal *b);
MSCoreExport CDecimal *CCreateDecimalDivide  (CDecimal *a, CDecimal *b, int decimalPlaces);

#pragma mark Value

MSCoreExport MSChar     CDecimalCharValue(    CDecimal*);
MSCoreExport MSByte     CDecimalByteValue(    CDecimal*);
MSCoreExport MSShort    CDecimalShortValue(   CDecimal*);
MSCoreExport MSUShort   CDecimalUShortValue(  CDecimal*);
MSCoreExport MSInt      CDecimalIntValue(     CDecimal*);
MSCoreExport MSUInt     CDecimalUIntValue(    CDecimal*);
MSCoreExport MSLong     CDecimalLongValue(    CDecimal*);
MSCoreExport MSULong    CDecimalULongValue(   CDecimal*);
MSCoreExport NSInteger  CDecimalIntegerValue( CDecimal*);
MSCoreExport NSUInteger CDecimalUIntegerValue(CDecimal*);
// TODO: MSCoreExport double    CDecimalDoubleValue (CDecimal*);


// Identique à CCreateDecimalWithSES mmais ecrite comme une SESEXtract... fonction.
// Extrait un décimal, ou juste sa partie entière si intOnly=YES.
// Le SES retourné est la chaine contenant le nombre sans les leftSpaces.
// Si le nombre est bien formé, le décimal correspondant est retourné dans decimalPtr.
// Il doit être libéré par l'appelant.
// Déclaré ici car MSCoreSES.h est inclut avant MSCDecimal.h.
MSCoreExport SES SESExtractDecimal(SES src, BOOL intOnly, CUnicharChecker leftSpaces, CDecimal **decimalPtr);

// TODO: description functions
MSCoreExport CString *CCreateDecimalDescription(CDecimal*);

MSCoreExport MSLong  CStrToLong( const char *restrict str, char **restrict endptr);
MSCoreExport MSULong CStrToULong(const char *restrict str, char **restrict endptr);

#endif

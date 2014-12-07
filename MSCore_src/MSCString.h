/* MSCString.h
 
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

#ifndef MSBase_MSCString_h
#define MSBase_MSCString_h

typedef struct CStringStruct {
  Class      isa;
#ifdef MSCORE_STANDALONE
  NSUInteger refCount;
#endif
  unichar*   buf;
  NSUInteger size;
  NSUInteger length;
  CGrowFlags flag;}
CString;


  MSCoreExport void       CStringFreeInside(id self); // for MSArray dealloc
//  MSCoreExport id         CStringInitCopy(CString *self, const CString *copied);
//Already defined in MSCObject.h
//MSCoreExport void       CStringFree(id self);
//MSCoreExport BOOL       CStringIsEqual(id self, id other);
//MSCoreExport NSUInteger CStringHash(id self, unsigned depth);
//MSCoreExport id         CStringCopy(id self);
//  Warning: the copy follows the options of self: if objects are not
//  retained in self, they are not retained in the copy. If nilItems are
//  allowed in self, they are also allowed in the copy.

MSCoreExport BOOL CStringEquals           (const CString *s1, const CString *s2);
MSCoreExport BOOL CStringInsensitiveEquals(const CString *s1, const CString *s2);

MSCoreExport CString *CCreateString(NSUInteger capacity);
MSCoreExport CString *CCreateStringWithBytes(NSStringEncoding encoding, const void *s, NSUInteger length);
MSCoreExport CString *CCreateStringWithSES(SES ses);

MSCoreExport void CStringGrow(CString *self, NSUInteger n);
MSCoreExport void CStringAdjustSize(CString *self);

MSCoreExport NSUInteger CStringLength(const CString *self);
MSCoreExport unichar    CStringCharacterAtIndex(const CString *self, NSUInteger i);
MSCoreExport NSUInteger CStringIndexOfCharacter(const CString *self, unichar c);
MSCoreExport SES        CStringSES(const CString *self);


MSCoreExport void CStringAppendCharacter(CString *self, unichar c);
MSCoreExport void CStringAppendCharacterSuite(CString *self, unichar c, NSUInteger nb);
MSCoreExport void CStringAppendBytes(CString *self, NSStringEncoding encoding, const void *s, NSUInteger length);
MSCoreExport void CStringAppendEncodedFormat(CString *self, NSStringEncoding encoding, const char *fmt, ...);
MSCoreExport void CStringAppendEncodedFormatArguments(CString *self, NSStringEncoding encoding, const char *fmt, va_list args);
MSCoreExport void CStringAppendSES(CString *self, SES ses);
MSCoreExport void CStringAppendString(CString *self, const CString *s);

// TODO: Not reviewed, not tested.
// this functions work only for ANSI, Mac roman, NextStep, ISO Latin 1, UTF8 and ASCII as supposed encoding NOT TESTED
MSCoreExport BOOL CStringAppendSupposedEncodingBytes(CString *self, const void *bytes, NSUInteger length, NSStringEncoding suposedEncoding, NSStringEncoding *foundEncodingPointer);
// if you don't know what encoding you've got from your internet source, try UTF8 as supposed encoding
MSCoreExport BOOL CStringAppendInternetBytes(CString *self, const void *bytes, NSUInteger len, NSStringEncoding suposedEncoding, NSStringEncoding *foundEncodingPointer);
// same remark. this function decodes URL encoding scheme in the supposed encoding
MSCoreExport BOOL CStringAppendURLBytes(CString *self, const void *bytes, NSUInteger len, NSStringEncoding suposedEncoding, NSStringEncoding *foundEncodingPointer);

//MSCoreExport BOOL CStringAppendTimeInterval(CString *self, MSTimeInterval interval, const char *utf8StringFormat, MSLanguage language);

MSCoreExport BOOL CStringAppendTextNumber(CString *self, MSLong n, MSLanguage language);

// MCSCreate car retourne un CString. MSCreateString est défini dans MSString.h
#define MCSCreate(S) ({ \
  char *__x__= (S); __x__?CCreateStringWithBytes(NSUTF8StringEncoding, __x__, strlen(__x__)):CCreateString(0);})
#define MSSAdd(       X, Y) CStringAppendString((CString*)(X), Y)
#define MSSAddUnichar(X, Y) CStringAppendCharacter((CString*)(X), Y)
#define MSSLength(    X   ) CStringLength((const CString*)(X))
#define MSSIndex(     X, Y) (((CString*)(X))->buf[(Y)])

#endif

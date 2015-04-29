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

struct CStringStruct {
  MSCORE_NSOBJECT_ATTRIBUTES
  CGrowFlags flags;
  unichar*   buf;
  NSUInteger size;
  NSUInteger length;};

MSCoreExtern void           CStringFreeInside(id self); // for MSArray dealloc
MSCoreExtern BOOL           CStringIsEqual(id self, id other);
MSCoreExtern NSUInteger     CStringHash(id self, unsigned depth);
MSCoreExtern id             CStringCopy(id self);
MSCoreExtern const CString* CStringRetainedDescription(id self);
//  Warning: the copy follows the options of self: if objects are not
//  retained in self, they are not retained in the copy. If nilItems are
//  allowed in self, they are also allowed in the copy.

MSCoreExtern id CStringInitCopyWithMutability(CString *self, const CString *copied, BOOL isMutable);

MSCoreExtern BOOL CStringEquals           (const CString *s1, const CString *s2);
MSCoreExtern BOOL CStringInsensitiveEquals(const CString *s1, const CString *s2);

MSCoreExtern CString *CCreateString(NSUInteger capacity);
MSCoreExtern CString *CCreateStringWithBytes(NSStringEncoding encoding, const void *s, NSUInteger length);
// TODO avec no free comme buffer
// MSCoreExtern CString *CCreateStringWithUTF8String(const char *s);
MSCoreExtern CString *CCreateStringWithSES(SES ses);

MSCoreExtern void CStringGrow(CString *self, NSUInteger n);
MSCoreExtern void CStringAdjustSize(CString *self);

MSCoreExtern NSUInteger CStringLength(const CString *self);
MSCoreExtern unichar    CStringCharacterAtIndex(const CString *self, NSUInteger i);
MSCoreExtern NSUInteger CStringIndexOfCharacter(const CString *self, unichar c);
MSCoreExtern SES        CStringSES(const CString *self);


MSCoreExtern void CStringAppendCharacter(CString *self, unichar c);
MSCoreExtern void CStringAppendCharacterSuite(CString *self, unichar c, NSUInteger nb);
MSCoreExtern void CStringAppendBytes(CString *self, NSStringEncoding encoding, const void *s, NSUInteger length);
MSCoreExtern void CStringAppendSES(CString *self, SES ses);
MSCoreExtern void CStringAppendString(CString *self, const CString *s);

// utf8Fmt est une UTF8String (null terminated)
MSCoreExtern void CStringAppendFormat(CString *self, const char *utf8Fmt, ...);
MSCoreExtern void CStringAppendFormatv(CString *self, const char *utf8Fmt, va_list vp);
MSCoreExtern void CStringReplaceInRangeWithSES(CString *self, NSRange range, SES ses);

// TODO: Not reviewed, not tested.
// this functions work only for ANSI, Mac roman, NextStep, ISO Latin 1, UTF8 and ASCII as supposed encoding NOT TESTED
MSCoreExtern BOOL CStringAppendSupposedEncodingBytes(CString *self, const void *bytes, NSUInteger length, NSStringEncoding suposedEncoding, NSStringEncoding *foundEncodingPointer);
// if you don't know what encoding you've got from your internet source, try UTF8 as supposed encoding
MSCoreExtern BOOL CStringAppendInternetBytes(CString *self, const void *bytes, NSUInteger len, NSStringEncoding suposedEncoding, NSStringEncoding *foundEncodingPointer);
// same remark. this function decodes URL encoding scheme in the supposed encoding
MSCoreExtern BOOL CStringAppendURLBytes(CString *self, const void *bytes, NSUInteger len, NSStringEncoding suposedEncoding, NSStringEncoding *foundEncodingPointer);

//MSCoreExtern BOOL CStringAppendTimeInterval(CString *self, MSTimeInterval interval, const char *utf8StringFormat, MSLanguage language);

MSCoreExtern BOOL CStringAppendTextNumber(CString *self, MSLong n, MSLanguage language);
MSCoreExtern MSUInt CStringSizeOfCharacterForEncoding(NSStringEncoding srcEncoding);

// CSCreate car retourne un CString. MSCreateString est défini dans MSString.h
#define CSCreate(S) ({ \
  char *__x__= (S); __x__?CCreateStringWithBytes(NSUTF8StringEncoding, __x__, strlen(__x__)):CCreateString(0);})

#endif

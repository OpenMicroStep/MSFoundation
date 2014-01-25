/*   MSCUnicodeBuffer.c
 
 This file is is a part of the MicroStep Framework.
 
 Copyright Herve MALAINGRE & Eric BARADAT (1996)
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
#include "MSCoreUnichar_Private.h"

#ifdef MSCORE_STANDALONE
//#include "_MSCorePrivate.h"

void CUnicodeBufferFree(id self)
{
  if (self) {
    if (((CUnicodeBuffer*)self)->buf)
      MSFree(((CUnicodeBuffer *)self)->buf, "CUnicodeBufferFree() [memory]");
    MSFree(self, "CUnicodeBufferFree() [self]");}
}

id  CUnicodeBufferCopy(id self)
{
  if (self) {
    CUnicodeBuffer *newObject= (CUnicodeBuffer*)MSCreateObjectWithClassIndex(CUnicodeBufferClassIndex);
    if (newObject) {
      CUnicodeBufferAppendUnicodeBuffer(newObject, (const CUnicodeBuffer*)self);}
    return (id)newObject;}
  return nil;
}

#define _CHashCharactersLimit 96

#define HashNextFourUniChars(accessStart, accessEnd, pointer) \
{result= result * 67503105 + (accessStart 0 accessEnd) * 16974593  + (accessStart 1 accessEnd) * 66049  + (accessStart 2 accessEnd) * 257 + (accessStart 3 accessEnd); pointer += 4;}

#define HashNextUniChar(accessStart, accessEnd, pointer) \
{result= result * 257 + (accessStart 0 accessEnd); pointer++;}

static inline MSUInt _CHashCharacters(const unichar *uContents, NSUInteger len) {
  MSUInt result = (MSUInt)len;
  if (len <= _CHashCharactersLimit) {
    const unichar *end4 = uContents + (len & (NSUInteger)~3);
    const unichar *end = uContents + len;
    while (uContents < end4) HashNextFourUniChars(uContents[, ], uContents);   // First count in fours
    while (uContents < end) HashNextUniChar(uContents[, ], uContents);    // Then for the last <4 chars, count in ones...
  } else {
    const unichar *contents, *end;
    contents = uContents;
    end = contents + 32;
    while (contents < end) HashNextFourUniChars(contents[, ], contents);
    contents = uContents + (len >> 1) - 16;
    end = contents + 32;
    while (contents < end) HashNextFourUniChars(contents[, ], contents);
    end = uContents + len;
    contents = end - 32;
    while (contents < end) HashNextFourUniChars(contents[, ], contents);
  }
  return result + (result << (len & 31));
}

/* for unicode buffers, for now we use the same hashing algorithm has in CoreFoundation */
NSUInteger CUnicodeBufferHash(id self, unsigned depth)
{
  depth= 0; // Unused
  return self && ((CUnicodeBuffer *)self)->length ? (NSUInteger)_CHashCharacters(((CUnicodeBuffer *)self)->buf, ((CUnicodeBuffer *)self)->length) : 0;
}

BOOL CUnicodeBufferIsEqual(id self, id other)
{
  if (self == other) { return YES; };
  return  self && other &&
  ((CUnicodeBuffer *)self)->isa == ((CUnicodeBuffer *)other)->isa &&
  CUnicodeBufferEquals(((CUnicodeBuffer *)self), ((CUnicodeBuffer *)other)) ? YES : NO;
}

#else
//#import "_MSFoundationCorePrivate.h"
//#import "_MSCoreUnicharPrivate.h"
#endif




static inline NSUInteger _addNonASCIIByte(CUnicodeBuffer *self,
                                          NSUInteger initialLen,
                                          MSByte c, NSUInteger pos,
                                          NSUInteger len,
                                          NSStringEncoding worseEncoding,
                                          BOOL tryISOLatinAfterUTF8,
                                          unichar *up,
                                          NSUInteger *sequenceLen,
                                          NSUInteger *sequenceIndex,
                                          NSStringEncoding *encoding)
{
  switch (*encoding) {
    case NSMacOSRomanStringEncoding:
      self->buf[self->length++] = __MSMacRomanToUnicode[c];
      pos ++;
      break;
    case NSNEXTSTEPStringEncoding:
      // we should never be here, but it's for the fun
      self->buf[self->length++] = __MSNextstepToUnicode[c];
      pos ++;
      break;
    case NSUTF8StringEncoding:{
      if (*sequenceLen == 0) {
        // we initialize a new UTF8 sequence
        unsigned slen = 0;
        *up = (unichar)c;
        while (c & 0x80) {
          c = (MSByte)(c << 1);
          slen ++;
        }
        if (slen < 2 || slen > 6 || pos+slen > len) {
          // it's not an UTF8 sequence
          self->length = initialLen; // we go back to initial buffer state
          *encoding = (!tryISOLatinAfterUTF8 || *up < 0xa0 ? worseEncoding : NSISOLatin1StringEncoding);
          *sequenceLen = 0;
          *sequenceIndex = 0;
          *up = 0;
          pos = 0;
        }
        else {
          *sequenceLen = slen;
          *sequenceIndex = 1;
          pos ++;
        }
      }
      else if (c <= 0XBF) {
        unsigned int u = *up;
        u = (u << 6) | (c & 0x3f);
        *sequenceIndex = *sequenceIndex + 1;
        if (*sequenceIndex == *sequenceLen) {
          u = u & ~(0xffffffff << ((5 * (*sequenceLen)) + 1));
          *sequenceLen = 0;
          *sequenceIndex = 0;
          *up = 0;
          if (((u >= 0xd800) && (u <= 0xdfff)) || (u > 0x10ffff)) {
            self->length = initialLen; // we go back to initial buffer state
            *encoding = (!tryISOLatinAfterUTF8 || c < 0xa0 ? worseEncoding : NSISOLatin1StringEncoding);
            pos = 0;
          }
          else if (u < 0x10000) {
            // a complete unicode character
            self->buf[self->length++] = (unichar)u;
            pos ++;
          }
          else {
            // we need to add two chars
            unichar ul, uh;
            u -= 0x10000;
            ul = u & 0x3ff;
            uh = (u >> 10) & 0x3ff;
            self->buf[self->length++] = uh + 0xd800; // first character added
            self->buf[self->length++] = ul + 0xdc00; // second
            pos ++;
          }
        }
        else {
          *up = (unichar)u;
          pos ++;
        }
      }
      else {
        // NO UTF8 here
        self->length = initialLen; // we go back to initial buffer state
        *encoding = worseEncoding;
        *sequenceLen = 0;
        *sequenceIndex = 0;
        *up = 0;
        pos = 0;
      }
      break;
    }
    case NSISOLatin1StringEncoding:{
      if (c < 0xa0) {
        // NO ISO LATIN HERE
        self->length = initialLen; // we go back to initial buffer state
        *encoding = worseEncoding;
        *sequenceLen = 0;
        *sequenceIndex = 0;
        *up = 0;
        pos = 0;
      }
      else {
        self->buf[self->length++] = (unichar)c; // ISO LATIN = UNICODE FIRST PAGE
        pos ++;
      }
      break;
    }
    case NSISOLatin2StringEncoding:{
      if (c < 0xa0) {
        // NO ISO LATIN HERE
        self->length = initialLen; // we go back to initial buffer state
        *encoding = worseEncoding;
        *sequenceLen = 0;
        *sequenceIndex = 0;
        *up = 0;
        pos = 0;
      }
      else {
        self->buf[self->length++] = __MSIsoLatin2ToUnicode[c];
        pos ++;
      }
      break;
    }
    case NSWindowsCP1252StringEncoding:
      self->buf[self->length++] = __MSAnsiToUnicode[c];
      pos ++;
      break;
    case NSWindowsCP1250StringEncoding:
      // we should never be here, but it's for the fun
      self->buf[self->length++] = __MSWindows1250ToUnicode[c];
      pos ++;
      break;
    case NSWindowsCP1251StringEncoding:
      // we should never be here, but it's for the fun
      self->buf[self->length++] = __MSWindows1251ToUnicode[c];
      pos ++;
      break;
    case NSWindowsCP1253StringEncoding:
      // we should never be here, but it's for the fun
      self->buf[self->length++] = __MSWindows1253ToUnicode[c];
      pos ++;
      break;
    case NSWindowsCP1254StringEncoding:
      // we should never be here, but it's for the fun
      self->buf[self->length++] = __MSWindows1254ToUnicode[c];
      pos ++;
      break;
    case NSSymbolStringEncoding:
      // we should never be here, but it's for the fun
      self->buf[self->length++] = __MSAdobeSymbolToUnicode[c];
      pos ++;
      break;
    case NSDOSStringEncoding:
      // we should never be here, but it's for the fun
      self->buf[self->length++] = __MSDOSToUnicode[c];
      pos ++;
      break;
      
    case NSASCIIStringEncoding:
    default:
      // if ASCII, back to worse immediatly
      // if not, well, that should not be...
      self->length = initialLen; // we go back to initial buffer state
      *encoding = worseEncoding;
      *sequenceLen = 0;
      *sequenceIndex = 0;
      *up = 0;
      pos =  NSNotFound;
      break;
  }
  return pos;
}


BOOL CUnicodeBufferAppendUTF8Bytes(CUnicodeBuffer *self, const void *bytes, NSUInteger len)
{
  if (self && bytes && len) {
    MSByte c, *s = (MSByte *)bytes;
    unichar uc = 0;
    NSUInteger i = 0, initialLen = self->length;
    NSUInteger sequenceLen = 0, sequenceIndex = 0;
    NSStringEncoding encoding = NSUTF8StringEncoding;
    
    
    if (self->length + len > self->size && !CUnicodeBufferGrow(self, len)) return NO; // we (hope) know that the length(utf8) <= length(unicode equivalent)
    
    while (i < len) {
      c = s[i];
      if (c > 0x7f) {
        i = _addNonASCIIByte(self, initialLen, c, i, len, NSASCIIStringEncoding, NO, &uc, &sequenceLen, &sequenceIndex, &encoding);
        if (encoding != NSUTF8StringEncoding) {
          return NO;
        }
      }
      else {
        self->buf[self->length++] = (unichar)c;
        i++;
      }
    }
    if (sequenceLen > 0) {
      self->length = initialLen; // we go back to initial buffer state
      return NO;
    }
    
  }
  return YES;
}

BOOL CUnicodeBufferAppendBytesWithEncoding(CUnicodeBuffer *self, const void *bytes, NSUInteger len, NSStringEncoding encoding)
{
  switch (encoding) {
    case NSUTF8StringEncoding:    return CUnicodeBufferAppendUTF8Bytes(self, bytes, len);
    case NSUnicodeStringEncoding:  return CUnicodeBufferAppendCharacters(self, (const unichar *)bytes, len);
    default:{
      SES ses = MSMakeSESWithBytes(bytes, len, encoding);
      return SESOK(ses) ? CUnicodeBufferAppendWithSES(self, ses, bytes) : NO;
    }
  }
}

#define NO_CONVERSION    0x0000
#define CONV_URI_MODE    0x0001

#define NORMAL_STATE    0
#define ESCAPE_START_STATE  1
#define ESCAPE_END_STATE  2

#define _XISHEXA(C)  (((C) >= '0' && (C) <= '9') || ((C) >= 'A' && (C) <= 'F') || ((C) >= 'a' && (C) <= 'f'))
#define _XHEXAVAL(C) ((C) >= 'a' ? (C) - 'a' + 10 : ((C) >= 'A' ? (C) - 'A' + 10 : (C) - '0'))

static BOOL _CUBAppendUnknownEncodingBytes(CUnicodeBuffer *self, const void *bytes, NSUInteger len, MSUShort cmode, NSStringEncoding encoding, BOOL tryIsoLatin, NSStringEncoding *foundEncodingPointer)
{
  if (self && bytes && len) {
    MSByte c, escaped = 0, *s = (MSByte *)bytes;
    unsigned state = NORMAL_STATE;
    unichar uc = 0;
    NSUInteger i = 0, initialLen = self->length;
    NSUInteger sequenceLen = 0, sequenceIndex = 0;
    NSStringEncoding worse = MSCurrentCStringEncoding();
    
    if (encoding != NSUTF8StringEncoding &&
        encoding != NSWindowsCP1252StringEncoding &&
        encoding != NSISOLatin1StringEncoding &&
        encoding != NSMacOSRomanStringEncoding &&
        encoding != NSNEXTSTEPStringEncoding &&
        encoding != NSASCIIStringEncoding) { return NO; }
    
    if (encoding == worse ||
        worse == NSShiftJISStringEncoding ||
        worse == NSISO2022JPStringEncoding ||
        worse == NSNonLossyASCIIStringEncoding ||
        worse == NSJapaneseEUCStringEncoding ||
        worse == NSSymbolStringEncoding ||
        worse == NSISOLatin2StringEncoding ||
        worse == NSWindowsCP1251StringEncoding ||
        worse == NSWindowsCP1253StringEncoding ||
        worse == NSWindowsCP1254StringEncoding ||
        worse == NSWindowsCP1250StringEncoding ||
        worse > NSMacOSRomanStringEncoding) {
      worse = NSUnicodeStringEncoding;
    }
    
    if (self->length + len > self->size && !CUnicodeBufferGrow(self, len)) return NO; // we (hope) know that the length(8byte encoding) <= length(unicode equivalent)
    
  restart:
    if (cmode == NO_CONVERSION) {
      while (i < len) {
        c = s[i];
        if (c > 0x7f) {
          i = _addNonASCIIByte(self, initialLen, c, i, len, worse, tryIsoLatin, &uc, &sequenceLen, &sequenceIndex, &encoding);
          if (encoding == NSUnicodeStringEncoding) return NO;
        }
        else {
          self->buf[self->length++] = (unichar)c;
          i++;
        }
      }
    }
    else {
      while (i < len) {
        c = s[i];
        switch (state) {
          case NORMAL_STATE:{
            if (c == '%' && (cmode & CONV_URI_MODE)) {
              state = ESCAPE_START_STATE;
              i ++;
            }
            else if (c > 0x7f) {
              i = _addNonASCIIByte(self, initialLen, c, i, len, worse, tryIsoLatin, &uc, &sequenceLen, &sequenceIndex, &encoding);
              if (encoding == NSUnicodeStringEncoding) return NO;
            }
            else if (cmode & CONV_URI_MODE) {
              self->buf[self->length++] = (unichar)(c == '+' ? ' ' : c);
              i ++;
            }
            else {
              self->buf[self->length++] = (unichar)c;
              i++;
            }
            break;
          }
          case ESCAPE_START_STATE:{
            if (!_XISHEXA(c)) { self->length = initialLen; return NO; }
            escaped = (MSByte)(_XHEXAVAL(c) << 4);
            state = ESCAPE_END_STATE;
            i ++;
            break;
          }
          case ESCAPE_END_STATE:{
            if (!_XISHEXA(c)) { self->length = initialLen; return NO; }
            escaped |= _XHEXAVAL(c);
            if (escaped < 0x80) {
              self->buf[self->length++] = escaped;
              i ++;
            }
            else {
              i = _addNonASCIIByte(self, initialLen, escaped, i, len, worse, tryIsoLatin, &uc, &sequenceLen, &sequenceIndex, &encoding);
              if (encoding == NSUnicodeStringEncoding) return NO;
            }
            state = NORMAL_STATE;
            break;
          }
        }
      }
    }
    
    if (sequenceLen > 0 && encoding != NSUnicodeStringEncoding) {
      self->length = initialLen;
      encoding = NSISOLatin1StringEncoding;
      i = 0;
      sequenceLen = 0;
      sequenceIndex = 0;
      uc = 0;
      goto restart;
    }
    if (state != NORMAL_STATE) { self->length = initialLen; return NO; }
    
  }
  if (foundEncodingPointer) *foundEncodingPointer = encoding;
  
  return YES;
}

BOOL CUnicodeBufferAppendInternetBytes(CUnicodeBuffer *self, const void *bytes, NSUInteger len, NSStringEncoding encoding, NSStringEncoding *foundEncodingPointer)
{ return _CUBAppendUnknownEncodingBytes(self, bytes, len, NO_CONVERSION, encoding, YES, foundEncodingPointer); }

BOOL CUnicodeBufferAppendSupposedEncodingBytes(CUnicodeBuffer *self, const void *bytes, NSUInteger len, NSStringEncoding encoding, NSStringEncoding *foundEncodingPointer)
{ return _CUBAppendUnknownEncodingBytes(self, bytes, len, NO_CONVERSION, encoding, NO, foundEncodingPointer); }

BOOL CUnicodeBufferAppendURLBytes(CUnicodeBuffer *self, const void *bytes, NSUInteger len, NSStringEncoding encoding, NSStringEncoding *foundEncodingPointer)
{ return _CUBAppendUnknownEncodingBytes(self, bytes, len, CONV_URI_MODE, encoding, NO, foundEncodingPointer); }

typedef BOOL (*_CUBNumberAppender)(CUnicodeBuffer *self, MSLong n);

#warning Re-enable MAPM
static BOOL _snd(CUnicodeBuffer *self, MSLong n)
{
  BOOL ret= NO;
  n= 0; // TODO: n is UNUSED, Re-enable MAPM
  self= nil;
  /*
   // a very slow method, I know, but I don't wand to use sprintf() or snprintf() with "%lld" since the result in quite uncertain
   char buf[128];
   M_APM bignum = m_apm_new();
   m_apm_to_integer_string(buf, bignum);
   ret = CUnicodeBufferAppendISOLatin1CString(self, buf);
   m_apm_free(bignum);
   */
  return ret;
}

static char *__french100[100] = {
  "", "un", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf",
  "dix", "onze", "douze", "treize", "quatorze", "quinze", "seize", "dix-sept", "dix-huit", "dix-neuf",
  "vingt", "vingt et un", "vingt-deux", "vingt-trois", "vingt-quatre", "vingt-cinq", "vingt-six", "vingt-sept", "vingt-huit", "vingt-neuf",
  "trente", "trente et un", "trente-deux", "trente-trois", "trente-quatre", "trente-cinq", "trente-six", "trente-sept", "trente-huit", "trente-neuf",
  "quarante", "quarante et un", "quarante-deux", "quarante-trois", "quarante-quatre", "quarante-cinq", "quarante-six", "quarante-sept", "quarante-huit", "quarante-neuf",
  "cinquante", "cinquante et un", "cinquante-deux", "cinquante-trois", "cinquante-quatre", "cinquante-cinq", "cinquante-six", "cinquante-sept", "cinquante-huit", "cinquante-neuf",
  "soixante", "soixante et un", "soixante-deux", "soixante-trois", "soixante-quatre", "soixante-cinq", "soixante-six", "soixante-sept", "soixante-huit", "soixante-neuf",
  "soixante-dix", "soixante et onze", "soixante-douze", "soixante-treize", "soixante-quatorze", "soixante-quinze", "soixante-seize", "soixante-dix-sept", "soixante-dix-huit", "soixante-dix-neuf",
  "quatre-vingts", "quatre-vingt-un", "quatre-vingt-deux", "quatre-vingt-trois", "quatre-vingt-quatre", "quatre-vingt-cinq", "quatre-vingt-six", "quatre-vingt-sept", "quatre-vingt-huit", "quatre-vingt-neuf",
  "quatre-vingt-dix", "quatre-vingt-onze", "quatre-vingt-douze", "quatre-vingt-treize", "quatre-vingt-quatorze", "quatre-vingt-quinze", "quatre-vingt-seize", "quatre-vingt-dix-sept", "quatre-vingt-dix-huit", "quatre-vingt-dix-neuf"
};

static inline BOOL _frenchNumber999(CUnicodeBuffer *self, NSUInteger originalLength, unsigned number, BOOL invariable)
{
  unsigned centaines = number / 100;
  unsigned reste = number % 100;
  if (centaines > 0) {
    if (centaines > 1) {
      if (!CUnicodeBufferAppendISOLatin1CString(self, __french100[centaines])) { self->length = originalLength; return NO; };
      if (!CUnicodeBufferAppendISOLatin1CString(self, (reste > 0 ? " cent " : (invariable ? " cent" : " cents")))) { self->length = originalLength; return NO; }
    }
    else {
      if (!CUnicodeBufferAppendISOLatin1CString(self, (reste > 0 ? "cent " : "cent"))) { self->length = originalLength; return NO; }
    }
  }
  if (reste && !CUnicodeBufferAppendISOLatin1CString(self, __french100[reste])) { self->length = originalLength; return NO; };
  return YES;
}


static BOOL CUnicodeBufferAppendFrenchNumber(CUnicodeBuffer *self, MSLong n)
{
  MSULong number = (MSULong)ABS(n);
  MSULong milliers, millions, milliards = number / 1000000000;
  NSUInteger originalLength = self->length;
  BOOL needsSpace = (originalLength == 0 || CUnicharIsSpace(self->buf[originalLength-1]) ? NO : YES);
  
  if (n == 0) {
    if (needsSpace) { if (!CUnicodeBufferAppendCharacter(self, 0x0020)) { self->length = originalLength; return NO; }; }
    if (!CUnicodeBufferAppendCharacter(self, 0x007a) || /* oh yeah, that's z&eacute;ro in french */
        !CUnicodeBufferAppendCharacter(self, 0x00e9) ||
        !CUnicodeBufferAppendCharacter(self, 0x0072) ||
        !CUnicodeBufferAppendCharacter(self, 0x006f)) { self->length = originalLength; return NO; }
    return YES;
  }
  if (number > 999999999999ULL) {
    return _snd(self, n);
  }
  if (n < 0) {
    if (needsSpace) { if (!CUnicodeBufferAppendCharacter(self, 0x0020)) { self->length = originalLength; return NO; }; }
    if (!CUnicodeBufferAppendISOLatin1CString(self, "moins")) { self->length = originalLength; return NO; }
    needsSpace = YES;
  }
  if (milliards) {
    number -= milliards * 1000000000;
    if (needsSpace) { if (!CUnicodeBufferAppendCharacter(self, 0x0020)) { self->length = originalLength; return NO; }; }
    if (!_frenchNumber999(self, originalLength, (unsigned)milliards, NO)) {  return NO; }
    if (!CUnicodeBufferAppendISOLatin1CString(self, (milliards > 1 ? " milliards" : " milliard"))) { self->length = originalLength; return NO; }
    needsSpace = YES;
  }
  millions = number / 1000000;
  if (millions) {
    number -= millions * 1000000;
    if (needsSpace) { if (!CUnicodeBufferAppendCharacter(self, 0x0020)) { self->length = originalLength; return NO; }; }
    if (!_frenchNumber999(self, originalLength, (unsigned)millions, NO)) {  return NO; }
    if (!CUnicodeBufferAppendISOLatin1CString(self, (millions > 1 ? " millions" : " millions"))) { self->length = originalLength; return NO; }
    needsSpace = YES;
  }
  milliers = number / 1000;
  if (milliers) {
    number -= milliers * 1000;
    if (milliers == 1 && number < 700) {
      number += 1000; // on le fait sous la forme treize-cents...
    }
    else {
      if (needsSpace) { if (!CUnicodeBufferAppendCharacter(self, 0x0020)) { self->length = originalLength; return NO; }; }
      if (milliers > 1 && !_frenchNumber999(self, originalLength, (unsigned)milliers, YES)) {  return NO; }
      if (!CUnicodeBufferAppendISOLatin1CString(self, " mille")) { self->length = originalLength; return NO; }
      needsSpace = YES;
    }
  }
  if (number) {
    if (needsSpace) { if (!CUnicodeBufferAppendCharacter(self, 0x0020)) { self->length = originalLength; return NO; }; }
    if (!_frenchNumber999(self, originalLength, (unsigned)number, NO)) {  return NO; }
  }
  return YES;
}

static char *__english100[100] = {
  "", "one", "two", "three", "four", "five", "six", "seven", "height", "nine",
  "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "heighteen", "nineteen",
  "twenty", "twenty-one", "twenty-two", "twenty-three", "twenty-four", "twenty-five", "twenty-six", "twenty-seven", "twenty-height", "twenty-nine",
  "thirty", "thirty-one", "thirty-two", "thirty-three", "thirty-four", "thirty-five", "thirty-six", "thirty-seven", "thirty-height", "thirty-nine",
  "fourty", "fourty-one", "fourty-two", "fourty-three", "fourty-four", "fourty-five", "fourty-six", "fourty-seven", "fourty-height", "fourty-nine",
  "fifty", "fifty-one", "fifty-two", "fifty-three", "fifty-four", "fifty-five", "fifty-six", "fifty-seven", "fifty-height", "fifty-nine",
  "sixty", "sixty-one", "sixty-two", "sixty-three", "sixty-four", "sixty-five", "sixty-six", "sixty-seven", "sixty-height", "sixty-nine",
  "seventy", "seventy-one", "seventy-two", "seventy-three", "seventy-four", "seventy-five", "seventy-six", "seventy-seven", "seventy-height", "seventy-nine",
  "heighty", "heighty-one", "heighty-two", "heighty-three", "heighty-four", "heighty-five", "heighty-six", "heighty-seven", "heighty-height", "heighty-nine"
  "ninety", "ninety-one", "ninety-two", "ninety-three", "ninety-four", "ninety-five", "ninety-six", "ninety-seven", "ninety-height", "ninety-nine"
};

static inline BOOL _englishNumber999(CUnicodeBuffer *self, NSUInteger originalLength, unsigned number)
{
  unsigned centaines = number / 100;
  unsigned reste = number % 100;
  if (centaines > 0) {
    if (!CUnicodeBufferAppendISOLatin1CString(self, __english100[centaines])) { self->length = originalLength; return NO; }
    if (!CUnicodeBufferAppendISOLatin1CString(self, (reste > 0 ? "hundred and " : "hundred"))) { self->length = originalLength; return NO; }
  }
  if (reste && !CUnicodeBufferAppendISOLatin1CString(self, __english100[reste])) { self->length = originalLength; return NO; }
  return YES;
}

static BOOL CUnicodeBufferAppendEnglishNumber(CUnicodeBuffer *self, MSLong n)
{
  MSULong number = (MSULong)ABS(n);
  MSULong initialNumber = number;
  MSULong milliers, millions, milliards = number / 1000000000;
  NSUInteger originalLength = self->length;
  BOOL needsSpace = (originalLength == 0 || CUnicharIsSpace(self->buf[originalLength-1]) ? NO : YES);
  
  if (n == 0) {
    if (needsSpace) { if (!CUnicodeBufferAppendCharacter(self, 0x0020)) { self->length = originalLength; return NO; }; }
    if (!CUnicodeBufferAppendISOLatin1CString(self, "zero")) { self->length = originalLength; return NO; }
    return YES;
  }
  if (number > 999999999999ULL) {
    return _snd(self, n);
  }
  if (n < 0) {
    if (needsSpace) { if (!CUnicodeBufferAppendCharacter(self, 0x0020)) { self->length = originalLength; return NO; }; }
    if (!CUnicodeBufferAppendISOLatin1CString(self, "minus")) { self->length = originalLength; return NO; }
    needsSpace = YES;
  }
  if (milliards) {
    number -= milliards * 1000000000;
    if (needsSpace) { if (!CUnicodeBufferAppendCharacter(self, 0x0020)) { self->length = originalLength; return NO; }; }
    if (!_englishNumber999(self, originalLength, (unsigned)milliards)) { return NO; }
    if (!CUnicodeBufferAppendISOLatin1CString(self, " billion")) { self->length = originalLength; return NO; }
    needsSpace = YES;
  }
  millions = number / 1000000;
  if (millions) {
    number -= millions * 1000000;
    if (needsSpace) { if (!CUnicodeBufferAppendCharacter(self, 0x0020)) { self->length = originalLength; return NO; }; }
    if (!_englishNumber999(self, originalLength, (unsigned)millions)) { return NO; }
    if (!CUnicodeBufferAppendISOLatin1CString(self, " million")) { self->length = originalLength; return NO; }
    needsSpace = YES;
  }
  milliers = number / 1000;
  if (milliers) {
    number -= milliers * 1000;
    if (needsSpace) { if (!CUnicodeBufferAppendCharacter(self, 0x0020)) { self->length = originalLength; return NO; }; }
    if (!_englishNumber999(self, originalLength, (unsigned)milliers)) { return NO; }
    if (!CUnicodeBufferAppendISOLatin1CString(self, " thousand")) { self->length = originalLength; return NO; }
    needsSpace = YES;
  }
  if (number) {
    if (needsSpace) {
      if (number < 100 && initialNumber > 100 && !CUnicodeBufferAppendISOLatin1CString(self, " and ")) { self->length = originalLength; return NO; }
      else if (!CUnicodeBufferAppendCharacter(self, 0x0020)) { self->length = originalLength; return NO; }
    }
    if (!_englishNumber999(self, originalLength, (unsigned)number)) { return NO; }
  }
  return YES;
}


static _CUBNumberAppender __numberAppenders[37] =
{
  _snd, // MSRussian
  _snd, // -- 1
  _snd, // -- 2
  _snd, // MSPortuguese
  _snd, // -- 4
  _snd, // MSItalian =*=*=*=*=*=*=*=*=*=*=                               DEFINED
  _snd, // MSGreek
  _snd, // MSDanish
  _snd, // -- 8
  _snd, // -- 9
  _snd, // -- 10
  _snd, // -- MSTurkish
  _snd, // -- 12
  _snd, // -- 13
  _snd, // MSDutch
  _snd, // MSNorwegian
  _snd, // MSRoman ==> should we use the roman representation here ?
  CUnicodeBufferAppendFrenchNumber, // MSFrench =*=*=*=*=*=*=*=*=*=*=    DEFINED
  _snd, // -- 18
  _snd, // -- 19
  _snd, // MSSpanish =*=*=*=*=*=*=*=*=*=*=                               DEFINED
  _snd, // MSArmenian
  _snd, // -- 22
  _snd, // MSArabic
  _snd, // -- 24
  _snd, // -- 25
  _snd, // MSGerman =*=*=*=*=*=*=*=*=*=*=                                DEFINED
  _snd, // MSBulgarian
  _snd, // -- 28
  CUnicodeBufferAppendEnglishNumber, // MSEnglish =*=*=*=*=*=*=*=*=*=*=  DEFINED
  _snd, // MSSerbian
  _snd, // -- 31
  _snd, // MSCzech
  _snd, // MSPolish
  _snd, // MSCroatian
  _snd, // -- 35
  _snd  // -- 36
};

BOOL CUnicodeBufferAppendTextNumber(CUnicodeBuffer *self, MSLong n, MSLanguage language)
{ return (__numberAppenders[(int)language])(self, n); }


/************************** TO DO IN THIS FILE  ****************
 (1)  be sure that the length of an UTF8String is <= of the length
 of its unicode (utf16) equivalent...
 (2)  german, italian and spanish number in text transformation
 (3)  recognising NSSymbolStringEncoding, NSISOLatin2StringEncoding,
 NSWindowsCP1251StringEncoding,  NSWindowsCP1253StringEncoding,
 NSWindowsCP1254StringEncoding, NSWindowsCP1250StringEncoding
 in CUnicodeBufferAppendUnknownEncodingBytes()
 
 *************************************************************/

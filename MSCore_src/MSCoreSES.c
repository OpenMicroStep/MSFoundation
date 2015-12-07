/* MSCoreSES.c

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

const SES MSInvalidSES= {
  .source=NULL,
  .chai=InvalidCHAI,
  .chaip=InvalidCHAI,
  .start=NSNotFound,
  .length=0,
  .encoding=0};

#pragma mark Encoding and Unicode

typedef struct _encodingStuffStruct {
  unichar *toUnicode; // 256
//unichar (*char2Unichar)(unsigned short); // to be removed ?
  CHAI chai;
  CHAI chaip;
  MSUInt chsize;
  }
_encodingStuff;

static _encodingStuff _encoding[];
static inline _encodingStuff *_encodingStuffForEncoding(NSStringEncoding encoding)
{
  if (0< encoding && encoding<=15)          return _encoding+encoding;
  else switch (encoding) {
    case NSISO2022JPStringEncoding:         return _encoding+16;
    case NSMacOSRomanStringEncoding:        return _encoding+17;
    case NSDOSStringEncoding:               return _encoding+18;
    case NSUTF16StringEncoding:             return _encoding+19;
    case NSUTF16BigEndianStringEncoding:    return _encoding+20;
    case NSUTF16LittleEndianStringEncoding: return _encoding+21;
    default:
      // we dont return a valid enumerator for NSUTF8StringEncoding, NSJapaneseEUCStringEncoding,
      // NSShiftJISStringEncoding and NSISO2022JPStringEncoding
      break;}
  return _encoding+0;
}
static inline unichar _aSimpleChaiN(const void *src, NSUInteger *pos, NSStringEncoding encoding)
// A chai for encoding with a table[256] transformation
  {
  unsigned char c= ((unsigned char*)src)[(*pos)++];
  return _encodingStuffForEncoding(encoding)->toUnicode[c];
  }

static inline unichar _aSimpleChaiP(const void *src, NSUInteger *pos, NSStringEncoding encoding)
// A chai for encoding with a table[256] transformation
  {
  unsigned char c= ((unsigned char*)src)[--(*pos)];
  return _encodingStuffForEncoding(encoding)->toUnicode[c];
  }

// TODO: à revoir pour les NSString -stringEnumeratorStructure
typedef unichar (*BasicCHAI)(const void *, NSUInteger);
unichar chaiN4BasicChai(BasicCHAI c, const void *src, NSUInteger *pos);
unichar chaiN4BasicChai(BasicCHAI c, const void *src, NSUInteger *pos)
{
  return c(src,(*pos)++);
}

static unichar __MSNextstepToUnicode   [256];
static unichar __MSAdobeSymbolToUnicode[256];
static unichar __MSIsoLatin2ToUnicode  [256];
static unichar __MSWindows1251ToUnicode[256];
static unichar __MSAnsiToUnicode       [256];
static unichar __MSWindows1253ToUnicode[256];
static unichar __MSWindows1254ToUnicode[256];
static unichar __MSWindows1250ToUnicode[256];
static unichar __MSMacRomanToUnicode   [256];
static unichar __MSDOSToUnicode        [256];

static unichar _asciiChaiN   (const void *src, NSUInteger *pos) {return (unichar)((char   *)src)[(*pos)++];}
static unichar _asciiChaiP   (const void *src, NSUInteger *pos) {return (unichar)((char   *)src)[--(*pos)];}
static unichar _unicodeChaiN (const void *src, NSUInteger *pos) {return (unichar)((unichar*)src)[(*pos)++];}
static unichar _unicodeChaiP (const void *src, NSUInteger *pos) {return (unichar)((unichar*)src)[--(*pos)];}
static unichar _nextstepChaiN(const void *src, NSUInteger *pos) {return _aSimpleChaiN(src,pos,NSNEXTSTEPStringEncoding     );}
static unichar _nextstepChaiP(const void *src, NSUInteger *pos) {return _aSimpleChaiP(src,pos,NSNEXTSTEPStringEncoding     );}
static unichar _symbolChaiN  (const void *src, NSUInteger *pos) {return _aSimpleChaiN(src,pos,NSSymbolStringEncoding       );}
static unichar _symbolChaiP  (const void *src, NSUInteger *pos) {return _aSimpleChaiP(src,pos,NSSymbolStringEncoding       );}
static unichar _latin2ChaiN  (const void *src, NSUInteger *pos) {return _aSimpleChaiN(src,pos,NSISOLatin2StringEncoding    );}
static unichar _latin2ChaiP  (const void *src, NSUInteger *pos) {return _aSimpleChaiP(src,pos,NSISOLatin2StringEncoding    );}
static unichar _w1251ChaiN   (const void *src, NSUInteger *pos) {return _aSimpleChaiN(src,pos,NSWindowsCP1251StringEncoding);}
static unichar _w1251ChaiP   (const void *src, NSUInteger *pos) {return _aSimpleChaiP(src,pos,NSWindowsCP1251StringEncoding);}
static unichar _ansiChaiN    (const void *src, NSUInteger *pos) {return _aSimpleChaiN(src,pos,NSWindowsCP1252StringEncoding);}
static unichar _ansiChaiP    (const void *src, NSUInteger *pos) {return _aSimpleChaiP(src,pos,NSWindowsCP1252StringEncoding);}
static unichar _w1253ChaiN   (const void *src, NSUInteger *pos) {return _aSimpleChaiN(src,pos,NSWindowsCP1253StringEncoding);}
static unichar _w1253ChaiP   (const void *src, NSUInteger *pos) {return _aSimpleChaiP(src,pos,NSWindowsCP1253StringEncoding);}
static unichar _w1254ChaiN   (const void *src, NSUInteger *pos) {return _aSimpleChaiN(src,pos,NSWindowsCP1254StringEncoding);}
static unichar _w1254ChaiP   (const void *src, NSUInteger *pos) {return _aSimpleChaiP(src,pos,NSWindowsCP1254StringEncoding);}
static unichar _w1250ChaiN   (const void *src, NSUInteger *pos) {return _aSimpleChaiN(src,pos,NSWindowsCP1250StringEncoding);}
static unichar _w1250ChaiP   (const void *src, NSUInteger *pos) {return _aSimpleChaiP(src,pos,NSWindowsCP1250StringEncoding);}
static unichar _macChaiN     (const void *src, NSUInteger *pos) {return _aSimpleChaiN(src,pos,NSMacOSRomanStringEncoding   );}
static unichar _macChaiP     (const void *src, NSUInteger *pos) {return _aSimpleChaiP(src,pos,NSMacOSRomanStringEncoding   );}
static unichar _dosChaiN     (const void *src, NSUInteger *pos) {return _aSimpleChaiN(src,pos,NSDOSStringEncoding          );}
static unichar _dosChaiP     (const void *src, NSUInteger *pos) {return _aSimpleChaiP(src,pos,NSDOSStringEncoding          );}
static unichar _bigChaiN     (const void *src, NSUInteger *pos) {return MSFromBig16   (((unichar*)src)[(*pos)++]);}
static unichar _bigChaiP     (const void *src, NSUInteger *pos) {return MSFromBig16   (((unichar*)src)[--(*pos)]);}
static unichar _littleChaiN  (const void *src, NSUInteger *pos) {return MSFromLittle16(((unichar*)src)[(*pos)++]);}
static unichar _littleChaiP  (const void *src, NSUInteger *pos) {return MSFromLittle16(((unichar*)src)[--(*pos)]);}

static _encodingStuff _encoding[]= {
  {NULL                    , InvalidCHAI   , InvalidCHAI   , sizeof(char)    }, //  0
  {NULL                    , _asciiChaiN   , _asciiChaiP   , sizeof(char)    }, //  1 NSASCIIStringEncoding=          1, // 0..127 only
  {__MSNextstepToUnicode   , _nextstepChaiN, _nextstepChaiP, sizeof(char)    }, //  2 NSNEXTSTEPStringEncoding=       2,
  {NULL                    , InvalidCHAI   , InvalidCHAI   , sizeof(char)    }, //  3 NSJapaneseEUCStringEncoding=    3,
  {NULL                    , utf8ChaiN     , utf8ChaiP     , sizeof(char)    }, //  4 NSUTF8StringEncoding=           4,
  {NULL                    , _asciiChaiN   , _asciiChaiP   , sizeof(char)    }, //  5 NSISOLatin1StringEncoding=      5,
  {__MSAdobeSymbolToUnicode, _symbolChaiN  , _symbolChaiP  , sizeof(char)    }, //  6 NSSymbolStringEncoding=         6,
  {NULL                    , _asciiChaiN   , _asciiChaiP   , sizeof(char)    }, //  7 NSNonLossyASCIIStringEncoding=  7,
  {NULL                    , InvalidCHAI   , InvalidCHAI   , sizeof(char)    }, //  8 NSShiftJISStringEncoding=       8, // kCFStringEncodingDOSJapanese
  {__MSIsoLatin2ToUnicode  , _latin2ChaiN  , _latin2ChaiP  , sizeof(char)    }, //  9 NSISOLatin2StringEncoding=      9,
  {NULL                    , _unicodeChaiN , _unicodeChaiP , sizeof(unichar) }, // 10 NSUnicodeStringEncoding=       10,
  {__MSWindows1251ToUnicode, _w1251ChaiN   , _w1251ChaiP   , sizeof(char)    }, // 11 NSWindowsCP1251StringEncoding= 11, // Cyrillic; same as AdobeStandardCyrillic
  {__MSAnsiToUnicode       , _ansiChaiN    , _ansiChaiP    , sizeof(char)    }, // 12 NSWindowsCP1252StringEncoding= 12, // WinLatin1
  {__MSWindows1253ToUnicode, _w1253ChaiN   , _w1253ChaiP   , sizeof(char)    }, // 13 NSWindowsCP1253StringEncoding= 13, // Greek
  {__MSWindows1254ToUnicode, _w1254ChaiN   , _w1254ChaiP   , sizeof(char)    }, // 14 NSWindowsCP1254StringEncoding= 14, // Turkish
  {__MSWindows1250ToUnicode, _w1250ChaiN   , _w1250ChaiP   , sizeof(char)    }, // 15 NSWindowsCP1250StringEncoding= 15, // WinLatin2

  {NULL                    , InvalidCHAI   , InvalidCHAI   , sizeof(char)    }, // 16 NSISO2022JPStringEncoding=     21, // ISO 2022 Japanese encoding for e-mail
  {__MSMacRomanToUnicode   , _macChaiN     , _macChaiP     , sizeof(char)    }, // 17 NSMacOSRomanStringEncoding=    30,
  {__MSDOSToUnicode        , _dosChaiN     , _dosChaiP     , sizeof(char)    }, // 18 NSDOSStringEncoding=           0x20000, // DOS: Added to NS...Encoding constants

  {NULL                    , InvalidCHAI   , InvalidCHAI   , sizeof(unichar) }, // 19 NSUTF16StringEncoding= NSUnicodeStringEncoding, // An alias for NSUnicodeStringEncoding

  {NULL                    , _bigChaiN     , _bigChaiP     , sizeof(unichar) }, // 20 NSUTF16BigEndianStringEncoding=    0x90000100,  // explicit endianness
  {NULL                    , _littleChaiN  , _littleChaiP  , sizeof(unichar) }  // 21 NSUTF16LittleEndianStringEncoding= 0x94000100,  // explicit endianness
};

/*
unichar CEncodingToUnicode(unsigned short c, NSStringEncoding encoding)
{
  unichar (*char2Unichar)(unsigned short)= _encodingStuffForEncoding(encoding)->char2Unichar;
  return char2Unichar ? char2Unichar(c) : 0;
}
unsigned short CUnicodeToEncoding(unichar u, NSStringEncoding encoding)
{
  return 0;
}
*/

MSUInt CStringSizeOfCharacterForEncoding(NSStringEncoding srcEncoding)
{
  return _encodingStuffForEncoding(srcEncoding)->chsize;
}

SES MSMakeSESWithSytes(const void *sytes, NSUInteger sytesLength, NSStringEncoding srcEncoding)
{
  _encodingStuff *s= _encodingStuffForEncoding(srcEncoding);
  return sytes && sytesLength && s->chai && s->chaip ? MSMakeSES(sytes, s->chai, s->chaip, 0, sytesLength, srcEncoding) : MSInvalidSES;
}

SES MSMakeSESWithBytes(const void *src, NSUInteger srcLength, NSStringEncoding srcEncoding)
{
  return MSMakeSESWithSytes(src, srcLength / CStringSizeOfCharacterForEncoding(srcEncoding), srcEncoding);
}

#pragma mark UTF8

unichar utf8ChaiN(const void *src, NSUInteger *pos)
// TODO: attention on ne vérifie pas un débordement éventuel du à une malformation
// Juste on s'arrête sur 0x00.
// Si pas de l'utf8, retourne 0.
// Ne prend en compte que jusqu'à 16 bits (si 4 octets, ie 17 à 21 bits, retourne 0 mais avance de 4.
  {
  unsigned char c, c1, c2;
  unichar u; int i;
//printf("A %lu %hhu\n",*pos,((unsigned char*)src)[*pos]);
  // 80: 1000 0000
  // C0: 1100 0000
  // E0: 1110 0000
  // F0: 1111 0000
  if ((c= ((unsigned char*)src)[(*pos)++]) < 0x80) u= (unichar)c;
  else if (c<0xe0) { // 110xxxxx 10xxxxxx
    if (c < 0xc0) u= 0;
    else {
      c1= ((unsigned char*)src)[(*pos)++];
      if (c1 < 0x80 || c1 >=0xc0) u= 0;
      else {
        u= (unichar)( ((unsigned)(c & 0x1f) << 6) | (unsigned)(c1 & 0x3f) );
//printf("B %hu\n",u);
        }}}
  else if (c<0xf0) { // 1110xxxx 10xxxxxx 10xxxxxx
    c1= ((unsigned char*)src)[(*pos)++];
    if (c1 < 0x80 || c1 >=0xc0) u= 0;
    else {
      c2= ((unsigned char*)src)[(*pos)++];
      if (c2 < 0x80 || c2 >=0xc0) u= 0;
      else {
        u= (unichar)( ((unsigned)(c & 0x0f) << 12) | ((unsigned)(c1 & 0x3f) << 6) | (unsigned)(c2 & 0x3f) );}}}
  else {
    for (i=0; c!=0x00 && i<3; i++) {
      c= ((unsigned char*)src)[(*pos)++];
      if (c < 0x80 || c >=0xc0) c= 0x00;}
    u= 0;}
//printf("C %hu\n",u);
  return u;
  }

unichar utf8ChaiP(const void *src, NSUInteger *pos)
{
  unichar u= 0; unsigned char c0, c1, c2;
  if ((c0= ((unsigned char*)src)[--(*pos)]) < 0x80 /* 1000 0000 */) { // 1 byte: 1 to 7 bits
    u= (unichar)c0;}
  else if (c0 < 0xc0) { // c0 is valid ((c0 & 0xC0) == 0x80)
    if ((c1= ((unsigned char*)src)[--(*pos)]) >= 0xc0 /* 1100 0000 */) { // 2 bytes: 8 to 11 bits
      if (c1 < 0xe0) { //c1 is valid ((c1 & 0xE0) == 0xc0)
        u= ( ((unichar)(c1 & 0x1F /* 0001 1111 */) << 6)
           | ((unichar)(c0 & 0x3F /* 0011 1111 */)     ));}}
    else if (c1 < 0xc0) { // c1 is valid ((c0 & 0xC0) == 0x80)
      if ((c2= ((unsigned char*)src)[--(*pos)]) & 0xe0 /* 1110 0000 */) { // 3 bytes: 12 to 16 bits
        if (c2 < 0xf0) { // c2 is valid
          u= ( ((unichar)(c2 & 0x0F /* 0000 1111 */) << 12)
             | ((unichar)(c1 & 0x3F /* 0011 1111 */) <<  6)
             | ((unichar)(c0 & 0x3f /* 0011 1111 */)      ));}}
      else { // 4 bytes: 17 to 21bits
        --(*pos);}}}
  return u;
}

// Optimised char -> action for utf8JsonStringChaiP
// C99 notation, non provided index are set to 0 by the compiler
static unsigned char _utf8JsonStringChaiPAction[] = {
  ['0']=0x80, ['1']=0x80, ['2']=0x80, ['3']=0x80, ['4']=0x80, ['5']=0x80, ['6']=0x80, ['7']=0x80, ['8']=0x80, ['9']=0x80,
  ['A']=0x80, ['B']=0x80, ['C']=0x80, ['D']=0x80, ['E']=0x80, ['F']=0x80,
  ['a']=0x80, ['b']=0x80 | '\b', ['c']=0x80, ['d']=0x80, ['e']=0x80, ['f']=0x80 | '\f',
  ['\"']= 1,
  ['\\']= '\\', ['/']= '/', ['n']= '\n', ['r']= '\r',  ['t']= '\t'
};
unichar utf8JsonStringChaiP(const void *src, NSUInteger *pos)
// Return 0xFFFF on begin or end of string ("), but return " on \"
{
  unichar u; unsigned char action;
  u= utf8ChaiP(src, pos);
  if (u < sizeof(_utf8JsonStringChaiPAction)/sizeof(unsigned char)) {
    action= _utf8JsonStringChaiPAction[u];
    if (action & 0x80) { // [A-Fa-f0-9]
      if (*pos >= 5 && ((unsigned char*)src)[*pos - 5] == '\\' && ((unsigned char*)src)[*pos - 4] == 'u') {
        u= (unichar)MSHexaStringToULong(src + *pos - 3, 4);
        *pos-= 5;}}
    if (action == 1) { // ["]
      if (*pos < 1 || ((unsigned char*)src)[*pos - 1] != '\\') {
        u= 0xFFFF;}}
    else if ((action=(action & 0x7F))) { // [\/bfnrt]
      if (*pos >= 1 && ((unsigned char*)src)[*pos - 1] == '\\') {
        u= (unichar)action;}}}
  return u;
}

unichar utf8JsonStringChaiN(const void *src, NSUInteger *pos)
// Return 0xFFFF on begin or end of string ("), but return " on \"
{
  unichar u= utf8ChaiN(src, pos); unsigned char c,hex[4]; int i;
  if (u=='\"') u= 0xFFFF;
  else if (u=='\\') switch ((u= utf8ChaiN(src, pos))) {
    case '\"': u= '\"'; break;
    case '\\': u= '\\'; break;
    case '/':  u= '/';  break;
    case 'b':  u= '\b'; break;
    case 'f':  u= '\f'; break;
    case 'n':  u= '\n'; break;
    case 'r':  u= '\r'; break;
    case 't':  u= '\t'; break;
    case 'u':
      for (c= 1, i= 0; c!=0x00 && i<4; i++) {
        hex[i]= c= ((unsigned char*)src)[(*pos)++];}
      if (!c) u= 0;
      else u= (unichar)MSHexaStringToULong((char*)hex, 4);
      break;
    default: break;} // invalid char ?
  return u;
}

#pragma mark Finding

// Compilers do optimise out things that aren't useful to the caller
// assume SESOK(src) && SESOK(prefix) && src.start <= srcIdx < src.end
static inline BOOL _SESPrefixAlg(SES src, NSUInteger srcIdx, NSUInteger *pSrcIdxN, NSUInteger *pSrcPrefixEnd, SES prefix, BOOL insensitive, NSUInteger *pPrefixLength)
{
  NSUInteger prefixIdx, prefixEnd, srcIdxN, srcEnd; BOOL fd;
  srcEnd= SESEnd(src);
  prefixIdx=SESStart(prefix), prefixEnd= SESEnd(prefix);
  fd= CUnicharEquals(SESIndexN(src, &srcIdx), SESIndexN(prefix, &prefixIdx), insensitive);
  srcIdxN= srcIdx; // for _SESFind
  *pPrefixLength= 1;
  while (fd && prefixIdx < prefixEnd && srcIdx < srcEnd) {
    fd= CUnicharEquals(SESIndexN(src, &srcIdx), SESIndexN(prefix, &prefixIdx), insensitive);
    ++(*pPrefixLength);}
  fd= fd && prefixIdx == prefixEnd;
  if (fd) {
    *pSrcPrefixEnd= srcIdx;}
  else {
    *pSrcIdxN= srcIdxN;}
  return fd;
}
static inline BOOL _SESSuffixAlg(SES src, NSUInteger srcIdx, NSUInteger *pSrcIdxP, NSUInteger *pSrcPrefixEnd, SES prefix, BOOL insensitive, NSUInteger *pSuffixLength)
{
  NSUInteger prefixStart, prefixIdx, srcIdxP, srcStart; BOOL fd;
  srcStart= SESStart(src);
  prefixIdx=SESEnd(prefix), prefixStart= SESStart(prefix);
  fd= CUnicharEquals(SESIndexP(src, &srcIdx), SESIndexP(prefix, &prefixIdx), insensitive);
  srcIdxP= srcIdx; // for _SESFind
  *pSuffixLength= 1;
  while (fd && prefixStart < prefixIdx && srcStart < srcIdx) {
    fd= CUnicharEquals(SESIndexP(src, &srcIdx), SESIndexP(prefix, &prefixIdx), insensitive);
    ++(*pSuffixLength);}
  fd= fd && prefixIdx == prefixStart;
  if (fd) {
    *pSrcPrefixEnd= srcIdx;}
  else {
    *pSrcIdxP= srcIdxP;}
  return fd;
}

static SES _SESSuffix(SES src, SES comparator, BOOL insensitive)
{
  SES ret= MSInvalidSES;
  if (SESOK(src) && SESOK(comparator)) {
    NSUInteger s1, e1= SESEnd(src), lg= 0;
    if (_SESSuffixAlg(src, e1, &e1, &s1, comparator, insensitive, &lg)) {
      ret= src;
      SESSetStart(ret, s1);}}
  return ret;
}

static SES _SESPrefix(SES src, SES comparator, BOOL insensitive)
{
  SES ret= MSInvalidSES;
  if (SESOK(src) && SESOK(comparator)) {
    NSUInteger i1, e1, lg= 0;
    i1= SESStart(src);
    if (_SESPrefixAlg(src, i1, &i1, &e1, comparator, insensitive, &lg)) {
      ret= src;
      SESSetEnd(ret, e1);}}
  return ret;
}

static inline NSUInteger SESRealLength(SES ses, NSUInteger idx, NSUInteger end) {
  NSUInteger n= 0;
  while (idx < end) {
    SESIndexN(ses, &idx);
    ++n;}
  return n;
}

SES _SESFind(SES src, SES searched, BOOL insensitive, BOOL backward, BOOL anchored, NSRange *range)
{
  SES ret= MSInvalidSES; BOOL fd= NO;
  if (SESOK(src) && SESOK(searched)) {
    NSUInteger i, n, e, end, start, realPos, realLength= 0;
    if (backward) {
      realPos= range ? SESRealLength(src, SESStart(src), SESEnd(src)) : SESEnd(src);
      for (n= SESEnd(src), start= anchored ? n - 1 : SESStart(src); !fd && (i= n) > start;) {
        fd= _SESSuffixAlg(src, i, &n, &e, searched, insensitive, &realLength);
        if(!fd) --realPos;}}
    else {
      realPos= 0;
      for (n= SESStart(src), end= anchored ? n + 1 : SESEnd(src); !fd && (i= n) < end;) {
        fd= _SESPrefixAlg(src, i, &n, &e, searched, insensitive, &realLength);
        if(!fd) ++realPos;}}
    if (fd) {
      ret= src;
      SESSetStart(ret, i);
      SESSetEnd(ret, e);
      if(range) {
        *range= NSMakeRange(backward ? realPos - realLength : realPos, realLength);}}
  }
  if(!fd && range) {
    *range= NSMakeRange(NSNotFound, 0);}
  return ret;
}

static inline NSComparisonResult SESCompareWithOptions(SES a, SES b, BOOL insensitive)
{
  NSComparisonResult res= NSOrderedSame; NSUInteger aIdx, bIdx, aEnd, bEnd;
  if (!SESOK(a)) return SESOK(b) ? NSOrderedAscending : NSOrderedSame;
  if (!SESOK(b)) return NSOrderedDescending;
  aIdx= SESStart(a); aEnd= SESEnd(a);
  bIdx= SESStart(b); bEnd= SESEnd(b);
  while (res == NSOrderedSame && aIdx < aEnd && bIdx < bEnd) {
    res= CUnicharCompare(SESIndexN(a, &aIdx), SESIndexN(b, &bIdx), insensitive); }
  if (res == NSOrderedSame) {
    if (aIdx < aEnd) {
      res= NSOrderedDescending;}
    else if (bIdx < bEnd) {
      res= NSOrderedAscending;}}
  return res;
}

NSComparisonResult SESCompare(SES a, SES b)
{ return SESCompareWithOptions(a, b, NO); }
NSComparisonResult SESInsensitiveCompare(SES a, SES b)
{ return SESCompareWithOptions(a, b, YES); }

BOOL SESEquals(SES a, SES b)
{ return SESCompareWithOptions(a, b, NO) == NSOrderedSame; }
BOOL SESInsensitiveEquals(SES a, SES b)
{ return SESCompareWithOptions(a, b, YES) == NSOrderedSame; }

SES SESFind(SES src, SES searched)
{
  return _SESFind(src, searched, NO, NO, NO, NULL);
}
SES SESInsensitiveFind(SES src, SES searched)
{
  return _SESFind(src, searched, YES, NO, NO, NULL);
}

SES SESCommonPrefix(SES src, SES comparator)
{
  return _SESPrefix(src, comparator, NO);
}
SES SESInsensitiveCommonPrefix(SES src, SES comparator)
{
  return _SESPrefix(src, comparator, YES);
}
SES SESCommonSuffix(SES src, SES comparator)
{
  return _SESSuffix(src, comparator, YES);
}
SES SESInsensitiveCommonSuffix(SES src, SES comparator)
{
  return _SESSuffix(src, comparator, YES);
}

SES SESExtractPart(SES src, CUnicharChecker matchingChar)
{
  SES ret= MSInvalidSES;
  if (SESOK(src) && matchingChar) {
    NSUInteger x, start= SESStart(src), end= SESEnd(src);
    while (start < end) {
      x= start;
      if (matchingChar(SESIndexN(src, &start))) {start= x; break;}}
    while (start < end) {
      x= end;
      if (matchingChar(SESIndexP(src, &end  ))) {end= x; break;}}
    if (start < end) {
      ret=        src;
      ret.start=  start;
      ret.length= end-start;}}
  return ret;
}

struct _sesWildcardsStruct
{
  SES src, wildcards;
  unichar c;
  NSUInteger srcIdx, srcEnd, mEnd;
  BOOL insensitive;
};

static inline BOOL _SESWildcardsMatch(struct _sesWildcardsStruct *s, unichar c, NSUInteger srcIdx, unichar m, NSUInteger mIdx)
{
  BOOL matching= YES, next= YES, nextM= YES;
  while (matching && next) {
    if (m == (unichar)'?') {
      nextM= YES;}
    else if (m == (unichar)'*') {
      NSUInteger mIdxNext= mIdx;
      unichar mNext= SESIndexN(s->wildcards, &mIdxNext);
      if (mIdx < s->mEnd && _SESWildcardsMatch(s, c, srcIdx, mNext, mIdxNext)) {
        return YES;}
      nextM= NO;}
    else if (CUnicharEquals(c, m, s->insensitive)) {
      nextM= YES;}
    else {
      matching= NO;}
    if (matching) {
      if (nextM && (next=(mIdx < s->mEnd))) {
          m= SESIndexN(s->wildcards, &mIdx);}
      if ((next= next && (srcIdx < s->srcEnd))) {
        c= SESIndexN(s->src, &srcIdx);}}}
  if (matching && mIdx == s->mEnd) {
    s->srcIdx= srcIdx;
    return YES;}
  return NO;
}

static SES _SESWildcardsExtractPart(SES src, SES wildcards, BOOL insensitive)
{
  SES ret= MSInvalidSES;
  if (SESOK(src) && SESOK(wildcards)) {
    NSUInteger mIdx, start= 0;
    unichar m;
    struct _sesWildcardsStruct s;
    s.src= src;
    s.srcIdx= SESStart(src);
    s.srcEnd= SESEnd(src);
    s.wildcards= wildcards;
    s.mEnd= SESEnd(wildcards);
    s.insensitive= insensitive;
    mIdx= SESStart(wildcards);
    m= SESIndexN(wildcards, &mIdx);
    while (s.srcIdx < s.srcEnd) {
      start= s.srcIdx;
      s.c= SESIndexN(s.src, &s.srcIdx);
      if (_SESWildcardsMatch(&s, s.c, s.srcIdx, m, mIdx)) {
        ret=        src;
        ret.start=  start;
        ret.length= s.srcIdx- start;
        break;}}}
  return ret;
}

SES SESWildcardsExtractPart(SES src, const char *utf8Wildcards)
{
  SES wildcards= MSMakeSESWithBytes(utf8Wildcards, strlen(utf8Wildcards), NSUTF8StringEncoding);
  return _SESWildcardsExtractPart(src, wildcards, NO);
}

SES SESInsensitiveWildcardsExtractPart(SES src, const char *utf8Wildcards)
{
  SES wildcards= MSMakeSESWithBytes(utf8Wildcards, strlen(utf8Wildcards), NSUTF8StringEncoding);
  return _SESWildcardsExtractPart(src, wildcards, YES);
}

static inline NSUInteger _go(SES src, CUnicharChecker check, NSUInteger b)
{
  NSUInteger pos,e= SESEnd(src);
  for (pos= b; b < e && check(SESIndexN(src, &pos)); b= pos);
  return b;
}
SES SESExtractToken(SES src, CUnicharChecker matchingChar, CUnicharChecker leftSpaces)
{
  SES ret= MSInvalidSES;
  if (SESOK(src) && matchingChar) {
    NSUInteger start,end;
    if (!leftSpaces) leftSpaces= (CUnicharChecker)CUnicharIsSpace;
    start= _go(src, leftSpaces  , SESStart(src));
    end=   _go(src, matchingChar, start);
    if (start < end) {
      ret=        src;
      ret.start=  start;
      ret.length= end-start;}}
  return ret;
}

SES SESExtractDecimal(SES src, BOOL intOnly, CUnicharChecker leftSpaces, CDecimal **decimalPtr)
{
  SES ret; CDecimal *d;
  d= CCreateDecimalWithSES(src, intOnly, leftSpaces, &ret);
  if (decimalPtr) *decimalPtr= d;
  return ret;
}

// Inspired by
// http://www.azillionmonkeys.com/qed/hash.html by Paul Hsieh in 2008
// https://github.com/adobe/webkit/blob/master/Source/WTF/wtf/StringHasher.h
NSUInteger SESHash(SES ses)
{
  uint32_t hash = 0x9e3779b9U, tmp;
  unichar c1, c2; NSUInteger i;

  if (!SESOK(ses)) return 0;

  i= SESStart(ses);
  while (i < SESEnd(ses)) {
    c1= SESIndexN(ses, &i);
    if(i < SESEnd(ses)) {
      c2= SESIndexN(ses, &i);
      hash+= c1;
      tmp= (c2 << 11) ^ hash;
      hash= (hash << 16) ^ tmp;
      hash+= hash >> 11;
    } else {
      hash+= c1;
      hash^= hash << 11;
      hash+= hash >> 17;
    }
  }

  /* Force "avalanching" of final 31 bits */
  hash ^= hash << 3;
  hash += hash >> 5;
  hash ^= hash << 2;
  hash += hash >> 15;
  hash ^= hash << 10;

  return hash;
}

// -----------------------------------------------------------------------------
#pragma mark encoding

static unichar __MSAnsiToUnicode[256]= {
  0x00, 0x01, 0x02 , 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
  0x10, 0x11, 0x12 , 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f,
  0x20, 0x21, 0x22 , 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f,
  0x30, 0x31, 0x32 , 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f,
  0x40, 0x41, 0x42 , 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f,
  0x50, 0x51, 0x52 , 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f,
  0x60, 0x61, 0x62 , 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f,
  0x70, 0x71, 0x72 , 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f,
  0x20ac, 0x81, 0x201a , 0x192, 0x201e, 0x2026, 0x2020, 0x2021, 0x2c6, 0x2030, 0x160, 0x2039, 0x152, 0x8d, 0x17d, 0x8f,
  0x90, 0x2018, 0x2019 , 0x201c, 0x201d, 0x2022, 0x2013, 0x2014, 0x2dc, 0x2122, 0x161, 0x203a, 0x153, 0x9d, 0x17e, 0x178,
  0xa0, 0xa1, 0xa2 , 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf,
  0xb0, 0xb1, 0xb2 , 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf,
  0xc0, 0xc1, 0xc2 , 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf,
  0xd0, 0xd1, 0xd2 , 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xda, 0xdb, 0xdc, 0xdd, 0xde, 0xdf,
  0xe0, 0xe1, 0xe2 , 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed, 0xee, 0xef,
  0xf0, 0xf1, 0xf2 , 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff
};

static unichar __MSMacRomanToUnicode[256]= {
  0x00, 0x01, 0x02 , 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
  0x10, 0x11, 0x12 , 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f,
  0x20, 0x21, 0x22 , 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f,
  0x30, 0x31, 0x32 , 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f,
  0x40, 0x41, 0x42 , 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f,
  0x50, 0x51, 0x52 , 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f,
  0x60, 0x61, 0x62 , 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f,
  0x70, 0x71, 0x72 , 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f,
  0xc4, 0xc5, 0xc7 , 0xc9, 0xd1, 0xd6, 0xdc, 0xe1, 0xe0, 0xe2, 0xe4, 0xe3, 0xe5, 0xe7, 0xe9, 0xe8,
  0xea, 0xeb, 0xed , 0xec, 0xee, 0xef, 0xf1, 0xf3, 0xf2, 0xf4, 0xf6, 0xf5, 0xfa, 0xf9, 0xfb, 0xfc,
  0x2020, 0xb0, 0xa2 , 0xa3, 0xa7, 0x2022, 0xb6, 0xdf, 0xae, 0xa9, 0x2122, 0xb4, 0xa8, 0x2260, 0xc6, 0xd8,
  0x221e, 0xb1, 0x2264 , 0x2265, 0xa5, 0xb5, 0x2202, 0x2211, 0x220f, 0x3c0, 0x222b, 0xaa, 0xba, 0x3a9, 0xe6, 0xf8,
  0xbf, 0xa1, 0xac , 0x221a, 0x192, 0x2248, 0x2206, 0xab, 0xbb, 0x2026, 0xa0, 0xc0, 0xc3, 0xd5, 0x152, 0x153,
  0x2013, 0x2014, 0x201c , 0x201d, 0x2018, 0x2019, 0xf7, 0x25ca, 0xff, 0x178, 0x2044, 0x20ac, 0x2039, 0x203a, 0xfb01, 0xfb02,
  0x2021, 0xb7, 0x201a , 0x201e, 0x2030, 0xc2, 0xca, 0xc1, 0xcb, 0xc8, 0xcd, 0xce, 0xcf, 0xcc, 0xd3, 0xd4,
  0xf8ff, 0xd2, 0xda , 0xdb, 0xd9, 0x131, 0x2c6, 0x2dc, 0xaf, 0x2d8, 0x2d9, 0x2da, 0xb8, 0x2dd, 0x2db, 0x2c7
};

static unichar __MSNextstepToUnicode[256]= {
  0x0,0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0x9,0xa,0xb,0xc,0xd,0xe,0xf,
  0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f,
  0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2a,0x2b,0x2c,0x2d,0x2e,0x2f,
  0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3a,0x3b,0x3c,0x3d,0x3e,0x3f,
  0x40,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4a,0x4b,0x4c,0x4d,0x4e,0x4f,
  0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x5a,0x5b,0x5c,0x5d,0x5e,0x5f,
  0x60,0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x6a,0x6b,0x6c,0x6d,0x6e,0x6f,
  0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x7a,0x7b,0x7c,0x7d,0x7e,0x7f,
  0xa0,0xc0,0xc1,0xc2,0xc3,0xc4,0xc5,0xc7,0xc8,0xc9,0xca,0xcb,0xcc,0xcd,0xce,0xcf,
  0xd0,0xd1,0xd2,0xd3,0xd4,0xd5,0xd6,0xd9,0xda,0xdb,0xdc,0xdd,0xde,0xb5,0xd7,0xf7,
  0xa9,0xa1,0xa2,0xa3,0x2044,0xa5,0x192,0xa7,0xa4,0x2019,0x201c,0xab,0x2039,0x203a,0xfb01,0xfb02,
  0xae,0x2013,0x2020,0x2021,0xb7,0xa6,0xb6,0x2022,0x201a,0x201e,0x201d,0xbb,0x2026,0x2030,0xac,0xbf,
  0xb9,0x2cb,0xb4,0x2c6,0x2dc,0xaf,0x2d8,0x2d9,0xa8,0xb2,0x2da,0xb8,0xb3,0x2dd,0x2db,0x2c7,
  0x2014,0xb1,0xbc,0xbd,0xbe,0xe0,0xe1,0xe2,0xe3,0xe4,0xe5,0xe7,0xe8,0xe9,0xea,0xeb,
  0xec,0xc6,0xed,0xaa,0xee,0xef,0xf0,0xf1,0x141,0xd8,0x152,0xba,0xf2,0xf3,0xf4,0xf5,
  0xf6,0xe6,0xf9,0xfa,0xfb,0x131,0xfc,0xfd,0x142,0xf8,0x153,0xdf,0xfe,0xff,0xfffd,0xfffd
};

static unichar __MSDOSToUnicode[256]= {
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
  32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
  64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
  80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
  96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
  112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
  199, 252, 233, 226, 228, 224, 229, 231, 234, 235, 232, 239, 238, 236, 196, 197,
  201, 230, 198, 244, 246, 242, 251, 249, 255, 214, 220, 162, 163, 165, 8359, 402,
  225, 237, 243, 250, 241, 209, 170, 186, 191, 8976, 172, 189, 188, 161, 171, 187,
  9617, 9618, 9619, 9474, 9508, 9569, 9570, 9558, 9557, 9571, 9553, 9559, 9565, 9564, 9563, 9488,
  9492, 9524, 9516, 9500, 9472, 9532, 9566, 9567, 9562, 9556, 9577, 9574, 9568, 9552, 9580, 9575,
  9576, 9572, 9573, 9561, 9560, 9554, 9555, 9579, 9578, 9496, 9484, 9608, 9604, 9612, 9616, 9600,
  945, 223, 915, 960, 931, 963, 181, 964, 934, 920, 937, 948, 8734, 966, 949, 8745,
  8801, 177, 8805, 8804, 8992, 8993, 247, 8776, 176, 8729, 183, 8730, 8319, 178, 9632, 160
};

static unichar __MSIsoLatin2ToUnicode[256]= {
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
  32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
  64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
  80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
  96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
  112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
  128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143,
  144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
  0x00A0, 0x0104, 0x02D8, 0x0141, 0x00A4, 0x013D, 0x015A, 0x00A7, 0x00A8, 0x0160, 0x015E, 0x0164, 0x0179, 0x00AD, 0x017D, 0x017B,
  0x00B0, 0x0105, 0x02DB, 0x0142, 0x00B4, 0x013E, 0x015B, 0x02C7, 0x00B8, 0x0161, 0x015F, 0x0165, 0x017A, 0x02DD, 0x017E, 0x017C,
  0x0154, 0x00C1, 0x00C2, 0x0102, 0x00C4, 0x0139, 0x0106, 0x00C7, 0x010C, 0x00C9, 0x0118, 0x00CB, 0x011A, 0x00CD, 0x00CE, 0x010E,
  0x0110, 0x0143, 0x0147, 0x00D3, 0x00D4, 0x0150, 0x00D6, 0x00D7, 0x0158, 0x016E, 0x00DA, 0x0170, 0x00DC, 0x00DD, 0x0162, 0x00DF,
  0x0155, 0x00E1, 0x00E2, 0x0103, 0x00E4, 0x013A, 0x0107, 0x00E7, 0x010D, 0x00E9, 0x0119, 0x00EB, 0x011B, 0x00ED, 0x00EE, 0x010F,
  0x0111, 0x0144, 0x0148, 0x00F3, 0x00F4, 0x0151, 0x00F6, 0x00F7, 0x0159, 0x016F, 0x00FA, 0x0171, 0x00FC, 0x00FD, 0x0163, 0x02D9
};


static unichar __MSWindows1250ToUnicode[256]= {
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
  32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
  64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
  80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
  96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
  112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
  0x20AC, 0xfffd, 0x201A, 0xfffd, 0x201E, 0x2026, 0x2020, 0x2021, 0xfffd, 0x2030, 0x0160, 0x2039, 0x015A, 0x0164, 0x017D, 0x0179,
  0xfffd, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014, 0xfffd, 0x2122, 0x0161, 0x203A, 0x015B, 0x0165, 0x017E, 0x017A,
  0x00A0, 0x02C7, 0x02D8, 0x0141, 0x00A4, 0x0104, 0x00A6, 0x00A7, 0x00A8, 0x00A9, 0x015E, 0x00AB, 0x00AC, 0x00AD, 0x00AE, 0x017B,
  0x00B0, 0x00B1, 0x02DB, 0x0142, 0x00B4, 0x00B5, 0x00B6, 0x00B7, 0x00B8, 0x0105, 0x015F, 0x00BB, 0x013D, 0x02DD, 0x013E, 0x017C,
  0x0154, 0x00C1, 0x00C2, 0x0102, 0x00C4, 0x0139, 0x0106, 0x00C7, 0x010C, 0x00C9, 0x0118, 0x00CB, 0x011A, 0x00CD, 0x00CE, 0x010E,
  0x0110, 0x0143, 0x0147, 0x00D3, 0x00D4, 0x0150, 0x00D6, 0x00D7, 0x0158, 0x016E, 0x00DA, 0x0170, 0x00DC, 0x00DD, 0x0162, 0x00DF,
  0x0155, 0x00E1, 0x00E2, 0x0103, 0x00E4, 0x013A, 0x0107, 0x00E7, 0x010D, 0x00E9, 0x0119, 0x00EB, 0x011B, 0x00ED, 0x00EE, 0x010F,
  0x0111, 0x0144, 0x0148, 0x00F3, 0x00F4, 0x0151, 0x00F6, 0x00F7, 0x0159, 0x016F, 0x00FA, 0x0171, 0x00FC, 0x00FD, 0x0163, 0x02D9
};

static unichar __MSWindows1251ToUnicode[256]= {
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
  32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
  64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
  80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
  96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
  112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
  0x0402, 0x0403, 0x201A, 0x0453, 0x201E, 0x2026, 0x2020, 0x2021, 0x20AC, 0x2030, 0x0409, 0x2039, 0x040A, 0x040C, 0x040B, 0x040F,
  0x0452, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014, 0xfffd, 0x2122, 0x0459, 0x203A, 0x045A, 0x045C, 0x045B, 0x045F,
  0x00A0, 0x040E, 0x045E, 0x0408, 0x00A4, 0x0490, 0x00A6, 0x00A7, 0x0401, 0x00A9, 0x0404, 0x00AB, 0x00AC, 0x00AD, 0x00AE, 0x0407,
  0x00B0, 0x00B1, 0x0406, 0x0456, 0x0491, 0x00B5, 0x00B6, 0x00B7, 0x0451, 0x2116, 0x0454, 0x00BB, 0x0458, 0x0405, 0x0455, 0x0457,
  0x0410, 0x0411, 0x0412, 0x0413, 0x0414, 0x0415, 0x0416, 0x0417, 0x0418, 0x0419, 0x041A, 0x041B, 0x041C, 0x041D, 0x041E, 0x041F,
  0x0420, 0x0421, 0x0422, 0x0423, 0x0424, 0x0425, 0x0426, 0x0427, 0x0428, 0x0429, 0x042A, 0x042B, 0x042C, 0x042D, 0x042E, 0x042F,
  0x0430, 0x0431, 0x0432, 0x0433, 0x0434, 0x0435, 0x0436, 0x0437, 0x0438, 0x0439, 0x043A, 0x043B, 0x043C, 0x043D, 0x043E, 0x043F,
  0x0440, 0x0441, 0x0442, 0x0443, 0x0444, 0x0445, 0x0446, 0x0447, 0x0448, 0x0449, 0x044A, 0x044B, 0x044C, 0x044D, 0x044E, 0x044F
};

static unichar __MSWindows1253ToUnicode[256]= {
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
  32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
  64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
  80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
  96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
  112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
  0x20AC, 0xfffd, 0x201A, 0x0192, 0x201E, 0x2026, 0x2020, 0x2021, 0xfffd, 0x2030, 0xfffd, 0x2039, 0xfffd, 0xfffd, 0xfffd, 0xfffd,
  0xfffd, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014, 0xfffd, 0x2122, 0xfffd, 0x203A, 0xfffd, 0xfffd, 0xfffd, 0xfffd,
  0x00A0, 0x0385, 0x0386, 0x00A3, 0x00A4, 0x00A5, 0x00A6, 0x00A7, 0x00A8, 0x00A9, 0xfffd, 0x00AB, 0x00AC, 0x00AD, 0x00AE, 0x2015,
  0x00B0, 0x00B1, 0x00B2, 0x00B3, 0x0384, 0x00B5, 0x00B6, 0x00B7, 0x0388, 0x0389, 0x038A, 0x00BB, 0x038C, 0x00BD, 0x038E, 0x038F,
  0x0390, 0x0391, 0x0392, 0x0393, 0x0394, 0x0395, 0x0396, 0x0397, 0x0398, 0x0399, 0x039A, 0x039B, 0x039C, 0x039D, 0x039E, 0x039F,
  0x03A0, 0x03A1, 0xfffd, 0x03A3, 0x03A4, 0x03A5, 0x03A6, 0x03A7, 0x03A8, 0x03A9, 0x03AA, 0x03AB, 0x03AC, 0x03AD, 0x03AE, 0x03AF,
  0x03B0, 0x03B1, 0x03B2, 0x03B3, 0x03B4, 0x03B5, 0x03B6, 0x03B7, 0x03B8, 0x03B9, 0x03BA, 0x03BB, 0x03BC, 0x03BD, 0x03BE, 0x03BF,
  0x03C0, 0x03C1, 0x03C2, 0x03C3, 0x03C4, 0x03C5, 0x03C6, 0x03C7, 0x03C8, 0x03C9, 0x03CA, 0x03CB, 0x03CC, 0x03CD, 0x03CE, 0xfffd
};

static unichar __MSWindows1254ToUnicode[256]= {
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
  32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
  64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
  80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
  96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
  112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
  0x20AC, 0xfffd, 0x201A, 0x0192, 0x201E, 0x2026, 0x2020, 0x2021, 0x02C6, 0x2030, 0x0160, 0x2039, 0x0152, 0xfffd, 0xfffd, 0xfffd,
  0xfffd, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014, 0x02DC, 0x2122, 0x0161, 0x203A, 0x0153, 0xfffd, 0xfffd, 0x0178,
  0x00A0, 0x00A1, 0x00A2, 0x00A3, 0x00A4, 0x00A5, 0x00A6, 0x00A7, 0x00A8, 0x00A9, 0x00AA, 0x00AB, 0x00AC, 0x00AD, 0x00AE, 0x00AF,
  0x00B0, 0x00B1, 0x00B2, 0x00B3, 0x00B4, 0x00B5, 0x00B6, 0x00B7, 0x00B8, 0x00B9, 0x00BA, 0x00BB, 0x00BC, 0x00BD, 0x00BE, 0x00BF,
  0x00C0, 0x00C1, 0x00C2, 0x00C3, 0x00C4, 0x00C5, 0x00C6, 0x00C7, 0x00C8, 0x00C9, 0x00CA, 0x00CB, 0x00CC, 0x00CD, 0x00CE, 0x00CF,
  0x011E, 0x00D1, 0x00D2, 0x00D3, 0x00D4, 0x00D5, 0x00D6, 0x00D7, 0x00D8, 0x00D9, 0x00DA, 0x00DB, 0x00DC, 0x0130, 0x015E, 0x00DF,
  0x00E0, 0x00E1, 0x00E2, 0x00E3, 0x00E4, 0x00E5, 0x00E6, 0x00E7, 0x00E8, 0x00E9, 0x00EA, 0x00EB, 0x00EC, 0x00ED, 0x00EE, 0x00EF,
  0x011F, 0x00F1, 0x00F2, 0x00F3, 0x00F4, 0x00F5, 0x00F6, 0x00F7, 0x00F8, 0x00F9, 0x00FA, 0x00FB, 0x00FC, 0x0131, 0x015F, 0x00FF
};

static unichar __MSAdobeSymbolToUnicode[256]= {
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
  0x0020, 0x0021, 0x2200, 0x0023, 0x2203, 0x0025, 0x0026, 0x220B, 0x0028, 0x0029, 0x2217, 0x002B, 0x002C, 0x2212, 0x002E, 0x002F,
  0x0030, 0x0031, 0x0032, 0x0033, 0x0034, 0x0035, 0x0036, 0x0037, 0x0038, 0x0039, 0x003A, 0x003B, 0x003C, 0x003D, 0x003E, 0x003F,
  0x2245, 0x0391, 0x0392, 0x03A7, 0x0394, 0x0395, 0x03A6, 0x0393, 0x0397, 0x0399, 0x03D1, 0x039A, 0x039B, 0x039C, 0x039D, 0x039F,
  0x03A0, 0x0398, 0x03A1, 0x03A3, 0x03A4, 0x03A5, 0x03C2, 0x03A9, 0x039E, 0x03A8, 0x0396, 0x005B, 0x2234, 0x005D, 0x22A5, 0x005F,
  0xF8E5, 0x03B1, 0x03B2, 0x03C7, 0x03B4, 0x03B5, 0x03C6, 0x03B3, 0x03B7, 0x03B9, 0x03D5, 0x03BA, 0x03BB, 0x00B5, 0x03BC, 0x03BD,
  0x03BF, 0x03C0, 0x03B8, 0x03C1, 0x03C3, 0x03C4, 0x03C5, 0x03D6, 0x03C9, 0x03BE, 0x03C8, 0x03B6, 0x007B, 0x007C, 0x007D, 0x223C,
  128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143,
  144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
  0x20AC, 0x03D2, 0x2032, 0x2264, 0x2044, 0x221E, 0x0192, 0x2663, 0x2666, 0x2665, 0x2660, 0x2194, 0x2190, 0x2191, 0x2192, 0x2193,
  0x00B0, 0x00B1, 0x2033, 0x2265, 0x00D7, 0x221D, 0x2202, 0x2022, 0x00F7, 0x2260, 0x2261, 0x2248, 0x2026, 0xF8E6, 0xF8E7, 0x21B5,
  0x2135, 0x2111, 0x211C, 0x2118, 0x2297, 0x2295, 0x2205, 0x2229, 0x222A, 0x2283, 0x2287, 0x2284, 0x2282, 0x2286, 0x2208, 0x2209,
  0x2220, 0x2207, 0xF6DA, 0xF6D9, 0xF6DB, 0x220F, 0x221A, 0x22C5, 0x00AC, 0x2227, 0x2228, 0x21D4, 0x21D0, 0x21D1, 0x21D2, 0x21D3,
  0x25CA, 0x2329, 0xF8E8, 0xF8E9, 0xF8EA, 0x2211, 0xF8EB, 0xF8EC, 0xF8ED, 0xF8EE, 0xF8EF, 0xF8F0, 0xF8F1, 0xF8F2, 0xF8F3, 0xF8F4,
  0xfffd, 0x232A, 0x222B, 0x2320, 0xF8F5, 0x2321, 0xF8F6, 0xF8F7, 0xF8F8, 0xF8F9, 0xF8FA, 0xF8FB, 0xF8FC, 0xF8FD, 0xF8FE, 0xfffd
};

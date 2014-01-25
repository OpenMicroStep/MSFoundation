/*   MSCoreUnichar.c
 
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
#include "MSCoreUnichar_Private.h"

unichar CUnicharToUpper(unichar ch)
{
  int info = GetUniCharInfo(ch);
  if (GetCaseType(info) & 0x04) return (unichar) (ch - GetDelta(info));
  else return ch;
}

unichar CUnicharToLower(unichar ch)
{
  int info = GetUniCharInfo(ch);
  if (GetCaseType(info) & 0x02) return (unichar) (ch + GetDelta(info));
  else return ch;
}

BOOL CUnicharIsAlpha(unichar ch)  { return ((ALPHA_BITS >> (GetUniCharInfo(ch) & UNICODE_CATEGORY_MASK)) & 1); }
BOOL CUnicharIsAlnum(unichar ch)  { return (((ALPHA_BITS | DIGIT_BITS) >> (GetUniCharInfo(ch) & UNICODE_CATEGORY_MASK)) & 1); }
BOOL CUnicharIsControl(unichar ch)   { return ((GetUniCharInfo(ch) & UNICODE_CATEGORY_MASK) == CONTROL); }
BOOL CUnicharIsUpper(unichar ch)   { return ((GetUniCharInfo(ch) & UNICODE_CATEGORY_MASK) == UPPERCASE_LETTER); }
BOOL CUnicharIsLower(unichar ch)   { return ((GetUniCharInfo(ch) & UNICODE_CATEGORY_MASK) == LOWERCASE_LETTER); }
BOOL CUnicharIsDigit(unichar ch)   { return ((GetUniCharInfo(ch) & UNICODE_CATEGORY_MASK)  == DECIMAL_DIGIT_NUMBER); }
BOOL CUnicharIsSpace(unichar ch)  { return _CUnicharIsSpace(ch); }
BOOL CUnicharIsSolid(unichar ch)  { return !_CUnicharIsSpace(ch) && !CUnicharIsEOL(ch); }

BOOL CUnicharIsPunct(unichar ch) { return ((PUNCT_BITS >> (GetUniCharInfo(ch) & UNICODE_CATEGORY_MASK)) & 1); }
BOOL CUnicharIsWordChar(unichar ch) { return (((ALPHA_BITS | DIGIT_BITS | CONNECTOR_BITS) >> (GetUniCharInfo(ch) & UNICODE_CATEGORY_MASK)) & 1); }
BOOL CUnicharIsPrintable(unichar ch) { return ((PRINT_BITS >> (GetUniCharInfo(ch) & UNICODE_CATEGORY_MASK)) & 1); }

BOOL CUnicharIsLetter(unichar c) { return (c < 'A' || c > 'z' || (c > 'Z' && c < 'a') ? NO : YES); }
BOOL CUnicharIsHexa(unichar c) { return ((c >= '0' && c <= '9') || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f')); }

BOOL CUnicharIsEOL(unichar c) { return (c == 0x000a || c == 0x000d ||  c == 0x2028 || c ==  0x2029 ? YES : NO); }
BOOL CUnicharIsSeparator(unichar c) { return CUnicharIsEOL(c) || _CUnicharIsSpace(c) || CUnicharIsPunct(c) ? YES : NO; }
BOOL CUnicharIsIsoDigit(unichar c) { return (c < '0' || c > '9' ? NO : YES); }
BOOL CUnicharIsSpaceOrEOL(unichar c) { return CUnicharIsEOL(c) || _CUnicharIsSpace(c) ? YES : NO; }

unichar  CAnsiToUnicode(MSByte c) { return __MSAnsiToUnicode[c]; }
unichar CMacRomanToUnicode(MSByte c) { return __MSMacRomanToUnicode[c]; }
unichar CNextstepToUnicode(MSByte c) { return __MSNextstepToUnicode[c]; }
unichar CWindows1250ToUnicode(MSByte c) { return __MSWindows1250ToUnicode[c]; }
unichar CWindows1251ToUnicode(MSByte c) { return __MSWindows1251ToUnicode[c]; }
unichar CWindows1253ToUnicode(MSByte c) { return __MSWindows1253ToUnicode[c]; }
unichar CWindows1254ToUnicode(MSByte c) { return __MSWindows1254ToUnicode[c]; }
unichar CDOSToUnicode(MSByte c) { return __MSDOSToUnicode[c]; }
unichar CIsoLatin2ToUnicode(MSByte c) { return __MSIsoLatin2ToUnicode[c]; }
unichar CAdobeSymbolToUnicode(MSByte c) { return __MSAdobeSymbolToUnicode[c]; }

BOOL CUnicharInsensitiveEquals(unichar ca, unichar cb)
{
  if (ca != cb) {
    int infoA = GetUniCharInfo(ca), infoB = GetUniCharInfo(cb);
    if (((GetCaseType(infoA) & 0x02) ? (unichar) (ca + GetDelta(infoA)) : ca) != ((GetCaseType(infoB) & 0x02) ? (unichar) (cb + GetDelta(infoB)) : cb)) return NO;
  }
  return YES;
}

NSComparisonResult CUnicharInsensitiveCompare(unichar ca, unichar cb)
{
  if (ca != cb) {
    int infoA = GetUniCharInfo(ca), infoB = GetUniCharInfo(cb);
    int comp = (int)((GetCaseType(infoA) & 0x02) ? (unichar) (ca + GetDelta(infoA)) : ca) - (int)((GetCaseType(infoB) & 0x02) ? (unichar) (cb + GetDelta(infoB)) : cb);
    if (comp < 0) { return NSOrderedAscending; }
    else if (comp > 0) { return NSOrderedDescending; }
    
  }
  return NSOrderedSame;
}

BOOL CUnicharsInsensitiveEquals(const unichar *ba, const unichar *bb, NSUInteger length)
{
  if (ba != bb) {
    NSUInteger i;
    if (!ba || !length) return NO;
    for (i = 0; i < length; i++) { if (!CUnicharInsensitiveEquals(ba[i], bb[i])) return NO; }
    
  }
  return YES;
}

NSComparisonResult CUnicharsInsensitiveCompare(const unichar *ba, const unichar *bb, NSUInteger length)
{
  if (ba != bb) {
    NSUInteger i;
    unichar ca, cb;
    int infoA, infoB;
    int comp = 0;
    if (!ba) return NSOrderedAscending;
    if (!bb) return NSOrderedDescending;
    for (i = 0; !comp && i < length; i++) {
      ca = ba[i]; cb = bb[i];
      infoA = GetUniCharInfo(ca); infoB = GetUniCharInfo(cb);
      comp = (int)((GetCaseType(infoA) & 0x02) ? (unichar) (ca + GetDelta(infoA)) : ca) - (int)((GetCaseType(infoB) & 0x02) ? (unichar) (cb + GetDelta(infoB)) : cb);
    }
    if (comp < 0) { return NSOrderedAscending; }
    else if (comp > 0) { return NSOrderedDescending; }
    
  }
  return NSOrderedSame;
}

NSUInteger CUnicharsInsensitiveFind(const unichar *b, NSUInteger l, const unichar *bf, NSUInteger lf)
{
  if (lf && lf < l && b && bf) {
    register NSUInteger found = 0, i;
    unichar ca, cb = bf[0];
    int infoA, infoB = GetUniCharInfo(cb);
    int compB = (int)((GetCaseType(infoB) & 0x02) ? (unichar) (cb + GetDelta(infoB)) : cb);
    int compB0 = compB;
    
    for (i = 0; i < l; i++) {
      ca = b[i]; infoA = GetUniCharInfo(ca);
      if ((int)((GetCaseType(infoA) & 0x02) ? (unichar) (ca + GetDelta(infoA)) : ca) == compB) {
        found++;
        if (found == lf) return (i+1)-found; // OK, we found our string
        cb = bf[found];
        infoB = GetUniCharInfo(cb);
        compB = (int)((GetCaseType(infoB) & 0x02) ? (unichar) (cb + GetDelta(infoB)) : cb);
      }
      else if (found) { i -= found; found = 0; compB = compB0; }
    }
    
  }
  return NSNotFound;
}


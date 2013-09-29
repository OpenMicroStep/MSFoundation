/*   MSCoreSES.c
 
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
#include "MSCoreUnicharPrivate_.h"

const SES MSInvalidSES = {InvalidCHAI,NSNotFound,0} ;

unichar __unicodeEnumerator(            const void *source, NSUInteger pos) ;
unichar __littleEndianUnicodeEnumerator(const void *source, NSUInteger pos) ;
unichar __bigEndianUnicodeEnumerator(   const void *source, NSUInteger pos) ;
unichar __asciiEnumerator(              const void *source, NSUInteger pos) ;
unichar __macRomanEnumerator(           const void *source, NSUInteger pos) ;
unichar __nextStepEnumerator(           const void *source, NSUInteger pos) ;
unichar __ansiEnumerator(               const void *source, NSUInteger pos) ;
unichar __windows1250Enumerator(        const void *source, NSUInteger pos) ;
unichar __windows1251Enumerator(        const void *source, NSUInteger pos) ;
unichar __windows1253Enumerator(        const void *source, NSUInteger pos) ;
unichar __windows1254Enumerator(        const void *source, NSUInteger pos) ;
unichar __isoLatin2Enumerator(          const void *source, NSUInteger pos) ;
unichar __adobeSymbolEnumerator(        const void *source, NSUInteger pos) ;
unichar __dosEnumerator(                const void *source, NSUInteger pos) ;

unichar __unicodeEnumerator(const void *source, NSUInteger pos) { return (unichar)((unichar *)source)[pos] ; }
unichar __littleEndianUnicodeEnumerator(const void *source, NSUInteger pos) { return MSFromLittle16(((unichar *)source)[pos]) ; }
unichar __bigEndianUnicodeEnumerator(const void *source, NSUInteger pos) { return MSFromBig16(((unichar *)source)[pos]) ; }
unichar __asciiEnumerator(const void *source, NSUInteger pos) { return (unichar)((char *)source)[pos] ; }
unichar __macRomanEnumerator(const void *source, NSUInteger pos) { return __MSMacRomanToUnicode[(int)(((char*)source)[pos])] ; }
unichar __nextStepEnumerator(const void *source, NSUInteger pos) { return __MSNextstepToUnicode[(int)(((char*)source)[pos])] ; }
unichar __ansiEnumerator(const void *source, NSUInteger pos) { return __MSAnsiToUnicode[(int)(((char*)source)[pos])] ; }
unichar __windows1250Enumerator(const void *source, NSUInteger pos) { return __MSWindows1250ToUnicode[(int)(((char*)source)[pos])] ; }
unichar __windows1251Enumerator(const void *source, NSUInteger pos) { return __MSWindows1251ToUnicode[(int)(((char*)source)[pos])] ; }
unichar __windows1253Enumerator(const void *source, NSUInteger pos) { return __MSWindows1253ToUnicode[(int)(((char*)source)[pos])] ; }
unichar __windows1254Enumerator(const void *source, NSUInteger pos) { return __MSWindows1254ToUnicode[(int)(((char*)source)[pos])] ; }
unichar __isoLatin2Enumerator(const void *source, NSUInteger pos) { return __MSIsoLatin2ToUnicode[(int)(((char*)source)[pos])] ; }
unichar __adobeSymbolEnumerator(const void *source, NSUInteger pos) { return __MSAdobeSymbolToUnicode[(int)(((char*)source)[pos])] ; }
unichar __dosEnumerator(const void *source, NSUInteger pos) { return __MSDOSToUnicode[(int)(((char*)source)[pos])] ; }

SES MSMakeSESWithBytes(const void *source, NSUInteger sourceLength, NSStringEncoding sourceEncoding)
{
  if (source && sourceLength) {
    switch (sourceEncoding) {
      case NSASCIIStringEncoding:
      case NSNonLossyASCIIStringEncoding:
      case NSISOLatin1StringEncoding:
        return MSMakeSES(__asciiEnumerator, 0, sourceLength) ;
      case NSISOLatin2StringEncoding:
        return MSMakeSES(__isoLatin2Enumerator, 0, sourceLength) ;
      case NSNEXTSTEPStringEncoding:
        return MSMakeSES(__nextStepEnumerator, 0, sourceLength) ;
      case NSMacOSRomanStringEncoding:
        return MSMakeSES(__macRomanEnumerator, 0, sourceLength) ;
      case NSWindowsCP1250StringEncoding: // WinLatin2
        return MSMakeSES(__windows1250Enumerator, 0, sourceLength) ;
      case NSWindowsCP1251StringEncoding: // Cyrilic
        return MSMakeSES(__windows1251Enumerator, 0, sourceLength) ;
      case NSWindowsCP1252StringEncoding: // WinLatin1
        return MSMakeSES(__ansiEnumerator, 0, sourceLength) ;
      case NSWindowsCP1253StringEncoding: // Greec
        return MSMakeSES(__windows1253Enumerator, 0, sourceLength) ;
      case NSWindowsCP1254StringEncoding: // Turkish
        return MSMakeSES(__windows1254Enumerator, 0, sourceLength) ;
      case NSSymbolStringEncoding:
        return MSMakeSES(__windows1254Enumerator, 0, sourceLength) ;
      case NSUnicodeStringEncoding:
        return MSMakeSES(__unicodeEnumerator, 0, sourceLength) ;
      case NSUTF16BigEndianStringEncoding:
        return MSMakeSES(__bigEndianUnicodeEnumerator, 0, sourceLength) ;
      case NSUTF16LittleEndianStringEncoding:
        return MSMakeSES(__littleEndianUnicodeEnumerator, 0, sourceLength) ;
      case NSDOSStringEncoding:
        return MSMakeSES(__dosEnumerator, 0, sourceLength) ;

      default:
        // we dont return a valid enumerator for NSUTF8StringEncoding, NSJapaneseEUCStringEncoding, NSShiftJISStringEncoding and NSISO2022JPStringEncoding
        break;
    }
  }
  return MSInvalidSES ;
}

SES SESFind(SES ses, const void *source, SES sesSearched, const void *searched)
{
  SES ret = {InvalidCHAI,NSNotFound,0} ;
  if (source && searched && SESOK(ses) && SESOK(sesSearched) && sesSearched.length <= ses.length) {
        register NSUInteger i1, i2, end1 = ses.start + ses.length ;
        for (i1 = ses.start, i2 = 0 ; i1 < end1 && i2 < sesSearched.length ; i1++) {
            if (SESIndex(ses, source, i1) == SESIndex(sesSearched, searched, i2)) { i2++ ; }
            else if (i2 > 0) { i1 -= i2 ; i2 = 0 ; /* comming back to last position we can recon knew pattern */ }
        }
        if (i2 == sesSearched.length) {
            ret.length = i2 ;
            ret.start = i1 - i2 ;
            ret.chai = ses.chai ;
        }
        
  }
  return ret ;
}

SES SESInsensitiveFind(SES ses, const void *source, SES sesSearched, const void *searched)
{
  SES ret = {InvalidCHAI,NSNotFound,0} ;
  if (source && searched && SESOK(ses) && SESOK(sesSearched) && sesSearched.length <= ses.length) {
        register NSUInteger i1, i2, end1 = ses.start + ses.length ;
        
        for (i1 = ses.start, i2 = 0 ; i1 < end1 && i2 < sesSearched.length ; i1++) {
            if (CUnicharInsensitiveEquals(SESIndex(ses, source, i1), SESIndex(sesSearched, searched, i2))) { i2 ++ ; }
            else if (i2 > 0) { i1 -= i2 ; i2 = 0 ; /* comming back to last position we can recon knew pattern */ }
        }
        if (i2 == sesSearched.length) {
            ret.length = i2 ;
            ret.start = i1 - i2 ;
            ret.chai = ses.chai ;
        }
        
  }
  return ret ;
}

SES SESCommonPrefix(SES ses, const void *source, SES sesComparator, const void *comparator)
{
  SES ret = {InvalidCHAI,NSNotFound,0} ;
  if (source && comparator && SESOK(ses) && SESOK(sesComparator)) {
        register NSUInteger i1, i2, end1 = ses.start + ses.length ;
        for (i1 = ses.start, i2 = 0 ; i1 < end1 && i2 < sesComparator.length ; i1++) {
            if (SESIndex(ses, source, i1) == SESIndex(sesComparator, comparator, i2)) { i2++ ; }
            else { break ;}
        }
        ret = ses ;
        ret.length = i2 ;
  }
  return ret ;
}

SES SESInsensitiveCommonPrefix(SES ses, const void *source, SES sesComparator, const void *comparator)
{
  SES ret = {InvalidCHAI,NSNotFound,0} ;
  if (source && comparator && SESOK(ses) && SESOK(sesComparator)) {
        register NSUInteger i1, i2, end1 = ses.start + ses.length ;
        for (i1 = ses.start, i2 = 0 ; i1 < end1 && i2 < sesComparator.length ; i1++) {
            if (CUnicharInsensitiveEquals(SESIndex(ses, source, i1), SESIndex(sesComparator, comparator, i2))) { i2++ ; }
            else { break ;}
        }
        ret = ses ;
        ret.length = i2 ;
  }
  return ret ;
}

SES SESExtractPart(SES ses, const void *s, CUnicharChecker matchingChar)
{
  SES ret = {InvalidCHAI,NSNotFound,0} ;
  if (SESOK(ses) && s && matchingChar) {
    NSUInteger start = ses.start, i = ses.length ;
    for (; start < i ; start++) if (matchingChar(SESIndex(ses, s, start))) break ;
    if (start < i) {
            while (i-- > start) { if (matchingChar(SESIndex(ses, s, i))) break ; }
      ret.chai = ses.chai ;
      ret.start = start ;
      ret.length = i-start+1 ;
    }
  }
  return ret ;
}

SES SESExtractToken(SES ses, const void *s, CUnicharChecker matchingChar, CUnicharChecker leftSpaces)
{
  SES ret = {InvalidCHAI,NSNotFound,0} ;
  if (SESOK(ses) && s && matchingChar) {
    NSUInteger start = ses.start, i = ses.length ;
    if (!leftSpaces) leftSpaces = (CUnicharChecker)CUnicharIsSpace ;
    
    for (; start < i ; start++) if (!leftSpaces(SESIndex(ses, s, start))) break ;
    if (start < i && matchingChar(SESIndex(ses, s, start))) {
      NSUInteger j ;
            for (j = start; j < i ; j++) if (!matchingChar(SESIndex(ses, s, j))) break ;
      ret.chai = ses.chai ;
      ret.start = start ;
      ret.length = j-start ;
    }
    
  }
  return ret ;
}


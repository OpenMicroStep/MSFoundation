/*   MSCoreSES.h
 
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

#ifndef MSCORE_SES_H
#define MSCORE_SES_H

typedef unichar (*CHAI)(const void *, NSUInteger);
#define InvalidCHAI  (CHAI)0

typedef struct SESStruct {
    CHAI chai ;
  NSUInteger start ;
    NSUInteger length ;
} SES ;

MSExport const SES MSInvalidSES ;

static inline SES MSMakeSES(CHAI funct, NSUInteger start, NSUInteger length)
{
  SES ret ;
  ret.chai = funct ;
  ret.start = start ;
  ret.length = length ;
  return ret ;
}

typedef MSByte MSRealScanOptions ;
#define MSAcceptsDot    1
#define MSAcceptsComma    2
#define MSAcceptsDotOrComma  3
#define MSAcceptsExponent  4

MSExport SES MSMakeSESWithBytes(const void *source, NSUInteger sourceLength, NSStringEncoding sourceEncoding) ;

MSExport SES SESFind(SES ses, const void *source, SES sesSearched, const void *searched) ;
MSExport SES SESInsensitiveFind(SES ses, const void *source, SES sesSearched, const void *searched) ;

MSExport SES SESCommonPrefix(SES ses, const void *source, SES sesComparator, const void *comparator) ;
MSExport SES SESInsensitiveCommonPrefix(SES ses, const void *source, SES sesComparator, const void *comparator) ;

MSExport SES SESExtractPart(SES ses, const void *s, CUnicharChecker matchingChar) ;
MSExport SES SESExtractToken(SES ses, const void *s, CUnicharChecker matchingChar, CUnicharChecker leftSpaces) ;

#define CAIOK(X)      ((X) != InvalidCHAI)
#define SESOK(X)      ({SES __x__ = (X) ;  CAIOK(__x__.chai) && (__x__.start != NSNotFound) && (__x__.length > 0) ;})
#define SESLength(X)    ((X).length)
#define SESCHAI(X)      ((X).chai)
#define SESStart(X)      ((X).start)
#define SESIndex(X,Y,Z)    ((X).chai(Y,Z))
#define SESEnd(X)      ((X).start + (X).length)

#endif /* MSCORE_SES_H */

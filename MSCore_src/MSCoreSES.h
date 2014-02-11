/* MSCoreSES.h
 
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

// CHAI (CHaracter At Index) est une fonction qui, à partir
// d'un pointeur vers une source et
// d'un entier i représentant l'index que l'on veut atteindre dans la source,
// retourne en tant qu'unichar le ième élément de la source.

typedef unichar (*CHAI)(const void *, NSUInteger);
#define InvalidCHAI (CHAI)0

// SES (String Enumerator S...) représente l'accès à une source que l'on peut
// parcourir grâce à sa fonction 'chai'
// qu'on limite volontairement à l'intervalle [start, start+length[

typedef struct SESStruct {
  const void *source;
  CHAI chai;
  NSUInteger start;
  NSUInteger length;
  NSStringEncoding encoding;}
SES;

MSExport const SES MSInvalidSES;

static inline SES MSMakeSES(const void *source, CHAI funct, NSUInteger start, NSUInteger length, NSStringEncoding encoding)
{
  SES ret;
  ret.source=   source;
  ret.chai=     funct;
  ret.start=    start;
  ret.length=   length;
  ret.encoding= encoding;
  return ret;
}

typedef MSByte MSRealScanOptions;
#define MSAcceptsDot        1
#define MSAcceptsComma      2
#define MSAcceptsDotOrComma 3
#define MSAcceptsExponent   4

unichar        CEncodingToUnicode(unsigned short c, NSStringEncoding encoding);
unsigned short CUnicodeToEncoding(unichar        u, NSStringEncoding encoding);

MSExport SES MSMakeSESWithBytes(const void *source, NSUInteger sourceLength, NSStringEncoding sourceEncoding);

MSExport SES SESFind(SES src, SES searched);
MSExport SES SESInsensitiveFind(SES src, SES searched);

MSExport SES SESCommonPrefix(SES src, SES comparator);
MSExport SES SESInsensitiveCommonPrefix(SES src, SES comparator);
// Retourne en tant que SES sur src le plus grand préfixe entre les deux chaînes.
// Retourne MSInvalidSES si pas de préfixe commun.

MSExport SES SESExtractPart(SES src, CUnicharChecker matchingChar);
MSExport SES SESExtractToken(SES src, CUnicharChecker matchingChar, CUnicharChecker leftSpaces);
// Si 'leftSpaces' est NULL, il est remplacé par CUnicharIsSpace.
// Retourne un SES de 'src' sans les 'leftSpaces', avec les caractères qui matchent
// avec 'matchingChar'.
// Ex: ('  123zehgf',CUnicharIsDigit,NULL) -> '123'

#define CAIOK(X)      ((X) != InvalidCHAI)
#define SESOK(X)      ({SES __x__= (X);  \
  (__x__.source != NULL) && CAIOK(__x__.chai) && \
  (__x__.start != NSNotFound) && (__x__.length > 0);})
#define SESSource(X)  ((X).source)
#define SESCHAI(X)    ((X).chai)
#define SESStart(X)   ((X).start)
#define SESLength(X)  ((X).length)
#define SESIndex(X,I) ({SES __x__= (X); __x__.chai(__x__.source,(I));})
#define SESEnd(X)     ((X).start + (X).length)

#endif /* MSCORE_SES_H */

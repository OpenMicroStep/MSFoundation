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
// d'un pointeur pi vers un entier représentant l'index que l'on veut atteindre dans la source,
// retourne en tant qu'unichar l'élément à la ième position de la source (pas
// nécessairement le ième élément : ex UTF-8).
// et dans pi l'index du prochain caractère.
// Peut aussi être utilisé pour parcourir dans l'autre sens. Dans ce cas, on veut le
// caractère AVANT l'index, ie c'est l'index de la fin du caractère, et on
// retourne par référence l'index du caractère (donc l'index à fournir pour
// avoir le précédent).

typedef unichar (*CHAI)(const void *, NSUInteger*);
#define InvalidCHAI (CHAI)0

MSCoreExtern unichar utf8ChaiN          (         const void *src, NSUInteger *pos);
MSCoreExtern unichar utf8ChaiP          (         const void *src, NSUInteger *pos);
MSCoreExtern unichar utf8JsonStringChaiN(         const void *src, NSUInteger *pos);
MSCoreExtern unichar utf8JsonStringChaiP(         const void *src, NSUInteger *pos);
// For UTF8 and UTF8 JSON String encoding.
// These chai returns 0x00 on badly-formed character. And pos-1 is the error position.
// if you're not sure that the string is well-formed
// add a 0x00 character at the end of the string to avoid crash.

// SES (String Enumerator S...) représente l'accès à une source que l'on peut
// parcourir grâce à sa fonction 'chai'
// qu'on limite volontairement à l'intervalle [start, start+length[
// Attention, les chai NE vérifie PAS que la 'pos' donnée est bien dans
// l'intervalle [start, start+length[.

typedef struct SESStruct {
  const void *source;
  CHAI chai;
  CHAI chaip;
  NSUInteger start;
  NSUInteger length;
  NSStringEncoding encoding;}
SES;

MSCoreExtern const SES MSInvalidSES;

static inline SES MSMakeSES(const void *source, CHAI chai, CHAI chaip, NSUInteger start, NSUInteger length, NSStringEncoding encoding)
{
  SES ret;
  ret.source=   source;
  ret.chai=     chai;
  ret.chaip=    chaip;
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

// TODO: A revoir avec des const void *
//unichar        CEncodingToUnicode(unsigned short c, NSStringEncoding encoding);
//unsigned short CUnicodeToEncoding(unichar        u, NSStringEncoding encoding);
MSCoreExtern SES MSMakeSESWithSytes(const void *sytes, NSUInteger sytesLength, NSStringEncoding sourceEncoding);
MSCoreExtern SES MSMakeSESWithBytes(const void *bytes, NSUInteger sytesLength, NSStringEncoding sourceEncoding);
// Use this function to make a SES from a source.
// To obtain the unichar suite equivalent to a source use:
// SES ses= MSMakeSESWithBytes(cmySource, mySourceLength, mySourceEncoding);
// NSUInteger i,e; unichar u;
// for (i= SESStart(ses), e= SESEnd(ses); i<e;) u= SESIndexN(ses, &i);
// Or CCreateStringWithBytes()

MSCoreExtern BOOL SESEquals(SES a, SES b);
MSCoreExtern BOOL SESInsensitiveEquals(SES a, SES b);

MSCoreExtern NSComparisonResult SESCompare(SES a, SES b);
MSCoreExtern NSComparisonResult SESInsensitiveCompare(SES a, SES b);

MSCoreExtern SES SESFind(SES src, SES searched);
MSCoreExtern SES SESInsensitiveFind(SES src, SES searched);

MSCoreExtern SES SESCommonPrefix(SES src, SES comparator);
MSCoreExtern SES SESInsensitiveCommonPrefix(SES src, SES comparator);

MSCoreExtern SES SESCommonSuffix(SES src, SES comparator);
MSCoreExtern SES SESInsensitiveCommonSuffix(SES src, SES comparator);
// Retourne en tant que SES sur src le plus grand préfixe entre les deux chaînes.
// Retourne MSInvalidSES si pas de préfixe commun.

MSCoreExtern SES SESExtractPart(SES src, CUnicharChecker matchingChar);

MSCoreExtern SES SESWildcardsExtractPart(SES src, const char *utf8Wildcards);
MSCoreExtern SES SESInsensitiveWildcardsExtractPart(SES src, const char *utf8Wildcards);

// TODO: Need utf8 SESIndexP NOT TESTED

// Si 'leftSpaces' est NULL, il est remplacé par CUnicharIsSpace.
// Retourne un SES de 'src' sans les 'leftSpaces', avec les caractères qui matchent
// avec 'matchingChar'.
// Ex: ('  123zehgf',CUnicharIsDigit,NULL) -> '123'
MSCoreExtern SES SESExtractToken(SES src, CUnicharChecker matchingChar, CUnicharChecker leftSpaces);

// Identique à CCreateDecimalWithSES mmais ecrite comme une SESEXtract... fonction.
// Extrait un décimal, ou juste sa partie entière si intOnly=YES.
// Le SES retourné est la chaine contenant le nombre sans les leftSpaces.
// Si le nombre est bien formé, le décimal correspondant est retourné dans decimalPtr.
// Il doit être libéré par l'appelant.
struct CDecimalStruct;
MSCoreExtern SES SESExtractDecimal(SES src, BOOL intOnly, CUnicharChecker leftSpaces, struct CDecimalStruct**decimalPtr);

MSCoreExtern NSUInteger SESHash(SES ses);

static inline BOOL SESCHAIOK(CHAI chai) { return chai != InvalidCHAI; }
static inline BOOL SESOK(SES ses) { return
  (ses.source != NULL) && SESCHAIOK(ses.chai) && SESCHAIOK(ses.chaip) &&
  (ses.start != NSNotFound) && (ses.length > 0); }
static inline const void*      SESSource   (SES ses) { return ses.source; }
static inline NSStringEncoding SESEncoding (SES ses) { return ses.encoding; }
static inline CHAI             SESCHAI     (SES ses) { return ses.chai; }
static inline CHAI             SESCHAIP    (SES ses) { return ses.chaip; }
static inline NSUInteger       SESStart    (SES ses) { return ses.start; }
static inline NSUInteger       SESLength   (SES ses) { return ses.length; }
static inline NSUInteger       SESEnd      (SES ses) { return ses.start + ses.length; }
#define SESSetStart(ses, start) SESPSetStart(&ses, start)
#define SESSetLength(ses, length) SESPSetLength(&ses, length)
#define SESSetEnd(ses, end) SESPSetEnd(&ses, end)
static inline void SESPSetStart (SES *pses, NSUInteger start ) { pses->length+= pses->start - start; pses->start= start; }
static inline void SESPSetLength(SES *pses, NSUInteger length) { pses->length= length; }
static inline void SESPSetEnd   (SES *pses, NSUInteger end   ) { pses->length= end - pses->start; }
static inline unichar SESIndexN(SES ses, NSUInteger *pos) {
  //assert(*pos >= SESStart(ses));
  //assert(*pos < SESEnd(ses));
  return ses.chai(ses.source,pos);}
static inline unichar SESIndexP(SES ses, NSUInteger *pos) {
  //assert(*pos > SESStart(ses));
  //assert(*pos <= SESEnd(ses));
  return ses.chaip(ses.source,pos);}

#endif /* MSCORE_SES_H */

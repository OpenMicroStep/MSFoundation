/* MSCoreTools.h
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
 Eric Baradat :  k18rt@free.fr
 Jean-Michel Bertheas :  jean-michel.bertheas@club-internet.fr
 
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

#ifndef MS_CORE_TOOLS_H
#define MS_CORE_TOOLS_H

#pragma mark ***** Checksum

MSCoreExtern MSUShort MSBytesSmallCRC    (const void *sbytes, NSUInteger slen);
MSCoreExtern MSUInt   MSBytesLargeCRC    (const void *sbytes, NSUInteger slen);
MSCoreExtern MSUInt   MSBytesELF         (const void *sbytes, NSUInteger slen);
MSCoreExtern MSUInt   MSBytesUppercaseELF(const void *sbytes, NSUInteger slen);
MSCoreExtern MSUInt   MSBytesAdlerHash(MSULong adler, const void *sbytes, NSUInteger slen);
MSCoreExtern MSUInt   MSBytesFastHash    (const void *sbytes, NSUInteger slen);

MSCoreExtern NSUInteger  MSPointerHash(void *pointer);

#pragma mark ***** Compress

typedef enum {
  MSCompressError= -1,
  MSCompressOK=     0,
  MSBufferOverflow= 1}
MSCompressResult;

MSCoreExtern NSUInteger        MSCompressBound(NSUInteger sourceLen);
MSCoreExtern MSCompressResult  MSCompress  (void *destination, NSUInteger *destinationLen, const void *source, NSUInteger sourceLen);
MSCoreExtern MSCompressResult  MSUncompress(void *destination, NSUInteger *destinationLen, const void *source, NSUInteger sourceLen);

#pragma mark ***** Sort

MSCoreExtern void MSSort(void **ps, NSUInteger count, NSComparisonResult (*compareFunction)(void*, void*, void*), void *context);

#pragma mark ***** Hexa

MSCoreExtern MSULong MSHexaStringToULong(const char *src, NSUInteger srcLen);
// If srcLen is 0, it is calculated with strlen
// Return the value of 'src' in base 16.
// No space, no '-' or '0x' or 'u'.

#endif // MS_CORE_TOOLS_H

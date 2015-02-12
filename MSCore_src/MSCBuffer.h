/* MSCBuffer.h
 
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

#ifndef MSCORE_BUFFER_H
#define MSCORE_BUFFER_H

typedef struct CBufferFlagsStruct {
  MSUInt noFree:1;
  MSUInt :31;
  }
  CBufferFlags;

typedef struct CBufferStruct {
  MSCORE_NSOBJECT_ATTRIBUTES
  MSByte *buf;
  NSUInteger   size;
  NSUInteger   length;
  CBufferFlags flags;}
CBuffer;

  MSCoreExtern void       CBufferFreeInside(id self); // for MSBuffer dealloc
MSCoreExtern void CBufferInitWithBytes(CBuffer *self, void *bytes, NSUInteger length, BOOL noCopy, BOOL noFree);
//Already defined in MSCObject.h
//MSCoreExtern void       CBufferFree(id self);
//MSCoreExtern BOOL       CBufferIsEqual(id self, id other);
//MSCoreExtern NSUInteger CBufferHash(id self, unsigned depth);
//MSCoreExtern id         CBufferCopy(id self);

MSCoreExtern BOOL CBufferEquals(const CBuffer *self, const CBuffer *anotherBuffer);

MSCoreExtern CBuffer *CCreateBuffer(NSUInteger capacity);
MSCoreExtern CBuffer *CCreateBufferWithBytes(const void *bytes, NSUInteger length);
MSCoreExtern CBuffer *CCreateBufferWithBytesNoCopy(void *bytes, NSUInteger length);
  // 'bytes' is supposed 'length' sized. The buffer takes the ownership of
  // 'bytes' and frees it at end. It also can be reallocated on append.
MSCoreExtern CBuffer *CCreateBufferWithBytesNoCopyNoFree(const void *bytes, NSUInteger length);
  // The returned buffer is immutable.
  // 'bytes' is supposed 'length' sized. The buffer doesn't take the ownership
  // of 'bytes' and doesn't free it at end. It can NOT be reallocated so
  // appending is forbidden and an exception is raised.
MSCoreExtern CBuffer *CCreateBufferWithString(const CString *s, NSStringEncoding destinationEncoding);

MSCoreExtern void CBufferGrow(CBuffer *self, NSUInteger n);
MSCoreExtern void CBufferAdjustSize(CBuffer *self);

MSCoreExtern NSUInteger CBufferLength(const CBuffer *self);
MSCoreExtern MSByte     CBufferByteAtIndex(const CBuffer *self, NSUInteger i);
MSCoreExtern MSByte    *CBufferBytes(const CBuffer *self);
MSCoreExtern MSByte    *CBufferCString(CBuffer *self);
// Make sure buf ends with 0x00 before returning the buf.

MSCoreExtern NSUInteger CBufferIndexOfByte          (const CBuffer *self, MSByte c);
MSCoreExtern NSUInteger CBufferIndexOfBytes         (const CBuffer *self, void *sbytes, NSUInteger slen);
MSCoreExtern NSUInteger CBufferIndexOfBytesInRange  (const CBuffer *self, void *sbytes, NSUInteger slen, NSRange searchRange);
MSCoreExtern NSUInteger CBufferIndexOfCString       (const CBuffer *self, char *cString);
MSCoreExtern NSUInteger CBufferIndexOfCStringInRange(const CBuffer *self, char *cString                , NSRange searchRange);

MSCoreExtern void CBufferAppendBuffer (CBuffer *self, const CBuffer *s);
MSCoreExtern void CBufferAppendCString(CBuffer *self, const char *myStr);
MSCoreExtern void CBufferAppendBytes  (CBuffer *self, const void *bytes, NSUInteger length);
MSCoreExtern void CBufferAppendByte   (CBuffer *self, MSByte c);
MSCoreExtern void CBufferFillWithByte (CBuffer *self, MSByte c, NSUInteger nb);
MSCoreExtern void CBufferAppendSES    (CBuffer *self, SES ses, NSStringEncoding destinationEncoding);
// Only UTF8 for destinationEncoding at this time
// or NSUnicodeStringEncoding IN THE SAME endianness than the ses encoding
MSCoreExtern void CBufferAppendString (CBuffer *self, const CString *s, NSStringEncoding destinationEncoding);
// See CBufferAppendSES

MSCoreExtern void CBufferAppendContentsOfFile(CBuffer *self, SES path);
MSCoreExtern void CBufferSetBytes(CBuffer *self, const void *ptr, NSUInteger length);

MSCoreExtern void CBufferBase64EncodeAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len);
MSCoreExtern BOOL CBufferBase64DecodeAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len);

MSCoreExtern void CBufferBase64URLEncodeAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len);
MSCoreExtern BOOL CBufferBase64URLDecodeAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len);

MSCoreExtern BOOL CBufferCompressAndAppendBytes  (CBuffer *self, const void *bytes, NSUInteger len);
MSCoreExtern BOOL CBufferDecompressAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len);

// @function MSCoreExtern BOOL CBufferAppendUniqueID(MSUInt domainID, MSUInt dealerID, MSUInt clientID);
// suggestion : use MSCurrentProcessID(), MSCurrentThreadID(), MSCurrentHostID(), MSUnsignedRandom(), nowGMT() + the parameters, salt it and mix all in at least a 32 bytes string

// @function MSCoreExtern BOOL CBufferAppendWithSES(CBuffer *self, SES enumerator, const void *source, NSStringEncoding destinationEncoding, BOOL strict);
// not so simple to do...

#endif

/* MSCBuffer.c
 
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

#pragma mark c-like class methods

MSExport void CBufferFreeInside(id self)
{
  if (self && !((CBuffer*)self)->flags.noFree) {
    MSFree(((CBuffer*)self)->buf, "CBufferFreeInside() [memory]");}
}
void CBufferFree(id self)
{
  CBufferFreeInside(self);
  MSFree(self, "CBufferFree() [self]");
}

BOOL CBufferIsEqual(id self, id other)
{
  return _CClassIsEqual(self,other,(CObjectEq)CBufferEquals);
}

NSUInteger CBufferHash(id self, unsigned depth)
{
  return (!self || !((CBuffer*)self)->length) ? 0 :
    (NSUInteger)MSBytesELF(((CBuffer*)self)->buf, ((CBuffer*)self)->length);
  depth= 0; // no warning
}

id CBufferCopy(id self)
{
  CBuffer *b;
  if (!self) return nil;
  b= (CBuffer*)MSCreateObjectWithClassIndex(CBufferClassIndex);
  if (b) CBufferAppendBuffer(b, (const CBuffer*)self);
  return (id)b;
}

#pragma mark Equality

BOOL CBufferEquals(const CBuffer *self, const CBuffer *anotherBuffer)
{
  if (self == anotherBuffer) return YES;
  if (self && anotherBuffer) {
    NSUInteger len= self->length * sizeof(char);
    return len == anotherBuffer->length && !memcmp(self->buf, anotherBuffer->buf, len) ? YES : NO;
  }
  return NO;
}

#pragma mark Creation

CBuffer *CCreateBuffer(NSUInteger capacity)
{
  CBuffer *b= (CBuffer*)MSCreateObjectWithClassIndex(CBufferClassIndex);
  CBufferGrow(b, capacity);
  return b;
}

// CBuffer *CCreateBufferWithBytes(const void *bytes, NSUInteger length)
// Coded with append fcts.

CBuffer *CCreateBufferWithBytesNoCopy(void *bytes, NSUInteger length)
{
  CBuffer *b= (CBuffer*)MSCreateObjectWithClassIndex(CBufferClassIndex);
  b->buf=    (MSByte*)bytes;
  b->length= length;
  b->size=   length;
  return b;
}

CBuffer *CCreateBufferWithBytesNoCopyNoFree(const void *bytes, NSUInteger length)
{
  CBuffer *b= (CBuffer*)MSCreateObjectWithClassIndex(CBufferClassIndex);
  b->buf=    (MSByte*)bytes;
  b->length= length;
  b->size=   length;
  b->flags.noFree= 1;
  return b;
}

CBuffer *CCreateBufferWithString(const CString *s, NSStringEncoding destinationEncoding)
{
  CBuffer *b= (CBuffer*)MSCreateObjectWithClassIndex(CBufferClassIndex);
  CBufferAppendString(b, s, destinationEncoding);
  return b;
}

#pragma mark Management

void CBufferGrow(CBuffer *self, NSUInteger n)
{
  _CClassGrow((id)self, n, self->length, sizeof(MSByte), &self->size, (void**)&self->buf);
}

void CBufferAdjustSize(CBuffer *self)
{
  _CClassAdjustSize((id)self, self->length, sizeof(MSByte), &self->size, (void**)&self->buf);
}

MSByte *CBufferCString(CBuffer *self)
{
  if (!self || !self->length) return (MSByte*)"";
  CBufferGrow(self, 1);
  self->buf[self->length]= 0x00;
  return self->buf;
}

NSUInteger CBufferLength(const CBuffer *self)
{
  return (self ? self->length : 0);
}

MSByte CBufferByteAtIndex(const CBuffer *self, NSUInteger i)
{
  if (!self || i >= self->length) return (MSByte)0;
  return self->buf[i];
}

NSUInteger CBufferIndexOfByte(const CBuffer *self, MSByte c)
{
  if (self) {
    register NSUInteger i, l = self->length;
    for (i = 0; i < l; i++) { if (self->buf[i] == c) return i; }
  }
  return NSNotFound;
}

NSUInteger CBufferIndexOfBytes(const CBuffer *self, void *sbytes, NSUInteger slen)
{ return self ? CBufferIndexOfBytesInRange(self, sbytes, slen, NSMakeRange(0, self->length)) : NSNotFound; }

NSUInteger CBufferIndexOfBytesInRange(const CBuffer *self, void *sbytes, NSUInteger slen, NSRange rg)
{
  NSUInteger len, found= 0;
  if (self && sbytes && slen > 0 && rg.location <= (len= self->length) &&
      rg.location+slen <= len) {    
    if ((rg.location + rg.length) > len) rg.length= len-rg.location;
    if (slen <= rg.length) {
      MSByte *s;
      MSByte *start= self->buf + rg.location;
      MSByte *end= start + rg.length - 1;
      for (s= start; s <= end; s++) {
        if (*s == ((MSByte*)sbytes)[found]) {
          found++;
          if (found == slen) {
            return (NSUInteger)s - (NSUInteger)self->buf - found + 1;}}
        else found= 0;}}}
  return NSNotFound;
}

NSUInteger CBufferIndexOfCString(const CBuffer *self, char *cString)
{ return self && cString ? CBufferIndexOfBytesInRange(self, (void *)cString, strlen(cString), NSMakeRange(0, self->length)) : NSNotFound; }

NSUInteger CBufferIndexOfCStringInRange(const CBuffer *self, char *cString, NSRange searchRange)
{ return self && cString ? CBufferIndexOfBytesInRange(self, (void *)cString, strlen(cString), searchRange) : NSNotFound; }

#pragma mark Append

static inline void _append(CBuffer *self, const void *ptr, NSUInteger length)
{
  if (self && ptr && length) {
    if (self->flags.noFree) { // immutable
      MSReportError(MSInvalidArgumentError, MSFatalError, MSIndexOutOfRangeError,
        "CBufferAppend...(): try to append on immutable buffer.");
      return;}
    CBufferGrow(self, length);
    memmove(self->buf+self->length, ptr, length);
    self->length+= length;}
}

CBuffer *CCreateBufferWithBytes(const void *bytes, NSUInteger length)
{
  CBuffer *b= CCreateBuffer(0);
  _append(b, bytes, length);
  return b;
}

void CBufferAppendBuffer(CBuffer *self, const CBuffer *s)
{
  if (s) _append(self, s->buf, s->length);
}

void CBufferAppendCString(CBuffer *self, const char *myStr)
{
  if (myStr) _append(self, myStr, strlen(myStr));
}

void CBufferAppendBytes(CBuffer *self, const void *bytes, NSUInteger length)
{
  _append(self, bytes, length);
}

void CBufferAppendByte(CBuffer *self, MSByte c)
{
  _append(self, &c, 1);
}

void CBufferFillWithByte(CBuffer *self, MSByte c, NSUInteger nb)
{
  if (self && nb) {
    register NSUInteger i;
    CBufferGrow(self, nb);
    for (i= 0; i < nb; i++) self->buf[self->length++]= c;}
}

void CBufferAppendSES(CBuffer *self, SES ses, NSStringEncoding destinationEncoding)
// Only UTF8 and NSUnicodeStringEncoding. TODO: Use a CHAI-1
{
  NSUInteger i,end,u8n;
  unichar u;
  MSByte u8[3];
  if (destinationEncoding==NSUnicodeStringEncoding) {
    if (ses.encoding==NSUnicodeStringEncoding) {
      _append(self, SESSource(ses), SESLength(ses)*sizeof(unichar));}
    else for (i= SESStart(ses), end= SESEnd(ses); i < end;) {
      u= SESIndexN(ses, &i);
      _append(self, &u, sizeof(unichar));}}
  else if (destinationEncoding==NSUTF8StringEncoding) {
    for (i= SESStart(ses), end= SESEnd(ses); i < end;) {
      u= SESIndexN(ses, &i);
      if (u<0x0080) {u8[0]= (MSByte)u; u8n= 1;}
      else if (u<0x0800) {
        u8[1]= (MSByte)(u & 0x003F) | 0x80; u>>= 6;
        u8[0]= (MSByte)(u & 0x001F) | 0xC0; u8n= 2;}
      else {
        u8[2]= (MSByte)(u & 0x003F) | 0x80; u>>= 6;
        u8[1]= (MSByte)(u & 0x003F) | 0x80; u>>= 6;
        u8[0]= (MSByte)(u & 0x000F) | 0xE0; u8n= 3;}
      _append(self, u8, u8n);}}
}

void CBufferAppendString(CBuffer *self, const CString *s, NSStringEncoding destinationEncoding)
{
  if (s) CBufferAppendSES(self, MSSSES(s), destinationEncoding);
}

/*
 MSExport BOOL CBufferAppendWithSES(CBuffer *self, SES enumerator, const void *source, NSStringEncoding destinationEncoding, BOOL strict)
 {
 switch (destinationEncoding) {
 case NSUTF8StringEncoding:
 return CBufferAppendUTF8WithSES(self, enumerator, source);
 case NSNonLossyASCIIStringEncoding:
 strict = YES;
 case NSASCIIStringEncoding:
 if (strict) {
 }
 else {
 }
 case NSISOLatin1StringEncoding:
 break;
 case NSUnicodeStringEncoding:
 return _CBufferAppendUnicode(self, enumerator, source, NO); // we don't swap
 case NSUTF16BigEndianStringEncoding:
 return _CBufferAppendUnicode(self, enumerator, source, MSCurrentByteOrder() == MSLittleEndian ? YES : NO);
 case NSUTF16LittleEndianStringEncoding:
 return _CBufferAppendUnicode(self, enumerator, source, MSCurrentByteOrder() == MSBigEndian ? YES : NO);
 default:
 return NO;
 }
 }
 */

#pragma mark Base64

static const MSByte  __cb64[64]=    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const MSByte  __cb64URL[64]= "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

static inline void _CBase64Encode(CBuffer *self, const MSByte *base64, MSByte paddingChar, const void *bytes, NSUInteger len)
{
  if (self && bytes && len) {
    MSByte *buffer = (MSByte *)bytes;
    while (len > 2) {
      CBufferAppendByte(self, base64[(buffer[0] & 0xfc) >> 2]);
      CBufferAppendByte(self, base64[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xf0) >> 4)]);
      CBufferAppendByte(self, base64[((buffer[1] & 0x0f) << 2) | ((buffer[2] & 0xc0) >> 6)]);
      CBufferAppendByte(self, base64[buffer[2] & 0x3f]);
      buffer += 3;
      len -= 3;
    }
    switch (len) {
      case 1:
        CBufferAppendByte(self, base64[(buffer[0] & 0xfc) >> 2]);
        CBufferAppendByte(self, base64[((buffer[0] & 0x03) << 4)]);
        CBufferAppendByte(self, paddingChar);
        CBufferAppendByte(self, paddingChar);
        break;
      case 2:
        CBufferAppendByte(self, base64[(buffer[0] & 0xfc) >> 2]);
        CBufferAppendByte(self, base64[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xf0) >> 4)]);
        CBufferAppendByte(self, base64[((buffer[1] & 0x0f) << 2)]);
        CBufferAppendByte(self, paddingChar);
        break;
      default:
        break;
    }
  }
}

static const short __cd64[256]= {
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -2, -1, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
  52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
  -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
  -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2};

static const short __cd64URL[256] = {
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -2, -1, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2,
  52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
  -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, 63,
  -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2};

static inline BOOL _CBase64Decode(CBuffer *self, const short *base64, MSByte paddingChar, const void *bytes, NSUInteger len)
{
  if (self && bytes) {
    MSByte c = 0, *buffer = (MSByte *)bytes;
    NSUInteger lengthBeforeAppend = self->length, i = 0;
    short dc;
    MSByte result[3];
    
    result[0] = result[1] = result[2] = 0;
    
    while (len-- > 0 && (c = *buffer++) != 0) {
      if (c == paddingChar) break;
      dc = base64[(int)c];
      if (dc == -1) continue; /* we skip spaces and separators */
      if (dc == -2) { self->length = lengthBeforeAppend; return NO; }
      
      switch(i % 4) {
        case 0: result[0] = (MSByte)(dc << 2);
          break;
        case 1:
          result[0] |= dc >> 4;
          result[1] = (MSByte)((dc & 0x0f) << 4);
          break;
        case 2:
          result[1] |= dc >>2;
          result[2] = (MSByte)((dc & 0x03) << 6);
          break;
        case 3:
          result[2] |= dc; /* our trigram is complete*/
          CBufferAppendBytes(self, result, 3);
          result[0] = result[1] = result[2] = 0;
          break;
      }
      i++;
    }
    if (c == paddingChar) {
      i = i % 4;
      if (i == 1) {
        self->length = lengthBeforeAppend;
        return NO;
      }
      else if (i > 0) {
        CBufferAppendBytes(self, result, i-1);
      }
    }
    return YES;
  }
  return NO;
}

void CBufferBase64EncodeAndAppendBytes   (CBuffer *self, const void *bytes, NSUInteger len)
{ _CBase64Encode(self, __cb64,    (MSByte)'=', bytes, len); }
void CBufferBase64URLEncodeAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len)
{ _CBase64Encode(self, __cb64URL, (MSByte)'=', bytes, len); }
BOOL CBufferBase64DecodeAndAppendBytes   (CBuffer *self, const void *bytes, NSUInteger len)
{ return _CBase64Decode(self, __cd64,    (MSByte)'=', bytes, len); }
BOOL CBufferBase64URLDecodeAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len)
{ return _CBase64Decode(self, __cd64URL, (MSByte)'=', bytes, len); }

#pragma mark Compress

BOOL CBufferCompressAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len)
{
  MSCompressResult result = MSCompressOK;
  if (self && bytes && len) {
    NSUInteger guessedSize = MSCompressBound(len), compressedLength = guessedSize;
    void *destination = (void *)MSMalloc(guessedSize, "CBufferCompressAndAppendBytes() allocation");
    if (!destination) { result = MSCompressError; }
    else {
      result = MSCompress(destination, &compressedLength, bytes, len);
      if (result == MSCompressOK) {
        CBufferAppendBytes(self, destination, compressedLength);}
      MSFree(destination, "CBufferCompressAndAppendBytes() free");}}
  return result == MSCompressOK ? YES : NO;
}

BOOL CBufferDecompressAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len)
{
  MSCompressResult result = MSCompressOK;
  if (self && bytes && len) {
    NSUInteger destLenIn = len*3 + 10, destLen;
    void *newDest, *dest = (void *)MSMalloc(destLenIn, "CBufferDecompressAndAppendBytes() allocation");
    
    result = MSBufferOverflow;
    
    while (dest) {
      destLen = destLenIn;
      result = MSUncompress(dest, &destLen, bytes, len);
      
      if (result == MSCompressOK || result != MSBufferOverflow) break;
      destLenIn += len*2+10;
      
      newDest = MSRealloc(dest, destLenIn, "CBufferDecompressAndAppendBytes() reallocation");
      if (!newDest) { result = MSCompressError; break; }
      dest = newDest;
    }
    if (result == MSCompressOK) {
      CBufferAppendBytes(self, dest, destLen);}
    
    MSFree(dest, "CBufferDecompressAndAppendBytes() free");
    
  }
  return result == MSCompressOK ? YES : NO;
}

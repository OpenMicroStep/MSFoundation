/*   MSCUnicodeBuffer.h
 
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

#ifndef MSBase_MSCUnicodeBuffer_h
#define MSBase_MSCUnicodeBuffer_h

typedef struct CUnicodeBufferStruct {
  Class      isa;
#ifdef MSCORE_STANDALONE
  NSUInteger refCount;
#endif
  unichar*   buf;
  NSUInteger length;
  NSUInteger size;}
CUnicodeBuffer;


static inline BOOL CUnicodeBufferGrow(CUnicodeBuffer *self, NSUInteger n)
{
  if (self && n) {
    NSUInteger newSize = MSCapacityForCount(self->size + n);
    if (self->buf) {
      if (!(self->buf = MSRealloc(self->buf, newSize * sizeof(unichar), "CUnicodeBufferGrow()"))) return NO;
      else self->size = newSize;
    }
    else {
      if (!(self->buf = MSMalloc(newSize * sizeof(unichar), "CUnicodeBufferGrow()"))) return NO;
      else self->size = newSize;
    }
  }
  return YES;
}

static inline NSUInteger CUnicodeBufferLength(const CUnicodeBuffer *self) { return (self ? self->length : 0); }
static inline unichar CUnicodeBufferCharacterAtIndex(const CUnicodeBuffer *self, NSUInteger i)
{
  if (!self || i >= self->length) return (unichar)0;
  return self->buf[i];
}

static inline BOOL CUnicodeBufferEquals(const CUnicodeBuffer *self, const CUnicodeBuffer *anotherBuffer)
{
  if (self == anotherBuffer) return YES;
  if (self && anotherBuffer) {
    NSUInteger len = self->length;
    return len == anotherBuffer->length && !memcmp(self->buf, anotherBuffer->buf, len * sizeof(unichar)) ? YES : NO;
  }
  return NO;
}

static inline BOOL CUnicodeBufferInsensitiveEquals(const CUnicodeBuffer *self, const CUnicodeBuffer *anotherBuffer)
{
  if (self == anotherBuffer) return YES;
  if (self && anotherBuffer) {
    NSUInteger len = self->length;
    return len == anotherBuffer->length && CUnicharsInsensitiveEquals(self->buf, anotherBuffer->buf, len) ? YES : NO;
  }
  return NO;
}

static inline BOOL CUnicodeBufferAppendUnicodeBuffer(CUnicodeBuffer *self, const CUnicodeBuffer *s)
{
  if (self && s && s->length) {
    if (self->length + s->length > self->size && !CUnicodeBufferGrow(self, s->length)) return NO;
    memmove(self->buf+self->length, s->buf, s->length*sizeof(unichar));
    self->length += s->length;
  }
  return YES;
}

static inline BOOL CUnicodeBufferAppendISOLatin1CString(CUnicodeBuffer *self, const char *s)
{
  if (self && s) {
    register NSUInteger length = (NSUInteger)strlen(s);
    if (length) {
      register NSUInteger i;
      if (self->length + length > self->size && !CUnicodeBufferGrow(self, length)) return NO;
      for (i= 0; i < length; i++) { self->buf[self->length++]= (unichar)s[i]; }
    }
  }
  return YES;
}

// with this one, we only need to have a String Enumeration Structure to add any source (even a CString)
static inline BOOL CUnicodeBufferAppendWithSES(CUnicodeBuffer *self, SES ses, const void *source)
{
  if (self && source && SESOK(ses)) {
    register NSUInteger i, end = ses.start + ses.length;
    
    if (self->length + ses.length > self->size && !CUnicodeBufferGrow(self, ses.length)) return NO;
    for (i = ses.start; i < end; i++) { self->buf[self->length++] = SESIndex(ses, source, i); }
  }
  return YES;
}

static inline BOOL CUnicodeBufferAppendCharacters(CUnicodeBuffer *self, const unichar *characters, NSUInteger length)
{
  if (self && length && characters) {
    if (self->length + length > self->size && !CUnicodeBufferGrow(self, length)) return NO;
    memmove(self->buf+self->length, characters, length*sizeof(unichar));
    self->length += length;
  }
  return YES;
}

static inline BOOL CUnicodeBufferAppendCharacter(CUnicodeBuffer *self, unichar c)
{
  if (self) {
    if (self->length >= self->size && !CUnicodeBufferGrow(self, 1)) return NO;
    self->buf[self->length++] = c;
  }
  return YES;
}

static inline BOOL CUnicodeBufferAppendCharacterSuite(CUnicodeBuffer *self, unichar c, NSUInteger nb)
{
  if (self && nb) {
    register NSUInteger i;
    if (self->length + nb > self->size && !CUnicodeBufferGrow(self, nb)) return NO;
    for (i = 0; i < nb; i++) self->buf[self->length++] = c;
  }
  return YES;
}

static inline NSUInteger CUnicodeBufferIndexOfCharacter(const CUnicodeBuffer *self, unichar c)
{
  if (self) {
    NSUInteger i, l = self->length;
    for (i = 0; i < l; i++) { if (self->buf[i] == c) return i; }
  }
  return NSNotFound;
}

MSExport BOOL CUnicodeBufferAppendUTF8Bytes(CUnicodeBuffer *self, const void *bytes, NSUInteger length);
MSExport BOOL CUnicodeBufferAppendBytesWithEncoding(CUnicodeBuffer *self, const void *sourceBytes, NSUInteger sourceLength, NSStringEncoding sourceEncoding);

// this functions work only for ANSI, Mac roman, NextStep, ISO Latin 1, UTF8 and ASCII as supposed encoding
MSExport BOOL CUnicodeBufferAppendSupposedEncodingBytes(CUnicodeBuffer *self, const void *bytes, NSUInteger length, NSStringEncoding suposedEncoding, NSStringEncoding *foundEncodingPointer);
// if you don't know what encoding you've got from your internet source, try UTF8 as supposed encoding
MSExport BOOL CUnicodeBufferAppendInternetBytes(CUnicodeBuffer *self, const void *bytes, NSUInteger len, NSStringEncoding suposedEncoding, NSStringEncoding *foundEncodingPointer);
// same remark. this function decodes URL encoding scheme in the supposed encoding
MSExport BOOL CUnicodeBufferAppendURLBytes(CUnicodeBuffer *self, const void *bytes, NSUInteger len, NSStringEncoding suposedEncoding, NSStringEncoding *foundEncodingPointer);

//MSExport BOOL CUnicodeBufferAppendTimeInterval(CUnicodeBuffer *self, MSTimeInterval interval, const char *utf8StringFormat, MSLanguage language);

MSExport BOOL CUnicodeBufferAppendTextNumber(CUnicodeBuffer *self, MSLong n, MSLanguage language);

#define MSUAdd(       X, Y) CUnicodeBufferAppendUnicodeBuffer((CUnicodeBuffer *)(X), Y)
#define MSUAddUnichar(X, Y) CUnicodeBufferAppendCharacter((CUnicodeBuffer *)(X), Y)
#define MSUAddString( X, Y) CUnicodeBufferAppendString((CUnicodeBuffer *)(X), (NSString *)(Y))
#define MSULength(    X   ) CUnicodeBufferLength((const CUnicodeBuffer *)(X))
#define MSUIndex(     X, Y) (((CUnicodeBuffer*)(X))->buf[(Y)])

/************************** TO DO IN THIS FILE  ****************
 
 *************************************************************/

#endif

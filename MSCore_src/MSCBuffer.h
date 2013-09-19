/*
 
 MSCBuffer.h
 
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

typedef struct CBufferStruct {
	Class isa ;
#ifdef MSCORE_STANDALONE
	NSUInteger refCount ;
#endif
    MSByte *buf ;
    NSUInteger length ;
    NSUInteger size ;
} CBuffer ;


static inline BOOL CBufferGrow(CBuffer *self, NSUInteger n)
{
    if (self && n) {
        NSUInteger newSize = MSCapacityForCount(self->size + n) ;
		
        if (self->buf) {
			if (!(self->buf = (MSByte *)MSRealloc(self->buf, newSize, "CBufferGrow()"))) return NO ;
			else self->size = newSize ;
		}
        else {
			if (!(self->buf = (MSByte *)MSMalloc(newSize, "CBufferGrow()"))) return NO ;
			else self->size = newSize ;
        }
    }
    return YES ;
}


static inline BOOL CBufferAdjustSize(CBuffer *self)
{
	if (self && self->length < self->size) {
		if (self->length) {
			if (!(self->buf = (MSByte *)MSRealloc(self->buf, self->length, "CBufferShrink()"))) return NO ;
			else self->size = self->length ;
		}
		else {
			MSFree(self->buf, "CBufferAdjustSize()") ; self->buf = NULL ;
			self->size = 0 ;
		}
		
	}
	return YES ;
}

static inline BOOL CBufferExpand(CBuffer *self, NSUInteger lengthAddition)
{
    if (self && lengthAddition) {
        if (self->length + lengthAddition > self->size && !CBufferGrow(self, lengthAddition)) return NO ;
    }
    return YES ;
}

static inline BOOL CBufferEquals(const CBuffer *self, const CBuffer *anotherBuffer)
{
	if (self == anotherBuffer) return YES ;
	if (self && anotherBuffer) {
		NSUInteger len = self->length * sizeof(char) ;
		return len == anotherBuffer->length && !memcmp(self->buf, anotherBuffer->buf, len) ? YES : NO ;
	}
	return NO ;
}


static inline NSUInteger CBufferLength(const CBuffer *self) { return (self ? self->length : 0) ; }
static inline MSByte CBufferByteAtIndex(const CBuffer *self, NSUInteger i)
{
    if (!self || i >= self->length) return (MSByte)0 ;
    return self->buf[i] ;
}

static inline BOOL CBufferAppendBuffer(CBuffer *self, const CBuffer *s)
{
    if (self && s && s->length) {
        if (self->length + s->length > self->size && !CBufferGrow(self, s->length)) return NO ;
        memmove(self->buf+self->length, s->buf, s->length) ;
        self->length += s->length ;
    }
    return YES ;
}

static inline BOOL CBufferAppendCString(CBuffer *self, const char *myStr)
{
    NSUInteger length ;
    if (self && myStr && (length = (NSUInteger)strlen(myStr))) {
        if (self->length + length > self->size && !CBufferGrow(self, length)) return NO ;
        memmove(self->buf+self->length, myStr, length) ;
        self->length += length ;
    }
    return YES ;
}

static inline BOOL CBufferAppendBytes(CBuffer *self, const void *bytes, NSUInteger length)
{
    if (self && bytes && length) {
        if (self->length + length > self->size && !CBufferGrow(self, length)) return NO ;
        memmove(self->buf+self->length, bytes, length) ;
        self->length += length ;
    }
    return YES ;
}

#ifndef MSCORE_STANDALONE
static inline BOOL CBufferAppendData(CBuffer *self, NSData *d)
{
    if (self) {
        NSUInteger length = [d length] ;
        if (length) {
            if (self->length + length > self->size && !CBufferGrow(self, length)) return NO ;
            [d getBytes:(void *)(self->buf+self->length) range:NSMakeRange(0, length)] ;
            self->length += length ;
        }
    }
    return YES ;
}
#endif

static inline BOOL CBufferAppendBytesSuite(CBuffer *self, MSByte c, NSUInteger nb)
{
    if (self && nb) {
        register NSUInteger i ;
        if (self->length + nb > self->size && !CBufferGrow(self, nb)) return NO ;
        for (i = 0 ; i < nb ; i++) self->buf[self->length++] = c ;
    }
    return YES ;
}

static inline BOOL CBufferAppendByte(CBuffer *self, MSByte c)
{
    if (self) {
        if (self->length >= self->size && !CBufferGrow(self, 1)) return NO ;
        self->buf[self->length++] = c ;
    }
    return YES ;
}

static inline NSUInteger CBufferIndexOfByte(CBuffer *self, MSByte c)
{
    if (self) {
        register NSUInteger i, l = self->length ;
        for (i = 0 ; i < l ; i++) { if (self->buf[i] == c) return i ; }
    }
    return NSNotFound ;
}

static inline NSUInteger CBufferIndexOfBytesInRange(const CBuffer *self, NSRange searchRange, void *sbytes, NSUInteger slen)
{
	NSUInteger len ;
	if (self && sbytes && slen > 0 && slen <= (len = self->length)) {
		NSUInteger found = 0 ;
		
		if ((searchRange.location + searchRange.length) > len) {
			if (searchRange.length > len) { searchRange.location = 0 ; searchRange.length = len ; }
			else { searchRange.location = len - searchRange.length ; }
		}
		if (slen <= searchRange.length) {
			MSByte *s ;
			MSByte *start = self->buf + searchRange.location ;
			MSByte *end = start + searchRange.length - 1;
			for (s = start ; s <= end ; s ++) {
				if (*s == ((MSByte *)sbytes)[found]) {
					found ++ ;
					if (found == slen) {
						return s - start - found + 1 ;
					}
				}
				else found = 0 ;
			}
		}
		
	}
	return NSNotFound ;
}
static inline NSUInteger CBufferIndexOfBytes(const CBuffer *self, void *sbytes, NSUInteger slen)
{ return self ? CBufferIndexOfBytesInRange(self, NSMakeRange(0, self->length), sbytes, slen) : NSNotFound ; }

static inline NSUInteger CBufferIndexOfCStringInRange(const CBuffer *self, NSRange searchRange, char *cString)
{ return self && cString ? CBufferIndexOfBytesInRange(self, searchRange, (void *)cString, strlen(cString)) : NSNotFound ; }

static inline NSUInteger CBufferIndexOfCString(const CBuffer *self, char *cString)
{ return self && cString ? CBufferIndexOfBytesInRange(self, NSMakeRange(0, self->length), (void *)cString, strlen(cString)) : NSNotFound ; }

MSExport BOOL CBufferBase64EncodeAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len) ;
MSExport BOOL CBufferBase64DecodeAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len) ;

MSExport BOOL CBufferBase64URLEncodeAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len) ;
MSExport BOOL CBufferBase64URLDecodeAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len) ;

MSExport BOOL CBufferCompressAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len) ;
MSExport BOOL CBufferDecompressAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len) ;

// @function MSExport BOOL CBufferAppendUniqueID(MSUInt domainID, MSUInt dealerID, MSUInt clientID) ;
// suggestion : use MSCurrentProcessID(), MSCurrentThreadID(), MSCurrentHostID(), MSUnsignedRandom(), nowGMT() + the parameters, salt it and mix all in at least a 32 bytes string

// @function MSExport BOOL CBufferAppendWithSES(CBuffer *self, SES enumerator, const void *source, NSStringEncoding destinationEncoding, BOOL strict) ;
// not so simple to do...

#define MSBAddBuffer(X, Y)		CBufferAppendBuffer((CBuffer *)(X), (const CBuffer *)(Y))
#define MSBAddData(X, Y)		CBufferAppendData((CBuffer *)(X), (NSData *)(Y))
#define MSBAddByte(X, Y)		CBufferAppendByte((CBuffer *)(X), (MSByte)(Y))
#define MSBLength(X)			CBufferLength((const CBuffer *)(X))
#define MSBIndex(X,Y)			((CBuffer *)(X))->_buf[(Y)]

#endif

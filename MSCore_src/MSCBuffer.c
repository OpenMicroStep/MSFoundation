/*
 
 MSCBuffer.c
 
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
#ifdef MSCORE_STANDALONE
#include "_MSCorePrivate.h"
#include "_MSCBufferPrivate.h"

void CBufferFree(void *self) { if (self) { if (((CBuffer *)self)->buf) MSFree(((CBuffer *)self)->buf, "CBufferFree() [memory]") ;  MSFree(self, "CBufferFree() [self]") ; }}
BOOL CBufferIsEqual(void *self, void *other)
{
	if (self == other) { return YES ; } ;
	return	self && other &&
	((CBuffer *)self)->isa == ((CBuffer *)other)->isa &&
	CBufferEquals((CBuffer *)self, (CBuffer *)other) ? YES : NO ;
}

id	CBufferCopy(void *self)
{
	if (self) {
		CBuffer *newObject = (CBuffer *)MSCreateObjectWithClassIndex(CBufferClassIndex) ;
		if (newObject){ CBufferAppendBuffer(newObject, (const CBuffer *)self) ; }
		return (id)newObject ;
	}
	return nil ;
}

NSUInteger CBufferHash(void *self, unsigned depth)
{ return self && ((CBuffer *)self)->length ? (NSUInteger)MSBytesELF(((CBuffer *)self)->buf, ((CBuffer *)self)->length) : 0 ; }

#else
#import "_MSFoundationCorePrivate.h"
#import "_MSCBufferPrivate.h"
#endif


BOOL CBufferBase64EncodeAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len) { return _CBase64Encode(self, __cb64, (MSByte)'=', bytes, len) ; }
BOOL CBufferBase64URLEncodeAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len) { return _CBase64Encode(self, __cb64URL, (MSByte)'=', bytes, len) ; }
BOOL CBufferBase64DecodeAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len) { return _CBase64Decode(self, __cd64, (MSByte)'=', bytes, len) ; }
BOOL CBufferBase64URLDecodeAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len) { return _CBase64Decode(self, __cd64URL, (MSByte)'=', bytes, len) ; }

BOOL CBufferCompressAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len)
{
	MSCompressResult result = MSCompressOK ;
	if (self && bytes && len) {
		NSUInteger guessedSize = MSCompressBound(len), compressedLength = guessedSize ;
		void *destination = (void *)MSMalloc(guessedSize, "CBufferCompressAndAppendBytes() allocation") ;
		if (!destination) { result = MSCompressError ; }
		else {
			result = MSCompress(destination, &compressedLength, bytes, len) ;
			if (result == MSCompressOK) {
				if (!CBufferAppendBytes(self, destination, compressedLength)) result = MSCompressError ;
			}
			MSFree(destination, "CBufferCompressAndAppendBytes() free") ;
		}
		
	}
	return result == MSCompressOK ? YES : NO ;
}

BOOL CBufferDecompressAndAppendBytes(CBuffer *self, const void *bytes, NSUInteger len)
{
	MSCompressResult result = MSCompressOK ;
	if (self && bytes && len) {
		NSUInteger destLenIn = len*3 + 10, destLen ;
        void *newDest, *dest = (void *)MSMalloc(destLenIn, "CBufferDecompressAndAppendBytes() allocation") ;

		result = MSBufferOverflow ;
		
		while (dest) {
            destLen = destLenIn ;
            result = MSUncompress(dest, &destLen, bytes, len) ;
            
			if (result == MSCompressOK || result != MSBufferOverflow) break ;
            destLenIn += len*2+10 ;
            
			newDest = MSRealloc(dest, destLenIn, "CBufferDecompressAndAppendBytes() reallocation") ;
            if (!newDest) { result = MSCompressError ; break ; }
            dest = newDest ;
        }
		if (result == MSCompressOK) {
			if (!CBufferAppendBytes(self, dest, destLen)) result = MSCompressError ;
		}

		FREE(dest, "CBufferDecompressAndAppendBytes() free") ;
		
	}
	return result == MSCompressOK ? YES : NO ;
}

/*
MSExport BOOL CBufferAppendWithSES(CBuffer *self, SES enumerator, const void *source, NSStringEncoding destinationEncoding, BOOL strict)
{
	switch (destinationEncoding) {
		case NSUTF8StringEncoding:
			return CBufferAppendUTF8WithSES(self, enumerator, source) ;
		case NSNonLossyASCIIStringEncoding:
			strict = YES ;
		case NSASCIIStringEncoding:
			if (strict) {
			}
			else {
			}
		case NSISOLatin1StringEncoding:
			break ;
		case NSUnicodeStringEncoding:
			return _CBufferAppendUnicode(self, enumerator, source, NO) ; // we don't swap
		case NSUTF16BigEndianStringEncoding:
			return _CBufferAppendUnicode(self, enumerator, source, MSCurrentByteOrder() == MSLittleEndian ? YES : NO) ;
		case NSUTF16LittleEndianStringEncoding:
			return _CBufferAppendUnicode(self, enumerator, source, MSCurrentByteOrder() == MSBigEndian ? YES : NO) ;
		default:
			return NO ;
	}
}
*/

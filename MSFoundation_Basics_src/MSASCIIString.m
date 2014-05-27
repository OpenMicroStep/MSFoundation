/*
 
 MSASCIIString.m
 
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
#import "MSFoundation_Private.h"
//#import "MSStringAdditions.h"
//#import "_MSStringBooleanAdditionsPrivate.h"
//#import "MSBuffer.h"

static Class __MSASCIIStringClass = Nil ;
static Class __NSStringClass = Nil ;
/*
static unichar _asciiStringCharacterAtIndex(id self, NSUInteger i) { return ((MSASCIIString *)self)->_buf[i] ; }
*/
#define MS_ASCIISTRING_LAST_VERSION 101
#define MSASCIIStringSES(X) MSMakeSESWithBytes((X)->_buf,(X)->_length,NSASCIIStringEncoding)


@implementation MSASCIIString

+ (void)load { if (!__MSASCIIStringClass) __MSASCIIStringClass = [self class] ; }
+ (void)initialize
{
    if (!__NSStringClass) {
		__NSStringClass = [NSString class] ;
        [MSASCIIString setVersion:MS_ASCIISTRING_LAST_VERSION] ;
    }
}

+ (id)alloc { return MSCreateObject(__MSASCIIStringClass) ; }
+ (id)allocWithZone:(NSZone *)zone { return MSAllocateObject(__MSASCIIStringClass, 0, zone) ; }
+ (id)new { return MSCreateObject(__MSASCIIStringClass) ; }

+ (id)string { return AUTORELEASE(MSCreateObject(__MSASCIIStringClass)) ; }
+ (id)stringWithString:(NSString *)string
{
    if (string) {
        SES ses = SESFromString(string) ;
        if (SESOK(ses)) {
            NSUInteger length = SESLength(ses) ;
            if (length) {
                MSASCIIString *ret = MSCreateASCIIString(length) ;
                if (ret) {
                    _MSFillCBufferFromString((CBuffer *)ret, ses) ;
                }
                return AUTORELEASE(ret) ;
            }
        }
        return AUTORELEASE(MSCreateObject(__MSASCIIStringClass)) ; 
    }
    return nil ;
}
+ (id)stringWithBytes:(const void *)bytes length:(NSUInteger)length { return AUTORELEASE(MSCreateASCIIStringWithBytes((void *)bytes, length, YES, YES)) ; }
+ (id)stringWithBytesNoCopy:(void *)bytes length:(NSUInteger)length { return AUTORELEASE(MSCreateASCIIStringWithBytes((void *)bytes, length, NO, YES)) ; }
+ (id)stringWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b
{ return AUTORELEASE(MSCreateASCIIStringWithBytes((void *)bytes, length, NO, b)) ; }

+ (id)stringWithData:(NSData *)aData { return aData ? AUTORELEASE(MSCreateASCIIStringWithBytes((void *)[aData bytes], [aData length], YES, YES)) : nil ; }
+ (id)stringWithBuffer:(MSBuffer *)aBuffer { return aBuffer ? AUTORELEASE(MSCreateASCIIStringWithBytes((void *)(((CBuffer*)aBuffer)->buf), ((CBuffer*)aBuffer)->length, YES, YES)) : nil ; }
+ (id)stringWithCBuffer:(CBuffer *)aBuffer { return aBuffer ? AUTORELEASE(MSCreateASCIIStringWithBytes((void *)(aBuffer->buf), aBuffer->length, YES, YES)) : nil ; } 
+ (id)stringWithASCIIString:(MSASCIIString *)aString { return aString ? AUTORELEASE(MSCreateASCIIStringWithBytes((void *)(aString->_buf), aString->_length, YES, YES)) : nil ; }

- (void)dealloc
{
	if (!_flags.leak && _buf) { MSFree(_buf, "- [MSASCIIString dealloc]") ; }
	[super dealloc] ;
}

- (id)init { return self ; }

- (id)initWithBytes:(const void *)bytes length:(NSUInteger)len
{
    if (bytes && len) { CBufferAppendBytes((CBuffer *)self, (void *)bytes, len) ; }
    return self ;
}

- (id)initWithData:(NSData *)aData
{
    NSUInteger length = [aData length] ;
    if (length) {
        CBufferAppendBytes((CBuffer *)self, (void *)[aData bytes], length) ;
    }
    return self ;
}

- (id)initWithBuffer:(MSBuffer *)aBuffer
{
    CBufferAppendBuffer((CBuffer *)self, (CBuffer *)aBuffer) ;
    return self ;
}

- (id)initWithCBuffer:(CBuffer *)aBuffer
{
    CBufferAppendBuffer((CBuffer *)self, aBuffer) ;
    return self ;
}

- (id)initWithASCIIString:(MSASCIIString *)aString
{
    CBufferAppendBuffer((CBuffer *)self, (CBuffer *)aString) ;
    return self ;
}

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length
{
	_buf = (MSByte *)bytes ;
	_size = _length = length ;
	return self ;
}

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b
{
	_buf = (MSByte *)bytes ;
	_size = _length = length ;
	_flags.leak = !b ;
	return self ;
}

- (id)initWithString:(NSString *)string
{
    if (string) {
        if ([string class] == __MSASCIIStringClass) {
            CBufferAppendBuffer((CBuffer *)self, (CBuffer *)string) ;
        }
        else {
            SES ses = [self stringEnumeratorStructure] ;
            if (SESOK(ses)) {
                NSUInteger length = SESLength(ses) ;
                _buf = (MSByte *)MSMalloc(length, "-[MSASCIIString initWithString:]") ;
                if (!_buf) {
                    RELEASE(self) ;
                    MSRaiseFrom(NSMallocException, self, _cmd, @"string of %lu characters cannot be allocated", (unsigned long)length) ;
                    return nil ;
                }
                _size = length ;
                _MSFillCBufferFromString((CBuffer *)self, ses) ;
            }
        }
    }
    return self ;
}


- (NSStringEncoding)smallestEncoding { return NSASCIIStringEncoding ; }
- (NSStringEncoding)fastestEncoding { return NSASCIIStringEncoding ; }
- (NSString *)asciiString { return self ; } // OK in theory we should test the content of the string and eliminate non ASCII chars. That's OK like that
- (const char *)asciiCString // idem here
{
    char *ret = "" ;
    if (_buf && _length) {
        MSASCIIString *keeper = MSCreateASCIIStringWithBytes(_buf, _length, YES, YES) ;
        if (keeper) {
            CBufferAppendByte((CBuffer *)keeper, '\0');
            ret = (char *)(keeper->_buf) ;
            AUTORELEASE(keeper) ; // the constitutional buffer holding our string will be released later
        }
        else { ret = NULL ; }
    }
    return (const char *)ret ;
}


- (const void *)bytes { return (const void *)_buf ; }

- (void)getBytes:(void *)buffer { if (buffer && _length) memmove(buffer, _buf, _length) ; }

- (void)getBytes:(void *)buffer length:(NSUInteger)length
{
    if (length > _length) {
        MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"range (0, %lu) out of range (0, %lu)", (unsigned long)length, (unsigned long)_length) ;
    }
    if (buffer && length) memcpy(buffer, _buf, length) ;
}

- (void)getBytes:(void *)buffer range:(NSRange)range
{
    if (range.location + range.length > _length) {
        MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"range %@ out of range (0, %lu)", NSStringFromRange(range), (unsigned long)_length) ;
    }
    if (buffer && range.length) memcpy(buffer, _buf + range.location, range.length) ;
}
// ==================== primitives ================================================
- (unichar)characterAtIndex:(NSUInteger)i
{
    if (i >= _length) MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"index %d out of bounds %d", i, _length) ;
    return (unichar)_buf[i] ;
}
- (NSUInteger)length { return _length ; }
// =================== extended overwrited methods =====================================

static inline void _copyASCIIToUnichars(unichar *dest, MSByte *source, NSUInteger len)
{
    if (dest && source && len) {
        register NSUInteger i ;
        for (i = 0; i < len; i++) { dest[i] = (unichar)(source[i]) ; }
    }
}

- (void)getCharacters:(unichar *)buffer { _copyASCIIToUnichars(buffer, _buf, _length) ; }
- (void)getCharacters:(unichar *)buffer range:(NSRange)range
{
    if (range.location + range.length > _length) {
        MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"range %@ out of range (0, %lu)", NSStringFromRange(range), (unsigned long)_length) ;
    }
    if (buffer && range.length) _copyASCIIToUnichars(buffer, _buf + range.location, range.length) ;
}

- (NSString *)substringFromIndex:(NSUInteger)i
{
    if (i == 0) return self ;
    if (i == _length) return [[self class] string] ;
    if (i > _length) MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"index %lu out of bounds %lu", (unsigned long)i, (unsigned long)_length) ;
	return AUTORELEASE(MSCreateASCIIStringWithBytes(_buf+i, _length-i, YES, YES)) ;
}

- (NSString *)substringToIndex:(NSUInteger)i
{
    if (i == _length) return self ;
    if (i == 0) return [[self class] string] ;
    if (i > _length) MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"index %lu out of bounds %lu", (unsigned long)i, (unsigned long)_length) ;
    return AUTORELEASE(MSCreateASCIIStringWithBytes(_buf, i, YES, YES)) ;
}

- (NSString *)substringWithRange:(NSRange)range
{
    if (range.location + range.length > _length) {
        MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"range %@ out of range (0, %lu)", NSStringFromRange(range), (unsigned long)_length) ;
    }
    return AUTORELEASE(MSCreateASCIIStringWithBytes(_buf+range.location, range.length, YES, YES)) ;
}

- (NSString *)mid:(NSUInteger)position
{
	if (position < _length) {
		return AUTORELEASE(MSCreateASCIIStringWithBytes(_buf + position,  _length - position, YES, YES)) ;
	}
	return @"" ;
}

- (NSString *)left:(NSUInteger)length
{
	if (length > _length) length = _length ;
	if (length) {
		return AUTORELEASE(MSCreateASCIIStringWithBytes(_buf, length, YES, YES)) ;
	}
	return @"" ;
}

- (NSString *)mid:(NSUInteger)position :(NSUInteger)length
{
	if (length) {
		if (position < _length) {
			return AUTORELEASE(MSCreateASCIIStringWithBytes(_buf+position, (length == NSUIntegerMax || position+length > _length ? _length - position : length), YES, YES)) ;
		}
	}
	return @"" ;
}

- (NSString *)right:(NSUInteger)length
{
	if (length) {
		NSUInteger position = (_length > length ? _length - length : 0) ;
		return AUTORELEASE(MSCreateASCIIStringWithBytes(_buf+position, _length - position, YES, YES)) ;
	}
	return @"" ;
}
/*
- (BOOL)isTrue
{
	SES ses = MSASCIIStringSES(self) ;
	if (SESOK(ses)) return MSStringIsTrue(self, ses, (CUnicharChecker)CUnicharIsSpace, NULL) ;
	return NO ;
}
*/
- (BOOL)isEqual:(id)object
{
	if (object == self) return YES ;
	if (!object || ![object isKindOfClass:__NSStringClass]) return NO ;
	return MSEqualStrings(self, (NSString *)object) ;
}

- (BOOL)isEqualToString:(NSString *)aString
{
	return MSEqualStrings(self, aString) ;
}

// ===================== NSCOPYING AND MUTABLE COPYING PROTOCOL ======================================
#ifdef WO451
// since NSASCIIStringEncoding is included in any system encoding we consider that the current system encoding is worth a usage here.
// So we loose the information that we have a pure ASCII string. Pity !
- (id)mutableCopyWithZone:(NSZone *)zone { return [[NSMutableString allocWithZone:zone] initWithCString:_buf length:_length] ; }
#else
- (id)mutableCopyWithZone:(NSZone *)zone { return [[NSMutableString allocWithZone:zone] initWithBytes:_buf length:_length encoding:NSASCIIStringEncoding] ; }
#endif
- (id)copyWithZone:(NSZone *)zone
{ 
	if  (zone == [self zone]) { return RETAIN(self) ; }
	return [[[self class] allocWithZone:zone] initWithBytes:_buf length:_length] ;
}

// ================ NSCODING PROTOCOL ==================
- (id)replacementObjectForPortCoder:(NSPortCoder *)encoder
{
    if ([encoder isBycopy]) return self;
    return [super replacementObjectForPortCoder:encoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if ([aCoder allowsKeyedCoding]) {
		// we save the capacity as an information for the reader
		[aCoder	encodeUnsignedInteger:_size forKey:@"capacity"] ;
		[aCoder encodeBytes:(const MSByte *)_buf length:_length forKey:@"ascii-string"] ;
	}
	else {
		[aCoder encodeBytes:(const void *)_buf length:_length] ;
	}
}

- (id)initWithCoder:(NSCoder *)aCoder
{ 
	NSUInteger length = 0 ;
	void *bytes = NULL ;
	
	if ([aCoder allowsKeyedCoding]) {
		// in that mode, we decide to drop the capacity information and resize the buffer
		// acording to length need
		bytes = (void *)[aCoder decodeBytesForKey:@"ascii-string" returnedLength:&length] ;
	}
	else {	
		bytes = [aCoder decodeBytesWithReturnedLength:&length] ;
	}
	if (length && bytes) {
		NSUInteger capacity = MSCapacityForCount(length) ;
		_buf = MSMalloc(capacity, "- [MSASCIIString initWithCoder]") ;
		if (!_buf) {
			RELEASE(self) ;
			MSRaiseFrom(NSMallocException, self, _cmd, @"buffer of %lu bytes cannot be allocated", (unsigned long)capacity) ;
			return nil ;
		}
		memcpy(_buf, bytes, length) ;
		_length = length ;
		_size = capacity ;
	}
	return self ; 
}
- (Class)classForAchiver { return [self class] ; }
- (Class)classForCoder { return [self class] ; }
- (Class)classForPortCoder { return [self class] ; }


//================= String enumeration ======================

- (SES)stringEnumeratorStructure { return MSASCIIStringSES(self) ; }


@end


#define _MSCreateWithCapacity(PROTO, ITEMS_TYPE, ITEMS_TOKEN) MS ## PROTO *MSCreate ## PROTO(NSUInteger capacity) \
{ \
	MS ## PROTO *ret = (MS ## PROTO *)MSCreateObject(__MS ## PROTO ## Class) ; \
	if (ret) { \
		if (capacity) { \
			char *str = "MSCreate" #PROTO "()" ; \
			ITEMS_TYPE *p = MSMalloc(capacity * sizeof(ITEMS_TYPE), str) ; \
			if (!p) { \
				RELEASE(ret) ; \
				MSRaise(NSMallocException, [NSString stringWithFormat:@"%s : buffer of %lu elements cannot be allocated", str, (unsigned long)capacity]) ; \
				return nil ; \
			} \
			ret->ITEMS_TOKEN = p ; \
			ret->_size = capacity ; \
		} \
	} \
	return ret ; \
}
_MSCreateWithCapacity(ASCIIString, MSByte, _buf)

MSASCIIString *MSCreateASCIIStringWithBytes(void *bytes, NSUInteger length, BOOL takesACopy, BOOL freeWhenDone)
{
	MSASCIIString *ret = (MSASCIIString *)MSCreateObject(__MSASCIIStringClass) ;
    if (ret) {
		if (takesACopy) {
			if (length) {
				ret->_buf = MSMalloc(length, "MSCreateASCIIStringWithBytes()") ;
				if (!ret->_buf) {
					RELEASE(ret) ;
					MSRaise(NSMallocException, @"MSCreateASCIIStringWithBytes(): data of %lu bytes cannot be allocated", (unsigned long)length) ;
					return nil ;
				}
				memcpy(ret->_buf, bytes, length) ;
			}
        }
		else { 
			ret->_buf = bytes ;
			ret->_flags.leak = !freeWhenDone ;
		}
		ret->_length = length ;
		ret->_size = length ;
    }
    return ret ;
}

NSString *MSBytesToHexaString(void *_buf, NSUInteger _length, BOOL plistEncoded)
{
  static const char *__hexa= "0123456789ABCDEF";
  if (_buf && _length) {
    NSUInteger i, len= _length*2 + (plistEncoded ? 7 : 0);
		char *s= (char *)malloc(len);
		char *str= s;
		if (plistEncoded) {strcpy(s, "<hexa:"); s+= 6;}
		for (i= 0 ; i < _length ; i++) {
			unsigned char c= ((unsigned char *)_buf)[i];
			*s++= __hexa[c>>4];
			*s++= __hexa[c&0x0f];}
		if (plistEncoded) *s++= '>';
    return AUTORELEASE(MSCreateASCIIStringWithBytes((void*)str, len, NO, YES));}
	return @"<>";
}

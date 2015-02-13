/* MSBuffer.h
 
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
 
 WARNING : this header file cannot be included alone, please direclty
 include <MSFoundation/MSFoundation.h>
 
 */

@interface MSBuffer : NSData
{
@private
  MSByte      *_buf;
  NSUInteger   _size;
  NSUInteger   _length;
  CBufferFlags _flags;
}

#pragma mark Init

+ (id)buffer;
+ (id)bufferWithData:(NSData *)data;
+ (id)bufferWithBuffer:(MSBuffer *)data;
+ (id)bufferWithContentsOfFile:(NSString *)path;

+ (id)bufferWithBytes:(const void *)bytes length:(NSUInteger)length;
+ (id)bufferWithBytesNoCopy:(void *)bytes length:(NSUInteger)length;
+ (id)bufferWithBytesNoCopyNoFree:(void *)bytes length:(NSUInteger)length;

+ (id)bufferWithCString:(char *)cString;
+ (id)bufferWithCStringNoCopy:(char *)cString;
+ (id)bufferWithCStringNoCopyNoFree:(char *)cString;

- (id)initWithData:(NSData *)data;
- (id)initWithBuffer:(MSBuffer *)data;
- (id)initWithContentsOfFile:(NSString *)path;

- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length;
- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length;
- (id)initWithBytesNoCopyNoFree:(void *)bytes length:(NSUInteger)length;

- (id)initWithCString:(char *)string;
- (id)initWithCStringNoCopy:(char *)string;
- (id)initWithCStringNoCopyNoFree:(char *)string;

#pragma mark Mutable init

+ (id)mutableBuffer;
+ (id)mutableBufferWithData:(NSData *)data;
+ (id)mutableBufferWithBuffer:(MSBuffer *)data;
+ (id)mutableBufferWithContentsOfFile:(NSString *)path;

+ (id)mutableBufferWithBytes:(const void *)bytes length:(NSUInteger)length;
+ (id)mutableBufferWithCString:(char *)cString;

- (id)mutableInitWithData:(NSData *)data;
- (id)mutableInitWithBuffer:(MSBuffer *)data;
- (id)mutableInitWithContentsOfFile:(NSString *)path;

- (id)mutableInitWithBytes:(const void *)bytes length:(NSUInteger)length;
- (id)mutableInitWithCString:(char *)string;

#pragma mark Standard methods

- (const void *)bytes;
- (NSUInteger)length;

#pragma mark Extended methods

- (void)getBytes:(void *)bytes length:(NSUInteger)length;
- (void)getBytes:(void *)bytes range:(NSRange)range;
- (MSBuffer *)bufferWithRange:(NSRange)range;
- (BOOL)isEqualToBuffer:(MSBuffer *)other;

#pragma mark Mutability

- (BOOL)isMutable;
- (void)setImmutable;

- (void *)mutableBytes;
- (void)setLength:(NSUInteger)length;
- (void)increaseLengthBy:(NSUInteger)extraLength;
- (void)appendBytes:(const void *)bytes length:(NSUInteger)length;
- (void)appendBuffer:(NSData *)other;
- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)bytes;
- (void)resetBytesInRange:(NSRange)range;
- (void)setBuffer:(NSData *)data;
- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)replacementBytes length:(NSUInteger)replacementLength;

#pragma mark Encoding

- (MSByte*)cString; // With 0x00 at end
- (MSBuffer *)encodedToBase64;
- (MSBuffer *)decodedFromBase64;
  // return nil if not decodable.

- (MSBuffer *)compressed;
  // return nil if not decodable.
- (MSBuffer *)decompressed;
  // return nil if not decodable.

@end

#define MSCreateBuffer(C) (MSBuffer*)CCreateBuffer(C)
//The following method is obsolete. Use: CCreateBufferWithBytes[NoCopy[NoFree]]
//MSFoundationExport MSBuffer *MSCreateBufferWithBytes(void *bytes, NSUInteger length, BOOL takesACopy, BOOL freeWhenDone); // returns a retained object
#define MSCreateBufferWithBytes(            C,L) (MSBuffer*)CCreateBufferWithBytes            ((C),(L))
#define MSCreateBufferWithBytesNoCopy(      C,L) (MSBuffer*)CCreateBufferWithBytesNoCopy      ((C),(L))
#define MSCreateBufferWithBytesNoCopyNoFree(C,L) (MSBuffer*)CCreateBufferWithBytesNoCopyNoFree((C),(L))

//The following methods are obsolete Use: CBufferBase64[En|De]codeAndAppendBytes(b, bytes, length)
//MSFoundationExport MSBuffer *MSBase64FromBytes(const void *bytes, NSUInteger length, BOOL encodeWithNewLines);
//MSFoundationExport MSBuffer *MSBufferFromBase64(const void *bytes, NSUInteger length, BOOL encodedWithNewLines);
//MSFoundationExport MSBuffer *MSCreateBufferEncodeBytesBase64(const void *bytes, NSUInteger length);

// TODO: A mettre dans CBuffer
MSFoundationExport MSBuffer *MSURLComponentFromBytes(void *bytes, NSUInteger length); // also converts special characters $-_.+!*'(),
MSFoundationExport MSBuffer *MSURLFromBytes(void *bytes, NSUInteger length); // doesn't convert special characters $-_.+!*'(),

@interface NSData (MSBufferAdditions)
/*
 These 4 methods are not replicated from leopard to older macosx and in WOF 4.51 : that means that you MUST NOT use them.
 
 - (id)initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
 - (id)initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
 - (BOOL)writeToFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr;
 - (BOOL)writeToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr;
 
 Use instead :
 + (id)dataWithContentsOfURL:(NSURL *)url;
 + (id)dataWithContentsOfMappedFile:(NSString *)path;
 - (id)initWithContentsOfFile:(NSString *)path;
 - (id)initWithContentsOfURL:(NSURL *)url;
 - (id)initWithContentsOfMappedFile:(NSString *)path;
 - (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
 - (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically;
 */

- (MSUShort)smallCRC;
- (MSUInt  )largeCRC;
- (MSUInt  )elfHash;
- (MSUInt  )elfUppercaseHash;
- (BOOL)containsOnlyBase64Characters;

@end

@interface NSMutableData (MSBufferAdditions) 
- (void)appendCString:(const char *)str;
- (void)appendCRLF;

- (void)appendUTF8String:(NSString *)s;
- (void)appendString:(NSString *)s encoding:(NSStringEncoding)encoding;

- (void)appendUTF8Format:(NSString *)format, ...;
- (void)appendWithEncoding:(NSStringEncoding)encoding format:(NSString *)format, ...;
- (void)appendWithEncoding:(NSStringEncoding)encoding format:(NSString *)format arguments:(va_list)l;
@end

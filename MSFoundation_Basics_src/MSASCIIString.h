/*
 
 MSASCIIString.h
 
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
/*
 ================ WARNING ======================
 MSASCIIString should be considered as a final class. It's optimized for 
 speed and that means that all initializers are independant and always create 
 MSASCIIString instance even if they are called from subclasses. 
 So, if you want to sublcass MSASCIIString, beware and create your own 
 initializers and don't call super from them. For the very same reasons, all 
 instance methods returning MSASCIIString objects always instanciate
 MSASCIIString object and cannot return subclasses. They must
 be overwritten when subclassing. In conclusion : MSASCIIString class 
 would be very difficult to subclass.
 
 For speed create MSASCIIString objects with the initialization functions :
 MSCreateASCIIString(), MSCreateASCIIStringWithBytes().
 
 As an ObjC object MSASCIIString is condidered as an immutable object. 
 As a clone of the CBuffer C structure it's a mutable buffer. 
 Good usage is : create with a MSCreateASCIIString... method, fill with 
 CBuffer functions and when it's done, use with ObjC interface as 
 an immutable Object. 
 
 Another thing is that 
 
 - (id)initWithFormat:(NSString *)format, ... ;
 - (id)initWithFormat:(NSString *)format arguments:(va_list)argList ;
 - (id)initWithFormat:(NSString *)format locale:(id)locale, ... ;
 - (id)initWithFormat:(NSString *)format locale:(id)locale arguments:(va_list)argList ;
 - (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding;
 - (id)initWithBytes:(const void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding;
 - (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer;
 + (id)stringWithFormat:(NSString *)format, ... ;
 + (id)localizedStringWithFormat:(NSString *)format, ... ;
 - (id)initWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding;
 + (id)stringWithCString:(const char *)cString encoding:(NSStringEncoding)enc;
 - (id)initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError **)error;
 - (id)initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error;
 + (id)stringWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError **)error;
 + (id)stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error;
 - (id)initWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding *)enc error:(NSError **)error;
 - (id)initWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error;
 + (id)stringWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding *)enc error:(NSError **)error;
 + (id)stringWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error;
 + (id)stringWithCharacters:(const unichar *)characters length:(NSUInteger)length ;
 - (id)initWithCharacters:(const unichar *)characters length:(NSUInteger)length ;
 - (id)initWithCharactersNoCopy:(unichar *)characters length:(NSUInteger)length freeWhenDone:(BOOL)freeWhenDone ;
 - (id)initWithUTF8String:(const char *)nullTerminatedCString ;

 
 methods are not overwritted. So you cannot consider that you have a true
 NSUnicodeString if you use this initializers.
 
 Please note that the mutable copy of a MSASCIIString returns a NSMutableString.
 
 */
typedef struct _MSASCIIStringFlagsStruct {
#ifdef __BIG_ENDIAN__
    MSUInt leak:1;
    MSUInt _pad:31;
#else
    MSUInt _pad:31;
    MSUInt leak:1;
#endif
} _MSASCIIStringFlags ;

@class MSBuffer ;

@interface MSASCIIString : NSString
{
@public
    MSByte                  *_buf ;
    NSUInteger              _length ;
    NSUInteger              _size ;
	_MSASCIIStringFlags     _flags;
}

+ (id)stringWithBytes:(const void *)bytes length:(NSUInteger)length ;
+ (id)stringWithBytesNoCopy:(void *)bytes length:(NSUInteger)length ;
+ (id)stringWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b ;

+ (id)stringWithData:(NSData *)aData ;
+ (id)stringWithBuffer:(MSBuffer *)aBuffer ;
+ (id)stringWithCBuffer:(CBuffer *)aBuffer ;
+ (id)stringWithASCIIString:(MSASCIIString *)aString ;

- (id)initWithBytes:(const void *)bytes length:(NSUInteger)len ;
- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length ;
- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b ;

- (id)initWithData:(NSData *)aData ;
- (id)initWithBuffer:(MSBuffer *)aBuffer ;
- (id)initWithCBuffer:(CBuffer *)aBuffer ;
- (id)initWithASCIIString:(MSASCIIString *)aString ;

// since this class is just like a NSData and a NSString, it implements some NSData methods
- (const void *)bytes ;
- (void)getBytes:(void *)buffer ;
- (void)getBytes:(void *)buffer length:(NSUInteger)length ;
- (void)getBytes:(void *)buffer range:(NSRange)range ;

@end

MSFoundationExport MSASCIIString *MSCreateASCIIString(NSUInteger capacity) ; // returns a retained object
MSFoundationExport MSASCIIString *MSCreateASCIIStringWithBytes(void *bytes, NSUInteger length, BOOL takesACopy, BOOL freeWhenDone) ; // returns a retained object

MSFoundationExport NSString *MSBytesToHexaString(void *_buf, NSUInteger _length, BOOL plistEncoded);

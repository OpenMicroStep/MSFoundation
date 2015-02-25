/* MSBuffer.m
 
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

#define MS_BUFFER_LAST_VERSION 112

@implementation MSBuffer
+ (void)load          {MSFinishLoadingAddClass(self);}
+ (void)finishLoading {[MSBuffer setVersion:MS_BUFFER_LAST_VERSION];}

#pragma mark Alloc / Init

#define AL(X)   ALLOC(X)
#define AR(X)   AUTORELEASE(X)
#define FIXE(a) CGrowSetForeverImmutable((id)a)

static inline id _init(id a, BOOL m)
{
  if (!m) FIXE(a);
  return a;
}
static inline id _initWithBytes(id a, BOOL m, const void *bytes, NSUInteger length, BOOL noCopy, BOOL noFree)
{
  if      (!noCopy) CBufferInitWithBytes            ((CBuffer*)a, (void*)bytes, length);
  else if (!noFree) CBufferInitWithBytesNoCopy      ((CBuffer*)a, (void*)bytes, length);
  else              CBufferInitWithBytesNoCopyNoFree((CBuffer*)a, (void*)bytes, length);
  return _init(a,m);
}
static inline id _initWithData(id a, BOOL m, NSData *d)
{ 
  CBufferAppendData((CBuffer*)a, d);
  return _init(a,m);
}
static inline id _initWithBuffer(id a, BOOL m, MSBuffer *d)
{ 
  CBufferAppendBuffer((CBuffer*)a, (CBuffer*)d);
  return _init(a,m);
}
static inline id _initWithContentsOfFile(id a, BOOL m, NSString *path)
{ 
  CBufferAppendContentsOfFile((CBuffer*)a, SESFromString(path));
  return _init(a,m);
}

+ (id)data          {return AR([AL(self)        init]);}
+ (id)buffer        {return AR([AL(self)        init]);}
+ (id)mutableBuffer {return AR([AL(self) mutableInit]);}
+ (id)new           {return [AL(self) mutableInit];} // mutable
- (id)init          {return _init(self,  NO);}
- (id)mutableInit   {return _init(self, YES);}

- (id)mutableInitWithCapacity:(NSUInteger)capacity
  {
  CGrowGrow(self, capacity);
  return self;
  }
- (id)mutableInitWithLength:(NSUInteger)length
  {
  [self increaseLengthBy:length];
  return self;
  }

+ (id)dataWithData:             (NSData *)data {return AR([AL(self)        initWithData:  data]);}
+ (id)bufferWithData:           (NSData *)data {return AR([AL(self)        initWithData:  data]);}
+ (id)mutableBufferWithData:    (NSData *)data {return AR([AL(self) mutableInitWithData:  data]);}
- (id)initWithData:             (NSData *)data {return _initWithData(self,  NO, data);}
- (id)mutableInitWithData:      (NSData *)data {return _initWithData(self, YES, data);}
+ (id)bufferWithBuffer:       (MSBuffer *)buf  {return AR([AL(self)        initWithBuffer:buf ]);}
+ (id)mutableBufferWithBuffer:(MSBuffer *)buf  {return AR([AL(self) mutableInitWithBuffer:buf ]);}
- (id)initWithBuffer:         (MSBuffer *)buf  {return _initWithBuffer(self,  NO, buf );}
- (id)mutableInitWithBuffer:  (MSBuffer *)buf  {return _initWithBuffer(self, YES, buf );}

+ (id)dataWithBytes:         (const void *)b length:(NSUInteger)l                      {return AR([AL(self)        initWithBytes:            b length:l]);}
+ (id)dataWithBytesNoCopy:         (void *)b length:(NSUInteger)l                      {return AR([AL(self)        initWithBytesNoCopy:      b length:l]);}
+ (id)dataWithBytesNoCopy:         (void *)b length:(NSUInteger)l freeWhenDone:(BOOL)f {return AR([AL(self)        initWithBytesNoCopy:      b length:l freeWhenDone:f]);}

+ (id)bufferWithBytes:       (const void *)b length:(NSUInteger)l                      {return AR([AL(self)        initWithBytes:            b length:l]);}
+ (id)bufferWithBytesNoCopy:       (void *)b length:(NSUInteger)l                      {return AR([AL(self)        initWithBytesNoCopy:      b length:l]);}
+ (id)bufferWithBytesNoCopyNoFree: (void *)b length:(NSUInteger)l                      {return AR([AL(self)        initWithBytesNoCopyNoFree:b length:l]);}
+ (id)mutableBufferWithBytes:(const void *)b length:(NSUInteger)l                      {return AR([AL(self) mutableInitWithBytes:            b length:l]);}
+ (id)mutableBufferWithBytesNoCopy:(void *)b length:(NSUInteger)l                      {return AR([AL(self) mutableInitWithBytesNoCopy:      b length:l]);}

- (id)initWithBytes:         (const void *)b length:(NSUInteger)l                      {return _initWithBytes(self,  NO, b, l,  NO,  NO);}
- (id)initWithBytesNoCopy:         (void *)b length:(NSUInteger)l                      {return _initWithBytes(self,  NO, b, l, YES,  NO);}
- (id)initWithBytesNoCopyNoFree:   (void *)b length:(NSUInteger)l                      {return _initWithBytes(self,  NO, b, l, YES, YES);}
- (id)initWithBytesNoCopy:         (void *)b length:(NSUInteger)l freeWhenDone:(BOOL)f {return _initWithBytes(self,  NO, b, l, YES,  !b);}
- (id)mutableInitWithBytes:  (const void *)b length:(NSUInteger)l                      {return _initWithBytes(self, YES, b, l,  NO,  NO);}
- (id)mutableInitWithBytesNoCopy:  (void *)b length:(NSUInteger)l                      {return _initWithBytes(self, YES, b, l, YES,  NO);}

+ (id)bufferWithCString:            (char *)s {return AR([AL(self)        initWithCString:            s]);}
+ (id)bufferWithCStringNoCopy:      (char *)s {return AR([AL(self)        initWithCStringNoCopy:      s]);}
+ (id)bufferWithCStringNoCopyNoFree:(char *)s {return AR([AL(self)        initWithCStringNoCopyNoFree:s]);}
+ (id)mutableBufferWithCString:     (char *)s {return AR([AL(self) mutableInitWithCString:            s]);}
- (id)initWithCString:              (char *)s {return _initWithBytes(self,  NO, s, strlen(s),  NO,  NO);}
- (id)initWithCStringNoCopy:        (char *)s {return _initWithBytes(self,  NO, s, strlen(s), YES,  NO);}
- (id)initWithCStringNoCopyNoFree:  (char *)s {return _initWithBytes(self,  NO, s, strlen(s), YES, YES);}
- (id)mutableInitWithCString:       (char *)s {return _initWithBytes(self, YES, s, strlen(s),  NO,  NO);}

+ (id)dataWithContentsOfFile:         (NSString *)path {return AR([AL(self)        initWithContentsOfFile:path]);}
+ (id)bufferWithContentsOfFile:       (NSString *)path {return AR([AL(self)        initWithContentsOfFile:path]);}
+ (id)mutableBufferWithContentsOfFile:(NSString *)path {return AR([AL(self) mutableInitWithContentsOfFile:path]);}
- (id)initWithContentsOfFile:         (NSString *)path {return _initWithContentsOfFile(self,  NO, path);}
- (id)mutableInitWithContentsOfFile:  (NSString *)path {return _initWithContentsOfFile(self, YES, path);}

- (void)dealloc
{
  CBufferFreeInside(self);
  [super dealloc];
}

#pragma mark Copying

- (id)copyWithZone:(NSZone*)z
{return MSGrowCopyWithZone(z,self, NO,(MSGrowInitCopyMethod)CBufferInitCopyWithMutability);}
- (id)mutableCopyWithZone:(NSZone*)z
{return MSGrowCopyWithZone(z,self,YES,(MSGrowInitCopyMethod)CBufferInitCopyWithMutability);}

#pragma mark Primitives

- (NSUInteger)hash:(unsigned)depth {return CBufferHash(self, depth);}
- (NSString*)description   {return [(id)CBufferRetainedDescription(self) autorelease];}

- (NSUInteger)length { return _length; }
- (const void *)bytes { return (const void *)_buf; }
- (MSByte*)cString
{
  MSBuffer *from= !_flags.noFree ? self : [MSBuffer bufferWithBuffer:self];
  return CBufferCString((CBuffer*)from);
}

// - (NSString *)description;

- (void)getBytes:(void *)buffer { if (buffer && _length) memmove(buffer, _buf, _length); }

- (void)getBytes:(void *)buffer length:(NSUInteger)length
{
  if (length > _length) {
    MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"range (0, %lu) out of range (0, %lu)", (unsigned long)length, (unsigned long)_length);
  }
  if (buffer && length) memcpy(buffer, _buf, length);
}

- (void)getBytes:(void *)buffer range:(NSRange)range
{
  if (range.location + range.length > _length) {
    MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"range %@ out of range (0, %lu)", NSStringFromRange(range), (unsigned long)_length);
  }
  if (buffer && range.length) memcpy(buffer, _buf + range.location, range.length);
}

- (BOOL)isEqualToData:(NSData *)other
{ return (other ? (_length == [other length] ? !memcmp(_buf, [other bytes], _length) : NO) : NO); }

- (BOOL)isEqualToBuffer:(MSBuffer *)other
{ return CBufferEquals((CBuffer*)self, (CBuffer*)other); }

- (BOOL)isEqual:(id)object
  {
  if (object == (id)self) return YES;
  if (!object) return NO;
  if ([object isKindOfClass:[MSBuffer class]]) {
    return CBufferEquals((CBuffer*)self, (CBuffer*)object);}
  else if ([object isKindOfClass:[NSData class]]) {
    return [self isEqualToData:object];}
  return NO;
  }

- (NSData *)subdataWithRange:(NSRange)range
{
  if (range.location + range.length > _length) {
    MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"range %@ out of range (0, %lu)", NSStringFromRange(range), (unsigned long)_length);
  }
  return AUTORELEASE((id)CCreateBufferWithBytes(_buf+range.location, range.length));
}

- (MSBuffer *)bufferWithRange:(NSRange)range
{
  if (range.location + range.length > _length) {
    MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"range %@ out of range (0, %lu)", NSStringFromRange(range), (unsigned long)_length);
  }
  return AUTORELEASE((id)CCreateBufferWithBytes(_buf+range.location, range.length));
}

#pragma 

// TODO: MSBytesToHexaString as CString
//- (NSString *)toString       { return MSBytesToHexaString(_buf, _length, YES); }
//- (NSString *)listItemString { return MSBytesToHexaString(_buf, _length, YES); }
- (MSUShort)smallCRC         { return MSBytesSmallCRC    ((void *)_buf, _length); }
- (MSUInt  )largeCRC         { return MSBytesLargeCRC    ((void *)_buf, _length); }
- (MSUInt  )ELFHash          { return MSBytesELF         ((void *)_buf, _length); }
- (MSUInt  )elfUppercaseHash { return MSBytesUppercaseELF((void *)_buf, _length); }

#pragma mark Base 64

- (MSBuffer *)encodedToBase64
  {
  MSBuffer *b= MSCreateBuffer(0);
  CBufferBase64EncodeAndAppendBytes((CBuffer*)b, _buf, _length);
  return AUTORELEASE((id)b);
  }
- (MSBuffer *)decodedFromBase64
  {
  MSBuffer *b= MSCreateBuffer(0);
  if (_buf && !CBufferBase64DecodeAndAppendBytes((CBuffer*)b, _buf, _length)) {
    ASSIGN(b, nil);}
  return AUTORELEASE(b);
  }

#pragma mark Compression

- (MSBuffer *)compressed
  {
  // TODO: réécrire partout avec des MSBuffer
  MSBuffer *b= MSCreateBuffer(0);
  if (_buf && !CBufferCompressAndAppendBytes((CBuffer*)b, _buf, _length)) {
    ASSIGN(b, nil);}
  return AUTORELEASE(b);
  }
- (MSBuffer *)decompressed
  {
  MSBuffer *b= MSCreateBuffer(0);
  if (_buf && !CBufferDecompressAndAppendBytes((CBuffer*)b, _buf, _length)) {
    ASSIGN(b, nil);}
  return AUTORELEASE(b);
  }

#pragma mark NSCoding

- (id)replacementObjectForPortCoder:(NSPortCoder *)encoder
{
  if ([encoder isBycopy]) return self;
  return [super replacementObjectForPortCoder:encoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  if ([aCoder allowsKeyedCoding]) {
    // we save the capacity as an information for the reader
    [aCoder  encodeUnsignedInteger:_size forKey:@"capacity"];
    [aCoder encodeBytes:(const MSByte *)_buf length:_length forKey:@"data"];
  }
  else {
    [aCoder encodeBytes:(const void *)_buf length:_length];
  }
}

- (id)initWithCoder:(NSCoder *)aCoder
{
  NSUInteger length= 0;
  void *bytes= NULL;
  
  if ([aCoder allowsKeyedCoding]) {
    // in that mode, we decide to drop the capacity information and resize the buffer
    // acording to length need
    bytes= (void *)[aCoder decodeBytesForKey:@"data" returnedLength:&length];
  }
  else {
    bytes= [aCoder decodeBytesWithReturnedLength:&length];
  }
  if (length && bytes) {
    NSUInteger capacity= MSCapacityForCount(length);
    _buf= MSMalloc(capacity, "- [MSBuffer initWithCoder]");
    if (!_buf) {
      RELEASE(self);
      MSRaiseFrom(NSMallocException, self, _cmd, @"buffer of %lu bytes cannot be allocated", (unsigned long)capacity);
      return nil;
    }
    memcpy(_buf, bytes, length);
    _length= length;
    _size= capacity;
  }
  return self;
}
- (Class)classForAchiver   { return [self class]; }
- (Class)classForCoder     { return [self class]; }
- (Class)classForPortCoder { return [self class]; }

#pragma mark Mutability

- (BOOL)isMutable    {return !CGrowIsForeverImmutable(self);}
- (void)setImmutable {CGrowSetForeverImmutable(self);}

- (void *)mutableBytes{ return _buf; }
- (void)appendBytes:(const void *)bytes length:(NSUInteger)length
{ CBufferAppendBytes((CBuffer*)self, bytes, length); }
- (void)appendData:(NSData *)data
{ CBufferAppendData((CBuffer*)self, data); }
- (void)appendBuffer:(MSBuffer *)buffer
{ CBufferAppendBuffer((CBuffer*)self, (CBuffer*)buffer); }

- (void)setLength:(NSUInteger)length
{
  CGrowMutVerif((id)self, 0, 0, "setLength:");
  if (length > _length)
    [self increaseLengthBy:length - _length];
  else
    _length= length;
}
- (void)increaseLengthBy:(NSUInteger)extraLength
{
  CBufferGrow((CBuffer*)self, extraLength, YES);
  memset(_buf + _length, 0, extraLength);
  _length+= extraLength;
}
- (void)setData:(NSData *)data
{
  CBufferSetBytes((CBuffer*)self, [data bytes], [data length]);
}
- (void)setBuffer:(MSBuffer *)buffer
{
  CBufferSetBytes((CBuffer*)self, buffer->_buf, buffer->_length);
}

- (void)resetBytesInRange:(NSRange)range
{ 
  CGrowMutVerif((id)self, range.location, range.length, "resetBytesInRange:");
  memset(_buf + range.location, 0, range.length);
}
- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)bytes
{ 
  CGrowMutVerif((id)self, range.location, range.length, "replaceBytesInRange:withBytes");
  memmove(_buf + range.location, bytes, range.length);
}
- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)replacementBytes length:(NSUInteger)replacementLength
{
  NSUInteger rangeEnd;
  CGrowMutVerif((id)self, range.location, range.length, "replaceBytesInRange:withBytes:length:");
  if (replacementLength > range.length) {
    CBufferGrow((CBuffer*)self, replacementLength - range.length, NO); }
  rangeEnd= range.location + range.length;
  memmove(_buf + range.location + replacementLength, _buf + rangeEnd, _length - rangeEnd);
  memmove(_buf + range.location, replacementBytes, replacementLength);
  _length+= replacementLength - range.length;
}

@end
/*
MSBuffer *MSCreateBufferEncodeBytesBase64(const void *bytes, NSUInteger length)
{
  MSBuffer *b= MSCreateBuffer(0);
  CBufferBase64EncodeAndAppendBytes((CBuffer*)b, bytes, length);
  return b;
}
*/
static char *__fullURITags[256]= {
  /*00*/ "\003%00", "\003%01", "\003%02", "\003%03", "\003%04", "\003%05", "\003%06", "\003%07",
  /*08*/ "\003%08", "\003%09", "\003%0A", "\003%0B", "\003%0C", "\003%0D", "\003%0E", "\003%0F",
  /*10*/ "\003%10", "\003%11", "\003%12", "\003%13", "\003%14", "\003%15", "\003%16", "\003%17",
  /*18*/ "\003%18", "\003%19", "\003%1A", "\003%1B", "\003%1C", "\003%1D", "\003%1E", "\003%1F",
  /*20*/ "\003%20", "\001!"  , "\003%22", "\003%23", "\003%24", "\003%25", "\003%26", "\001'"  ,
  /*28*/ "\001("  , "\001)"  , "\001*"  , "\003%2B", "\003%2C", "\001-"  , "\001."  , "\003%2F",
  /*30*/ "\0010"  , "\0011"  , "\0012"  , "\0013"  , "\0014"  , "\0015"  , "\0016"  , "\0017"  ,
  /*38*/ "\0018"  , "\0019"  , "\003%3A", "\003%3B", "\003%3C", "\003%3D", "\003%3E", "\003%3F",
  /*40*/ "\003%40", "\001A"  , "\001B"  , "\001C"  , "\001D"  , "\001E"  , "\001F"  , "\001G"  ,
  /*48*/ "\001H"  , "\001I"  , "\001J"  , "\001K"  , "\001L"  , "\001M"  , "\001N"  , "\001O"  ,
  /*50*/ "\001P"  , "\001Q"  , "\001R"  , "\001S"  , "\001T"  , "\001U"  , "\001V"  , "\001W"  ,
  /*58*/ "\001X"  , "\001Y"  , "\001Z"  , "\003%5B", "\003%5C", "\003%5D", "\003%5E", "\001_"  ,
  /*60*/ "\003%60", "\001a"  , "\001b"  , "\001c"  , "\001d"  , "\001e"  , "\001f"  , "\001g"  ,
  /*68*/ "\001h"  , "\001i"  , "\001j"  , "\001k"  , "\001l"  , "\001m"  , "\001n"  , "\001o"  ,
  /*70*/ "\001p"  , "\001q"  , "\001r"  , "\001s"  , "\001t"  , "\001u"  , "\001v"  , "\001w"  ,
  /*78*/ "\001x"  , "\001y"  , "\001z"  , "\003%7B", "\003%7C", "\003%7D", "\003%7E", "\003%7F",
  /*80*/ "\003%80", "\003%81", "\003%82", "\003%83", "\003%84", "\003%85", "\003%86", "\003%87",
  /*88*/ "\003%88", "\003%89", "\003%8A", "\003%8B", "\003%8C", "\003%8D", "\003%8E", "\003%8F",
  /*90*/ "\003%90", "\003%91", "\003%92", "\003%93", "\003%94", "\003%95", "\003%96", "\003%97",
  /*98*/ "\003%98", "\003%99", "\003%9A", "\003%9B", "\003%9C", "\003%9D", "\003%9E", "\003%9F",
  /*A0*/ "\003%A0", "\003%A1", "\003%A2", "\003%A3", "\003%A4", "\003%A5", "\003%A6", "\003%A7",
  /*A8*/ "\003%A8", "\003%A9", "\003%AA", "\003%AB", "\003%AC", "\003%AD", "\003%AE", "\003%AF",
  /*B0*/ "\003%B0", "\003%B1", "\003%B2", "\003%B3", "\003%B4", "\003%B5", "\003%B6", "\003%B7",
  /*B8*/ "\003%B8", "\003%B9", "\003%BA", "\003%BB", "\003%BC", "\003%BD", "\003%BE", "\003%BF",
  /*C0*/ "\003%C0", "\003%C1", "\003%C2", "\003%C3", "\003%C4", "\003%C5", "\003%C6", "\003%C7",
  /*C8*/ "\003%C8", "\003%C9", "\003%CA", "\003%CB", "\003%CC", "\003%CD", "\003%CE", "\003%CF",
  /*D0*/ "\003%D0", "\003%D1", "\003%D2", "\003%D3", "\003%D4", "\003%D5", "\003%D6", "\003%D7",
  /*D8*/ "\003%D8", "\003%D9", "\003%DA", "\003%DB", "\003%DC", "\003%DD", "\003%DE", "\003%DF",
  /*E0*/ "\003%E0", "\003%E1", "\003%E2", "\003%E3", "\003%E4", "\003%E5", "\003%E6", "\003%E7",
  /*E8*/ "\003%E8", "\003%E9", "\003%EA", "\003%EB", "\003%EC", "\003%ED", "\003%EE", "\003%EF",
  /*F0*/ "\003%F0", "\003%F1", "\003%F2", "\003%F3", "\003%F4", "\003%F5", "\003%F6", "\003%F7",
  /*F8*/ "\003%F8", "\003%F9", "\003%FA", "\003%FB", "\003%FC", "\003%FD", "\003%FE", "\003%FF",
};


MSBuffer *MSURLComponentFromBytes(void *bytes, NSUInteger length) // also converts special characters $-_.+!*'(),
{
  if (bytes) {
    CBuffer *buffer= CCreateBuffer(length);
    NSUInteger i;
    for (i= 0; i < length; i++) {
      char *item= __fullURITags[((unsigned char *)bytes)[i]];
      MSByte l= (MSByte) *item ++;
      CBufferAppendBytes(buffer, (void *)item, (NSUInteger)l);
    }
    return AUTORELEASE((id)buffer);
  }
  return nil;
}

static char *__partialURITags[256]= {
  /* 00*/ "\003%00", "\003%01", "\003%02", "\003%03", "\003%04", "\003%05", "\003%06", "\003%07",
  /* 08*/ "\003%08", "\003%09", "\003%0A", "\003%0B", "\003%0C", "\003%0D", "\003%0E", "\003%0F",
  /* 10*/ "\003%10", "\003%11", "\003%12", "\003%13", "\003%14", "\003%15", "\003%16", "\003%17",
  /* 18*/ "\003%18", "\003%19", "\003%1A", "\003%1B", "\003%1C", "\003%1D", "\003%1E", "\003%1F",
  /* 20*/ "\003%20", "\001!"  , "\003%22", "\003%23", "\001$"  , "\003%25", "\001&"  , "\001'"  ,
  /* 28*/ "\001("  , "\001)"  , "\001*"  , "\001+"  , "\001,"  , "\001-"  , "\001."  , "\001/"  ,
  /* 30*/ "\0010"  , "\0011"  , "\0012"  , "\0013"  , "\0014"  , "\0015"  , "\0016"  , "\0017"  ,
  /* 38*/ "\0018"  , "\0019"  , "\001:"  , "\001;"  , "\003%3C", "\001="  , "\003%3E", "\001?"  ,
  /* 40*/ "\001@"  , "\001A"  , "\001B"  , "\001C"  , "\001D"  , "\001E"  , "\001F"  , "\001G"  ,
  /* 48*/ "\001H"  , "\001I"  , "\001J"  , "\001K"  , "\001L"  , "\001M"  , "\001N"  , "\001O"  ,
  /* 50*/ "\001P"  , "\001Q"  , "\001R"  , "\001S"  , "\001T"  , "\001U"  , "\001V"  , "\001W"  ,
  /* 58*/ "\001X"  , "\001Y"  , "\001Z"  , "\003%5B", "\003%5C", "\003%5D", "\003%5E", "\001_"  ,
  /* 60*/ "\003%60", "\001a"  , "\001b"  , "\001c"  , "\001d"  , "\001e"  , "\001f"  , "\001g"  ,
  /* 68*/ "\001h"  , "\001i"  , "\001j"  , "\001k"  , "\001l"  , "\001m"  , "\001n"  , "\001o"  ,
  /* 70*/ "\001p"  , "\001q"  , "\001r"  , "\001s"  , "\001t"  , "\001u"  , "\001v"  , "\001w"  ,
  /* 78*/ "\001x"  , "\001y"  , "\001z"  , "\003%7B", "\003%7C", "\003%7D", "\003%7E", "\003%7F",
  /* 80*/ "\003%80", "\003%81", "\003%82", "\003%83", "\003%84", "\003%85", "\003%86", "\003%87",
  /* 88*/ "\003%88", "\003%89", "\003%8A", "\003%8B", "\003%8C", "\003%8D", "\003%8E", "\003%8F",
  /* 90*/ "\003%90", "\003%91", "\003%92", "\003%93", "\003%94", "\003%95", "\003%96", "\003%97",
  /* 98*/ "\003%98", "\003%99", "\003%9A", "\003%9B", "\003%9C", "\003%9D", "\003%9E", "\003%9F",
  /* A0*/ "\003%A0", "\003%A1", "\003%A2", "\003%A3", "\003%A4", "\003%A5", "\003%A6", "\003%A7",
  /* A8*/ "\003%A8", "\003%A9", "\003%AA", "\003%AB", "\003%AC", "\003%AD", "\003%AE", "\003%AF",
  /* B0*/ "\003%B0", "\003%B1", "\003%B2", "\003%B3", "\003%B4", "\003%B5", "\003%B6", "\003%B7",
  /* B8*/ "\003%B8", "\003%B9", "\003%BA", "\003%BB", "\003%BC", "\003%BD", "\003%BE", "\003%BF",
  /* C0*/ "\003%C0", "\003%C1", "\003%C2", "\003%C3", "\003%C4", "\003%C5", "\003%C6", "\003%C7",
  /* C8*/ "\003%C8", "\003%C9", "\003%CA", "\003%CB", "\003%CC", "\003%CD", "\003%CE", "\003%CF",
  /* D0*/ "\003%D0", "\003%D1", "\003%D2", "\003%D3", "\003%D4", "\003%D5", "\003%D6", "\003%D7",
  /* D8*/ "\003%D8", "\003%D9", "\003%DA", "\003%DB", "\003%DC", "\003%DD", "\003%DE", "\003%DF",
  /* E0*/ "\003%E0", "\003%E1", "\003%E2", "\003%E3", "\003%E4", "\003%E5", "\003%E6", "\003%E7",
  /* E8*/ "\003%E8", "\003%E9", "\003%EA", "\003%EB", "\003%EC", "\003%ED", "\003%EE", "\003%EF",
  /* F0*/ "\003%F0", "\003%F1", "\003%F2", "\003%F3", "\003%F4", "\003%F5", "\003%F6", "\003%F7",
  /* F8*/ "\003%F8", "\003%F9", "\003%FA", "\003%FB", "\003%FC", "\003%FD", "\003%FE", "\003%FF",
};

MSBuffer *MSURLFromBytes(void *bytes, NSUInteger length) // doesn't convert special characters $-_.+!*'(),
{
  if (bytes) {
    CBuffer *buffer= CCreateBuffer(length);
    NSUInteger i;
    
    for (i= 0; i < length; i++) {
      char *item= __partialURITags[((unsigned char *)bytes)[i]];
      MSByte l= (MSByte)*item ++;
      CBufferAppendBytes(buffer, (void *)item, (NSUInteger)l);
    }
    return AUTORELEASE((id)buffer);
  }
  return nil;
}

@implementation NSData (MSDataAdditions)

// TODO: MSBytesToHexaString as CString
//- (NSString *)toString { return MSBytesToHexaString((void *)[self bytes], [self length], YES); }
//- (NSString *)listItemString { return MSBytesToHexaString((void *)[self bytes], [self length], YES); }
- (MSUShort)smallCRC         { return MSBytesSmallCRC    ((void *)[self bytes], [self length]); }
- (MSUInt  )largeCRC         { return MSBytesLargeCRC    ((void *)[self bytes], [self length]); }
- (MSUInt  )ELFHash          { return MSBytesELF         ((void *)[self bytes], [self length]); }
- (MSUInt  )elfUppercaseHash { return MSBytesUppercaseELF((void *)[self bytes], [self length]); }

- (BOOL)containsOnlyBase64Characters
{
  unsigned char *c= (unsigned char *)[self bytes];
  unsigned char *e= c + [self length];

  while(c < e) {
    if (   !(*c >= 65 && *c <=  90) //'A' to 'Z'
        && !(*c >= 97 && *c <= 122) //'a' to 'z'
        && !(*c >= 48 && *c <=  57) //'0' to '9'
        && (*c != 43)  // '+'
        && (*c != 47)  // '/'
        && (*c != 61)) // '/'
    {
      return NO;
    }
    ++c;
  }
  return YES;
}
@end

@implementation NSMutableData (MSDataAdditions)
- (void)appendCString:(const char *)str { if (str && *str) [self appendBytes:str length:strlen(str)]; }
- (void)appendCRLF { [self appendBytes:"\015\012" length:2]; }

/*
 all these append methods are not optimized
 */
- (void)appendUTF8String:(NSString *)s { return [self appendString:s encoding:NSUTF8StringEncoding]; }
- (void)appendString:(NSString *)str encoding:(NSStringEncoding)encoding
{
  if ([str length]) {
    switch (encoding) {
      case NSUTF8StringEncoding:{
        const char *s= [str UTF8String];
        size_t len;
        if (s && (len= strlen(s))) { [self appendBytes:(void *)s length:(NSUInteger)len];}
        break;
      }
      default:
        [self appendData:[str dataUsingEncoding:encoding allowLossyConversion:YES]];
        break;
    }
  }
}

- (void)appendUTF8Format:(NSString *)format, ...
{ va_list l; va_start (l, format); [self appendWithEncoding:NSUTF8StringEncoding format:format arguments:l]; va_end(l); }

- (void)appendWithEncoding:(NSStringEncoding)encoding format:(NSString *)format, ...
{ va_list l; va_start (l, format); [self appendWithEncoding:encoding format:format arguments:l]; va_end(l); }

- (void)appendWithEncoding:(NSStringEncoding)encoding format:(NSString *)format arguments:(va_list)l
{
  NSString *str= [ALLOC(NSString) initWithFormat:format arguments:l];
  if (str) {
    [self appendString:str encoding:encoding];
    RELEASE(str);
  }
}

@end

void CBufferAppendData(CBuffer *self, NSData *data)
{
  if (self) {
    NSUInteger len= [data length];
    CBufferGrow(self, len, YES);
    [data getBytes:self->buf + self->length range:NSMakeRange(0, len)];
    self->length+= len;}
}

/* Obsolete. Use: CBufferBase64[En|De]codeAndAppendBytes(b, bytes, length)
MSBuffer *MSBase64FromBytes(const void *bytes, NSUInteger length, BOOL encodeWithNewLines)
{return nil;}
MSBuffer *MSBufferFromBase64(const void *bytes, NSUInteger length, BOOL encodedWithNewLines)
{return nil;}
*/

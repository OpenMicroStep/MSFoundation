#import "FoundationCompatibility_Private.h"

static const MSByte ENCODE_REF= 0x01;
static const MSByte ENCODE_OBJECT= 0x02;
static const MSByte ENCODE_NIL= 0x03;

static inline void _replaceObject(CDictionary **replacements, id object, id newObject) {
  if (!*replacements)
    *replacements= CCreateDictionaryWithOptions(0, CDictionaryPointer, CDictionaryPointer);
  CDictionarySetObjectForKey(*replacements, newObject, object);
}

static inline id _tryReplaceObject(CDictionary *replacements, id object) {
  id r= CDictionaryObjectForKey(replacements, object);
  return r ? r : object;
}

static inline NSString * _mappedClassName(CDictionary *map, NSString *name)
{
  NSString *className;
  className= CDictionaryObjectForKey(map, name);
  if (!className)
    className= name;
  return className;
}

@implementation NSArchiver
+ (BOOL)archiveRootObject:(id)rootObject toFile:(NSString *)path
{
	NSData *data= [self archivedDataWithRootObject:rootObject];
	return [data writeToFile:path atomically:YES];
}
+ (NSData *)archivedDataWithRootObject:(id)rootObject
{
	NSMutableData* data; NSArchiver *archiver;
	data= [NSMutableData data];
	archiver= [ALLOC(self) initForWritingWithMutableData:data];
	[archiver encodeRootObject:rootObject];
	[archiver release];
	return data;
}
- (instancetype)initForWritingWithMutableData:(NSMutableData *)data
{
	_data= [data retain];
  _clsMap= CCreateDictionary(0);
  _refs= CCreateDictionary(128);
  return self;
}
- (void)dealloc
{
	RELEASE(_data);
  RELEASE(_clsMap);
  RELEASE(_refs);
  RELEASE(_replacements);
	[super dealloc];
}
- (NSMutableData *)archiverData
{ return _data;}
- (NSString *)classNameEncodedForTrueClassName:(NSString *)trueName
{ return _mappedClassName(_clsMap, trueName); }

- (void)encodeClassName:(NSString *)trueName intoClassName:(NSString *)inArchiveName
{
  CDictionarySetObjectForKey(_clsMap, inArchiveName, trueName);
}

- (void)encodeRootObject:(id)rootObject
{
  [rootObject encodeWithCoder:self];
}
- (void)replaceObject:(id)object withObject:(id)newObject
{ _replaceObject(&_replacements, object, newObject); }

- (void)encodeConditionalObject:(id)object
{
  if (!object || CDictionaryObjectForKey(_refs, object))
    [self encodeObject:object];
}

- (void)encodeObject:(id)object
{
  uint32_t ref;
  object= _tryReplaceObject(_replacements, object);
  ref= (uint32_t)CDictionaryObjectForKey(_refs, object);
  if (ref) {
    [_data appendBytes:&ENCODE_REF length:sizeof(ENCODE_REF)];
    ref= htonl(ref);
    [_data appendBytes:&ref length:sizeof(ref)];
  }
  else if (object) {
    const char *className; uint32_t classNameLen, classNameLenN; 
    CDictionarySetObjectForKey(_refs, (id)(++_refCounter), object);
    [_data appendBytes:&ENCODE_OBJECT length:sizeof(ENCODE_OBJECT)];
    className= [[self classNameEncodedForTrueClassName:[object className]] UTF8String];
    classNameLen= (uint32_t)strlen(className);
    classNameLenN= htonl(classNameLen);
    [_data appendBytes:&classNameLenN length:sizeof(classNameLen)];
    [_data appendBytes:className length:sizeof(char) *  classNameLen];
    [object encodeWithCoder:self];
  }
  else {
    [_data appendBytes:&ENCODE_NIL length:sizeof(ENCODE_NIL)];
  }
}

- (void)encodeValueOfObjCType:(const char *)type at:(const void *)addr
{
  NSUInteger size;
  NSGetSizeAndAlignment(type, &size, NULL);
  [_data appendBytes:addr length:size];
}

- (void)encodeDataObject:(NSData *)data
{
  [_data appendData:data];
}

@end

@implementation NSUnarchiver
+ (id)unarchiveObjectWithFile:(NSString *)path
{
  id ret; NSData *data;
  data= [ALLOC(NSData) initWithContentsOfFile:path];
  ret= [NSUnarchiver unarchiveObjectWithData:data];
  [data release];
  return ret;
}
+ (id)unarchiveObjectWithData:(NSData *)data
{
  id ret; NSUnarchiver *unarchiver;
  unarchiver= [ALLOC(self) initForReadingWithData:data];
  ret= [unarchiver decodeObject];
  [unarchiver release];
  return ret;
}
- (id)initForReadingWithData:(NSData *)data
{
  _data= [data retain];
  _clsMap= CCreateDictionary(0);
  _refs= CCreateDictionary(128);
  return self;
}
- (void)dealloc
{
  RELEASE(_clsMap);
  RELEASE(_data);
  RELEASE(_replacements);
  RELEASE(_refs);
  [super dealloc];
}

- (void)decodeClassName:(NSString *)nameInArchive asClassName:(NSString *)trueName
{ CDictionarySetObjectForKey(_clsMap, trueName, nameInArchive); }
- (NSString *)classNameDecodedForArchiveClassName:(NSString *)nameInArchive
{ return _mappedClassName(_clsMap, nameInArchive); }
- (void)replaceObject:(id)object withObject:(id)newObject
{ _replaceObject(&_replacements, object, newObject); }
- (BOOL)isAtEnd
{ return _pos == [_data length]; }

static inline void _readBytes(NSData *data, NSUInteger *pos, void *into, NSUInteger length)
{
  [data getBytes:into range:NSMakeRange(*pos, length)];
  *pos += length;
}

- (id)decodeObject
{
  id ret= nil; uint32_t ref; MSByte type;
  _readBytes(_data, &_pos, &type, sizeof(type));
  if (type == ENCODE_REF) {
    _readBytes(_data, &_pos, &ref, sizeof(ref));
    ref= ntohl(ref);
    ret= CDictionaryObjectForKey(_refs, (id)(intptr_t)ref);
  }
  else if (type == ENCODE_OBJECT) {
    uint32_t classNameLen; NSString *className; Class cls;
    _readBytes(_data, &_pos, &classNameLen, sizeof(classNameLen));
    classNameLen= ntohl(classNameLen);
    {
      char classNameUTF8[classNameLen];
      _readBytes(_data, &_pos, classNameUTF8, sizeof(char) * classNameLen);
      className= (NSString *)CCreateStringWithBytes(NSUTF8StringEncoding, classNameUTF8, classNameLen);
    }
    cls= NSClassFromString([self classNameDecodedForArchiveClassName:className]);
    ret= AUTORELEASE([ALLOC(cls) initWithCoder:self]);
    CDictionarySetObjectForKey(_refs, (id)(intptr_t)(++_refCounter), ret);
    [className release];
  }
  return _tryReplaceObject(_replacements, ret);
}

- (void)decodeValueOfObjCType:(const char *)type at:(void *)addr
{
  NSUInteger size;
  NSGetSizeAndAlignment(type, &size, NULL);
  _readBytes(_data, &_pos, addr, size);
}

@end
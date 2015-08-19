
typedef struct {
  union {
    struct 
    {
      CString *s;
      union {
        unichar u;
        MSByte bytes[4];
      };
      MSUInt idx;
    } str; // String
    struct {
      CBuffer *b;
      MSByte bytes[4];
      MSUInt idx;
    } b64; // Base64 Data    
    CBuffer *d; // Decimal
    struct 
    {
      MSUInt val;
      MSUInt idx;
    } crc;
    MSLong i8;  // INT
    MSULong u8; // UINT
  } v;
  MSByte type;
} CMSTEDecoderToken;

typedef struct {
  MSUInt allowsUnknownUserClasses:1;
  MSUInt verifyCRC:1;
} CMSTEDecoderFlags;

@interface MSMSTEDecoder : NSObject {
  MSInt _version;
  CMSTEDecoderFlags _flags;
  NSDictionary *_classMap;
  
  id _rootObject;
  CString *_error;
  CGrow *_stack;
  void *_head;
  MSByte _state;
  CMSTEDecoderToken _token;

  // MSTE0102
  MSUInt _crc, _expectedCRC;
  CArray *_classes, *_refs, *_keys;
  MSULong _tokenCount, _keysCount, _classesCount;
}
- (instancetype)init;
- (instancetype)initWithCustomClasses:(NSDictionary *)classes allowsUnknownUserClasses:(BOOL)allowsUnknownUserClasses verifyCRC:(BOOL)verifyCRC;
- (void)parseBytes:(const void *)bytes length:(NSUInteger)length;
- (id)parseResult:(NSString **)error;
@end

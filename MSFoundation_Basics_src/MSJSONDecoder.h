
typedef struct {
  union {
    struct
    {
      CString *s; // must be first in struct
      union {
        unichar u;
        MSByte bytes[4];
      };
      MSUInt idx;
    } str; // string
    CBuffer *d; // number
    id ret;
  } v;
  char type;
} CJSONDecoderToken;

@interface MSJSONDecoder : NSObject {
  id _rootObject;
  CString *_error;
  CGrow *_stack;
  void *_head;
  CJSONDecoderToken _token;
}
- (instancetype)init;
- (void)parseBytes:(const void *)bytes length:(NSUInteger)length;
- (id)parseResult:(NSString **)error;
@end

@interface NSData (JSONDecoding)
- (id)JSONDecodedObject:(NSString **)error;
@end

@class MSHttpFormParser;

@interface MSHttpFormMiddleware : NSObject <MSHttpMiddleware> {
  BOOL _simpleFormUrlParser;
}
+ (instancetype)formMiddleware;
+ (instancetype)formMiddlewareWithSimpleUrlFormParser;
@end

typedef BOOL (*MSHttpFormFieldHandler)(MSHttpFormParser *parser, int idx, NSString *name, NSString *value, MSHandlerArg *args);
typedef BOOL (*MSHttpFormFileHeaderHandler)(MSHttpFormParser *parser, int idx, NSString *name, NSString *value, MSHandlerArg *args);
typedef BOOL (*MSHttpFormFileChunkHandler)(MSHttpFormParser *parser, int idx, const MSByte *bytes, NSUInteger length, MSHandlerArg *args);

@interface MSHttpFormParser : NSObject {
  int _state; NSUInteger _fieldIdx;
  MSHandlerList _onField, _onFileHeader, _onFileChunk;
  union {
    struct {
      CBuffer *field;
      CBuffer *value;
      NSUInteger bufPos;
    } ue; // urlencoded

    struct
    {
      CBuffer *field;
      CBuffer *value;
      CBuffer *boundary;
      NSUInteger boundaryDetectPos;
    } fd; // formdata

  } _u;
}
- (instancetype)initWithUrlEncoded;
- (instancetype)initWithFormDataBoundary:(NSString *)boundary;
- (instancetype)initWithTransaction:(MSHttpTransaction*)tr allowFormData:(BOOL)allowFormData;
- (void)writeData:(NSData *)data;
- (void)writeEnd;
- (MSHandler *)addOnFieldHandler:(MSHttpFormFieldHandler)handler args:(int)argc, ...;
- (MSHandler *)addOnFileHeaderHandler:(MSHttpFormFileHeaderHandler)handler args:(int)argc, ...;
- (MSHandler *)addOnFileChunkHandler:(MSHttpFormFileChunkHandler)handler args:(int)argc, ...;
@end

@interface MSHttpTransaction (MSHttpFormParser)
- (MSHttpFormParser *)httpFormParser;
- (MSDictionary *)httpFormFields;
@end

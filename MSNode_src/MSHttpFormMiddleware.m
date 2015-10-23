#import "MSNode_Private.h"

const NSString * MSHttpFormURLEncoder = @"application/x-www-form-urlencoded";
const NSString * MSHttpFormMultipartFormData = @"multipart/form-data";



@interface MSHttpFormParser (Private)
- (instancetype)initWithTransaction:(MSHttpTransaction*)tr allowFormData:(BOOL)allowFormData;
@end

@implementation MSHttpFormMiddleware
+ (instancetype)formMiddleware
{ return AUTORELEASE([ALLOC(self) initWithSimpleUrlFormParser:NO]); }
+ (instancetype)formMiddlewareWithSimpleUrlFormParser
{ return AUTORELEASE([ALLOC(self) initWithSimpleUrlFormParser:YES]); }
- (instancetype)initWithSimpleUrlFormParser:(BOOL)simpleUrlFormParser
{
  if ((self= [self init])) {
    _simpleFormUrlParser= simpleUrlFormParser;
  }
  return self;
}

static BOOL _formmiddleware_receivedata_handler(MSHttpTransaction *tr, NSData *data, MSHandlerArg *args)
{
  [(MSHttpFormParser*)args[0].id writeData:data];
  return YES;
}

static BOOL _formmiddleware_receivefield_fast_handler(MSHttpFormParser *parser, int idx, NSString *name, NSString *value, MSHandlerArg *args)
{
  [args[0].id setObject:value forKey:name];
  return YES;
}
static BOOL _formmiddleware_receiveend_fast_handler(MSHttpTransaction *tr, NSString *error, MSHandlerArg *args)
{
  [(MSHttpFormParser*)args[0].id writeEnd];
  RELEASE(args[0].id);
  [args[1].id nextRoute];
  return YES;
}
static BOOL _formmiddleware_receiveend_events_handler(MSHttpTransaction *tr, NSString *error, MSHandlerArg *args)
{
  [args[0].id writeEnd];
  return YES;
}
- (void)onTransaction:(MSHttpTransaction *)tr
{
  MSHttpFormParser *parser; mutable MSDictionary *fields;
  parser= [ALLOC(MSHttpFormParser) initWithTransaction:tr allowFormData:!_simpleFormUrlParser];
  if (!parser) {
    [tr nextRoute];}
  else {
    [tr addReceiveDataHandler:_formmiddleware_receivedata_handler args:1, MSMakeHandlerArg(parser)];
    if (_simpleFormUrlParser) {
      // Dictionary based parsing
      fields= [MSDictionary mutableDictionary];
      [tr setObject:fields forKey:@"MSHttpFormFields"];
      [parser addOnFieldHandler:_formmiddleware_receivefield_fast_handler args:1, MSMakeHandlerArg(fields)];
      [tr addReceiveEndHandler:_formmiddleware_receiveend_fast_handler args:2, MSMakeHandlerArg(parser), MSMakeHandlerArg(tr)];
    }
    else {
      // Event based parsing
      [tr addReceiveEndHandler:_formmiddleware_receiveend_events_handler args:1, MSMakeHandlerArg(parser)];
      [tr setObject:parser forKey:@"MSHttpFormParser"];
      RELEASE(parser);
      [tr nextRoute];}}
}
@end

enum MSHttpFormParserState {
  STATE_ERROR                  =  0,
  STATE_FORMDATA_PENDING       ,
  STATE_FORMDATA_PENDING_CR    ,
  STATE_FORMDATA_PENDING_CRLF  ,
  STATE_FORMDATA_BODY          ,
  STATE_FORMDATA_BODY_END      ,
  STATE_FORMDATA_HEAD_START    ,
  STATE_FORMDATA_HEAD_CRLF     ,
  STATE_FORMDATA_HEAD_KEY_START, // SPACE until CHAR
  STATE_FORMDATA_HEAD_KEY_DATA , // CHAR until SPACE or EQ
  STATE_FORMDATA_HEAD_EQ       , // SPACE until EQ
  STATE_FORMDATA_HEAD_VAL_START, // SPACE until CHAR
  STATE_FORMDATA_HEAD_VAL_DATA , // CHAR until CR
  STATE_FORMDATA_HEAD_END      , // LF
  STATE_URLENCODED_KEY         ,
  STATE_URLENCODED_VALUE       ,
};
static inline BOOL _isUrlEncodedState(int state)
{
  return state >= STATE_URLENCODED_KEY && state <= STATE_URLENCODED_VALUE;
}
static inline BOOL _isFormDataState(int state)
{
  return state >= STATE_FORMDATA_PENDING && state <= STATE_FORMDATA_PENDING;
}

@implementation MSHttpFormParser

- (instancetype)initWithUrlEncoded
{
  _state= STATE_URLENCODED_KEY;
  _u.ue.field= CCreateBuffer(32);
  _u.ue.value= CCreateBuffer(32);
  return self;
}
- (instancetype)initWithFormDataBoundary:(NSString *)boundary
{
  _state= STATE_FORMDATA_PENDING;
  _u.fd.boundary= CCreateBuffer(0);
  CBufferAppendCString(_u.fd.boundary, "\r\n--");
  CBufferAppendCString(_u.fd.boundary, [boundary UTF8String]);
  _u.fd.boundaryDetectPos= 2;
  _u.fd.field= CCreateBuffer(32);
  _u.fd.value= CCreateBuffer(32);
  return self;
}
- (instancetype)initWithTransaction:(MSHttpTransaction*)tr allowFormData:(BOOL)allowFormData
{
  mutable MSString * mimeType; mutable MSDictionary *params;
  mimeType= [MSString new];
  params= [MSDictionary new];

  if (MSHttpParseMimeType([tr valueForHeader:@"content-type"], mimeType, params)) {
    if ([MSHttpFormURLEncoder isEqual:mimeType]) {
      self= [self initWithUrlEncoded];
    }
    else if (allowFormData && [MSHttpFormMultipartFormData isEqual:mimeType]) {
      self= [self initWithFormDataBoundary:[params objectForKey:@"boundary"]];
    }
  }

  RELEASE(mimeType);
  RELEASE(params);
  if (self && !_state)
    DESTROY(self);
  return self;
}

- (void)dealloc
{
  if (_isFormDataState(_state)) {
    RELEASE(_u.fd.boundary);
    RELEASE(_u.fd.field);
    RELEASE(_u.fd.value);}
  else if (_isUrlEncodedState(_state)) {
    RELEASE(_u.ue.field);
    RELEASE(_u.ue.value);}
  MSHandlerListFreeInside(&_onField);
  MSHandlerListFreeInside(&_onFileHeader);
  MSHandlerListFreeInside(&_onFileChunk);
  [super dealloc];
}

- (void)emitField:(int)idx
{
  CString *field= CCreateStringWithBytes(NSUTF8StringEncoding, CBufferBytes(_u.ue.field), CBufferLength(_u.ue.field));
  CString *value= CCreateStringWithBytes(NSUTF8StringEncoding, CBufferBytes(_u.ue.value), CBufferLength(_u.ue.value));
  _u.ue.field->length= 0;
  _u.ue.value->length= 0;
  MSHandlerListCall(&_onField, MSHttpFormFieldHandler, self, idx, (id)field, (id)value);
  RELEASE(field); RELEASE(value);
}
- (void)emitFileHeader:(int)idx
{
  CString *field= CCreateStringWithBytes(NSUTF8StringEncoding, CBufferBytes(_u.fd.field), CBufferLength(_u.fd.field));
  CString *value= CCreateStringWithBytes(NSUTF8StringEncoding, CBufferBytes(_u.fd.value), CBufferLength(_u.fd.value));
  _u.fd.field->length= 0;
  _u.fd.value->length= 0;
  MSHandlerListCall(&_onFileHeader, MSHttpFormFileHeaderHandler, self, idx, (id)field, (id)value);
  RELEASE(field); RELEASE(value);
}
- (void)emitFileChunk:(int)idx bytes:(const MSByte *)bytes length:(NSUInteger)length
{ MSHandlerListCall(&_onFileChunk, MSHttpFormFileChunkHandler, self, idx, bytes, length); }

- (MSHandler *)addOnFieldHandler:(MSHttpFormFieldHandler)handler args:(int)argc, ...
{ return MSHandlerListAdd(&_onField, handler, argc, argc); }
- (MSHandler *)addOnFileHeaderHandler:(MSHttpFormFileHeaderHandler)handler args:(int)argc, ...
{ return MSHandlerListAdd(&_onFileHeader, handler, argc, argc); }
- (MSHandler *)addOnFileChunkHandler:(MSHttpFormFileChunkHandler)handler args:(int)argc, ...
{ return MSHandlerListAdd(&_onFileChunk, handler, argc, argc); }

static inline BOOL _hexaCharValue(MSByte *c)
{
  if ('0' <= *c && *c <= '9') *c= *c - '0';
  else if ('a' <= *c && *c <= 'f') *c= 10 + *c - 'a';
  else if ('A' <= *c && *c <= 'F') *c= 10 + *c - 'A';
  else return NO;
  return YES;
}
static inline BOOL decodeOneChar(MSByte byte, CBuffer *buffer, NSUInteger *bufferPos)
{
  BOOL ret; NSUInteger pos;

  pos= *bufferPos;
  if ((ret= pos == 0)) {
    if (byte != '%')
      CBufferAppendByte(buffer, byte == '+' ? (MSByte)' ' : byte);
    else
      *bufferPos= 1;
  }
  else if (pos == 1) {
    if ((ret= _hexaCharValue(&byte))) {
      CBufferAppendByte(buffer, byte);
      *bufferPos= 2;
    }
  }
  else if (pos == 2) {
    if ((ret= _hexaCharValue(&byte))) {
      MSByte *p;
      p= buffer->buf + buffer->length - 1;
      *p= *p * 16 + byte;
      *bufferPos= 0;
    }
  }
  return ret;
}

/*
# RFC 822, Header resume

Character domain is ASCII
    field = field-name ":" [ field-body ] CRLF
    field-name = 1*<any CHAR, excluding CTLs, SPACE, and ":">
    field-body = field-body-contents [CRLF LWSP-char field-body]
    field-body-contents = 1*<any CHAR, excluding CTLs>
*/
static inline BOOL _isInRestrictedASCIIRange(MSByte b)
{
  return b > 31 && b < 127;
}

- (void)writeData:(NSData *)data
{
  CBuffer *d; const MSByte *bytes; NSUInteger pos, len, detectPos, start; MSByte b; enum MSHttpFormParserState state, pstate;
  state= (enum MSHttpFormParserState)_state;
  d= (CBuffer *)data;
  bytes= (const MSByte*)[data bytes];
  start= 0;
  pos= 0;
  len= [data length];
  detectPos= _u.fd.boundaryDetectPos;

  while(state != STATE_ERROR && pos < len) {
    b= bytes[pos++];
    pstate= state;
    state= 0;
    switch(pstate) {
      case STATE_ERROR:
        break;

      case STATE_FORMDATA_PENDING:
        state= STATE_FORMDATA_PENDING;
        if (b != CBufferByteAtIndex(_u.fd.boundary, detectPos++)) {
          detectPos= 0; // We are pending the first boundary, we can drop everything here
        }
        else if (detectPos == CBufferLength(_u.fd.boundary)) {
          state= STATE_FORMDATA_PENDING_CR; // The next byte is an head
          detectPos= 0;
          _u.fd.boundaryDetectPos= 0;
        }
        break;

      case STATE_FORMDATA_PENDING_CR:
        if (b == '\r')
          state= STATE_FORMDATA_PENDING_CRLF;
        break;

      case STATE_FORMDATA_PENDING_CRLF:
        if (b == '\n')
          state= STATE_FORMDATA_HEAD_START;
        break;

      case STATE_FORMDATA_BODY:
        state= STATE_FORMDATA_BODY;
        if (b != CBufferByteAtIndex(_u.fd.boundary, detectPos++)) {
          detectPos= 0;}
        else if (detectPos == CBufferLength(_u.fd.boundary)) {
          if (_u.fd.boundaryDetectPos > 0 && pos >= detectPos) { // Some parts were frozen by the previous pass
            [self emitFileChunk:_fieldIdx bytes:CBufferBytes(_u.fd.boundary) length:_u.fd.boundaryDetectPos];}
          [self emitFileChunk:_fieldIdx bytes:bytes + start length:pos - start - detectPos + _u.fd.boundaryDetectPos];
          _u.fd.boundaryDetectPos= 0;
          ++_fieldIdx;
          state = STATE_FORMDATA_BODY_END;
          detectPos= 0;}
        break;

      case STATE_FORMDATA_BODY_END:
        if (b == '-')
          state= STATE_ERROR;
        else if (b == '\r')
          state= STATE_FORMDATA_PENDING_CRLF;
        break;

      case STATE_FORMDATA_HEAD_START:
        if (b == '\r')
          state= STATE_FORMDATA_HEAD_CRLF;
        else if (b == ' ' || b == '\t')
          state= STATE_FORMDATA_HEAD_KEY_START;
        else if (_isInRestrictedASCIIRange(b))
          state= STATE_FORMDATA_HEAD_KEY_DATA;
        break;

      case STATE_FORMDATA_HEAD_CRLF:
        if (b == '\n') {
          state= STATE_FORMDATA_BODY;
          start= pos;
        }
        break;

      case STATE_FORMDATA_HEAD_KEY_START:
        if (b == ' ' || b == '\t')
          state= STATE_FORMDATA_HEAD_KEY_START;
        else if (_isInRestrictedASCIIRange(b))
          state= STATE_FORMDATA_HEAD_KEY_DATA;
        break;

      case STATE_FORMDATA_HEAD_KEY_DATA:
        if (b == ' ' || b == '\t')
          state= STATE_FORMDATA_HEAD_EQ;
        else if (b == ':')
          state= STATE_FORMDATA_HEAD_VAL_START;
        else if (_isInRestrictedASCIIRange(b))
          state= STATE_FORMDATA_HEAD_KEY_DATA;
        break;

      case STATE_FORMDATA_HEAD_EQ:
        if (b == ':')
          state= STATE_FORMDATA_HEAD_VAL_START;
        else if (b == ' ' || b == '\t')
          state= STATE_FORMDATA_HEAD_EQ;
        break;

      case STATE_FORMDATA_HEAD_VAL_START:
        if (b == ' ' || b == '\t')
          state= STATE_FORMDATA_HEAD_VAL_START;
        else if (_isInRestrictedASCIIRange(b))
          state= STATE_FORMDATA_HEAD_VAL_DATA;
        break;

      case STATE_FORMDATA_HEAD_VAL_DATA:
        if (b == '\r')
          state= STATE_FORMDATA_HEAD_END;
        else
          state= STATE_FORMDATA_HEAD_VAL_DATA;
        break;

      case STATE_FORMDATA_HEAD_END:
        if (b == '\n')
          state= STATE_FORMDATA_HEAD_START;
        break;

      case STATE_URLENCODED_KEY:
        if (b == '=' && _u.ue.bufPos == 0) {
          state= STATE_URLENCODED_VALUE;}
        else if (b == '&' && _u.ue.bufPos == 0 && CBufferLength(_u.ue.field) > 0) {
          [self emitField:_fieldIdx++];
          state= STATE_URLENCODED_KEY;}
        else if (decodeOneChar(b, _u.ue.field, &_u.ue.bufPos)) {
          state= STATE_URLENCODED_KEY;}
        break;

      case STATE_URLENCODED_VALUE:
        if (b == '&' && _u.ue.bufPos == 0) {
          [self emitField:_fieldIdx++];
          state= STATE_URLENCODED_KEY;}
        else if (decodeOneChar(b, _u.ue.value, &_u.ue.bufPos)) {
          state= STATE_URLENCODED_VALUE;}
        break;
    }
    if (state == STATE_FORMDATA_HEAD_VAL_DATA) {
      CBufferAppendByte(_u.fd.value, b);
    }
    else if (state == STATE_FORMDATA_HEAD_KEY_DATA) {
      CBufferAppendByte(_u.fd.field, b);
    }
    else if (state == STATE_FORMDATA_HEAD_END) {
      [self emitFileHeader:_fieldIdx];
    }
  }

  if (state == STATE_FORMDATA_BODY && pos - detectPos > start) {
    [self emitFileChunk:_fieldIdx bytes:bytes + start length:pos - start - detectPos];
  }
  _u.fd.boundaryDetectPos= detectPos;
  _state= (int)state;
}
- (void)writeEnd
{
  if (_isUrlEncodedState(_state) && CBufferLength(_u.ue.field) > 0 && _u.ue.bufPos == 0) {
    [self emitField:_fieldIdx++];
  }
}

@end

@implementation MSHttpTransaction (MSHttpFormParser)
- (MSHttpFormParser *)httpFormParser
{
  return [self objectForKey:@"MSHttpFormParser"];
}

- (MSDictionary *)httpFormFields
{
  return [self objectForKey:@"MSHttpFormFields"];
}
@end

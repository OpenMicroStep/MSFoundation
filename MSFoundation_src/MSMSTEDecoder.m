#import "MSFoundation_Private.h"

typedef enum {
  STATE_START=0,
  STATE_END,
  STATE_VERSION,
  STATE_COUNT,
  STATE_CRC,
  STATE_CLASSESCOUNT,
  STATE_CLASSNAME,
  STATE_KEYSCOUNT,
  STATE_KEYNAME,
  STATE_CODE,
  STATE_CODE_1,
  STATE_DATA,
  STATE_DICTIONARY_KEY,
  STATE_NARRAY,
  STATE_STRING
} CMSTEDecoderState;

typedef enum {
  TOKEN_START=0,
  TOKEN_END,
  TOKEN_STRING_OR_UINT,
  TOKEN_STRING,
  TOKEN_STRING_CONTENT,
  TOKEN_STRING_UTF8_1,
  TOKEN_STRING_UTF8_2,
  TOKEN_STRING_UTF8_3,
  TOKEN_STRING_ESCAPE,
  TOKEN_STRING_UNICODE,
  TOKEN_STRING_END,
  TOKEN_DECIMAL,
  TOKEN_DECIMAL_DIGITS_OR_SEP,
  TOKEN_DECIMAL_DIGITS,
  TOKEN_CRC,
  TOKEN_CRC_CONTENT,
  TOKEN_CRC_END,
  TOKEN_DATA,
  TOKEN_DATA_CONTENT,
  TOKEN_DATA_END,
  TOKEN_INT,
  TOKEN_UINT,
  TOKEN_UINT_POS,
  TOKEN_INT_POS,
  TOKEN_INT_NEG,
} CMSTEDecoderTokenType;

static const char *_stateNames[] = {
  "STATE_START",
  "STATE_END",
  "STATE_VERSION",
  "STATE_COUNT",
  "STATE_CRC",
  "STATE_CLASSESCOUNT",
  "STATE_CLASSNAME",
  "STATE_KEYSCOUNT",
  "STATE_KEYNAME",
  "STATE_CODE",
  "STATE_CODE_1",
  "STATE_DATA",
  "STATE_DICTIONARY_KEY",
  "STATE_NARRAY",
  "STATE_STRING",
};
static const char *_tokenTypeNames[] = {
  "TOKEN_START",
  "TOKEN_END",
  "TOKEN_STRING_OR_UINT",
  "TOKEN_STRING",
  "TOKEN_STRING_CONTENT",
  "TOKEN_STRING_UTF8_1",
  "TOKEN_STRING_UTF8_2",
  "TOKEN_STRING_UTF8_3",
  "TOKEN_STRING_ESCAPE",
  "TOKEN_STRING_UNICODE",
  "TOKEN_STRING_END",
  "TOKEN_DECIMAL",
  "TOKEN_DECIMAL_DIGITS_OR_SEP",
  "TOKEN_DECIMAL_DIGITS",
  "TOKEN_CRC",
  "TOKEN_CRC_CONTENT",
  "TOKEN_CRC_END",
  "TOKEN_DATA",
  "TOKEN_DATA_CONTENT",
  "TOKEN_DATA_END",
  "TOKEN_INT",
  "TOKEN_UINT",
  "TOKEN_UINT_POS",
  "TOKEN_INT_POS",
  "TOKEN_INT_NEG"
};
static const CMSTEDecoderTokenType _stateToTokenType[] = {
  [STATE_START]= TOKEN_START,
  [STATE_END]= TOKEN_END,
  [STATE_VERSION]= TOKEN_STRING,
  [STATE_COUNT]= TOKEN_UINT,
  [STATE_CRC]= TOKEN_CRC,
  [STATE_CLASSESCOUNT]= TOKEN_UINT,
  [STATE_CLASSNAME]= TOKEN_STRING,
  [STATE_KEYSCOUNT]= TOKEN_UINT,
  [STATE_KEYNAME]= TOKEN_STRING,
  [STATE_CODE]= TOKEN_UINT,
  [STATE_CODE_1]= TOKEN_UINT,
  [STATE_DATA]= TOKEN_DATA,
  [STATE_DICTIONARY_KEY]= TOKEN_STRING_OR_UINT,
  [STATE_NARRAY]= TOKEN_UINT,
  [STATE_STRING]= TOKEN_STRING,
};

typedef struct {
  id obj;
  id key;
  id cls;
  MSUInt code;
  NSUInteger count;
} CMSTEDecoderStack;

typedef struct 
{
  MSCORE_NSOBJECT_ATTRIBUTES
  MSInt version;
  CMSTEDecoderFlags flags;
  NSDictionary *classMap;
  
  id rootObject;
  CString *error;
  CGrow *stack;
  CMSTEDecoderStack *head;
  MSByte state;
  CMSTEDecoderToken token;

  // MSTE0102
  MSUInt crc, expectedCRC;
  CArray *classes, *refs, *keys;
  MSULong tokenCount, keysCount, classesCount;
} CMSTEDecoder;

MSUInt _MSBytesLargeCRCAppend(MSUInt crc, MSByte b);
static void CMSTEDecoderInit(CMSTEDecoder *self);
static void CMSTEDecoderFinish(CMSTEDecoder *self);
static void CMSTEDecoderError(CMSTEDecoder *self, const char *err, ...);
static void CMSTEDecoderPush(CMSTEDecoder *self, MSUInt code);
static void CMSTEDecoderPop(CMSTEDecoder *self, id ret);
static void CMSTEDecoderCleanStack(CMSTEDecoder *self);
static void CMSTEDecoderCleanToken(CMSTEDecoder *self);
static void CMSTEDecoderExpect(CMSTEDecoder *self, CMSTEDecoderState state);
static id CMSTEDecoderParseResult(CMSTEDecoder *self, NSString **error);
static void CMSTEDecoderParseBytes(CMSTEDecoder *self, const MSByte *bytes, NSUInteger length);
static void CMSTEDecoderHandleToken(CMSTEDecoder *self);
static inline void CMSTEDecoderHandleTokenCode(CMSTEDecoder *self, MSULong code);
static inline void CMSTEDecoderHandleTokenCode1(CMSTEDecoder *self, MSULong code);
static void CMSTEDecoderHandleReturn(CMSTEDecoder* self, id ret);

static void CMSTEDecoderInit(CMSTEDecoder *self)
{
  self->crc= 0XFFFFFFFF;
  self->stack= (CGrow *)MSCallocFatal(1, sizeof(CGrow), "CMSTEDecodeInit");
  self->stack->flags.elementBytes= sizeof(CMSTEDecoderStack);
  self->classes= CCreateArray(0);
  self->refs= CCreateArray(0);
  self->keys= CCreateArray(0);
}

static void CMSTEDecoderFinish(CMSTEDecoder *self)
{
  CMSTEDecoderCleanToken(self);
  CMSTEDecoderCleanStack(self);
  RELEASE(self->error);
  RELEASE(self->classes);
  RELEASE(self->refs);
  RELEASE(self->keys);
  RELEASE(self->classMap);
  RELEASE(self->rootObject);
  CGrowFreeInside((id)self->stack);
  MSFree(self->stack, "CMSTEDecoderFinish");
}

static void CMSTEDecoderError(CMSTEDecoder *self, const char *err, ...)
{
  va_list vp;
  CMSTEDecoderCleanStack(self);
  CMSTEDecoderCleanToken(self);

  self->error= CCreateString(0);
  va_start(vp, err);
  CStringAppendFormatv(self->error, err, vp);
  va_end(vp);
}
static void CMSTEDecoderPush(CMSTEDecoder *self, MSUInt code)
{
  CMSTEDecoderStack *s;
  CGrowGrow((id)self->stack, 1);
  s= (CMSTEDecoderStack *)self->stack->zone;
  s+= self->stack->count++;
  memset(s, 0, sizeof(CMSTEDecoderStack));
  s->code= code;
  self->head= s;
}

static void CMSTEDecoderPop(CMSTEDecoder *self, id ret)
{
  self->head--;
  --self->stack->count;
  CMSTEDecoderHandleReturn(self, ret);
}

#define CMSTEDecoderPopI8(self, error, TYPE, METHOD) \
{ \
  MSLong v= self->token.v.i8; \
  if (TYPE ## Min <= v && v <= TYPE ## Max) \
    CMSTEDecoderPop(self, [NSNumber METHOD:(TYPE)v]); \
  else \
    CMSTEDecoderError(self, "Unable to decode native integer, value %lld is out of bounds [%lld, %lld]", v, (MSLong)TYPE ## Min, (MSLong)TYPE ## Max); \
}

#define CMSTEDecoderPopU8(self, error, TYPE, METHOD) \
{ \
  MSULong v= self->token.v.u8; \
  if (v <= TYPE ## Max) \
    CMSTEDecoderPop(self, [NSNumber METHOD:(TYPE)v]); \
  else \
    CMSTEDecoderError(self, "Unable to decode native integer, value %lld is out of bounds [0, %lld]", v, (MSLong)TYPE ## Max); \
}
static void CMSTEDecoderCleanStack(CMSTEDecoder *self)
{
  while(self->stack->count > 0) {
    CMSTEDecoderStack *s;
    s= (CMSTEDecoderStack *)self->stack->zone;
    s+= --self->stack->count;
    RELEASE(s->obj);
    RELEASE(s->key);
    RELEASE(s->cls);}
}
static void CMSTEDecoderCleanToken(CMSTEDecoder *self)
{
  switch (self->token.type) {
    case TOKEN_STRING:
    case TOKEN_STRING_CONTENT:
    case TOKEN_STRING_UTF8_1:
    case TOKEN_STRING_UTF8_2:
    case TOKEN_STRING_UTF8_3:
    case TOKEN_STRING_ESCAPE:
    case TOKEN_STRING_UNICODE:
    case TOKEN_STRING_END:
      DESTROY(self->token.v.str.s);
      break;
    case TOKEN_DECIMAL:
      DESTROY(self->token.v.d);
      break;
    case TOKEN_DATA:
    case TOKEN_DATA_CONTENT:
    case TOKEN_DATA_END:
      DESTROY(self->token.v.b64.b);
      break;
    default:
      break;
  }
}
static void CMSTEDecoderExpectTokenType(CMSTEDecoder *self, CMSTEDecoderTokenType tokenType)
{
  CMSTEDecoderCleanToken(self);
  self->token.type= tokenType;
  switch (tokenType) {
    case TOKEN_STRING:
      self->token.v.str.s= CCreateString(0);
      break;
    case TOKEN_DATA:
      self->token.v.b64.b= CCreateBuffer(0);
      self->token.v.b64.idx= 0;
      break;
    case TOKEN_DECIMAL:
      self->token.v.d= CCreateBuffer(0);
      break;
    case TOKEN_INT:
      self->token.v.i8= 0;
      break;
    case TOKEN_UINT:
      self->token.v.u8= 0;
      break;
    case TOKEN_CRC:
      self->token.v.crc.idx= 0;
      self->token.v.crc.val= 0;
      break;
    case TOKEN_STRING_OR_UINT:
    case TOKEN_START:
    case TOKEN_END:
      break;
    default:
      CMSTEDecoderError(self, "Invalid token type %lld, this is a bug in CMSTEDecoderExpect", (MSLong)tokenType);
      break;
  }
}
static void CMSTEDecoderExpect(CMSTEDecoder *self, CMSTEDecoderState state)
{
  self->state= state;
  CMSTEDecoderExpectTokenType(self, _stateToTokenType[state]);
}

static id CMSTEDecoderParseResult(CMSTEDecoder *self, NSString **error)
{
  id ret= nil;
  if (!self->error && self->token.type != TOKEN_END) {
    CMSTEDecoderError(self, "MSTE string is incomplete");}
  if (!self->error) {
    ret= self->rootObject;}
  else if(error) {
    *error= (id)self->error;}
  return ret;
}

static inline id CMSTEDecoderReference(CMSTEDecoder *self, id o)
{
  CArrayAddObject(self->refs, o);
  return o;
}
static inline Class CMSTEDecoderClassFor(CMSTEDecoder* self, id classname)
{
  id mappedClassname= [self->classMap objectForKey:classname];
  if (!mappedClassname)
    mappedClassname= classname;
  return NSClassFromString(mappedClassname);
}

static inline BOOL _hexaCharValue(MSByte *c)
{
  if ('0' <= *c && *c <= '9') *c= *c - '0';
  else if ('a' <= *c && *c <= 'f') *c= 10 + *c - 'a';
  else if ('A' <= *c && *c <= 'F') *c= 10 + *c - 'A';
  else return NO;
  return YES;
}

static inline BOOL _isTokenSeparator(MSByte c)
{
  return c == ',' || c == ']';
}
static void CMSTEDecoderParseBytes(CMSTEDecoder *self, const MSByte *bytes, NSUInteger length)
{
  const MSByte *pc= bytes, *pe= pc + length;
  MSByte c;
  //NSLog(@"CMSTEDecoderParseBytes(%p, %.*s, %d)", self, (int)length, bytes, (int)length);
  while (!self->error && pc < pe) {
    c= *(pc++);
    //NSLog(@"CMSTEDecoderParseBytes %c %s %s", c, _tokenTypeNames[self->token.type], _stateNames[self->state]);
    if (self->token.type != TOKEN_CRC_CONTENT || self->token.v.crc.idx < 3 || self->token.v.crc.idx >= 11)
      self->crc= _MSBytesLargeCRCAppend(self->crc, c);
    if (self->token.type == TOKEN_STRING_OR_UINT) {  
      if (c == '"') CMSTEDecoderExpectTokenType(self, TOKEN_STRING);
      else if('0' <= c && c <= '9') CMSTEDecoderExpectTokenType(self, TOKEN_UINT);
      else CMSTEDecoderError(self, "The start of a string '\"' or a reference number was expected");
    }
    switch(self->token.type) {
      case TOKEN_START:
        if (c == '[') CMSTEDecoderExpect(self, STATE_VERSION);
        else CMSTEDecoderError(self, "MSTE string must start with '[', %.*s", (int)length, bytes);
        break;
      case TOKEN_END:
        CMSTEDecoderError(self, "MSTE is already at end");
        break;
      case TOKEN_STRING:
        if (c == '"') self->token.type= TOKEN_STRING_CONTENT;
        else CMSTEDecoderError(self, "The start of a string '\"' was expected");
        break;
      case TOKEN_STRING_CONTENT:
        if (c == '\\') self->token.type= TOKEN_STRING_ESCAPE;
        else if (c == '"') self->token.type= TOKEN_STRING_END;
        else if (c < 0x7F) CStringAppendCharacter(self->token.v.str.s, (unichar)c);
        else if (0xC2 <= c && c <= 0xDF) { self->token.type= TOKEN_STRING_UTF8_1; self->token.v.str.bytes[0]= c; self->token.v.str.idx=1;}
        else if (0xE0 <= c && c <= 0xEF) { self->token.type= TOKEN_STRING_UTF8_2; self->token.v.str.bytes[0]= c; self->token.v.str.idx=1;}
        else if (0xF0 <= c && c <= 0xF4) { self->token.type= TOKEN_STRING_UTF8_3; self->token.v.str.bytes[0]= c; self->token.v.str.idx=1;}
        else CMSTEDecoderError(self, "Invalid string character %c", c);
        break;
      case TOKEN_STRING_UTF8_1:
        self->token.v.str.bytes[self->token.v.str.idx++]= c;
        CStringAppendBytes(self->token.v.str.s, NSUTF8StringEncoding, (const void *)self->token.v.str.bytes, (NSUInteger)self->token.v.str.idx);
        break;
      case TOKEN_STRING_UTF8_2:
        self->token.v.str.bytes[self->token.v.str.idx++]= c;
        self->token.type= TOKEN_STRING_UTF8_1;
        break;
      case TOKEN_STRING_UTF8_3:
        self->token.v.str.bytes[self->token.v.str.idx++]= c;
        self->token.type= TOKEN_STRING_UTF8_2;
        break;
      case TOKEN_STRING_ESCAPE:
        switch(c) {
          case '"': CStringAppendCharacter(self->token.v.str.s, (unichar)'"' ); self->token.type= TOKEN_STRING_CONTENT; break;
          case '\\':CStringAppendCharacter(self->token.v.str.s, (unichar)'\\'); self->token.type= TOKEN_STRING_CONTENT; break;
          case '/': CStringAppendCharacter(self->token.v.str.s, (unichar)'/'); self->token.type= TOKEN_STRING_CONTENT; break;
          case 'b': CStringAppendCharacter(self->token.v.str.s, (unichar)'\b'); self->token.type= TOKEN_STRING_CONTENT; break;
          case 'f': CStringAppendCharacter(self->token.v.str.s, (unichar)'\f'); self->token.type= TOKEN_STRING_CONTENT; break;
          case 'n': CStringAppendCharacter(self->token.v.str.s, (unichar)'\n'); self->token.type= TOKEN_STRING_CONTENT; break;
          case 'r': CStringAppendCharacter(self->token.v.str.s, (unichar)'\r'); self->token.type= TOKEN_STRING_CONTENT; break;
          case 't': CStringAppendCharacter(self->token.v.str.s, (unichar)'\t'); self->token.type= TOKEN_STRING_CONTENT; break;
          case 'u': self->token.v.str.u= 0; self->token.v.str.idx= 0; self->token.type= TOKEN_STRING_UNICODE; break;
          default: CMSTEDecoderError(self, "escaped character %c not valid", c); break;
        }
        break;
      case TOKEN_STRING_UNICODE:
        if (_hexaCharValue(&c)) { 
          self->token.v.str.u = (self->token.v.str.u << 4) + (unichar)c;
          if (++self->token.v.str.idx == 4) {
            CStringAppendCharacter(self->token.v.str.s, self->token.v.str.u);
            self->token.type= TOKEN_STRING_CONTENT;}}
        else CMSTEDecoderError(self, "a hexadecimal character was expected");
        break;
      case TOKEN_STRING_END:
        if (_isTokenSeparator(c)) { CMSTEDecoderHandleToken(self); }
        else CMSTEDecoderError(self, "a token separator ',' or ']' was expected");
        break;

      case TOKEN_INT:
        if (c == '-') { self->token.type= TOKEN_INT_NEG; }
        else if (c == '+') { self->token.type= TOKEN_INT_POS; }
        else if ('0' <= c && c <= '9') { self->token.type= TOKEN_INT_POS; self->token.v.u8= c - '0'; }
        else { CMSTEDecoderError(self, "A '-' or '+' or a positive integer was expected"); }
        break;

      case TOKEN_UINT:
        if ('0' <= c && c <= '9') { self->token.type= TOKEN_UINT_POS; self->token.v.u8= c - '0'; }
        else { CMSTEDecoderError(self, "A positive integer was expected"); }
        break;

      case TOKEN_UINT_POS: 
      case TOKEN_INT_POS: 
      case TOKEN_INT_NEG:
        if ('0' <= c && c <= '9') {
          self->token.v.u8= self->token.v.u8 * 10 + c - '0'; }
        else if (_isTokenSeparator(c)) {
          if (self->token.type == TOKEN_INT_POS) self->token.v.i8= (MSLong)self->token.v.u8;
          else if (self->token.type == TOKEN_INT_NEG) self->token.v.i8= -(MSLong)self->token.v.u8;
          CMSTEDecoderHandleToken(self); }
        else { CMSTEDecoderError(self, "An integer was expected"); }
        break;

      case TOKEN_DECIMAL:
        if (('0' <= c && c <= '9') || c == '+' || c == '-') { 
          self->token.type = TOKEN_DECIMAL_DIGITS_OR_SEP; 
          CBufferAppendBytes(self->token.v.d, (MSByte *)&c, 1);}
        else if (_isTokenSeparator(c)) { CMSTEDecoderHandleToken(self); }
        else { CMSTEDecoderError(self, "An integer was expected");}
        break;
      case TOKEN_DECIMAL_DIGITS_OR_SEP:
        if ('.' == c) {
          CBufferAppendBytes(self->token.v.d, (MSByte *)&c, 1);
          self->token.type = TOKEN_DECIMAL_DIGITS;}
        else if ('0' <= c && c <= '9') CBufferAppendBytes(self->token.v.d, (MSByte *)&c, 1);
        else if (_isTokenSeparator(c)) { CMSTEDecoderHandleToken(self); }
        else { CMSTEDecoderError(self, "An integer was expected");}
        break;
      case TOKEN_DECIMAL_DIGITS:
        if ('0' <= c && c <= '9') CBufferAppendBytes(self->token.v.d, (MSByte *)&c, 1);
        else if (_isTokenSeparator(c)) { CMSTEDecoderHandleToken(self); }
        else { CMSTEDecoderError(self, "An integer was expected");}
        break;

      case TOKEN_CRC:
        if (c == '"') self->token.type= TOKEN_CRC_CONTENT;
        else CMSTEDecoderError(self, "The start of a string '\"' was expected");
        break;
      case TOKEN_CRC_CONTENT:
        if (c == '"') self->token.type= TOKEN_CRC_END;
        else if (self->token.v.crc.idx > 2 && self->token.v.crc.idx < 11 && _hexaCharValue(&c)) {
          self->token.v.crc.val= self->token.v.crc.val * 10 + c;
          self->token.v.crc.idx++;
          self->crc= _MSBytesLargeCRCAppend(self->crc, '0');}
        else if (c == 'C' && (self->token.v.crc.idx == 0 || self->token.v.crc.idx == 2)) self->token.v.crc.idx++;
        else if (c == 'R' && self->token.v.crc.idx == 1) self->token.v.crc.idx++;
        else CMSTEDecoderError(self, "a CRC code was expected");
        break;
      case TOKEN_CRC_END:
        if (_isTokenSeparator(c)) { CMSTEDecoderHandleToken(self); }
        else CMSTEDecoderError(self, "a token separator ',' or ']' was expected");
        break;

      case TOKEN_DATA:
        if (c == '"') self->token.type= TOKEN_DATA_CONTENT;
        else CMSTEDecoderError(self, "The start of a string '\"' was expected");
        break;
      case TOKEN_DATA_CONTENT:
        if (c != '"') {
          self->token.v.b64.bytes[self->token.v.b64.idx++]= c;
          if(self->token.v.b64.idx == 4) {
            if(!CBufferBase64DecodeAndAppendBytes(self->token.v.b64.b, self->token.v.b64.bytes, 4))
              CMSTEDecoderError(self, "Invalid base64 string");
            self->token.v.b64.idx= 0;}}
        else self->token.type= TOKEN_DATA_END;
        break;
      case TOKEN_DATA_END:
        if (_isTokenSeparator(c)) { CMSTEDecoderHandleToken(self); }
        else CMSTEDecoderError(self, "a token separator ',' or ']' was expected");
        break;
      default:
        CMSTEDecoderError(self, "Invalid token type %lld, this is a bug in CMSTEDecoderParseBytes", (MSLong)self->token.type);
        break;
    }
  }
  //NSLog(@"CMSTEDecoderParseBytes end position: %d", (int)(pc - bytes));
}


static void CMSTEDecoderHandleToken(CMSTEDecoder *self)
{
  switch(self->state) {
    case STATE_VERSION:
      if ([@"MSTE0102" isEqual:(id)self->token.v.str.s]) {
        self->version=102;
        CMSTEDecoderExpect(self, STATE_COUNT);}
      else {
        CMSTEDecoderError(self, "Unknown version %@", self->token.v.str.s); }
      break;
    case STATE_COUNT:
      self->tokenCount= self->token.v.u8;
      CMSTEDecoderExpect(self, STATE_CRC);
      break;
    case STATE_CRC:
      self->expectedCRC= self->token.v.crc.val;
      CMSTEDecoderExpect(self, STATE_CLASSESCOUNT);
      break;

    case STATE_CLASSESCOUNT:
      self->classesCount= self->token.v.u8;
      if (self->classesCount > 0)
        CMSTEDecoderExpect(self, STATE_CLASSNAME);
      else 
        CMSTEDecoderExpect(self, STATE_KEYSCOUNT);
      break;
    case STATE_CLASSNAME:
      CArrayAddObject(self->classes, (id)self->token.v.str.s);
      if (CArrayCount(self->classes) < self->classesCount)
        CMSTEDecoderExpect(self, STATE_CLASSNAME);
      else
        CMSTEDecoderExpect(self, STATE_KEYSCOUNT);
      break;

    case STATE_KEYSCOUNT:
      self->keysCount= self->token.v.u8;
      if (self->keysCount > 0)
        CMSTEDecoderExpect(self, STATE_KEYNAME);
      else 
        CMSTEDecoderExpect(self, STATE_CODE);
      break;
    case STATE_KEYNAME:
      CArrayAddObject(self->keys, (id)self->token.v.str.s);
      if (CArrayCount(self->keys) < self->keysCount)
        CMSTEDecoderExpect(self, STATE_KEYNAME);
      else
        CMSTEDecoderExpect(self, STATE_CODE);
      break;

    case STATE_CODE:
      CMSTEDecoderHandleTokenCode(self, self->token.v.u8);
      break;

    case STATE_CODE_1:
      CMSTEDecoderHandleTokenCode1(self, self->head->code);
      break;

    case STATE_DATA:
      CMSTEDecoderHandleReturn(self, CMSTEDecoderReference(self, (id)self->token.v.b64.b));
      break;

    case STATE_STRING:
      CMSTEDecoderHandleReturn(self, CMSTEDecoderReference(self, (id)self->token.v.str.s));
      break;

    case STATE_NARRAY:
      [(MSMutableNaturalArray*)self->head->obj addNatural:(NSUInteger)self->token.v.u8];
      if (--self->head->count > 0)
        CMSTEDecoderExpect(self, STATE_NARRAY);
      else
        CMSTEDecoderPop(self, AUTORELEASE(self->head->obj));
      break;

    case STATE_DICTIONARY_KEY:
      if (self->token.type == TOKEN_STRING_END)
        self->head->key= RETAIN(self->token.v.str.s);
      else if((NSUInteger)self->token.v.u8 < CArrayCount(self->keys))
        self->head->key= RETAIN(CArrayObjectAtIndex(self->keys, (NSUInteger)self->token.v.u8));
      else CMSTEDecoderError(self, "Invalid key ref %llu", self->token.v.u8);
      CMSTEDecoderExpect(self, STATE_CODE);
      break;
    case STATE_END:

      CMSTEDecoderExpect(self, STATE_END);
      break;

    default:
      CMSTEDecoderError(self, "Invalid parser state %lld, this is a bug in CMSTEDecoderHandleToken", (MSLong)self->state);
      break;
  }
}

static inline void CMSTEDecoderHandleTokenCode(CMSTEDecoder *self, MSULong code)
{
  switch(code) {
    // Constants
    case MSTE_TOKEN_TYPE_NULL             : CMSTEDecoderHandleReturn(self, nil);           break;
    case MSTE_TOKEN_TYPE_TRUE             : CMSTEDecoderHandleReturn(self, [NSNumber numberWithBool:YES]);        break;
    case MSTE_TOKEN_TYPE_FALSE            : CMSTEDecoderHandleReturn(self, [NSNumber numberWithBool:NO]);       break;
    case MSTE_TOKEN_TYPE_EMPTY_STRING     : CMSTEDecoderHandleReturn(self, @"");           break;
    case MSTE_TOKEN_TYPE_EMPTY_DATA       : CMSTEDecoderHandleReturn(self, [NSData data]); break;
    case MSTE_TOKEN_TYPE_STRING           : CMSTEDecoderExpect(self, STATE_STRING); break;

    case MSTE_TOKEN_TYPE_REFERENCED_OBJECT:
    case MSTE_TOKEN_TYPE_UNSIGNED_CHAR    :
    case MSTE_TOKEN_TYPE_UNSIGNED_SHORT   :
    case MSTE_TOKEN_TYPE_UNSIGNED_INT32   :
    case MSTE_TOKEN_TYPE_UNSIGNED_INT64   :
    case MSTE_TOKEN_TYPE_DATE             :
    case MSTE_TOKEN_TYPE_COLOR            :
    case MSTE_TOKEN_TYPE_NATURAL_ARRAY    :
    case MSTE_TOKEN_TYPE_DICTIONARY       :
    case MSTE_TOKEN_TYPE_ARRAY            :
      CMSTEDecoderPush(self, code);
      CMSTEDecoderExpect(self, STATE_CODE_1); 
      break;
    case MSTE_TOKEN_TYPE_BASE64_DATA      : 
      CMSTEDecoderExpect(self, STATE_DATA);
      break;
    case MSTE_TOKEN_TYPE_CHAR             :
    case MSTE_TOKEN_TYPE_SHORT            :
    case MSTE_TOKEN_TYPE_INT32            :
    case MSTE_TOKEN_TYPE_INT64            :
      CMSTEDecoderPush(self, code);
      CMSTEDecoderExpect(self, STATE_CODE_1); 
      CMSTEDecoderExpectTokenType(self, TOKEN_INT);
      break;
    case MSTE_TOKEN_TYPE_TIMESTAMP        :
    case MSTE_TOKEN_TYPE_FLOAT            :
    case MSTE_TOKEN_TYPE_DOUBLE           :
    case MSTE_TOKEN_TYPE_DECIMAL_VALUE    :
      CMSTEDecoderPush(self, code);
      CMSTEDecoderExpect(self, STATE_CODE_1); 
      CMSTEDecoderExpectTokenType(self, TOKEN_DECIMAL);
      break;

    case MSTE_TOKEN_TYPE_COUPLE           :
      CMSTEDecoderPush(self, code);
      CMSTEDecoderExpect(self, STATE_CODE);
      self->head->obj= CMSTEDecoderReference(self, (id)CCreateCouple(nil, nil));
      self->head->count= 2;
      break;

    default: 
      if (code >= 50) {
        NSUInteger idx= code - 50;
        if (idx < CArrayCount(self->classes)) {
          CMSTEDecoderPush(self, code);
          CMSTEDecoderExpect(self, STATE_CODE_1);
        }
        else { CMSTEDecoderError(self, "Invalid user class at index: %llu", (MSULong)idx); }}
      else { 
        CMSTEDecoderError(self, "Unknown token %llu", code);}
      break;
  }
}
static inline void CMSTEDecoderStartDecodingContainer(CMSTEDecoder *self, id obj, CMSTEDecoderState state)
{
  self->head->obj= CMSTEDecoderReference(self, obj);
  self->head->count= self->token.v.u8;
  if (self->head->count > 0)
    CMSTEDecoderExpect(self, state);
  else
    CMSTEDecoderPop(self, AUTORELEASE(self->head->obj));
}
static inline void CMSTEDecoderHandleTokenCode1(CMSTEDecoder *self, MSULong code)
{
  switch(code) {
    case MSTE_TOKEN_TYPE_REFERENCED_OBJECT:
      if ((NSUInteger)self->token.v.u8 < CArrayCount(self->refs))
        CMSTEDecoderPop(self, CArrayObjectAtIndex(self->refs, (NSUInteger)self->token.v.u8));
      else
        CMSTEDecoderError(self, "Referenced object is out of bounds");
      break;

    case MSTE_TOKEN_TYPE_CHAR          : CMSTEDecoderPopI8(self, error, MSChar  , numberWithChar);             break;
    case MSTE_TOKEN_TYPE_UNSIGNED_CHAR : CMSTEDecoderPopU8(self, error, MSByte  , numberWithUnsignedChar);     break;
    case MSTE_TOKEN_TYPE_SHORT         : CMSTEDecoderPopI8(self, error, MSShort , numberWithShort);            break;
    case MSTE_TOKEN_TYPE_UNSIGNED_SHORT: CMSTEDecoderPopU8(self, error, MSUShort, numberWithUnsignedShort);    break;
    case MSTE_TOKEN_TYPE_INT32         : CMSTEDecoderPopI8(self, error, MSInt   , numberWithInt);              break;
    case MSTE_TOKEN_TYPE_UNSIGNED_INT32: CMSTEDecoderPopU8(self, error, MSUInt  , numberWithUnsignedInt);      break;
    case MSTE_TOKEN_TYPE_INT64         : CMSTEDecoderPopI8(self, error, MSLong  , numberWithLongLong);         break;
    case MSTE_TOKEN_TYPE_UNSIGNED_INT64: CMSTEDecoderPopU8(self, error, MSULong , numberWithUnsignedLongLong); break;

    case MSTE_TOKEN_TYPE_FLOAT         : 
    {
      char *start=(char *)CBufferCString(self->token.v.d), *end= NULL;
      float f= strtof(start, &end);
      if (end > start) CMSTEDecoderPop(self, [NSNumber numberWithFloat:f]);
      else CMSTEDecoderError(self, "Unable to decode float");
      break;
    }
    case MSTE_TOKEN_TYPE_DOUBLE        :
    {
      char *start=(char *)CBufferCString(self->token.v.d), *end= NULL;
      double f= strtod(start, &end);
      if (end > start) CMSTEDecoderPop(self, [NSNumber numberWithDouble:f]);
      else CMSTEDecoderError(self, "Unable to decode double");
      break;
    }
    case MSTE_TOKEN_TYPE_DECIMAL_VALUE :
    {
      CDecimal *c= CCreateDecimalWithUTF8String((char *)CBufferCString(self->token.v.d));
      if (c) CMSTEDecoderPop(self, CMSTEDecoderReference(self, AUTORELEASE(c)));
      else   CMSTEDecoderError(self, "Unable to decode decimal");
      break;
    }
    case MSTE_TOKEN_TYPE_TIMESTAMP :
    {
      char *start=(char *)CBufferCString(self->token.v.d), *end= NULL;
      double f= strtod(start, &end);
      if (end > start) CMSTEDecoderPop(self, CMSTEDecoderReference(self, [NSDate dateWithTimeIntervalSinceReferenceDate:f - (NSTimeInterval)CDateSecondsFrom19700101To20010101]));
      else CMSTEDecoderError(self, "Unable to decode timestamp");
      break;
    }
    case MSTE_TOKEN_TYPE_DATE          : CMSTEDecoderPop(self, CMSTEDecoderReference(self, [MSDate dateWithSecondsSinceLocalReferenceDate:(MSTimeInterval)(self->token.v.i8 - CDateSecondsFrom19700101To20010101)])); break;
    case MSTE_TOKEN_TYPE_COLOR         : CMSTEDecoderPop(self, CMSTEDecoderReference(self, [MSColor colorWithCSSValue:(MSUInt)self->token.v.u8])); break;

    case MSTE_TOKEN_TYPE_NATURAL_ARRAY    :
      CMSTEDecoderStartDecodingContainer(self, [MSMutableNaturalArray new], STATE_NARRAY);
      break;
    case MSTE_TOKEN_TYPE_DICTIONARY       :
      CMSTEDecoderStartDecodingContainer(self, (id)CCreateDictionary(0), STATE_DICTIONARY_KEY);
      break;
    case MSTE_TOKEN_TYPE_ARRAY            :
      CMSTEDecoderStartDecodingContainer(self, (id)CCreateArray(0), STATE_CODE);
      break;
    default:
      if (code >= 50) {
        id classname= CArrayObjectAtIndex(self->classes, (NSUInteger)(code - 50));
        Class cls= CMSTEDecoderClassFor(self, classname);
        self->head->obj= (id)CCreateDictionary(0);
        self->head->count= self->token.v.u8;
        self->head->code= MSTE_TOKEN_TYPE_DICTIONARY;
        CMSTEDecoderExpect(self, STATE_DICTIONARY_KEY);
        if (cls) { 
          self->head->cls= CMSTEDecoderReference(self, ALLOC(cls)); }
        else if (!self->flags.allowsUnknownUserClasses) {
          CMSTEDecoderError(self, "Unknown user classe %@", classname);}
        else {
          CMSTEDecoderReference(self, self->head->obj);}}
      else {CMSTEDecoderError(self, "Unexpected code in CMSTEDecoderHandleTokenCode1, this is a decoder bug");}
      break;
  }
}
static void CMSTEDecoderHandleReturn(CMSTEDecoder* self, id ret)
{
  if(self->stack->count == 0) {
    self->rootObject= [ret retain];
    CMSTEDecoderExpect(self, STATE_END);}
  else {
    switch(self->head->code)
    {
      case MSTE_TOKEN_TYPE_DICTIONARY:
        CDictionarySetObjectForKey((CDictionary*)self->head->obj, ret, self->head->key);
        DESTROY(self->head->key);
        if (--self->head->count > 0)
          CMSTEDecoderExpect(self, STATE_DICTIONARY_KEY);
        else if (self->head->cls) 
          CMSTEDecoderPop(self, AUTORELEASE([self->head->cls initWithDictionary:AUTORELEASE(self->head->obj)]));
        else
          CMSTEDecoderPop(self, AUTORELEASE(self->head->obj));
        break;
      case MSTE_TOKEN_TYPE_ARRAY:
        CArrayAddObject((CArray*)self->head->obj, ret);
        if (--self->head->count > 0)
          CMSTEDecoderExpect(self, STATE_CODE);
        else
          CMSTEDecoderPop(self, AUTORELEASE(self->head->obj));
        break;
      case MSTE_TOKEN_TYPE_COUPLE:
        if(--self->head->count == 1) {
          CCoupleSetFirstMember((CCouple*)self->head->obj, ret);
          CMSTEDecoderExpect(self, STATE_CODE);}
        else if(self->head->count == 0) {
          CCoupleSetSecondMember((CCouple*)self->head->obj, ret);
          CMSTEDecoderPop(self, AUTORELEASE(self->head->obj));}
        break;
      default:
        CMSTEDecoderError(self, "Unexpected code in CMSTEDecoderHandleReturn, this is a decoder bug");
        break;
    }
  }
}

@implementation MSMSTEDecoder
- (instancetype)initWithCustomClasses:(NSDictionary *)classes allowsUnknownUserClasses:(BOOL)allowsUnknownUserClasses verifyCRC:(BOOL)verifyCRC
{
  if ((self= [self init])) {
    self->_classMap= [classes copy];
    self->_flags.allowsUnknownUserClasses= allowsUnknownUserClasses;
    self->_flags.verifyCRC= verifyCRC;}
  return self;
}
- (instancetype)init
{
  if ((self= [super init])) {
    CMSTEDecoderInit((CMSTEDecoder*)self);}
  return self;
}
- (void)dealloc
{
  CMSTEDecoderFinish((CMSTEDecoder*)self);
  [super dealloc];
}
- (void)parseBytes:(const void *)bytes length:(NSUInteger)length
{
  CMSTEDecoderParseBytes((CMSTEDecoder*)self, (MSByte*)bytes, length);
}
- (id)parseResult:(NSString **)error
{
  return CMSTEDecoderParseResult((CMSTEDecoder*)self, error);
}
@end
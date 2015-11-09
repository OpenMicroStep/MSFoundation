#import "MSFoundation_Private.h"

typedef enum {
  ST_ERR= -1,
  ST_VAL,
  ST_VAL_END,
  ST_END,
  ST_POP,

  ST_STR,
  ST_STR_ESCAPE,
  ST_STR_UNICODE,
  ST_STR_UTF8_1,
  ST_STR_UTF8_2,
  ST_STR_UTF8_3,

  ST_NUM,
  ST_NUM_2,
  ST_NUM_E_START,
  ST_NUM_E,

  ST_ARR,

  ST_DIC,
  ST_DIC_KEY,

  ST_YES,
  ST_YES_U,
  ST_YES_E,

  ST_NO,
  ST_NO_L,
  ST_NO_S,
  ST_NO_E,

  ST_NIL,
  ST_NIL_U,
  ST_NIL_L1,
  ST_NIL_L2
} CJSONDecoderState;

static const char *_tokenTypeNames[] = {
  "ST_ERR",
  "ST_VAL",
  "ST_VAL_END",
  "ST_END",
  "ST_POP",
  "ST_STR",
  "ST_STR_ESCAPE",
  "ST_STR_UNICODE",
  "ST_STR_UTF8_1",
  "ST_STR_UTF8_2",
  "ST_STR_UTF8_3",
  "ST_NUM",
  "ST_NUM_2",
  "ST_NUM_E_START",
  "ST_NUM_E",
  "ST_ARR",
  "ST_DIC",
  "ST_DIC_KEY",
  "ST_YES",
  "ST_YES_U",
  "ST_YES_E",
  "ST_NO",
  "ST_NO_L",
  "ST_NO_S",
  "ST_NO_E",
  "ST_NIL",
  "ST_NIL_U",
  "ST_NIL_L1",
  "ST_NIL_L2",
};

static const CJSONDecoderState _valueCharToState[128] = {
/*   0 nul    1 soh    2 stx    3 etx    4 eot    5 enq    6 ack    7 bel  */
   ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,
/*   8 bs     9 ht    10 nl    11 vt    12 np    13 cr    14 so    15 si   */
   ST_ERR,  ST_VAL,  ST_VAL,  ST_ERR,  ST_ERR,  ST_VAL,  ST_ERR,  ST_ERR,
/*  16 dle   17 dc1   18 dc2   19 dc3   20 dc4   21 nak   22 syn   23 etb */
   ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,
/*  24 can   25 em    26 sub   27 esc   28 fs    29 gs    30 rs    31 us  */
   ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,
/*  32 sp    33  !    34  "    35  #    36  $    37  %    38  &    39  '  */
   ST_VAL,  ST_ERR,  ST_STR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,
/*  40  (    41  )    42  *    43  +    44  ,    45  -    46  .    47  /  */
   ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_NUM,  ST_ERR,  ST_ERR,
/*  48  0    49  1    50  2    51  3    52  4    53  5    54  6    55  7  */
   ST_NUM,  ST_NUM,  ST_NUM,  ST_NUM,  ST_NUM,  ST_NUM,  ST_NUM,  ST_NUM,
/*  56  8    57  9    58  :    59  ;    60  <    61  =    62  >    63  ?  */
   ST_NUM,  ST_NUM,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,
/*  64  @    65  A    66  B    67  C    68  D    69  E    70  F    71  G  */
   ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,
/*  72  H    73  I    74  J    75  K    76  L    77  M    78  N    79  O  */
   ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,
/*  80  P    81  Q    82  R    83  S    84  T    85  U    86  V    87  W  */
   ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,
/*  88  X    89  Y    90  Z    91  [    92  \    93  ]    94  ^    95  _  */
   ST_ERR,  ST_ERR,  ST_ERR,  ST_ARR,  ST_ERR,  ST_POP,  ST_ERR,  ST_ERR,
/*  96  `    97  a    98  b    99  c   100  d   101  e   102  f   103  g  */
   ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_NO ,  ST_ERR,
/* 104  h   105  i   106  j   107  k   108  l   109  m   110  n   111  o  */
   ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_NIL,  ST_ERR,
/* 112  p   113  q   114  r   115  s   116  t   117  u   118  v   119  w  */
   ST_ERR,  ST_ERR,  ST_ERR,  ST_ERR,  ST_YES,  ST_ERR,  ST_ERR,  ST_ERR,
/* 120  x   121  y   122  z   123  {   124  |   125  }   126  ~   127 del */
   ST_ERR,  ST_ERR,  ST_ERR,  ST_DIC,  ST_ERR,  ST_POP,  ST_ERR,  ST_ERR
};

typedef struct {
  id obj;
  id key;
  MSByte popChar;
} CJSONDecoderStack;

typedef struct
{
  MSCORE_NSOBJECT_ATTRIBUTES
  id rootObject;
  CString *error;
  CGrow *stack;
  CJSONDecoderStack *head;
  CJSONDecoderToken token;
} CJSONDecoder;

static void CJSONDecoderInit(CJSONDecoder *self);
static void CJSONDecoderFinish(CJSONDecoder *self);
static void CJSONDecoderError(CJSONDecoder *self, const char *err, ...);
static void CJSONDecoderPush(CJSONDecoder *self, id retainedObj, MSByte popChar);
static void CJSONDecoderPop(CJSONDecoder *self);
static void CJSONDecoderCleanStack(CJSONDecoder *self);
static void CJSONDecoderCleanToken(CJSONDecoder *self);
static void CJSONDecoderExpect(CJSONDecoder *self, CJSONDecoderState state, MSByte currentChar);
static id CJSONDecoderParseResult(CJSONDecoder *self, NSString **error);
static void CJSONDecoderParseBytes(CJSONDecoder *self, const MSByte *bytes, NSUInteger length);
static void CJSONDecoderHandleReturn(CJSONDecoder* self, id ret);
static void CJSONDecoderTokenEnd(CJSONDecoder* self, MSByte reason);

static void CJSONDecoderInit(CJSONDecoder *self)
{
  self->stack= (CGrow *)MSCallocFatal(1, sizeof(CGrow), "CJSONDecodeInit");
  self->stack->flags.elementBytes= sizeof(CJSONDecoderStack);
}

static void CJSONDecoderFinish(CJSONDecoder *self)
{
  CJSONDecoderCleanToken(self);
  CJSONDecoderCleanStack(self);
  RELEASE(self->rootObject);
  CGrowFreeInside((id)self->stack);
  MSFree(self->stack, "CJSONDecoderFinish");
}

static void CJSONDecoderError(CJSONDecoder *self, const char *err, ...)
{ // assert !self->error
  va_list vp;
  CJSONDecoderCleanStack(self);
  CJSONDecoderCleanToken(self);

  self->error= CCreateString(0);
  va_start(vp, err);
  CStringAppendFormatv(self->error, err, vp);
  va_end(vp);
}

static void CJSONDecoderPush(CJSONDecoder *self, id retainedObj, MSByte popChar)
{
  CJSONDecoderStack *s;
  CGrowGrow((id)self->stack, 1);
  s= (CJSONDecoderStack *)self->stack->zone;
  s+= self->stack->count++;
  s->obj= retainedObj;
  s->key= nil;
  s->popChar= popChar;
  self->head= s;
}

static void CJSONDecoderPop(CJSONDecoder *self)
{
  id obj= self->head->obj;
  self->token.type= ST_VAL_END;
  self->head--;
  --self->stack->count;
  CJSONDecoderHandleReturn(self, obj);
  RELEASE(obj);
}

static void CJSONDecoderCleanStack(CJSONDecoder *self)
{
  while(self->stack->count > 0) {
    CJSONDecoderStack *s;
    s= (CJSONDecoderStack *)self->stack->zone;
    s+= --self->stack->count;
    RELEASE(s->obj);
    RELEASE(s->key);}
}

static void CJSONDecoderCleanToken(CJSONDecoder *self)
{
  switch (self->token.type) {
    case ST_STR:
      DESTROY(self->token.v.str.s);
      break;
    case ST_NUM:
      DESTROY(self->token.v.d);
      break;
    default:
      break;
  }
}

static void CJSONDecoderExpect(CJSONDecoder *self, CJSONDecoderState state, MSByte currentChar)
{
  if (state == ST_VAL) return;

  CJSONDecoderCleanToken(self);
  self->token.type= state;
  switch(state) {
    case ST_ERR:
      if (self->head && self->head->popChar == currentChar) {
        CJSONDecoderPop(self);
      }
      else {
        CJSONDecoderError(self, "invalid character code %d", (int)currentChar);
      }
      break;

    case ST_POP:
      self->token.type= ST_ERR;
      switch(currentChar) {
        case '}': if (self->head && self->head->popChar != ']') { CJSONDecoderPop(self); } break;
        case ']': if (self->head && self->head->popChar == ']') { CJSONDecoderPop(self); } break;
        default: break;
      }
      if (self->token.type == ST_ERR)
        CJSONDecoderError(self, "invalid character code %d", (int)currentChar);
      break;

    case ST_YES:
      self->token.v.ret= MSTrue;
      break;

    case ST_NO:
      self->token.v.ret= MSFalse;
      break;

    case ST_NIL:
      self->token.v.ret= MSNull;
      break;

    case ST_NUM:
      self->token.v.d= CCreateBuffer(0);
      CBufferAppendByte(self->token.v.d, currentChar);
      break;

    case ST_STR:
      self->token.v.str.s= CCreateString(0);
      break;

    case ST_ARR:
      CJSONDecoderPush(self, (id)CCreateArray(0), ']');
      self->token.type= ST_VAL;
      break;

    case ST_DIC:
      CJSONDecoderPush(self, (id)CCreateDictionary(0), ':');
      self->token.type= ST_DIC_KEY;
     break;

    default:
      CJSONDecoderError(self, "invalid state %d, this is a bug in CJSONDecoderExpect", (int)state);
      break;
  }
}

static inline BOOL _hexaCharValue(MSByte *c)
{
  if ('0' <= *c && *c <= '9') *c= *c - '0';
  else if ('a' <= *c && *c <= 'f') *c= 10 + *c - 'a';
  else if ('A' <= *c && *c <= 'F') *c= 10 + *c - 'A';
  else return NO;
  return YES;
}
static inline void CJSONDecoderAssertChar(CJSONDecoder *self, MSByte c, MSByte e, CJSONDecoderState next)
{
  if (c == e)
    self->token.type= next;
  else
    CJSONDecoderError(self, "%c was expected", e);
}
static inline void CJSONDecoderAssertCharEnd(CJSONDecoder *self, MSByte c, MSByte e)
{
  if (c == e) {
    self->token.type= ST_VAL_END;
    CJSONDecoderHandleReturn(self, self->token.v.ret);
  }
  else
    CJSONDecoderError(self, "%c was expected", e);
}
static inline BOOL _isSpace(MSByte c)
{
  return c == ' ' || c == '\n' || c == '\r' || c == '\t';
}
static void CJSONDecoderIsEndOfToken(CJSONDecoder *self, MSByte c, const char *expected)
{
  if (c == ',' || (self->head && c == self->head->popChar)) {
    self->token.type = ST_VAL;
    CJSONDecoderHandleReturn(self, [MSDecimal decimalWithUTF8String:(const char *)CBufferCString(self->token.v.d)]);
    CJSONDecoderTokenEnd(self, c);
  }
  else if (!_isSpace(c)) {
    CJSONDecoderError(self, "%send of token was expected", expected);
  }
}
static inline BOOL _isDecimalEnd(CJSONDecoderState state)
{
  return state == ST_NUM || state == ST_NUM_2 || state == ST_NUM_E;
}
static id CJSONDecoderParseResult(CJSONDecoder *self, NSString **error)
{
  id ret= nil;
  if (!self->error && _isDecimalEnd(self->token.type)) {
    CJSONDecoderHandleReturn(self, [MSDecimal decimalWithUTF8String:(const char *)CBufferCString(self->token.v.d)]); }
  if (!self->error && self->token.type != ST_END) {
    CJSONDecoderError(self, "JSON string is incomplete");}
  if (!self->error) {
    ret= self->rootObject;}
  else if(error) {
    *error= (id)self->error;}
  return ret;
}

static void CJSONDecoderParseBytes(CJSONDecoder *self, const MSByte *bytes, NSUInteger length)
{
  const MSByte *pc= bytes, *pe= pc + length;
  MSByte c;
  // NSLog(@"CJSONDecoderParseBytes(%p, %.*s, %d)", self, (int)length, bytes, (int)length);
  while (!self->error && pc < pe) {
    c= *(pc++);
    // NSLog(@"CJSONDecoderParseBytes '%c' '%c' %s", c, self->head ? self->head->popChar : '?', _tokenTypeNames[self->token.type + 1]);
    switch(self->token.type) {
      case ST_VAL:
        if (c > 127)
          CJSONDecoderExpect(self, ST_ERR, c);
        else
          CJSONDecoderExpect(self, _valueCharToState[c], c);
        break;
      case ST_END:
        if (!_isSpace(c)) {
          CJSONDecoderError(self, "only spaces are possible after root object");}
        break;
      case ST_VAL_END:
        if (c == ',' || (self->head && c == self->head->popChar)) {
          self->token.type= ST_VAL;
          CJSONDecoderTokenEnd(self, c); }
        else if (!_isSpace(c)) {
          CJSONDecoderError(self, "end of token was expected");}
        break;

      case ST_DIC_KEY:
        if (c== '"') {
          CJSONDecoderExpect(self, ST_STR, c);}
        else if (c== '}') {
          CJSONDecoderPop(self);}
        else if (!_isSpace(c)) {
          CJSONDecoderError(self, "\" or SP or LF or CR was expected");}
        break;

      case ST_NIL   : CJSONDecoderAssertChar(self, c, 'u', ST_NIL_L1); break;
      case ST_NIL_L1: CJSONDecoderAssertChar(self, c, 'l', ST_NIL_L2); break;
      case ST_NIL_L2: CJSONDecoderAssertCharEnd(self, c, 'l');break;

      case ST_YES  : CJSONDecoderAssertChar(self, c, 'r', ST_YES_U); break;
      case ST_YES_U: CJSONDecoderAssertChar(self, c, 'u', ST_YES_E); break;
      case ST_YES_E: CJSONDecoderAssertCharEnd(self, c, 'e');   break;

      case ST_NO  : CJSONDecoderAssertChar(self, c, 'a', ST_NO_L); break;
      case ST_NO_L: CJSONDecoderAssertChar(self, c, 'l', ST_NO_S); break;
      case ST_NO_S: CJSONDecoderAssertChar(self, c, 's', ST_NO_E); break;
      case ST_NO_E: CJSONDecoderAssertCharEnd(self, c, 'e'); break;

      case ST_STR:
        if (c == '\\') self->token.type= ST_STR_ESCAPE;
        else if (c == '"') { self->token.type= ST_VAL_END; CJSONDecoderHandleReturn(self, (id)self->token.v.str.s); }
        else if (c < 0x7F) { CStringAppendCharacter(self->token.v.str.s, (unichar)c); }
        else if (0xC2 <= c && c <= 0xDF) { self->token.type= ST_STR_UTF8_1; self->token.v.str.bytes[0]= c; self->token.v.str.idx=1;}
        else if (0xE0 <= c && c <= 0xEF) { self->token.type= ST_STR_UTF8_2; self->token.v.str.bytes[0]= c; self->token.v.str.idx=1;}
        else if (0xF0 <= c && c <= 0xF4) { self->token.type= ST_STR_UTF8_3; self->token.v.str.bytes[0]= c; self->token.v.str.idx=1;}
        else CJSONDecoderError(self, "invalid string character %c", c);
        break;
      case ST_STR_UTF8_1:
        self->token.v.str.bytes[self->token.v.str.idx++]= c;
        CStringAppendBytes(self->token.v.str.s, NSUTF8StringEncoding, (const void *)self->token.v.str.bytes, (NSUInteger)self->token.v.str.idx);
        self->token.type= ST_STR;
        break;
      case ST_STR_UTF8_2:
        self->token.v.str.bytes[self->token.v.str.idx++]= c;
        self->token.type= ST_STR_UTF8_1;
        break;
      case ST_STR_UTF8_3:
        self->token.v.str.bytes[self->token.v.str.idx++]= c;
        self->token.type= ST_STR_UTF8_2;
        break;
      case ST_STR_ESCAPE:
        switch(c) {
          case '"': CStringAppendCharacter(self->token.v.str.s, (unichar)'"' ); self->token.type= ST_STR; break;
          case '\\':CStringAppendCharacter(self->token.v.str.s, (unichar)'\\'); self->token.type= ST_STR; break;
          case '/': CStringAppendCharacter(self->token.v.str.s, (unichar)'/');  self->token.type= ST_STR; break;
          case 'b': CStringAppendCharacter(self->token.v.str.s, (unichar)'\b'); self->token.type= ST_STR; break;
          case 'f': CStringAppendCharacter(self->token.v.str.s, (unichar)'\f'); self->token.type= ST_STR; break;
          case 'n': CStringAppendCharacter(self->token.v.str.s, (unichar)'\n'); self->token.type= ST_STR; break;
          case 'r': CStringAppendCharacter(self->token.v.str.s, (unichar)'\r'); self->token.type= ST_STR; break;
          case 't': CStringAppendCharacter(self->token.v.str.s, (unichar)'\t'); self->token.type= ST_STR; break;
          case 'u': self->token.v.str.u= 0; self->token.v.str.idx= 0; self->token.type= ST_STR_UNICODE; break;
          default: CJSONDecoderError(self, "escaped character %c not valid", c); break;
        }
        break;
      case ST_STR_UNICODE:
        if (_hexaCharValue(&c)) {
          self->token.v.str.u = (self->token.v.str.u << 4) + (unichar)c;
          if (++self->token.v.str.idx == 4) {
            CStringAppendCharacter(self->token.v.str.s, self->token.v.str.u);
            self->token.type= ST_STR;}}
        else CJSONDecoderError(self, "a hexadecimal character was expected");
        break;

      case ST_NUM:
        if ('0' <= c && c <= '9') {
          CBufferAppendByte(self->token.v.d, c);}
        else if(c == '.') {
          CBufferAppendByte(self->token.v.d, c); self->token.type= ST_NUM_2;}
        else if (c == 'e' || c == 'E') {
          CBufferAppendByte(self->token.v.d, c); self->token.type= ST_NUM_E;}
        else {
          CJSONDecoderIsEndOfToken(self, c, "0-9 or . or e or E or ");}
        break;
      case ST_NUM_2:
        if ('0' <= c && c <= '9') {
          CBufferAppendByte(self->token.v.d, c);}
        else if (c == 'e' || c == 'E') {
          CBufferAppendByte(self->token.v.d, c); self->token.type= ST_NUM_E_START;}
        else {
          CJSONDecoderIsEndOfToken(self, c, "0-9 or e or E or ");}
        break;
      case ST_NUM_E_START:
        if (('0' <= c && c <= '9') || c == '+' || c == '-') {
          CBufferAppendByte(self->token.v.d, c); self->token.type=ST_NUM_E;}
        else { CJSONDecoderError(self, "0-9 or + or - or ");}
        break;
      case ST_NUM_E:
        if ('0' <= c && c <= '9') {
          CBufferAppendByte(self->token.v.d, c);}
        else {
          CJSONDecoderIsEndOfToken(self, c, "0-9 or ");}
        break;

      default:
        CJSONDecoderError(self, "invalid token type %lld, this is a bug in CJSONDecoderParseBytes", (MSLong)self->token.type);
        break;
    }
  }
  // NSLog(@"CJSONDecoderParseBytes end position: %d", (int)(pc - bytes));
}

static void CJSONDecoderTokenEnd(CJSONDecoder* self, MSByte reason)
{
  // NSLog(@"CJSONDecoderTokenEnd: %c %c", (char)reason, (char)(self->head ? self->head->popChar : ' '));
  if(self->head) {
    switch(self->head->popChar)
    {
      case ':':
        if (reason == ':')
          self->head->popChar= '}';
        else {
          CJSONDecoderError(self, "unexpected token end char ',' (':' was expected)");}
        break;

      case '}':
        if (reason == ',') {
          self->head->popChar= ':';
          self->token.type= ST_DIC_KEY;}
        else
          CJSONDecoderPop(self);
        break;

      case ']':
        if (reason == ']')
          CJSONDecoderPop(self);
        break;

      default:
        CJSONDecoderError(self, "unexpected popChar %c in CJSONDecoderHandleReturn, this is a decoder bug", (int)self->head->popChar);
        break;
    }
  }
}
static void CJSONDecoderHandleReturn(CJSONDecoder* self, id ret)
{
  if(self->stack->count == 0) {
    self->rootObject= RETAIN(ret);
    CJSONDecoderCleanToken(self);
    self->token.type= ST_END;}
  else {
    switch(self->head->popChar)
    {
      case ':':
        self->head->key= RETAIN(ret);
        break;

      case '}':
        CDictionarySetObjectForKey((CDictionary*)self->head->obj, ret, self->head->key);
        DESTROY(self->head->key);
        break;

      case ']':
        CArrayAddObject((CArray*)self->head->obj, ret);
        break;

      default:
        CJSONDecoderError(self, "unexpected popChar %c in CJSONDecoderHandleReturn, this is a decoder bug", (int)self->head->popChar);
        break;
    }
  }
}

@implementation MSJSONDecoder
- (instancetype)init
{
  if ((self= [super init])) {
    CJSONDecoderInit((CJSONDecoder*)self);}
  return self;
}
- (void)dealloc
{
  CJSONDecoderFinish((CJSONDecoder*)self);
  [super dealloc];
}
- (void)parseBytes:(const void *)bytes length:(NSUInteger)length
{
  CJSONDecoderParseBytes((CJSONDecoder*)self, (MSByte*)bytes, length);
}
- (id)parseResult:(NSString **)error
{
  return CJSONDecoderParseResult((CJSONDecoder*)self, error);
}
@end

@implementation NSData (JSONDecoding)

- (id)JSONDecodedObject:(NSString **)error
{
  MSJSONDecoder *decoder; id ret;
  if (error) *error= nil;
  decoder= [MSJSONDecoder new];
  [decoder parseBytes:[self bytes] length:[self length]];
  ret= [[[decoder parseResult:error] retain] autorelease];
  if (error) [[*error retain] autorelease];
  RELEASE(decoder);
  return ret;
}
@end
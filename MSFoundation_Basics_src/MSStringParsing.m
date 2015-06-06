/*
 
 MSStringParsing.m
 
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

#pragma mark Parse context

enum {
  STATE_END = 1,
  STATE_ERR = -1
};

typedef struct _ParseContext
{
  SES ses;
  MSUInt flags;
  NSUInteger pos, col, line;
  NSUInteger nextWordCharCounter;
  BOOL nextIsCurrent;
  NSDictionary *classMap;
  unichar c;
  id error;
} ParseContext;

typedef struct _ParseContextPos
{
  NSUInteger pos, col, line;
  unichar c;
} ParseContextPos;


static inline unichar ParseContextNextTmp(ParseContext *context)
{
  NSUInteger pos = context->pos;
  return context->pos < SESEnd(context->ses) ? SESIndexN(context->ses, &pos) : 0;
}

static inline BOOL ParseContextNext(ParseContext *context)
{
  BOOL ret;
  if (context->nextIsCurrent) {
    context->nextIsCurrent= NO;
    ret= YES;}
  else {
    ret= context->pos < SESEnd(context->ses);
    if (ret) {
      context->c= SESIndexN(context->ses, &context->pos);
      if (context->c == '\n') {
        context->line++;
        context->col= 1;}
      else {
        context->col++;}}}
  return ret;
}

static inline void ParseContextNextIsCurrent(ParseContext *context)
{
  context->nextIsCurrent= 1;
}

static inline ParseContextPos ParseContextStorePosition(ParseContext *context)
{
  ParseContextPos pos;
  pos.pos= context->pos;
  pos.col= context->col;
  pos.line= context->line;
  pos.c= context->c;
  return pos;
}
static inline void ParseContextRestorePosition(ParseContext *context, ParseContextPos pos)
{
  context->pos= pos.pos;
  context->col= pos.col;
  context->line= pos.line;
  context->c= pos.c;
}

static BOOL ParseContextNextWord(ParseContext *context)
{
  BOOL ret= NO, next= YES;
  
  context->nextWordCharCounter= 0;
  while (next && (ret= ParseContextNext(context))) {
    context->nextWordCharCounter++;
    if (context->c == (unichar)'/') {
      ParseContextPos ppos= ParseContextStorePosition(context);
      if (!ParseContextNext(context)) ret= YES;
      else if (context->c == (unichar)'/') { // Single Line Comment
        while ((ret= ParseContextNext(context)) && !CUnicharIsEOL(context->c));
      }
      else if (context->c == (unichar)'*') { // Multiline comment
        BOOL canClose= NO;
        while ((ret= ParseContextNext(context)) && !(canClose && context->c == (unichar)'/')) {
          if (context->c == (unichar)'*')
            canClose= YES;}
      }
      else {
        ParseContextRestorePosition(context, ppos);
        next= NO;
      }
    }
    else if (!CUnicharIsSpaceOrEOL(context->c)) {
      next= NO;
    }
  }
  
  return ret;
}

static void ParseContextError(ParseContext *context, NSString* object, NSString *expect)
{
  if (!context->error)
    context->error= FMT(@"Error while parsing %s, %s was expected at %lld:%lld", [object UTF8String], [expect UTF8String], (MSLong)context->line, (MSLong)context->col);
}

#pragma mark Common

static id parsePList(NSString *str, MSUInt flags, NSString **error);
static MSLong parseInt64(ParseContext *context, int *state);
static unichar parseUnichar(ParseContext *context, int *state);

static BOOL parseObject(ParseContext *context, id *obj, BOOL isRoot);
static BOOL parseString(ParseContext *context, id *obj, BOOL keyUsage);
static BOOL parseQuotedString(ParseContext *context, id *obj);
static BOOL parseSimpleString(ParseContext *context, id *obj);
static BOOL parseDictionary(ParseContext *context, id *obj);
static BOOL parseArray(ParseContext *context, id *obj);
static BOOL parseData(ParseContext *context, id *obj);
static BOOL parseNaturals(ParseContext *context, id *obj);
static BOOL parseUserClass(ParseContext *context, id *obj);
static BOOL parseCouple(ParseContext *context, id *obj);

static MSLong parseInt64(ParseContext *context, int *state) {
  MSLong v= 0; BOOL neg= NO;
  
  if(!*state && ((neg= context->c == (unichar)'-') || context->c == (unichar)'+')) {
    if (!ParseContextNext(context)) *state= STATE_ERR;}
  while (!*state && CUnicharIsIsoDigit(context->c)) {
    v = v * 10 + (char)context->c - '0';
    if (!ParseContextNext(context)) *state= STATE_ERR;}
  
  return neg ? -v : v;
}

id SESParsePList(SES ses, MSUInt flags, NSString **error)
{
  id ret= nil;
  ParseContext context;
  memset(&context, 0, sizeof(context));
  context.line= 1;
  context.col= 1;
  context.ses= ses;
  context.flags= flags > 0 ? flags & MSPPLParseAll : MSPPLParseAll;
  if (SESOK(context.ses)) {
    if (!ParseContextNextWord(&context)) ParseContextError(&context, @"Object", @"Something");
    else {
      parseObject(&context, &ret, YES);
      if (ParseContextNextWord(&context)) {
        DESTROY(ret);
        ParseContextError(&context, @"Object", @"Nothing");
      }
    }
    if (context.error && error)
      *error= context.error;
  }
  return AUTORELEASE(ret);
}

static id parsePList(NSString *str, MSUInt flags, NSString **error)
{
  return SESParsePList(SESFromString(str), flags, error);
}

static inline BOOL parseObjectIfAllowed(ParseContext *context, id *obj, BOOL isRoot, BOOL (*parseMethod)(ParseContext*, id*), MSUInt rootFlags, NSString* desc)
{
  BOOL ret= NO;
  if (isRoot && !(context->flags & rootFlags))
    ParseContextError(context, @"Object", FMT(@"Root must be a %@", desc));
  else
    ret= parseMethod(context, obj);
  return ret;
}

static BOOL parseObject(ParseContext *context, id *obj, BOOL isRoot)
{
  BOOL ret;
  switch (context->c) {
    case (unichar)'{': ret= parseObjectIfAllowed(context, obj, isRoot, parseDictionary, MSPPLParseDict,     @"dictionary"   ); break;
    case (unichar)'(': ret= parseObjectIfAllowed(context, obj, isRoot, parseArray,      MSPPLParseArray,    @"array"        ); break;
    case (unichar)'<': ret= parseObjectIfAllowed(context, obj, isRoot, parseData,       MSPPLParseData,     @"data"         ); break;
    case (unichar)'[': ret= parseObjectIfAllowed(context, obj, isRoot, parseNaturals,   MSPPLParseNaturals, @"natural array"); break;
    case (unichar)'@': ret= (ParseContextNextTmp(context) == (unichar)'(')
                          ? parseObjectIfAllowed(context, obj, isRoot, parseCouple,     MSPPLParseNaturals, @"couple")
                          : parseObjectIfAllowed(context, obj, isRoot, parseUserClass,  MSPPLParseNaturals, @"user class"); break;
    default: ret= !isRoot && parseString(context, obj, NO); break;
  }
  return ret;
}

#pragma mark Dictionary

static BOOL parseDictionary(ParseContext *context, id *obj)
{
  CDictionary *ret; id key=nil, val=nil, expect=nil; int state = 0;
  
  ret= CCreateDictionary(0);
  while ((expect= @"key or '}'") && !state && ParseContextNextWord(context)) {
    if (context->c == (unichar)'}')        state= STATE_END;
    else if (!parseString(context, &key, YES)) state= STATE_ERR;
    
    if (!state) {
      expect= @"'='";
      if (!ParseContextNextWord(context) || context->c != (unichar)'=') state= STATE_ERR;}
    
    if (!state) {
      expect= @"object";
      if (!ParseContextNextWord(context) || !parseObject(context, &val, NO)) state= STATE_ERR;
      else {
        CDictionarySetObjectForKey(ret, val, key);
        DESTROY(key);
        RELEASE(val);}}
    
    if (!state) {
      expect= @"';'";
      if (!ParseContextNextWord(context) || context->c != (unichar)';') state= STATE_ERR;}
  }
  
  if (state != STATE_END) {
    ParseContextError(context, @"Dictionary", expect);
    DESTROY(key);
    DESTROY(ret);}
  *obj= (id)ret;
  return state == STATE_END;
}

#pragma mark Array

static BOOL parseArray(ParseContext *context, id *obj)
{
  CArray* ret; id val= nil, expect=nil; int state= 0;
  
  ret= CCreateArray(0);
  while ((expect= @"object or ')'") && !state && ParseContextNextWord(context)) {
    if (context->c == (unichar)')') state= STATE_END;
    else if (!parseObject(context, &val, NO)) state= STATE_ERR;
    
    if (!state) {
      CArrayAddObject(ret, val);
      RELEASE(val);
      
      expect= @"',' or ')'";
      if (!ParseContextNextWord(context))  state= STATE_ERR;
      else if (context->c == (unichar)')') state= STATE_END;
      else if (context->c != (unichar)',') state= STATE_ERR;}
  }
  
  if (state != STATE_END) {
    ParseContextError(context, @"Array", expect);
    DESTROY(ret);}
  *obj= (id)ret;
  return state == STATE_END;
}

#pragma mark Data

static BOOL parseData(ParseContext *context, id *obj)
{
  MSByte byte = '\0', b1 = '\0'; BOOL first= YES; int state= 0;
  CBuffer *ret= CCreateBuffer(0);
  while (!state && ParseContextNext(context)) {
    if (context->c == '>') state= first ? STATE_END : STATE_ERR;
    else if (!CUnicharIsSpaceOrEOL(context->c)) {
      if ('a' <= context->c && context->c <= 'f')
        byte = (MSByte)(context->c - (unichar)'a') + 10;
      else if ('A' <= context->c && context->c <= 'F')
        byte = (MSByte)(context->c - (unichar)'A') + 10;
      else if ('0' <= context->c && context->c <= '9')
        byte = (MSByte)(context->c - (unichar)'0');
      else state= STATE_ERR;
      
      if(!state) {
        if (first) b1= byte;
        else CBufferAppendByte(ret, (MSByte)(b1 << 4) + byte);
        first= !first;}
    }
  }
  
  if (state != STATE_END) {
    ParseContextError(context, @"Data", @"[A-Fa-f0-9]+");
    DESTROY(ret);}
  *obj= (id)ret;
  return state == STATE_END;
}

#pragma mark String

static BOOL parseString(ParseContext *context, id *obj, BOOL keyUsage)
{
  id ret; BOOL ok;
  
  ok= (context->c == (unichar)'"') ? parseQuotedString(context, &ret) : parseSimpleString(context, &ret);
  if (!keyUsage && (context->flags & MSPPLDecodeNull)  &&
     (MSInsensitiveEqualStrings(ret, @"*NULL*") ||
      MSInsensitiveEqualStrings(ret, @"NULL") ||
      MSInsensitiveEqualStrings(ret, @"NIL") ||
      MSInsensitiveEqualStrings(ret, @"*NIL*")))
  { RELEASE(ret); ret= nil; }
  else if (!keyUsage && (context->flags & MSPPLDecodeBoolean)  &&
     (MSInsensitiveEqualStrings(ret, @"Y") ||
      MSInsensitiveEqualStrings(ret, @"YES") ||
      MSInsensitiveEqualStrings(ret, @"TRUE")))
  { RELEASE(ret); ret= MSTrue; }
  else if (!keyUsage && (context->flags & MSPPLDecodeBoolean)  &&
     (MSInsensitiveEqualStrings(ret, @"N") ||
      MSInsensitiveEqualStrings(ret, @"NO") ||
      MSInsensitiveEqualStrings(ret, @"FALSE")))
  { RELEASE(ret); ret= MSFalse; }
  else if ((context->flags & (MSPPLDecodeUnsigned | MSPPLDecodeInteger))) {
    int state= 0;
    MSLong v= parseInt64(context, &state);
    if(v >= 0 || (context->flags & MSPPLDecodeInteger)) {
      RELEASE(ret);
      ret= [ALLOC(NSNumber) initWithLongLong:v];}
  }
  /*else if (!keyUsage && (context->flags & MSPPLDecodeOthers)) {
    id v= context->analyseFn(ret, context->flags, context->analyseContext);
    ASSIGN(ret, v);
  }*/
  *obj= ret;
  return ok;
}

static unichar parseUnichar(ParseContext *context, int *state)
{
  unichar c= 0; MSUInt pos= 0;
  while (pos < 4 && ParseContextNext(context) && CUnicharIsIsoDigit(context->c)) {
    c += ((context->c - (unichar)'0') << (pos * 4));
    ++pos;
  }
  if (pos != 4) {
    *state= STATE_ERR;}
  return c;
}

static BOOL parseQuotedString(ParseContext *context, id *obj)
{
  int state= 0; unichar c; CString *ret; id expect;
  
  ret= CCreateString(0);
  while ((expect = @"[^\"]+") && !state && ParseContextNext(context)) {
    if (context->c == (unichar)'\\') {
      expect = @"\\t, \\n, \\r, \\U[0-9]{4}, \\\"";
      if (!ParseContextNext(context)) state= STATE_ERR;
      else {
        c= context->c;
        switch (c) {
          case 't': context->c= '\t'; break;
          case 'n': context->c= '\n'; break;
          case 'r': context->c= '\r'; break;
          case '"': context->c= '"';  break;
          case 'U':
          case 'u': context->c = parseUnichar(context, &state); break;
          default:  break;
        }}
    }
    else if (context->c == '"') state= STATE_END;
    
    if (!state)
      CStringAppendCharacter(ret, context->c);
  }
  
  if (state != STATE_END) {
    ParseContextError(context, @"String", expect);
    DESTROY(ret);}
  *obj= (id)ret;
  return state == STATE_END;
}

typedef BOOL (*parsechar_t)(unichar c);
static BOOL parseSimpleStringCharNoExt(unichar c)
{
  return CUnicharIsLetter(c) || CUnicharIsIsoDigit(c) || c == (unichar)'_';
}
static BOOL parseSimpleStringCharExt(unichar c)
{
  return !strchr("(){}[]@',;=/\r\n", (int)c) && !CUnicharIsSpace(c) && !CUnicharIsEOL(c);
}
static BOOL parseSimpleString(ParseContext *context, id *obj)
{
  parsechar_t parseChar; int state= 0; CString *ret;
  
  ret= CCreateString(0);
  parseChar = (context->flags & MSPPLStrictMode) == 0 ? parseSimpleStringCharExt : parseSimpleStringCharNoExt;
  while (!state && parseChar(context->c)) {
    CStringAppendCharacter(ret, context->c);
    if (!ParseContextNext(context)) state= STATE_END;}
  ParseContextNextIsCurrent(context);
  if (!CStringLength(ret))
    DESTROY(ret);
  *obj= (id)ret;
  return ret != nil;
}

#pragma mark User class

static BOOL parseUserClass(ParseContext *context, id *obj)
{
  int state= 0; CString *cls; id ret= nil, arg= nil;
  
  cls = CCreateString(0);
  while (!state && ParseContextNextWord(context)) {
    if (context->nextWordCharCounter == 1 && (CUnicharIsLetter(context->c) || CUnicharIsIsoDigit(context->c) || context->c == (unichar)'_')) {
      CStringAppendCharacter(cls, context->c); }
    else if (!CStringLength(cls))
      state= STATE_ERR;
    else if (context->c == (unichar)'(')
      state= parseArray(context, &arg) ? STATE_END : STATE_ERR;
    else if (context->c == (unichar)'{')
      state= parseDictionary(context, &arg) ? STATE_END : STATE_ERR;
    else
      state= STATE_ERR;
  }
  
  if (state == STATE_END) {
    id userClsName; Class userCls;
    
    userClsName = [context->classMap objectForKey:(id)cls];
    if(!userClsName) userClsName= (id)cls;
    userCls= NSClassFromString(userClsName);
    ret= [ALLOC(userCls) initWithPPLParsedObject:arg] ;}
  else if (state != STATE_END) {
    ParseContextError(context, @"UserClass", @"classname");}
  
  RELEASE(arg);
  RELEASE(cls);
  *obj= ret;
  return state == STATE_END;
}

#pragma mark Couple

static BOOL parseCouple(ParseContext *context, id *obj)
{
  CCouple *ret; int state= 0; id firstMember= nil, secondMember= nil, expect = nil;
  
  if (!state && (expect = @"'('"   ) && (!ParseContextNext(context)     || context->c != (unichar)'('))
    state= STATE_ERR;
  if (!state && (expect = @"object") && (!ParseContextNextWord(context) || !parseObject(context, &firstMember, NO)))
    state= STATE_ERR;
  if (!state && (expect = @"','"   ) && (!ParseContextNextWord(context) || context->c != (unichar)','))
    state= STATE_ERR;
  if (!state && (expect = @"object") && (!ParseContextNextWord(context) || !parseObject(context, &secondMember, NO)))
    state= STATE_ERR;
  if (!state && (expect = @"')'"   ) && (!ParseContextNextWord(context) || context->c != (unichar)')'))
    state= STATE_ERR;
  
  if (!state) {
    ret= CCreateCouple(firstMember, secondMember);}
  else {
    ParseContextError(context, @"Couple", expect);}
  RELEASE(firstMember);
  RELEASE(secondMember);
  *obj= (id)ret;
  return !state;
}

#pragma mark Naturals

static BOOL parseNaturals(ParseContext *context, id *obj)
{
  MSMutableNaturalArray *ret; id expect=nil; int state= 0; MSLong natural;
  
  ret= [MSMutableNaturalArray new];
  while ((expect= @"natural or ']'") && !state && ParseContextNextWord(context)) {
    if (context->c == (unichar)']') state= STATE_END;
    else {
      natural= parseInt64(context, &state);
      if (!state && (natural < 0 || natural > NSUIntegerMax)) {
        state= STATE_ERR;}
      if (!state) {
        [ret addNatural:natural];}
      
      expect= (@"',' or ']'");
      if (!ParseContextNextWord(context))  state= STATE_ERR;
      else if (context->c == (unichar)']') state= STATE_END;
      else if (context->c != (unichar)',') state= STATE_ERR;
    }
  }
  
  if (state != STATE_END) {
    ParseContextError(context, @"NaturalArray", expect);
    DESTROY(ret);}
  *obj= ret;
  return state == STATE_END;
}


static id parsePListLogError(NSString *str, MSUInt flags)
{
  id ret, error=nil;
  ret= parsePList(str, flags, &error);
  if (error)
    NSLog(@"%@", error);
  return ret;
}
@implementation NSString (MSPPPLParsing)

- (NSMutableDictionary *)dictionaryValue
{ return parsePListLogError(self, MSPPLParseDict); }

- (NSMutableArray *)arrayValue
{ return parsePListLogError(self, MSPPLParseArray); }

- (NSMutableDictionary *)stringsDictionaryValue
{ return parsePListLogError(self, MSPPLParseDict); }

- (NSMutableArray *)stringsArrayValue
{ return parsePListLogError(self, MSPPLParseArray); }

@end


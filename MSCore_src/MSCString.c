/* MSCString.c
 
 This file is is a part of the MicroStep Framework.
 
 Copyright Herve MALAINGRE & Eric BARADAT (1996)
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

#include "MSCore_Private.h"

#pragma mark c-like class methods

void CStringFreeInside(id self)
{
  if (self) {
    CString *s= (CString*)self;
    MSFree(s->buf, "CStringFree() [memory]");
    s->length= 0; s->buf= NULL;}
}

BOOL CStringIsEqual(id self, id other)
{
  return _CClassIsEqual(self,other,(CObjectEq)CStringEquals);
}

NSUInteger CStringHash(id self, unsigned depth)
{
  return SESHash(CStringSES((const CString *)self));
}

id CStringInitCopyWithMutability(CString *self, const CString *copied, BOOL isMutable)
{
  if (!self) return nil;
  if (copied) {
    CStringAppendString(self, copied);}
  if (!isMutable) CGrowSetForeverImmutable((id)self);
  return (id)self;
}

id CStringCopy(id self)
{
  CString *s;
  if (!self) return nil;
  s= (CString*)MSCreateObjectWithClassIndex(CStringClassIndex);
  return CStringInitCopyWithMutability(s, (CString*)self, !CGrowIsForeverImmutable(self));
}

const CString* CStringRetainedDescription(id self)
{
  return (const CString*)RETAIN(self);
}

#pragma mark Equality

BOOL CStringEquals(const CString *s1, const CString *s2)
{
  if (s1 == s2) return YES;
  if (s1 && s2) {
    NSUInteger l1= s1->length;
    return l1 == s2->length && !memcmp(s1->buf, s2->buf, l1*sizeof(unichar)) ? YES : NO;}
  return NO;
}

BOOL CStringInsensitiveEquals(const CString *s1, const CString *s2)
{
  if (s1 == s2) return YES;
  if (s1 && s2) {
    return CUnicharsInsensitiveEquals(s1->buf, s1->length, s2->buf, s2->length);}
  return NO;
}

#pragma mark Creation

CString *CCreateString(NSUInteger capacity)
{
  CString *s= (CString*)MSCreateObjectWithClassIndex(CStringClassIndex);
  if (s && capacity) CStringGrow(s, capacity);
  return s;
}

CString *CCreateStringWithBytes(NSStringEncoding encoding, const void *s, NSUInteger length)
{
  CString *x= (CString*)MSCreateObjectWithClassIndex(CStringClassIndex);
  CStringAppendBytes(x, encoding, s, length);
  return x;
}

CString *CCreateStringWithSES(SES ses)
{
  CString *x= (CString*)MSCreateObjectWithClassIndex(CStringClassIndex);
  CStringAppendSES(x, ses);
  return x;
}

CString *CCreateStringWithGeneratedUUID()
{
  char uuid[37]; CString *x;
  uuid_generate_string(uuid);
  x= CCreateStringWithBytes(NSASCIIStringEncoding, uuid, 36);
  CGrowSetForeverImmutable((id)x);
  return x;
}

#pragma mark Management

void CStringGrow(CString *self, NSUInteger n)
{
  CGrowGrow((id)self,n);
}

void CStringAdjustSize(CString *self)
{
  CGrowAdjustSize((id)self);
}

NSUInteger CStringLength(const CString *self)
{
  return (self ? self->length : 0);
}
unichar CStringCharacterAtIndex(const CString *self, NSUInteger i)
{
  if (!self || i >= self->length) return (unichar)0;
  return self->buf[i];
}

NSUInteger CStringIndexOfCharacter(const CString *self, unichar c)
{
  if (self) {
    NSUInteger i, l= self->length;
    for (i= 0; i < l; i++) if (self->buf[i] == c) return i;}
  return NSNotFound;
}

SES CStringSES(const CString *self)
{
  return !self ? MSInvalidSES : MSMakeSESWithBytes(self->buf, self->length, NSUnicodeStringEncoding);
}

#pragma mark Append

void CStringAppendCharacter(CString *self, unichar c)
{
  if (self) {
    if (self->size < self->length+1) CStringGrow(self, 1);
    self->buf[self->length++]= c;}
}

void CStringAppendCharacterSuite(CString *self, unichar c, NSUInteger nb)
{
  if (self && nb) {
    register NSUInteger i;
    if (self->size < self->length+nb) CStringGrow(self, nb);
    for (i= 0; i < nb; i++) self->buf[self->length++]= c;}
}

void CStringAppendBytes(CString *self, NSStringEncoding encoding, const void *s, NSUInteger length)
{
  CStringAppendSES(self, MSMakeSESWithBytes(s, length, encoding));
}

void CStringAppendSES(CString *self, SES ses)
{
  if (self && SESOK(ses)) {
    NSUInteger i, end, lg= SESLength(ses);
    if (self->size < self->length+lg) CStringGrow(self, lg);
    if (ses.encoding==NSUnicodeStringEncoding) {
      memmove(self->buf+self->length, SESSource(ses)+SESStart(ses), lg*sizeof(unichar));
      self->length+= SESLength(ses);}
    else for (i= SESStart(ses), end= SESEnd(ses); i < end;) {
      unichar u= SESIndexN(ses, &i);
      self->buf[self->length++]= (u?u:'?');
      }}
}

void CStringAppendString(CString *self, const CString *s)
{
  CStringAppendSES(self, CStringSES(s));
}

void CStringAppendFormat(CString *self, const char *fmt, ...)
{
  va_list vp;
  va_start(vp, fmt);
  CStringAppendFormatv(self, fmt, vp);
  va_end(vp);
}

#pragma mark Append format
#define FORMAT_MAX2(A, B)            (A > B ? A : B)
#define FORMAT_MAX3(A, B, C)         FORMAT_MAX2(FORMAT_MAX2(A, B), C)

static const int argsOnStack= 128; // 128 arg is far enough to hold pending formatting arguments
#ifndef WO451
_Static_assert(sizeof(size_t) <= sizeof(intmax_t), "size_t must fit in intmax");
_Static_assert(sizeof(ptrdiff_t) <= sizeof(uintmax_t), "ptrdiff_t must fit in uintmax");
_Static_assert(sizeof(void*) <= sizeof(uintmax_t), "void* must fit in uintmax");
#endif
// TODO: Implement a fallback to heap allocation if format should support more extreme cases (> 127 out of order arg, ie. "%128$d $1$d")

typedef enum {
  FormatTypeUndefined= 0,
  FormatTypeS4,
  FormatTypeU4,
  FormatTypeSL,
  FormatTypeUL,
  FormatTypeS8,
  FormatTypeU8,
  FormatTypeSM,
  FormatTypeUM,
  FormatTypeST,
  FormatTypeUD,
  FormatTypePTR,
  FormatTypeDBL,
  FormatTypeLDBL
} FormatType;

typedef struct {
  FormatType type;
  union {
    intmax_t im;
    uintmax_t um;
    double dbl;
    long double ldbl;
    void *ptr;
  } u;
} FormatArg;

enum FormatFlags {
  FormatFlagThousandGrouping = 0x01, // '
  FormatFlagLeftJustify      = 0x02, // -
  FormatFlagSigned           = 0x04, // +
  FormatFlagSpace            = 0x08, //' ' && !FormatFlagSigned
  FormatFlagAlternativeForm  = 0x10, // #
  FormatFlagLeadingZeros     = 0x20, // 0  && !FormatFlagLeftJustify && !precision
  FormatFlagHasWidth         = 0x40,
  FormatFlagHasPrecision     = 0x80,
};

const MSByte __nextArg = MSByteMax;

typedef struct {
  MSUShort width;
  MSUShort precision;
  FormatType type;
  MSByte arg;
  MSByte widthArg;
  MSByte precisionArg;
  MSByte specifier;
  struct {
    MSByte thousandGroup : 1;   // '
    MSByte leftJustify : 1;     // -
    MSByte plus : 1;            // +
    MSByte space : 1;           //' '
    MSByte alternativeForm : 1; // #
    MSByte leadingZeros : 1;    // 0
    MSByte hasWidth : 1;
    MSByte hasPrecision : 1;
  } flags;
} FormatToken;


#define NEXT_CHAR c= ((u= SESIndexN(ses, pos)) > 127 ? 0 : (char)u)
#define TRY_NEXT_CHAR ({ hasMore= *pos < SESLength(ses); if (hasMore) NEXT_CHAR; hasMore; })

static inline FormatToken _formatParse(SES ses, NSUInteger *pos)
{
  FormatToken f; unichar u; char c;
  BOOL hasMore = YES;
  memset(&f, 0, sizeof(f));
  NEXT_CHAR;
  
  // %
  if (c == '%') {
    f.specifier= c;
    return f;
  }
  
  // Position OR Width OR 0 Flag
  if (hasMore && '0' == c) {
    f.flags.leadingZeros= 1;
    TRY_NEXT_CHAR;}
  while(hasMore && f.arg == 0) {
    if ('0' <= c && c <= '9') {
      f.flags.hasWidth= 1;
      f.width= f.width * 10 + (c - '0'); }
    else if ('$' == c) {
      f.flags.hasWidth= 0;
      f.arg= f.width;
      f.width= 0;}
    else break;
    TRY_NEXT_CHAR;}
  
  // Flags
  if (f.width == 0) {
    while(hasMore) {
      BOOL next=NO;
      switch (c) {
        case '\'': f.flags.thousandGroup= 1;    break;
        case '-' : f.flags.leftJustify= 1;      break;
        case '+' : f.flags.plus= 1;             break;
        case ' ' : f.flags.space= 1;            break;
        case '#' : f.flags.alternativeForm= 1;  break;
        case '0' : f.flags.leadingZeros= 1;     break;
        default: next= YES; break;
      }
      if (next) break;
      TRY_NEXT_CHAR;
    }
    // Width
    while(hasMore) {
      if ('0' <= c && c <= '9') {
        f.flags.hasWidth= 1;
        f.width= f.width * 10 + (c - '0'); }
      else if ('*' == c) {
        f.flags.hasWidth= 1;
        f.widthArg= __nextArg; }
      else if ('$' == c) {
        f.widthArg=f.width;
        f.width= 0;}
      else break;
      TRY_NEXT_CHAR;
    }
  }
  
  // Precision
  if (hasMore && '.' == c) {
    while(TRY_NEXT_CHAR) {
      if ('0' <= c && c <= '9') {
        f.flags.hasPrecision= 1;
        f.precision= f.precision * 10 + (c - '0'); }
      else if ('*' == c) {
        f.flags.hasPrecision= 1;
        f.precisionArg= __nextArg; }
      else if ('$' == c) {
        f.precisionArg= f.precision;
        f.precision= 0;}
      else break;
    }
  }
  
  // Length
  while(hasMore) {
    BOOL next=NO;
    switch (c) {
      case 'h': f.type= FormatTypeS4; break;
      case 'l': f.type= f.type == FormatTypeSL ? FormatTypeS8 : FormatTypeSL;  break;
      case 'q': f.type= FormatTypeS8; break;
      case 'j': f.type= FormatTypeSM; break;
      case 'z': f.type= FormatTypeST; break;
      case 't': f.type= FormatTypeUD; break;
      case 'L': f.type= FormatTypeLDBL; break;
      default:               next= YES; break;
    }
    if (next) break;
    TRY_NEXT_CHAR;
  }
  
  // Specifier
  if (hasMore) {
    switch(c) {
      case 'd': case 'i':
        if (!f.type)
          f.type= FormatTypeS4;
        f.specifier= 'd';
        break;
      case 'o': case 'u':
      case 'x': case 'X':
        f.type= (f.type > 0 ? f.type + (f.type < FormatTypeUM ? 1 : 0) : FormatTypeU4);
        f.specifier= c;
        break;
      case 'f': case 'F':
      case 'e': case 'E':
      case 'g': case 'G':
      case 'a': case 'A':
        if (f.type != FormatTypeLDBL)
          f.type= FormatTypeDBL;
        f.specifier= c;
        break;
      case 'c':
        f.type= FormatTypeS4;
        f.specifier= c;
        break;
      case '@': case 'n': case 's': case 'p':
        f.type= FormatTypePTR;
        f.specifier= c;
        break;
      default:
        break;
    }
  }
  
  return f;
}

static inline void _formatPrintSES(CString *s, SES ses, NSUInteger len, NSUInteger width, MSUInt leftJustify)
{
  if (!leftJustify && width > len) {
    CStringAppendCharacterSuite(s, ' ', width - len); }
  CStringAppendSES(s, ses);
  if (leftJustify && width > len) {
    CStringAppendCharacterSuite(s, ' ', width - len); }
}

static inline void _formatPrintUTF8(CString *s, const char *cstr, NSUInteger len, NSUInteger width, MSByte flags)
{
  _formatPrintSES(s, MSMakeSESWithBytes(cstr, len, NSUTF8StringEncoding), len, width, flags);
}

static
#ifndef WO451 // WO451 is failing inlining this method (SIGSEGV)
inline
#endif
void _formatPrintInteger(CString *s, FormatToken f, BOOL neg, uintmax_t v, uintmax_t radix, int precision, int width, const char *chars)
{
  if (f.flags.leadingZeros && !f.flags.hasPrecision) {
      precision= (f.specifier == 'd' && (neg || f.flags.plus || f.flags.space)) ? width - 1 : width;}
  
  // Buffer on stack block
  {
    char *pos, *end, buffer[1 + MAX(precision, 22)]; // 22 = ceil(log8(2^64))
    
    end= buffer + sizeof(buffer);
    pos= end - 1;
    do {
      *(pos--)= chars[v % radix];
      v /= radix;}
    while (v > 0);
    
    while(precision >= end - pos) {
      *(pos--)= '0';}
    
    if (f.flags.alternativeForm) {
      if (f.specifier== 'o') {
        *pos--= '0';}
      else if (f.specifier== 'x' || f.specifier== 'X') {
        *pos--= chars[16];
        *pos--= '0';}}
    else if (f.specifier == 'p') {
      *pos--= 'x';
      *pos--= '0';}
    else if(f.specifier == 'd') {
      if (neg) {
        *pos--= '-';}
      else if (f.flags.plus) {
        *pos--= '+';}
      else if (f.flags.space) {
        *pos--= ' ';}}
    
    _formatPrintUTF8(s, pos + 1, end - pos - 1, width, f.flags.leftJustify);
  }
}

static void _formatPrintArg(CString *s, FormatToken f, FormatArg *argTypes)
{
  static const char* charsL="0123456789abcdefx";
  static const char* charsU="0123456789ABCDEFX";
  int width=     f.widthArg     ? (int)argTypes[f.widthArg - 1].u.im : f.width;
  int precision= f.precisionArg ? (int)argTypes[f.precisionArg - 1].u.im : f.precision;
  switch(f.specifier) {
    case 'd':
    {
      intmax_t value; uintmax_t v;
      value= argTypes[f.arg - 1].u.im;
      v= value > 0 ? value : -value;
      _formatPrintInteger(s, f, value < 0, v, 10, precision, width, charsL);
      break;
    }
    case 'p':
    {
      uintmax_t v;
      v= (uintptr_t)(intptr_t)argTypes[f.arg - 1].u.ptr;
      _formatPrintInteger(s, f, NO, v, 16, precision, width, charsL);
      break;
    }
    case 'u': case 'o':
    case 'x': case 'X':{
      uintmax_t v, radix; const char *chars;
      v= argTypes[f.arg - 1].u.um;
      chars= f.specifier == 'X' ? charsU : charsL;
      radix= f.specifier == 'u' ? 10LL : (f.specifier == 'o' ? 8LL : 16LL);
      _formatPrintInteger(s, f, NO, v, radix, precision, width, chars);
      break;
    }
    case 'f': case 'F':
    case 'e': case 'E':
    case 'g': case 'G':
    case 'a': case 'A': {
      // TODO: Implement it ? insteed of relying on snprinf.
      // We have to be very carefull about precision handling.
      // Requires a lot of tests.
      char fmt[/*%*/1 + /*flags*/5 + /*width*/20 + /*precision*/21 + /*length*/1 + /*specifier*/1 + /*'\0'*/1];
      char *fmtPos= fmt, *fmtEnd= fmt + sizeof(fmt);
      *(fmtPos++)= '%';
      if (f.flags.leftJustify)     { *(fmtPos++)= '-'; }
      if (f.flags.plus)            { *(fmtPos++)= '+'; }
      if (f.flags.space)           { *(fmtPos++)= ' '; }
      if (f.flags.alternativeForm) { *(fmtPos++)= '#'; }
      if (f.flags.leadingZeros)    { *(fmtPos++)= '0'; }
      if (f.flags.hasWidth) {
        fmtPos+= snprintf(fmtPos, fmtEnd - fmtPos, "%d", (int)width); }
      if (f.flags.hasPrecision) {
        fmtPos+= snprintf(fmtPos, fmtEnd - fmtPos, ".%d", (int)precision); }
      if (f.type == FormatTypeLDBL){ *(fmtPos++)= 'L'; }
      *(fmtPos++)= f.specifier;
      *(fmtPos++)= 0;
      // TODO: Performance test the overhead of the rare usage of long double against double (x87 FPU vs SSE)
      // to see if it's really needed to distinct both in the code;
      // several benchmark shows a 50% overhead, which is quite a lot
      if (f.type == FormatTypeLDBL)
      {
        long double value= argTypes[f.arg - 1].u.ldbl;
        int n= snprintf(NULL, 0, fmt, value);
        char buffer[n + 1];
        snprintf(buffer, n + 1, fmt, value);
        _formatPrintUTF8(s, buffer, n, width, f.flags.leftJustify);
      }
      else
      {
        double value= argTypes[f.arg - 1].u.dbl;
        int n= snprintf(NULL, 0, fmt, value);
        char buffer[n + 1];
        snprintf(buffer, n + 1, fmt, value);
        _formatPrintUTF8(s, buffer, n, width, f.flags.leftJustify);
      }
      break;
    }
    case 'c':
    {
      unichar str[1];
      *str = (unichar)argTypes[f.arg - 1].u.im;
      _formatPrintSES(s, MSMakeSESWithBytes(str, 1, NSUnicodeStringEncoding), 1, width, f.flags.leftJustify);
      break;
    }
    case 's':
    {
      char *cstr= (char*)argTypes[f.arg - 1].u.ptr;
      _formatPrintUTF8(s, cstr, strlen(cstr), width, f.flags.leftJustify);
      break;
    }
    case '@':
    {
      id obj= (id)argTypes[f.arg - 1].u.ptr;
      const CString *str= DESCRIPTION(obj);
      if (str) {
        _formatPrintSES(s, CStringSES(str), CStringLength(str), width, f.flags.leftJustify); }
      else {
        _formatPrintUTF8(s, "nil", 3, width, f.flags.leftJustify); }
      RELEASE(str);
      break;
    }
  }
}

#define LOAD_ARG(argtype, var) argType->u.var= (__typeof__(argType->u.var))va_arg(ap, argtype)

void CStringAppendFormatv(CString *self, const char *cfmt, va_list ap)
{
  SES fmt= MSMakeSESWithBytes(cfmt, strlen(cfmt), NSUTF8StringEncoding);
  if (!SESOK(fmt)) return;
  else {
    // arg informations/values
    FormatArg argTypes[argsOnStack];
    FormatArg *argType;
    NSUInteger argLoadIdx= 0, argParseIdx= 0;
    NSUInteger pos=0, positionalPassPos= 0, startPos;
    BOOL positionalFormating= NO, firstPass= YES;
    // tmp
    FormatToken f; unichar u;
    memset(argTypes, 0, sizeof(argTypes));
    while(1) {
      while (pos < SESLength(fmt)) {
        startPos= pos;
        u= SESIndexN(fmt, &pos);
        if (u == (unichar)'%' && pos < SESLength(fmt)) {
          f= _formatParse(fmt, &pos);
          if (f.specifier == '%') {
            if (!positionalPassPos) CStringAppendCharacter((CString*)self, '%'); }
          else if (f.specifier > 0) {
            if (firstPass && !positionalFormating && f.arg > 0) {
              positionalFormating= YES;
              positionalPassPos= startPos;}
            if (!positionalFormating) {
              if (f.widthArg == __nextArg) {
                f.widthArg= ++argParseIdx;}
              if (f.precisionArg == __nextArg) {
                f.precisionArg= ++argParseIdx;}
              f.arg= ++argParseIdx;}
            if (f.widthArg) {
              argTypes[f.widthArg - 1].type= FormatTypeS4; }
            if (f.precisionArg) {
              argTypes[f.precisionArg - 1].type= FormatTypeS4; }
            argTypes[f.arg - 1].type= f.type;
            while((argType= argTypes + argLoadIdx)->type) {
              // Can't be move to a sub method due arch handling of va_arg
              switch(argType->type) {
                case FormatTypeUndefined: abort();
                case FormatTypeS4:   LOAD_ARG(signed int, im); break;
                case FormatTypeU4:   LOAD_ARG(unsigned int, um); break;
                case FormatTypeSL:   LOAD_ARG(signed long, im); break;
                case FormatTypeUL:   LOAD_ARG(unsigned long, um); break;
                case FormatTypeS8:   LOAD_ARG(signed long long, im); break;
                case FormatTypeU8:   LOAD_ARG(unsigned long long, um); break;
                case FormatTypeSM:   LOAD_ARG(intmax_t, im); break;
                case FormatTypeUM:   LOAD_ARG(uintmax_t, um); break;
                case FormatTypeST:   LOAD_ARG(size_t, im); break;
                case FormatTypeUD:   LOAD_ARG(ptrdiff_t, um); break;
                case FormatTypePTR:  LOAD_ARG(void*, ptr); break;
                case FormatTypeDBL:  LOAD_ARG(double, dbl); break;
                case FormatTypeLDBL: LOAD_ARG(long double, ldbl); break;
              }
              argLoadIdx++;}
            if (!positionalPassPos) {
              _formatPrintArg(self, f, argTypes);}
          }
        }
        else if (!positionalPassPos) {
          CStringAppendCharacter(self, u);}}
      if (positionalPassPos) {
        pos= positionalPassPos;
        positionalPassPos= 0;
        firstPass= NO;}
      else break;
    }
  }
}

static inline unichar _CEncodingToUnicode(MSByte c, NSStringEncoding encoding)
// TODO: use SES
{
  SES ses= MSMakeSESWithBytes(&c, 1, encoding);
  NSUInteger index= 0;
  return SESIndexN(ses, &index);
}

static inline NSUInteger _addNonASCIIByte(CString *self,
                                          NSUInteger initialLen,
                                          MSByte c, NSUInteger pos,
                                          NSUInteger len,
                                          NSStringEncoding worseEncoding,
                                          BOOL tryISOLatinAfterUTF8,
                                          unichar *up,
                                          NSUInteger *sequenceLen,
                                          NSUInteger *sequenceIndex,
                                          NSStringEncoding *encoding)
{
  switch (*encoding) {
    case NSNEXTSTEPStringEncoding:
    case NSSymbolStringEncoding:
    case NSWindowsCP1251StringEncoding:
    case NSWindowsCP1252StringEncoding:
    case NSWindowsCP1253StringEncoding:
    case NSWindowsCP1254StringEncoding:
    case NSWindowsCP1250StringEncoding:
    case NSMacOSRomanStringEncoding:
    case NSDOSStringEncoding:
      self->buf[self->length++]= _CEncodingToUnicode(c, *encoding);
      pos ++;
      break;
    case NSUTF8StringEncoding:{
      if (*sequenceLen == 0) {
        // we initialize a new UTF8 sequence
        unsigned slen = 0;
        *up = (unichar)c;
        while (c & 0x80) {
          c = (MSByte)(c << 1);
          slen ++;
        }
        if (slen < 2 || slen > 6 || pos+slen > len) {
          // it's not an UTF8 sequence
          self->length = initialLen; // we go back to initial buffer state
          *encoding = (!tryISOLatinAfterUTF8 || *up < 0xa0 ? worseEncoding : NSISOLatin1StringEncoding);
          *sequenceLen = 0;
          *sequenceIndex = 0;
          *up = 0;
          pos = 0;
        }
        else {
          *sequenceLen = slen;
          *sequenceIndex = 1;
          pos ++;
        }
      }
      else if (c <= 0XBF) {
        unsigned int u = *up;
        u = (u << 6) | (c & 0x3f);
        *sequenceIndex = *sequenceIndex + 1;
        if (*sequenceIndex == *sequenceLen) {
          u = u & ~(0xffffffff << ((5 * (*sequenceLen)) + 1));
          *sequenceLen = 0;
          *sequenceIndex = 0;
          *up = 0;
          if (((u >= 0xd800) && (u <= 0xdfff)) || (u > 0x10ffff)) {
            self->length = initialLen; // we go back to initial buffer state
            *encoding = (!tryISOLatinAfterUTF8 || c < 0xa0 ? worseEncoding : NSISOLatin1StringEncoding);
            pos = 0;
          }
          else if (u < 0x10000) {
            // a complete unicode character
            self->buf[self->length++] = (unichar)u;
            pos ++;
          }
          else {
            // we need to add two chars
            unichar ul, uh;
            u -= 0x10000;
            ul = u & 0x3ff;
            uh = (u >> 10) & 0x3ff;
            self->buf[self->length++] = uh + 0xd800; // first character added
            self->buf[self->length++] = ul + 0xdc00; // second
            pos ++;
          }
        }
        else {
          *up = (unichar)u;
          pos ++;
        }
      }
      else {
        // NO UTF8 here
        self->length = initialLen; // we go back to initial buffer state
        *encoding = worseEncoding;
        *sequenceLen = 0;
        *sequenceIndex = 0;
        *up = 0;
        pos = 0;
      }
      break;
    }
    case NSISOLatin1StringEncoding:{
      if (c < 0xa0) {
        // NO ISO LATIN HERE
        self->length = initialLen; // we go back to initial buffer state
        *encoding = worseEncoding;
        *sequenceLen = 0;
        *sequenceIndex = 0;
        *up = 0;
        pos = 0;
      }
      else {
        self->buf[self->length++] = (unichar)c; // ISO LATIN = UNICODE FIRST PAGE
        pos ++;
      }
      break;
    }
    case NSISOLatin2StringEncoding:{
      if (c < 0xa0) {
        // NO ISO LATIN HERE
        self->length = initialLen; // we go back to initial buffer state
        *encoding = worseEncoding;
        *sequenceLen = 0;
        *sequenceIndex = 0;
        *up = 0;
        pos = 0;
      }
      else {
        self->buf[self->length++]= _CEncodingToUnicode(c, NSISOLatin2StringEncoding);
        pos ++;
      }
      break;
    }
      
    case NSASCIIStringEncoding:
    default:
      // if ASCII, back to worse immediatly
      // if not, well, that should not be...
      self->length = initialLen; // we go back to initial buffer state
      *encoding = worseEncoding;
      *sequenceLen = 0;
      *sequenceIndex = 0;
      *up = 0;
      pos =  NSNotFound;
      break;
  }
  return pos;
}

static inline NSUInteger _insertSES(unichar *buf, SES ses) {
  NSUInteger i, end, count= 0;
  for (i= SESStart(ses), end= SESEnd(ses); i < end;) {
    unichar u= SESIndexN(ses, &i);
    *(buf++)= (u?u:'?');
    count++;}
  return count;
}
MSCoreExtern void CStringReplaceInRangeWithSES(CString *self, NSRange range, SES ses)
{
  if (range.location + range.length > self->length) {
    MSReportError(MSInvalidArgumentError, MSFatalError, MSInvalidArgumentError,
                  "range (%lu, %lu) out of range (0, %lu)",
                  (unsigned long)range.location, (unsigned long)range.length,
                  (unsigned long)self->length);}
  else {
    NSUInteger len, rangeEnd, inserted;
    rangeEnd= range.location + range.length;
    len= SESLength(ses);
    if (len > range.length) {
      NSUInteger maxAddLen= len - range.length;
      NSUInteger bufferLen= MIN(maxAddLen, self->length - rangeEnd);
      unichar buffer[bufferLen];
      memcpy(buffer, self->buf + rangeEnd, bufferLen * sizeof(unichar));
      CStringGrow(self, maxAddLen);
      inserted= _insertSES(self->buf + range.location, ses);
      if (inserted != range.length){
        NSUInteger insertEnd= range.location + inserted;
        memmove(self->buf + insertEnd + bufferLen, self->buf + rangeEnd + bufferLen, self->length - rangeEnd - bufferLen);
        memcpy(self->buf + insertEnd, buffer, bufferLen);}
    }
    else {
      inserted= _insertSES(self->buf + range.location, ses);
      if (inserted != range.length){
        memmove(self->buf + range.location + inserted, self->buf + rangeEnd, self->length - rangeEnd);}
    }
    self->length += inserted;
    self->length -= range.length;}
}

/*
static void _CStringAppendUTF8Bytes(CString *self, const void *bytes, NSUInteger len)
{
  if (self && bytes && len) {
    MSByte c, *s = (MSByte *)bytes;
    unichar uc = 0;
    NSUInteger i = 0, initialLen = self->length;
    NSUInteger sequenceLen = 0, sequenceIndex = 0;
    NSStringEncoding encoding = NSUTF8StringEncoding;

    if (self->length + len > self->size) CStringGrow(self, len); // we (hope) know that the length(utf8) <= length(unicode equivalent)
    while (i < len) {
      c = s[i];
      if (c > 0x7f) {
        i = _addNonASCIIByte(self, initialLen, c, i, len, NSASCIIStringEncoding, NO, &uc, &sequenceLen, &sequenceIndex, &encoding);
        if (encoding != NSUTF8StringEncoding) {
          return;}}
      else {
        self->buf[self->length++] = (unichar)c;
        i++;}}
    if (sequenceLen > 0) {
      self->length = initialLen; // we go back to initial buffer state
      return;}}
}
*/
#define NO_CONVERSION    0x0000
#define CONV_URI_MODE    0x0001

#define NORMAL_STATE    0
#define ESCAPE_START_STATE  1
#define ESCAPE_END_STATE  2

#define _XISHEXA(C)  (((C) >= '0' && (C) <= '9') || ((C) >= 'A' && (C) <= 'F') || ((C) >= 'a' && (C) <= 'f'))
#define _XHEXAVAL(C) ((C) >= 'a' ? (C) - 'a' + 10 : ((C) >= 'A' ? (C) - 'A' + 10 : (C) - '0'))

static BOOL _CUBAppendUnknownEncodingBytes(CString *self, const void *bytes, NSUInteger len, MSUShort cmode, NSStringEncoding encoding, BOOL tryIsoLatin, NSStringEncoding *foundEncodingPointer)
{
  if (self && bytes && len) {
    MSByte c, escaped = 0, *s = (MSByte *)bytes;
    unsigned state = NORMAL_STATE;
    unichar uc = 0;
    NSUInteger i = 0, initialLen = self->length;
    NSUInteger sequenceLen = 0, sequenceIndex = 0;
    NSStringEncoding worse = MSCurrentCStringEncoding();
    
    if (encoding != NSUTF8StringEncoding &&
        encoding != NSWindowsCP1252StringEncoding &&
        encoding != NSISOLatin1StringEncoding &&
        encoding != NSMacOSRomanStringEncoding &&
        encoding != NSNEXTSTEPStringEncoding &&
        encoding != NSASCIIStringEncoding) { return NO; }
    
    if (encoding == worse ||
        worse == NSShiftJISStringEncoding ||
        worse == NSISO2022JPStringEncoding ||
        worse == NSNonLossyASCIIStringEncoding ||
        worse == NSJapaneseEUCStringEncoding ||
        worse == NSSymbolStringEncoding ||
        worse == NSISOLatin2StringEncoding ||
        worse == NSWindowsCP1251StringEncoding ||
        worse == NSWindowsCP1253StringEncoding ||
        worse == NSWindowsCP1254StringEncoding ||
        worse == NSWindowsCP1250StringEncoding ||
        worse > NSMacOSRomanStringEncoding) {
      worse = NSUnicodeStringEncoding;
    }
    
    if (self->length + len > self->size) CStringGrow(self, len); // we (hope) know that the length(8byte encoding) <= length(unicode equivalent)
    
  restart:
    if (cmode == NO_CONVERSION) {
      while (i < len) {
        c = s[i];
        if (c > 0x7f) {
          i = _addNonASCIIByte(self, initialLen, c, i, len, worse, tryIsoLatin, &uc, &sequenceLen, &sequenceIndex, &encoding);
          if (encoding == NSUnicodeStringEncoding) return NO;
        }
        else {
          self->buf[self->length++] = (unichar)c;
          i++;
        }
      }
    }
    else {
      while (i < len) {
        c = s[i];
        switch (state) {
          case NORMAL_STATE:{
            if (c == '%' && (cmode & CONV_URI_MODE)) {
              state = ESCAPE_START_STATE;
              i ++;
            }
            else if (c > 0x7f) {
              i = _addNonASCIIByte(self, initialLen, c, i, len, worse, tryIsoLatin, &uc, &sequenceLen, &sequenceIndex, &encoding);
              if (encoding == NSUnicodeStringEncoding) return NO;
            }
            else if (cmode & CONV_URI_MODE) {
              self->buf[self->length++] = (unichar)(c == '+' ? ' ' : c);
              i ++;
            }
            else {
              self->buf[self->length++] = (unichar)c;
              i++;
            }
            break;
          }
          case ESCAPE_START_STATE:{
            if (!_XISHEXA(c)) { self->length = initialLen; return NO; }
            escaped = (MSByte)(_XHEXAVAL(c) << 4);
            state = ESCAPE_END_STATE;
            i ++;
            break;
          }
          case ESCAPE_END_STATE:{
            if (!_XISHEXA(c)) { self->length = initialLen; return NO; }
            escaped |= _XHEXAVAL(c);
            if (escaped < 0x80) {
              self->buf[self->length++] = escaped;
              i ++;
            }
            else {
              i = _addNonASCIIByte(self, initialLen, escaped, i, len, worse, tryIsoLatin, &uc, &sequenceLen, &sequenceIndex, &encoding);
              if (encoding == NSUnicodeStringEncoding) return NO;
            }
            state = NORMAL_STATE;
            break;
          }
        }
      }
    }
    
    if (sequenceLen > 0 && encoding != NSUnicodeStringEncoding) {
      self->length = initialLen;
      encoding = NSISOLatin1StringEncoding;
      i = 0;
      sequenceLen = 0;
      sequenceIndex = 0;
      uc = 0;
      goto restart;
    }
    if (state != NORMAL_STATE) { self->length = initialLen; return NO; }
    
  }
  if (foundEncodingPointer) *foundEncodingPointer = encoding;
  
  return YES;
}

BOOL CStringAppendInternetBytes(CString *self, const void *bytes, NSUInteger len, NSStringEncoding encoding, NSStringEncoding *foundEncodingPointer)
{ return _CUBAppendUnknownEncodingBytes(self, bytes, len, NO_CONVERSION, encoding, YES, foundEncodingPointer); }

BOOL CStringAppendSupposedEncodingBytes(CString *self, const void *bytes, NSUInteger len, NSStringEncoding encoding, NSStringEncoding *foundEncodingPointer)
{ return _CUBAppendUnknownEncodingBytes(self, bytes, len, NO_CONVERSION, encoding, NO, foundEncodingPointer); }

BOOL CStringAppendURLBytes(CString *self, const void *bytes, NSUInteger len, NSStringEncoding encoding, NSStringEncoding *foundEncodingPointer)
{ return _CUBAppendUnknownEncodingBytes(self, bytes, len, CONV_URI_MODE, encoding, NO, foundEncodingPointer); }

typedef BOOL (*_CUBNumberAppender)(CString *self, MSLong n);

#warning Re-enable MAPM
static BOOL _snd(CString *self, MSLong n)
{
  BOOL ret= NO;
  n= 0; // TODO: n is UNUSED, Re-enable MAPM
  self= nil;
  /*
   // a very slow method, I know, but I don't wand to use sprintf() or snprintf() with "%lld" since the result in quite uncertain
   char buf[128];
   M_APM bignum = m_apm_new();
   m_apm_to_integer_string(buf, bignum);
   ret = CStringAppendISOLatin1CString(self, buf);
   m_apm_free(bignum);
   */
  return ret;
}

static char *__french100[100] = {
  "", "un", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf",
  "dix", "onze", "douze", "treize", "quatorze", "quinze", "seize", "dix-sept", "dix-huit", "dix-neuf",
  "vingt", "vingt et un", "vingt-deux", "vingt-trois", "vingt-quatre", "vingt-cinq", "vingt-six", "vingt-sept", "vingt-huit", "vingt-neuf",
  "trente", "trente et un", "trente-deux", "trente-trois", "trente-quatre", "trente-cinq", "trente-six", "trente-sept", "trente-huit", "trente-neuf",
  "quarante", "quarante et un", "quarante-deux", "quarante-trois", "quarante-quatre", "quarante-cinq", "quarante-six", "quarante-sept", "quarante-huit", "quarante-neuf",
  "cinquante", "cinquante et un", "cinquante-deux", "cinquante-trois", "cinquante-quatre", "cinquante-cinq", "cinquante-six", "cinquante-sept", "cinquante-huit", "cinquante-neuf",
  "soixante", "soixante et un", "soixante-deux", "soixante-trois", "soixante-quatre", "soixante-cinq", "soixante-six", "soixante-sept", "soixante-huit", "soixante-neuf",
  "soixante-dix", "soixante et onze", "soixante-douze", "soixante-treize", "soixante-quatorze", "soixante-quinze", "soixante-seize", "soixante-dix-sept", "soixante-dix-huit", "soixante-dix-neuf",
  "quatre-vingts", "quatre-vingt-un", "quatre-vingt-deux", "quatre-vingt-trois", "quatre-vingt-quatre", "quatre-vingt-cinq", "quatre-vingt-six", "quatre-vingt-sept", "quatre-vingt-huit", "quatre-vingt-neuf",
  "quatre-vingt-dix", "quatre-vingt-onze", "quatre-vingt-douze", "quatre-vingt-treize", "quatre-vingt-quatorze", "quatre-vingt-quinze", "quatre-vingt-seize", "quatre-vingt-dix-sept", "quatre-vingt-dix-huit", "quatre-vingt-dix-neuf"
};

static inline BOOL _frenchNumber999(CString *self, NSUInteger originalLength, unsigned number, BOOL invariable)
{
  unsigned centaines= number / 100;
  unsigned reste= number % 100;
  char *s;
  if (centaines > 0) {
    if (centaines > 1) {
      s= __french100[centaines];
      CStringAppendBytes(self, NSISOLatin1StringEncoding, s, strlen(s));
      s= (reste > 0 ? " cent " : (invariable ? " cent" : " cents"));
      CStringAppendBytes(self, NSISOLatin1StringEncoding, s, strlen(s));}
    else {
      s= (reste > 0 ? "cent " : "cent");
      CStringAppendBytes(self, NSISOLatin1StringEncoding, s, strlen(s));}}
  if (reste) {
    s= __french100[reste];
    CStringAppendBytes(self, NSISOLatin1StringEncoding, s, strlen(s));}
  return YES;
  MSUnused(originalLength);
}

static BOOL CStringAppendFrenchNumber(CString *self, MSLong n)
{
  MSULong number = (MSULong)ABS(n);
  MSULong milliers, millions, milliards = number / 1000000000;
  NSUInteger originalLength = self->length;
  BOOL needsSpace = (originalLength == 0 || CUnicharIsSpace(self->buf[originalLength-1]) ? NO : YES);
  char *s;
  
  if (n == 0) {
    if (needsSpace) CStringAppendCharacter(self, 0x0020);
    CStringAppendCharacter(self, 0x007a); /* oh yeah, that's z&eacute;ro in french */
    CStringAppendCharacter(self, 0x00e9);
    CStringAppendCharacter(self, 0x0072);
    CStringAppendCharacter(self, 0x006f);
    return YES;}
  if (number > 999999999999ULL) {
    return _snd(self, n);}

  if (n < 0) {
    if (needsSpace) CStringAppendCharacter(self, 0x0020);
    s= "moins";
    CStringAppendBytes(self, NSISOLatin1StringEncoding, s, strlen(s));
    needsSpace= YES;}
  if (milliards) {
    number-= milliards * 1000000000;
    if (needsSpace) CStringAppendCharacter(self, 0x0020);
    if (!_frenchNumber999(self, originalLength, (unsigned)milliards, NO)) {  return NO; }
    s= (milliards > 1 ? " milliards" : " milliard");
    CStringAppendBytes(self, NSISOLatin1StringEncoding, s, strlen(s));
    needsSpace = YES;}
  millions = number / 1000000;
  if (millions) {
    number -= millions * 1000000;
    if (needsSpace) CStringAppendCharacter(self, 0x0020);
    if (!_frenchNumber999(self, originalLength, (unsigned)millions, NO)) {  return NO; }
    s= (millions > 1 ? " millions" : " millions");
    CStringAppendBytes(self, NSISOLatin1StringEncoding, s, strlen(s));
    needsSpace = YES;}
  milliers = number / 1000;
  if (milliers) {
    number -= milliers * 1000;
    if (milliers == 1 && number < 700) {
      number += 1000; // on le fait sous la forme treize-cents...
    }
    else {
      if (needsSpace) CStringAppendCharacter(self, 0x0020);
      if (milliers > 1 && !_frenchNumber999(self, originalLength, (unsigned)milliers, YES)) {  return NO; }
      s= " mille";
      CStringAppendBytes(self, NSISOLatin1StringEncoding, s, strlen(s));
      needsSpace = YES;}}
  if (number) {
    if (needsSpace) CStringAppendCharacter(self, 0x0020);
    if (!_frenchNumber999(self, originalLength, (unsigned)number, NO)) {  return NO; }}
  return YES;
}

static char *__english100[100] = {
  "", "one", "two", "three", "four", "five", "six", "seven", "height", "nine",
  "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "heighteen", "nineteen",
  "twenty", "twenty-one", "twenty-two", "twenty-three", "twenty-four", "twenty-five", "twenty-six", "twenty-seven", "twenty-height", "twenty-nine",
  "thirty", "thirty-one", "thirty-two", "thirty-three", "thirty-four", "thirty-five", "thirty-six", "thirty-seven", "thirty-height", "thirty-nine",
  "fourty", "fourty-one", "fourty-two", "fourty-three", "fourty-four", "fourty-five", "fourty-six", "fourty-seven", "fourty-height", "fourty-nine",
  "fifty", "fifty-one", "fifty-two", "fifty-three", "fifty-four", "fifty-five", "fifty-six", "fifty-seven", "fifty-height", "fifty-nine",
  "sixty", "sixty-one", "sixty-two", "sixty-three", "sixty-four", "sixty-five", "sixty-six", "sixty-seven", "sixty-height", "sixty-nine",
  "seventy", "seventy-one", "seventy-two", "seventy-three", "seventy-four", "seventy-five", "seventy-six", "seventy-seven", "seventy-height", "seventy-nine",
  "heighty", "heighty-one", "heighty-two", "heighty-three", "heighty-four", "heighty-five", "heighty-six", "heighty-seven", "heighty-height", "heighty-nine"
  "ninety", "ninety-one", "ninety-two", "ninety-three", "ninety-four", "ninety-five", "ninety-six", "ninety-seven", "ninety-height", "ninety-nine"
};

static inline BOOL _englishNumber999(CString *self, NSUInteger originalLength, unsigned number)
{
  unsigned centaines = number / 100;
  unsigned reste = number % 100;
  char *s;
  if (centaines > 0) {
    s= __english100[centaines];
    CStringAppendBytes(self, NSISOLatin1StringEncoding, s, strlen(s));
    s= (reste > 0 ? "hundred and " : "hundred");
    CStringAppendBytes(self, NSISOLatin1StringEncoding, s, strlen(s));}
  if (reste) {
    s= __english100[reste];
    CStringAppendBytes(self, NSISOLatin1StringEncoding, s, strlen(s));}
  return YES;
  MSUnused(originalLength); // Unused
}

static BOOL CStringAppendEnglishNumber(CString *self, MSLong n)
{
  MSULong number = (MSULong)ABS(n);
  MSULong initialNumber = number;
  MSULong milliers, millions, milliards = number / 1000000000;
  NSUInteger originalLength = self->length;
  BOOL needsSpace = (originalLength == 0 || CUnicharIsSpace(self->buf[originalLength-1]) ? NO : YES);
  char *s;
  if (n == 0) {
    if (needsSpace) CStringAppendCharacter(self, 0x0020);
    s= "zero";
    CStringAppendBytes(self, NSISOLatin1StringEncoding, s, strlen(s));
    return YES;}
  if (number > 999999999999ULL) {
    return _snd(self, n);}
  if (n < 0) {
    if (needsSpace) CStringAppendCharacter(self, 0x0020);
    s= "minus";
    CStringAppendBytes(self, NSISOLatin1StringEncoding, s, strlen(s));
    needsSpace = YES;}
  if (milliards) {
    number -= milliards * 1000000000;
    if (needsSpace) CStringAppendCharacter(self, 0x0020);
    if (!_englishNumber999(self, originalLength, (unsigned)milliards)) { return NO; }
    s= " billion";
    CStringAppendBytes(self, NSISOLatin1StringEncoding, s, strlen(s));
    needsSpace = YES;}
  millions = number / 1000000;
  if (millions) {
    number -= millions * 1000000;
    if (needsSpace) CStringAppendCharacter(self, 0x0020);
    if (!_englishNumber999(self, originalLength, (unsigned)millions)) { return NO; }
    s= " million";
    CStringAppendBytes(self, NSISOLatin1StringEncoding, s, strlen(s));
    needsSpace = YES;}
  milliers = number / 1000;
  if (milliers) {
    number -= milliers * 1000;
    if (needsSpace) CStringAppendCharacter(self, 0x0020);
    if (!_englishNumber999(self, originalLength, (unsigned)milliers)) { return NO; }
    s= " thousand";
    CStringAppendBytes(self, NSISOLatin1StringEncoding, s, strlen(s));
    needsSpace = YES;}
  if (number) {
    if (needsSpace) {
      if (number < 100 && initialNumber > 100) {
        s= " and ";
        CStringAppendBytes(self, NSISOLatin1StringEncoding, s, strlen(s));}
      else CStringAppendCharacter(self, 0x0020);}
    if (!_englishNumber999(self, originalLength, (unsigned)number)) { return NO; }}
  return YES;
}

static _CUBNumberAppender __numberAppenders[37] =
{
  _snd, // MSRussian
  _snd, // -- 1
  _snd, // -- 2
  _snd, // MSPortuguese
  _snd, // -- 4
  _snd, // MSItalian =*=*=*=*=*=*=*=*=*=*=                               DEFINED
  _snd, // MSGreek
  _snd, // MSDanish
  _snd, // -- 8
  _snd, // -- 9
  _snd, // -- 10
  _snd, // -- MSTurkish
  _snd, // -- 12
  _snd, // -- 13
  _snd, // MSDutch
  _snd, // MSNorwegian
  _snd, // MSRoman ==> should we use the roman representation here ?
  CStringAppendFrenchNumber, // MSFrench =*=*=*=*=*=*=*=*=*=*=    DEFINED
  _snd, // -- 18
  _snd, // -- 19
  _snd, // MSSpanish =*=*=*=*=*=*=*=*=*=*=                               DEFINED
  _snd, // MSArmenian
  _snd, // -- 22
  _snd, // MSArabic
  _snd, // -- 24
  _snd, // -- 25
  _snd, // MSGerman =*=*=*=*=*=*=*=*=*=*=                                DEFINED
  _snd, // MSBulgarian
  _snd, // -- 28
  CStringAppendEnglishNumber, // MSEnglish =*=*=*=*=*=*=*=*=*=*=  DEFINED
  _snd, // MSSerbian
  _snd, // -- 31
  _snd, // MSCzech
  _snd, // MSPolish
  _snd, // MSCroatian
  _snd, // -- 35
  _snd  // -- 36
};

BOOL CStringAppendTextNumber(CString *self, MSLong n, MSLanguage language)
{ return (__numberAppenders[(int)language])(self, n); }


/************************** TO DO IN THIS FILE  ****************
 (1)  be sure that the length of an UTF8String is <= of the length
 of its unicode (utf16) equivalent...
 (2)  german, italian and spanish number in text transformation
 (3)  recognising NSSymbolStringEncoding, NSISOLatin2StringEncoding,
 NSWindowsCP1251StringEncoding,  NSWindowsCP1253StringEncoding,
 NSWindowsCP1254StringEncoding, NSWindowsCP1250StringEncoding
 in CStringAppendUnknownEncodingBytes()
 
 *************************************************************/

/*
parse number
def string_to_int(s):
    i = 0
    sign = 1
    if s[0] == '-':
        sign = -1
        s = s[1:]
    for c in s:
        if not ('0' <= c <= '9'):
            raise ValueError
        i *= 10
        i += ord(c) - ord('0')
    i *= sign
    return i

// atoi - christopher.watford@gmail.com
// PUBLIC DOMAIN
long atoi(const char *value) {
  unsigned long ival = 0, c, n = 1, i = 0, oval;
  for(; c = value[i]; ++i) // chomp leading spaces
    if (!isspace(c)) break;
  if (c == '-' || c == '+') { // chomp sign
    n = (c != '-' ? n : -1);
    i++;
  }
  while(c = value[i++]) { // parse number
    if (!isdigit(c)) return 0;
    ival = (ival * 10) + (c - '0'); // mult/accum
    if ((n > 0 && ival > LONG_MAX)
    || (n < 0 && ival > (LONG_MAX + 1UL))) {
      // report overflow/underflow
      errno = ERANGE;
      return (n > 0 ? LONG_MAX : LONG_MIN);
    }
  }
  return (n>0 ? (long)ival : -(long)ival);
}

parseNumber(plusSigns,minusSigns,chiffreSigns,separatorSigns,pointSigns)
1/ retourne l’index du premier caractère non reconnu
2/ retourne le décimal associé, NULL si non reconnu
sign= +1; decimal= NULL;
passer les blancs
Si c est dans plusSigns sign= +1;
Si c est dans minusSigns sign= -1;
Si c n’est pas un chiffre on sort avec l’index de c
tant que c est un chiffre ou un séparateur (' ' ou ',')

// http://krashan.ppa.pl/articles/stringtofloat/
*/

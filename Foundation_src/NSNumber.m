#import "FoundationCompatibility_Private.h"

typedef union {
  MSChar        i1;
  MSShort       i2;
  MSInt         i4;
  MSLong        i8;
  MSByte        u1;
  MSUShort      u2;
  MSUInt        u4;
  MSULong       u8;
  long          ld;
  unsigned long lu;
  NSInteger     nsi;
  NSUInteger    nsu;
  float         flt;
  double        dbl;
} NSNumberUnion;

static const char * i1ObjCType=  @encode(MSChar);
static const char * i2ObjCType=  @encode(MSShort);
static const char * i4ObjCType=  @encode(MSInt);
static const char * i8ObjCType=  @encode(MSLong);
static const char * u1ObjCType=  @encode(MSByte);
static const char * u2ObjCType=  @encode(MSUShort);
static const char * u4ObjCType=  @encode(MSUInt);
static const char * u8ObjCType=  @encode(MSULong);
static const char * ldObjCType=  @encode(long);
static const char * luObjCType=  @encode(unsigned long);
static const char * nsiObjCType= @encode(NSInteger);
static const char * nsuObjCType= @encode(NSUInteger);
static const char * fltObjCType= @encode(float);
static const char * dblObjCType= @encode(double);

static const char ci1ObjCType  = 'c';
static const char ci2ObjCType  = 's';
static const char ci4ObjCType  = 'i';
static const char ci8ObjCType  = 'q';
static const char cldObjCType  = 'l';
static const char cu1ObjCType  = 'C';
static const char cu2ObjCType  = 'S';
static const char cu4ObjCType  = 'I';
static const char cu8ObjCType  = 'Q';
static const char cluObjCType  = 'L';
static const char cfltObjCType = 'f';
static const char cdblObjCType = 'd';

@interface _NSNumber : NSNumber {
  const char *_objctype;
  NSNumberUnion _value;
}
@end

@implementation _NSNumber
- (NSNumber *)initWithBool:(BOOL)value                       { RELEASE(self); return (id)(value ? MSTrue : MSFalse);}
- (NSNumber *)initWithChar:(char)v                           { _value.i1  = v; _objctype= i1ObjCType;  return self; }
- (NSNumber *)initWithShort:(short)v                         { _value.i2  = v; _objctype= i2ObjCType;  return self; }
- (NSNumber *)initWithInt:(int)v                             { _value.i4  = v; _objctype= i4ObjCType;  return self; }
- (NSNumber *)initWithLongLong:(long long)v                  { _value.i8  = v; _objctype= i8ObjCType;  return self; }
- (NSNumber *)initWithLong:(long)v                           { _value.ld  = v; _objctype= ldObjCType;  return self; }
- (NSNumber *)initWithInteger:(NSInteger)v                   { _value.nsi = v; _objctype= nsiObjCType; return self; }
- (NSNumber *)initWithUnsignedChar:(unsigned char)v          { _value.u1  = v; _objctype= u1ObjCType;  return self; }
- (NSNumber *)initWithUnsignedShort:(unsigned short)v        { _value.u2  = v; _objctype= u2ObjCType;  return self; }
- (NSNumber *)initWithUnsignedInt:(unsigned int)v            { _value.u4  = v; _objctype= u4ObjCType;  return self; }
- (NSNumber *)initWithUnsignedLongLong:(unsigned long long)v { _value.u8  = v; _objctype= u8ObjCType;  return self; }
- (NSNumber *)initWithUnsignedLong:(unsigned long)v          { _value.lu  = v; _objctype= luObjCType;  return self; }
- (NSNumber *)initWithUnsignedInteger:(NSUInteger)v          { _value.nsu = v; _objctype= nsuObjCType; return self; }
- (NSNumber *)initWithFloat:(float)v                         { _value.flt = v; _objctype= fltObjCType; return self; }
- (NSNumber *)initWithDouble:(double)v                       { _value.dbl = v; _objctype= dblObjCType; return self; }
- (const char*)objCType { return _objctype; }
- (void)getValue:(void *)buffer
{
  NSNumberUnion *v= (NSNumberUnion*)buffer;
  switch(*_objctype) {
    case ci1ObjCType:  (*v).i1  = _value.i1 ; break;
    case ci2ObjCType:  (*v).i2  = _value.i2 ; break;
    case ci4ObjCType:  (*v).i4  = _value.i4 ; break;
    case ci8ObjCType:  (*v).i8  = _value.i8 ; break;
    case cldObjCType:  (*v).ld  = _value.ld ; break;
    case cu1ObjCType:  (*v).u1  = _value.u1 ; break;
    case cu2ObjCType:  (*v).u2  = _value.u2 ; break;
    case cu4ObjCType:  (*v).u4  = _value.u4 ; break;
    case cu8ObjCType:  (*v).u8  = _value.u8 ; break;
    case cluObjCType:  (*v).lu  = _value.lu ; break;
    case cfltObjCType: (*v).flt = _value.flt; break;
    case cdblObjCType: (*v).dbl = _value.dbl; break;
    default: MSReportError(MSInternalInconsistencyError, MSFatalError, -1, "objctype \"%s\" was not expected\n", _objctype); break;
  }
}
@end

@implementation NSNumber
+ (instancetype)allocWithZone:(NSZone *)zone
{
  if (self == [NSNumber class]) return [_NSNumber allocWithZone:zone];
  return [super allocWithZone:zone];
}
+ (NSNumber *)numberWithChar:(char)value                           { return AUTORELEASE([ALLOC(_NSNumber) initWithChar:value]); }
+ (NSNumber *)numberWithUnsignedChar:(unsigned char)value          { return AUTORELEASE([ALLOC(_NSNumber) initWithUnsignedChar:value]); }
+ (NSNumber *)numberWithShort:(short)value                         { return AUTORELEASE([ALLOC(_NSNumber) initWithShort:value]); }
+ (NSNumber *)numberWithUnsignedShort:(unsigned short)value        { return AUTORELEASE([ALLOC(_NSNumber) initWithUnsignedShort:value]); }
+ (NSNumber *)numberWithInt:(int)value                             { return AUTORELEASE([ALLOC(_NSNumber) initWithInt:value]); }
+ (NSNumber *)numberWithUnsignedInt:(unsigned int)value            { return AUTORELEASE([ALLOC(_NSNumber) initWithUnsignedInt:value]); }
+ (NSNumber *)numberWithLong:(long)value                           { return AUTORELEASE([ALLOC(_NSNumber) initWithLong:value]); }
+ (NSNumber *)numberWithUnsignedLong:(unsigned long)value          { return AUTORELEASE([ALLOC(_NSNumber) initWithUnsignedLong:value]); }
+ (NSNumber *)numberWithLongLong:(long long)value                  { return AUTORELEASE([ALLOC(_NSNumber) initWithLongLong:(MSLong)value]); }
+ (NSNumber *)numberWithUnsignedLongLong:(unsigned long long)value { return AUTORELEASE([ALLOC(_NSNumber) initWithUnsignedLongLong:(MSULong)value]); }
+ (NSNumber *)numberWithFloat:(float)value                         { return AUTORELEASE([ALLOC(_NSNumber) initWithFloat:value]); }
+ (NSNumber *)numberWithDouble:(double)value                       { return AUTORELEASE([ALLOC(_NSNumber) initWithDouble:value]); }
+ (NSNumber *)numberWithBool:(BOOL)value                           { return value ? MSTrue : MSFalse; }
+ (NSNumber *)numberWithInteger:(NSInteger)value                   { return AUTORELEASE([ALLOC(_NSNumber) initWithInteger:value]); }
+ (NSNumber *)numberWithUnsignedInteger:(NSUInteger)value          { return AUTORELEASE([ALLOC(_NSNumber) initWithUnsignedInteger:value]); }

- (NSNumber *)initWithChar:(char)v                           { return [self notImplemented:_cmd]; }
- (NSNumber *)initWithUnsignedChar:(unsigned char)v          { return [self notImplemented:_cmd]; }
- (NSNumber *)initWithShort:(short)v                         { return [self notImplemented:_cmd]; }
- (NSNumber *)initWithUnsignedShort:(unsigned short)v        { return [self notImplemented:_cmd]; }
- (NSNumber *)initWithInt:(int)v                             { return [self notImplemented:_cmd]; }
- (NSNumber *)initWithUnsignedInt:(unsigned int)v            { return [self notImplemented:_cmd]; }
- (NSNumber *)initWithLong:(long)v                           { return [self notImplemented:_cmd]; }
- (NSNumber *)initWithUnsignedLong:(unsigned long)v          { return [self notImplemented:_cmd]; }
- (NSNumber *)initWithLongLong:(long long)v                  { return [self notImplemented:_cmd]; }
- (NSNumber *)initWithUnsignedLongLong:(unsigned long long)v { return [self notImplemented:_cmd]; }
- (NSNumber *)initWithFloat:(float)v                         { return [self notImplemented:_cmd]; }
- (NSNumber *)initWithDouble:(double)v                       { return [self notImplemented:_cmd]; }
- (NSNumber *)initWithBool:(BOOL)v                           { return [self notImplemented:_cmd]; }
- (NSNumber *)initWithInteger:(NSInteger)v                   { return [self notImplemented:_cmd]; }
- (NSNumber *)initWithUnsignedInteger:(NSUInteger)v          { return [self notImplemented:_cmd]; }
- (instancetype)initWithCoder:(NSCoder *)aDecoder            { return [self notImplemented:_cmd]; }

- (MSLong)_signedValue
{
  NSNumberUnion v; MSLong ret;
  [self getValue:&v];
  switch(*[self objCType]) {
    case ci1ObjCType: ret= (MSLong)v.i1; break;
    case ci2ObjCType: ret= (MSLong)v.i2; break;
    case ci4ObjCType: ret= (MSLong)v.i4; break;
    case ci8ObjCType: ret= (MSLong)v.i8; break;
    case cldObjCType: ret= (MSLong)v.ld; break;
    case cu1ObjCType: ret= (MSLong)v.u1; break;
    case cu2ObjCType: ret= (MSLong)v.u2; break;
    case cu4ObjCType: ret= (MSLong)v.u4; break;
    case cu8ObjCType: ret= (MSLong)v.u8; break;
    case cluObjCType: ret= (MSLong)v.lu; break;
    case cdblObjCType:ret= (MSLong)v.dbl; break;
    case cfltObjCType:ret= (MSLong)v.flt; break;
    default: MSReportError(MSInternalInconsistencyError, MSFatalError, -1, "objctype \"%s\" was not expected\n", [self objCType]); break;
  }
  return ret;
}
- (MSULong)_unsignedValue
{
  NSNumberUnion v; MSLong ret;
  [self getValue:&v];
  switch(*[self objCType]) {
    case ci1ObjCType: ret= (MSULong)v.i1; break;
    case ci2ObjCType: ret= (MSULong)v.i2; break;
    case ci4ObjCType: ret= (MSULong)v.i4; break;
    case ci8ObjCType: ret= (MSULong)v.i8; break;
    case cldObjCType: ret= (MSULong)v.ld; break;
    case cu1ObjCType: ret= (MSULong)v.u1; break;
    case cu2ObjCType: ret= (MSULong)v.u2; break;
    case cu4ObjCType: ret= (MSULong)v.u4; break;
    case cu8ObjCType: ret= (MSULong)v.u8; break;
    case cluObjCType: ret= (MSULong)v.lu; break;
    case cdblObjCType:ret= (MSULong)v.dbl; break;
    case cfltObjCType:ret= (MSULong)v.flt; break;
    default: MSReportError(MSInternalInconsistencyError, MSFatalError, -1, "objctype \"%s\" was not expected\n", [self objCType]); break;
  }
  return ret;
}

- (BOOL)boolValue                           { return                      [self _signedValue] != 0;   }
- (char)charValue                           { return                (char)[self _signedValue]; }
- (short)shortValue                         { return               (short)[self _signedValue]; }
- (int)intValue                             { return                 (int)[self _signedValue]; }
- (long)longValue                           { return                (long)[self _signedValue]; }
- (long long)longLongValue                  { return           (long long)[self _signedValue]; }
- (unsigned char)unsignedCharValue          { return       (unsigned char)[self _unsignedValue]; }
- (unsigned short)unsignedShortValue        { return      (unsigned short)[self _unsignedValue]; }
- (unsigned int)unsignedIntValue            { return        (unsigned int)[self _unsignedValue]; }
- (unsigned long)unsignedLongValue          { return       (unsigned long)[self _unsignedValue]; }
- (unsigned long long)unsignedLongLongValue { return  (unsigned long long)[self _unsignedValue]; }
- (float)floatValue                         { return               (float)[self doubleValue]; }
- (double)doubleValue
{
  NSNumberUnion v; double ret;
  [self getValue:&v];
  switch(*[self objCType]) {
    case ci1ObjCType: ret= (double)v.i1; break;
    case ci2ObjCType: ret= (double)v.i2; break;
    case ci4ObjCType: ret= (double)v.i4; break;
    case ci8ObjCType: ret= (double)v.i8; break;
    case cldObjCType: ret= (double)v.ld; break;
    case cu1ObjCType: ret= (double)v.u1; break;
    case cu2ObjCType: ret= (double)v.u2; break;
    case cu4ObjCType: ret= (double)v.u4; break;
    case cu8ObjCType: ret= (double)v.u8; break;
    case cluObjCType: ret= (double)v.lu; break;
    case cdblObjCType:ret= (double)v.dbl; break;
    case cfltObjCType:ret= (double)v.flt; break;
    default: MSReportError(MSInternalInconsistencyError, MSFatalError, -1, "objctype \"%s\" was not expected\n", [self objCType]); break;
  }
  return ret;
}
- (NSString *)stringValue
{ return [self description]; }

- (BOOL)isEqual:(id)object
{
  if (object == self) return YES;
  return [object isKindOfClass:[NSNumber class]] && [self isEqualToNumber:object];
}
- (BOOL)isEqualToNumber:(NSNumber *)aNumber
{
  return [self compare:aNumber] == NSOrderedSame;
}
#define _cmp(A,B) ({ __typeof__(A) __a= (A); __typeof__(B) __b= (B); \
  __a < __b ? NSOrderedAscending : (__a > __b ? NSOrderedDescending : NSOrderedSame); })
#define _cmp_llu_lld(A,B) ({ MSULong __llu= (A); MSLong __lld= (B); \
  __llu > NSOrderedDescending ? O : _cmp((MSLong)__llu, __lld); })

- (NSComparisonResult)compare:(NSNumber *)aNumber
{
  NSComparisonResult ret;
  char t0= *[self objCType], t1= *[aNumber objCType];
  if (t0 == 'd' || t1 == 'd' || t0 == 'f' || t1 == 'f') { // at least one is a real
    ret= _cmp([self doubleValue], [aNumber doubleValue]);}
  else if (t0 == 'Q' || t1 == 'Q') { // at least one is llu
    if (t0 == 'Q' && t1 == 'Q') {
      ret= _cmp([self unsignedLongLongValue], [aNumber unsignedLongLongValue]);}
    else if (t0 == 'Q') {
      MSULong a= [self unsignedLongLongValue];
      ret= a > LLONG_MAX ? NSOrderedDescending : _cmp((MSLong)a, [aNumber longLongValue]); }
    else {
      MSULong b= [aNumber unsignedLongLongValue];
      ret= b > LLONG_MAX ? NSOrderedAscending : _cmp([self longLongValue], (MSLong)b); }}
  else { // both are signed value
    ret= _cmp([self longLongValue], [aNumber longLongValue]);}
  return ret;
}
- (NSString*)description
{
  id d= nil;
  switch(*[self objCType]) {
    case ci1ObjCType: d= [NSString stringWithFormat:@"%d",    [self intValue]]; break;
    case ci2ObjCType: d= [NSString stringWithFormat:@"%hd",   [self shortValue]]; break;
    case ci4ObjCType: d= [NSString stringWithFormat:@"%d",    [self intValue]]; break;
    case ci8ObjCType: d= [NSString stringWithFormat:@"%lld",  [self longLongValue]]; break;
    case cldObjCType: d= [NSString stringWithFormat:@"%ld",   [self longValue]]; break;
    case cu1ObjCType: d= [NSString stringWithFormat:@"%u",    [self unsignedIntValue]]; break;
    case cu2ObjCType: d= [NSString stringWithFormat:@"%hu",   [self unsignedShortValue]]; break;
    case cu4ObjCType: d= [NSString stringWithFormat:@"%u",    [self unsignedIntValue]]; break;
    case cu8ObjCType: d= [NSString stringWithFormat:@"%llu",  [self unsignedLongLongValue]]; break;
    case cluObjCType: d= [NSString stringWithFormat:@"%lu",   [self unsignedLongValue]]; break;
    case cdblObjCType:d= [NSString stringWithFormat:@"%0.16g",[self doubleValue]]; break;
    case cfltObjCType:d= [NSString stringWithFormat:@"%0.7g", [self doubleValue]]; break;
    default: MSReportError(MSInternalInconsistencyError, MSFatalError, -1, "objctype \"%s\" was not expected\n", [self objCType]); break;
  }
  return d;
}

- (id)copyWithZone:(NSZone *)zone
{ return [self retain]; }

@end

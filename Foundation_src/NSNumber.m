#import "FoundationCompatibility_Private.h"

static const char *i8ObjCType = "q";
static const char *u8ObjCType = "Q";
static const char *dblObjCType = "d";
@implementation NSNumber

+ (NSNumber *)numberWithChar:(char)value
{ return [ALLOC(self) initWithChar:value]; }
+ (NSNumber *)numberWithUnsignedChar:(unsigned char)value
{ return [ALLOC(self) initWithUnsignedChar:value]; }
+ (NSNumber *)numberWithShort:(short)value
{ return [ALLOC(self) initWithShort:value]; }
+ (NSNumber *)numberWithUnsignedShort:(unsigned short)value
{ return [ALLOC(self) initWithUnsignedShort:value]; }
+ (NSNumber *)numberWithInt:(int)value
{ return [ALLOC(self) initWithInt:value]; }
+ (NSNumber *)numberWithUnsignedInt:(unsigned int)value
{ return [ALLOC(self) initWithUnsignedInt:value]; }
+ (NSNumber *)numberWithLong:(long)value
{ return [ALLOC(self) initWithLong:value]; }
+ (NSNumber *)numberWithUnsignedLong:(unsigned long)value
{ return [ALLOC(self) initWithUnsignedLong:value]; }
+ (NSNumber *)numberWithLongLong:(long long)value
{ return [ALLOC(self) initWithLongLong:(MSLong)value]; }
+ (NSNumber *)numberWithUnsignedLongLong:(unsigned long long)value
{ return [ALLOC(self) initWithUnsignedLongLong:(MSULong)value]; }
+ (NSNumber *)numberWithFloat:(float)value
{ return [ALLOC(self) initWithFloat:value]; }
+ (NSNumber *)numberWithDouble:(double)value
{ return [ALLOC(self) initWithDouble:value]; }
+ (NSNumber *)numberWithBool:(BOOL)value
{ return [ALLOC(self) initWithBool:value]; }
+ (NSNumber *)numberWithInteger:(NSInteger)value
{ return [ALLOC(self) initWithInteger:value]; }
+ (NSNumber *)numberWithUnsignedInteger:(NSUInteger)value
{ return [ALLOC(self) initWithUnsignedInteger:value]; }

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{ /* TODO */ return nil; }
- (NSNumber *)initWithChar:(char)v
{ return [self initWithLongLong:(MSLong)v]; }
- (NSNumber *)initWithUnsignedChar:(unsigned char)v
{ return [self initWithUnsignedLongLong:(MSULong)v]; }
- (NSNumber *)initWithShort:(short)v
{ return [self initWithLongLong:(MSLong)v]; }
- (NSNumber *)initWithUnsignedShort:(unsigned short)v
{ return [self initWithUnsignedLongLong:(MSULong)v]; }
- (NSNumber *)initWithInt:(int)v
{ return [self initWithLongLong:(MSLong)v]; }
- (NSNumber *)initWithUnsignedInt:(unsigned int)v
{ return [self initWithUnsignedLongLong:(MSULong)v]; }
- (NSNumber *)initWithLong:(long)v
{ return [self initWithLongLong:(MSLong)v]; }
- (NSNumber *)initWithUnsignedLong:(unsigned long)v
{ return [self initWithUnsignedLongLong:(MSULong)v]; }
- (NSNumber *)initWithLongLong:(long long)v
{
  self->_objctype= i8ObjCType;
  self->value.i8= v;
  return self;
}
- (NSNumber *)initWithUnsignedLongLong:(unsigned long long)v
{
  self->_objctype= u8ObjCType;
  self->value.u8= v;
  return self;
}
- (NSNumber *)initWithFloat:(float)v
{ return [self initWithDouble:(double)v]; }
- (NSNumber *)initWithDouble:(double)v
{
  self->_objctype= dblObjCType;
  self->value.dbl= v;
  return self;
}
- (NSNumber *)initWithBool:(BOOL)v
{ return [self initWithLongLong:(MSLong)v]; }
- (NSNumber *)initWithInteger:(NSInteger)v
{ return [self initWithLongLong:(MSLong)v]; }
- (NSNumber *)initWithUnsignedInteger:(NSUInteger)v
{ return [self initWithUnsignedLongLong:(MSULong)v]; }

- (MSLong)_signedValueWithMin:(MSLong)min max:(MSLong)max
{
  MSLong v;
  switch(*self->_objctype) {
    case 'q':  v=self->value.i8; break;
    case 'Q':  v= (MSLong)MAX((MSULong)MSLongMax, self->value.u8); break;
    case 'd': v= (MSLong)(self->value.dbl + 0.5); break;
    default: MSReportError(MSInternalInconsistencyError, MSFatalError, -1, "objctype \"%s\" was not expected\n", self->_objctype); break;
  }
  return MAX(min, MIN(v, max));
}

- (MSULong)_unsignedValueWithMax:(MSULong)max
{
  MSULong v;
  switch(*self->_objctype) {
    case 'q':  v= (MSULong)MIN((MSLong)0, self->value.i8); break;
    case 'Q':  v= self->value.u8; break;
    case 'd': v= (MSULong)(self->value.dbl + 0.5); break;
    default: MSReportError(MSInternalInconsistencyError, MSFatalError, -1, "objctype \"%s\" was not expected\n", self->_objctype); break;
  }
  return MIN(v, max);
}

- (double)_doubleValueWithMin:(double)min max:(double)max
{
  double v;
  switch(*self->_objctype) {
    case 'q':  v= (double)self->value.i8; break;
    case 'Q':  v= (double)self->value.u8; break;
    case 'd': v= self->value.dbl; break;
    default: MSReportError(MSInternalInconsistencyError, MSFatalError, -1, "objctype \"%s\" was not expected\n", self->_objctype); break;
  }
  return MAX(min, MIN(v, max));
}

- (char)charValue
{ return (char)[self _signedValueWithMin:CHAR_MIN max:CHAR_MAX]; }
- (unsigned char)unsignedCharValue
{ return (unsigned char)[self _unsignedValueWithMax:UCHAR_MAX]; }
- (short)shortValue
{ return (short)[self _signedValueWithMin:SHRT_MIN max:SHRT_MAX]; }
- (unsigned short)unsignedShortValue
{ return (unsigned short)[self _unsignedValueWithMax:USHRT_MAX]; }
- (int)intValue
{ return (int)[self _signedValueWithMin:INT_MIN max:INT_MAX]; }
- (unsigned int)unsignedIntValue
{ return (unsigned int)[self _unsignedValueWithMax:UINT_MAX]; }
- (long)longValue
{ return (long)[self _signedValueWithMin:LONG_MIN max:LONG_MAX]; }
- (unsigned long)unsignedLongValue
{ return (unsigned long)[self _unsignedValueWithMax:ULONG_MAX]; }
- (long long)longLongValue
{ return (long long)[self _signedValueWithMin:LLONG_MIN max:LLONG_MAX]; }
- (unsigned long long)unsignedLongLongValue
{ return (unsigned long long)[self _unsignedValueWithMax:ULLONG_MAX]; }
- (float)floatValue
{ return (float)[self _doubleValueWithMin:FLT_MIN max:FLT_MAX]; }
- (double)doubleValue
{ return (double)[self _doubleValueWithMin:DBL_MIN max:DBL_MAX]; }
- (BOOL)boolValue
{ return [self _signedValueWithMin:-1LL max:1LL] == 0; }

@end

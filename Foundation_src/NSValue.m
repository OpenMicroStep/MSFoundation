#import "FoundationCompatibility_Private.h"

@interface _NSValueAllocator : NSObject
@end

@interface _NSValueFast : NSValue {
@public
  union {
    char fast[8];
    char *ptr; // for _NSValueComplex
  } _type;
}
@end

@interface _NSValueComplex : _NSValueFast
@end

@implementation _NSValueAllocator
+ (id)initWithBytes:(const void *)value objCType:(const char *)type
{
  _NSValueFast *v; const char *end; size_t typeLen; NSUInteger sz, align; Class cls;

  typeLen= NSGetSizeAndAlignment(type, &sz, &align) - type;
  if (typeLen < 8) {
    v= NSAllocateObject(cls= [_NSValueFast class], sz, NULL);
    memcpy(v->_type.fast, type, typeLen);
    v->_type.fast[typeLen] = '\0';}
  else {
    v= NSAllocateObject(cls= [_NSValueComplex class], sz, NULL);
    v->_type.ptr= MSMalloc(typeLen + 1, "_NSValueComplex");
    memcpy(v->_type.ptr, type, typeLen);
    v->_type.ptr[typeLen] = '\0';}
  memcpy((void* )((char *)v + class_getInstanceSize(cls)), value, sz);

  return v;
}
@end

@implementation _NSValueFast
- (const char*)objCType
{
  return _type.fast;
}

- (void)getValue:(void *)buffer
{
  NSUInteger sz, align;
  NSGetSizeAndAlignment([self objCType], &sz, &align);
  memcpy(buffer, (void* )((char *)self + class_getInstanceSize([self class])), sz);
}
@end

@implementation _NSValueComplex
- (void)dealloc
{
  MSFree(_type.ptr, "_NSValueComplex");
  [super dealloc];
}
- (const char*)objCType
{
  return _type.ptr;
}
@end

@implementation NSValue
+ (instancetype)allocWithZone:(NSZone *)zone
{
  if (self == [NSValue class]) return [_NSValueAllocator class];
  return [super allocWithZone:zone];
}

+ (NSValue *)valueWithBytes:(const void *)value objCType:(const char *)type
{
  return AUTORELEASE([_NSValueAllocator initWithBytes:value objCType:type]);
}

+ (NSValue *)value:(const void *)value withObjCType:(const char *)type;
{
  return [self valueWithBytes:value objCType:type];
}

- (BOOL)isEqual:(id)object
{
  if (object == self)
    return YES;
  return [object isKindOfClass:[NSValue class]] && [self isEqualToValue:object];
}
- (BOOL)isEqualToValue:(NSValue *)aValue
{
  char *ta, *tb; BOOL equals;
  equals= strcmp((ta= [self objCType]), (tb= [aValue objCType])) == 0;
  if(equals) {
    NSUInteger sz, align;
    NSGetSizeAndAlignment(ta, &sz, &align);

    {
      char va[sz], vb[sz];
      [self getValue:(void *)va];
      [aValue getValue:(void *)vb];
      equals= memcmp((void*)va, (void*)vb, sz) == 0;
    }
  }
  return equals;
}
@end

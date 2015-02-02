#import "FoundationCompatibility_Private.h"

@implementation NSString

@end

@implementation NSMutableString

@end

@implementation NSConstantString

#pragma root class

+ (Class)class
{
  return self;
}

- (Class)class
{
  return isa;
}

- (BOOL)isKindOfClass:(Class)aClass
{
    Class selfClass= isa;
    while (selfClass && selfClass != aClass) {
        selfClass= class_getSuperclass(selfClass);
    }
    return selfClass == aClass;
}

#pragma primitives

- (NSUInteger)length
{
  return _length;
}

- (unichar)characterAtIndex:(NSUInteger)index
{
  return (unichar)(index<_length?_bytes[index]:0);
}

- (const char*)UTF8String
{
  return (const char *)_bytes;
}

- (SES)stringEnumeratorStructure
{
//printf("NSConstantString stringEnumeratorStructure\n");
  return MSMakeSESWithBytes(_bytes, _length, NSUTF8StringEncoding);
}

// TODO: This is very inefficient
- (NSUInteger)hash:(unsigned)depth
{
  CString *str= CCreateStringWithBytes(NSUTF8StringEncoding, _bytes, _length);
  NSUInteger hash= CStringHash((id)str, depth);
  CStringFree((id)str);
  return hash;
}

- (BOOL)isEqual:(id)object
  {
  BOOL ret;
  if (object == (id)self) return YES;
  if (!object) return NO;
  if ([object isKindOfClass:[NSConstantString class]]) {
    ret= _length==[object length] && strncmp(_bytes, [object UTF8String], _length)==0;}
  else {
    CString *str1,*str2; BOOL ret;
    str1= CCreateStringWithBytes(NSUTF8StringEncoding, _bytes, _length);
    if ([object isKindOfClass:[MSString class]]) str2= (CString*)RETAIN(object);
    else str2= CCreateStringWithSES([object stringEnumeratorStructure]);
    ret= CStringEquals(str1, str2);
    CStringFree((id)str1); RELEASE((id)str2);}
//printf("NSConstantString isEqual %s %s %d\n",_bytes,[object UTF8String],ret);
  return ret;
  }

- (id)copyWithZone:(NSZone*)z
{
//printf("NSConstantString copyWithZone %s %u\n",_bytes,_length);
//return [super copyWithZone:z];
  return self;
}

@end

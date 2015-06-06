#import "FoundationCompatibility_Private.h"

@implementation NSObject (NSCoderMethods)

+ (void)setVersion:(NSInteger)aVersion
{

}

@end

@implementation NSCoder

- (void)encodeObject:(id)object
{ [self encodeValueOfObjCType:@encode(id) at:&object]; }

- (void)encodeRootObject:(id)object
{ [self encodeObject:object]; }
- (void)encodeBycopyObject:(id)object
{ [self encodeObject:object]; }
- (void)encodeByrefObject:(id)object
{ [self encodeObject:object]; }
- (void)encodeConditionalObject:(id)object
{ [self encodeObject:object]; }

- (id)decodeObject
{
  id object;
  [self decodeValueOfObjCType:@encode(id) at:&object];
  return object;
}

- (void)encodeArrayOfObjCType:(const char *)type count:(NSUInteger)count at:(const void *)array
{
  NSUInteger size;
  NSGetSizeAndAlignment(type, &size, NULL);
  while(count > 0) {
    [self encodeValueOfObjCType:type at:array];
    array+= size;
    --count;
  }
}
- (void)decodeArrayOfObjCType:(const char *)type count:(NSUInteger)count at:(void *)array
{
  NSUInteger size;
  NSGetSizeAndAlignment(type, &size, NULL);
  while(count > 0) {
    [self decodeValueOfObjCType:type at:array];
    array+= size;
    --count;
  }
}

- (NSZone *)objectZone
{
  return NULL;
}

@end

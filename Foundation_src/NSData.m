#import "FoundationCompatibility_Private.h"

@interface _MSMBuffer : MSBuffer
// Mutable version of MSBuffer with some changes to follow NSMutableData specs
@end

@implementation NSData
+ (void)initialize
{
  if (self==[NSData class]) {
    FoundationCompatibilityExtendClass('+', self, 0, [MSBuffer class], @selector(data));
    FoundationCompatibilityExtendClass('+', self, 0, [MSBuffer class], @selector(dataWithData:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSBuffer class], @selector(dataWithBytes:length:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSBuffer class], @selector(dataWithBytesNoCopy:length:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSBuffer class], @selector(dataWithBytesNoCopy:length:freeWhenDone:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSBuffer class], @selector(dataWithContentsOfFile:options:error:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSBuffer class], @selector(dataWithContentsOfFile:));}
}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  if (self == [NSData class]) return [[MSBuffer class] allocWithZone:zone];
  return [super allocWithZone:zone];
}
- (BOOL)isEqual:(id)object
{
  if (object == self) return YES;
  return [object isKindOfClass:[NSData class]] && [self isEqualToData:object];
}

- (BOOL)isEqualToData:(NSData *)otherData
{
  return [self length] == [otherData length] && memcmp([self bytes], [otherData bytes], [self length]) == 0;
}

- (NSUInteger)length
{ [self notImplemented:_cmd]; return 0; }
- (const void *)bytes
{ [self notImplemented:_cmd]; return 0; }
@end

@implementation NSMutableData
+ (instancetype)allocWithZone:(NSZone *)zone
{
  if (self == [NSMutableData class]) return [[_MSMBuffer class] allocWithZone:zone];
  return [super allocWithZone:zone];
}
+ (instancetype)dataWithCapacity:(NSUInteger)capacity
{ return AUTORELEASE([ALLOC(self) initWithCapacity:capacity]); }
+ (instancetype)dataWithLength:(NSUInteger)length
{ return AUTORELEASE([ALLOC(self) initWithLength:length]); }

- (void *)mutableBytes
{ [self notImplemented:_cmd]; return 0; }
- (void)setLength:(NSUInteger)length
{ [self notImplemented:_cmd]; }

@end

@implementation _MSMBuffer
+ (void)initialize
{
  if (self==[_MSMBuffer class]) {
    FoundationCompatibilityExtendClass('-', self, @selector(initWithCapacity:), self, @selector(mutableInitWithCapacity:));
    FoundationCompatibilityExtendClass('-', self, @selector(initWithLength:), self, @selector(mutableInitWithLength:));}
}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  id o= [super allocWithZone:zone];
  CGrowSetForeverMutable(o);
  return o;
}
- (Class)_classForCopy {return [MSBuffer class];}

- (Class)superclass
{ 
  return [NSMutableData class]; 
}
- (BOOL)isKindOfClass:(Class)aClass
{
  return (aClass == [NSMutableData class]) || [super isKindOfClass:aClass];
}

@end

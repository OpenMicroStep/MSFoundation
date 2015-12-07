#import "FoundationCompatibility_Private.h"

@interface _MSMBuffer : MSBuffer
// Mutable version of MSBuffer with some changes to follow NSMutableData specs
@end

@implementation NSData
+ (void)initialize
{
  if (self==[NSData class]) {
    Class fromClass= [MSBuffer class];
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(data));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(dataWithData:));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(dataWithBytes:length:));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(dataWithBytesNoCopy:length:));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(dataWithBytesNoCopy:length:freeWhenDone:));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(dataWithContentsOfFile:options:error:));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(dataWithContentsOfFile:));}
}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  return (self == [NSData class]) ? [MSBuffer allocWithZone:zone]: [super allocWithZone:zone];
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
-(id)copyWithZone:(NSZone *)zone
{
  return [self retain];
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
  return [ALLOC(_MSMBuffer) initWithData:self];
}

- (NSUInteger)length
{ [self notImplemented:_cmd]; return 0; }
- (const void *)bytes
{ [self notImplemented:_cmd]; return 0; }
@end

@implementation NSMutableData
+ (instancetype)allocWithZone:(NSZone *)zone
{
  return (self == [NSMutableData class]) ? (NSMutableData*)[_MSMBuffer allocWithZone:zone]: [super allocWithZone:zone];
}
+ (instancetype)dataWithCapacity:(NSUInteger)capacity
{
  return AUTORELEASE([ALLOC(self) initWithCapacity:capacity]);
}
+ (instancetype)dataWithLength:(NSUInteger)length
{
  return AUTORELEASE([ALLOC(self) initWithLength:length]);
}
-(id)copyWithZone:(NSZone *)zone
{
  return [ALLOC(NSData) initWithData:self];
}

- (void *)mutableBytes
{ [self notImplemented:_cmd]; return 0; }
- (void)setLength:(NSUInteger)length
{ [self notImplemented:_cmd]; }

@end

@implementation _MSMBuffer
+ (void)initialize
{
  if (self==[_MSMBuffer class]) {
    Class fromClass= [MSBuffer class];
    FoundationCompatibilityExtendClass('-', self, @selector(initWithCapacity:), fromClass, @selector(mutableInitWithCapacity:));
    FoundationCompatibilityExtendClass('-', self, @selector(initWithLength:), fromClass, @selector(mutableInitWithLength:));
    FoundationCompatibilityExtendClass('-', self, @selector(initWithData:), fromClass, @selector(mutableInitWithData:));
    FoundationCompatibilityExtendClass('-', self, @selector(initWithBytes:length:), fromClass, @selector(mutableInitWithBytes:length:));
    FoundationCompatibilityExtendClass('-', self, @selector(initWithBytesNoCopy:length:), fromClass, @selector(mutableInitWithBytesNoCopy:length:));
    FoundationCompatibilityExtendClass('-', self, @selector(initWithContentsOfFile:options:error:), fromClass, @selector(mutableInitWithContentsOfFile:options:error:));
    FoundationCompatibilityExtendClass('-', self, @selector(initWithContentsOfFile:), fromClass, @selector(mutableInitWithContentsOfFile:));
  }
}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  id o= [super allocWithZone:zone];
  CGrowSetForeverMutable(o);
  return o;
}
- (instancetype)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)freeWhenDone
{
  if (freeWhenDone)
    CBufferInitWithBytesNoCopy((CBuffer*)self, bytes, length);
  else
    CBufferInitWithBytesNoCopyNoFree((CBuffer*)self, bytes, length);
  return self;
}
@end

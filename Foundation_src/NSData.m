#import "FoundationCompatibility_Private.h"

@implementation NSData
+ (void)load{ MSFinishLoadingAddClass(self); }
+ (void)finishLoading {
  FoundationCompatibilityExtendClass('+', self, 0, [MSBuffer class], @selector(data));
  FoundationCompatibilityExtendClass('+', self, 0, [MSBuffer class], @selector(dataWithData:));
  FoundationCompatibilityExtendClass('+', self, 0, [MSBuffer class], @selector(dataWithBytes:length:));
  FoundationCompatibilityExtendClass('+', self, 0, [MSBuffer class], @selector(dataWithBytesNoCopy:length:));
  FoundationCompatibilityExtendClass('+', self, 0, [MSBuffer class], @selector(dataWithBytesNoCopy:length:freeWhenDone:));
  FoundationCompatibilityExtendClass('+', self, 0, [MSBuffer class], @selector(dataWithContentsOfFile:options:error:));
  FoundationCompatibilityExtendClass('+', self, 0, [MSBuffer class], @selector(dataWithContentsOfFile:));
}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  if(self == [NSData class]) self= [MSBuffer class];
  return [super allocWithZone:zone];
}
-(id)copyWithZone:(NSZone *)zone
{
  return [self retain];
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
  return [ALLOC(NSMutableData) initWithData:self];
}
- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[NSData class]] && [self isEqualToData:object];
}

- (BOOL)isEqualToData:(NSData *)otherData
{
    return [self length] == [otherData length] && memcmp([self bytes], [otherData bytes], [self length]);
}

- (NSUInteger)length
{ [self notImplemented:_cmd]; return 0; }
- (const void *)bytes
{ [self notImplemented:_cmd]; return 0; }
@end


@implementation NSMutableData
+ (instancetype)allocWithZone:(NSZone *)zone
{
  if(self == [NSMutableData class]) {
    id o= [[MSBuffer class] allocWithZone:zone];
    CGrowSetMutabilityFixed(o);
    return o;}
  return [super allocWithZone:zone];
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

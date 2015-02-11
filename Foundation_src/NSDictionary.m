#import "FoundationCompatibility_Private.h"

@implementation NSDictionary
+ (void)load{ MSFinishLoadingAddClass(self); }
+ (void)finishLoading {
  FoundationCompatibilityExtendClass('+', self, 0, [MSDictionary class], @selector(dictionary));
  FoundationCompatibilityExtendClass('+', self, 0, [MSDictionary class], @selector(dictionaryWithObject:forKey:));
  FoundationCompatibilityExtendClass('+', self, 0, [MSDictionary class], @selector(dictionaryWithObjects:forKeys:count:));
  FoundationCompatibilityExtendClass('+', self, 0, [MSDictionary class], @selector(dictionaryWithObjectsAndKeys:));
  FoundationCompatibilityExtendClass('+', self, 0, [MSDictionary class], @selector(dictionaryWithDictionary:));
  FoundationCompatibilityExtendClass('+', self, 0, [MSDictionary class], @selector(dictionaryWithContentsOfFile:));
  FoundationCompatibilityExtendClass('+', self, 0, [MSDictionary class], @selector(dictionaryWithObjects:forKeys:));}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  if(self == [NSDictionary class]) self= [MSDictionary class];
  return [super allocWithZone:zone];
}
-(id)copyWithZone:(NSZone *)zone
{
  return [self retain];
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
  return [ALLOC(NSMutableDictionary) initWithDictionary:self];
}

- (NSUInteger)count
{ [self notImplemented:_cmd]; return 0; }
- (id)objectForKey:(id)aKey
{ [self notImplemented:_cmd]; return 0; }
- (NSEnumerator *)keyEnumerator
{ [self notImplemented:_cmd]; return 0; }
@end

@implementation NSMutableDictionary
+ (instancetype)allocWithZone:(NSZone *)zone
{
  if(self == [NSMutableDictionary class]) {
    id o= [[MSDictionary class] allocWithZone:zone];
    CGrowSetMutabilityFixed(o);
    return o;}
  return [super allocWithZone:zone];
}
-(id)copyWithZone:(NSZone *)zone
{
  return [ALLOC(NSDictionary) initWithDictionary:self];
}
@end

#import "FoundationCompatibility_Private.h"

@implementation NSArray
+ (void)load{ MSFinishLoadingAddClass(self); }
+ (void)finishLoading {
  FoundationCompatibilityExtendClass('+', self, 0, [MSArray class], @selector(array));
  FoundationCompatibilityExtendClass('+', self, 0, [MSArray class], @selector(arrayWithObjects:));
  FoundationCompatibilityExtendClass('+', self, 0, [MSArray class], @selector(arrayWithObjects:count:));
  FoundationCompatibilityExtendClass('+', self, 0, [MSArray class], @selector(arrayWithArray:));
}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  if(self == [NSArray class]) self= [MSArray class];
  return [super allocWithZone:zone];
}
-(id)copyWithZone:(NSZone *)zone
{
  return [self retain];
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
  return [ALLOC(NSMutableArray) initWithArray:self];
}

- (id)objectAtIndex:(NSUInteger)index
{ [self notImplemented:_cmd]; return 0; }
- (NSUInteger)count
{ [self notImplemented:_cmd]; return 0; }
@end

@implementation NSMutableArray
+ (instancetype)allocWithZone:(NSZone *)zone
{
  if(self == [NSMutableArray class]) self= [MSArray class];
  return [super allocWithZone:zone];
}
-(id)copyWithZone:(NSZone *)zone
{
  return [ALLOC(NSArray) initWithArray:self];
}
- (void)addObject:(id)anObject
{ [self notImplemented:_cmd]; }
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{ [self notImplemented:_cmd]; }
- (void)removeLastObject
{ [self notImplemented:_cmd]; }
- (void)removeObjectAtIndex:(NSUInteger)index
{ [self notImplemented:_cmd]; }
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{ [self notImplemented:_cmd]; }
@end

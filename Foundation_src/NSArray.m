#import "FoundationCompatibility_Private.h"

@interface _MSSArray : MSArray
// Immutable version of MSArray with some changes to follow NSArray specs
@end

@interface _MSMArray : MSArray
// Mutable version of MSArray with some changes to follow NSMutableArray specs
@end

@implementation NSArray
+ (void)load {MSFinishLoadingAddClass(self);}
+ (void)finishLoading
{
  if (self==[NSArray class]) {
    FoundationCompatibilityExtendClass('+', self, 0, [MSArray class], @selector(array));
    FoundationCompatibilityExtendClass('+', self, 0, [MSArray class], @selector(arrayWithObjects:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSArray class], @selector(arrayWithObjects:count:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSArray class], @selector(arrayWithArray:));}
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
  if(self == [NSMutableArray class]) {
    id o= [_MSMArray allocWithZone:zone];
    CGrowSetForeverMutable(o);
    return o;}
  return [super allocWithZone:zone];
}
+ (instancetype)dictionaryWithCapacity:(NSUInteger)capacity
{ return AUTORELEASE([ALLOC(self) initWithCapacity:capacity]); }
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

@implementation _MSSArray
-(id)copyWithZone:(NSZone *)zone
{ return [self retain]; }
-(id)mutableCopyWithZone:(NSZone *)zone
{ return [ALLOC(NSMutableArray) initWithArray:self]; }
@end

@implementation _MSMArray
-(id)copyWithZone:(NSZone *)zone
{ return [ALLOC(NSArray) initWithArray:self]; }
-(id)mutableCopyWithZone:(NSZone *)zone
{ return [ALLOC(NSMutableArray) initWithArray:self]; }

- (Class)superclass
{ 
  return [NSMutableArray class]; 
}
- (BOOL)isKindOfClass:(Class)aClass
{
  return (aClass == [NSMutableArray class]) || [super isKindOfClass:aClass];
}

- (instancetype)initWithCapacity:(NSUInteger)capacity{
  if((self= [self init])) {
    CArrayGrow((CArray*)self, capacity);
  }
  return self;
}
@end

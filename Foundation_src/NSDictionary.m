#import "FoundationCompatibility_Private.h"

@implementation NSDictionary
+ (void)load {MSFinishLoadingAddClass(self);}
+ (void)finishLoading
{
  if (self==[NSDictionary class]) {
    FoundationCompatibilityExtendClass('+', self, 0, [MSDictionary class], @selector(dictionary));
    FoundationCompatibilityExtendClass('+', self, 0, [MSDictionary class], @selector(dictionaryWithObject:forKey:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSDictionary class], @selector(dictionaryWithObjects:forKeys:count:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSDictionary class], @selector(dictionaryWithObjectsAndKeys:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSDictionary class], @selector(dictionaryWithDictionary:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSDictionary class], @selector(dictionaryWithContentsOfFile:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSDictionary class], @selector(dictionaryWithObjects:forKeys:));}
}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  if (self == [NSDictionary class]) self= [MSDictionary class];
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

@interface _MSMDictionary : MSDictionary
@end

@implementation _MSMDictionary

- (Class)superclass
{
    return [NSMutableDictionary class];
}

- (BOOL)isKindOfClass:(Class)aClass
{
    return (aClass == [NSMutableDictionary class]) || [super isKindOfClass:aClass];
}
- (instancetype)initWithCapacity:(NSUInteger)capacity{
  if((self= [self init])) {
    CDictionaryGrow((CDictionary*)self, capacity);
  }
  return self;
}
@end

@implementation NSMutableDictionary
+ (instancetype)allocWithZone:(NSZone *)zone
{
  if(self == [NSMutableDictionary class]) {
    id o= [_MSMDictionary allocWithZone:zone];
    CGrowSetMutabilityFixed(o);
    return o;}
  return [super allocWithZone:zone];
}
+ (instancetype)dictionaryWithCapacity:(NSUInteger)capacity
{ return AUTORELEASE([ALLOC(self) initWithCapacity:capacity]); }
-(id)copyWithZone:(NSZone *)zone
{
  return [ALLOC(NSDictionary) initWithDictionary:self];
}
- (void)removeObjectForKey:(id)aKey
{ [self notImplemented:_cmd]; }
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey
{ [self notImplemented:_cmd]; }
@end

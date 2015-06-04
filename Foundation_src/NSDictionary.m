#import "FoundationCompatibility_Private.h"

@interface _MSMDictionary : MSDictionary
// Mutable version of MSDictionary with some changes to follow NSMutableDictionary specs
@end

@implementation NSDictionary
+ (void)initialize
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
  if (self == [NSDictionary class]) return [[MSDictionary class] allocWithZone:zone];
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
- (NSEnumerator*)keyEnumerator
{ [self notImplemented:_cmd]; return 0; }

@end

@implementation NSMutableDictionary
+ (instancetype)allocWithZone:(NSZone *)zone
{
  if (self == [NSMutableDictionary class]) return [[_MSMDictionary class] allocWithZone:zone];
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

@implementation _MSMDictionary
+ (void)initialize
{
  if (self==[_MSMDictionary class]) {
    FoundationCompatibilityExtendClass('-', self, @selector(initWithCapacity:), self, @selector(mutableInitWithCapacity:));}
}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  id o= [super allocWithZone:zone];
  CGrowSetForeverMutable(o);
  return o;
}
- (Class)_classForCopy {return [MSDictionary class];}

- (Class)superclass
{ 
  return [NSMutableDictionary class]; 
}
- (BOOL)isKindOfClass:(Class)aClass
{
  return (aClass == [NSMutableDictionary class]) || [super isKindOfClass:aClass];
}

@end
@interface NSDictionary (Private)
- (BOOL)_isMS;
@end

@implementation NSDictionary (NSGenericDictionary)

- (BOOL)isEqualToDictionary:(NSDictionary*)otherDict
  {
  gdict_pfs_t sPfs= [self      _isMS] ? NULL : GDictionaryPfs;
  gdict_pfs_t oPfs= [otherDict _isMS] ? NULL : GDictionaryPfs;
  return GDictionaryEquals(sPfs, self, oPfs, otherDict);
  }
- (BOOL)isEqual:(id)object
  {
  if (object == (id)self) return YES;
  if (!object) return NO;
  if ([object isKindOfClass:[NSDictionary class]]) {
    gdict_pfs_t sPfs= [self   _isMS] ? NULL : GDictionaryPfs;
    gdict_pfs_t oPfs= [object _isMS] ? NULL : GDictionaryPfs;
    return GDictionaryEquals(sPfs, self, oPfs, object);}
  return NO;
  }

- (NSString*)description
{
  CString *s= CCreateString(0);
  CStringAppendGDictionaryDescription(s, GDictionaryPfs, self);
  return [(id)s autorelease];
}

@end

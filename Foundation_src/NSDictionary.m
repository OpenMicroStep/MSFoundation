#import "FoundationCompatibility_Private.h"

@interface _NSDictionaryEnumerator : NSEnumerator
{
@private
  gdict_pfs_t _pfs;
  GDictionaryEnumerator _dictEnumerator;
}
- (id)initWithDictionary:(NSDictionary*)a;
- (id)nextObject;
@end

@interface _MSMDictionary : MSDictionary
// Mutable version of MSDictionary with some changes to follow NSMutableDictionary specs
@end

@implementation NSDictionary
+ (void)initialize
{
  if (self==[NSDictionary class]) {
    Class fromClass= [MSDictionary class];
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(dictionary));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(dictionaryWithObject:forKey:));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(dictionaryWithObjects:forKeys:count:));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(dictionaryWithObjectsAndKeys:));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(dictionaryWithDictionary:));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(dictionaryWithContentsOfFile:));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(dictionaryWithObjects:forKeys:));

    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(objectEnumerator));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(isEqualToDictionary:));
  }
}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  return (self == [NSDictionary class]) ? [MSDictionary allocWithZone:zone] : [super allocWithZone:zone];
}
+ (NSDictionary *)dictionaryWithContentsOfFile:(NSString *)path
{
  NSString *contents= [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
  return [contents dictionaryValue];
}
- (NSDictionary *)initWithContentsOfFile:(NSString *)path
{
  DESTROY(self);
  return [[NSDictionary dictionaryWithContentsOfFile:path] retain];
}

-(id)copyWithZone:(NSZone *)zone
{
  return [self retain];
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
  return [ALLOC(NSMutableDictionary) initWithDictionary:self];
}

- (BOOL)isEqual:(id)object
{
  if (object == self) return YES;
  if (!object) return NO;
  return [object isKindOfClass:[NSDictionary class]] && [self isEqualToDictionary:object];
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
  return (self == [NSMutableDictionary class]) ? (id)[_MSMDictionary allocWithZone:zone] : [super allocWithZone:zone];
}
+ (instancetype)dictionaryWithCapacity:(NSUInteger)capacity
{
  return AUTORELEASE([ALLOC(self) initWithCapacity:capacity]);
}
-(id)copyWithZone:(NSZone *)zone
{
  return [ALLOC(NSDictionary) initWithDictionary:self];
}

- (void)removeObjectForKey:(id)aKey
{ [self notImplemented:_cmd]; }
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey
{ [self notImplemented:_cmd]; }

@end

@implementation NSMutableDictionary (NSExtendedMutableDictionary)

- (void)addEntriesFromDictionary:(NSDictionary*)otherDictionary
{
  GDictionaryEnumerator de; id k; gdict_pfs_t pfs;
  pfs= [otherDictionary _gdict_pfs];
  de= GMakeDictionaryEnumerator(pfs, otherDictionary);
  while ((k= GDictionaryEnumeratorNextKey(pfs, &de)) != de.stop) {
    [self setObject:GDictionaryEnumeratorCurrentObject(pfs, &de) forKey:k];
  }
}
- (void)removeAllObjects
{
  [self removeObjectsForKeys:[self allKeys]];
}
- (void)removeObjectsForKeys:(NSArray*)keyArray
{
  NSUInteger i, count;
  garray_pfs_t pfs= [keyArray _garray_pfs];
  for(i= 0, count= GArrayCount(pfs, keyArray); i < count; ++i)
    [self removeObjectForKey:GArrayObjectAtIndex(pfs, keyArray, i)];
}
- (void)setDictionary:(NSDictionary*)otherDictionary
{
  [self removeAllObjects];
  [self addEntriesFromDictionary:otherDictionary];
}

@end

@implementation _MSMDictionary
+ (void)initialize
{
  if (self==[_MSMDictionary class]) {
    Class fromClass= [MSDictionary class];
    FoundationCompatibilityExtendClass('-', self, @selector(initWithCapacity:), fromClass, @selector(mutableInitWithCapacity:));}
}

+ (instancetype)allocWithZone:(NSZone *)zone
{
  id o= [super allocWithZone:zone];
  CGrowSetForeverMutable(o);
  return o;
}
@end

@implementation NSDictionary (NSGenericDictionary)

- (NSArray*)allKeys
{
  GDictionaryEnumerator de; id k; gdict_pfs_t pfs; CArray *ret;
  pfs= [self _gdict_pfs];
  ret= CCreateArray(GDictionaryCount(pfs, self));
  de= GMakeDictionaryEnumerator(pfs, self);
  while ((k= GDictionaryEnumeratorNextKey(pfs, &de)) != de.stop)
    CArrayAddObject(ret, k);
  CGrowSetForeverImmutable((id)ret);
  return AUTORELEASE(ret);
}

- (NSArray*)allValues
{
  GDictionaryEnumerator de; id k; gdict_pfs_t pfs; CArray *ret;
  pfs= [self _gdict_pfs];
  ret= CCreateArray(GDictionaryCount(pfs, self));
  de= GMakeDictionaryEnumerator(pfs, self);
  while ((k= GDictionaryEnumeratorNextKey(pfs, &de)) != de.stop)
    CArrayAddObject(ret, GDictionaryEnumeratorCurrentObject(pfs, &de));
  CGrowSetForeverImmutable((id)ret);
  return AUTORELEASE(ret);
}

- (NSEnumerator *)objectEnumerator
{
  return AUTORELEASE([ALLOC(_NSDictionaryEnumerator) initWithDictionary:self]);
}

- (NSString*)description
{
  CString *s= CCreateString(0);
  CStringAppendGDictionaryDescription(s, [self _gdict_pfs], self);
  return [(id)s autorelease];
}

@end

@implementation _NSDictionaryEnumerator
- (id)initWithDictionary:(NSDictionary*)d
{
  _pfs= [d _gdict_pfs];
  _dictEnumerator= GMakeDictionaryEnumerator(_pfs, d);
  if (_pfs) {
    RETAIN(_dictEnumerator.e.fs.enumerator);
    RETAIN(_dictEnumerator.e.fs.dict);
  }
  else {
    RETAIN(_dictEnumerator.e.cEnumerator.dictionary);
  }
  return self;
}

- (void)dealloc
{
  if (_pfs) {
    RETAIN(_dictEnumerator.e.fs.enumerator);
    RETAIN(_dictEnumerator.e.fs.dict);
  }
  else {
    RETAIN(_dictEnumerator.e.cEnumerator.dictionary);
  }
  [super dealloc];
}

- (id)nextObject
{
  id o= nil;
  if (GDictionaryEnumeratorNextKey(_pfs, &_dictEnumerator) != _dictEnumerator.stop)
    o= GDictionaryEnumeratorCurrentObject(_pfs, &_dictEnumerator);
  return o;
}
@end

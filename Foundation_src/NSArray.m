#import "FoundationCompatibility_Private.h"
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@interface _MSMArray : MSArray
// Mutable version of MSArray with some changes to follow NSMutableArray specs
@end

@implementation NSArray
+ (void)initialize
{
  Class cls;
  if (self==[NSArray class]) {
    cls= [MSArray class];
    FoundationCompatibilityExtendClass('+', self, 0, cls, @selector(array));
    FoundationCompatibilityExtendClass('+', self, 0, cls, @selector(arrayWithObject:));
    FoundationCompatibilityExtendClass('+', self, 0, cls, @selector(arrayWithObjects:));
    FoundationCompatibilityExtendClass('+', self, 0, cls, @selector(arrayWithObjects:count:));
    FoundationCompatibilityExtendClass('+', self, 0, cls, @selector(arrayWithArray:));

    FoundationCompatibilityExtendClass('-', self, 0, cls, @selector(objectEnumerator));
    FoundationCompatibilityExtendClass('-', self, 0, cls, @selector(reverseObjectEnumerator));}
}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  return (self == [NSArray class]) ? [MSArray allocWithZone:zone] : [super allocWithZone:zone];
}

-(id)copyWithZone:(NSZone *)zone
{
  return [self retain];
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
  return [[NSMutableArray allocWithZone:zone] initWithArray:self];
}

- (BOOL)isEqual:(id)object
{
  if (object == self) return YES;
  if (!object) return NO;
  return [object isKindOfClass:[NSArray class]] && [self isEqualToArray:object];
}

- (NSUInteger)count
{ [self notImplemented:_cmd]; return 0; }
- (id)objectAtIndex:(NSUInteger)index
{ [self notImplemented:_cmd]; return 0; }
- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)cnt
{ [self notImplemented:_cmd]; return nil; }

+ (NSArray *)arrayWithContentsOfFile:(NSString *)path
{
  NSString *contents= [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
  return [contents arrayValue];
}
- (NSArray *)initWithContentsOfFile:(NSString *)path
{
  DESTROY(self);
  return [[NSArray arrayWithContentsOfFile:path] retain];
}

@end

@implementation NSMutableArray
+ (instancetype)allocWithZone:(NSZone *)zone
{
  return (NSMutableArray*)((self == [NSMutableArray class]) ? [_MSMArray allocWithZone:zone] : [super allocWithZone:zone]);
}
+ (instancetype)arrayWithCapacity:(NSUInteger)capacity
{
  return AUTORELEASE([ALLOC(self) initWithCapacity:capacity]);
}

-(id)copyWithZone:(NSZone *)zone
{
  return [[NSArray allocWithZone:zone] initWithArray:self];
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

@implementation _MSMArray

+ (void)initialize
{
  if (self==[_MSMArray class]) {
    FoundationCompatibilityExtendClass('-', self, @selector(initWithCapacity:), self, @selector(mutableInitWithCapacity:));}
}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  id o= [super allocWithZone:zone];
  CGrowSetForeverMutable(o);
  return o;
}

@end

@implementation NSArray (NSGenericArray)

- (BOOL)isEqualToArray:(NSArray*)otherArray
{
  return GArrayEquals([self _garray_pfs], self, [otherArray _garray_pfs], otherArray);
}

- (NSString*)description
{
  CString *s= CCreateString(0);
  CStringAppendGArrayDescription(s, [self _garray_pfs], self);
  return [(id)s autorelease];
}

- (id)firstObject
{
  return GArrayFirstObject([self _garray_pfs], self);
}

- (id)lastObject
{
  return GArrayLastObject([self _garray_pfs], self);
}

- (BOOL)containsObject:(id)o
{
  garray_pfs_t pfs= [self _garray_pfs];
  return GArrayIndexOfObject(pfs, self, o, 0, GArrayCount(pfs, self)) != NSNotFound;
}
- (BOOL)containsObjectIdenticalTo:(id)o
{
  garray_pfs_t pfs= [self _garray_pfs];
  return GArrayIndexOfIdenticalObject(pfs, self, o, 0, GArrayCount(pfs, self)) != NSNotFound;
}

- (NSUInteger)indexOfObject:(id)anObject
{
  garray_pfs_t pfs= [self _garray_pfs];
  return GArrayIndexOfObject(pfs, self, anObject, 0, GArrayCount(pfs, self));
}
- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range
{
  return GArrayIndexOfObject([self _garray_pfs], self, anObject, range.location, range.length);
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject
{
  garray_pfs_t pfs= [self _garray_pfs];
  return GArrayIndexOfIdenticalObject(pfs, self, anObject, 0, GArrayCount(pfs, self));
}
- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)range
{
  return GArrayIndexOfIdenticalObject([self _garray_pfs], self, anObject, range.location, range.length);
}

//- (NSEnumerator*)objectEnumerator { return nil; /* taken from MSArray, see +load */ }
//- (NSEnumerator*)reverseObjectEnumerator { return nil; /* taken from MSArray, see +load */ }

- (void)getObjects:(id*)objects
  {
  garray_pfs_t pfs= [self _garray_pfs];
  GArrayGetObject(pfs, self, 0, GArrayCount(pfs, self), objects);
  }
- (void)getObjects:(id*)objects range:(NSRange)rg
  {
  GArrayGetObject([self _garray_pfs], self, rg.location, rg.length, objects);
  }

- (void)makeObjectsPerformSelector:(SEL)aSelector
  {
  id e= [self objectEnumerator], o;
  while ((o= [e nextObject])) (*((void (*)(id, SEL))objc_msgSend))(o, aSelector);
  }

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)object
  {
  id e= [self objectEnumerator], o;
  while ((o= [e nextObject])) (*((void (*)(id, SEL, id))objc_msgSend))(o, aSelector, object);
  }

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2
  {
  id e= [self objectEnumerator], o;
  while ((o= [e nextObject])) (*((void (*)(id, SEL, id, id))objc_msgSend))(o, aSelector, object1, object2);
  }

@end

@implementation NSArray (NSGenericNewArray)

- (NSArray*)arrayByAddingObject:(id)anObject
{
  garray_pfs_t pfs= [self _garray_pfs];
  NSUInteger n= GArrayCount(pfs, self);
  CArray *ret= CCreateArray(n + 1);
  CArrayAddGArray(ret, pfs, self, 0, n, NO);
  CArrayAddObject(ret, anObject);
  CGrowSetForeverImmutable((id)ret);
  return AUTORELEASE(ret);
}

- (NSArray*)arrayByAddingObjectsFromArray:(NSArray *)otherArray
{
  garray_pfs_t spfs= [self _garray_pfs];
  garray_pfs_t opfs= [otherArray _garray_pfs];
  NSUInteger n= GArrayCount(spfs, self);
  NSUInteger m= GArrayCount(opfs, otherArray);
  CArray *ret= CCreateArray(n + m);
  CArrayAddGArray(ret, spfs, self, 0, n, NO);
  CArrayAddGArray(ret, opfs, otherArray, 0, m, NO);
  CGrowSetForeverImmutable((id)ret);
  return AUTORELEASE(ret);
}

@end

@implementation NSArray (NSExtendedArray)

- (NSString *)componentsJoinedByString:(NSString *)separator
{
  // TODO: use describeIn ?
  garray_pfs_t pfs= [self _garray_pfs];
  CString *ret; NSUInteger i= 0, count= GArrayCount(pfs, self); SES ses;
  ret= CCreateString(0);
  ses= SESFromString(separator);
  if (i < count)
    CStringAppendSES(ret, SESFromString([GArrayObjectAtIndex(pfs, self, i++) description]));
  while (i < count) {
    CStringAppendSES(ret, ses);
    CStringAppendSES(ret, SESFromString([GArrayObjectAtIndex(pfs, self, i++) description]));}
  return AUTORELEASE(ret);
}
- (NSString *)descriptionWithLocale:(id)locale
{
  return [self descriptionWithLocale:locale indent:0];
}
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
  [self notImplemented:_cmd];
  return nil;
}
- (id)firstObjectCommonWithArray:(NSArray *)othr
{
  id ret= nil;
  if (othr) {
    garray_pfs_t spfs= [self _garray_pfs];
    garray_pfs_t opfs= [othr _garray_pfs];
    NSUInteger si, sn= GArrayCount(spfs, self);
    NSUInteger oi, on= GArrayCount(opfs, othr);
    id oo;
    for(oi= 0; !ret && oi < on; ++oi) {
      oo= GArrayObjectAtIndex(opfs, othr, oi);
      for(si= 0; !ret && oi < on; ++on) {
        if ([GArrayObjectAtIndex(spfs, self, si) isEqual:oo]) {
          ret= oo;}}}}
  return nil;
}

- (NSData *)sortedArrayHint
{
  return nil;
}
- (NSArray *)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context
{
  CArray *copy= (CArray *)[MSArray mutableArrayWithArray:self];
  NSUInteger n= CArrayCount(copy);
  if (n) {
    MSObjectSort(copy->pointers, n, comparator, context);}
  CGrowSetForeverImmutable((id)copy);
  return (NSArray*)copy;
}
- (NSArray *)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context hint:(NSData *)hint
{
  return [self sortedArrayUsingFunction:comparator context:context];
  MSUnused(hint);
}
static NSInteger _compareUsingSelector(id a, id b, void *selector)
{
  return (*((NSInteger(*)(id,SEL,id))objc_msgSend))(a, (SEL)selector, b);
}
- (NSArray *)sortedArrayUsingSelector:(SEL)comparator
{
  return [self sortedArrayUsingFunction:_compareUsingSelector context:comparator];
}
- (NSArray *)subarrayWithRange:(NSRange)range
{
  garray_pfs_t pfs= [self _garray_pfs];
  if (range.location + range.length > GArrayCount(pfs, self))
    [NSException raise:NSRangeException format:@"out of range"];
  CArray *ret= CCreateArray(range.length);
  CArrayAddGArray(ret, pfs, self, range.location, range.length, NO);
  CGrowSetForeverImmutable((id)ret);
  return AUTORELEASE(ret);
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
  // TODO
  return NO;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
  return [self objectAtIndex:idx];
}

@end

@implementation NSMutableArray (NSExtendedMutableArray)

- (void)addObjectsFromArray:(NSArray *)otherArray
{
  NSUInteger i, count;
  garray_pfs_t pfs= [otherArray _garray_pfs];
  for(i= 0, count= GArrayCount(pfs, otherArray); i < count; ++i)
    [self addObject:GArrayObjectAtIndex(pfs, otherArray, i)];
}
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2
{
  id o1= [self objectAtIndex:idx1];
  id o2= [self objectAtIndex:idx2];
  [o1 retain];
  [self replaceObjectAtIndex:idx1 withObject:o2];
  [self replaceObjectAtIndex:idx2 withObject:o1];
  [o1 release];
}
- (void)removeAllObjects
{
  NSUInteger i= [self count];
  while (i > 0)
    [self removeObjectAtIndex:--i];
}
static inline void _removeObjectAtIndex(NSMutableArray *self, NSUInteger idx)
{
  if (idx != NSNotFound)
    [self removeObjectAtIndex:idx];
}
- (void)removeObject:(id)anObject inRange:(NSRange)range
{
  _removeObjectAtIndex(self, [self indexOfObject:anObject inRange:range]);
}
- (void)removeObject:(id)anObject
{
  _removeObjectAtIndex(self, [self indexOfObject:anObject]);
}
- (void)removeObjectIdenticalTo:(id)anObject inRange:(NSRange)range
{
  _removeObjectAtIndex(self, [self indexOfObjectIdenticalTo:anObject inRange:range]);
}
- (void)removeObjectIdenticalTo:(id)anObject
{
  _removeObjectAtIndex(self, [self indexOfObjectIdenticalTo:anObject]);
}
//- (void)removeObjectsFromIndices:(NSUInteger *)indices numIndices:(NSUInteger)cnt
- (void)removeObjectsInArray:(NSArray *)otherArray
{
  NSUInteger i, count;
  garray_pfs_t pfs= [otherArray _garray_pfs];
  for(i= 0, count= GArrayCount(pfs, otherArray); i < count; ++i)
    [self removeObject:GArrayObjectAtIndex(pfs, otherArray, i)];
}
- (void)removeObjectsInRange:(NSRange)range
{
  NSUInteger i= range.location + range.length;
  while (i > range.location)
    [self removeObjectAtIndex:--i];
}
// TODO - (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange
// TODO - (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray
- (void)setArray:(NSArray *)otherArray
{
  [self removeAllObjects];
  [self addObjectsFromArray:otherArray];
}
// TODO - (void)sortUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context;
// TODO - (void)sortUsingSelector:(SEL)comparator;

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx
{
  [self replaceObjectAtIndex:idx withObject:obj];
}
@end
#import "FoundationCompatibility_Private.h"

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
  if (self == [NSArray class]) return [[MSArray class] allocWithZone:zone];
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

- (NSUInteger)count
{ [self notImplemented:_cmd]; return 0; }
- (id)objectAtIndex:(NSUInteger)index
{ [self notImplemented:_cmd]; return 0; }
- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)cnt
{ [self notImplemented:_cmd]; return nil; }

@end

@implementation NSMutableArray
+ (instancetype)allocWithZone:(NSZone *)zone
{
  if (self == [NSMutableArray class]) return [[_MSMArray class] allocWithZone:zone];
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

@implementation _MSMArray

+ (void)load {MSFinishLoadingAddClass(self);}
+ (void)finishLoading
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
- (Class)_classForCopy {return [MSArray class];}

- (Class)superclass
{ 
  return [NSMutableArray class]; 
}
- (BOOL)isKindOfClass:(Class)aClass
{
  return (aClass == [NSMutableArray class]) || [super isKindOfClass:aClass];
}

@end

@interface NSArray (Private)
- (BOOL)_isMS;
@end

@implementation NSArray (NSGenericArray)

- (BOOL)isEqualToArray:(NSArray*)otherArray
  {
  garray_pfs_t sPfs= [self       _isMS] ? NULL : GArrayPfs;
  garray_pfs_t oPfs= [otherArray _isMS] ? NULL : GArrayPfs;
  return GArrayEquals(sPfs, self, oPfs, otherArray);
  }
- (BOOL)isEqual:(id)object
  {
  if (object == (id)self) return YES;
  if (!object) return NO;
  if ([object isKindOfClass:[NSArray class]]) {
    garray_pfs_t sPfs= [self   _isMS] ? NULL : GArrayPfs;
    garray_pfs_t oPfs= [object _isMS] ? NULL : GArrayPfs;
    return GArrayEquals(sPfs, self, oPfs, object);}
  return NO;
  }

- (NSString*)description
{
  CString *s= CCreateString(0);
  CStringAppendGArrayDescription(s, GArrayPfs, self);
  return [(id)s autorelease];
}

- (id)firstObject
{
  return GArrayFirstObject(GArrayPfs, self);
}

- (id)lastObject
{
  return GArrayLastObject(GArrayPfs, self);
}

- (BOOL)containsObject:(id)o
{
  return GArrayIndexOfObject(GArrayPfs, self, o, 0, GArrayPfs->count(self)) == NSNotFound ? NO : YES;
}
- (BOOL)containsObjectIdenticalTo:(id)o
{
  return GArrayIndexOfIdenticalObject(GArrayPfs, self, o, 0, GArrayPfs->count(self)) == NSNotFound ? NO : YES;
}

- (NSUInteger)indexOfObject:(id)anObject
{
  return GArrayIndexOfObject(GArrayPfs, self, anObject, 0, GArrayPfs->count(self));
}
- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range
{
  return GArrayIndexOfObject(GArrayPfs, self, anObject, range.location, range.length);
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject
{
  return GArrayIndexOfIdenticalObject(GArrayPfs, self, anObject, 0, GArrayPfs->count(self));
}
- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)range
{
  return GArrayIndexOfIdenticalObject(GArrayPfs, self, anObject, range.location, range.length);
}

- (NSEnumerator*)objectEnumerator
{
  NSArrayEnumerator *e= MSAllocateObject([NSArrayEnumerator class],0,nil);
  [e initWithArray:self reverse:NO];
  return AUTORELEASE(e);
}

- (NSEnumerator*)reverseObjectEnumerator
  {
  NSArrayEnumerator *e= MSAllocateObject([NSArrayEnumerator class],0,nil);
  [e initWithArray:self reverse:YES];
  return AUTORELEASE(e);
  }

- (void)getObjects:(id*)objects
  {
  GArrayGetObject(GArrayPfs, self, 0, GArrayPfs->count(self), objects);
  }
- (void)getObjects:(id*)objects range:(NSRange)rg
  {
  GArrayGetObject(GArrayPfs, self, rg.location, rg.length, objects);
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
  NSUInteger n= [self count];
  id os[n+1];
  [self getObjects:os];
  os[n]= anObject;
  return AUTORELEASE([[[self class] alloc] initWithObjects:os count:n+1]);
}

- (NSArray*)arrayByAddingObjectsFromArray:(NSArray *)otherArray
{
  NSUInteger n= [self count], m=[otherArray count];
  id os[n+m];
  [self getObjects:os]; [otherArray getObjects:os+n];
  return AUTORELEASE([[[self class] alloc] initWithObjects:os count:n+m]);
}

@end

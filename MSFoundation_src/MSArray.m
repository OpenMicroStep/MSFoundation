/*   MSArray.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
 
 This software is a computer program whose purpose is to [describe
 functionalities and technical features of your software].
 
 This software is governed by the CeCILL-C license under French law and
 abiding by the rules of distribution of free software.  You can  use,
 modify and/ or redistribute the software under the terms of the CeCILL-C
 license as circulated by CEA, CNRS and INRIA at the following URL
 "http://www.cecill.info".
 
 As a counterpart to the access to the source code and  rights to copy,
 modify and redistribute granted by the license, users are provided only
 with a limited warranty  and the software's author,  the holder of the
 economic rights,  and the successive licensors  have only  limited
 liability.
 
 In this respect, the user's attention is drawn to the risks associated
 with loading,  using,  modifying and/or developing or reproducing the
 software by the user in light of its specific status of free software,
 that may mean  that it is complicated to manipulate,  and  that  also
 therefore means  that it is reserved for developers  and  experienced
 professionals having in-depth computer knowledge. Users are therefore
 encouraged to load and test the software's suitability as regards their
 requirements in conditions enabling the security of their systems and/or
 data to be ensured and,  more generally, to use and operate it in the
 same conditions as regards security.
 
 The fact that you are presently reading this means that you have had
 knowledge of the CeCILL-C license and that you accept its terms.
 
 */

#import "MSFoundation_Private.h"

#pragma mark Private

@interface _MSArrayEnumerator : NSEnumerator
{
@private
  GArrayEnumerator _arrayEnumerator;
  BOOL _reverse;
}
- (id)initWithArray:(NSArray*)a reverse:(BOOL)reverse;
- (id)nextObject;
@end

@interface MSArray (Private)
- (BOOL)_isMS;
- (garray_pfs_t)_garray_pfs;
@end

static NSUInteger _NSArray_count(id o) { return [o count]; }
static id _NSArray_objectAtIndex(id o, NSUInteger idx) { return [o objectAtIndex:idx];}
static const struct garray_pfs_s GNSArrayPfs = {
  .count= _NSArray_count,
  .objectAtIndex= _NSArray_objectAtIndex
};

@implementation NSArray (Private)
- (garray_pfs_t)_garray_pfs {
  return &GNSArrayPfs;
}
- (BOOL)_isMS {return NO;}
@end

@implementation MSArray (Private)
- (BOOL)_isMS {return YES;}
- (garray_pfs_t)_garray_pfs {
  return NULL;
}
@end

#pragma mark Public

//***************************** TODO: IN THIS FILE *****************************
// (1)  a correct implementation of description... methods
// (2)  if possible (under cocotron for example) a better initWithCoder and encodeWithCoder method
//******************************************************************************

#define MS_ARRAY_LAST_VERSION 101

@implementation MSArray
+ (void)load          {
  MSFinishLoadingDec();}
+ (void)initialize {[MSArray setVersion:MS_ARRAY_LAST_VERSION];}

#pragma mark alloc / init

#define AL(X)   ALLOC(X)
#define AR(X)   AUTORELEASE(X)
#define FIXE(a) CGrowSetForeverImmutable((id)a)

static inline id _init(id a, BOOL m)
  {
  if (!m) FIXE(a);
  return a;
  }
+ (id)array        {return AR([AL(self)        init]);}
+ (id)mutableArray {return AR([AL(self) mutableInit]);}
+ (id)new          {return [AL(self) mutableInit];} // mutable
- (id)init         {return _init(self,  NO);}
- (id)mutableInit  {return _init(self, YES);}

static inline id _initWithObject(id a, BOOL m, id o)
  {
  CArrayAddObject((CArray*)a, o);
  return _init(a,m);
  }
+ (id)arrayWithObject:       (id)o {return AR([AL(self)        initWithObject:o]);}
+ (id)mutableArrayWithObject:(id)o {return AR([AL(self) mutableInitWithObject:o]);}
- (id)initWithObject:        (id)o {return _initWithObject(self,  NO, o);}
- (id)mutableInitWithObject: (id)o {return _initWithObject(self, YES, o);}

static inline id _initOsNC(id a, BOOL m, const id *os, NSUInteger n, BOOL copy)
  {
  CArrayAddObjects((CArray*)a, os, n, copy);
  return _init(a,m);
  }
+ (id)arrayWithObjects:       (const id*)os count:(NSUInteger)n {return AR([AL(self)        initWithObjects:os count:n]);}
+ (id)mutableArrayWithObjects:(const id*)os count:(NSUInteger)n {return AR([AL(self) mutableInitWithObjects:os count:n]);}
- (id)initWithObjects:        (const id*)os count:(NSUInteger)n {return _initOsNC(self,  NO, os,n,NO);}
- (id)mutableInitWithObjects: (const id*)os count:(NSUInteger)n {return _initOsNC(self, YES, os,n,NO);}

static inline id _initFoArgs(id a, BOOL m, id o, va_list l)
  {
  if (o) {
    CArrayAddObject((CArray*)a,o);
    while ((o= va_arg(l, id))) CArrayAddObject((CArray*)a,o);}
  return _init(a,m);
  }
+ (id)arrayWithFirstObject:       (id)o arguments:(va_list)l {return AR([AL(self)        initWithFirstObject:o arguments:l]);}
+ (id)mutableArrayWithFirstObject:(id)o arguments:(va_list)l {return AR([AL(self) mutableInitWithFirstObject:o arguments:l]);}
- (id)initWithFirstObject:        (id)o arguments:(va_list)l {return _initFoArgs(self,  NO, o,l);}
- (id)mutableInitWithFirstObject: (id)o arguments:(va_list)l {return _initFoArgs(self, YES, o,l);}

#define _arrayOs(CL,A,M,O) \
  id ret; \
  va_list ap; \
  va_start(ap, O); \
  ret= CL ? AL((id)CL) : A; \
  ret= _initFoArgs(ret,M, O,ap); \
  va_end(ap); \
  return CL ? AR(ret) : ret

+ (id)arrayWithObjects:       (id)firstObject, ... {_arrayOs(self, nil,  NO, firstObject);}
+ (id)mutableArrayWithObjects:(id)firstObject, ... {_arrayOs(self, nil, YES, firstObject);}
- (id)initWithObjects:        (id)firstObject, ... {_arrayOs(Nil ,self,  NO, firstObject);}
- (id)mutableInitWithObjects: (id)firstObject, ... {_arrayOs(Nil ,self, YES, firstObject);}

static inline void _addArray(CArray *self, NSArray *a, BOOL copyItems)
{
  garray_pfs_t pfs= [a _garray_pfs];
  CArrayAddGArray(self, pfs, a, 0, GArrayCount(pfs, a), copyItems);
}

static inline id _initA(id a, BOOL m, id aa, BOOL copy)
  {
  _addArray((CArray*)a, aa, copy);
  return _init(a,m);
  }
+ (id)arrayWithArray:       (NSArray*)array {return AR([AL(self)        initWithArray:array]);}
+ (id)mutableArrayWithArray:(NSArray*)array {return AR([AL(self) mutableInitWithArray:array]);}
- (id)initWithArray:        (NSArray*)array {return _initA(self,  NO, array, NO);}
- (id)mutableInitWithArray: (NSArray*)array {return _initA(self, YES, array, NO);}


#pragma mark Other inits

- (id)initWithObjects:       (const id*)os count:(NSUInteger)n copyItems:(BOOL)c {return _initOsNC(self,  NO, os,n,c);}
- (id)mutableInitWithObjects:(const id*)os count:(NSUInteger)n copyItems:(BOOL)c {return _initOsNC(self, YES, os,n,c);}

- (id)initWithArray:       (NSArray*)array copyItems:(BOOL)copy {return _initA(self,  NO, array, copy);}
- (id)mutableInitWithArray:(NSArray*)array copyItems:(BOOL)copy {return _initA(self, YES, array, copy);}

- (id)mutableInitWithCapacity:(NSUInteger)capacity
  {
  CArrayGrow((CArray*)self, capacity);
  return self;
  }
- (id)mutableInitWithCapacity:(NSUInteger)capacity noRetainRelease:(BOOL)noRR nilItems:(BOOL)nilItems
  {
  CArrayGrow((CArray*)self, capacity);
  self->_flags.noRetainRelease= noRR    ?1:0;
  self->_flags.nilItems=        nilItems?1:0;
  return self;
  }

#pragma mark Standard methods

- (BOOL)isMutable    {return !CGrowIsForeverImmutable(self);}
- (void)setImmutable {FIXE(self);}

- (NSUInteger)capacity {return _size;}

- (void)dealloc
  {
  CArrayFreeInside(self);
  [super dealloc];
  }

#pragma mark Primitives

- (NSUInteger)count {return _count;}

- (id)objectAtIndex:(NSUInteger)i
  {
  return CArrayObjectAtIndex((CArray*)self,i);
  }

#pragma mark Global methods

- (NSUInteger)hash:(unsigned)depth {return CArrayHash(self, depth);}

- (id)copyWithZone:(NSZone*)z
{return MSGrowCopyWithZone(z,self, NO,(MSGrowInitCopyMethod)CArrayInitCopyWithMutability);}
- (id)mutableCopyWithZone:(NSZone*)z
{return MSGrowCopyWithZone(z,self,YES,(MSGrowInitCopyMethod)CArrayInitCopyWithMutability);}

- (MSArray*)retainedSubs:(MSDictionary*)ctx
{
  return (MSArray*)CCreateArrayOfArraySubs(self, (CDictionary*)ctx);
  MSUnused(ctx);
}
- (void)describeIn:(id)result level:(int)level context:(MSDictionary*)ctx
{
  CArrayDescribe(self, result, level, (CDictionary*)ctx);
}

- (BOOL)isTrue
  {
  if (_count) {
    NSUInteger i;
    for (i= 0; i < _count; i++) { if (![_pointers[i] isTrue]) return NO; }
    return YES;}
  return NO;
  }

- (BOOL)isEqualToArray:(NSArray*)otherArray
  {
  if (otherArray == (id)self) return YES;
  if (!otherArray) return NO;
  if ([otherArray _isMS]) return CArrayEquals((CArray*)self,(CArray*)otherArray);
  return [super isEqualToArray:otherArray];
  }
- (BOOL)isEqual:(id)object
  {
  if (object == (id)self) return YES;
  if (!object) return NO;
  if ([object isKindOfClass:[NSArray class]]) {
    if ([object _isMS]) return CArrayEquals((CArray*)self, (CArray*)object);
    return [super isEqualToArray:(NSArray*)object];}
  return NO;
  }

- (void)makeObjectsPerformSelector:(SEL)aSelector
  {
  register NSUInteger i;
  for (i= 0; i < _count; i++) (*((void (*)(id, SEL))objc_msgSend))(_pointers[i], aSelector);
  }

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)object
  {
  register NSUInteger i;
  for (i= 0; i < _count; i++) (*((void (*)(id, SEL, id))objc_msgSend))(_pointers[i], aSelector, object);
  }

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2
  {
  register NSUInteger i;
  for (i= 0; i < _count; i++) (*((void (*)(id, SEL, id, id))objc_msgSend))(_pointers[i], aSelector, object1, object2);
  }

- (NSArray*)arrayByAddingObject:(id)anObject
  {
  NSArray *copy= [self mutableCopy];
  CArrayAddObject((CArray*)copy, anObject);
  if (![self isMutable]) FIXE(copy);
  return AUTORELEASE(copy);
  }

- (NSArray*)arrayByAddingObjectsFromArray:(NSArray*)a
  {
  NSArray *copy= [self mutableCopy];
  _addArray((CArray*)copy, a, NO);
  if (![self isMutable]) FIXE(copy);
  return AUTORELEASE(copy);
  }

- (NSArray*)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void*)context
  {
  NSArray *copy= [self mutableCopy];
  if (_count > 1 ) {
    MSObjectSort(((CArray*)copy)->pointers, _count, comparator, context);}
  if (![self isMutable]) FIXE(copy);
  return AUTORELEASE(copy);
  }

static NSComparisonResult _internalCompareFunction(id e1, id e2, void *selector)
  {
  return (*((NSComparisonResult(*)(id,SEL,id))objc_msgSend))(e1, (SEL)selector, e2);
  }
- (NSArray*)sortedArrayUsingSelector:(SEL)comparator
  {
  NSArray *copy= [self mutableCopy];
  if (_count > 1 ) {
    MSObjectSort(((CArray*)copy)->pointers, _count, _internalCompareFunction, (void*)comparator);}
  if (![self isMutable]) FIXE(copy);
  return AUTORELEASE(copy);
  }

- (NSArray*)subarrayWithRange:(NSRange)rg
  {
  if (rg.location + rg.length > _count) {
    MSReportError(MSInvalidArgumentError, MSFatalError, MSIndexOutOfRangeError,
      "%s: range %s out of range (0, %lu)",
      sel_getName(_cmd), [NSStringFromRange(rg) UTF8String], WLU(_count));
    return nil;}
  return AUTORELEASE((id)CCreateSubArrayWithRange((CArray*)self, rg));
  }

#pragma mark Access

- (MSArray*)microstepArray
  {
  return (MSArray*)self;
  }

- (id)lastObject
  {
  return CArrayLastObject((CArray*)self);
  }

- (NSEnumerator*)objectEnumerator
  {
  _MSArrayEnumerator *e= MSAllocateObject([_MSArrayEnumerator class],0,nil);
  [e initWithArray:self reverse:NO];
  return AUTORELEASE(e);
  }

- (NSEnumerator*)reverseObjectEnumerator
  {
  _MSArrayEnumerator *e= MSAllocateObject([_MSArrayEnumerator class],0,nil);
  [e initWithArray:self reverse:YES];
  return AUTORELEASE(e);
  }

- (void)getObjects:(id*)objects
  {
  GArrayGetObject(NULL, self, 0, _count, objects);
  }

- (void)getObjects:(id*)objects range:(NSRange)rg
  {
  NSUInteger n= GArrayGetObject(NULL, self, rg.location, rg.length, objects);
  if (n != rg.length) {
    MSReportError(MSInvalidArgumentError, MSFatalError, MSIndexOutOfRangeError,
      "%s: range %s out of range (0, %lu)",
      sel_getName(_cmd), [NSStringFromRange(rg) UTF8String], WLU(_count));}
  }

#pragma mark Search

- (BOOL)containsObject:(id)o
  {
  return CArrayIndexOfObject((CArray*)self, o, 0, _count) == NSNotFound ? NO : YES;
  }
- (BOOL)containsObjectIdenticalTo:(id)o
  {
  return CArrayIndexOfIdenticalObject((CArray*)self, o, 0, _count) == NSNotFound ? NO : YES;
  }

- (NSUInteger)indexOfObject:(id)o
  {
  return CArrayIndexOfObject((CArray*)self, o, 0, _count);
  }
- (NSUInteger)indexOfObject:(id)o inRange:(NSRange)range
  {
  return CArrayIndexOfObject((CArray*)self, o, range.location, range.length);
  }
- (NSUInteger)indexOfObjectIdenticalTo:(id)o
  {
  return CArrayIndexOfIdenticalObject((CArray*)self, o, 0, _count);
  }
- (NSUInteger)indexOfObjectIdenticalTo:(id)o inRange:(NSRange)rg
  {
  return CArrayIndexOfIdenticalObject((CArray*)self, o, rg.location, rg.length);
  }

// TODO: This is NOT the spec of NSArray method
- (id)firstObjectCommonWithArray:(NSArray*)a
  {
  if ([a _isMS]) return CArrayFirstCommonObject((CArray*)self, (CArray*)a);
  else {
    register NSUInteger count= MIN(_count, [a count]);
    if (count) {
      register NSUInteger i;
      for (i= 0; i < count; i++) {
        if ([_pointers[i] isEqual:[a objectAtIndex:i]]) return _pointers[i];}}}
  return nil;
  }

- (id)firstIdenticalObjectCommonWithArray:(NSArray*)a
  {
  if ([a _isMS]) return CArrayFirstCommonIdenticalObject((CArray*)self, (CArray*)a);
  else {
    register NSUInteger count= MIN(_count, [a count]);
    if (count) {
      register NSUInteger i;
      for (i= 0; i < count; i++) {
        if (_pointers[i] == [a objectAtIndex:i]) return _pointers[i];}}}
  return nil;
  }

- (NSString *)componentsJoinedByString:(NSString *)separator
{
  CString *ret; NSUInteger i= 0; SES ses;
  ret= CCreateString(0);
  ses= SESFromString(separator);
  if (i < _count)
    CStringAppendSES(ret, SESFromString([CArrayObjectAtIndex((CArray*)self, i++) description]));
  while (i < _count) {
    CStringAppendSES(ret, ses);
    CStringAppendSES(ret, SESFromString([CArrayObjectAtIndex((CArray*)self, i++) description]));}
  return AUTORELEASE(ret);
}
/*
- (NSString *)jsonRepresentation { return CArrayJsonRepresentation((CArray *)self); }
*/

- (NSString*)toString
  {return [self description];}
- (NSString*)description
{
  CString *s= CCreateString(0);
  CStringAppendGArrayDescription(s, NULL, self);
  return [(id)s autorelease];
}
- (NSString*)descriptionWithLocale:(NSDictionary*)locale
  {return [self description]; locale= NULL;}
- (NSString*)descriptionWithLocale:(NSDictionary*)locale indent:(NSUInteger)level
  {return [self description]; locale= NULL; level= 0;}

#pragma mark NSCoding protocol

- (Class)classForAchiver
  {return [self class];}
- (Class)classForCoder
  {return [self class];}
- (Class)classForPortCoder
  {return [self class];}
- (id)replacementObjectForPortCoder:(NSPortCoder*)encoder
  {
  if ([encoder isBycopy]) return self;
  return [super replacementObjectForPortCoder:encoder];
  }

- (void)encodeWithCoder:(NSCoder*)aCoder
  {
  BOOL immut=CGrowIsForeverImmutable(self), mut=CGrowIsForeverMutable(self), noRR= _flags.noRetainRelease, nilItems= _flags.nilItems;
  if ([aCoder allowsKeyedCoding]) {
    [aCoder  encodeUnsignedInteger:_size forKey:@"capacity"];
    if (immut) [aCoder encodeBool:YES forKey:@"immutable"];
    if (mut)   [aCoder encodeBool:YES forKey:@"mutable"];
    if (noRR)      [aCoder encodeBool:YES forKey:@"noRetainRelease"];
    if (nilItems)  [aCoder encodeBool:YES forKey:@"nilItems"];
    if (_pointers) {
      [aCoder encodeCArray:(CArray*)self forKey:@"ms-array"];}}
  else {
    [aCoder encodeValueOfObjCType:@encode(BOOL) at:&immut];
    [aCoder encodeValueOfObjCType:@encode(BOOL) at:&mut];
    [aCoder encodeValueOfObjCType:@encode(BOOL) at:&noRR];
    [aCoder encodeValueOfObjCType:@encode(BOOL) at:&nilItems];
    [aCoder encodeValueOfObjCType:@encode(NSUInteger) at:&_count];
    if (_count) {
      register NSUInteger i;
      for (i= 0; i < _count; i++) [aCoder encodeObject:_pointers[i]];}}
  }

- (id)initWithCoder:(NSCoder*)aCoder
  {
  BOOL immut= NO, mut=NO, noRR= NO,  nilItems= NO;
  if ([aCoder allowsKeyedCoding]) {
    immut= [aCoder decodeBoolForKey:@"immutable"];
    mut=   [aCoder decodeBoolForKey:@"mutable"];
    noRR=      [aCoder decodeBoolForKey:@"noRetainRelease"];
    nilItems=  [aCoder decodeBoolForKey:@"nilItems"];
    [aCoder decodeInCArray:(CArray*)self retainObjects:!_flags.noRetainRelease forKey:@"ms-array"];}
  else {
    NSUInteger n;
    [aCoder decodeValueOfObjCType:@encode(BOOL) at:&immut];
    [aCoder decodeValueOfObjCType:@encode(BOOL) at:&mut];
    [aCoder decodeValueOfObjCType:@encode(BOOL) at:&noRR];
    [aCoder decodeValueOfObjCType:@encode(BOOL) at:&nilItems];
    [aCoder decodeValueOfObjCType:@encode(NSUInteger) at:&n];
    if (n) {
      NSUInteger i;
      CArrayGrow((CArray*)self, n);
      for (i= 0; i < n; i++) {
        CArrayAddObject((CArray*)self, [aCoder decodeObject]);}}}
    if    (immut) CGrowSetForeverImmutable(self);
    else if (mut) CGrowSetForeverMutable(self);
    _flags.noRetainRelease= noRR;
    _flags.nilItems=        nilItems;
  return self;
  }

#pragma mark Mutability

/************************** TO DO IN THIS FILE  ****************
 
 (1)  an implementation for methods :
 
 - (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange;
 - (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray;
 
 - (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;
 - (void)removeObjectsAtIndexes:(NSIndexSet *)indexes AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;
 - (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;
 
 
 *************************************************************/

- (void)addObject:(id)anObject
{
  CArrayAddObject((CArray*)self, anObject);
}

- (void)addObjects:(const id*)objects count:(NSUInteger)n copyItems:(BOOL)copy
{
  CArrayAddObjects((CArray*)self, objects, n, copy);
}

- (void)addObjectsFromArray:(NSArray*)otherArray
{
  _addArray((CArray*)self, otherArray, NO);
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)i
{
  CArrayInsertObjectAtIndex((CArray*)self, anObject, i);
}

- (BOOL)conditionalAddObject:(id)anObject
{
  if (anObject && (!_count || CArrayIndexOfObject((CArray*)self, anObject, 0, _count) == NSNotFound)) {
    CArrayAddObject((CArray *)self, anObject);
    return YES;}
  return NO;
}

- (BOOL)conditionalAddObjectIdenticalTo:(id)anObject
{
  if (anObject && (!_count || CArrayIndexOfIdenticalObject((CArray *)self, anObject, 0, _count) == NSNotFound)) {
    CArrayAddObject((CArray *)self, anObject);
    return YES;}
  return NO;
}

- (void)replaceObjectAtIndex:(NSUInteger)i withObject:(id)anObject
{
  CArrayReplaceObjectAtIndex((CArray*)self, anObject, i);
}

- (void)replaceObjectsInRange:(NSRange)rg withObjects:(const id*)objects copyItems:(BOOL)copy
{
  CArrayReplaceObjectsInRange((CArray*)self, objects, rg, copy);
}

- (void)removeObject:(id)anObject
{
  CArrayRemoveObject((CArray*)self, anObject);
}

- (void)removeObjectAtIndex:(NSUInteger)i
{
  CArrayRemoveObjectAtIndex((CArray*)self, i);
}

- (void)removeObjectIdenticalTo:(id)anObject
{
  CArrayRemoveIdenticalObject((CArray*)self, anObject);
}

- (void)removeLastObject
{
  CArrayRemoveLastObject((CArray*)self);
}

- (void)removeObjectsInRange:(NSRange)range
{
  CArrayRemoveObjectsInRange((CArray*)self, range);
}

- (void)removeObjectsInArray:(NSArray*)otherArray
{
  if (otherArray == self) CArrayRemoveAllObjects((CArray*)self);
  else if ([otherArray _isMS]) {
    // TODO: hash optimisation in a CArray fct ?
    register NSUInteger i, count= [otherArray count];
    for (i= 0; i < count; i++) CArrayRemoveObject((CArray*)self, ((MSArray*)otherArray)->_pointers[i]);}
  else {
    register NSUInteger i, count= [otherArray count];
    for (i= 0; i < count; i++) CArrayRemoveObject((CArray*)self, [otherArray objectAtIndex:i]);}
}

- (void)removeAllObjects
{
  CArrayRemoveAllObjects((CArray*)self);
}

- (void)setArray:(NSArray *)otherArray
{
  if (otherArray != self) {
    CArrayRemoveAllObjects((CArray*)self);
    [self addObjectsFromArray:otherArray];}
}
/*
- (void)removeObjectsFromIndices:(NSUInteger *)indices numIndices:(NSUInteger)count
{
  if (indices && count) {
    while (count-- > 0) {
      CArrayRemoveObjectAtIndex((CArray *)self, indices[count]);}}
}
*/
- (void)sortUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context
{
  if (_count > 1 ) MSObjectSort(_pointers, _count, comparator, context);
}

static NSComparisonResult _internalCompareFunction2(id e1, id e2, void *selector)
  {
  return (*((NSComparisonResult(*)(id,SEL,id))objc_msgSend))(e1, (SEL)selector, e2);
  }
- (void)sortUsingSelector:(SEL)comparator
{
  if (_count > 1 ) MSObjectSort(_pointers, _count, _internalCompareFunction2, (void*)comparator);
}

@end

@implementation _MSArrayEnumerator
- (id)initWithArray:(NSArray*)a reverse:(BOOL)reverse
{
  garray_pfs_t pfs= [a _garray_pfs];
  _arrayEnumerator= GMakeArrayEnumerator(pfs, a, 0, GArrayCount(pfs, a));
  _reverse= reverse;
  RETAIN(_arrayEnumerator.array);
}

- (void)dealloc
{
  RELEASE(_arrayEnumerator.array);
  [super dealloc];
}

- (id)nextObject
{
  return _reverse ? GArrayEnumeratorPreviousObject(&_arrayEnumerator, NULL) :
                    GArrayEnumeratorNextObject(&_arrayEnumerator, NULL);
}
@end

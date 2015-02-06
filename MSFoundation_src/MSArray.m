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
#import <objc/objc-runtime.h>

#pragma mark Private

@interface NSArray (Private)
- (BOOL)_isMS;
@end

@interface MSArray (Private)
- (BOOL)_isMS;
@end

@interface _MSArrayEnumerator : NSEnumerator
{
@public
  CArray*    _array;
  NSUInteger _next;
}
@end

@interface _MSArrayReverseEnumerator : _MSArrayEnumerator
@end

@implementation NSArray (Private)
- (BOOL)_isMS {return NO;}
@end
@implementation MSArray (Private)
- (BOOL)_isMS {return YES;}
@end
@implementation _MSArrayEnumerator
- (id)nextObject {return _next < _array->count ? _array->pointers[_next++] : nil;}
- (void)dealloc  {RELEASE((id)_array); [super dealloc];}
@end
@implementation _MSArrayReverseEnumerator
- (id)nextObject {return _next > 0 ? _array->pointers[--_next] : nil;}
@end

#pragma mark Public

//***************************** TODO: IN THIS FILE *****************************
// (1)  a correct implementation of description... methods
// (2)  if possible (under cocotron for example) a better initWithCoder and encodeWithCoder method
//******************************************************************************

@implementation MSArray
+ (void)load{ MSFinishLoadingAddClass(self); }
#pragma mark alloc / init

#define FIXE(a) CArraySetImmutable((CArray*)a)

+ (id)allocWithZone:(NSZone*)zone {return MSAllocateObject(self, 0, zone);}
+ (id)alloc                       {return MSAllocateObject(self, 0, NULL);}
+ (id)new                         {return MSAllocateObject(self, 0, NULL);}

static inline id _array(Class cl, id a, BOOL m)
  {
  if (!a) a= AUTORELEASE(MSAllocateObject(cl, 0, NULL));
  if (!m) FIXE(a);
  return a;
  }
+ (id)array        {return _array(self, nil,  NO);}
+ (id)mutableArray {return _array(self, nil, YES);}
- (id)init         {return _array(nil ,self,  NO);}
- (id)mutableInit  {return _array(nil ,self, YES);}

static inline id _arrayWithObject(Class cl, id a, BOOL m, id o)
  {
  if (!a) a= AUTORELEASE(MSAllocateObject(cl, 0, NULL));
  CArrayAddObject((CArray*)a, o);
  if (!m) FIXE(a);
  return a;
  }
+ (id)arrayWithObject:       (id)o {return _arrayWithObject(self, nil,  NO, o);}
+ (id)mutableArrayWithObject:(id)o {return _arrayWithObject(self, nil, YES, o);}
- (id)initWithObject:        (id)o {return _arrayWithObject(nil ,self,  NO, o);}
- (id)mutableInitWithObject: (id)o {return _arrayWithObject(nil ,self, YES, o);}

static inline id _arrayOsNC(Class cl, id a, BOOL m, const id *os, NSUInteger n, BOOL copy)
  {
  if (!a) a= AUTORELEASE(MSAllocateObject(cl, 0, NULL));
  CArrayAddObjects((CArray*)a, os, n, copy);
  if (!m) FIXE(a);
  return a;
  }
+ (id)arrayWithObjects:       (const id*)os count:(NSUInteger)n {return _arrayOsNC(self, nil,  NO, os,n,NO);}
+ (id)mutableArrayWithObjects:(const id*)os count:(NSUInteger)n {return _arrayOsNC(self, nil, YES, os,n,NO);}
- (id)initWithObjects:        (const id*)os count:(NSUInteger)n {return _arrayOsNC(nil ,self,  NO, os,n,NO);}
- (id)mutableInitWithObjects: (const id*)os count:(NSUInteger)n {return _arrayOsNC(nil ,self, YES, os,n,NO);}

static inline id _arrayFoArgs(Class cl, id a, BOOL m, id o, va_list l)
  {
  if (!a) a= AUTORELEASE(MSAllocateObject(cl, 0, NULL));
  if (o) {
    CArrayAddObject((CArray*)a,o);
    while ((o= va_arg (l, id))) CArrayAddObject((CArray*)a,o);}
  if (!m) FIXE(a);
  return a;
  }
+ (id)arrayWithFirstObject:       (id)o arguments:(va_list)l {return _arrayFoArgs(self, nil,  NO, o,l);}
+ (id)mutableArrayWithFirstObject:(id)o arguments:(va_list)l {return _arrayFoArgs(self, nil, YES, o,l);}
- (id)initWithFirstObject:        (id)o arguments:(va_list)l {return _arrayFoArgs(nil ,self,  NO, o,l);}
- (id)mutableInitWithFirstObject: (id)o arguments:(va_list)l {return _arrayFoArgs(nil ,self, YES, o,l);}

#define _arrayOs(CL,A,M,O) \
  id ret; \
  va_list ap; \
  va_start(ap, O); \
  ret= _arrayFoArgs(CL,A,M, O,ap); \
  va_end(ap); \
  return ret

+ (id)arrayWithObjects:       (id)firstObject, ... {_arrayOs(self, nil,  NO, firstObject);}
+ (id)mutableArrayWithObjects:(id)firstObject, ... {_arrayOs(self, nil, YES, firstObject);}
- (id)initWithObjects:        (id)firstObject, ... {_arrayOs(nil ,self,  NO, firstObject);}
- (id)mutableInitWithObjects: (id)firstObject, ... {_arrayOs(nil ,self, YES, firstObject);}

static inline void _addArray(CArray *self, NSArray *a, BOOL copyItems)
  {
  if ([a _isMS]) CArrayAddArray(self, (CArray*)a, copyItems);
  else {
    id e,o;
    CArrayGrow(self, [a count]);
    for (e= [a objectEnumerator]; (o= [e nextObject]);) {
      CArrayAddObjects(self,&o,1,copyItems);}}
  }

static inline id _arrayA(Class cl, id a, BOOL m, id aa, BOOL copy)
  {
  if (!a) a= AUTORELEASE(MSAllocateObject(cl, 0, NULL));
  _addArray((CArray*)a, aa, copy);
  if (!m) FIXE(a);
  return a;
  }
+ (id)arrayWithArray:       (NSArray*)array {return _arrayA(self, nil,  NO, array, NO);}
+ (id)mutableArrayWithArray:(NSArray*)array {return _arrayA(self, nil, YES, array, NO);}
- (id)initWithArray:        (NSArray*)array {return _arrayA(nil ,self,  NO, array, NO);}
- (id)mutableInitWithArray: (NSArray*)array {return _arrayA(nil ,self, YES, array, NO);}


#pragma mark Other inits

- (id)initWithObjects:       (const id*)os count:(NSUInteger)n copyItems:(BOOL)c {return _arrayOsNC(nil ,self,  NO, os,n,c);}
- (id)mutableInitWithObjects:(const id*)os count:(NSUInteger)n copyItems:(BOOL)c {return _arrayOsNC(nil ,self, YES, os,n,c);}

- (id)initWithArray:       (NSArray*)array copyItems:(BOOL)copy {return _arrayA(nil ,self,  NO, array, copy);}
- (id)mutableInitWithArray:(NSArray*)array copyItems:(BOOL)copy {return _arrayA(nil ,self, YES, array, copy);}

- (id)mutableInitWithCapacity:(NSUInteger)capacity
  {
  return [self mutableInitWithCapacity:capacity  noRetainRelease:NO nilItems:NO];
  }
- (id)mutableInitWithCapacity:(NSUInteger)capacity noRetainRelease:(BOOL)noRR nilItems:(BOOL)nilItems
  {
  CArrayGrow((CArray*)self, capacity);
  self->_flags.noRetainRelease= noRR    ?1:0;
  self->_flags.nilItems=        nilItems?1:0;
  return self;
  }

// TODO: to be removed
- (id)initWithCapacity:(NSUInteger)capacity
  {
  return [self initWithCapacity:capacity  noRetainRelease:NO nilItems:NO];
  }
- (id)initWithCapacity:(NSUInteger)capacity noRetainRelease:(BOOL)noRR nilItems:(BOOL)nilItems
  {
  CArrayGrow((CArray*)self, capacity);
  self->_flags.noRetainRelease= noRR    ?1:0;
  self->_flags.nilItems=        nilItems?1:0;
  FIXE(self);
  return self;
  }

#pragma mark Standard methods

- (BOOL)isMutable    {return CArrayIsMutable((CArray*)self);}
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

// La copie ne préserve pas la mutablility TODO: à revoir ?
- (id)copyWithZone:(NSZone*)z
  {
  CArray *a= (CArray*)MSAllocateObject([self class], 0, z);
  return CArrayInitCopyWithMutability(a, (CArray*)self, NO);
  }
- (id)mutableCopyWithZone:(NSZone*)z
  {
  CArray *a= (CArray*)MSAllocateObject([self class], 0, z);
  return CArrayInitCopyWithMutability(a, (CArray*)self, YES);
  }

- (BOOL)isTrue
  {
  if (_count) {
    register NSUInteger i;
    for (i = 0; i < _count; i++) { if (![_pointers[i] isTrue]) return NO; }
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
  _MSArrayEnumerator *e= MSAllocateObject([_MSArrayEnumerator class],0,[self zone]);
  e->_array= (CArray*)RETAIN(self);
  return AUTORELEASE(e);
  }

- (NSEnumerator*)reverseObjectEnumerator
  {
  _MSArrayReverseEnumerator *e= MSAllocateObject([_MSArrayReverseEnumerator class],0,[self zone]);
  e->_array= (CArray*)RETAIN(self);
  e->_next= _count;
  return AUTORELEASE(e);
  }
- (void)getObjects:(id*)objects
  {
  if (objects && _count) memcpy(objects, _pointers, _count*sizeof(id));
  }

- (void)getObjects:(id*)objects range:(NSRange)rg
  {
  if (rg.location + rg.length > _count) {
    MSReportError(MSInvalidArgumentError, MSFatalError, MSIndexOutOfRangeError,
      "%s: range %s out of range (0, %lu)",
      sel_getName(_cmd), [NSStringFromRange(rg) UTF8String], WLU(_count));
    return;}
  if (objects && rg.length) memcpy(objects, _pointers+rg.location, rg.length*sizeof(id));
  }

#pragma mark Search

- (BOOL)containsObject:(id)o
  {
  return CArrayIndexOfObject((CArray*)self, o, 0, _count) == NSNotFound ? NO : YES;
  }
- (BOOL)containsIdenticalObject:(id)o
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

/* TODO:
- (NSString *)componentsJoinedByString:(NSString *)separator
{
  if (_count > 0) {
    if (_count > 1) {
      MSUnicodeString *s = MSCreateUnicodeString(128);
      NSUInteger i, slen = [separator length];
      if (!slen) {
        for (i = 0; i < _count; i++) { MSUAddString(s, [_pointers[i] toString]); }
        if (MSULength(s)) { return AUTORELEASE(s); }
        RELEASE(s);
      }
      else {
        MSUAddString(s, [_pointers[0] toString]);
        for (i = 1; i < _count; i++) {
          MSUAddString(s, separator);
          MSUAddString(s, [_pointers[i] toString]);
        }
        return AUTORELEASE(s); // can never be empty here
      }
    }
    else {
      NSString *ret = [_pointers[0] toString];
      if ([ret length]) return ret;
    }
  }
  return @"";
}
- (NSString *)jsonRepresentation { return CArrayJsonRepresentation((CArray *)self); }
*/

- (NSString*)toString                                                             {return [self description];}
- (NSString*)description                                                          {return [(id)CArrayRetainedDescription(self) autorelease];}
- (NSString*)descriptionWithLocale:(NSDictionary*)locale                          {return [self description]; locale= NULL;}
- (NSString*)descriptionWithLocale:(NSDictionary*)locale indent:(NSUInteger)level {return [self description]; locale= NULL; level= 0;}

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
  if ([aCoder allowsKeyedCoding]) {
    [aCoder  encodeUnsignedInteger:_size forKey:@"capacity"];
    if (_flags.fixed)           [aCoder encodeBool:YES forKey:@"fixed"];
    if (_flags.noRetainRelease) [aCoder encodeBool:YES forKey:@"noRetainRelease"];
    if (_flags.nilItems)        [aCoder encodeBool:YES forKey:@"nilItems"];
    if (_pointers) {
      [aCoder encodeCArray:(CArray*)self forKey:@"ms-array"];}}
  else {
    BOOL fixed=_flags.fixed, noRR= _flags.noRetainRelease, nilItems= _flags.nilItems;
    [aCoder encodeValueOfObjCType:@encode(BOOL) at:&fixed];
    [aCoder encodeValueOfObjCType:@encode(BOOL) at:&noRR];
    [aCoder encodeValueOfObjCType:@encode(BOOL) at:&nilItems];
    [aCoder encodeValueOfObjCType:@encode(NSUInteger) at:&_count];
    if (_count) {
      register NSUInteger i;
      for (i= 0; i < _count; i++) [aCoder encodeObject:_pointers[i]];}}
  }

- (id)initWithCoder:(NSCoder*)aCoder
  {
  if ([aCoder allowsKeyedCoding]) {
    _flags.noRetainRelease= (unsigned int)[aCoder decodeBoolForKey:@"fixed"];
    _flags.noRetainRelease= (unsigned int)[aCoder decodeBoolForKey:@"noRetainRelease"];
    _flags.nilItems=        (unsigned int)[aCoder decodeBoolForKey:@"nilItems"];
    [aCoder decodeInCArray:(CArray*)self retainObjects:!_flags.noRetainRelease forKey:@"ms-array"];}
  else {
    NSUInteger n;
    BOOL fixed= NO, noRR= NO,  nilItems= NO;
    [aCoder decodeValueOfObjCType:@encode(BOOL) at:&fixed];
    [aCoder decodeValueOfObjCType:@encode(BOOL) at:&noRR];
    [aCoder decodeValueOfObjCType:@encode(BOOL) at:&nilItems];
    [aCoder decodeValueOfObjCType:@encode(NSUInteger) at:&n];
    _flags.fixed=           NO;
    _flags.noRetainRelease= noRR    ?1:0;
    _flags.nilItems=        nilItems?1:0;
    if (n) {
      NSUInteger i;
      CArrayGrow((CArray*)self, n);
      for (i= 0; i < n; i++) {
        CArrayAddObject((CArray*)self, [aCoder decodeObject]);}}
    _flags.fixed=           fixed   ?1:0;}
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
  if (otherArray) {
    if ([otherArray _isMS]) {
      CArrayAddArray((CArray*)self, (CArray*)otherArray, NO);} // No copy
    else {
      NSUInteger i, n; id o;
      n= [otherArray count];
      CArrayGrow((CArray*)self, n);
      for (i= 0; i < n; i++) {
        o= [otherArray objectAtIndex:i]; // WE CAN OPTIMIZE THAT WITH LOOKUP
        CArrayAddObject((CArray*)self, o);}}}
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

/*   MSArray_.i
 
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

#pragma mark alloc / init

+ (id)allocWithZone:(NSZone*)zone {return MSAllocateObject(self, 0, zone);}
+ (id)alloc                       {return MSAllocateObject(self, 0, NULL);}
+ (id)new                         {return MSAllocateObject(self, 0, NULL);}
+ (id)array           {return AUTORELEASE(MSAllocateObject(self, 0, NULL));}
+ (id)arrayWithObject:(id)anObject
  {
  id a= MSAllocateObject(self, 0, NULL); // MSArray or MSMutableArray
  CArrayAddObject((CArray*)a, anObject);
  return AUTORELEASE(a);
  }
+ (id)arrayWithObjects:(const id*)objs count:(NSUInteger)n
  {
  id a= MSAllocateObject(self, 0, NULL);
  CArrayAddObjects((CArray*)a, objs, n, NO);
  return AUTORELEASE(a);
  }
+ (id)arrayWithFirstObject:(id)firstObject arguments:(va_list)ap
  {
  id a= MSAllocateObject(self, 0, NULL);
  return AUTORELEASE([a initWithFirstObject:firstObject arguments:ap]);
  }
+ (id)arrayWithObjects:(id)firstObject, ...
  {
  id ret;
  va_list ap;
  va_start(ap, firstObject);
  ret= [self arrayWithFirstObject:firstObject arguments:ap];
  va_end(ap);
  return ret;
  }
+ (id)arrayWithArray:(NSArray*)array
  {
  id a= MSAllocateObject(self, 0, NULL);
  return AUTORELEASE([a initWithArray:array copyItems:NO]);
  }

- (id)init
  {
  return self;
  }
- (id)initWithObject:(id)o
  {
  CArrayAddObject((CArray*)self,o);
  return self;
  }
- (id)initWithObjects:(const id*)objects count:(NSUInteger)n
  {
  return [self initWithObjects:objects count:n copyItems:NO];
  }

- (id)initWithObjects:(const id*)objects count:(NSUInteger)n copyItems:(BOOL)copy
  {
  CArrayAddObjects((CArray*)self, objects, n, copy);
  return self;
  }

- (id)initWithObjects:(id)firstObject, ...
  {
  va_list ap;
  va_start(ap, firstObject);
  self= [self initWithFirstObject:firstObject arguments:ap];
  va_end(ap);
  return self;
  }
- (id)initWithFirstObject:(id)o arguments:(va_list)ap
  {
  CArrayAddObject((CArray*)self,o);
  while ((o= va_arg (ap, id))) CArrayAddObject((CArray*)self,o);
  return self;
  }

- (id)initWithArray:(NSArray*)array
  {
  return [self initWithArray:array copyItems:NO];
  }

static inline void _addArray(CArray *self, NSArray *a, BOOL copyItems)
  {
  if ([a _isMS]) CArrayAddArray(self, (CArray*)a, copyItems);
  else {
    id e,o;
    CArrayGrow(self, [a count]);
    for (e= [a objectEnumerator]; (o= [e nextObject]);) {
      CArrayAddObjects(self,&o,1,copyItems);}}
  }
- (id)initWithArray:(NSArray*)array copyItems:(BOOL)copy
  {
  _addArray((CArray*)self, array, copy);
  return self;
  }

- (id)initWithCapacity:(NSUInteger)capacity
  {
  return [self initWithCapacity:capacity  noRetainRelease:NO nilItems:NO];
  }
- (id)initWithCapacity:(NSUInteger)capacity noRetainRelease:(BOOL)noRR nilItems:(BOOL)nilItems
  {
  CArrayGrow((CArray*)self, capacity);
  self->_flags.noRetainRelease= noRR    ?1:0;
  self->_flags.nilItems=        nilItems?1:0;
  return self;
  }
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

- (id)copyWithZone:(NSZone*)z // La copie n'est pas mutable TODO: à revoir ?
  {
  CArray *a= (CArray*)MSAllocateObject([MSArray class], 0, z);
  return CArrayInitCopy(a, (CArray*)self);
  }
- (id)mutableCopyWithZone:(NSZone*)z
  {
  CArray *a= (CArray*)MSAllocateObject([MSMutableArray class], 0, z);
  return CArrayInitCopy(a, (CArray*)self);
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
  NSArray *copy= COPY(self);
  CArrayAddObject((CArray*)copy, anObject);
  return AUTORELEASE(copy);
  }

- (NSArray*)arrayByAddingObjectsFromArray:(NSArray*)a
  {
  NSArray *copy= COPY(self);
  _addArray((CArray*)copy, a, NO);
  return AUTORELEASE(copy);
  }

- (NSArray*)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void*)context
  {
  NSArray *copy= COPY(self);
  if (_count > 1 ) {
    MSObjectSort(((CArray*)copy)->pointers, _count, comparator, context);}
  return AUTORELEASE(copy);
  }

static NSComparisonResult _internalCompareFunction(id e1, id e2, void *selector)
  {
  return (*((NSComparisonResult(*)(id,SEL,id))objc_msgSend))(e1, (SEL)selector, e2);
  }
- (NSArray*)sortedArrayUsingSelector:(SEL)comparator
  {
  NSArray *copy= COPY(self);
  if (_count > 1 ) {
    MSObjectSort(((CArray*)copy)->pointers, _count, _internalCompareFunction, (void*)comparator);}
  return AUTORELEASE(copy);
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
- (NSString*)toString {return (NSString*)CArrayToString((CArray*)self);}

- (NSString*)description                                                          {return [self toString];}
- (NSString*)descriptionWithLocale:(NSDictionary*)locale                          {return [self toString]; locale= NULL;}
- (NSString*)descriptionWithLocale:(NSDictionary*)locale indent:(NSUInteger)level {return [self toString]; locale= NULL; level= 0;}


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

- (NSArray*)subarrayWithRange:(NSRange)rg
  {
  if (rg.location + rg.length > _count) {
    MSReportError(MSInvalidArgumentError, MSFatalError, MSIndexOutOfRangeError,
      "%s: range %s out of range (0, %lu)",
      sel_getName(_cmd), [NSStringFromRange(rg) UTF8String], WLU(_count));
    return nil;}
  return AUTORELEASE((id)CCreateSubArrayWithRange((CArray*)self, rg));
  }

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
    if (_flags.noRetainRelease) [aCoder encodeBool:YES forKey:@"noRetainRelease"];
    if (_flags.nilItems)        [aCoder encodeBool:YES forKey:@"nilItems"];
    if (_pointers) {
      [aCoder encodeCArray:(CArray*)self forKey:@"ms-array"];}}
  else {
    BOOL noRR= _flags.noRetainRelease, nilItems= _flags.nilItems;
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
    _flags.noRetainRelease= (unsigned int)[aCoder decodeBoolForKey:@"noRetainRelease"];
    _flags.nilItems=        (unsigned int)[aCoder decodeBoolForKey:@"nilItems"];
    [aCoder decodeInCArray:(CArray*)self retainObjects:!_flags.noRetainRelease forKey:@"ms-array"];}
  else {
    NSUInteger n;
    BOOL noRR= NO,  nilItems= NO;
    [aCoder decodeValueOfObjCType:@encode(BOOL) at:&noRR];
    [aCoder decodeValueOfObjCType:@encode(BOOL) at:&nilItems];
    [aCoder decodeValueOfObjCType:@encode(NSUInteger) at:&n];
    _flags.noRetainRelease= noRR    ?1:0;
    _flags.nilItems=        nilItems?1:0;
    if (n) {
      NSUInteger i;
      CArrayGrow((CArray*)self, n);
      for (i= 0; i < n; i++) {
        CArrayAddObject((CArray*)self, [aCoder decodeObject]);}}}
  return self;
  }

/***************************** TODO: IN THIS FILE *****************************
 
 (1)  a correct implementation of description, descriptionWithLocale: and descriptionWithLocale:indent: method
 (2)  if possible (under cocotron for example) a better initWithCoder and encodeWithCoder method
 
 ******************************************************************************/

/*   MSArray.h

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

// Le principe est: l'array est mutable jusqu'au momment où il est rendu immutable,
// Pour parer toute ambiguïté, toutes les méthodes d'initialisation de classe ou
// d'instance existent en version immutable (array, init) et mutable ().

// Attention toutefois pour les méthodes de classe alloc et new.
// Sans initialisation, alloc retourne une instance mutable.
// Et de même pour new car la version mutable a plus de sens que l'immutable.
// (Donc new= alloc mutableInit)

// La seule logique aurait sans doute préféré que les init... standards soient les
// versions mutables mais c'est trop confusant avec l'existant. En effet, on aurait
// [MSArray array] pour la version mutable et quelque chose comme
// [MSArray immutableArray] pour la version statique.

// TODO: à revoir ? La copie ne préserve pas la mutablility.
// Donc la seule façon de copier avec la mutabilité est subarrayWithRange:.

@class NSPortCoder;

@interface MSArray : NSArray
{
@private
  CArrayFlags _flags;
  id*         _pointers;
  NSUInteger  _size;
  NSUInteger  _count;
}

// Attention, alloc et new retourne des instances mutables.
+ (id)new;

#pragma mark init

+ (id)array;
+ (id)arrayWithObject:(id)anObject;
+ (id)arrayWithObjects:(const id*)objs count:(NSUInteger)n;
+ (id)arrayWithFirstObject:(id)firstObject arguments:(va_list)ap;
+ (id)arrayWithObjects:(id)firstObject, ...;
// arrayWithArray:
// The returned array is immutable.
// The methode may be used to convert NSArray to MSArray.
+ (id)arrayWithArray:(NSArray*)array;

- (id)init;
- (id)initWithObject:(id)o;
- (id)initWithObjects:(const id*)objects count:(NSUInteger)n;
- (id)initWithObjects:(id)firstObject, ...;
- (id)initWithFirstObject:(id)o arguments:(va_list)ap;
- (id)initWithArray:(NSArray*)array;

#pragma mark mutable init

+ (id)mutableArray;
+ (id)mutableArrayWithObject:(id)anObject;
+ (id)mutableArrayWithObjects:(const id*)objs count:(NSUInteger)n;
+ (id)mutableArrayWithFirstObject:(id)firstObject arguments:(va_list)ap;
+ (id)mutableArrayWithObjects:(id)firstObject, ...;
// mutableArrayWithArray:
// The returned array is mutable.
// The methode may be used to convert NSArray to MSArray.
+ (id)mutableArrayWithArray:(NSArray*)array;

- (id)mutableInit;
- (id)mutableInitWithObject:(id)o;
- (id)mutableInitWithObjects:(const id*)objects count:(NSUInteger)n;
- (id)mutableInitWithObjects:(id)firstObject, ...;
- (id)mutableInitWithFirstObject:(id)o arguments:(va_list)ap;
- (id)mutableInitWithArray:(NSArray*)array;

#pragma mark Other inits

- (id)initWithObjects:(const id*)objects count:(NSUInteger)n copyItems:(BOOL)copy;
- (id)initWithArray:(NSArray*)array copyItems:(BOOL)copy;
- (id)mutableInitWithObjects:(const id*)objects count:(NSUInteger)n copyItems:(BOOL)copy;
- (id)mutableInitWithArray:(NSArray*)array copyItems:(BOOL)copy;

- (id)mutableInitWithCapacity:(NSUInteger)capacity;
- (id)mutableInitWithCapacity:(NSUInteger)cap noRetainRelease:(BOOL)noRR nilItems:(BOOL)nilItems;

#pragma mark Standard methods

- (BOOL)isMutable;
- (void)setImmutable;
- (NSUInteger)capacity;
- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)i;

#pragma mark Global methods

- (NSUInteger)hash:(unsigned)depth;
- (id)copyWithZone:(NSZone*)z;        // immutable copy ???
- (id)mutableCopyWithZone:(NSZone*)z; //   mutable copy
//- (id)immutableCopyWithZone:(NSZone*)z; //   ???
- (BOOL)isTrue; // YES if not emty and all the objects are true.
- (BOOL)isEqualToArray:(NSArray*)otherArray;
- (BOOL)isEqual:(id)object;

#pragma mark Common methods (fixed or mutable instance)

- (void)makeObjectsPerformSelector:(SEL)aSelector;
- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)o;
- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)o1 withObject:(id)o2;

// The mutability is preserved.
- (NSArray*)arrayByAddingObject:(id)anObject;
- (NSArray*)arrayByAddingObjectsFromArray:(NSArray*)a;
- (NSArray*)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void*)context;
- (NSArray*)sortedArrayUsingSelector:(SEL)comparator;
- (NSArray*)subarrayWithRange:(NSRange)rg;

#pragma mark Access

- (MSArray*)microstepArray; // TODO: usefull ???
- (id)lastObject;
- (NSEnumerator*)objectEnumerator;
- (NSEnumerator*)reverseObjectEnumerator;
- (void)getObjects:(id*)objects;
- (void)getObjects:(id*)objects range:(NSRange)rg;

#pragma mark Search

- (BOOL)containsObject:(id)o;
- (BOOL)containsObjectIdenticalTo:(id)o;
- (NSUInteger)indexOfObject:(id)o;
- (NSUInteger)indexOfObject:(id)o inRange:(NSRange)range;
- (NSUInteger)indexOfObjectIdenticalTo:(id)o;
- (NSUInteger)indexOfObjectIdenticalTo:(id)o inRange:(NSRange)rg;

// TODO: The actual implementation does not respond to the spec of the NSArray method.
- (id)firstObjectCommonWithArray:(NSArray*)a;
- (id)firstIdenticalObjectCommonWithArray:(NSArray*)a;

#pragma mark Description

- (NSString*)toString;
- (NSString*)description;
- (NSString*)descriptionWithLocale:(NSDictionary*)locale;
- (NSString*)descriptionWithLocale:(NSDictionary*)locale indent:(NSUInteger)level;

#pragma mark NSCoding protocol

- (Class)classForAchiver;
- (Class)classForCoder;
- (Class)classForPortCoder;
- (id)replacementObjectForPortCoder:(NSPortCoder*)encoder;
- (void)encodeWithCoder:(NSCoder*)aCoder;
- (id)initWithCoder:(NSCoder*)aCoder;

#pragma mark Mutability

/************************** TO DO IN THIS FILE  ****************

 (1)  an implementation for methods :

 - (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange;
 - (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray;

 - (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;
 - (void)removeObjectsAtIndexes:(NSIndexSet *)indexes AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;
 - (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;


 *************************************************************/

- (void)addObject:(id)anObject;
- (void)addObjects:(const id*)objects count:(NSUInteger)n copyItems:(BOOL)copy;
- (void)addObjectsFromArray:(NSArray*)otherArray;

- (void)insertObject:(id)anObject atIndex:(NSUInteger)i;

- (BOOL)conditionalAddObject:(id)anObject;
- (BOOL)conditionalAddObjectIdenticalTo:(id)anObject;

- (void)replaceObjectAtIndex:(NSUInteger)i withObject:(id)anObject;
- (void)replaceObjectsInRange:(NSRange)rg withObjects:(const id*)objects copyItems:(BOOL)copy;

- (void)removeObject:(id)anObject;
- (void)removeObjectAtIndex:(NSUInteger)i;
- (void)removeObjectIdenticalTo:(id)anObject;
- (void)removeLastObject;

- (void)removeObjectsInRange:(NSRange)range;
- (void)removeObjectsInArray:(NSArray*)otherArray;
- (void)removeAllObjects;

- (void)setArray:(NSArray *)otherArray;
/*
- (void)removeObjectsFromIndices:(NSUInteger *)indices numIndices:(NSUInteger)count;
*/

- (void)sortUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context;
- (void)sortUsingSelector:(SEL)comparator;

@end

// TODO: To be removed
#define MSCreateArray(C) (MSArray*)CCreateArray(C)
//MSMutableArray *MSCreateMutableArray(NSUInteger capacity);

@interface NSArrayEnumerator : NSEnumerator
{
@private
  GArrayEnumerator _arrayEnumerator;
  BOOL _reverse;
}
- (id)initWithArray:(NSArray*)a reverse:(BOOL)reverse;
- (id)initWithArray:(NSArray*)a pfs:(garray_pfs_t)pfs count:(NSUInteger)c reverse:(BOOL)reverse;
- (id)nextObject;
@end
@interface MSArrayEnumerator : NSArrayEnumerator
{
}
@end

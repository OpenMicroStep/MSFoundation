/*   MSDictionary.h
 
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


@class MSDictionary;
@interface MSDictionaryEnumerator : NSEnumerator
{
@private
  CDictionaryEnumerator *_dictionaryEnumerator;
  BOOL _forKeys;
}
- (id)initWithDictionary:(MSDictionary*)d forKeys:(BOOL)forKeys;
- (id)nextObject;
- (id)nextKey;
- (id)currentObject;
- (id)currentKey;
@end

@interface MSDictionary : NSObject
{
@private
  void **_buckets;
  NSUInteger _nBuckets;
  NSUInteger _count;
  CGrowFlags _flag;
}

// Attention, alloc et new retourne des instances mutables.
+ (id)allocWithZone:(NSZone*)zone;
+ (id)alloc;
+ (id)new;

#if WIN32
#define COPY_PT
#else
#define COPY_PT <NSCopying>
#endif

#pragma mark init

+ (id)dictionary;
+ (id)dictionaryWithObject:(id)o forKey:(id <NSCopying>)k;
+ (id)dictionaryWithKey:(id <NSCopying>)k andObject:(id)o;
+ (id)dictionaryWithObjects:(const id [])os forKeys:(const id COPY_PT [])ks count:(NSUInteger)n;
+ (id)dictionaryWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
+ (id)dictionaryWithKeysAndObjects:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

- (id)init;
- (id)initWithObject:(id)o forKey:(id <NSCopying>)k;
- (id)initWithKey:(id <NSCopying>)k andObject:(id)o;
- (id)initWithObjects:(const id [])os forKeys:(const id COPY_PT [])ks count:(NSUInteger)n;
- (id)initWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initWithKeysAndObjects:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark mutable init

+ (id)mutableDictionary;
+ (id)mutableDictionaryWithObject:(id)o forKey:(id <NSCopying>)k;
+ (id)mutableDictionaryWithKey:(id <NSCopying>)k andObject:(id)o;
+ (id)mutableDictionaryWithObjects:(const id [])os forKeys:(const id COPY_PT [])ks count:(NSUInteger)n;
+ (id)mutableDictionaryWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
+ (id)mutableDictionaryWithKeysAndObjects:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

- (id)mutableInit;
- (id)mutableInitWithObject:(id)o forKey:(id <NSCopying>)k;
- (id)mutableInitWithKey:(id <NSCopying>)k andObject:(id)o;
- (id)mutableInitWithObjects:(const id [])os forKeys:(const id COPY_PT [])ks count:(NSUInteger)n;
- (id)mutableInitWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
- (id)mutableInitWithKeysAndObjects:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark Other inits 

+ (id)dictionaryWithDictionary:(id)otherDictionary;
+ (id)mutableDictionaryWithDictionary:(id)otherDictionary;
- (id)initWithDictionary:(id)otherDictionary;
- (id)mutableInitWithDictionary:(id)otherDictionary;

+ (id)dictionaryWithDictionary:(id)otherDictionary copyItems:(BOOL)flag;
+ (id)mutableDictionaryWithDictionary:(id)otherDictionary copyItems:(BOOL)flag;
- (id)initWithDictionary:(id)otherDictionary copyItems:(BOOL)flag;
- (id)mutableInitWithDictionary:(id)otherDictionary copyItems:(BOOL)flag;

#pragma mark Standard methods

- (BOOL)isMutable;
- (void)setImmutable;
- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (id)objectForLazyKey: (id)aKey;
- (id)objectForLazyKeys:(id)aKey, ...; // nil terminated

- (MSArray*)allKeys;
- (MSArray*)allObjects;

//- (BOOL)isEqualToDictionary:(NSDictionary*)otherDict; // ???

- (MSDictionaryEnumerator*)dictionaryEnumerator;

#pragma mark Mutability

+ (id)mutableDictionaryWithCapacity:(NSUInteger)numItems;
- (id)mutableInitWithCapacity:(NSUInteger)numItems;

- (void)removeObjectForKey:(id)aKey;
- (void)removeObjectsForKeys:(NSArray *)keyArray;
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;
// set the object to the lowercase aKey.
// TODO: Good ? If no aKey, remove the object to the lowercase aKey.
- (void)setObject:(id)anObject forLazyKey:(id <NSCopying>)aKey;
@end

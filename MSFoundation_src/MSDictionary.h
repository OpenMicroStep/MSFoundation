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

@interface NSDictionary (MSAddendum)
- (id)objectForLazyKey: (id)aKey;
- (id)objectForLazyKeys:(id)aKey, ...; // nil terminated
@end

@interface NSMutableDictionary (MSAddendum)
- (void)setObject:(id)anObject forLazyKey:(id <NSCopying>)aKey;
  // set the object to the lowercase aKey.
  // TODO: Good ? If no aKey, remove the object to the lowercase aKey.
@end

@class MSDictionary;
@interface MSDictionaryEnumerator : NSEnumerator
{
@private
  CDictionaryEnumerator *_dictionaryEnumerator;
}
- (id)initWithDictionary:(MSDictionary*)d;
- (id)nextObject;
- (id)nextKey;
- (id)currentObject;
- (id)currentKey;
@end

@interface MSDictionary : NSDictionary
{
@private
  NSUInteger _count;
  NSUInteger _nBuckets;
  void **_buckets;
}
+ (id)dictionary;
- (id)init;
+ (id)dictionaryWithObject:(id)object forKey:(id <NSCopying>)key;
- (id)      initWithObject:(id)object forKey:(id <NSCopying>)key;
+ (id)dictionaryWithKey:(id <NSCopying>)k andObject:(id)o;
- (id)      initWithKey:(id <NSCopying>)k andObject:(id)o;
#if WIN32
+ (id)dictionaryWithObjects:(const id [])objects forKeys:(const id [])keys count:(NSUInteger)cnt;
- (id)      initWithObjects:(const id [])objects forKeys:(const id [])keys count:(NSUInteger)cnt;
#else
+ (id)dictionaryWithObjects:(const id [])os forKeys:(const id <NSCopying> [])ks count:(NSUInteger)n;
- (id)      initWithObjects:(const id [])os forKeys:(const id <NSCopying> [])ks count:(NSUInteger)n;
#endif
+ (id)dictionaryWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
- (id)      initWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
+ (id)dictionaryWithKeysAndObjects:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;
- (id)      initWithKeysAndObjects:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

- (id)initWithDictionary:(NSDictionary*)otherDictionary copyItems:(BOOL)flag;

- (NSUInteger)count;
- (id)objectForKey:(id)aKey;

- (MSArray*)allKeys;
- (MSArray*)allObjects;

//- (BOOL)isEqualToDictionary:(NSDictionary*)otherDict; // ???

- (MSDictionaryEnumerator*)dictionaryEnumerator;
@end

@interface MSMutableDictionary : MSDictionary
{
@private
}
+ (id)dictionaryWithCapacity:(NSUInteger)numItems;
- (id)initWithCapacity:(NSUInteger)numItems;

- (void)removeObjectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;
@end

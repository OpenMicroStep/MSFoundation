 /*   MSDictionary.m
 
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

@interface MSDictionary (Private)
- (BOOL)_isMS;
- (gdict_pfs_t)_gdict_pfs;
@end

static NSUInteger _NSDictionary_count(id o) { return [o count]; }
static id _NSDictionary_objectForKey(id dict, id k) {return [dict objectForKey:k];}
static id _NSDictionary_keyEnumerator(id dict){ return [dict keyEnumerator]; }
static id _NSDictionary_nextKey(id enumerator) { return [enumerator nextObject]; }
static const struct gdict_pfs_s GNSDictPfs = {
  .count= _NSDictionary_count,
  .objectForKey= _NSDictionary_objectForKey,
  .keyEnumerator= _NSDictionary_keyEnumerator,
  .nextKey= _NSDictionary_nextKey
};

@implementation NSDictionary (Private)
- (gdict_pfs_t)_gdict_pfs { return &GNSDictPfs;}
- (BOOL)_isMS {return NO;}
@end

@implementation MSDictionary (Private)
- (BOOL)_isMS {return YES;}
- (gdict_pfs_t)_gdict_pfs { return NULL; }
@end

#pragma mark Public
@implementation MSDictionaryEnumerator
- (id)initWithDictionary:(MSDictionary*)d forKeys:(BOOL)forKeys
{
  _dictionaryEnumerator= CMakeDictionaryEnumerator((CDictionary*)d);
  RETAIN(_dictionaryEnumerator.dictionary);
  _forKeys= forKeys;
  return self;
}
- (void)dealloc
{
  RELEASE(_dictionaryEnumerator.dictionary);
  [super dealloc];
}
- (id)nextObject    {return _forKeys?
                            CDictionaryEnumeratorNextKey      (&_dictionaryEnumerator):
                            CDictionaryEnumeratorNextObject   (&_dictionaryEnumerator);}
- (id)nextKey       {return CDictionaryEnumeratorNextKey      (&_dictionaryEnumerator);}
- (id)currentObject {return CDictionaryEnumeratorCurrentObject( _dictionaryEnumerator);}
- (id)currentKey    {return CDictionaryEnumeratorCurrentKey   ( _dictionaryEnumerator);}
@end

#define MS_DICTIONARY_LAST_VERSION 101

@implementation MSDictionary
+ (void)load          {MSFinishLoadingDec();}
+ (void)initialize {[MSDictionary setVersion:MS_DICTIONARY_LAST_VERSION];}

#pragma mark alloc / init

#define FIXE(X) CGrowSetForeverImmutable((id)X)

+ (id)new                         {return ALLOC(self);}

static inline id _dict(Class cl, id d, BOOL m)
  {
  if (!d) d= AUTORELEASE(ALLOC(cl));
  if (!m) FIXE(d);
  return d;
  }
+ (id)dictionary        {return _dict(self, nil,  NO);}
+ (id)mutableDictionary {return _dict(self, nil, YES);}
- (id)init              {return _dict(nil ,self,  NO);}
- (id)mutableInit       {return _dict(nil ,self, YES);}

static inline id _dictWithObject(Class cl, id d, BOOL m, id o, id k)
  {
  if (!d) d= AUTORELEASE(ALLOC(cl));
  CDictionarySetObjectForKey((CDictionary*)d, o, k);
  if (!m) FIXE(d);
  return d;
  }
+ (id)dictionaryWithObject:       (id)o forKey:(id <NSCopying>)k {return _dictWithObject(self, nil,  NO, o, k);}
+ (id)mutableDictionaryWithObject:(id)o forKey:(id <NSCopying>)k {return _dictWithObject(self, nil, YES, o, k);}
- (id)initWithObject:             (id)o forKey:(id <NSCopying>)k {return _dictWithObject(nil ,self,  NO, o, k);}
- (id)mutableInitWithObject:      (id)o forKey:(id <NSCopying>)k {return _dictWithObject(nil ,self, YES, o, k);}

+ (id)dictionaryWithKey:       (id <NSCopying>)k andObject:(id)o {return _dictWithObject(self, nil,  NO, o, k);}
+ (id)mutableDictionaryWithKey:(id <NSCopying>)k andObject:(id)o {return _dictWithObject(self, nil, YES, o, k);}
- (id)initWithKey:             (id <NSCopying>)k andObject:(id)o {return _dictWithObject(nil ,self,  NO, o, k);}
- (id)mutableInitWithKey:      (id <NSCopying>)k andObject:(id)o {return _dictWithObject(nil ,self, YES, o, k);}

static inline id _dictWithOsKsN(Class cl, id d, BOOL m, const id* os, const id COPY_PT *ks, NSUInteger n)
  {
  NSUInteger i;
  if (!d) d= AUTORELEASE(ALLOC(cl));
  CDictionaryGrow((CDictionary*)d, n);
  for (i= 0; i<n; i++) {
    CDictionarySetObjectForKey((CDictionary*)d,os[i],ks[i]);}
  if (!m) FIXE(d);
  return d;
  }
+ (id)dictionaryWithObjects:       (const id [])os forKeys:(const id COPY_PT [])ks count:(NSUInteger)n {return _dictWithOsKsN(self, nil,  NO, os, ks, n);}
+ (id)mutableDictionaryWithObjects:(const id [])os forKeys:(const id COPY_PT [])ks count:(NSUInteger)n {return _dictWithOsKsN(self, nil, YES, os, ks, n);}
- (id)initWithObjects:             (const id [])os forKeys:(const id COPY_PT [])ks count:(NSUInteger)n {return _dictWithOsKsN(nil, self,  NO, os, ks, n);}
- (id)mutableInitWithObjects:      (const id [])os forKeys:(const id COPY_PT [])ks count:(NSUInteger)n {return _dictWithOsKsN(nil, self, YES, os, ks, n);}

static inline id _dictWithArgs(Class cl, id d, BOOL m, BOOL kFirst, id a, va_list l)
  {
  id b;
  if (!d) d= AUTORELEASE(ALLOC(cl));
  if (a) while ((b= va_arg (l, id))) {
    if (a==nil) {a= b;}
    else {
      CDictionarySetObjectForKey((CDictionary*)d, kFirst?b:a, kFirst?a:b);
      a= nil;}}
  if (!m) FIXE(d);
  return d;
  }
#define _dictOs(CL,D,M,KFIRST,X) \
  id ret; \
  va_list ap; \
  va_start(ap, X); \
  ret= _dictWithArgs(CL,D,M, KFIRST,X,ap); \
  va_end(ap); \
  return ret

+ (id)dictionaryWithObjectsAndKeys:       (id)o, ... {_dictOs(self, nil,  NO,  NO, o);}
+ (id)mutableDictionaryWithObjectsAndKeys:(id)o, ... {_dictOs(self, nil, YES,  NO, o);}
- (id)initWithObjectsAndKeys:             (id)o, ... {_dictOs(nil ,self,  NO,  NO, o);}
- (id)mutableInitWithObjectsAndKeys:      (id)o, ... {_dictOs(nil ,self, YES,  NO, o);}

+ (id)dictionaryWithKeysAndObjects:       (id)k, ... {_dictOs(self, nil,  NO, YES, k);}
+ (id)mutableDictionaryWithKeysAndObjects:(id)k, ... {_dictOs(self, nil, YES, YES, k);}
- (id)initWithKeysAndObjects:             (id)k, ... {_dictOs(nil ,self,  NO, YES, k);}
- (id)mutableInitWithKeysAndObjects:      (id)k, ... {_dictOs(nil ,self, YES, YES, k);}

static inline id _dictWithOsKs(Class cl, id d, BOOL m, NSArray *objects, NSArray *keys)
{
  NSUInteger n;
  if (!d) d= AUTORELEASE(ALLOC(cl));
  n= MIN([objects count], [keys count]);
  CDictionaryGrow((CDictionary*)d, n);
  while (n > 0) {
    --n;
    CDictionarySetObjectForKey((CDictionary*)d, [objects objectAtIndex:n], [keys objectAtIndex:n]); }
  if (!m) FIXE(d);
  return d;
}
+ (id)dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys        { return _dictWithOsKs(self, nil,  NO, objects, keys); }
+ (id)mutableDictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys { return _dictWithOsKs(self, nil, YES, objects, keys); }
- (id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys              { return _dictWithOsKs(nil ,self,  NO, objects, keys); }
- (id)mutableInitWithObjects:(NSArray *)objects forKeys:(NSArray *)keys       { return _dictWithOsKs(nil ,self, YES, objects, keys); }

#pragma mark Other inits

static inline id _dictWithDictCpy(Class cl, id d, BOOL m, id src, BOOL cpy)
{
  if (!d) d= AUTORELEASE(ALLOC(cl));
  if ([src isKindOfClass:[MSDictionary class]]) {
    d= CDictionaryInitCopy((CDictionary*)d, (CDictionary*)src, cpy);}
  else if ([src respondsToSelector:@selector(keyEnumerator)]) {
    id ke,k,o;
    CDictionaryGrow((CDictionary*)d, [src count]);
    for (ke= [(NSDictionary*)src keyEnumerator]; (k= [ke nextObject]);) {
      if ((o= [(NSDictionary*)src objectForKey:k]) && cpy) o= COPY(o);
      if (o) CDictionarySetObjectForKey((CDictionary*)d,o,k);
      if (cpy) RELEASE(o);}}
  if (!m) FIXE(d);
  return d;
}
+ (id)dictionaryWithDictionary:       (id)src {return _dictWithDictCpy(self, nil,  NO, src, NO);}
+ (id)mutableDictionaryWithDictionary:(id)src {return _dictWithDictCpy(self, nil, YES, src, NO);}
- (id)initWithDictionary:             (id)src {return _dictWithDictCpy(nil ,self,  NO, src, NO);}
- (id)mutableInitWithDictionary:      (id)src {return _dictWithDictCpy(nil ,self, YES, src, NO);}
+ (id)dictionaryWithDictionary:       (id)src copyItems:(BOOL)cpy {return _dictWithDictCpy(self, nil,  NO, src, cpy);}
+ (id)mutableDictionaryWithDictionary:(id)src copyItems:(BOOL)cpy {return _dictWithDictCpy(self, nil, YES, src, cpy);}
- (id)initWithDictionary:             (id)src copyItems:(BOOL)cpy {return _dictWithDictCpy(nil ,self,  NO, src, cpy);}
- (id)mutableInitWithDictionary:      (id)src copyItems:(BOOL)cpy {return _dictWithDictCpy(nil ,self, YES, src, cpy);}

- (void)dealloc
  {
  CDictionaryFreeInside(self);
  [super dealloc];
  }

#pragma mark Primitives

- (BOOL)isMutable    {return !CGrowIsForeverImmutable(self);}
- (void)setImmutable {FIXE(self);}

- (NSUInteger)count {return CDictionaryCount((CDictionary*)self);}

- (id)objectForKey:(id)k
  {
  return CDictionaryObjectForKey((CDictionary*)self, k);
  }

- (MSDictionaryEnumerator*)dictionaryEnumerator
{
  return [[[MSDictionaryEnumerator alloc] initWithDictionary:self forKeys:NO] autorelease];
}
- (MSDictionaryEnumerator*)objectEnumerator
{
  return [[[MSDictionaryEnumerator alloc] initWithDictionary:self forKeys:NO] autorelease];
}
- (MSDictionaryEnumerator*)keyEnumerator
{
  return [[[MSDictionaryEnumerator alloc] initWithDictionary:self forKeys:YES] autorelease];
}

- (MSArray*)allKeys
{
  return AUTORELEASE((id)CCreateArrayOfDictionaryKeys((CDictionary*)self));
}
- (MSArray*)allObjects
{
  return AUTORELEASE((id)CCreateArrayOfDictionaryObjects((CDictionary*)self));
}
- (NSArray*)allValues
{
  return AUTORELEASE((id)CCreateArrayOfDictionaryObjects((CDictionary*)self));
}


#pragma mark Global methods

- (NSUInteger)hash:(unsigned)depth {return CDictionaryHash(self, depth);}

- (NSString*)description   {return [(id)CDictionaryRetainedDescription(self) autorelease];}

- (id)copyWithZone:(NSZone*)z
{return MSGrowCopyWithZone(z,self, NO,(MSGrowInitCopyMethod)CDictionaryInitCopyWithMutability);}
- (id)mutableCopyWithZone:(NSZone*)z
{return MSGrowCopyWithZone(z,self,YES,(MSGrowInitCopyMethod)CDictionaryInitCopyWithMutability);}

- (MSArray*)retainedSubs:(MSDictionary*)ctx
{
  return (MSArray*)CCreateArrayOfDictionarySubs(self, (CDictionary*)ctx);
}
- (void)describeIn:(id)result level:(int)level context:(MSDictionary*)ctx
{
  CDictionaryDescribe(self, result, level, (CDictionary*)ctx);
}

- (BOOL)isEqualToDictionary:(NSDictionary*)otherDict
{
  return GDictionaryEquals([self _gdict_pfs], self, [otherDict _gdict_pfs], otherDict);
}

#pragma mark Mutability

+ (id)mutableDictionaryWithCapacity:(NSUInteger)numItems
  {
  id d= AUTORELEASE(MSAllocateObject(self, 0, NULL));
  CDictionaryGrow((CDictionary*)d, numItems);
  return AUTORELEASE(d);
  }

- (id)mutableInitWithCapacity:(NSUInteger)numItems
  {
  CDictionaryGrow((CDictionary*)self, numItems);
  return self;
  }

- (void)removeObjectForKey:(id)k
{
  CDictionarySetObjectForKey((CDictionary*)self, nil, k);
}

- (void)removeObjectsForKeys:(NSArray *)keyArray
{
  NSUInteger i, count;
  garray_pfs_t pfs= [keyArray _garray_pfs];
  for(i= 0, count= GArrayCount(pfs, keyArray); i < count; ++i)
    CDictionarySetObjectForKey((CDictionary*)self, nil, GArrayObjectAtIndex(pfs, keyArray, i));
}

- (void)removeAllObjects
{
  [self removeObjectsForKeys:[self allKeys]];
}

- (void)setObject:(id)o forKey:(id <NSCopying>)k
{
  if (o && k) CDictionarySetObjectForKey((CDictionary*)self, o, k);
}

#pragma mark Lazy keys

- (void)setObject:(id)o forLazyKey:(id)k
{
  if (k) k= [[k toString] lowercaseString];
  if ([k length]) {
    if (o) [self setObject:o forKey:k];
    else [self removeObjectForKey:k];}
}

- (id)objectForLazyKey:(id)aKey
{
  id o= nil;
  if (aKey) {
    o= [self objectForKey:aKey];
    if (!o) {
      if (![aKey isKindOfClass:[NSString class]]) {
        aKey= [aKey toString];
        o= [self objectForKey:aKey];}
      if (!o && [aKey length]) o= [self objectForKey:[aKey lowercaseString]];}}
  return o;
}

- (id)objectForLazyKeys:(id)aKey, ...
{
  id ret= nil;
  if (aKey && !(ret= [self objectForLazyKey:aKey])) {
    va_list args; id k= aKey;
    va_start(args, aKey);
    while (!ret && (k= va_arg(args, id))) {
      ret= [self objectForLazyKey:k];}
    va_end(args);}
  return ret;
}

@end

@implementation NSDictionary (LazyKeys)

- (id)objectForLazyKey:(id)aKey
{
  id o= nil;
  if (aKey) {
    o= [self objectForKey:aKey];
    if (!o) {
      if (![aKey isKindOfClass:[NSString class]]) {
        aKey= [aKey toString];
        o= [self objectForKey:aKey];}
      if (!o && [aKey length]) o= [self objectForKey:[aKey lowercaseString]];}}
  return o;
}

- (id)objectForLazyKeys:(id)aKey, ...
{
  id ret= nil;
  if (aKey && !(ret= [self objectForLazyKey:aKey])) {
    va_list args; id k= aKey;
    va_start(args, aKey);
    while (!ret && (k= va_arg(args, id))) {
      ret= [self objectForLazyKey:k];}
    va_end(args);}
  return ret;
}

@end

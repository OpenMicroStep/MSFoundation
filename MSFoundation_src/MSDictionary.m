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

@implementation NSDictionary (MSAddendum)
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

@implementation NSMutableDictionary (MSAddendum)
- (void)setObject:(id)o forLazyKey:(id)k
{
	if (k) k= [[k toString] lowercaseString];
	if ([k length]) {
		if (o) [self setObject:o forKey:k];
		else [self removeObjectForKey:k];}
}
@end

@implementation MSDictionaryEnumerator
- (id)initWithDictionary:(MSDictionary*)d forKeys:(BOOL)forKeys
{
  _dictionaryEnumerator= CDictionaryEnumeratorAlloc((CDictionary*)d);
  _forKeys= forKeys;
  return self;
}
- (void)dealloc
{
  CDictionaryEnumeratorFree(_dictionaryEnumerator);
  [super dealloc];
}
- (id)nextObject    {return _forKeys?
                            CDictionaryEnumeratorNextKey      (_dictionaryEnumerator):
                            CDictionaryEnumeratorNextObject   (_dictionaryEnumerator);}
- (id)nextKey       {return CDictionaryEnumeratorNextKey      (_dictionaryEnumerator);}
- (id)currentObject {return CDictionaryEnumeratorCurrentObject(_dictionaryEnumerator);}
- (id)currentKey    {return CDictionaryEnumeratorCurrentKey   (_dictionaryEnumerator);}
@end

@implementation MSDictionary

#pragma mark alloc / init

+ (id)allocWithZone:(NSZone*)zone {return MSAllocateObject(self, 0, zone);}
+ (id)alloc                       {return MSAllocateObject(self, 0, NULL);}
+ (id)new                         {return MSAllocateObject(self, 0, NULL);}
+ (id)dictionary     {return AUTORELEASE(MSAllocateObject(self, 0, NULL));}
+ (id)dictionaryWithObject:(id)object forKey:(id <NSCopying>)key
  {
  id d= MSAllocateObject(self, 0, NULL); // self may be a MSMutableDictionary
  CDictionarySetObjectForKey((CDictionary*)d, object, key);
  return AUTORELEASE(d);
  }
+ (id)dictionaryWithKey:(id <NSCopying>)k andObject:(id)o
  {
  id d= MSAllocateObject(self, 0, NULL); // self may be a MSMutableDictionary
  CDictionarySetObjectForKey((CDictionary*)d, o, k);
  return AUTORELEASE(d);
  }

#if WIN32
+ (id)dictionaryWithObjects:(const id [])os forKeys:(const id             [])ks count:(NSUInteger)n
#else
+ (id)dictionaryWithObjects:(const id [])os forKeys:(const id <NSCopying> [])ks count:(NSUInteger)n
#endif
  {
  id d= MSAllocateObject(self, 0, NULL);
  return AUTORELEASE([d initWithObjects:os forKeys:ks count:n]);
  }
- (id)_initWithFirstObject:(id)o arguments:(va_list)ap
  {
  id k;
  if (o) while ((k= va_arg (ap, id))) {
    if (o==nil) {o= k;}
    else {
      CDictionarySetObjectForKey((CDictionary*)self, o, k);
      o= nil;}}
  return self;
  }
- (id)_initWithFirstKey:(id)k arguments:(va_list)ap
  {
  id o;
  if (k) while ((o= va_arg (ap, id))) {
    if (k==nil) {k= o;}
    else {
      CDictionarySetObjectForKey((CDictionary*)self, o, k);
      k= nil;}}
  return self;
  }
+ (id)dictionaryWithObjectsAndKeys:(id)firstObject, ...
  {
  id d= MSAllocateObject(self, 0, NULL);
  va_list ap;
  va_start(ap, firstObject);
  d= [d _initWithFirstObject:firstObject arguments:ap];
  va_end(ap);
  return AUTORELEASE(d);
  }
+ (id)dictionaryWithKeysAndObjects:(id)firstKey, ...
  {
  id d= MSAllocateObject(self, 0, NULL);
  va_list ap;
  va_start(ap, firstKey);
  d= [d _initWithFirstKey:firstKey arguments:ap];
  va_end(ap);
  return AUTORELEASE(d);
  }

- (id)init
  {
  return self;
  }
- (id)initWithObject:(id)object forKey:(id <NSCopying>)key
  {
  CDictionarySetObjectForKey((CDictionary*)self, object, key);
  return self;
  }
- (id)initWithKey:(id <NSCopying>)k andObject:(id)o
  {
  CDictionarySetObjectForKey((CDictionary*)self, o, k);
  return self;
  }

#if WIN32
- (id)initWithObjects:(const id [])os forKeys:(const id             [])ks count:(NSUInteger)n
#else
- (id)initWithObjects:(const id [])os forKeys:(const id <NSCopying> [])ks count:(NSUInteger)n
#endif
  {
  NSUInteger i;
  CDictionaryGrow((CDictionary*)self, n);
  for (i= 0; i<n; i++) {
    CDictionarySetObjectForKey((CDictionary*)self,os[i],ks[i]);}
  return self;
  }

- (id)initWithObjectsAndKeys:(id)firstObject, ...
{
  va_list ap;
  va_start(ap, firstObject);
  self= [self _initWithFirstObject:firstObject arguments:ap];
  va_end(ap);
  return self;
}
- initWithKeysAndObjects:(id)firstKey, ...
{
  va_list ap;
  va_start(ap, firstKey);
  self= [self _initWithFirstKey:firstKey arguments:ap];
  va_end(ap);
  return self;
}

- (id)initWithDictionary:(NSDictionary*)src copyItems:(BOOL)cpy
{
  if ([src respondsToSelector:@selector(dictionaryEnumerator)]) {
    id de,k,o;
    CDictionaryGrow((CDictionary*)self, [src count]);
    for (de= [(MSDictionary*)src dictionaryEnumerator]; (k= [de nextKey]);) {
      if ((o= [de currentObject]) && cpy) o= COPY(o);
      if (o) CDictionarySetObjectForKey((CDictionary*)self,o,k);}}
  else self= [super initWithDictionary:src copyItems:cpy];
  return self;
}

- (void)dealloc
  {
  CDictionaryFreeInside(self);
  [super dealloc];
  }

#pragma mark Primitives

- (NSUInteger)count {return _count;}

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


#pragma mark Global methods

- (NSUInteger)hash:(unsigned)depth {return CDictionaryHash(self, depth);}

- (id)copyWithZone:(NSZone*)z // La copie n'est pas mutable TODO: à revoir ?
  {
  CDictionary *d= (CDictionary*)MSAllocateObject([MSDictionary class], 0, z);
  return CDictionaryInitCopy(d, (CDictionary*)self);
  }
- (id)mutableCopyWithZone:(NSZone*)z
  {
  CDictionary *d= (CDictionary*)MSAllocateObject([MSMutableDictionary class], 0, z);
  return CDictionaryInitCopy(d, (CDictionary*)self);
  }
/*
- (BOOL)isEqualToDictionary:(NSDictionary*)otherDict
  {
  if (otherDict == (id)self) return YES;
  if (!otherDict) return NO;
  if ([otherDict _isMS]) return CArrayEquals((CArray*)self,(CArray*)otherDict);
  return [super isEqualToArray:otherDict];
  }
*/
- (BOOL)isEqual:(id)object
  {
  if (object == (id)self) return YES;
  if (!object) return NO;
  if ([object isKindOfClass:[MSDictionary class]]) {
    return CDictionaryEquals((CDictionary*)self, (CDictionary*)object);}
  else if ([object isKindOfClass:[NSDictionary class]]) { // TODO: a revoir. Quid dans l'autre sens ?
    return [object isEqualToDictionary:(id)self];}
  return NO;
  }

@end

@implementation MSMutableDictionary

+ (id)dictionaryWithCapacity:(NSUInteger)numItems
  {
  id d= MSAllocateObject(self, 0, NULL);
  CDictionaryGrow((CDictionary*)d, numItems);
  return AUTORELEASE(d);
  }

- (id)initWithCapacity:(NSUInteger)numItems
  {
  CDictionaryGrow((CDictionary*)self, numItems);
  return self;
  }

- (void)removeObjectForKey:(id)k
{
  CDictionarySetObjectForKey((CDictionary*)self, nil, k);
}

- (void)setObject:(id)o forKey:(id <NSCopying>)k
{
  if (o && k) CDictionarySetObjectForKey((CDictionary*)self, o, k);
}

@end

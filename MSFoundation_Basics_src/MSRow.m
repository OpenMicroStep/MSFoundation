/*
 
 MSRow.m
 
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

@implementation MSRow

- (id)initWithRowKeys:(MSRowKeys *)rowKeys values:(MSArray *)values
{
  if (!rowKeys || !values || [rowKeys count] != CArrayCount((CArray*)values)) {
    RELEASE(self) ;
    return nil ;
  }
  _rowKeys = RETAIN(rowKeys) ;
  _values = RETAIN(values) ;
  return self ;
}

- (void)dealloc
{
  RELEASE(_rowKeys) ;
  RELEASE(_values) ;
  [super dealloc] ;
}

- (id)objectAtIndex:(NSUInteger)i
{
  if (i >= CArrayCount((CArray*)_values)) MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"index %lu out of bounds %lu", (unsigned long)i, (unsigned long)CArrayCount((CArray*)_values)) ;
  return CArrayObjectAtIndex((CArray*)_values, i) ;
}
- (MSArray *)allKeys { return _rowKeys ? _rowKeys->_keys : nil ; }
- (MSArray *)allValues { return _values ; }

// ================== primitives ==================================
- (id)objectForKey:(id)aKey
{
  id o = nil ;
  if (aKey && _rowKeys) {
    NSUInteger idx = (NSUInteger)CDictionaryObjectForKey(_rowKeys->_table, aKey) ;
    if (idx != NSNotFound) {
      o = CArrayObjectAtIndex((CArray*)_values, idx) ;
      if ([o isNull]) { o = nil ; }
    }
  }
  return o ;
}

- (NSUInteger)count { return CArrayCount((CArray*)_values) ; }
- (NSEnumerator *)keyEnumerator { return _rowKeys ? [_rowKeys->_keys objectEnumerator] : nil ; }
- (NSEnumerator *)objectEnumerator { return [_values objectEnumerator] ; }

// ================== protocols ==================================
- (id)mutableCopyWithZone:(NSZone *)zone { return [[NSMutableDictionary allocWithZone:zone] initWithObjects:_values forKeys:[_rowKeys keys]] ; }
- (id)copyWithZone:(NSZone *)zone
{
  if  (zone == [self zone]) { return RETAIN(self) ; }
  return [[ISA(self) allocWithZone:zone] initWithRowKeys:_rowKeys values:_values] ;
}

// TO DO : encoding/decoding
@end

@implementation MSRowKeys

+ (CDictionary *)_conversionTableWithKeys:(MSArray *)keys
{
  CDictionary *table = NULL ;
  NSUInteger count ;
  if ((count = CArrayCount((CArray*)keys))) {
    NSUInteger i ;
    table= CCreateDictionaryWithOptions(count, CDictionaryObject, CDictionaryNatural);
    for (i = 0 ; i < count ; i++) {
      CDictionarySetObjectForKey(table, (id)i, CArrayObjectAtIndex((CArray*)keys,i)) ;
    }
  }
  return table ;
}

+ (MSRowKeys *)rowKeysWithKeys:(NSArray *)originalKeys
{
  NSUInteger count = [originalKeys count] ;
  if (count) {
    MSArray *keys = [originalKeys isKindOfClass:[MSArray class]] ? (MSArray *)RETAIN(originalKeys) : [ALLOC(MSArray) initWithArray:originalKeys] ;
    if (keys) {
      CDictionary *table = [self _conversionTableWithKeys:keys] ;
      if (table) {
        MSRowKeys *rk = ALLOC(self) ;
        if (rk) {
          rk->_keys = keys ;
          rk->_table = table ;
          return AUTORELEASE(rk) ;
        }
        else {
          RELEASE(keys) ;
          RELEASE((id)table) ;
        }
      }
      else { RELEASE(keys) ; }
    }
  }
  return nil ;
}

- (void)dealloc
{
  RELEASE(_keys) ;
  RELEASE((id)_table) ;
  [super dealloc] ;
}

- (MSArray *)keys { return _keys ; }
- (NSUInteger)indexForKey:(id)aKey
{
  return (NSUInteger)CDictionaryObjectForKey(_table, (id)aKey) ;
}

- (NSUInteger)count { return CArrayCount((CArray*)_keys) ; }
- (void *)context { return _context ; }

@end


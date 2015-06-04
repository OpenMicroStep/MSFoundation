/*
 
 MSNaturalArray.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
 Eric Baradat :  k18rt@free.fr
 Jean-Michel Bertheas : jean-michel.bertheas@club-internet.fr
 
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

#define MS_NATURALARRAY_LAST_VERSION	102

@implementation MSNaturalArray
+ (void)initialize {[MSNaturalArray setVersion:MS_NATURALARRAY_LAST_VERSION];}

// ====================== ALLOCATIONS, CREATIONS AND DEALLOCATIONS ============================
+ (id)alloc { return MSCreateObject(self) ; }
+ (id)allocWithZone:(NSZone *)zone { return MSAllocateObject(self, 0, zone) ; }
+ (id)new { return MSCreateObject(self) ; }

+ (id)naturalArray { return AUTORELEASE(MSCreateObject(self)) ; }
+ (id)naturalArrayWithNatural:(NSUInteger)n { return AUTORELEASE([ALLOC(self) initWithNatural:n]) ; }
+ (id)naturalArrayWithRange:(NSRange)range { return AUTORELEASE([ALLOC(self) initWithRange:range]) ; }
+ (id)naturalArrayWithNaturals:(NSUInteger *)naturals count:(NSUInteger)count
{ return AUTORELEASE([ALLOC(self) initWithNaturals:naturals count:count]) ; }
+ (id)naturalArrayWithNaturalArray:(MSNaturalArray *)array  { return AUTORELEASE([ALLOC(self) initWithNaturalArray:array]) ; }

- (id)init { return self ; }
- (id)initWithNatural:(NSUInteger)n
{
	if (n == NSNotFound) {
        DESTROY(self) ;
        MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"try to insert NSNotFound as a natural") ;
        return nil ;
	}
    _naturals  = MSMalloc(sizeof(NSUInteger), "- [MSNaturalArray initWithNatural:]") ;
    if (!_naturals) {
        DESTROY(self) ;
        MSRaiseFrom(NSMallocException, self, _cmd, @"natural array of  one element cannot be allocated") ;
        return nil ;
    }
    _count = _size = 1 ;
    *_naturals = n ;
    return self ;
}

- (id)initWithRange:(NSRange)range
{
	if (range.location == NSNotFound) {
		// TO DO : check if we overflow with range.length...
      MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"try to insert invalid range in natural array") ;
      DESTROY(self) ;
		return nil ;
	}
    if (range.length) {
        register NSUInteger i ;
        _naturals  = MSMalloc(sizeof(NSUInteger)*range.length, "- [MSNaturalArray initWithRange:]") ;
        if (!_naturals) {
            DESTROY(self) ;
            MSRaiseFrom(NSMallocException, self, _cmd, @"natural array of %lu elements cannot be allocated", (unsigned long)(range.length)) ;
            return nil ;
        }
        _size = range.length ;
        i = range.location ;
        for (_count = 0 ; _count < _size ; _count++) _naturals[_count] = i++ ;
    }
    return self ;
}

- (id)initWithNaturals:(NSUInteger *)naturals count:(NSUInteger)count
{
    if (naturals && count) {
        _naturals  = MSMalloc(sizeof(NSUInteger)*count, "- [MSNaturalArray initWithNaturals:count:]") ;
        if (!_naturals) {
            RELEASE(self) ;
            MSRaiseFrom(NSMallocException, self, _cmd, @"array of %lu elements cannot be allocated", (unsigned long)count) ;
            return nil ;
        }
		_size = count ;
		if (!CAddNaturals((CNaturalArray *)self, naturals, count)) {
			RELEASE(self) ;
			MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"try to insert NSNotFound as a natural") ;
			return nil ;			
		}
    }
    return self ;
}

- (id)initWithNaturalArray:(MSNaturalArray *)array
{
	if (!CAddNaturalArray((CNaturalArray *)self, (CNaturalArray *)array)) {
		RELEASE(self) ;
		MSRaiseFrom(NSMallocException, self, _cmd, @"array of %lu elements cannot be allocated", (unsigned long)MSNCount(array)) ;
		return nil ;
	}
    return self ;
}

- (void)dealloc { MSFree(_naturals, "- [MSNaturalArray dealloc]") ; [super dealloc] ; }

- (NSUInteger)count { return _count ; }
- (NSUInteger)lastNatural
{
    if (!_count) MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"index 0 out of bounds") ;
    return _naturals[_count-1] ;
}

- (NSUInteger)firstNatural
{
    if (!_count) MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"index 0 out of bounds") ;
    return _naturals[0] ;
}

- (NSUInteger)naturalAtIndex:(NSUInteger)i
{
    if( i >= _count) MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"index %lu out of bounds %lu", (unsigned long)i, (unsigned long)_count) ;
    return _naturals[i] ;
}

- (id)objectAtIndex:(NSUInteger)i
{
    if( i >= _count) MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"index %lu out of bounds %lu", (unsigned long)i, (unsigned long)_count) ;
	return [NSNumber numberWithUnsignedInteger:_naturals[i]] ;
}

- (BOOL)containsNatural:(NSUInteger)n { return CIndexOfNatural((CNaturalArray *)self, n, 0, _count) == NSNotFound ? NO : YES ; }
- (NSUInteger)indexOfNatural:(NSUInteger)n { return CIndexOfNatural((CNaturalArray *)self, n, 0, _count) ; }

- (BOOL)isEqualToNaturalArray:(MSNaturalArray *)a
{
    if (a && a->_count == _count) {
        return !memcmp(_naturals, a->_naturals, _count*sizeof(NSUInteger)) ;
    }
    return NO ;
}

- (BOOL)isEqual:(id)otherObject
{
    if ([otherObject isKindOfClass:[MSNaturalArray class]]) {
        if (MSNCount(otherObject) == _count) {
            return !memcmp(_naturals, ((MSNaturalArray *)otherObject)->_naturals, _count*sizeof(NSUInteger)) ;
        }
    }
    return NO ;
}

- (BOOL)isEqualToNaturalArray:(MSNaturalArray *)a inRange:(NSRange)range
{
    if (a && a->_count && range.length) {
        NSUInteger end = range.location + range.length ;
        if (end <= _count && end <= a->_count) {
            return !memcmp(_naturals+range.location, a->_naturals+range.location, range.length*sizeof(NSUInteger)) ;            
        }
    }
    return NO ;
}

- (BOOL)intersectsNaturalArray:(MSNaturalArray *)a
{
    if (_count && a && a->_count) {
        register NSUInteger j, i, jcount = a->_count ;
        register NSUInteger *naturals = a->_naturals ;
		
        for (i = 0 ; i< _count ; i++) {
            NSUInteger n = _naturals[i] ;
            for (j = 0 ; j < jcount ; j++) if (n == naturals[j]) return YES ;
        }
    }
    return NO ;
}

- (BOOL)intersectsRange:(NSRange)range
{
    if (_count && range.length) {
        register NSUInteger i, s = range.location, e = s + range.length ;
        for (i = 0 ; i < _count ; i++) if (_naturals[i] >= s && _naturals[i] < e) return YES ;
    }
    return NO ;
}

- (BOOL)isTrue
{
    if (_count) {
        register NSUInteger i ;
        for (i = 0 ; i < _count ; i++) { if (!_naturals[i]) return NO ; }
        return YES ;
    }
    return NO ;
}

- (NSString *)toString { return CNaturalArrayToString((CNaturalArray *)self) ; }
- (NSString *)listItemString { return CNaturalArrayToString((CNaturalArray *)self) ; }
- (NSString *)description { return CNaturalArrayToString((CNaturalArray *)self) ; }
- (NSString *)jsonRepresentation { return CNaturalArrayJsonRepresentation((CNaturalArray *)self) ; }

static int _naturalCompare(const void *aa, const void *bb)
{
    NSUInteger a=*(NSUInteger*)aa,b=*(NSUInteger*)bb;
    return a<b?-1:a>b?1:0;
}

- (id)sortedNaturalArray
{
    MSNaturalArray *retour = MSCreateNaturalArray(_count) ;
    if (_count) {
        memcpy(retour->_naturals, _naturals, _count*sizeof(NSUInteger)) ;
        if (_count > 1) qsort(retour->_naturals, _count, sizeof(NSUInteger), _naturalCompare) ;
    }
    return retour ;
}

static inline _MSNaturalConcreteEnumerator *_naturalArrayEnumerator(MSNaturalArray *array)
{
    _MSNaturalConcreteEnumerator *e = MSAllocateObject([MSNaturalArrayEnumerator class], 0, [array zone]) ;
    e->_array = RETAIN(array) ;
    return AUTORELEASE(e) ;
}

- (MSNaturalArrayEnumerator *)naturalEnumerator { return _naturalArrayEnumerator(self) ; }
- (NSEnumerator *)objectEnumerator { return _naturalArrayEnumerator(self) ; }

- (NSEnumerator *)arrangementEnumerator:(NSUInteger)nb
{
    if (nb && nb <= _count) {
        register NSUInteger i ;
        _MSNaturalArangementEnumerator *e = MSAllocateObject([_MSNaturalArangementEnumerator class], 0, [self zone]) ;
        e->_array = RETAIN(self) ;
        e->_ones = MSCreateNaturalArray(nb) ;
        if (e->_ones) {
            e->_nb = nb ;
            for (i = 0 ; i < nb ; i++) e->_ones->_naturals[i] = i ;
            return AUTORELEASE(e) ;
        }
        RELEASE(e) ;
    }
    return nil ;
}


// ===================== NSCOPYING AND MUTABLE COPYING PROTOCOL ======================================
- (id)copyWithZone:(NSZone *)zone { return zone == [self zone] ? RETAIN(self) : [[ISA(self) allocWithZone:zone] initWithNaturals:_naturals count:_count ] ; }
- (id)mutableCopyWithZone:(NSZone *)zone { return [[MSMutableNaturalArray allocWithZone:zone] initWithNaturals:_naturals count:_count ] ; }

// ===================== NSCODING PROTOCOL ======================================
- (id)replacementObjectForPortCoder:(NSPortCoder *)encoder
{
    if ([encoder isBycopy]) return self;
    return [super replacementObjectForPortCoder:encoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if ([aCoder allowsKeyedCoding]) {
		NSUInteger unitSize = sizeof(NSUInteger) ;
		
		if (unitSize != 4 && unitSize != 8) {
			MSRaiseFrom(NSInternalInconsistencyException, self, _cmd, @"impossible to encode MSNaturalArray because we don't know NSUInteger size") ;
		}

		[aCoder	encodeUnsignedInteger:_size forKey:@"capacity"] ;		
		[aCoder	encodeUnsignedInteger:_count forKey:@"count"] ;
		if (_count) {
#ifdef __BIG_ENDIAN__
			[aCoder encodeBool:YES forKey:@"big-endian"] ;
#else
			[aCoder encodeBool:YES forKey:@"little-endian"] ;
#endif
			[aCoder encodeBytes:(const void *)_naturals length:_count*unitSize forKey:@"naturals"] ;
		}
	}
	else {
		[aCoder encodeValueOfObjCType:@encode(NSUInteger) at:&_count] ;
		if (_count) [aCoder encodeArrayOfObjCType:@encode(NSUInteger) count:_count at:_naturals] ;
	}
}

- (id)initWithCoder:(NSCoder *)aCoder
{
	BOOL keyedCoding = [aCoder allowsKeyedCoding] ;
	if (keyedCoding) { _count = [aCoder decodeUnsignedIntegerForKey:@"count"] ; }
	else { [aCoder decodeValueOfObjCType:@encode(NSUInteger) at:&_count] ; }
	
	if (_count) {
		_naturals  = MSMalloc(sizeof(NSUInteger) * _count, "- [MSNaturalArray initWithCoder:]") ;
		if (!_naturals) {
			RELEASE(self) ;
			MSRaiseFrom(NSMallocException, self, _cmd, @"natural array of %lu elements cannot be allocated", (unsigned long)_count) ;
			return nil ;
		}
		_size = _count ;
		if (keyedCoding) {
#ifdef __BIG_ENDIAN__
			BOOL direct = [aCoder decodeBoolForKey:@"big-endian"] ;
#else
			BOOL direct = [aCoder decodeBoolForKey:@"little-endian"] ;
#endif
			NSUInteger i, bytesLength = 0 ;
			MSByte *bytes = (MSByte *)[aCoder decodeBytesForKey:@"naturals" returnedLength:&bytesLength] ;
			NSUInteger unitSize = sizeof(NSUInteger) ;
			NSUInteger storedUnitSize = bytesLength / _count ;
			
			if (unitSize != 4 && unitSize != 8) {
				RELEASE(self) ;
				MSRaiseFrom(NSInternalInconsistencyException, self, _cmd, @"impossible to decode MSNaturalArray because we don't know NSUInteger size") ;
				return nil ;
			}
			if (bytesLength != storedUnitSize*_count || (storedUnitSize != 4 && storedUnitSize != 8)) {
				RELEASE(self) ;
				MSRaiseFrom(NSInternalInconsistencyException, self, _cmd, @"storage of MSNaturalArray was inconsistent.") ;
				return nil ;
			}
			
			if (direct) {
				if (unitSize == storedUnitSize) {
					memcpy((MSByte *)_naturals, bytes, unitSize*_count) ;  
				}
				else if (unitSize > storedUnitSize) {
					for (i = 0 ; i < _count ; i++) { _naturals[i] = (NSUInteger)(((MSUInt *)bytes)[i]) ; }
				}
				else {
					MSULong n ;
					for (i = 0 ; i < _count ; i++) { 
						n = ((MSULong *)bytes)[i] ;
						if (n > MSUIntMax || n == (MSULong)NSNotFound) {
							RELEASE(self) ;
							MSRaiseFrom(NSInternalInconsistencyException, self, _cmd, @"storage of MSNaturalArray contains too large values.") ;
							return nil ;
						}
						else {
							_naturals[i] = (NSUInteger)n ;
						}

					}
				}

			}
			else {
				if (unitSize == storedUnitSize) {
					if (unitSize == 4) {
						for (i = 0 ; i < _count ; i++) { _naturals[i] = (NSUInteger)MSSwap32(((MSUInt *)bytes)[i]) ; }
					}
					else {
						for (i = 0 ; i < _count ; i++) { _naturals[i] = (NSUInteger)MSSwap64(((MSUInt *)bytes)[i]) ; }
					}
				}
				else if (unitSize > storedUnitSize) {
					for (i = 0 ; i < _count ; i++) { _naturals[i] = (NSUInteger)MSSwap32(((MSUInt *)bytes)[i]) ; }
				}
				else {
					MSULong n ;
					for (i = 0 ; i < _count ; i++) { 
						n = (NSUInteger)MSSwap64(((MSULong *)bytes)[i]) ;
						if (n > MSUIntMax || n == (MSULong)NSNotFound) {
							RELEASE(self) ;
							MSRaiseFrom(NSInternalInconsistencyException, self, _cmd, @"storage of MSNaturalArray contains too large values.") ;
							return nil ;
						}
						else {
							_naturals[i] = (NSUInteger)n ;
						}
						
					}
				}
			}
		}
		else {
			[aCoder decodeArrayOfObjCType:@encode(NSUInteger) count:_count at:_naturals] ;
		}
	}
	return self ;
}

@end

@implementation MSMutableNaturalArray

+ (id)naturalArrayWithCapacity:(NSUInteger)capacity { return AUTORELEASE([ALLOC(self) initWithCapacity:capacity]) ; }
- (id)initWithCapacity:(NSUInteger)capacity
{
    if (capacity) {
        _naturals = MSMalloc(capacity * sizeof(NSUInteger), "-[MSMutableNaturalArray initWithCapacity:]") ;
        if (!_naturals) {
            RELEASE(self) ;
            MSRaiseFrom(NSMallocException, self, _cmd, @"unable to allocate enougth memory for %u element(s)", capacity) ;
            return nil ;
        }
        _size = capacity ;
    }
    return self ;
}

- (void)addNatural:(NSUInteger)n
{
    if (!MSNAdd(self, n)) {
        MSRaiseFrom(NSMallocException, self, _cmd, @"unable to allocate enougth memory to add one element") ;
    }
}

- (void)addNaturals:(NSUInteger *)naturals count:(NSUInteger)count
{
    if (!CAddNaturals((CNaturalArray *)self, naturals, count)) {
        MSRaiseFrom(NSGenericException, self, _cmd, @"unable to allocate enougth memory to add %lu element or trying to insert NSNotFound", (unsigned long)count) ;
	}
}

- (void)addNaturalsFromNaturalArray:(MSNaturalArray *)array
{
	if (!CAddNaturalArray((CNaturalArray *)self, (CNaturalArray *)array)) {
        MSRaiseFrom(NSGenericException, self, _cmd, @"unable to allocate enougth memory to add %lu element", (unsigned long)MSNCount(array)) ;
	}
}

- (void)addRange:(NSRange)range
{
 	if (range.location == NSNotFound) { MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"Trying to insert bad range") ; }
	else {
		NSUInteger count = range.length ;
		if (count) {
			register NSUInteger i ;
			if (_count + count > _size && !CNaturalArrayGrow((CNaturalArray *)self, count)) {
				MSRaiseFrom(NSMallocException, self, _cmd, @"unable to allocate enougth memory to add %lu element(s)", (unsigned long)count) ;
			}
			else {
				count += range.location ;
				for (i = range.location ; i < count ; i++) _naturals[_count++] = i ;
			}
		}
	}
}

- (void)replaceNatural:(NSUInteger)n atIndex:(NSUInteger)i
{
	if (n == NSNotFound) { MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"Trying to insert NSNotFound value") ; }
    else if( i >= _count) { MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"index %lu out of bounds %lu", (unsigned long)i, (unsigned long)_count) ;}
    else _naturals[i] = n ;
}

- (void)replaceWithNaturalsFromNaturalArray:(MSNaturalArray *)a
{
    if (a != self) {
        MSFree(_naturals, "- [MSMutableNaturalArray replaceWithNaturalsFromNaturalArray:]") ;
        _size = _count = 0 ;
        if (a->_count) {
            _naturals = MSMalloc(a->_count * sizeof(NSUInteger), "- [MSMutableNaturalArray replaceWithNaturalsFromNaturalArray:]") ;
            if (!_naturals) MSRaiseFrom(NSMallocException, self, _cmd, @"unable to allocate enougth memory for %lu element(s)", (unsigned long)a->_count) ;
            else {
                _size = _count = a->_count ;
                memmove(_naturals, a->_naturals, _count*sizeof(NSUInteger)) ;
            }
        }
    }
}

- (void)insertNatural:(NSUInteger)n atIndex:(NSUInteger)i
{
	if (n == NSNotFound) { MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"Trying to insert NSNotFound value") ; }
    else if (i > _count) MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"index %lu out of bounds %lu", (unsigned long)i, (unsigned long)(_count+1))  ;
    else {
        if (_count >= _size && !CNaturalArrayGrow((CNaturalArray *)self, 1)) {
            MSRaiseFrom(NSMallocException, self, _cmd, @"unable to allocate enougth memory to add one element") ;
        }
        if (i < _count) {
            memmove(_naturals+(i+1), _naturals+i, (_count - i)*sizeof(NSUInteger)) ;
        }
        _naturals[i] = n ;
        _count ++ ;
    }
}

- (void)insertNaturals:(NSUInteger *)naturals count:(NSUInteger)count atIndex:(NSUInteger)insertIndex
{
	if (naturals && count) {
        if (insertIndex > _count) MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"index %lu out of bounds %lu", (unsigned long)insertIndex, (unsigned long)(_count + 1)) ;
        else {
			register NSUInteger i ;
			if (_count + count > _size && !CNaturalArrayGrow((CNaturalArray *)self, count)) {
				MSRaiseFrom(NSMallocException, self, _cmd, @"unable to allocate enougth memory to add %lu element(s)", (unsigned long)count) ;
			}
			if (insertIndex < _count) {
				memmove(_naturals+(insertIndex+count), _naturals+insertIndex, (_count - insertIndex)*sizeof(NSUInteger)) ;
			}
			for (i = 0 ; i < count ; i++) {
				NSUInteger n = naturals[i] ;
				if (n == NSNotFound) { MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"Trying to insert NSNotFound value") ; }
				_naturals[insertIndex++] = naturals[i] ;
			}
			_count += count ;
		}
	}
}


- (void)insertRange:(NSRange)range atIndex:(NSUInteger)insertIndex
{
 	if (range.location == NSNotFound) { MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"Trying to insert bad range") ; }
	else {
		NSUInteger count = range.length ;
		if (count) {
			if (insertIndex > _count) MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"index %lu out of bounds %lu", (unsigned long)insertIndex, (unsigned long)_count + 1) ;
			else {
				register NSUInteger i, end ;
				if (_count + count > _size && !CNaturalArrayGrow((CNaturalArray *)self, count)) {
					MSRaiseFrom(NSMallocException, self, _cmd, @"unable to allocate enougth memory to add %lu element(s)", (unsigned long)count) ;
				}
				if (insertIndex < _count) {
					memmove(_naturals+(insertIndex+count), _naturals+insertIndex, (_count - insertIndex)*sizeof(NSUInteger)) ;
				}
				end = range.location + count ;
				for (i = range.location ; i < end ; i++) _naturals[insertIndex++] = i ;
				_count += count ;
			}
		}    
	}
}

- (void)insertNaturalsFromNaturalArray:(MSNaturalArray *)a atIndex:(NSUInteger)i
{
    if (a && a->_count) {
        if (i > _count) MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"index %lu out of bounds %lu", (unsigned long)i, (unsigned long)(_count + 1)) ;
        else {
            NSUInteger count = a->_count ;
            if (_count + count > _size && !CNaturalArrayGrow((CNaturalArray *)self, count)) {
                MSRaiseFrom(NSMallocException, self, _cmd, @"unable to allocate enougth memory to add %lu element(s)", (unsigned long)count) ;
            }
            if (i < _count) {
                memmove(_naturals+(i+count), _naturals+i, (_count - i)*sizeof(NSUInteger)) ;
            }
            memmove(_naturals+i, a->_naturals, count*sizeof(NSUInteger)) ;
            _count += count ;
        }
    }
}

- (void)removeAllNaturals
{
	// TO DO : we keep the memory here because if not, just destroy the object
    _count = 0 ;
}

- (void)removeLastNatural
{
    if (!_count) MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"index 0 out of bounds") ;
    else _count -- ;
}

- (void)removeLastNaturals:(NSUInteger)count
{
    if (count) {
        if (count > _count) MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"count %lu to be removed greater than count %lu", (unsigned long)count, (unsigned long)_count) ;
        else _count -= count ;
    }
}

- (void)removeNaturalAtIndex:(NSUInteger)i
{
    if (i >= _count) MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"index %lu out of bounds %lu", (unsigned long)i, (unsigned long)_count) ;
	(void)CRemoveNaturalAtIndex((CNaturalArray *)self, i) ;
}

- (void)removeNatural:(NSUInteger)n
{
	if (n == NSNotFound) { MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"Trying to remove NSNotFound value") ; }
	(void)CRemoveNatural((CNaturalArray *)self, n) ;
}

- (void)removeNaturals:(NSUInteger *)naturals count:(NSUInteger)count
{
	if (naturals && count) {
		while (_count > 0 && count-- > 0) {
			NSUInteger n = naturals[count] ;
			if (n == NSNotFound) { MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"Trying to remove NSNotFound value") ; return ; }
			(void)CRemoveNatural((CNaturalArray *)self, n) ;
		}
	}
}

- (void)removeNaturalsFromNaturalArray:(MSNaturalArray *)a
{
	NSUInteger i = MSNCount(a) ;
	while (_count > 0 && i-- > 0) { (void)CRemoveNatural((CNaturalArray *)self, MSNIndex(a, i)) ; }
}

- (void)removeNaturalsInRange:(NSRange)range
{
	if (range.location == NSNotFound) { MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"Trying to remove naturals from bad range") ; }
	else if (range.length) {
		CRemoveNaturalsInRange((CNaturalArray *)self, range.location, NSMaxRange(range) - 1) ;
	}

}

- (void)sort { if (_count > 1) qsort(_naturals,_count, sizeof(NSUInteger), _naturalCompare); }

// ===================== NSCOPYING AND MUTABLE COPYING PROTOCOL ======================================
- (id)copyWithZone:(NSZone *)zone { return [[MSNaturalArray allocWithZone:zone] initWithNaturals:_naturals count:_count] ; }
- (id)mutableCopyWithZone:(NSZone *)zone { return [[ISA(self) allocWithZone:zone] initWithNaturals:_naturals count:_count] ; }

@end


#define _MSCreateWithCapacity(PROTO, ITEMS_TYPE, ITEMS_TOKEN) MS ## PROTO *MSCreate ## PROTO(NSUInteger capacity) \
{ \
	MS ## PROTO *ret = (MS ## PROTO *)MSCreateObject([MS ## PROTO class]) ; \
	if (ret) { \
		if (capacity) { \
			char *str = "MSCreate" #PROTO "()" ; \
			ITEMS_TYPE *p = MSMalloc(capacity * sizeof(ITEMS_TYPE), str) ; \
			if (!p) { \
				RELEASE(ret) ; \
				MSRaise(NSMallocException, [NSString stringWithFormat:@"%s : buffer of %lu elements cannot be allocated", str, (unsigned long)capacity]) ; \
				return nil ; \
			} \
			ret->ITEMS_TOKEN = p ; \
			ret->_size = capacity ; \
		} \
	} \
	return ret ; \
}
_MSCreateWithCapacity(NaturalArray, NSUInteger, _naturals) ;
_MSCreateWithCapacity(MutableNaturalArray, NSUInteger, _naturals) ;

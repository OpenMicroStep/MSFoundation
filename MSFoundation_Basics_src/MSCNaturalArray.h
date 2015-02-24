/*
 
 MSCNaturalArray.h
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
 Eric Baradat :  k18rt@free.fr
 
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
 
 WARNING : this header file cannot be included alone, please direclty
 include <MSFoundation/MSFoundation.h>
 */
/*
	CNaturaArray can store any NSUInteger but NSNotFound which is by default the value
	returned when we cannot found any natural in an array
 */

typedef struct CNaturalArrayStruct {
    Class isa ; /* here only to bind this structure to an objective-c object */
    NSUInteger *pointers ;
    NSUInteger count ;
    NSUInteger size ;
} CNaturalArray ;

static inline BOOL CNaturalArrayGrow(CNaturalArray *self, NSUInteger n)
{
    if (self && n) {
        NSUInteger newSize = MSCapacityForCount(self->size + n) ;
        if (self->pointers) {
            if (!(self->pointers = (NSUInteger *)MSRealloc(self->pointers, newSize * sizeof(NSUInteger), "CNaturalArrayGrow()"))) return NO ;
            else self->size = newSize ;
        }
        else {
            if (!(self->pointers = (NSUInteger *)MSMalloc(newSize * sizeof(NSUInteger), "CNaturalArrayGrow()"))) return NO ;
            else self->size = newSize ;
        }
    }
    return YES ;
}

static inline BOOL CNaturalArrayAdjustSize(CNaturalArray *self)
{
	if (self && self->count < self->size) {
		if (self->count) {
			if (!(self->pointers = (NSUInteger *)MSRealloc(self->pointers, (self->count) * sizeof(NSUInteger), "CArrayAdjustSize()"))) return NO ;
			else self->size = self->count ;
		}
		else {
			MSFree(self->pointers, "CNaturalArrayAdjustSize()") ; self->pointers = NULL ;
			self->size = 0 ;
		}
		
	}
	return NO ;
}

static inline NSUInteger CNaturalArrayCount(CNaturalArray *self) { return (self ? self->count : 0) ; }

static inline NSUInteger CNaturalAtIndex(CNaturalArray *self, NSUInteger i)
{
    if (!self || i >= self->count) return NSNotFound ;
    return self->pointers[i] ;
}

static inline NSUInteger CLastNatural(CNaturalArray *self)
{
    if (!self || !self->count) return NSNotFound ;
    return self->pointers[self->count - 1] ;
}

static inline NSUInteger CFirstNatural(CNaturalArray *self)
{
    if (!self || !self->count) return NSNotFound ;
    return self->pointers[0] ;
}


static inline NSUInteger CIndexOfNatural(CNaturalArray *self, NSUInteger searchedNatural, NSUInteger start, NSUInteger count)
{
    if (self && count && start < self->count) {
        register NSUInteger i ;
        register NSUInteger *p = self->pointers ;
        register NSUInteger end = MIN(start + count, self->count) ;
        for (i = start ; i < end ; i++) { if (searchedNatural == p[i]) return i ; }
    }
    return NSNotFound ;
}

static inline BOOL CAddNatural(CNaturalArray *self, NSUInteger aNatural)
{
    if (self) {
        if (aNatural == NSNotFound || (self->count >= self->size && !CNaturalArrayGrow(self, 1))) return NO ;
        self->pointers[self->count++] = aNatural ; 
    }
    return YES ;
}

static inline BOOL CAddNaturals(CNaturalArray *self, NSUInteger *naturals, NSUInteger nb)
{
	if (self && naturals && nb) {
        if ((self->count + nb > self->size && !CNaturalArrayGrow(self, nb))) return NO ;
		else {
			NSUInteger i, n, oldCount = self->count ;
			for	(i = 0 ; i < nb ; i++) { 
				n = naturals[i] ;
				if (n == NSNotFound) { self->count = oldCount ; return NO ; }
				else { self->pointers[self->count++] = naturals[i] ; }
			}
		}
	}
	return YES ;
}

static inline NSUInteger CAddNaturalArray(CNaturalArray *self, CNaturalArray *other)
{
	NSUInteger nb ;
	if (self && (nb = CNaturalArrayCount(other))) {
        if ((self->count + nb > self->size && !CNaturalArrayGrow(self, nb))) return NO ;
		else {
			NSUInteger i ;
			NSUInteger *naturals = other->pointers ;
			for	(i = 0 ; i < nb ; i++) { self->pointers[self->count++] = naturals[i] ; }
			return nb ;
		}		
	}
	return 0 ;
}

static inline void CRemoveAllNaturals(CNaturalArray *self) { if (self) { self->count = 0 ; } }

static inline NSUInteger CRemoveNaturalsInRange(CNaturalArray *self, NSUInteger startIndex, NSUInteger endIndex)
{
    if (self && self->count > 0) {
		if (endIndex >= self->count) endIndex = self->count - 1 ;
		if (startIndex <= endIndex) {
			NSUInteger count = self->count ;
			if (endIndex < count - 1) {
				memmove(self->pointers+startIndex, self->pointers+(endIndex+1), (count - endIndex - 1)*sizeof(NSUInteger)) ;
			}
			self->count -= endIndex - startIndex + 1 ;
			return endIndex - startIndex + 1 ;
		}
	}
	return 0 ;
}

static inline BOOL CRemoveNaturalAtIndex(CNaturalArray *self, NSUInteger i)
{
    if (self) {
        if (i >= self->count) return NO ;
        if (i < self->count -1) {
            memmove(self->pointers+i, self->pointers+(i+1), (self->count - i - 1)*sizeof(NSUInteger)) ;
        }
        self->count -- ;
    }
    return YES ;
}

static inline void CRemoveNatural(CNaturalArray *self, NSUInteger aNatural)
{
    if (self) {
        register NSUInteger *p = self->pointers ;
        register NSUInteger i = self->count ;
		while (i-- > 0) { if (aNatural == p[i]) { CRemoveNaturalAtIndex(self, i) ;}}
    }
}

static inline BOOL CRemoveLastNatural(CNaturalArray *self)
{
    if (self) {
        if (!self->count) return NO ;
        self->count -- ;
    }
    return YES ;
}

static inline BOOL CReplaceNaturalAtIndex(CNaturalArray *self, NSUInteger newNatural, NSUInteger i)
{
    if (self) {
        if (newNatural == NSNotFound || i >= self->count) return NO ;
		self->pointers[i] = newNatural ;
    }
    return YES ;
}

static inline BOOL CInsertNaturalAtIndex(CNaturalArray *self, NSUInteger aNatural, NSUInteger i)
{
    if (self) {
        if (aNatural == NSNotFound || i > self->count || (self->count >= self->size && !CNaturalArrayGrow(self, 1))) return NO ;
        if (i < self->count) {
            memmove(self->pointers+(i+1), self->pointers+i, (self->count - i)*sizeof(NSUInteger)) ;
        }
        self->pointers[i] = aNatural ;
        self->count ++ ;
    }
    return YES ;
}

MSFoundationExtern NSUInteger CSortedArrayIndexOfNatural(CNaturalArray *self, NSUInteger aNatural, NSUInteger start, NSUInteger nb, BOOL exact) ;

static inline BOOL CSortedArrayAddNatural(CNaturalArray *self, NSUInteger aNatural)
{
    NSUInteger n ;
    if (!self) return NO ;
    n = CSortedArrayIndexOfNatural(self, aNatural, 0, self->count, NO) ;
    return CInsertNaturalAtIndex(self, aNatural, n) ; 
}

MSFoundationExtern NSString *CNaturalArrayToString(CNaturalArray *self) ;
MSFoundationExtern NSString *CNaturalArrayJsonRepresentation(CNaturalArray *self) ;

#define MSNAdd(X, Y)			CAddNatural((CNaturalArray *)(X), (Y))
#define MSNIndex(X, Y)			((CNaturalArray *)(X))->pointers[(Y)]
#define MSNCount(X)				CNaturalArrayCount((CNaturalArray *)(X))
#define MSNLast(X)				CLastNatural((CNaturalArray *)(X))
#define MSNFirst(X)				CFirstNatural((CNaturalArray *)(X))
#define MSNPush(X, Y)			MSNAdd(X, Y)
#define MSNPull(X)				CRemoveLastNatural((CNaturalArray *)(X))


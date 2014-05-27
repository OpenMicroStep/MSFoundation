/*
 
 MSNaturalArrayEnumerator.m
 
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
//#import "MSArray.h"
//#import "MSNaturalArray.h"
//#import "MSNaturalArrayEnumerator.h"
//#include "_MSNaturalArrayEnumeratorPrivate.h"
//#import "NSNumberAdditions.h"


@implementation MSNaturalArrayEnumerator
- (NSUInteger)nextNatural { return NSNotFound ; }

- (MSNaturalArray *)allNaturals
{
    NSUInteger n = [self nextNatural] ;
	if (n != NSNotFound) {
        MSNaturalArray *array = [MSNaturalArray naturalArrayWithNatural:n] ;
		while ((n = [self nextNatural]) != NSNotFound) { MSNAdd(array, n) ; }
		return array ;
	}
	return nil ;
}

- (id)nextObject
{
    NSUInteger n = [self nextNatural] ;
	return (n == NSNotFound ? nil : [NSNumber numberWithUnsignedInteger:n]) ;
}

- (NSArray *)allObjects
{
    NSUInteger n = [self nextNatural] ;
	if (n != NSNotFound) {
        MSArray *array = [MSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:n]] ;
		while ((n = [self nextNatural]) != NSNotFound) { MSAAdd(array, [NSNumber numberWithUnsignedInteger:n]) ; }
		return array ;
	}
	return nil ;
}

@end

@implementation _MSNaturalConcreteEnumerator
- (NSUInteger)nextNatural { return _next < _array->_count ? _array->_naturals[_next++] : NSNotFound ; } 
- (id)nextObject { return _next < _array->_count ? [NSNumber numberWithUnsignedInteger:_array->_naturals[_next++]] : nil ; }
- (void)dealloc { RELEASE(_array) ; [super dealloc] ; }
@end

@implementation _MSNaturalArangementEnumerator
- (id)nextObject
{
    MSNaturalArray *r = nil ;
    if (_ones) {
        NSUInteger i, p = 0, positionP;
        BOOL mustFree = NO ;
        r = AUTORELEASE(MSCreateNaturalArray(_nb)) ;
        for (i = 0 ; i < _nb ; i++) {
            r->_naturals[r->_count++] = _array->_naturals[_ones->_naturals[i]] ;
        }
        if ((positionP = _ones->_naturals[0]) > 0) mustFree = YES ;
        while (p+1 < _nb) {
            if (_ones->_naturals[p+1] == positionP+1) { positionP++; p++; }
            else break;
        }
        if ( positionP == _array->_count-1) { RELEASE(_ones) ; _ones = nil ; }
        else {
            _ones->_naturals[p] = positionP + 1 ;
            if (p > 0 && mustFree) {
                for (i = 0; i < p ; i++) _ones->_naturals[i] = i ;
            }
        }
    }
    return r ;
}


- (void)dealloc { RELEASE(_ones) ; RELEASE(_array) ; [super dealloc] ; }
@end


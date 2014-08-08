/*
 
 MSNaturalArray.h
 
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
 
 IMPORTANT WARNING:
 
 MSNaturalArray can store any NSUInteger but NSNotFound which is by default the value
 returned when we cannot found any natural in an array
 
 */

@class MSNaturalArrayEnumerator ;

@interface MSNaturalArray : NSObject <NSCoding, NSCopying, NSMutableCopying>
{
@public
    NSUInteger        *_naturals ;
    NSUInteger   		_count ;
    NSUInteger			_size ;
}

+ (id)naturalArray;
+ (id)naturalArrayWithNatural:(NSUInteger)n;
+ (id)naturalArrayWithRange:(NSRange)range ;
+ (id)naturalArrayWithNaturals:(NSUInteger *)naturals count:(NSUInteger)count ;
+ (id)naturalArrayWithNaturalArray:(MSNaturalArray *)array ;

- (id)init ;
- (id)initWithNatural:(NSUInteger)n;
- (id)initWithRange:(NSRange)range ;
- (id)initWithNaturals:(NSUInteger *)naturals count:(NSUInteger)count ;
- (id)initWithNaturalArray:(MSNaturalArray *)array ;

- (NSUInteger)count ;

- (BOOL)isEqual:(id)otherObject ;
- (BOOL)isEqualToNaturalArray:(MSNaturalArray *)a ;
- (BOOL)isEqualToNaturalArray:(MSNaturalArray *)a inRange:(NSRange)range ;

- (NSUInteger)naturalAtIndex:(NSUInteger)i;
- (NSUInteger)firstNatural ;
- (NSUInteger)lastNatural ;
- (id)objectAtIndex:(NSUInteger)i;

- (BOOL)containsNatural:(NSUInteger)n;
- (NSUInteger)indexOfNatural:(NSUInteger)n;

- (BOOL)intersectsNaturalArray:(MSNaturalArray *)a ;
- (BOOL)intersectsRange:(NSRange)range ;

- (MSNaturalArrayEnumerator *)naturalEnumerator ;
- (NSEnumerator *)objectEnumerator ;
- (NSEnumerator *)arrangementEnumerator:(NSUInteger)nb;

- (id)sortedNaturalArray ;

@end

@interface MSMutableNaturalArray : MSNaturalArray

+ (id)naturalArrayWithCapacity:(NSUInteger)capacity ;
- (id)initWithCapacity:(NSUInteger)capacity ;

- (void)addNatural:(NSUInteger)n ;
- (void)addNaturals:(NSUInteger *)naturals count:(NSUInteger)count ;
- (void)addRange:(NSRange)range ;
- (void)addNaturalsFromNaturalArray:(MSNaturalArray *)array ;

- (void)replaceNatural:(NSUInteger)n atIndex:(NSUInteger)i ;
- (void)replaceWithNaturalsFromNaturalArray:(MSNaturalArray *)a ;

- (void)insertNatural:(NSUInteger)n atIndex:(NSUInteger)i ;
- (void)insertNaturals:(NSUInteger *)naturals count:(NSUInteger)count atIndex:(NSUInteger)i ;
- (void)insertRange:(NSRange)range atIndex:(NSUInteger)index ;
- (void)insertNaturalsFromNaturalArray:(MSNaturalArray *)a atIndex:(NSUInteger)i ;

- (void)removeLastNatural ;
- (void)removeLastNaturals:(NSUInteger)count ;
- (void)removeNaturalAtIndex:(NSUInteger)i ;
- (void)removeNatural:(NSUInteger)n ;
- (void)removeNaturals:(NSUInteger *)naturals count:(NSUInteger)count ;
- (void)removeNaturalsFromNaturalArray:(MSNaturalArray *)a ;
- (void)removeNaturalsInRange:(NSRange)range ;

- (void)removeAllNaturals ;

- (void)sort ;

@end

MSFoundationExport MSNaturalArray *MSCreateNaturalArray(NSUInteger capacity) ; // returns a retained object
MSFoundationExport MSMutableNaturalArray *MSCreateMutableNaturalArray(NSUInteger capacity) ; // returns a retained object 

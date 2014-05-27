
/*
 
 MSCNaturalArray.m
 
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
#import "MSFoundation_Private.h"
//#import "MSStringAdditions.h"
//#import "MSUnicodeString.h"
//#import "MSASCIIString.h"

// si n>ns[nb-1] retourne nb-1
// sinon retourne le plus petit i tq n<=ns[i]
// return NSNotFound si on est pas dans de bonnes conditions (objet nil ou self nil ou pas trouve en mode exact)
NSUInteger CSortedArrayIndexOfNatural(CNaturalArray *self, NSUInteger aNatural, NSUInteger start, NSUInteger nb, BOOL exact)
{
    if (self) {
        register NSUInteger min, mid,max, comp = NSOrderedAscending ;
        register NSUInteger *p ;
		
        if (start >= self->count) { return (exact ? NSNotFound : self->count) ; /* si on recherche au dela du range, on n'insere forcement a la fin */ }
        if (!nb) { return (exact ? NSNotFound : start) ; }
        
        p = self->pointers ;
        min=start; max=start+nb-1;
        if (max > self->count) max = self->count ;

		while (min<max) {
			mid=(min+max)/2;
			comp = (aNatural == p[mid] ? NSOrderedSame : (aNatural > p[mid] ? NSOrderedDescending : NSOrderedAscending)) ;
			if (comp != NSOrderedDescending) max = mid ;
			else min=mid+1;
		}
        //if (min==nb-1 && index && n>ns[min]) min++;
        return (!exact || comp == NSOrderedSame ? min : NSNotFound) ;
        
    }
    return (exact ? NSNotFound : 0) ;
}

static inline NSString *_MSNaturalsToString(NSUInteger *naturals, NSUInteger count)
{
    if (count) {
        char *buf = MSMalloc(12*count+3, "_MSNaturalsToString()") ;
        register char *s = buf ;
        register NSUInteger i ;
        int len ;
        *s++ = '[' ;
        len = sprintf(s, "%lu", (unsigned long)naturals[0]) ;
        s += len ;
        for (i = 1 ; i < count ; i++) {
            len = sprintf(s, ", %lu", (unsigned long)naturals[i]) ;
            s += len ;
        }
        *s++ = ']' ;
        return AUTORELEASE(MSCreateASCIIStringWithBytes((void *)buf, (NSUInteger)(s-buf), NO, YES)) ;
    }
    return @"[]" ;
}

NSString *CNaturalArrayToString(CNaturalArray *self)
{
    if (self && self->pointers) {
		return _MSNaturalsToString(self->pointers, self->count) ;
    }
    return nil ;
}

NSString *CNaturalArrayJsonRepresentation(CNaturalArray *self)
{
    if (self && self->pointers) {
		return _MSNaturalsToString(self->pointers, self->count) ;
    }
    return nil ;
}


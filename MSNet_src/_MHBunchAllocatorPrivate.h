/*
 
 MHBunchAllocator.h
 
 This file is is a part of the MicroStep Application Server over Http Framework.
 
 Initial copyright LOGITUD Solutions (logitud@logitud.fr) since 2012
 
 Herve Malaingre : herve@malaingre.com
 Jean-Michel Bertheas :  jean-michel.bertheas@club-internet.fr
 
 
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
typedef struct CBunchStruct CBunch ;

@class MHBunchAllocator ;

struct CBunchStruct
{
    MSUInt instanceSize ;               //size of the objects instances contained into the bunch
    MSUShort maxSize ;                  //maximum objects number that the bunch can contain
    MSUShort allocatedObjectsCount ;    //number of objects allocated into the bunch
    MSUShort deallocatedObjectsCount ;  //number of objects already deallocated into the bunch
    char *nextFree ;                    //pointer to next free object
    struct CBunchStruct *previousBunch ;     //pointer to previous bunch
    struct CBunchStruct *nextBunch ;         //pointer to next bunch
    MHBunchAllocator *parentBunchAllocator ; //pointer to the parent bunch allocator
} ;

#ifdef WIN32
#define A_BUNCH 			4
#else
#define A_BUNCH 			8
#endif
#define S_BUNCH			((sizeof(CBunch) + (A_BUNCH-1)) & (MSUInt)~(A_BUNCH-1))

@interface MHBunchAllocator : NSObject
{
    Class _instanceClass ;
    MSUShort _bunchSize ;
    CBunch *_lastBunch ;
    mtx_t _bunchAllocatorMutex ;
}

+ (id)bunchAllocatorForClass:(Class)aClass withBunchSize:(MSUShort)size;
+ (id)retainedBunchAllocatorForClass:(Class)aClass withBunchSize:(MSUShort)size ;
- (id)initForClass:(Class)aClass withBunchSize:(MSUShort)size ;

- (id)newBunchObjectIntoBunch:(CBunch **)aBunch ;
- (void)removeBunch:(CBunch *)aBunch ;
- (void)removeObjectFromBunch:(CBunch *)aBunch ;

@end

static inline CBunch *newBunch(MHBunchAllocator *bunchAllocator, MSUInt objectInstanceSize, MSUShort numberOfObjects) //protected by mutex lock in [parentBunchAllocator newBunchObjectIntoBunch:]
{
    MSUInt len ;
    CBunch *bunch ;
    
    numberOfObjects = (MSUShort)MAX(16, numberOfObjects) ; //at least 16 objects
    objectInstanceSize = (objectInstanceSize + (A_BUNCH-1)) & (MSUInt)~(A_BUNCH-1) ;
    len = objectInstanceSize * ((MSUInt)numberOfObjects) + S_BUNCH ;
    if ((bunch = calloc(len,1))) {
        bunch->instanceSize = objectInstanceSize ;
        bunch->maxSize = numberOfObjects ;
        bunch->allocatedObjectsCount = 0 ;
        bunch->deallocatedObjectsCount = 0 ;
        bunch->nextFree = ((char *)bunch) + S_BUNCH ;
        bunch->previousBunch = NULL ;
        bunch->nextBunch = NULL ;
        bunch->parentBunchAllocator = bunchAllocator ;
        return bunch ;
    }
    return NULL ;
}

static inline id newBunchObject(MHBunchAllocator *bunchAllocator, CBunch **bunch, Class objectClass) //protected by mutex lock in [parentBunchAllocator newBunchObjectIntoBunch:] 
{
    CBunch *currentBunch = *bunch ;
    id obj ;
    if (currentBunch->allocatedObjectsCount == currentBunch->maxSize) {
        CBunch *n = newBunch(bunchAllocator, currentBunch->instanceSize, currentBunch->maxSize) ;
        if (!n) return nil ;
        currentBunch->nextBunch = n ;
        n->previousBunch = currentBunch ;
        *bunch = n ;
        currentBunch = n ;
    }
    obj = (id)currentBunch->nextFree ;
#ifdef WO451
    obj->isa = objectClass ;
#else
    object_setClass(obj, objectClass) ;
#endif
    currentBunch->nextFree += currentBunch->instanceSize ;
    currentBunch->allocatedObjectsCount++;
    return obj ;
}

static inline BOOL freeBunch(CBunch *bunch) //protected by mutex lock in [parentBunchAllocator removeObjectFromBunch]
{
    if (bunch && (bunch->maxSize == bunch->allocatedObjectsCount) && (bunch->allocatedObjectsCount == bunch->deallocatedObjectsCount)) {
        CBunch *nextBunch = bunch->nextBunch ;
        CBunch *previousBunch = bunch->previousBunch ;

        [bunch->parentBunchAllocator removeBunch:bunch] ;
        if (nextBunch) {
            nextBunch->previousBunch = previousBunch ;
        }
        if (previousBunch) {
            previousBunch->nextBunch = nextBunch ;
        }
        free(bunch) ;
        return YES ;
    }
    return NO ;
}

static inline void removeObjectFromBunch(CBunch *bunch, id object)
{
    if (bunch && object) {
        [object dealloc];
        [bunch->parentBunchAllocator removeObjectFromBunch:bunch] ; //locks the mutex on parentBunchAllocator
    }
}

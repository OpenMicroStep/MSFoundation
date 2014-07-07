/*
 
 MHBunchRegister.m
 
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

#import "MSNet_Private.h"

#define INITIAL_CLASS_REGISTER_SIZE 8

static Class *__classRegister = NULL ;
static void *__bunchAllocatorRegister = NULL ;
static MSUShort __classRegisterSize = 0;
static MSUShort __classRegisterCount = 0;
static BOOL __bunchAllocatorMutexInitialized = NO ;
static mutex_t __bunchAllocatorMutex ;

MHBunchAllocator *getBunchAllocatorForClass(Class aClass, MSUShort aBunchSize) 
{
    MSUShort i ;
    MHBunchAllocator *newBunchAllocator = nil ;
    void **newBunchAllocatorRegistered = NULL ;
    
    if (!__bunchAllocatorMutexInitialized) {
        mutex_init(__bunchAllocatorMutex) ;
        __bunchAllocatorMutexInitialized = YES ;
    }
    mutex_lock(__bunchAllocatorMutex);

    if (!__classRegister) {
        __classRegisterSize = INITIAL_CLASS_REGISTER_SIZE ;
        __classRegister = malloc(__classRegisterSize*sizeof(Class *)) ;
        __bunchAllocatorRegister = malloc(__classRegisterSize*sizeof(MHBunchAllocator *)) ;
    }
    
    for (i=0; i<__classRegisterCount; i++) {
        if(__classRegister[i] == aClass) { //we find the requested bunchAllocator
            return (MHBunchAllocator *)(__bunchAllocatorRegister+(i*sizeof(MHBunchAllocator *))) ;
        }
    }

    //the requested bunchAllocator does not already exists, we will instanciate it
    if (__classRegisterCount == __classRegisterSize) {
        MSUShort newClassRegisterSize = __classRegisterSize*2 ;

        __classRegister = MSRealloc(__classRegister, newClassRegisterSize*sizeof(Class *), @"getBunchAllocatorForClass() newClassRegister") ;
        if (!__classRegister) return nil ;
        
        __bunchAllocatorRegister = MSRealloc(__bunchAllocatorRegister, newClassRegisterSize*sizeof(MHBunchAllocator *), @"getBunchAllocatorForClass() newBunchAllocatorRegister") ;
        if (!__bunchAllocatorRegister) return nil ;
        
        __classRegisterSize = newClassRegisterSize ;
    }
    
    newBunchAllocator = [MHBunchAllocator retainedBunchAllocatorForClass:aClass withBunchSize:aBunchSize] ;
    newBunchAllocatorRegistered = (&__bunchAllocatorRegister)+(__classRegisterCount*sizeof(MHBunchAllocator *)) ;
    *newBunchAllocatorRegistered = (void *)newBunchAllocator ;
    
    __classRegister[__classRegisterCount] = aClass ;
    __classRegisterCount++ ;
    
    mutex_unlock(__bunchAllocatorMutex);
    
    return newBunchAllocator ;
}

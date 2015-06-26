/*
 
 MHBunchAllocator.m
 
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

@implementation MHBunchAllocator

+ (id)bunchAllocatorForClass:(Class)aClass withBunchSize:(MSUShort)size
{
    return [[[self alloc] initForClass:aClass withBunchSize:(MSUShort)size] autorelease] ;
}

+ (id)retainedBunchAllocatorForClass:(Class)aClass withBunchSize:(MSUShort)size
{
    return [[self alloc] initForClass:aClass withBunchSize:(MSUShort)size] ;
}

- (id)initForClass:(Class)aClass withBunchSize:(MSUShort)size
{
    mtx_init(&_bunchAllocatorMutex, mtx_plain) ;
    _instanceClass = aClass ;
    _bunchSize = size ;
    _lastBunch = NULL ;
    return self ;
}

- (void)dealloc
{
    mtx_destroy(&_bunchAllocatorMutex);
    [super dealloc] ;
}

- (id)newBunchObjectIntoBunch:(CBunch **)aBunch
{
    id newObject = nil ;
    mtx_lock(&_bunchAllocatorMutex);
#if !__OBJC2__
    if (!_lastBunch) _lastBunch = newBunch(self, ((struct objc_class *)_instanceClass)->instance_size, _bunchSize) ;
#else
    if (!_lastBunch) _lastBunch = newBunch(self, (MSUInt)class_getInstanceSize(_instanceClass), _bunchSize) ;
#endif    
    newObject = newBunchObject(self, &_lastBunch, _instanceClass) ;
    *aBunch = _lastBunch ;
    mtx_unlock(&_bunchAllocatorMutex);
    return newObject ;
}

- (void)removeObjectFromBunch:(CBunch *)aBunch
{
    mtx_lock(&_bunchAllocatorMutex);
    aBunch->deallocatedObjectsCount++ ;
    freeBunch(aBunch) ;
    mtx_unlock(&_bunchAllocatorMutex);
}

- (void)removeBunch:(CBunch *)aBunch
{
    if (aBunch && (aBunch == _lastBunch)) {
        _lastBunch = aBunch->previousBunch ;
    }
}

@end

/*   MSMutableArray.m
 
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
#import "MSArray_.h"
#import <objc/objc-runtime.h>

@interface MSMutableArray (Private)
- (BOOL)_isMS;
@end
@implementation MSMutableArray (Private)
- (BOOL)_isMS {return YES;}
@end

@implementation MSMutableArray

#include "MSArray_.i"

- (void)addObject:(id)anObject
{
  CArrayAddObject((CArray*)self, anObject);
}

- (void)addObjects:(const id*)objects count:(NSUInteger)n copyItems:(BOOL)copy
{
  CArrayAddObjects((CArray*)self, objects, n, copy);
}

- (void)replaceObjectsInRange:(NSRange)rg withObjects:(const id*)objects copyItems:(BOOL)copy
{
  CArrayReplaceObjectsInRange((CArray*)self, objects, rg, copy);
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)i
{
  CArrayInsertObjectAtIndex((CArray*)self, anObject, i);
}

- (void)replaceObjectAtIndex:(NSUInteger)i withObject:(id)anObject
{
  CArrayReplaceObjectAtIndex((CArray*)self, anObject, i);
}

- (void)removeLastObject
{
  CArrayRemoveLastObject((CArray*)self);
}
- (void)removeObjectAtIndex:(NSUInteger)i
{
  CArrayRemoveObjectAtIndex((CArray*)self, i);
}
- (void)removeAllObjects
{
  CArrayRemoveAllObjects((CArray*)self);
}

- (void)removeObjectsInRange:(NSRange)range
{
  CArrayRemoveObjectsInRange((CArray*)self, range);
}

- (void)removeObject:(id)anObject
{
  CArrayRemoveObject((CArray*)self, anObject);
}

- (void)removeObjectsInArray:(NSArray*)otherArray
{
  if (otherArray == self) CArrayRemoveAllObjects((CArray*)self);
  else if ([otherArray _isMS]) {
    // TODO: hash optimisation in a CArray fct ?
    register NSUInteger i, count= MSACount(otherArray);
    for (i= 0; i < count; i++) CArrayRemoveObject((CArray*)self, MSAIndex(self,i));}
  else {
    register NSUInteger i, count= [otherArray count];
    for (i= 0; i < count; i++) CArrayRemoveObject((CArray*)self, [otherArray objectAtIndex:i]);}
}

- (void)removeObjectIdenticalTo:(id)anObject
{
  CArrayRemoveIdenticalObject((CArray*)self, anObject);
}

- (void)setArray:(NSArray *)otherArray
{
  if (otherArray != self) {
    CArrayRemoveAllObjects((CArray*)self);
    if ([otherArray _isMS]) {
      CArrayAddArray((CArray*)self, (CArray*)otherArray, NO);} // No copy
    else {
      NSUInteger i, n; id o;
      n= [otherArray count];
      CArrayGrow((CArray*)self, n);
      for (i= 0; i < n; i++) {
        o= [otherArray objectAtIndex:i]; // WE CAN OPTIMIZE THAT WITH LOOKUP
        CArrayAddObject((CArray*)self, o);}}}
}

- (void)removeObjectsFromIndices:(NSUInteger *)indices numIndices:(NSUInteger)count
{
  if (indices && count) {
    while (count-- > 0) {
      CArrayRemoveObjectAtIndex((CArray *)self, indices[count]);}}
}

- (void)sortUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context
{
  if (_count > 1 ) {
    MSObjectSort(_pointers, _count, comparator, context);}
}

static NSComparisonResult _internalCompareFunction2(id e1, id e2, void *selector)
  {
  return (*((NSComparisonResult(*)(id,SEL,id))objc_msgSend))(e1, (SEL)selector, e2);
  }
- (void)sortUsingSelector:(SEL)comparator
{
  if (_count > 1 ) {
    MSObjectSort(_pointers, _count, _internalCompareFunction2, (void*)comparator);}
}

- (BOOL)conditionalAddObject:(id)anObject
{
  if (anObject && (!_count || CArrayIndexOfObject((CArray*)self, anObject, 0, _count) == NSNotFound)) {
    CArrayAddObject((CArray *)self, anObject);
    return YES;}
  return NO;
}

- (BOOL)conditionalAddObjectIdenticalTo:(id)anObject
{
  if (anObject && (!_count || CArrayIndexOfIdenticalObject((CArray *)self, anObject, 0, _count) == NSNotFound)) {
    CArrayAddObject((CArray *)self, anObject);
    return YES;}
  return NO;
}

@end

MSMutableArray *MSCreateMutableArray(NSUInteger capacity)
  {
  id a= MSAllocateObject([MSMutableArray class], 0, NULL);
  CArrayGrow((CArray*)a, capacity);
  return a;
  }

/************************** TO DO IN THIS FILE  ****************
 
 (1)  an implementation for methods :
 
 - (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange;
 - (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray;
 
 - (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;
 - (void)removeObjectsAtIndexes:(NSIndexSet *)indexes AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;
 - (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;
 
 
 *************************************************************/

/*
 
 MSCArray.c
 
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

#include "MSCore.h"

#pragma mark local functions

static inline void _erase(noRR, p, idxStart, idxCount)
BOOL noRR; id *p; NSUInteger idxStart, idxCount;
{
  if (!noRR) {
    for (p+= idxStart; idxCount; idxCount--) RELEASE(*p++);}
}

static inline void _compress(p, pn, idxStart, idxCount)
id *p; NSUInteger *pn, idxStart, idxCount;
{
  NSUInteger idxEnd= idxStart+idxCount;
  if (idxEnd < *pn) memmove(p+idxStart, p+idxEnd, (*pn-idxEnd)*sizeof(id));
  *pn-= idxCount;
}

static inline void _expand(a, idxStart, idxCount)
CArray *a; NSUInteger idxStart, idxCount;
{
  NSUInteger n= a->count;
  NSUInteger idxEnd= idxStart+idxCount;
  if (a->size < n+idxCount) CArrayGrow(a, idxCount);
  if (idxStart < n) {
    id *p= a->pointers;
    memmove(p+idxEnd, p+idxStart, (n-idxStart)*sizeof(id));}
  a->count+= idxCount;
}

// HM: 27/08/13 protect from inserting *nil* object and from bad index
static inline void _fill(noRR, p, po,idxStart,idxCount, copyItems,nilVerif, fct)
BOOL noRR,copyItems,nilVerif; id *p,*po; NSUInteger idxStart,idxCount; char*fct;
{
  id o;
  if (!nilVerif && !copyItems && noRR) {
    memmove(p+idxStart, po, idxCount*sizeof(id));}
  else for  (p+= idxStart; idxCount; idxCount--) {
    if (!(o= *po++)) {
      MSReportError(MSInvalidArgumentError, MSFatalError, MSTryToInsertNilError,
                    "%s(): try to insert *nil* object at index %lu.",
                    fct,(unsigned long)idxStart);
      return;}
    if (copyItems) o= COPY(o);
    else if (!noRR) RETAIN(o);
    *p++= o;}
}

static inline void _insert(a, po,idxStart,idxCount, copyItems,nilVerif, fct)
CArray *a; id *po; NSUInteger idxStart,idxCount; BOOL copyItems,nilVerif; char*fct;
{
  if (!a || !po || !idxCount) return;
  _expand(a, idxStart, idxCount);
  _fill(a->flag.noRR, a->pointers, po,idxStart,idxCount, copyItems,nilVerif, fct);
}

#pragma mark c-like class methods

void CArrayFreeInside(id self)
{
  if (self) {
    CArray *a= (CArray*)self;
    _erase(a->flag.noRR, a->pointers, 0, a->count);
    MSFree(a->pointers, "CArrayFree() [memory]");}
}
void CArrayFree(id self)
{
  CArrayFreeInside(self);
  MSFree(self, "CArrayFree() [self]");
}

BOOL CArrayIsEqual(id self, id other)
{
  if (self == other) return YES;
  if (self && other && (self)->isa == (other)->isa) {
    return CArrayEquals((CArray*)self, (CArray*)other);}
  return NO;
}

NSUInteger CArrayHash(id self, unsigned depth)
{
  NSUInteger count = MSACount(self);
  
  if (!count || depth == MSMaxHashingHop) return count;
  
  depth++;
  
  switch (count) {
    case 1:
      return count ^
        HASHDEPTH(((CArray*)self)->pointers[0], depth);
    case 2:
      return count ^
        HASHDEPTH(((CArray*)self)->pointers[0], depth) ^
        HASHDEPTH(((CArray*)self)->pointers[1], depth);
    default:
      return count ^
        HASHDEPTH(((CArray*)self)->pointers[0], depth) ^
        HASHDEPTH(((CArray*)self)->pointers[count/2], depth) ^
        HASHDEPTH(((CArray*)self)->pointers[count-1], depth);}
}

id CArrayCopy(id self)
{
  CArray *a;
  if (!self) return nil;
  a= (CArray *)MSCreateObjectWithClassIndex(CArrayClassIndex);
  if (a) {
    a->flag.noRR= ((CArray*)self)->flag.noRR;
    CArrayAddArray(a, (CArray*)self, NO);}
  return (id)a;
}

#pragma mark Creation

CArray *CCreateArrayWithOptions(NSUInteger capacity, BOOL noRetainRelease, BOOL nilItems)
{
  CArray *a= CCreateArray(capacity);
  a->flag.noRR=     noRetainRelease;
  a->flag.nilItems= nilItems;
  return a;
}

CArray *CCreateArray(NSUInteger capacity)
{
  CArray *a= (CArray*)MSCreateObjectWithClassIndex(CArrayClassIndex);
  if (a && capacity) CArrayGrow(a, capacity);
  return a;
}

CArray *CCreateArrayWithObject(id object)
{
  CArray *a;
  if (!object) {
    MSReportError(MSInvalidArgumentError, MSFatalError, MSTryToInsertNilError,
      "CCreateArrayWithObject(): try to insert *nil* object");
    return nil;}
  a= CCreateArray(1);
  CArrayAddObject(a, object);
  return a;
}

CArray *CCreateArrayWithObjects(id *objects, NSUInteger count, BOOL copyItems)
{
  CArray *a;
  if (!objects && count) {
    MSReportError(MSInvalidArgumentError, MSFatalError, MSNULLPointerError,
      "CCreateArrayWithObjects(): try to insert %lu objects from a NULL pointer",
      (unsigned long)count);
    return nil;}
  a= CCreateArray(count);
  _insert(a, objects, 0, count, copyItems, !a->flag.nilItems, "CCreateArrayWithObjects");
  return a;
}

CArray *CCreateSubArrayWithRange(CArray *a, NSRange rg)
{
  CArray *sub; BOOL nilVerif;
  if (rg.location + rg.length > a->count) {
    MSReportError(MSInvalidArgumentError, MSFatalError, MSIndexOutOfRangeError,
      "CCreateSubArrayWithRange: range [%lu %lu] %s out of range [0 %lu]",
      WLU(rg.location), WLU(rg.location+rg.length-1), WLU(a->count));
    return nil;}
  sub= CCreateArray(rg.length);
  nilVerif= (!sub->flag.nilItems && a->flag.nilItems);
  _insert(sub, a->pointers+rg.location, 0, rg.length, NO, nilVerif, "CCreateArrayWithObjects");
  return sub;
}

#pragma mark Management

// HM: 27/08/13 change the BOOL returned parameter from a report error to be conform to ObjC error reporting
void CArrayGrow(CArray *self, NSUInteger n)
{
  NSUInteger newSize;
  if (self && n && (newSize= MSCapacityForCount(self->count + n)) > self->size) {
    if (!self->pointers) {
      if (!(self->pointers= (id*)MSMalloc(newSize * sizeof(id), "CArrayGrow()"))) {
        MSReportError(MSMallocError, MSFatalError, MSMallocErrorCode, "CArrayGrow() allocation error");
        return;}}
    else if (!(self->pointers= (id*)MSRealloc(self->pointers, newSize * sizeof(id), "CArrayGrow()"))) {
      MSReportError(MSMallocError, MSFatalError, MSReallocErrorCode, "CArrayGrow() reallocation error");
      return;}
    self->size= newSize;}
}

// HM: 27/08/13 change the BOOL returned parameter from a report error to be conform to ObjC error reporting
void CArrayAdjustSize(CArray *self)
{
  if (self && self->count < self->size) {
    if (self->count) {
      if (!(self->pointers = (id *)MSRealloc(self->pointers, (self->count) * sizeof(id), "CArrayAdjustSize()"))) {
        MSReportError(MSMallocError, MSFatalError, MSReallocErrorCode, "CArrayAdjustSize() reallocation error");
        return;
      }
      else self->size = self->count;
    }
    else {
      MSFree(self->pointers, "CArrayAdjustSize()"); self->pointers = NULL;
      self->size = 0;
    }
    
  }
}

NSUInteger CArrayCount(const CArray *self)
{
  return (self ? self->count : 0);
}

id CArrayObjectAtIndex(const CArray *self, NSUInteger i)
{
  if (!self || i >= self->count) return nil;
  return self->pointers[i];
}

id CArrayLastObject(const CArray *self)
{
  if (!self || !self->count) return nil;
  return self->pointers[self->count - 1];
}

id CArrayFirstObject(const CArray *self)
{
  if (!self || !self->count) return nil;
  return self->pointers[0];
}

NSUInteger CArrayIndexOfObject(const CArray *self, const id object, NSUInteger start, NSUInteger count)
{
  if (self && count && start < self->count) {
    register NSUInteger i;
    register id *p = self->pointers;
    register NSUInteger end = MIN(start + count, self->count);
    for (i = start; i < end; i++) {
      if (object == p[i] || ISEQUAL(object, p[i])) return i;}
  }
  return NSNotFound;
}

NSUInteger CArrayIndexOfIdenticalObject(const CArray *self, const id object, NSUInteger start, NSUInteger count)
{
  if (self && count && start < self->count) {
    register NSUInteger i;
    register id *p = self->pointers;
    register NSUInteger end = MIN(start + count, self->count);
    for (i = start; i < end; i++) { if (object == p[i]) return i;}
  }
  return NSNotFound;
}

#pragma mark Equality

BOOL CArrayEquals(const CArray *self, const CArray *anotherArray)
{
  if (self == anotherArray) return YES;
  if (self && anotherArray) {
    NSUInteger c = self->count;
    if (c == anotherArray->count) {
      NSUInteger i;
      for (i = 0; i < c; i++) { if (!ISEQUAL(self->pointers[i],anotherArray->pointers[i])) { return NO; }}
      return YES;
    }
  }
  return NO;
}

BOOL CArrayIdenticals(const CArray *self, const CArray *anotherArray)
{
  if (self == anotherArray) return YES;
  if (self && anotherArray) {
    NSUInteger c = self->count;
    if (c == anotherArray->count) {
      NSUInteger i;
      for (i = 0; i < c; i++) { if (self->pointers[i] != anotherArray->pointers[i]) { return NO; }}
      return YES;
    }
  }
  return NO;
}

#pragma mark Add

void CArrayAddObject(CArray *self, id object)
{
  if (!self) return;
  _insert(self, &object, self->count, 1, NO, !self->flag.nilItems, "CArrayAddObject");
}

void CArrayAddObjects(CArray *self, id *objects, NSUInteger nb, BOOL copyItems)
{
  if (!self) return;
  _insert(self, objects, self->count, nb, copyItems, !self->flag.nilItems, "CArrayAddObjects");
}
void CArrayAddArray(CArray *self, const CArray *other, BOOL copyItems)
{
  BOOL nilVerif;
  if (!self || !other) return;
  nilVerif= (!self->flag.nilItems && other->flag.nilItems);
  _insert(self, other->pointers, self->count, other->count, copyItems, nilVerif, "CArrayAddArray");
}

#pragma mark Remove

void CArrayRemoveObjectAtIndex(CArray *self, NSUInteger i)
{
  CArrayRemoveObjectsInRange(self, NSMakeRange(i,1));
}

void CArrayRemoveLastObject(CArray *self)
{
  register NSUInteger n;
  if (self && (n= self->count))
    CArrayRemoveObjectsInRange(self, NSMakeRange(n-1, 1));
}

NSUInteger CArrayRemoveAllObjects(CArray *self)
{
  register NSUInteger n;
  if (!self || !(n= self->count)) return 0;
  return CArrayRemoveObjectsInRange(self, NSMakeRange(0,n));
}

NSUInteger CArrayRemoveObjectsInRange(CArray *self, NSRange rg)
{
  register id *p;
  register NSUInteger n,idxStart,idxCount;
  if (!self || !(n= self->count) ||
      n <= (idxStart= rg.location) || !(idxCount= rg.length))
    return 0;
  if (n < idxStart+idxCount) idxCount= n-idxStart;
  _erase(self->flag.noRR, (p= self->pointers), idxStart, idxCount);
  _compress(p, &self->count, idxStart, idxCount);
  return idxCount;
}

NSUInteger CArrayRemoveObject(CArray *self, id object)
{
  register id *p;
  register NSUInteger i,removed;
  if (!self || !object) return 0;
  p= self->pointers; i= self->count; removed= 0;
  while (i-- > 0) if (ISEQUAL(object, p[i])) {
    CArrayRemoveObjectAtIndex(self, i);
    removed++;}
  return removed;
}

// HM: 27/08/13 change the void return with the effective number of object removed
NSUInteger CArrayRemoveIdenticalObject(CArray *self, id object)
{
  register id *p;
  register NSUInteger i,removed;
  if (!self || !object) return 0;
  p= self->pointers; i= self->count; removed= 0;
  while (i-- > 0) if (object == p[i]) {
    CArrayRemoveObjectAtIndex(self, i);
    removed++;}
  return removed;
}

#pragma mark Replace

void CArrayReplaceObjectAtIndex(CArray *self, id object, NSUInteger i)
{
  if (!object) return;
  CArrayReplaceObjectsInRange(self, &object, NSMakeRange(i,1), NO);
}

void CArrayReplaceObjectsInRange(CArray *self, id *objects, NSRange rg, BOOL copyItems)
{
  char *fct= "CArrayReplaceObjectsInRange";
  NSUInteger idxStart,ixdCount; BOOL noRR; id *p;
  if (!self) return;
  if ((idxStart= rg.location) >= self->count) {
    MSReportError(MSInvalidArgumentError, MSFatalError, MSIndexOutOfRangeError,
                  "%s(): try to replace object at bad index %lu.",
                  fct,(unsigned long)idxStart);
    return;}
  _erase((noRR= self->flag.noRR), (p= self->pointers), idxStart, (ixdCount= rg.length));
  _fill(noRR, p, objects,idxStart,ixdCount, copyItems,!self->flag.nilItems, fct);
}

#pragma mark Insert

void CArrayInsertObjectAtIndex(CArray *self, id object, NSUInteger i)
{
  if (!object) return;
  CArrayInsertObjectsInRange(self, &object, NSMakeRange(i,1), NO);
}

void CArrayInsertObjectsInRange(CArray *self, id *objects, NSRange rg, BOOL copyItems)
{
  char *fct= "CArrayInsertObjectsInRange";
  NSUInteger n,idxStart;
  if (!self) return;
  if ((n= self->count) < (idxStart= rg.location)) {
    MSReportError(MSInvalidArgumentError, MSFatalError, MSIndexOutOfRangeError,
                  "%s(): try to insert object at bad index %lu.",
                  fct,(unsigned long)idxStart);
    return;}
  _insert(self, objects, idxStart, rg.length, copyItems, YES, fct);
}

#pragma mark Common

id CArrayFirstCommonIdenticalObject(const CArray *self, const CArray *other)
{
  register NSUInteger i, n;
  register id *p, *op;
  if (!self || !other) return nil;
  n= MIN(self->count, other->count);
  p= self->pointers;
  op= other->pointers;
  for (i= 0; i < n; i++) {
    if (p[i] == op[i]) return p[i];}
  return nil;
}

id CArrayFirstCommonObject(const CArray *self, const CArray *other)
{
  register NSUInteger i, n;
  register id *p, *op;
  if (!self || !other) return nil;
  n= MIN(self->count, other->count);
  p= self->pointers;
  op= other->pointers;
  for (i= 0; i < n; i++) {
    if (ISEQUAL(p[i],op[i])) return p[i];}
  return nil;
}

#pragma mark Sort

static NSComparisonResult __equalityComparator(id obj1, id obj2, void *context)
{
  return (obj1 == obj2 ? NSOrderedSame : (obj1 > obj2 ? NSOrderedDescending : NSOrderedAscending));
  context= NULL; // no warning
}

NSUInteger CSortedArrayIndexOfObject(CArray *self, id object, NSUInteger start, NSUInteger nb, MSObjectComparator comparator, void *context, BOOL exact)
// si n>ns[nb-1] retourne nb-1
// sinon retourne le plus petit i tq n<=ns[i]
// return NSNotFound si on est pas dans de bonnes conditions (objet nil ou self nil ou pas trouve en mode exact)
{
  if (self) {
    register NSUInteger min, mid,max;
    register NSInteger comp = NSOrderedAscending;
    register id *p;
    
    if (!comparator) comparator = __equalityComparator;
    if (start >= self->count) { return (exact ? NSNotFound : self->count);} // si on recherche au dela du range, on n'insere forcement a la fin
    if (!nb) { return (exact ? NSNotFound : start); }
    
    p = self->pointers;
    min=start; max=start+nb-1;
    if (max > self->count) max = self->count;
    while (min<max) {
      mid=(min+max)/2;
      comp = comparator(object, p[mid], context);
      if (comp != NSOrderedDescending) max = mid;
      else min=mid+1;
    }
    //if (min==nb-1 && index && n>ns[min]) min++;
    return (!exact || comp == NSOrderedSame ? min : NSNotFound);
    
  }
  return (exact ? NSNotFound : 0);
}

// HM: 27/08/13 protect from inserting *nil* object and from bad index and modify the function in order to return the index of the inserted object
NSUInteger CSortedArrayAddObject(CArray *self, id obj, MSObjectComparator cmp, void *context)
{
  NSUInteger idx;
  if (!self) return NSNotFound;
  if (!obj) {
    MSReportError(MSInvalidArgumentError, MSFatalError, MSTryToInsertNilError,
      "CSortedArrayAddObject(): try to insert *nil* object.");
    return NSNotFound;}
  idx= CSortedArrayIndexOfObject(self, obj, 0, self->count, cmp, context, NO);
  CArrayInsertObjectAtIndex(self, obj, idx);
  return idx;
}

#ifndef MSCORE_STANDALONE
/* TODO:
 // these 2 function should be replaced by "MSUnicodeBuffer" functions :
 MSExport NSString *CArrayToString(CArray *self);
 MSExport NSString *CArrayJsonRepresentation(CArray *self);
NSString *CArrayToString(CArray *self)
  {
  if (self) {
    NSUInteger count = self->count;
    if (count) {
      NSUInteger i;
      register id *p = self->pointers;
      MSUnicodeString *ret = MSCreateUnicodeString(count*3);
      MSUAddUnichar(ret, (unichar)'(');
      MSUAddString(ret, [p[0] listItemString]);
      
      for (i = 1; i < count; i++) {
        MSUAddUnichar(ret, (unichar)',');
        MSUAddString(ret,[p[i] listItemString]);}
      MSUAddUnichar(ret, (unichar)')');
      return AUTORELEASE(ret);}
    return @"()";}
  return nil;
  }
 */
CUnicodeBuffer *CArrayToString(CArray *self)
  {
  return nil;
  self= nil;
  }
#endif

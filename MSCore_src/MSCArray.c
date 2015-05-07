/* MSCArray.c
 
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

#include "MSCore_Private.h"

#pragma mark Genericity for immutable methods

#define _CCOUNT(  a) (((CArray*)(a))->count)
#define _GCOUNT(g,a) (g->count(a))
#define GARRAY_COUNT( g,a) (!g ? _CCOUNT(a) : _GCOUNT(g,a))

#define _COAI(  a,i) (((CArray*)(a))->pointers[i])
#define _GOAI(g,a,i) (g->objectAtIndex(a,i))
#define GARRAY_OAI( g,a,i) (!g ? _COAI(a,i) : _GOAI(g,a,i))

void GArrayEnumeratorInit(GArrayEnumerator *e,
  garray_pfs_t fs, const id array, NSUInteger start, NSUInteger count)
{
  if (!e) return;
  e->fs=    fs;
  e->array= array;
  if (!array) e->start= e->end= 0;
  else {
    NSUInteger n= GARRAY_COUNT(fs, array);
    e->start= MIN(start, n);
    e->end=   MIN(start + count, n);}
}
// Ended is needed when niltems are accepted
id GArrayEnumeratorNextObject(GArrayEnumerator *e, BOOL *ended)
{
  id o;
  if (e && e->start < e->end) {
    o= GARRAY_OAI(e->fs, e->array, e->start++); if (ended) *ended= NO;}
  else {o= nil; if (ended) *ended= YES;}
  return o;
}
id GArrayEnumeratorPreviousObject(GArrayEnumerator *e, BOOL *ended)
{
  id o;
  if (e && e->start < e->end) {
    o= GARRAY_OAI(e->fs, e->array, --e->end); if (ended) *ended= NO;}
  else {o= nil; if (ended) *ended= YES;}
  return o;
}

// A t'on vraiment besoin d'un hash pour les arrays ?
// De plus, s'il change, son hash change (même si on ne garde que le count).
// TODO: Si ce n'est jamais utilisé, considérer sa suppression.
NSUInteger GArrayHash(garray_pfs_t g, id self, unsigned depth)
{
  NSUInteger count= GARRAY_COUNT(g, self);
  if (!count || depth == MSMaxHashingHop) return count;
  depth++;
  switch (count) {
    case 1: return count ^
      HASHDEPTH(GARRAY_OAI(g, self, 0), depth);
    case 2: return count ^
      HASHDEPTH(GARRAY_OAI(g, self, 0), depth) ^
      HASHDEPTH(GARRAY_OAI(g, self, 1), depth);
    default: return count ^
      HASHDEPTH(GARRAY_OAI(g, self,       0), depth) ^
      HASHDEPTH(GARRAY_OAI(g, self, count/2), depth) ^
      HASHDEPTH(GARRAY_OAI(g, self, count-1), depth);}
}

BOOL GArrayIdenticals(garray_pfs_t fs1, const id a1, garray_pfs_t fs2, const id a2)
{
  NSUInteger i,c;
  if ( a1 ==  a2) return YES;
  if (!a1 || !a2) return NO;
  if ((c= GARRAY_COUNT(fs1, a1)) != GARRAY_COUNT(fs2, a2)) return NO;
  for (i= 0; i < c; i++) {
    if (GARRAY_OAI(fs1, a1, i) != GARRAY_OAI(fs2, a2, i)) return NO;}
  return YES;
}

BOOL GArrayEquals(garray_pfs_t fs1, const id a1, garray_pfs_t fs2, const id a2)
{
  NSUInteger i,c;
  if ( a1 ==  a2) return YES;
  if (!a1 || !a2) return NO;
  if ((c= GARRAY_COUNT(fs1, a1)) != GARRAY_COUNT(fs2, a2)) return NO;
  for (i= 0; i < c; i++) {
    if (!ISEQUAL(GARRAY_OAI(fs1, a1, i), GARRAY_OAI(fs2, a2, i))) return NO;}
  return YES;
}

void CStringAppendGArrayDescription(CString *s, garray_pfs_t fs, const id a) // + context de description ?
{
  if (!a) CStringAppendFormat(s,"nil");
  else {
    GArrayEnumerator e; NSUInteger i,n; const CString *d;
    CStringAppendCharacter(s, '(');
    GArrayEnumeratorInit(&e, fs, a, 0, (n= GARRAY_COUNT(fs, a)));
    for (i= 0; i < n; i++) {
      if (i>0) CStringAppendFormat(s, ", ");
      // TODO: APPEND_DESCRIPTION(GARRAY_OAI(fs, a,i));
      d= DESCRIPTION(GARRAY_OAI(fs, a, i));
      if (!d) CStringAppendFormat(s,"nil");
      else CStringAppendString(s, d);
      RELEASE(d);}
    CStringAppendCharacter(s, ')');}
}

id GArrayFirstObject(garray_pfs_t fs, const id self)
{
  if (!self || !GARRAY_COUNT(fs, (id)self)) return nil;
  return GARRAY_OAI(fs, (id)self, 0);
}

id GArrayLastObject(garray_pfs_t fs, const id self)
{
  NSUInteger n;
  if (!self || !(n= GARRAY_COUNT(fs, (id)self))) return nil;
  return GARRAY_OAI(fs, (id)self, n-1);
}

NSUInteger GArrayIndexOfIdenticalObject(garray_pfs_t fs, const id self, const id object, NSUInteger start, NSUInteger count)
{
  GArrayEnumerator e; BOOL ended; id o;
  GArrayEnumeratorInit(&e, fs, self, start, count);
  for (; (o= GArrayEnumeratorNextObject(&e, &ended)) || !ended; start++) {
    if (o == object) return start;}
  return NSNotFound;
}

NSUInteger GArrayIndexOfObject(garray_pfs_t fs, const id self, const id object, NSUInteger start, NSUInteger count)
{
  GArrayEnumerator e; BOOL ended; id o;
  GArrayEnumeratorInit(&e, fs, self, start, count);
  for (; (o= GArrayEnumeratorNextObject(&e, &ended)) || !ended; start++) {
    if (ISEQUAL(o, object)) return start;}
  return NSNotFound;
}

NSUInteger GArrayGetObject(garray_pfs_t fs, const id self, NSUInteger start, NSUInteger count, id *objects)
{
  NSUInteger end,i;
  if (fs && fs->get) return fs->get(self, start, count, objects);
  if (!objects || start >= (end= MIN(start+count, GARRAY_COUNT(fs, self)))) return 0;
  if (!fs) memcpy(objects, (((CArray*)(self))->pointers)+start, (end-start)*sizeof(id));
  else for (i= start; i<end; i++) *objects++= fs->objectAtIndex(self, i);
  return end-start;
}

#pragma mark local functions

static inline void _erase(noRR, p, idxStart, idxCount)
BOOL noRR; id *p; NSUInteger idxStart, idxCount;
{
  if (!noRR) {
    for (p+= idxStart; idxCount; idxCount--) RELEASE(*p++);}
}

static inline void _fill(a, noRR, p, po,idxStart,idxCount, copyItems,nilVerif, fct)
CArray *a; BOOL noRR,copyItems,nilVerif; id *p; const id *po; NSUInteger idxStart,idxCount; char*fct;
{
  id o;
  if (!nilVerif && !copyItems && noRR) CGrowMutFill((id)a, idxStart, idxCount, po);
  else for  (p+= idxStart; idxCount; idxCount--) {
    if (!(o= *po++)) {
      MSReportError(MSInvalidArgumentError, MSFatalError, MSTryToInsertNilError,
                    "%s(): try to insert *nil* object at index %lu.",
                    fct,(unsigned long)idxStart);
      return;}
    if (copyItems) {
      o= COPY(o);
      if (!o) {
        MSReportError(MSMallocError, MSFatalError, MSTryToInsertNilError,
                      "%s(): copy failed at index %lu.",
                      fct,(unsigned long)idxStart);
        return;}}
    else if (!noRR) RETAIN(o);
    *p++= o;}
}

static inline void _insert(a, po,idxStart,idxCount, copyItems,nilVerif, fct)
CArray *a; const id *po; NSUInteger idxStart,idxCount; BOOL copyItems,nilVerif; char*fct;
{
  if (!a || !po || !idxCount) return;
  CGrowMutVerif((id)a, idxStart, 0, fct);
  CGrowMutExpand((id)a, idxStart, idxCount);
  _fill(a, a->flags.noRetainRelease, a->pointers, po,idxStart,idxCount, copyItems,nilVerif, fct);
}

#pragma mark c-like class methods

void CArrayFreeInside(id self)
{
  if (self) {
    CArray *a= (CArray*)self;
    _erase(a->flags.noRetainRelease, a->pointers, 0, a->count);
    CGrowFreeInside(self);}
}

BOOL CArrayIsEqual(id self, id other)
{
  return _CClassIsEqual(self,other,(CObjectEq)CArrayEquals);
}

NSUInteger CArrayHash(id self, unsigned depth)
{
  return GArrayHash(NULL, self, depth);
}

id CArrayInitCopyWithMutability(CArray *self, const CArray *copied, BOOL isMutable)
{
  if (!self) return nil;
  if (copied) {
    self->flags.noRetainRelease= copied->flags.noRetainRelease;
    self->flags.nilItems=        copied->flags.nilItems;
    // Pas de copy des items
    // Pas de nilItems verif puisque copied est cohérent
    _insert(self, copied->pointers, self->count, copied->count, NO, NO, "CArrayInitCopy");}
  if (!isMutable) CGrowSetForeverImmutable((id)self);
  return (id)self;
}
id CArrayCopy(id self)
{
  CArray *a;
  if (!self) return nil;
  a= (CArray*)MSCreateObjectWithClassIndex(CArrayClassIndex);
  return CArrayInitCopyWithMutability(a, (CArray*)self, !CGrowIsForeverImmutable(self));
}

const CString* CArrayRetainedDescription(id self)
{
  CString *s= CCreateString(20);
  CStringAppendCArrayDescription(s, (CArray*)self);
  return s;
}

void CStringAppendCArrayDescription(CString *s, CArray *a) // + context de description ?
{
  CStringAppendGArrayDescription(s, NULL, (id)a);
}

#pragma mark Equality

BOOL CArrayIdenticals(const CArray *self, const CArray *anotherArray)
{
  return GArrayIdenticals(NULL, (id)self, NULL, (id)anotherArray);
}

BOOL CArrayEquals(const CArray *self, const CArray *anotherArray)
{
  return GArrayEquals(NULL, (id)self, NULL, (id)anotherArray);
}

#pragma mark Creation

CArray *CCreateArrayWithOptions(NSUInteger capacity, BOOL noRetainRelease, BOOL nilItems)
{
  CArray *a= CCreateArray(capacity);
  a->flags.noRetainRelease= noRetainRelease;
  a->flags.nilItems=        nilItems;
  return a;
}

CArray *CCreateArray(NSUInteger capacity)
{
  CArray *a= (CArray*)MSCreateObjectWithClassIndex(CArrayClassIndex);
  if (a && capacity) CGrowGrow((id)a, capacity);
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

CArray *CCreateArrayWithObjects(const id *objects, NSUInteger count, BOOL copyItems)
{
  CArray *a;
  if (!objects && count) {
    MSReportError(MSInvalidArgumentError, MSFatalError, MSNULLPointerError,
      "CCreateArrayWithObjects(): try to insert %lu objects from a NULL pointer",
      (unsigned long)count);
    return nil;}
  a= CCreateArray(count);
  _insert(a, objects, 0, count, copyItems, !a->flags.nilItems, "CCreateArrayWithObjects");
  return a;
}

CArray *CCreateSubArrayWithRange(CArray *a, NSRange rg)
{
  CArray *sub;
  if (rg.location + rg.length > a->count) {
    MSReportError(MSInvalidArgumentError, MSFatalError, MSIndexOutOfRangeError,
      "CCreateSubArrayWithRange: range [%lu %lu] %s out of range [0 %lu]",
      WLU(rg.location), WLU(rg.location+rg.length-1), WLU(a->count));
    return nil;}
  sub= CCreateArray(rg.length);
  sub->flags.noRetainRelease= a->flags.noRetainRelease;
  sub->flags.nilItems=        a->flags.nilItems;
  _insert(sub, a->pointers+rg.location, 0, rg.length, NO, NO, "CCreateArrayWithObjects");
  if (CGrowIsForeverImmutable((id)sub)) CGrowSetForeverImmutable((id)a);
  return sub;
}

#pragma mark Management

void CArrayGrow(CArray *self, NSUInteger n)
{
  CGrowGrow((id)self,n);
}

void CArrayAdjustSize(CArray *self)
{
  CGrowAdjustSize((id)self);
}

void CArraySetRetainReleaseOptionAndRetainAllObjects(CArray *self, BOOL retain)
{
  self->flags.noRetainRelease= NO;
  if (retain) {
    NSUInteger n= self->count;
    id *p= self->pointers;
    for (; n; n--) RETAIN(*p++);}
}
void CArrayUnsetRetainReleaseOptionAndReleaseAllObjects(CArray *self, BOOL release)
{
  self->flags.noRetainRelease= YES;
  if (release) {
    NSUInteger n= self->count;
    id *p= self->pointers;
    for (; n; n--) RELEASE(*p++);}
}

NSUInteger CArrayCount(const CArray *self)
{
  return (self ? self->count : 0);
}

id CArrayObjectAtIndex(const CArray *self, NSUInteger i)
{
  if (!self || i >= _CCOUNT(self)) return nil;
  return _COAI(self, i);
}

id CArrayFirstObject(const CArray *self)
{
  return GArrayFirstObject(NULL, (id)self);
}

id CArrayLastObject(const CArray *self)
{
  return GArrayLastObject(NULL, (id)self);
}

NSUInteger CArrayIndexOfIdenticalObject(const CArray *self, const id object, NSUInteger start, NSUInteger count)
{
  return GArrayIndexOfIdenticalObject(NULL, (id)self, object, start, count);
}

NSUInteger CArrayIndexOfObject(const CArray *self, const id object, NSUInteger start, NSUInteger count)
{
  return GArrayIndexOfObject(NULL, (id)self, object, start, count);
}

#pragma mark Add

void CArrayAddObject(CArray *self, id object)
{
  if (!self) return;
  _insert(self, &object, self->count, 1, NO, !self->flags.nilItems, "CArrayAddObject");
}

void CArrayAddObjects(CArray *self, const id *objects, NSUInteger nb, BOOL copyItems)
{
  if (!self) return;
  _insert(self, objects, self->count, nb, copyItems, !self->flags.nilItems, "CArrayAddObjects");
}
void CArrayAddArray(CArray *self, const CArray *other, BOOL copyItems)
{
  BOOL nilVerif;
  if (!self || !other) return;
  nilVerif= (!self->flags.nilItems && other->flags.nilItems);
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
  CGrowMutVerif((id)self, idxStart, idxCount, "CArrayRemoveObjectsInRange");
  _erase(self->flags.noRetainRelease, (p= self->pointers), idxStart, idxCount);
  CGrowMutCompress((id)self, idxStart, idxCount);
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

void CArrayReplaceObjectsInRange(CArray *self, const id *objects, NSRange rg, BOOL copyItems)
{
  char *fct= "CArrayReplaceObjectsInRange";
  NSUInteger idxStart,idxCount; BOOL noRR; id *p;
  if (!self) return;
  CGrowMutVerif((id)self, (idxStart= rg.location), (idxCount= rg.length), "CArrayReplaceObjectsInRange");
  _erase((noRR= self->flags.noRetainRelease), (p= self->pointers), idxStart, idxCount);
  _fill(self, noRR, p, objects,idxStart,idxCount, copyItems,!self->flags.nilItems, fct);
}

#pragma mark Insert

void CArrayInsertObjectAtIndex(CArray *self, id object, NSUInteger i)
{
  if (!object) return;
  CArrayInsertObjectsInRange(self, &object, NSMakeRange(i,1), NO);
}

void CArrayInsertObjectsInRange(CArray *self, const id *objects, NSRange rg, BOOL copyItems)
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

/* TODO:
 // these 2 function should be replaced by "MSCString" functions :
 NSString *CArrayToString(CArray *self);
 NSString *CArrayJsonRepresentation(CArray *self);
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
CString *CArrayToString(CArray *self)
  {
  return nil;
  self= nil;
  }

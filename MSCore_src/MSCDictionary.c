/* MSCDictionary.c
 
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

#define CDICT_KEY_HASH(k)       (((CDictionary*)self)->flag.keyAsSimplePtr ? MSPointerHash(k) : HASH(k))
#define CDICT_KEY_COPY(k)       (((CDictionary*)self)->flag.keyAsSimplePtr ? k : COPY(k))
#define CDICT_KEY_EQUALS(a, b)  (((CDictionary*)self)->flag.keyAsSimplePtr ? a == b : ISEQUAL(a, b))
#define CDICT_KEY_RETAIN(k)     (((CDictionary*)self)->flag.keyAsSimplePtr ? k : RETAIN(k))
#define CDICT_KEY_RELEASE(k)    (((CDictionary*)self)->flag.keyAsSimplePtr ? (void)0 : RELEASE(k))
#define CDICT_OBJ_EQUALS(a, b)  (((CDictionary*)self)->flag.objAsSimplePtr ? a == b : ISEQUAL(a, b))
#define CDICT_OBJ_RETAIN(o)     (((CDictionary*)self)->flag.objAsSimplePtr ? o : RETAIN(o))
#define CDICT_OBJ_RELEASE(o)    (((CDictionary*)self)->flag.objAsSimplePtr ? (void)0 : RELEASE(o))

typedef struct _nodeStruct {
   id key;
   id value;
   struct _nodeStruct *next;}
_node;

#pragma mark static

static inline void _grow(id self, NSUInteger n, NSUInteger count, NSUInteger unitSize, NSUInteger *size, _node ***ptr)
  {
  NSUInteger newSize, i, newi; _node *j, *next, **ns= *ptr;
  if (self && n && count + n > *size) {
    newSize= MSCapacityForCount(count + n);
    if (!(*ptr= MSCalloc(newSize, unitSize, "_grow()"))) {
      MSReportError(MSMallocError, MSFatalError, MSReallocErrorCode, "_grow() callocation error");
      return;}
    for (i= 0; i<*size; i++) {
      for (j= ns[i]; j!=NULL; j= next) {
        newi= CDICT_KEY_HASH(j->key) % newSize;
        next= j->next;
        j->next= (*ptr)[newi];
        (*ptr)[newi]= j;}}
    *size= newSize;
    MSFree(ns, "CDictionary _grow");}
  }


static inline void _setObjectForKey(CDictionary *self, id o, id k, BOOL fromDict)
{
  NSUInteger h;
  NSUInteger i;
  _node *j,**pj;
  BOOL fd;

  if (!self || !k) return;
  CGrowMutVerif((id)self, 0, 0, "CDictionarySetObjectForKey");
  h= CDICT_KEY_HASH(k);
  fd= NO;
  if (self->nBuckets && !fromDict) {
    i= h % self->nBuckets;
    // k may already exist
    for (j= *(pj= (_node**)&self->buckets[i]); !fd && j!=NULL; j= *(pj= &j->next)) {
      if (CDICT_KEY_EQUALS(j->key, k)) {
        void *oldKey=   j->key;
        void *oldValue= j->value;
        fd= YES;
        if (o) { // replace the node
          j->key=   CDICT_KEY_COPY(k);
          j->value= CDICT_OBJ_RETAIN(o);}
        else { // remove the node
          *pj= j->next;
          MSFree(j, "CDictionarySetObjectForKey");
          self->count--;}
        CDICT_KEY_RELEASE(oldKey);
        CDICT_OBJ_RELEASE(oldValue);}}}
  if (!fd && o) { // add a new node
    // may grown
    if (!fromDict)
      _grow((id)self, 1, self->count, sizeof(_node*), &self->nBuckets, (_node***)&self->buckets);
    i= h % self->nBuckets;
    if (!(j= MSMalloc(sizeof(_node),"CDictionarySetObjectForKey"))) {
      MSReportError(MSMallocError, MSFatalError, MSMallocErrorCode,
        "CDictionarySetObjectForKey() allocation error");
      return;}
    j->key=   (fromDict ? CDICT_KEY_RETAIN(k) : CDICT_KEY_COPY(k));
    j->value= CDICT_OBJ_RETAIN(o);
    j->next= self->buckets[i];
    self->buckets[i]= j;
    self->count++;}
}

#pragma mark c-like class methods

void CDictionaryFreeInside(id s)
{
  if (s) {
    CDictionary *self= (CDictionary*)s;
    NSUInteger i, n; _node *j,*nj;
    for (n= self->nBuckets, i= 0; i < n; i++) {
      for (j= self->buckets[i]; j != NULL; j= nj) {
        CDICT_KEY_RELEASE(j->key);
        CDICT_OBJ_RELEASE(j->value);
        nj= j->next; MSFree(j, "CDictionaryFreeInside");}}
    MSFree(self->buckets, "CDictionaryFreeInside"); self->buckets= NULL;}
}
void CDictionaryFree(id self)
{
  CDictionaryFreeInside(self);
  MSFree(self, "CDictionaryFree() [self]");
}

BOOL CDictionaryIsEqual(id self, id other)
{
  return _CClassIsEqual(self,other,(CObjectEq)CDictionaryEquals);
}

NSUInteger CDictionaryHash(id self, unsigned depth)
{
  NSUInteger count= ((CDictionary*)self)->count;
  return count;
  MSUnused(depth);
// TOTO: find something cool !
/*
  if (!count || depth == MSMaxHashingHop) return count;
  
  depth++;
  
  switch (count) {
    case 1:
      return count ^
        HASHDEPTH(((CDictionary*)self)->pointers[0], depth);
    case 2:
      return count ^
        HASHDEPTH(((CArray*)self)->pointers[0], depth) ^
        HASHDEPTH(((CArray*)self)->pointers[1], depth);
    default:
      return count ^
        HASHDEPTH(((CArray*)self)->pointers[0], depth) ^
        HASHDEPTH(((CArray*)self)->pointers[count/2], depth) ^
        HASHDEPTH(((CArray*)self)->pointers[count-1], depth);}
*/
}

id CDictionaryInitCopy(CDictionary *self, const CDictionary *copied, BOOL copyItems)
{
  CDictionaryEnumerator *de; id k,o;
  if (!self) return nil;
  if (copied && copied->count) {
    CDictionaryGrow(self, copied->count);
    de= CDictionaryEnumeratorAlloc(copied);
    while ((k= CDictionaryEnumeratorNextKey(de))) {
      if ((o= CDictionaryEnumeratorCurrentObject(de)) && copyItems) o= COPY(o);
      _setObjectForKey(self,o,k,YES);}
    CDictionaryEnumeratorFree(de);}
  return (id)self;
}
id CDictionaryCopy(id self)
{
  CDictionary *d;
  if (!self) return nil;
  d= CCreateDictionary(((CDictionary*)self)->count);
  return CDictionaryInitCopy(d, (CDictionary*)self, NO);
}

#pragma mark Equality

BOOL CDictionaryEquals(const CDictionary *self, const CDictionary *other)
{
  BOOL ret= NO;
  if (self == other) return YES;
  if (self && other) {
    NSUInteger i, n; _node *j;
    if (self->count == other->count) ret= YES;
    for (n= self->nBuckets, i= 0; ret && i < n; i++) {
      for (j= self->buckets[i]; ret && j != NULL; j= j->next) {
        ret= CDICT_OBJ_EQUALS(j->value, CDictionaryObjectForKey(other, j->key)); }}}
  return ret;
}

#pragma mark Creation

CDictionary *CCreateDictionary(NSUInteger capacity)
{
  CDictionary *d;
  d= (CDictionary*)MSCreateObjectWithClassIndex(CDictionaryClassIndex);
  if (d && capacity) CDictionaryGrow(d, capacity);
  return d;
}
CDictionary *CCreateDictionaryWithObjectsAndKeys(const id *os, const id *ks, NSUInteger n)
{
  CDictionary *d; NSUInteger i;
  d= (CDictionary*)MSCreateObjectWithClassIndex(CDictionaryClassIndex);
  if (d && n) {
    CDictionaryGrow(d, n);
    for (i= 0; i<n; i++) {
      CDictionarySetObjectForKey(d,os[i],ks[i]);}}
  return d;
}

CDictionary *CCreateDictionaryWithDictionaryCopyItems(const CDictionary *src, BOOL cpy)
{
  CDictionary *d;
  d= CCreateDictionary(CDictionaryCount(src));
  if (!d) return NULL;
  CDictionaryInitCopy(d, src, cpy);
  return d;
}

#pragma mark Management

BOOL CDictionaryIsMutable(CDictionary *self)
{
  return CGrowIsMutable((id)self);
}

void CDictionarySetImmutable(CDictionary *self)
{
  CGrowSetImmutable((id)self);
}

void CDictionaryGrow(CDictionary *self, NSUInteger n)
{
  _grow((id)self, n, self->count, sizeof(_node*), &self->nBuckets, (_node***)&self->buckets);
}

void CDictionaryAdjustSize(CDictionary *self)
{
  self= nil; // no warning
}

#pragma mark Informations

NSUInteger CDictionaryCount(const CDictionary *self)
{
  return !self ? 0 : self->count;
}

id CDictionaryObjectForKey(const CDictionary *self, id k)
{
  id o= nil;
  NSUInteger i;
  _node *j;
  if (!self || !k || !self->nBuckets) return nil;
  i= CDICT_KEY_HASH(k) % self->nBuckets;
  for (j= self->buckets[i]; !o && j!=NULL; j= j->next) {
    if (CDICT_KEY_EQUALS(j->key, k)) o= j->value;}
  return o;
}

#pragma mark Setters

void CDictionarySetObjectForKey(CDictionary *self, id o, id k)
{
  _setObjectForKey(self,o,k,NO);
}

#pragma mark Enumeration

CDictionaryEnumerator *CDictionaryEnumeratorAlloc(const CDictionary *self)
{
  CDictionaryEnumerator *de;
  if (!self) return NULL;
  if (!(de= MSMalloc(sizeof(CDictionaryEnumerator),"CDictionaryEnumerator"))) {
    MSReportError(MSMallocError, MSFatalError, MSMallocErrorCode,
      "CDictionaryEnumerator allocation error");
    return NULL;}
  de->dictionary= (CDictionary*)RETAIN(self);
  de->iBucket=    0;
  de->jnode=      NULL;
  return de;
}

void CDictionaryEnumeratorFree(CDictionaryEnumerator *de)
{
  if (de) RELEASE(de->dictionary);
  MSFree(de, "CDictionaryEnumeratorFree");
}

static inline void _moveForward(CDictionaryEnumerator *de)
{
  NSUInteger n;
//NSUInteger i= de->iBucket;
  if (de && de->dictionary && (n= de->dictionary->nBuckets)) {
    if (de->jnode != NULL) de->jnode= ((_node*)(de->jnode))->next;
    while (de->jnode == NULL && de->iBucket < n) {
      de->jnode= de->dictionary->buckets[de->iBucket++];}}
//if (i==de->iBucket) printf(" +"); else printf("\n%lu",de->iBucket);
}
id CDictionaryEnumeratorNextObject(CDictionaryEnumerator *de)
{
  _moveForward(de);
  return CDictionaryEnumeratorCurrentObject(de);
}
id CDictionaryEnumeratorNextKey(CDictionaryEnumerator *de)
{
  _moveForward(de);
  return CDictionaryEnumeratorCurrentKey(de);
}
id CDictionaryEnumeratorCurrentObject(CDictionaryEnumerator *de)
{
  return !de || !de->jnode ? nil : ((_node*)(de->jnode))->value;
}
id CDictionaryEnumeratorCurrentKey(CDictionaryEnumerator *de)
{
  return !de || !de->jnode ? nil : ((_node*)(de->jnode))->key;
}

CArray *CCreateArrayOfDictionaryKeys(CDictionary *d)
{
  CArray *a; CDictionaryEnumerator *de; id k;
  if (!d) return NULL;
  a= CCreateArray(CDictionaryCount(d));
  de= CDictionaryEnumeratorAlloc(d);
  while ((k= CDictionaryEnumeratorNextKey(de))) CArrayAddObject(a, k);
  CDictionaryEnumeratorFree(de);
  return a;
}

CArray *CCreateArrayOfDictionaryObjects(CDictionary *d)
{
  CArray *a; CDictionaryEnumerator *de; id o;
  if (!d) return NULL;
  a= CCreateArray(CDictionaryCount(d));
  de= CDictionaryEnumeratorAlloc(d);
  while ((o= CDictionaryEnumeratorNextObject(de))) CArrayAddObject(a, o);
  CDictionaryEnumeratorFree(de);
  return a;
}

#pragma mark Description

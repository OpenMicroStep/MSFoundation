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

#define CDICT_KEYS_ARE_OBJS(D) (((CDictionary*)(D))->flags.keyType==CDictionaryObject)
#define CDICT_OBJS_ARE_OBJS(D) (((CDictionary*)(D))->flags.objType==CDictionaryObject)
#define CDICT_KEYS_ARE_NATS(D) (((CDictionary*)(D))->flags.keyType==CDictionaryNatural)
#define CDICT_OBJS_ARE_NATS(D) (((CDictionary*)(D))->flags.objType==CDictionaryNatural)

#define _NOT_A_MARKER(IS_NAT) ((IS_NAT) ? (void*)NSNotFound : nil)
#define _HASH(   IS_OBJ,X)    ((IS_OBJ) ? HASH(X)           : MSPointerHash(X))
#define _COPY(   IS_OBJ,X)    ((IS_OBJ) ? COPY(X)           : (X))
#define _EQUALS( IS_OBJ,A,B)  ((IS_OBJ) ? ISEQUAL((A),(B))  : (A)==(B))
#define _RETAIN( IS_OBJ,X)    ((IS_OBJ) ? RETAIN(X)         : (X))
#define _RELEASE(IS_OBJ,X)    ((IS_OBJ) ? RELEASE(X)        : (void)0)

#define CDICT_NOT_A_KEY(D)      _NOT_A_MARKER(CDICT_KEYS_ARE_NATS(D))
#define CDICT_KEY_HASH(D,K)     _HASH(   CDICT_KEYS_ARE_OBJS(D),(K))
#define CDICT_KEY_COPY(D,K)     _COPY(   CDICT_KEYS_ARE_OBJS(D),(K))
#define CDICT_KEY_EQUALS(D,A,B) _EQUALS( CDICT_KEYS_ARE_OBJS(D),(A),(B))
#define CDICT_KEY_RETAIN(D,K)   _RETAIN( CDICT_KEYS_ARE_OBJS(D),(K))
#define CDICT_KEY_RELEASE(D,K)  _RELEASE(CDICT_KEYS_ARE_OBJS(D),(K))

#define CDICT_NOT_AN_OBJ(D)     _NOT_A_MARKER(CDICT_OBJS_ARE_NATS(D))
#define CDICT_OBJ_EQUALS(D,A,B) _EQUALS( CDICT_OBJS_ARE_OBJS(D),(A),(B))
#define CDICT_OBJ_RETAIN(D,O)   _RETAIN( CDICT_OBJS_ARE_OBJS(D),(O))
#define CDICT_OBJ_RELEASE(D,O)  _RELEASE(CDICT_OBJS_ARE_OBJS(D),(O))

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
        newi= CDICT_KEY_HASH(self,j->key) % newSize;
        next= j->next;
        j->next= (*ptr)[newi];
        (*ptr)[newi]= j;}}
    *size= newSize;
    MSFree(ns, "CDictionary _grow");}
  }

static inline id _setObjectForKey(CDictionary *self, id o, id k, BOOL fromDict, BOOL ifAbsent, CDictionarySetHandler hndl, void *arg, BOOL *pAdded)
{
  NSUInteger h;
  NSUInteger i;
  _node *j,**pj;
  BOOL fd, added= NO;
  id obj= nil;

  if (!self || k==CDICT_NOT_A_KEY(self)) return nil;
  CGrowMutVerif((id)self, 0, 0, "CDictionarySetObjectForKey");
  h= CDICT_KEY_HASH(self,k);
  fd= NO;
  if (self->nBuckets && !fromDict) {
    i= h % self->nBuckets;
    // k may already exist
    for (j= *(pj= (_node**)&self->buckets[i]); !fd && j!=NULL;) {
      if (CDICT_KEY_EQUALS(self, j->key, k)) {
        fd= YES;
        if (ifAbsent) obj= j->value;
        else if (o!=CDICT_NOT_AN_OBJ(self)) { // replace the node
          id oldValue= j->value;
          j->value= CDICT_OBJ_RETAIN(self, o);
          CDICT_OBJ_RELEASE(self, oldValue);
          obj= j->value; added= YES;}
        else { // remove the node
          *pj= j->next;
          CDICT_KEY_RELEASE(self, j->key);
          CDICT_OBJ_RELEASE(self, j->value);
          MSFree(j, "CDictionarySetObjectForKey");
          self->count--;}}
      else j= *(pj= &j->next);}}
  if (!fd && o==CDICT_NOT_AN_OBJ(self) && hndl) { // ask the object to the handler
    o= hndl(arg);}
  if (!fd && o!=CDICT_NOT_AN_OBJ(self)) { // add a new node
    // may grown
    if (!fromDict)
      _grow((id)self, 1, self->count, sizeof(_node*), &self->nBuckets, (_node***)&self->buckets);
    i= h % self->nBuckets;
    if (!(j= MSMalloc(sizeof(_node),"CDictionarySetObjectForKey"))) {
      MSReportError(MSMallocError, MSFatalError, MSMallocErrorCode,
        "CDictionarySetObjectForKey() allocation error");
      return nil;}
    j->key=   (fromDict ? CDICT_KEY_RETAIN(self, k) : CDICT_KEY_COPY(self, k));
    j->value= CDICT_OBJ_RETAIN(self, o);
    j->next= self->buckets[i];
    self->buckets[i]= j;
    self->count++;
    obj= j->value; added= YES;}
  if (pAdded) *pAdded= added;
  return obj;
}

#pragma mark c-like class methods

void CDictionaryFreeInside(id s)
{
  if (s) {
    CDictionary *self= (CDictionary*)s;
    NSUInteger i, n; _node *j,*nj;
    for (n= self->nBuckets, i= 0; i < n; i++) {
      for (j= self->buckets[i]; j != NULL; j= nj) {
        CDICT_KEY_RELEASE(self, j->key);
        CDICT_OBJ_RELEASE(self, j->value);
        nj= j->next; MSFree(j, "CDictionaryFreeInside");}}
    MSFree(self->buckets, "CDictionaryFreeInside"); self->buckets= NULL;}
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

id CDictionaryInitCopyWithMutability(CDictionary *self, const CDictionary *copied, BOOL isMutable)
{
  if (!self) return nil;
  if (copied) {
    self= (CDictionary*)CDictionaryInitCopy(self, copied, NO);}
  if (!isMutable) CGrowSetForeverImmutable((id)self);
  return (id)self;
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
      _setObjectForKey(self,o,k,YES,NO,NULL,NULL,NULL);}
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

typedef struct {
  const void *source;
  CHAI chai;
  MSByte counter;
} _indentChaiSrc;

unichar _indentChai(const void *src, NSUInteger *pos) {
  unichar c; _indentChaiSrc *s;
  s= (_indentChaiSrc *)src;
  if(s->counter > 0) {
    c= ' ';
    s->counter--; }
  else {
    c= s->chai(s->source, pos);
    if(c == (unichar)'\n') {
      s->counter= 2; }}
  return c;
}

// TODO:
// CStringAppendCDictionaryDescription(CString *s, CDictionary *s, long indentWhites)
// Et c'est cette fonction qui devient polymorphe.

const CString* CDictionaryRetainedDescription(id self)
{
  if(!self) return nil;
  else {
    id k, o; const CString *d; SES ses; _indentChaiSrc identChai;
    CDictionaryEnumerator *e= CDictionaryEnumeratorAlloc((CDictionary*)self);
    CString *s= CCreateString(0);
    CStringAppendCharacter(s, '{');
    CStringAppendCharacter(s, '\n');
    while ((k= CDictionaryEnumeratorNextKey(e)) && (o= CDictionaryEnumeratorCurrentObject(e))) {
      CStringAppendCharacter(s, ' ');
      CStringAppendCharacter(s, ' ');
      d= DESCRIPTION(k);
      CStringAppendString(s, d);
      RELEASE(d);
      CStringAppendCharacter(s, ' ');
      CStringAppendCharacter(s, '=');
      CStringAppendCharacter(s, ' ');
      d= DESCRIPTION(o);
      ses= CStringSES(d);
      identChai.source= ses.source;
      identChai.chai= ses.chai;
      identChai.counter= 0;
      ses.encoding= 0;
      ses.source= &identChai;
      ses.chai= _indentChai;
      CStringAppendSES(s, ses);
      RELEASE(d);
      CStringAppendCharacter(s, '\n');
    }
    CDictionaryEnumeratorFree(e);
    CStringAppendCharacter(s, '}');
    return s;}
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
        ret= CDICT_OBJ_EQUALS(self, j->value, CDictionaryObjectForKey(other, j->key)); }}}
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
MSCoreExtern CDictionary *CCreateDictionaryWithOptions(NSUInteger capacity, CDictionaryElementType keyType, CDictionaryElementType objType)
{
  CDictionary *d;
  if ((d= CCreateDictionary(capacity))) {
    d->flags.keyType= keyType;
    d->flags.objType= objType;}
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
  NSUInteger i; BOOL fd;
  _node *j;
  if (!self || k==CDICT_NOT_A_KEY(self) || !self->nBuckets) return CDICT_NOT_AN_OBJ(self);
  i= CDICT_KEY_HASH(self, k) % self->nBuckets;
  for (j= self->buckets[i], fd= NO; !fd && j!=NULL; j= j->next) {
    if (CDICT_KEY_EQUALS(self, j->key, k)) {fd=YES; o= j->value;}}
  return !fd?CDICT_NOT_AN_OBJ(self):o;
}

#pragma mark Setters

void CDictionarySetObjectForKey(CDictionary *self, id o, id k)
{
  _setObjectForKey(self,o,k,NO,NO,NULL,NULL,NULL);
}
id CDictionarySetObjectIfKeyAbsent(CDictionary *self, id o, id k, BOOL *added)
{
  return _setObjectForKey(self,o,k,NO,YES,NULL,NULL,added);
}
id CDictionarySetObjectFromHandlerIfKeyAbsent(CDictionary *self, CDictionarySetHandler h, void *arg, id k, BOOL *added)
{
  return _setObjectForKey(self,CDICT_NOT_AN_OBJ(self),k,NO,YES,h,arg,added);
}

#pragma mark Enumeration

// We only provide the allocation concept due to the flexibility it provides
// If there is any proven performances issues, we will reconsider this decision
CDictionaryEnumerator *CDictionaryEnumeratorAlloc(const CDictionary *self)
{
  CDictionaryEnumerator *de;
  if (!self) return NULL;
  if (!(de= MSMalloc(sizeof(CDictionaryEnumerator),"CDictionaryEnumerator"))) {
    MSReportError(MSMallocError, MSFatalError, MSMallocErrorCode,
      "CDictionaryEnumerator allocation error");
    return NULL;}
  de->dictionary= self;
  de->iBucket=    0;
  de->jnode=      NULL;
  return de;
}

void CDictionaryEnumeratorFree(CDictionaryEnumerator *de)
{
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
  return !de ? nil : !de->jnode ? CDICT_NOT_AN_OBJ(de->dictionary) : ((_node*)(de->jnode))->value;
}
id CDictionaryEnumeratorCurrentKey(CDictionaryEnumerator *de)
{
  return !de ? nil : !de->jnode ? CDICT_NOT_A_KEY(de->dictionary) : ((_node*)(de->jnode))->key;
}

CArray *CCreateArrayOfDictionaryKeys(CDictionary *d)
{
  CArray *a; BOOL noRetainRelease, nilItems; CDictionaryEnumerator *de; id k,stop;
  if (!d) return NULL;
  noRetainRelease= d->flags.keyType!=CDictionaryObject;
  nilItems=        d->flags.keyType==CDictionaryNatural;
  a= CCreateArrayWithOptions(CDictionaryCount(d), noRetainRelease, nilItems);
  de= CDictionaryEnumeratorAlloc(d);
  stop= CDICT_NOT_A_KEY(d);
  while ((k= CDictionaryEnumeratorNextKey(de))!=stop) CArrayAddObject(a, k);
  CDictionaryEnumeratorFree(de);
  return a;
}

CArray *CCreateArrayOfDictionaryObjects(CDictionary *d)
{
  CArray *a; BOOL noRetainRelease, nilItems; CDictionaryEnumerator *de; id o,stop;
  if (!d) return NULL;
  noRetainRelease= d->flags.objType!=CDictionaryObject;
  nilItems=        d->flags.objType==CDictionaryNatural;
  a= CCreateArrayWithOptions(CDictionaryCount(d), noRetainRelease, nilItems);
  de= CDictionaryEnumeratorAlloc(d);
  stop= CDICT_NOT_AN_OBJ(d);
  while ((o= CDictionaryEnumeratorNextObject(de))!=stop) CArrayAddObject(a, o);
  CDictionaryEnumeratorFree(de);
  return a;
}

#pragma mark Description

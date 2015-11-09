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

#pragma mark CDictionary OBJS or NATS

#define CDICT(D)               ((CDictionary*)(D))
#define CDICT_KEYS_ARE_OBJS(D) (CDICT(D)->flags.keyType==CDictionaryObject)
#define CDICT_OBJS_ARE_OBJS(D) (CDICT(D)->flags.objType==CDictionaryObject)
#define CDICT_KEYS_ARE_NATS(D) (CDICT(D)->flags.keyType==CDictionaryNatural)
#define CDICT_OBJS_ARE_NATS(D) (CDICT(D)->flags.objType==CDictionaryNatural)

#define _NOT_A_MARKER(IS_NAT)  ((IS_NAT) ? (void*)NSNotFound : nil)
#define _EQUALS( IS_OBJ,A,B)   ((IS_OBJ) ? ISEQUAL((A),(B))  : (A)==(B))

#define CDICT_NOT_A_KEY(D)     _NOT_A_MARKER(CDICT_KEYS_ARE_NATS(D))

typedef struct _nodeStruct {
   id key;
   id value;
   struct _nodeStruct *next;}
_node;

#pragma mark Generic

#define _CCOUNT(  d) (CDICT(d)->count)
#define _GCOUNT(g,d) (g->count(d))
#define GDICT_COUNT(g,d) (!g ? _CCOUNT(d) : _GCOUNT(g,d))

#define _CENUM(  d,de) (de= CMakeDictionaryEnumerator((CDictionary*)d), (id)&de)
#define _GENUM(g,d   ) (g->keyEnumerator(d))
#define GDICT_ENUM(g,d,de) (!g ? _CENUM(d,de) : _GENUM(g,d))

#define _CNEXTKEY(  e) (CDictionaryEnumeratorNextKey((CDictionaryEnumerator*)(e)))
#define _GNEXTKEY(g,e) (g->nextKey(e))
#define GDICT_NEXTKEY(g,e) (!g ? _CNEXTKEY(e) : _GNEXTKEY(g,e))

#define GDICT_STOPKEY(g,d) (!g ? CDICT_NOT_A_KEY(d) : nil)

#define _COFK(e,d,k) (e ? ((_node*)(((CDictionaryEnumerator*)(e))->jnode))->value : CDictionaryObjectForKey(CDICT(d),k))
#define _GOFK(g,d,k) (g->objectForKey(d,k))
#define GDICT_OFK(g,e,d,k) (!g ? _COFK(e,d,k) : _GOFK(g,d,k))

NSUInteger GDictionaryHash(gdict_pfs_t fs, const id dict, unsigned depth)
{
  return GDICT_COUNT(fs, dict);
  MSUnused(depth);
}

BOOL GDictionaryEquals(gdict_pfs_t fs1, const id dd1, gdict_pfs_t fs2, const id dd2)
{
  id e,k,kstop; CDictionaryEnumerator de; id d1= dd1, d2= dd2; BOOL objs= YES;
  if ( d1 ==  d2) return YES;
  if (!d1 || !d2) return NO;
  if (GDICT_COUNT(fs1, d1) != GDICT_COUNT(fs2, d2)) return NO;
  if (!fs1 && !fs2) { // les types doivent être les mêmes
    if (CDICT(d1)->flags.keyType != CDICT(d2)->flags.keyType) return NO;
    if (CDICT(d1)->flags.objType != CDICT(d2)->flags.objType) return NO;
    objs= CDICT(d1)->flags.objType==CDictionaryObject;}
  else if (!fs1 && (!CDICT_KEYS_ARE_OBJS(d1) || !CDICT_OBJS_ARE_OBJS(d1))) return NO;
  else if (!fs2 && (!CDICT_KEYS_ARE_OBJS(d2) || !CDICT_OBJS_ARE_OBJS(d2))) return NO;
  // On privilégie l'énumération du CDictionary
  if (fs1 && !fs2) {gdict_pfs_t fs= fs1; const id d= d1; fs1= fs2; d1= d2; fs2= fs; d2= d;}
  e= GDICT_ENUM(fs1, d1, de); kstop= GDICT_STOPKEY(fs1,d1);
  while ((k= GDICT_NEXTKEY(fs1, e))!=kstop) {
    if (!_EQUALS(objs, GDICT_OFK(fs1, e, d1, k), GDICT_OFK(fs2, nil, d2, k))) return NO;}
  return YES;
}

typedef struct {
  const void *source;
  CHAI chai;
  MSByte counter;}
_indentChaiSrc;

unichar _indentChai(const void *src, NSUInteger *pos)
{
  unichar c; _indentChaiSrc *s;
  s= (_indentChaiSrc *)src;
  if (s->counter > 0) {
    c= ' ';
    s->counter--;}
  else {
    c= s->chai(s->source, pos);
    if (c == (unichar)'\n') {
      s->counter= 2;}}
  return c;
}

// TODO: long indentWhites dans context de description ?
// TODO: non cross-references safe.
void CStringAppendGDictionaryDescription(CString *s, gdict_pfs_t fs, const id dict)
{
  if (!dict) CStringAppendFormat(s,"nil");
  else {
    CDictionaryEnumerator de; id e,k,kstop; BOOL keysAreObjs= YES, objsAreObjs= YES;
    CStringAppendFormat(s,"{\n");
    if (!fs) {
      keysAreObjs= CDICT(dict)->flags.keyType==CDictionaryObject;
      objsAreObjs= CDICT(dict)->flags.objType==CDictionaryObject;}
    e= GDICT_ENUM(fs, dict, de);  kstop= GDICT_STOPKEY(fs,dict);
    while ((k= GDICT_NEXTKEY(fs, e))!=kstop) {
      const CString *d;
      CStringAppendFormat(s,"  ");
      // TODO: APPEND_DESCRIPTION(s,k);
      // TODO: Si k not an obj, ne pas utiliser description !
      d= DESCRIPTION(k);
      if (!d) CStringAppendFormat(s,"nil");
      else CStringAppendString(s, d);
      RELEASE(d);
      CStringAppendFormat(s," = ");
      // TODO: Si o not an obj, ne pas utiliser description !
      d= DESCRIPTION(GDICT_OFK(fs, e, dict, k));
      if (!d) CStringAppendFormat(s,"nil");
      else {
        SES ses; _indentChaiSrc identChai;
        ses= CStringSES(d);
        identChai.source= ses.source;
        identChai.chai= ses.chai;
        identChai.counter= 0;
        ses.encoding= 0;
        ses.source= &identChai;
        ses.chai= _indentChai;
        CStringAppendSES(s, ses);}
      RELEASE(d);
      CStringAppendCharacter(s, '\n');}
    CStringAppendCharacter(s, '}');}
}

#pragma mark CDictionary

#define _KHASH(  IS_OBJ,X)    ((IS_OBJ) ? HASH(X)           : MSPointerHash(X))
#define _COPY(   IS_OBJ,X)    ((IS_OBJ) ? COPY(X)           : (X))
#define _RETAIN( IS_OBJ,X)    ((IS_OBJ) ? RETAIN(X)         : (X))
#define _RELEASE(IS_OBJ,X)    ((IS_OBJ) ? RELEASE(X)        : (void)0)

#define CDICT_KEY_HASH(D,K)     _KHASH(  CDICT_KEYS_ARE_OBJS(D),(K))
#define CDICT_KEY_COPY(D,K)     _COPY(   CDICT_KEYS_ARE_OBJS(D),(K))
#define CDICT_KEY_EQUALS(D,A,B) _EQUALS( CDICT_KEYS_ARE_OBJS(D),(A),(B))
#define CDICT_KEY_RETAIN(D,K)   _RETAIN( CDICT_KEYS_ARE_OBJS(D),(K))
#define CDICT_KEY_RELEASE(D,K)  _RELEASE(CDICT_KEYS_ARE_OBJS(D),(K))

#define CDICT_NOT_AN_OBJ(D)     _NOT_A_MARKER(CDICT_OBJS_ARE_NATS(D))
#define CDICT_OBJ_EQUALS(D,A,B) _EQUALS( CDICT_OBJS_ARE_OBJS(D),(A),(B))
#define CDICT_OBJ_RETAIN(D,O)   _RETAIN( CDICT_OBJS_ARE_OBJS(D),(O))
#define CDICT_OBJ_RELEASE(D,O)  _RELEASE(CDICT_OBJS_ARE_OBJS(D),(O))

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
  return GDictionaryHash(NULL, self, depth);
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
  CDictionaryEnumerator de; id k,o;
  if (!self) return nil;
  if (copied && copied->count) {
    CDictionaryGrow(self, copied->count);
    de= CMakeDictionaryEnumerator(copied);
    while ((k= CDictionaryEnumeratorNextKey(&de))) {
      if ((o= CDictionaryEnumeratorCurrentObject(de)) && copyItems) o= COPY(o);
      _setObjectForKey(self,o,k,YES,NO,NULL,NULL,NULL);}}
  return (id)self;
}
id CDictionaryCopy(id self)
{
  CDictionary *d, *s;
  if (!(s= (CDictionary*)self)) return nil;
  d= CCreateDictionaryWithOptions(s->count, s->flags.keyType, s->flags.objType);
  return CDictionaryInitCopy(d, s, NO);
}

CArray* CCreateArrayOfDictionarySubs(id self, mutable CDictionary *ctx)
{
  return CCreateArrayOfDictionaryObjects((CDictionary*)self);
  MSUnused(ctx);
}

void CDictionaryDescribe(id self, id result, int level, mutable CDictionary *ctx)
{
  gdict_pfs_t fs= nil;
  id dict= self;
  CString *s= (CString*)result;
  NSUInteger i; CDictionaryEnumerator de; id e,k,kstop; BOOL keysAreObjs= YES, objsAreObjs= YES;
  CStringAppendCharacter(s, '{');
  if (!fs) {
    keysAreObjs= CDICT(dict)->flags.keyType==CDictionaryObject;
    objsAreObjs= CDICT(dict)->flags.objType==CDictionaryObject;}
  e= GDICT_ENUM(fs, dict, de);  kstop= GDICT_STOPKEY(fs,dict);
  while ((k= GDICT_NEXTKEY(fs, e))!=kstop) {
    CStringAppendCharacter(s, '\n');
    for (i= 0; i<=level; i++) CStringAppendLiteral(s,"  ");
    // TODO: Si k not an obj, ne pas utiliser description !
    CDescribe(k, result, level+1, ctx);
    CStringAppendLiteral(s,": ");
    // TODO: Si o not an obj, ne pas utiliser description !
    CDescribe(GDICT_OFK(fs, e, dict, k), result, level+1, ctx);
    CStringAppendCharacter(s, ';');}
  CStringAppendCharacter(s, '}');
}

const CString* CDictionaryRetainedDescription(id self)
{
  CString *s= CCreateString(20);
  CStringAppendCDictionaryDescription(s, (CDictionary*)self);
  return s;
}

void CStringAppendCDictionaryDescription(CString *s, CDictionary *d) // + context de description ?
{
  CStringAppendGDictionaryDescription(s, NULL, (id)d);
}

#pragma mark Equality

BOOL CDictionaryEquals(const CDictionary *self, const CDictionary *other)
{
  return GDictionaryEquals(NULL, (id)self, NULL, (id)other);
/*
  BOOL ret= NO;
  if (self == other) return YES;
  if (self && other) {
    NSUInteger i, n; _node *j;
    if (self->count == other->count) ret= YES;
    for (n= self->nBuckets, i= 0; ret && i < n; i++) {
      for (j= self->buckets[i]; ret && j != NULL; j= j->next) {
        ret= CDICT_OBJ_EQUALS(self, j->value, CDictionaryObjectForKey(other, j->key)); }}}
  return ret;
*/
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

CDictionaryEnumerator CMakeDictionaryEnumerator(const CDictionary *d)
{
  CDictionaryEnumerator de;
  de.dictionary= d;
  de.iBucket=    0;
  de.jnode=      NULL;
  return de;
}

static inline void _moveForward(CDictionaryEnumerator *de)
{
  if (de) {
    NSUInteger n;
    if (de->jnode != NULL) de->jnode= ((_node*)(de->jnode))->next;
    if (de->jnode == NULL && de->dictionary && de->iBucket < (n= de->dictionary->nBuckets)) {
      do de->jnode= de->dictionary->buckets[de->iBucket++];
      while (de->jnode == NULL && de->iBucket < n);}}
}
id CDictionaryEnumeratorNextObject(CDictionaryEnumerator *de)
{
  _moveForward(de);
  return CDictionaryEnumeratorCurrentObject(*de);
}
id CDictionaryEnumeratorNextKey(CDictionaryEnumerator *de)
{
  _moveForward(de);
  return CDictionaryEnumeratorCurrentKey(*de);
}
id CDictionaryEnumeratorCurrentObject(CDictionaryEnumerator de)
{
  return !de.jnode ? CDICT_NOT_AN_OBJ(de.dictionary) : ((_node*)(de.jnode))->value;
}
id CDictionaryEnumeratorCurrentKey(CDictionaryEnumerator de)
{
  return !de.jnode ? CDICT_NOT_A_KEY(de.dictionary) : ((_node*)(de.jnode))->key;
}

CArray *CCreateArrayOfDictionaryKeys(CDictionary *d)
{
  CArray *a; BOOL noRetainRelease, nilItems; CDictionaryEnumerator de; id k,stop;
  if (!d) return NULL;
  noRetainRelease= d->flags.keyType!=CDictionaryObject;
  nilItems=        d->flags.keyType==CDictionaryNatural;
  a= CCreateArrayWithOptions(CDictionaryCount(d), noRetainRelease, nilItems);
  de= CMakeDictionaryEnumerator(d);
  stop= CDICT_NOT_A_KEY(d);
  while ((k= CDictionaryEnumeratorNextKey(&de))!=stop) CArrayAddObject(a, k);
  return a;
}

CArray *CCreateArrayOfDictionaryObjects(CDictionary *d)
{
  CArray *a; BOOL noRetainRelease, nilItems; CDictionaryEnumerator de; id o,stop;
  if (!d) return NULL;
  noRetainRelease= d->flags.objType!=CDictionaryObject;
  nilItems=        d->flags.objType==CDictionaryNatural;
  a= CCreateArrayWithOptions(CDictionaryCount(d), noRetainRelease, nilItems);
  de= CMakeDictionaryEnumerator(d);
  stop= CDICT_NOT_AN_OBJ(d);
  while ((o= CDictionaryEnumeratorNextObject(&de))!=stop) CArrayAddObject(a, o);
  return a;
}

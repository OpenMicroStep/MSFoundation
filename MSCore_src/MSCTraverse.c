// MSCTraverse.c, 150505

#include "MSCore_Private.h"

#pragma mark Traverse

CString* KJob;
CString* KCopy;
CString* KDescription;
CString* KDeep;
CString* KMutable;
CString* KRoot;
CString* KAll;
CString* KDone;
CString* KIndice;

void CTraversePrepare(id root, CArray* (*createSubs)(id, mutable CDictionary *), mutable CDictionary *ctx)
{
  mutable CDictionary *allDict;
  mutable CArray *todo; CArray *os; GArrayEnumerator ose; id o; NSUInteger n;
  if (!root) return;
  CDictionarySetObjectForKey(ctx, root, (id)KRoot);
  allDict= CCreateDictionaryWithOptions(1, CDictionaryPointer, CDictionaryNaturalNotZero);
  // todo: tous ceux de all qui restent à traiter (todo ⊂ all).
  todo= CCreateArrayWithOptions(1, YES, NO);
  CDictionarySetObjectForKey(allDict, (id)1, (id)root);
  CArrayAddObject(todo, root);
  while (CArrayCount(todo)) {
    o= CArrayObjectAtIndex(todo, 0);
    os= createSubs(o, ctx);
    ose= GMakeArrayEnumerator(nil, (id)os, 0, CArrayCount(os));
    while ((o= GArrayEnumeratorNextObject(&ose, NULL))) {
      n= (NSUInteger)CDictionaryObjectForKey(allDict, o) + 1;
      CDictionarySetObjectForKey(allDict, (id)n, o);
      if (n==1) CArrayAddObject(todo, o);}
    RELEASE(os);
    CArrayRemoveObjectAtIndex(todo, 0);}
  CDictionarySetObjectForKey(ctx, (id)allDict, (id)KAll);
  RELEASE(todo);
  RELEASE(allDict);
}

/*
void CTraversePerform(id o, id result, int level, id (*action)(id, id, id, int, mutable CDictionary *), mutable CDictionary *ctx)
{
  mutable CDictionary *done; BOOL removeDone; id oldValue, newValue;
  if ((done= (CDictionary*)CDictionaryObjectForKey(ctx, (id)KDone))) removeDone= NO;
  else {
    done= CCreateDictionaryWithOptions(1, CDictionaryPointer, CDictionaryObject);
    CDictionarySetObjectForKey(ctx, (id)done, (id)KDone);
    removeDone= YES;}
  oldValue= CDictionaryObjectForKey(done, o);
  newValue= action(o, oldValue, result, level, ctx);
//if (newValue != oldValue) {
//  CDictionarySetObjectForKey(done, newValue, o);
//  RELEASE(newValue);}
  if (removeDone) {
    CDictionarySetObjectForKey(ctx, nil, (id)KDone);
    RELEASE(done);}
}
*/

MSCoreExtern void CDescribe(id o, id result, int level, mutable CDictionary *ctx)
{
  mutable CDictionary *done; BOOL removeCtx,removeDone;
  id value, indice= nil; NSUInteger n;
  if (ctx) removeCtx= NO;
  else {
    ctx= CCreateDictionary(0);
    CTraversePrepare(o, SUBS, ctx);
    removeCtx= YES;}

  if ((done= (CDictionary*)CDictionaryObjectForKey(ctx, (id)KDone))) removeDone= NO;
  else {
    done= CCreateDictionaryWithOptions(1, CDictionaryPointer, CDictionaryObject);
    CDictionarySetObjectForKey(ctx, (id)done, (id)KDone);
    RELEASE(done);
    indice= (id)CCreateArray(0);
    CDictionarySetObjectForKey(ctx, indice, (id)KIndice);
    RELEASE(indice);
    removeDone= YES;}

  value= CDictionaryObjectForKey(done, o);
  if (value) CStringAppendString((CString*)result, (CString*)value);
  else if (!o) CStringAppendFormat((CString*)result,"nil");
  else {
    n= (NSUInteger)CDictionaryObjectForKey((CDictionary*)CDictionaryObjectForKey(ctx, (id)KAll), o);
    if (n>1) { // l'objet est référencé plus d'une fois
      indice= CDictionaryObjectForKey(ctx, (id)KIndice);
      CArrayAddObject((CArray*)indice,indice);
      value= (id)CCreateString(0);
      CStringAppendFormat((CString*)value, "<<%llu>>", (MSULong)CArrayCount((CArray*)indice));
      CStringAppendFormat((CString*)result,"%llu:: ", (MSULong)CArrayCount((CArray*)indice));
      CDictionarySetObjectForKey(done, value, o);}
    _DESCRIBE(o, result, level, ctx);}

  if (removeDone) {
    CDictionarySetObjectForKey(ctx, nil, (id)KDone);
    CArrayRemoveAllObjects((CArray*)indice);
    CDictionarySetObjectForKey(ctx, nil, (id)KIndice);}
  if (removeCtx) RELEASE(ctx);
}

MSCoreExtern CString *CCreateDescription(id o)
{
  // TODO:? Si o est CString immutable, just RETAIN ?
  CString *s= CCreateString(0);
  CDescribe(o, (id)s, 0, nil);
  return s;
}

void _CTraverseInitialize(void); // used in MSFinishLoadingCore
void _CTraverseInitialize()
{
  KJob=         CSCreate("job");
  KCopy=        CSCreate("copy");
  KDescription= CSCreate("description");
  KDeep=    CSCreate("deep");
  KMutable= CSCreate("mutable");
  KRoot=    CSCreate("root");
  KAll=     CSCreate("all");
  KDone=    CSCreate("done");
  KIndice=  CSCreate("indice");
}

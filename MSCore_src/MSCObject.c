/* MSCObject.c
 
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
 
 WARNING : the CObject mechanism is NOT Thread Safe. Each object
 must be allocated, retained, autoreleased, released in the same thread.
 
 */

#include "MSCore_Private.h"

#ifndef MSCORE_STANDALONE
#warning Check you compilation settings, this file shouldnt be compiled if MSCORE_STANDALONE is not defined
#endif

#ifdef MSCORE_STANDALONE

typedef void           (*CObjectAction  )(id);
typedef BOOL           (*CObjectTest    )(id, id);
typedef NSUInteger     (*CObjectHashier )(id, unsigned);
typedef id             (*CObjectAccessor)(id);
typedef CArray*        (*CObjectSubs)(id, mutable CDictionary *);
typedef void           (*CObjectDescribe)(id, id, int, mutable CDictionary *);
typedef const CString* (*CObjectDescription)(id);

typedef struct CClassStruct {
  struct CClassStruct *isa;
  const char*          className;
  CObjectAction        deInit;
  CObjectTest          isEqual; // Ne pas prendre le equals car ce faisant on s'interdirait que des objets du core n'ayant pas la même classe puissent être égaux.
  CObjectHashier       hashier;
  CObjectAccessor      copier;
  CObjectSubs          createSubs;
  CObjectDescribe      describe;
  CObjectDescription   descriptor;
  NSUInteger           instanceSize;
  NSUInteger           elementSize;} // For growable instance
CClass;

BOOL CClassIsEqual(id c1, id c2)
{
  return c1==c2;
}
const CString *CClassRetainedDescription(id self)
{
  return CCreateStringWithBytes(NSUTF8StringEncoding, ((CClass*)self)->className, strlen(((CClass*)self)->className));
}

static struct CClassStruct metaclass=
{  NULL      , "Class"      , NULL                 , CClassIsEqual     , NULL           , NULL           , NULL                        , NULL                        , CClassRetainedDescription     , sizeof(CClass)     , 0              };
static CClass __allClasses[CClassIndexMax+1]=
{ //           className      deInit                 isEqual             hashier          copier           subs                          describe                      descriptor                      instanceSize         elementSize
  {&metaclass, "CArray"     , CArrayFreeInside     , CArrayIsEqual     , CArrayHash     , CArrayCopy     , CCreateArrayOfArraySubs     , CArrayDescribe     , CArrayRetainedDescription     , sizeof(CArray)     , sizeof(id)     },
  {&metaclass, "CBuffer"    , CBufferFreeInside    , CBufferIsEqual    , CBufferHash    , CBufferCopy    , NULL                        , CBufferDescribe    , CBufferRetainedDescription    , sizeof(CBuffer)    , sizeof(MSByte) },
  {&metaclass, "CColor"     , CColorFreeInside     , CColorIsEqual     , CColorHash     , CColorCopy     , NULL                        , CColorDescribe     , CColorRetainedDescription     , sizeof(CColor)     , 0              },
  {&metaclass, "CCouple"    , CCoupleFreeInside    , CCoupleIsEqual    , CCoupleHash    , CCoupleCopy    , CCreateArrayOfCoupleSubs    , CCoupleDescribe    , CCoupleRetainedDescription    , sizeof(CCouple)    , 0              },
  {&metaclass, "CDate"      , CDateFreeInside      , CDateIsEqual      , CDateHash      , CDateCopy      , NULL                        , CDateDescribe      , CDateRetainedDescription      , sizeof(CDate)      , 0              },
  {&metaclass, "CDecimal"   , CDecimalFreeInside   , CDecimalIsEqual   , CDecimalHash   , CDecimalCopy   , NULL                        , CDecimalDescribe   , CDecimalRetainedDescription   , sizeof(CDecimal)   , 0              },
  {&metaclass, "CDictionary", CDictionaryFreeInside, CDictionaryIsEqual, CDictionaryHash, CDictionaryCopy, CCreateArrayOfDictionarySubs, CDictionaryDescribe, CDictionaryRetainedDescription, sizeof(CDictionary), sizeof(void*)  },
  {&metaclass, "CString"    , CStringFreeInside    , CStringIsEqual    , CStringHash    , CStringCopy    , NULL                        , CStringDescribe    , CStringRetainedDescription    , sizeof(CString)    , sizeof(unichar)}
};

#define CISA(obj) ((CClass*)((obj)->isa))

id _CRetain(id object)
{
  if (object && object->isa) __sync_add_and_fetch(&object->refCount, 1);
  return object;
}

void _CRelease(id object)
{
  if (object && object->isa) {
    // a 0 refCount means the object is retained once, so we can deallocate it after the release;
    if (__sync_sub_and_fetch(&object->refCount, 1) == -1) {
      if (CISA(object)->deInit) CISA(object)->deInit((void *)object);
      MSFree(object, "CRelease() [object]");}}
}

NSUInteger _CRetainCount(id object)
{
  return !object ? 0 : object->refCount+1;
}

BOOL _CObjectIsEqual(id obj1, id obj2)
{
  if ( obj1 ==  obj2) return YES;
  if (!obj1 || !obj2) return NO;
  if (CISA(obj1)->isEqual) return (CISA(obj1)->isEqual)(obj1,obj2);
  else {
    MSReportError(MSGenericError, MSFatalError, MSUnimplementedMethod, "Objects of class %s don't implement the 'isEqual' function", obj1->isa->className);
    return NO;}
}

NSUInteger _CObjectHashDepth(id obj, unsigned depth)
{
  return !obj ? 0 : CISA(obj)->hashier(obj, depth);
}

NSUInteger _CObjectHash(id obj)
{
  return HASHDEPTH(obj, 0);
}

id _CObjectCopy(id obj)
{
  if (!obj) return nil;
  if (CISA(obj)->copier) return CISA(obj)->copier(obj);
  else {
    MSReportError(MSGenericError, MSFatalError, MSUnimplementedMethod, "Objects of class %s don't implement the 'copier' function", obj->isa->className);
    return nil;}
}

CArray *_CObjectSubs(id obj, mutable CDictionary *ctx)
{
  if (!obj || !CISA(obj)->createSubs) return nil;
  return CISA(obj)->createSubs(obj,ctx);
}

void _CObjectDescribe(id obj, id result, int level, mutable CDictionary *ctx)
{
  if (!obj || !CISA(obj)->describe) return;
  return CISA(obj)->describe(obj, result, level, ctx);
}

const CString* _CObjectRetainedDescription(id obj)
{
  if (!obj) return nil;
  if (CISA(obj)->descriptor) return CISA(obj)->descriptor(obj);
  else {
    MSReportError(MSGenericError, MSFatalError, MSUnimplementedMethod, "Objects of class %s don't implement the 'descriptor' function", obj->isa->className);
    return nil;}
}

garray_pfs_t GArrayPfs= NULL;
BOOL _CIsArray(id obj)
{
  if (!obj) return NO;
  return CISA(obj)==__allClasses+CArrayClassIndex;
}

int _MSEnv() {return 0;}

void _CObjectInitialize(void); // used in MSFinishLoadingCore
void _CObjectInitialize()
{
}

id MSCreateObjectWithClassIndex(CClassIndex classIndex)
{
  CClass *aClass= __allClasses+classIndex;
  if (aClass) {
    if (aClass->instanceSize) {
      id newObject= (id)MSCalloc(1, aClass->instanceSize,
        "MSCreateObjectWithClassIndex() allocation");
      newObject->isa= (Class)aClass;
      return (id)newObject;}}
  return nil;
}

NSUInteger CGrowElementSize(id self)
{
  return self && self->isa ? CISA(self)->elementSize : 0;
}

#endif

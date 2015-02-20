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

typedef void       (*CObjectAction  )(id);
typedef BOOL       (*CObjectTest    )(id, id);
typedef NSUInteger (*CObjectHashier )(id, unsigned);
typedef id         (*CObjectAccessor)(id);
typedef const CString* (*CObjectDescription)(id);

typedef struct CClassStruct {
  struct CClassStruct *isa;
  const char*          className;
  CObjectAction        deallocator;
  CObjectTest          isEqual;
  CObjectHashier       hashier;
  CObjectAccessor      copier;
  CObjectDescription   descriptor;
  NSUInteger           instanceSize;
  NSUInteger           elementSize;} // For growable instance
CClass;

const CString *CClassRetainedDescription(id self)
{
  return CCreateStringWithBytes(NSUTF8StringEncoding, ((CClass*)self)->className, strlen(((CClass*)self)->className));
}

static struct CClassStruct metaclass=
{  NULL      , "Class"         , NULL              , NULL                 , NULL              , NULL              , CClassRetainedDescription      , sizeof(CClass)     , 0              };
static CClass __allClasses[CClassIndexMax+1]=
{ //           className         deallocator         isEqual                hashier             copier              descriptor                       instanceSize         elementSize
  {&metaclass, "CArray"        , CArrayFree        , CArrayIsEqual        , CArrayHash        , CArrayCopy        , CArrayRetainedDescription      , sizeof(CArray)     , sizeof(id)     },
  {&metaclass, "CBuffer"       , CBufferFree       , CBufferIsEqual       , CBufferHash       , CBufferCopy       , CBufferRetainedDescription     , sizeof(CBuffer)    , sizeof(MSByte) },
  {&metaclass, "CColor"        , CColorFree        , CColorIsEqual        , CColorHash        , CColorCopy        , CColorRetainedDescription      , sizeof(CColor)     , 0              },
  {&metaclass, "CCouple"       , CCoupleFree       , CCoupleIsEqual       , CCoupleHash       , CCoupleCopy       , CCoupleRetainedDescription     , sizeof(CCouple)    , 0              },
  {&metaclass, "CDate"         , CDateFree         , CDateIsEqual         , CDateHash         , CDateCopy         , CDateRetainedDescription       , sizeof(CDate)      , 0              },
  {&metaclass, "CDecimal"      , CDecimalFree      , CDecimalIsEqual      , CDecimalHash      , CDecimalCopy      , CDecimalRetainedDescription    , sizeof(CDecimal)   , 0              },
  {&metaclass, "CDictionary"   , CDictionaryFree   , CDictionaryIsEqual   , CDictionaryHash   , CDictionaryCopy   , CDictionaryRetainedDescription , sizeof(CDictionary), sizeof(void*)  },
  {&metaclass, "CString"       , CStringFree       , CStringIsEqual       , CStringHash       , CStringCopy       , CStringRetainedDescription     , sizeof(CString)    , sizeof(unichar)}
};

#define CISA(obj) ((CClass*)((obj)->isa))

id _CRetain(id object)
{
  if (object && object->isa) {
    __sync_add_and_fetch(&object->refCount, 1);
  }
  return object;
}

void _CRelease(id object)
{
  if (object && object->isa) {
    // a 0 refCount means the object is retained once, so we can deallocate it after the release;
    if(__sync_sub_and_fetch(&object->refCount, 1) == -1) {
      if (CISA(object)->deallocator) { CISA(object)->deallocator((void *)object); }
      else { MSFree(object, "CRelease() [object]"); }
    }
  }
}

NSUInteger _CRetainCount(id object)
{
  return !object ? 0 : object->refCount+1;
}

BOOL _CObjectIsEqual(id obj1, id obj2)
{
  return obj1 ? _CClassIsEqual(obj1,obj2,CISA(obj1)->isEqual) : !obj2 ? YES : NO;
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
  if (obj) {
    if (CISA(obj)->copier) {
      return CISA(obj)->copier(obj);}
    else {
      MSReportError(MSGenericError, MSFatalError, MSUnimplementedMethod, "Objects of class %s don't implement the 'copier' function", obj->isa->className);
    }
  }
  return nil;
}

const CString* _CObjectRetainedDescription(id obj)
{
  if (obj) {
    if (CISA(obj)->descriptor) {
      return CISA(obj)->descriptor(obj);}
    else {
      MSReportError(MSGenericError, MSFatalError, MSUnimplementedMethod, "Objects of class %s don't implement the 'descriptor' function", obj->isa->className);
    }
  }
  return nil;
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

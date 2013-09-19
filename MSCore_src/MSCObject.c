/*
 
 MSCObject.c
 
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

#include "MSCore.h"

NSUInteger MSPointerHash(void *pointer)
{
  // Thank's to Nat! remark
  // (http://www.mulle-kybernetik.com/artikel/Optimization/opti-7.html)
  // about address alignment and adding salt in a hash.
  // Even if we return a NSUInteger I decided to go with 32 bits number since
  // a 8 bits hashing is useless.
  return (NSUInteger)((((MSUInt)pointer >> 4) | (MSUInt)pointer << 28)) ;
}

#ifdef MSCORE_STANDALONE

typedef void       (*CObjectAction  )(id) ;
typedef BOOL       (*CObjectTest    )(id, id) ;
typedef NSUInteger (*CObjectHashier )(id, unsigned) ;
typedef id         (*CObjectAccessor)(id) ;

typedef struct {
  const char*     className ;
  CObjectAction   deallocator ;
  CObjectTest     isEqual ;
  CObjectHashier  hashier ;
  CObjectAccessor copier ;
  NSUInteger      instancesSize ;}
CClass;

static CClass __allClasses[CClassIndexMax+1]=
{ // className         deallocator         isEqual                hashier             copier              instancesSize
  {  "CArray"        , CArrayFree        , CArrayIsEqual        , CArrayHash        , CArrayCopy        , sizeof(CArray)        },
  //{"CBuffer"       , CBufferFree       , CBufferIsEqual       , CBufferHash       , CBufferCopy       , sizeof(CBuffer)       },
  //{"CColor"        , NULL              , CColorIsEqual        , CColorHash        , CColorCopy        , sizeof(CColor)        },
  //{"CCouple"       , CCoupleFree       , CCoupleIsEqual       , CCoupleHash       , CCoupleCopy       , sizeof(CCouple)       },
  //{"CDate"         , NULL              , CDateIsEqual         , CDateHash         , CDateCopy         , sizeof(CDate)         },
  //{"CDecimal"      , CDecimalFree      , CDecimalIsEqual      , CDecimalHash      , CDecimalCopy      , sizeof(CDecimal)      },
  //{"CDictionary"   , CDictionaryFree   , CDictionaryIsEqual   , CDictionaryHash   , CDictionaryCopy   , sizeof(CDictionary)   },
  //{"CMutex"        , CMutexFree        , NULL                 , MSPointerHash     , NULL              , sizeof(CMutex)        },
  {  "CUnicodeBuffer", CUnicodeBufferFree, CUnicodeBufferIsEqual, CUnicodeBufferHash, CUnicodeBufferCopy, sizeof(CUnicodeBuffer)}
};

#define CISA(obj) ((CClass*)((obj)->isa))

id _CRetain(id object)
{
  if (object && object->isa) {
    object->refCount ++ ;
  }
  return object ;
}

void _CRelease(id object)
{
  if (object && object->isa) {
    // a 0 refCount means the object is retained once, so we can deallocate it after the release ;
    if (object->refCount) { object->refCount -- ; }
    else if (CISA(object)->deallocator) { CISA(object)->deallocator((void *)object) ; }
    else { MSFree(object, "CRelease() [object]") ; }
  }
}

id _CAutorelease(id object)
{
  if (object && CISA(object)) {
  }
  return object ;
}

NSUInteger _CRetainCount(id object)
{
  return !object ? 0 : object->refCount+1;
}

BOOL _CObjectIsEqual(id obj1, id obj2)
{
  if (obj1 == obj2) { return YES ; }
  if (obj1 && obj1->isa && obj2 && obj1->isa == obj2->isa && CISA(obj1)->isEqual) {
    // we only compare objects of the same class since class are a very poor concept in this C library
    return CISA(obj1)->isEqual(obj1, obj2) ;
  }
  return NO ;
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
      return CISA(obj)->copier(obj) ;
    }
    else {
      MSReportError(MSGenericError, MSFatalError, MSUnimplementedMethod, "Objects of class %s don't implement the 'copier' function", obj->isa->className) ;
    }
  }
  return nil ;
}

id MSCreateObjectWithClassIndex(CClassIndex classIndex)
{
  CClass *aClass= __allClasses+classIndex ;
  if (aClass) {
    if (aClass->instancesSize) {
      id newObject= (id)calloc(1, aClass->instancesSize) ; // allocated and filled with zeros ;
      newObject->isa= (Class)aClass ;
      return (id)newObject ;
    }
  }
  return nil ;
}

#endif

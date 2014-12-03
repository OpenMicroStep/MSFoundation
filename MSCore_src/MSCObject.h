/* MSCObject.h
 
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
 
 WARNING : outside the MSCore library this header file cannot
 be included alone, please direclty include MSCore.h AND NEVER
 INCLUDE IT IN MSFoundation
 
 */

#ifndef MSCORE_OBJECT_H
#define MSCORE_OBJECT_H

#pragma mark c-like Class and Objects

#if defined(MSCORE_STANDALONE) || defined(MSCORE_FORFOUNDATION)

///// Class for c-like objects
typedef struct ClassStruct {
  struct ClassStruct *isa;
  const char* className;}
*Class;
#define Nil ((Class)0)

///// c-like object
typedef struct {
  Class isa;
#ifdef MSCORE_STANDALONE
  NSUInteger refCount;
#endif
  }
*id;
#define nil ((void*)0)

#define MSMaxHashingHop 3

#endif // defined(MSCORE_STANDALONE) || defined(MSCORE_FORFOUNDATION)

typedef enum {
  CArrayClassIndex= 0,
  CBufferClassIndex,
  CColorClassIndex,
  CCoupleClassIndex,
  CDateClassIndex,
  CDecimalClassIndex,
  CDictionaryClassIndex,
  CMUtexClassIndex,
  CStringClassIndex}
CClassIndex;
#define CClassIndexMax ((NSUInteger)CStringClassIndex)


id MSCreateObjectWithClassIndex(CClassIndex classIndex);

typedef NSComparisonResult (*MSObjectComparator)(id, id, void*);
#define MSObjectSort(P,N,CMP,CTX) \
  MSSort((void**)(P),(N),((NSComparisonResult(*)(void*,void*,void*))CMP),(CTX))

#pragma mark Retain / Release

#ifdef RETAIN
#undef RETAIN
#endif

#ifdef RELEASE
#undef RELEASE
#endif

#ifdef AUTORELEASE
#undef AUTORELEASE
#endif

#ifdef ISA
#undef ISA
#endif

#ifdef ISEQUAL
#undef ISEQUAL
#endif

#ifdef HASH
#undef HASH
#endif

#ifdef COPY
#undef COPY
#endif

#ifdef MSCORE_STANDALONE // ---------------------------------- MSCORE_STANDALONE
// No autorelease in Core. Not needed, not a priority.

MSCoreExport NSUInteger  _CRetainCount    (id obj);
MSCoreExport id          _CRetain         (id obj);
MSCoreExport void        _CRelease        (id obj);
//MSCoreExport id        _CAutorelease    (id obj);
MSCoreExport BOOL        _CObjectIsEqual  (id obj1, id obj2);
MSCoreExport NSUInteger  _CObjectHash     (id obj);
MSCoreExport NSUInteger  _CObjectHashDepth(id obj, unsigned depth);
MSCoreExport id          _CObjectCopy     (id obj);

#define ISA(X)         ((X)->isa)
#define NAMEOFCLASS(X) (ISA(X)->className)

#define RETAINCOUNT(X) _CRetainCount((id)(X))
#define RETAIN(X)      _CRetain     ((id)(X))
#define RELEASE(X)     _CRelease    ((id)(X))
//#define AUTORELEASE(X) _CAutorelease((id)(X))

#define ISEQUAL(X, Y)  _CObjectIsEqual  ((id)(X), (id)(Y))
#define HASH(X)        _CObjectHash     ((id)(X))
#define HASHDEPTH(X,D) _CObjectHashDepth((id)(X),(D))
#define COPY(X)        _CObjectCopy     ((id)(X))

#else // ---------------------------------------------------- !MSCORE_STANDALONE

MSCoreExport Class       _MIsa            (id obj);
MSCoreExport const char *_MNameOfClass    (id obj);
MSCoreExport NSUInteger  _MRetainCount    (id obj);
MSCoreExport id          _MRetain         (id obj);
MSCoreExport void        _MRelease        (id obj);
MSCoreExport id          _MAutorelease    (id obj);
MSCoreExport BOOL        _MObjectIsEqual  (id obj1, id obj2);
MSCoreExport NSUInteger  _MObjectHash     (id obj);
MSCoreExport NSUInteger  _MObjectHashDepth(id obj, unsigned depth);
MSCoreExport id          _MObjectCopy     (id obj);

#ifdef MSCORE_FORFOUNDATION                              // MSCORE_FORFOUNDATION

#define ISA(X)         _MIsa        ((id)(X))
#define NAMEOFCLASS(X) _MNameOfClass((id)(X))

#define RETAINCOUNT(X) _MRetainCount((id)(X))
#define RETAIN(X)      _MRetain     ((id)(X))
#define RELEASE(X)     _MRelease    ((id)(X))
#define AUTORELEASE(X) _MAutorelease((id)(X))

#define ISEQUAL(X, Y)  _MObjectIsEqual  ((id)(X), (id)(Y))
#define HASH(X)        _MObjectHash     ((id)(X))
#define HASHDEPTH(X,D) _MObjectHashDepth((id)(X),(D))
#define COPY(X)        _MObjectCopy     ((id)(X))

#else                                                              // FOUNDATION

#include <objc/objc-runtime.h>
#if defined(WIN32)
  #warning --WIN--
  #define ISA(X)         (((id)(X))->isa)
  #define NAMEOFCLASS(X) object_getClassName((id)(X))
#elif defined(__APPLE__) || defined(FOUNDATION_STATIC_INLINE)
  #warning --MACOSX--
  #define ISA(X)         object_getClass(X)
  #define NAMEOFCLASS(X) object_getClassName(X)
#else
  #warning --NOT MAC OS--
  #define ISA(X)         object_get_class(X)
  #define NAMEOFCLASS(X) object_get_class_name(X)
#endif

#define RETAINCOUNT(X) [(X) retainCount]
#define RETAIN(X)      [(X) retain]
#define RELEASE(X)     [(X) release]
#define AUTORELEASE(X) [(X) autorelease]
/*
#define ISEQUAL(X,Y) ({ \
  id __x__= (id)(X), __y__= (id)(Y); \
  (__x__ == __y__) ? YES : [__x__ isEqual:__y__];})
*/
static inline BOOL ISEQUAL(id x, id y) {
  return (x == y) ? YES : (!x || !y) ? NO : [x isEqual:y];}

#define HASH(X)        [(X) hash:0]
#define HASHDEPTH(X,D) [(X) hash:(D)]
#define COPY(X)        [(X) copyWithZone:NULL]

#endif                                      // MSCORE_FORFOUNDATION & FOUNDATION

#endif // ---------------------------------------------------- MSCORE_STANDALONE

// ========== common macros

#ifdef ASSIGN
#undef ASSIGN
#endif
#define ASSIGN(X,Y) ({ \
  id __x__= (id)X, __y__= (id)(Y); \
  if (__x__ != __y__) { \
    X=  (__y__ ? RETAIN(__y__) : nil); \
    if (__x__) RELEASE(__x__); }})

#ifdef RELEAZEN
#undef RELEAZEN
#endif
#define RELEAZEN(X) ({ id __x__= (id)X; X= NULL; RELEASE(__x__); })
#define DESTROY RELEAZEN

MSCoreExport void       CArrayFree(id self);
MSCoreExport BOOL       CArrayIsEqual(id self, id other);
MSCoreExport NSUInteger CArrayHash(id self, unsigned depth);
MSCoreExport id         CArrayCopy(id self);

MSCoreExport void       CBufferFree(id self);
MSCoreExport BOOL       CBufferIsEqual(id self, id other);
MSCoreExport NSUInteger CBufferHash(id self, unsigned depth);
MSCoreExport id         CBufferCopy(id self);

MSCoreExport void       CColorFree(id self);
MSCoreExport BOOL       CColorIsEqual(id self, id other);
MSCoreExport NSUInteger CColorHash(id self, unsigned depth);
MSCoreExport id         CColorCopy(id self);

MSCoreExport void       CCoupleFree(id self);
MSCoreExport BOOL       CCoupleIsEqual(id self, id other);
MSCoreExport NSUInteger CCoupleHash(id self, unsigned depth);
MSCoreExport id         CCoupleCopy(id self);

MSCoreExport void       CDateFree(id self);
MSCoreExport BOOL       CDateIsEqual(id self, id other);
MSCoreExport NSUInteger CDateHash(id self, unsigned depth);
MSCoreExport id         CDateCopy(id self);

MSCoreExport void       CDecimalFree(id self);
MSCoreExport BOOL       CDecimalIsEqual(id self, id other);
MSCoreExport NSUInteger CDecimalHash(id self, unsigned depth);
MSCoreExport id         CDecimalCopy(id self);

MSCoreExport void       CDictionaryFree(id self);
MSCoreExport BOOL       CDictionaryIsEqual(id self, id other);
MSCoreExport NSUInteger CDictionaryHash(id self, unsigned depth);
MSCoreExport id         CDictionaryCopy(id self);

//MSCoreExport void       CMutexFree(id self);

MSCoreExport void       CStringFree(id self);
MSCoreExport BOOL       CStringIsEqual(id self, id other);
MSCoreExport NSUInteger CStringHash(id self, unsigned depth);
MSCoreExport id         CStringCopy(id self);

// Private for CArrayIsEqual, CBufferIsEqual...
typedef BOOL (*CObjectEq)(id, id);
static inline BOOL _CClassIsEqual(id a, id b, CObjectEq classEqualFct)
  {
  return (a == b) ? YES : !classEqualFct ? NO :
    (a && b  && ISA(a) == ISA(b)) ? classEqualFct(a, b) : NO;
  }
static inline void _CClassGrow(id self, NSUInteger n, NSUInteger count, NSUInteger unitSize, NSUInteger *size, void **ptr)
  {
  if (self && n && count + n > *size) {
    NSUInteger newSize= MSCapacityForCount(count + n);
    if (!*ptr) {
      if (!(*ptr= MSMalloc(newSize * unitSize, "CGrow()"))) {
        MSReportError(MSMallocError, MSFatalError, MSMallocErrorCode, "CGrow() allocation error");
        return;}}
    else if (!(*ptr= MSRealloc(*ptr, newSize * unitSize, "CGrow()"))) {
      MSReportError(MSMallocError, MSFatalError, MSReallocErrorCode, "CGrow() reallocation error");
      return;}
    *size= newSize;}
  }

static inline void _CClassAdjustSize(id self, NSUInteger count, NSUInteger unitSize, NSUInteger *size, void **ptr)
{
  if (self && count < *size) {
    if (count) {
      if (!(*ptr= MSRealloc(*ptr, count * unitSize, "CAdjustSize()"))) {
        MSReportError(MSMallocError, MSFatalError, MSReallocErrorCode, "CAdjustSize() reallocation error");
        return;}
      else *size= count;}
    else {MSFree(*ptr, "CAdjustSize()"); *ptr= NULL; *size= 0;}}
}

#endif // MSCORE_OBJECT_H

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

MSExport NSUInteger  _CRetainCount    (id obj);
MSExport id          _CRetain         (id obj);
MSExport void        _CRelease        (id obj);
//MSExport id        _CAutorelease    (id obj);
MSExport BOOL        _CObjectIsEqual  (id obj1, id obj2);
MSExport NSUInteger  _CObjectHash     (id obj);
MSExport NSUInteger  _CObjectHashDepth(id obj, unsigned depth);
MSExport id          _CObjectCopy     (id obj);

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

MSExport Class       _MIsa            (id obj);
MSExport const char *_MNameOfClass    (id obj);
MSExport NSUInteger  _MRetainCount    (id obj);
MSExport id          _MRetain         (id obj);
MSExport void        _MRelease        (id obj);
MSExport id          _MAutorelease    (id obj);
MSExport BOOL        _MObjectIsEqual  (id obj1, id obj2);
MSExport NSUInteger  _MObjectHash     (id obj);
MSExport NSUInteger  _MObjectHashDepth(id obj, unsigned depth);
MSExport id          _MObjectCopy     (id obj);

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
  #warning WIN - WIN - WIN - WIN - WIN - WIN - WIN - WIN - WIN - WIN - WIN
  #define ISA(X)         (((id)(X))->isa)
  #define NAMEOFCLASS(X) object_getClassName((id)(X))
#elif defined(__APPLE__) || defined(FOUNDATION_STATIC_INLINE)
  #warning MACOSX - MACOSX - MACOSX - MACOSX - MACOSX - MACOSX - MACOSX
  #define ISA(X)         object_getClass(X)
  #define NAMEOFCLASS(X) object_getClassName(X)
#else
  #warning NOT MAC OS - NOT MAC OS - NOT MAC OS - NOT MAC OS - NOT MAC OS
  #define ISA(X)         object_get_class(X)
  #define NAMEOFCLASS(X) object_get_class_name(X)
#endif

#define RETAINCOUNT(X) [(X) retainCount]
#define RETAIN(X)      [(X) retain]
#define RELEASE(X)     [(X) release]
#define AUTORELEASE(X) [(X) autorelease]

#define ISEQUAL(X,Y) ({ \
  id __x__= (id)(X), __y__= (id)(Y); \
  (__x__ == __y__) ? YES : [__x__ isEqual:__y__];})
/*
static inline BOOL ISEQUAL(id x, id y) {
  return (x == y) ? YES : [x isEqual:y];}
*/
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

#ifdef DESTROY
#undef DESTROY
#endif
#define DESTROY(X) ({ id __x__= (id)X; X= NULL; RELEASE(__x__); })

MSExport void       CArrayFree(id self);
MSExport BOOL       CArrayIsEqual(id self, id other);
MSExport NSUInteger CArrayHash(id self, unsigned depth);
MSExport id         CArrayCopy(id self);

MSExport void       CBufferFree(id self);
MSExport BOOL       CBufferIsEqual(id self, id other);
MSExport NSUInteger CBufferHash(id self, unsigned depth);
MSExport id         CBufferCopy(id self);

MSExport void       CColorFree(id self);
MSExport BOOL       CColorIsEqual(id self, id other);
MSExport NSUInteger CColorHash(id self, unsigned depth);
MSExport id         CColorCopy(id self);

MSExport void       CCoupleFree(id self);
MSExport BOOL       CCoupleIsEqual(id self, id other);
MSExport NSUInteger CCoupleHash(id self, unsigned depth);
MSExport id         CCoupleCopy(id self);

MSExport void       CDateFree(id self);
MSExport BOOL       CDateIsEqual(id self, id other);
MSExport NSUInteger CDateHash(id self, unsigned depth);
MSExport id         CDateCopy(id self);

MSExport void       CDecimalFree(id self);
MSExport BOOL       CDecimalIsEqual(id self, id other);
MSExport NSUInteger CDecimalHash(id self, unsigned depth);
MSExport id         CDecimalCopy(id self);

MSExport void       CDictionaryFree(id self);
MSExport BOOL       CDictionaryIsEqual(id self, id other);
MSExport NSUInteger CDictionaryHash(id self, unsigned depth);
MSExport id         CDictionaryCopy(id self);

//MSExport void       CMutexFree(id self);

MSExport void       CStringFree(id self);
MSExport BOOL       CStringIsEqual(id self, id other);
MSExport NSUInteger CStringHash(id self, unsigned depth);
MSExport id         CStringCopy(id self);

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
    else {MSFree(ptr, "CAdjustSize()"); *ptr= NULL; *size= 0;}}
}

#endif // MSCORE_OBJECT_H

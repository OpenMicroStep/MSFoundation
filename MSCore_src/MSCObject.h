/*
 
 MSCObject.h
 
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

MSExport NSUInteger MSPointerHash(void *pointer);

#pragma mark c-like Class and Objects

#if defined(MSCORE_STANDALONE) || defined(MSCORE_FORFOUNDATION)

///// Class for c-like objects
typedef struct {
  const char* className;}
*Class;
#define Nil ((Class)0)

///// c-like object
typedef struct {
  Class isa ;
#ifdef MSCORE_STANDALONE
  NSUInteger refCount ;
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
  CUnicodeBufferClassIndex}
CClassIndex ;
#define CClassIndexMax ((NSUInteger)CUnicodeBufferClassIndex)


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

MSExport NSUInteger _CRetainCount    (id obj);
MSExport id         _CRetain         (id obj);
MSExport void       _CRelease        (id obj);
MSExport id         _CAutorelease    (id obj);
MSExport BOOL       _CObjectIsEqual  (id obj1, id obj2);
MSExport NSUInteger _CObjectHash     (id obj);
MSExport NSUInteger _CObjectHashDepth(id obj, unsigned depth);
MSExport id         _CObjectCopy     (id obj);

#define ISA(X)         ((X)->isa)

#ifdef NAMEOF
#undef NAMEOF
#endif
#define NAMEOF(X)      (ISA(X)->className)

#define RETAINCOUNT(X) _CRetainCount((id)(X))
#define RETAIN(X)      _CRetain     ((id)(X))
#define RELEASE(X)     _CRelease    ((id)(X))
#define AUTORELEASE(X) _CAutorelease((id)(X))

#define ISEQUAL(X, Y)  _CObjectIsEqual  ((id)(X), (id)(Y))
#define HASH(X)        _CObjectHash     ((id)(X))
#define HASHDEPTH(X,D) _CObjectHashDepth((id)(X),(D))
#define COPY(X)        _CObjectCopy     ((id)(X))

#else // ---------------------------------------------------- !MSCORE_STANDALONE

#if defined(__APPLE__) || defined(FOUNDATION_STATIC_INLINE)
  #define ISA(X)       ((Class)(((Class)(X))->isa))
// NAMEOF already defined by Apple runtime
#else
  #define ISA(X)       object_get_class(X)
  #ifdef NAMEOF
  #undef NAMEOF
  #endif
  #define NAMEOF(X)    object_get_class_name(X)
#endif

MSExport NSUInteger _MRetainCount    (id obj);
MSExport id         _MRetain         (id obj);
MSExport void       _MRelease        (id obj);
MSExport id         _MAutorelease    (id obj);
MSExport BOOL       _MObjectIsEqual  (id obj1, id obj2);
MSExport NSUInteger _MObjectHash     (id obj);
MSExport NSUInteger _MObjectHashDepth(id obj, unsigned depth);
MSExport id         _MObjectCopy     (id obj);

#ifdef MSCORE_FORFOUNDATION                              // MSCORE_FORFOUNDATION

#define RETAINCOUNT(X) _MRetainCount((id)(X))
#define RETAIN(X)      _MRetain     ((id)(X))
#define RELEASE(X)     _MRelease    ((id)(X))
#define AUTORELEASE(X) _MAutorelease((id)(X))

#define ISEQUAL(X, Y)  _MObjectIsEqual  ((id)(X), (id)(Y))
#define HASH(X)        _MObjectHash     ((id)(X))
#define HASHDEPTH(X,D) _MObjectHashDepth((id)(X),(D))
#define COPY(X)        _MObjectCopy     ((id)(X))

#else                                                              // FOUNDATION

#define RETAINCOUNT(X) [(X) retainCount]
#define RETAIN(X)      [(X) retain]
#define RELEASE(X)     [(X) release]
#define AUTORELEASE(X) [(X) autorelease]

#define ISEQUAL(X,Y) ({ \
  id __x__= (id)(X), __y__= (id)(Y); \
  return (__x__ == __y__) ? YES : [__x__ isEqual:__y__];})
#define HASH(X)        [(X) hash]
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
    X=  (__y__ ? RETAIN(__y__) : NULL); \
    if (__x__) RELEASE(__x__); }})

#ifdef DESTROY
#undef DESTROY
#endif
#define DESTROY(X) ({ id __x__= (id)X; X= NULL; RELEASE(__x__); })

MSExport void       CArrayFree(id self) ;
MSExport BOOL       CArrayIsEqual(id self, id other) ;
MSExport NSUInteger CArrayHash(id self, unsigned depth) ;
MSExport id         CArrayCopy(id self) ;

MSExport void       CBufferFree(id self) ;
MSExport BOOL       CBufferIsEqual(id self, id other) ;
MSExport NSUInteger CBufferHash(id self, unsigned depth) ;
MSExport id         CBufferCopy(id self) ;

MSExport BOOL       CColorIsEqual(id self, id other) ;
MSExport NSUInteger CColorHash(id self, unsigned depth) ;
MSExport id         CColorCopy(id self) ;

MSExport void       CCoupleFree(id self) ;
MSExport BOOL       CCoupleIsEqual(id self, id other) ;
MSExport NSUInteger CCoupleHash(id self, unsigned depth) ;
MSExport id         CCoupleCopy(id self) ;

MSExport BOOL       CDateIsEqual(id self, id other) ;
MSExport NSUInteger CDateHash(id self, unsigned depth) ;
MSExport id         CDateCopy(id self) ;

MSExport void       CDecimalFree(id self) ;
MSExport BOOL       CDecimalIsEqual(id self, id other) ;
MSExport id         CDecimalCopy(id self) ;
MSExport NSUInteger CDecimalHash(id self, unsigned depth) ;

MSExport void       CDictionaryFree(id self) ;
MSExport BOOL       CDictionaryIsEqual(id self, id other) ;
MSExport NSUInteger CDictionaryHash(id self, unsigned depth) ;
MSExport id         CDictionaryCopy(id self) ;

MSExport void       CMutexFree(id self) ;

MSExport void       CUnicodeBufferFree(id self) ;
MSExport BOOL       CUnicodeBufferIsEqual(id self, id other) ;
MSExport NSUInteger CUnicodeBufferHash(id self, unsigned depth) ;
MSExport id         CUnicodeBufferCopy(id self) ;

#endif // MSCORE_OBJECT_H

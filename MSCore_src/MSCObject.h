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

#ifdef MSFOUNDATION_FORCOCOA
#define MSCORE_NSOBJECT_ATTRIBUTES \
  Class isa; \
//int32_t _noRefCount;

#else
#define MSCORE_NSOBJECT_ATTRIBUTES \
  Class isa; \
  int32_t refCount;

#endif

// Return 0 for MSCORE_STANDALONE, 1 for MSFOUNDATION_FORCOCOA, 2 for MSFOUNDATION
MSCoreExtern int _MSEnv(void);

typedef struct CStringStruct     CString;

#if defined(MSCORE_STANDALONE) || defined(MSCORE_FORFOUNDATION)
///// Class for c-like objects
typedef struct ClassStruct {
  struct ClassStruct *isa;
  const char* className;}
*Class;
#define Nil ((Class)0)

///// c-like object
typedef struct {
  MSCORE_NSOBJECT_ATTRIBUTES
  }
*id;
#define nil ((void*)0)

#endif

#define MSMaxHashingHop 3

typedef enum {
  CArrayClassIndex= 0,
  CBufferClassIndex,
  CColorClassIndex,
  CCoupleClassIndex,
  CDateClassIndex,
  CDecimalClassIndex,
  CDictionaryClassIndex,
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

#ifdef DESCRIPTION
#undef DESCRIPTION
#endif

#ifdef MSCORE_STANDALONE // ---------------------------------- MSCORE_STANDALONE
// No autorelease in Core. Not needed, not a priority.

MSCoreExtern NSUInteger  _CRetainCount    (id obj);
MSCoreExtern id          _CRetain         (id obj);
MSCoreExtern void        _CRelease        (id obj);
//MSCoreExtern id        _CAutorelease    (id obj);
MSCoreExtern BOOL        _CObjectIsEqual  (id obj1, id obj2);
MSCoreExtern NSUInteger  _CObjectHash     (id obj);
MSCoreExtern NSUInteger  _CObjectHashDepth(id obj, unsigned depth);
MSCoreExtern id          _CObjectCopy     (id obj);
MSCoreExtern const CString* _CObjectRetainedDescription(id obj);
MSCoreExtern BOOL        _CIsArray        (id obj);

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
#define DESCRIPTION(X) _CObjectRetainedDescription((id)(X))
#define ISARRAY(X)     _CIsArray        ((id)(X))

#else // ---------------------------------------------------- !MSCORE_STANDALONE

MSCoreExtern const CString* _MObjectRetainedDescription(id obj);

// A retained CString made from [X description]
#define DESCRIPTION(X) _MObjectRetainedDescription((id)(X))

#ifdef MSCORE_FORFOUNDATION                              // MSCORE_FORFOUNDATION

MSCoreExtern Class       _MIsa            (id obj);
MSCoreExtern const char *_MNameOfClass    (id obj);
MSCoreExtern NSUInteger  _MRetainCount    (id obj);
MSCoreExtern id          _MRetain         (id obj);
MSCoreExtern void        _MRelease        (id obj);
MSCoreExtern id          _MAutorelease    (id obj);
MSCoreExtern BOOL        _MObjectIsEqual  (id obj1, id obj2);
MSCoreExtern NSUInteger  _MObjectHash     (id obj);
MSCoreExtern NSUInteger  _MObjectHashDepth(id obj, unsigned depth);
MSCoreExtern id          _MObjectCopy     (id obj);
MSCoreExtern BOOL        _MIsArray        (id obj);

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

#define ISARRAY(X)     _MIsArray        ((id)(X))

#else                                                              // FOUNDATION

#include <objc/objc-runtime.h>
#if defined(WIN32)
  #define ISA(X)         (((id)(X))->isa)
  #define NAMEOFCLASS(X) object_getClassName((id)(X))
#elif defined(__APPLE__) || defined(FOUNDATION_STATIC_INLINE)
  #define ISA(X)         object_getClass(X)
  #define NAMEOFCLASS(X) object_getClassName(X)
#else
  #define ISA(X)         object_get_class(X)
  #define NAMEOFCLASS(X) object_get_class_name(X)
#endif

#define RETAINCOUNT(X) [(id)(X) retainCount]
#define RETAIN(X)      [(id)(X) retain]
#define RELEASE(X)     [(id)(X) release]
#define AUTORELEASE(X) [(id)(X) autorelease]

#define ISEQUAL(X,Y) ({ \
  id __x__= (id)(X), __y__= (id)(Y); \
  (__x__ == __y__) ? YES : [__x__ isEqual:__y__];})

#define HASH(X)        [(id)(X) hash:0]
#define HASHDEPTH(X,D) [(id)(X) hash:(D)]
#define COPY(X)        [(id)(X) copyWithZone:NULL]

#define ISARRAY(X)     [(id)(X) isKindOfClass:[NSArray class]]

#endif                                      // MSCORE_FORFOUNDATION & FOUNDATION

#endif // ---------------------------------------------------- MSCORE_STANDALONE


// ========== common macros

#ifdef ASSIGN
#undef ASSIGN
#endif
#define ASSIGN(X,Y) ({ \
  id __x__= (id)X, __y__= (id)(Y); \
  if (__x__ != __y__) { \
    X= (id)(__y__ ? RETAIN(__y__) : nil); \
    if (__x__) RELEASE(__x__); }})

#ifdef RELEAZEN
#undef RELEAZEN
#endif
#define RELEAZEN(X) ({ id __x__= (id)X; X= NULL; RELEASE(__x__); })
#define DESTROY RELEAZEN

// Private for CArrayIsEqual, CBufferIsEqual...
typedef BOOL (*CObjectEq)(id, id);
static inline BOOL _CClassIsEqual(id a, id b, CObjectEq classEqualFct)
  {
  return (a == b) ? YES : !classEqualFct ? NO :
    (a && b  && ISA(a) == ISA(b)) ? classEqualFct(a, b) : NO;
  }

#endif // MSCORE_OBJECT_H

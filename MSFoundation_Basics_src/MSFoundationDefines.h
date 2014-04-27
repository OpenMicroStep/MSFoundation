/*
 
 MSFoundationDefines.h
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
 Eric Baradat :  k18rt@free.fr
 Jean-Michel Bertheas :  jean-michel.bertheas@club-internet.fr
 
 
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
 
 WARNING : this header file cannot be included alone, please direclty
 include <MSFoundation/MSFoundation.h>
 */

/*
 standardized OBJC fast access functions
 */

#if defined(WIN32)
/************************ APPLE WO 451 ON WIN32 **********************/
struct WOFakeClass { long isa; };
MSImport          IMP class_lookupMethod(Class, SEL);

//#define ISA(X)     ((Class)(((struct WOFakeClass *)(X))->isa))
#define LOOKUP(X, Y) class_lookupMethod(X, Y)
#define ISMETA(cls)  ((cls)->info & CLS_META)
#define ISCLASS(cls) ((cls)->info & CLS_CLASS)
//  NAMEOF   already defined in Apple runtime
//  SELNAME  already defined in Apple runtime
#define SELECTOR(X)  sel_getUid(X)

#define _C_LNG_LNG  'q'
#define _C_ULNG_LNG 'Q'
#define _C_LNGLNG   'q'
#define _C_ULNGLNG  'Q'
#define _C_BOOL     'B'
#define _C_ATOM     '%'
#define _C_VECTOR   '!'
#define _C_CONST    'r'
#define _C_IN     'n'
#define _C_INOUT  'N'
#define _C_OUT    'o'
#define _C_BYCOPY 'O'
#define _C_BYREF  'R'
#define _C_ONEWAY 'V'

#elif defined(__COCOTRON__)
/************************ COCOTRON **********************/
#define MSMethod      Method
//#define ISA(X)     ((Class)(((Class)(X))->isa))
#define LOOKUP(X, Y) class_getMethodImplementation(X, Y)
#define ISMETA(cls)  class_isMetaClass(cls)
#define ISCLASS(cls) ({ __typeof__(cls) __a = (cls); (__a ? !class_isMetaClass(__a) : NO);})
#define NAMEOF(X)    object_getClassName(X)
// SELNAME iS DEFINED
#define SELECTOR(X)  sel_getUid(X)

// this one is in order to correct COCOTRON which introduce a BYCOPY with a 'R'
#define _C_BYCOPY 'O'
#define _C_BYREF  'R'
#define _C_BOOL   'B'
#define _C_ATOM   '%'
#define _C_VECTOR '!'

#elif defined(MAC_OS_X_VERSION_MAX_ALLOWED)
/************************ APPLE RUNTIME **********************/

#define _C_IN     'n'
#define _C_INOUT  'N'
#define _C_OUT    'o'
#define _C_BYCOPY 'O'
#define _C_BYREF  'R'
#define _C_ONEWAY 'V'

#if MAC_OS_X_VERSION_10_5 <= MAC_OS_X_VERSION_MAX_ALLOWED
#define MSMethod      Method
//#define ISA(X)     ((Class)(((Class)(X))->isa))
#define LOOKUP(X, Y) class_getMethodImplementation(X, Y)
#define ISMETA(cls)  class_isMetaClass(cls)
#define ISCLASS(cls) ({ __typeof__(cls) __a = (cls); (__a ? !class_isMetaClass(__a) : NO);})
//  NAMEOF   already defined in Apple runtime
//  SELNAME  already defined in Apple runtime
#define SELECTOR(X)  sel_getUid(X)

#else
MSImport          IMP class_lookupMethod(Class, SEL);

#define MSMethod      Method
//#define ISA(X)     ((Class)(((Class)(X))->isa))
#define LOOKUP(X, Y) class_lookupMethod(X, Y)
#define ISMETA(cls)  ((cls)->info & CLS_META)
#define ISCLASS(cls) ((cls)->info & CLS_CLASS)
//  NAMEOF   already defined in Apple runtime
//  SELNAME  already defined in Apple runtime
#define SELECTOR(X)  sel_getUid(X)

#endif


#else
/************************ STANDARD OBJC RUNTIME **********************/
#warning STANDARD OBJC RUNTIME
#define MSMethod      Method_t
//#define ISA(X)       object_get_class(X)
#define LOOKUP(X, Y)   objc_msg_lookup(X, Y)
#define ISMETA(X)      CLS_ISMETA(X)
#define ISCLASS(X)     CLS_ISCLASS(X)
#define NAMEOF(obj)    object_get_class_name(obj)
#define SELNAME(mySel) sel_get_name(mySel)
#define SELECTOR(X)    sel_get_uid(X)

#endif

/*
 standardized macro for memory management
 */

#define MSAllocateObject(X, Y, Z) NSAllocateObject(X, Y, Z)
#define MSCreateObject(ACLASS)    MSAllocateObject(ACLASS, 0, NSDefaultMallocZone())

#ifdef ALLOC
#undef ALLOC
#endif
#define ALLOC(XX) [XX allocWithZone:NULL]

#ifdef NEW
#undef NEW
#endif
#define NEW(X)    [ALLOC(X) init]

#ifdef ASSIGNCOPY
#undef ASSIGNCOPY
#endif
#define ASSIGNCOPY(X,Y)     ({id __x__ = (id)X, __y__ = (id)(Y); \
if (__x__ != __y__) { X =  (__y__ ? COPY(__y__) : nil); if (__x__) RELEASE(__x__); } \
})

#define CREATE_POOL(X) NSAutoreleasePool *X = NEW(NSAutoreleasePool)
#define NEW_POOL       CREATE_POOL(_localPool_)
#define KILL_POOL      RELEASE(_localPool_)

#define DICT   [MSDictionary dictionaryWithObjectsAndKeys:
#define ARRAY  [MSArray arrayWithObjects:
#define MDICT  [MSMutableDictionary dictionaryWithObjectsAndKeys:
#define MARRAY [MSMutableArray arrayWithObjects:

#define END    , nil]
#define CLOSE    nil]

#define OBJECTORNULL(X) ((X) ? (X) : [NSNull null])

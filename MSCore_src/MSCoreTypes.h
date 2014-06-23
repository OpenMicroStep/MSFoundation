/* MSCoreTypes.h
 
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
 
 WARNING : outside the MSFoundation framework or the MSCore library,
 this header file cannot be included alone, please direclty include
 MSCore.h or MSFoundation.h
 */

#ifndef MSCORE_TYPES_H
#define MSCORE_TYPES_H

#ifndef NSINTEGER_DEFINED
#define NSINTEGER_DEFINED

// Si un jour TARGET_OS_IPHONE, éventuellement à revoir
typedef long           NSInteger;
typedef unsigned long  NSUInteger;

#define NSIntegerMax    LONG_MAX
#define NSIntegerMin    LONG_MIN
#define NSUIntegerMax   ULONG_MAX

#endif // NSINTEGER_DEFINED

// No warning on ILP32 printf("%ld",WLI((NSInteger)i))
static inline          long WLI(NSInteger  i) {return (         long)i;}
static inline unsigned long WLU(NSUInteger u) {return (unsigned long)u;}

#if defined(WIN32)
#define intptr_t  MSInt
#define uintptr_t MSUInt
#endif

#if defined(WIN32) || defined(MSCORE_STANDALONE) // ------------- defining types

// Microstep codifications for 8, 16, 32 et 64 bytes integers
typedef char               MSChar;
typedef unsigned char      MSByte;
typedef short              MSShort;
typedef unsigned short     MSUShort;
typedef int                MSInt;
typedef unsigned int       MSUInt;
typedef long long          MSLong;
typedef unsigned long long MSULong;

#define u_int8_t  MSByte
#define u_int16_t MSUShort
#define u_int32_t MSUInt
#define u_int64_t MSULong
#define int8_t    char
#define int16_t   short
#define int32_t   int
#define int64_t   MSLong

#define NSIntegerMapValueCallBacks NSIntMapValueCallBacks
#define NSIntegerMapKeyCallBacks   NSIntMapKeyCallBacks
#define NS_NO_NATIVE_INTEGERS

#elif defined(__APPLE__) // ------------------------------------- defining types
#if MAC_OS_X_VERSION_10_5 > MAC_OS_X_VERSION_MAX_ALLOWED
#define NSIntegerMapValueCallBacks NSIntMapValueCallBacks
#define NSIntegerMapKeyCallBacks   NSIntMapKeyCallBacks
#define NS_NO_NATIVE_INTEGERS
#endif
// Microstep codifications for 8, 16, 32 et 64 bytes integers
typedef int8_t   MSChar;
typedef uint8_t  MSByte;
typedef int16_t  MSShort;
typedef uint16_t MSUShort;
typedef int32_t  MSInt;
typedef uint32_t MSUInt;
typedef int64_t  MSLong;
typedef uint64_t MSULong;

#elif defined(__COCOTRON__) // ---------------------------------- defining types
#define u_int8_t  uint8_t
#define u_int16_t  uint16_t
#define u_int32_t  uint32_t
#define u_int64_t  uint64_t

typedef int8_t   MSChar;
typedef uint8_t  MSByte;
typedef int16_t  MSShort;
typedef uint16_t MSUShort;
typedef int32_t  MSInt;
typedef uint32_t MSUInt;
typedef int64_t  MSLong;
typedef uint64_t MSULong;
#endif // --------------------------------------------------- end defining types

typedef MSLong MSTimeInterval; // Time in seconds T0=01/01/2001

#if defined(MSCORE_STANDALONE) || defined(MSCORE_FORFOUNDATION)

typedef unsigned char BOOL;
#if !defined(YES)
#define YES  (BOOL)1
#endif
#if !defined(NO)
#define NO  (BOOL)0
#endif

#if !defined(MIN)
#define MIN(A,B)  ({ __typeof__(A) __a= (A); __typeof__(B) __b= (B); __a < __b ? __a : __b; })
#endif

#if !defined(MAX)
#define MAX(A,B)  ({ __typeof__(A) __a= (A); __typeof__(B) __b= (B); __a < __b ? __b : __a; })
#endif

#if !defined(ABS)
#define ABS(A)  ({ __typeof__(A) __a= (A); __a < 0 ? -__a : __a; })
#endif

typedef double NSTimeInterval;

typedef struct NSRangeStruct {
  NSUInteger location;
  NSUInteger length;}
NSRange;

static inline NSRange NSMakeRange(NSUInteger pos, NSUInteger len) {
  NSRange r;
  r.location= pos;
  r.length=   len;
  return r;}

enum _NSComparisonResult {
  NSOrderedAscending= -1L,
  NSOrderedSame,
  NSOrderedDescending};
typedef NSInteger NSComparisonResult;

enum {NSNotFound= NSIntegerMax};

typedef NSUInteger NSStringEncoding;
enum {
  NSASCIIStringEncoding=          1, // 0..127 only
  NSNEXTSTEPStringEncoding=       2,
  NSJapaneseEUCStringEncoding=    3,
  NSUTF8StringEncoding=           4,
  NSISOLatin1StringEncoding=      5,
  NSSymbolStringEncoding=         6,
  NSNonLossyASCIIStringEncoding=  7,
  NSShiftJISStringEncoding=       8, // kCFStringEncodingDOSJapanese
  NSISOLatin2StringEncoding=      9,
  NSUnicodeStringEncoding=       10,
  NSWindowsCP1251StringEncoding= 11, // Cyrillic; same as AdobeStandardCyrillic
  NSWindowsCP1252StringEncoding= 12, // WinLatin1
  NSWindowsCP1253StringEncoding= 13, // Greek
  NSWindowsCP1254StringEncoding= 14, // Turkish
  NSWindowsCP1250StringEncoding= 15, // WinLatin2
  NSISO2022JPStringEncoding=     21, // ISO 2022 Japanese encoding for e-mail
  NSMacOSRomanStringEncoding=    30,
//NSDOSStringEncoding=           0x20000, // DOS: Added to NS...Encoding constants (see below)
  
  NSUTF16StringEncoding= NSUnicodeStringEncoding, // An alias for NSUnicodeStringEncoding
  
  NSUTF16BigEndianStringEncoding=    0x90000100,  // NSUTF16StringEncoding encoding with explicit endianness specified
  NSUTF16LittleEndianStringEncoding= 0x94000100,  // NSUTF16StringEncoding encoding with explicit endianness specified
};
#endif // defined(MSCORE_STANDALONE) || defined(MSCORE_FORFOUNDATION)

///// For everybody

#define MSCharMin   -128
#define MSCharMax   127
#define MSByteMax   255
#define MSShortMin  -32768
#define MSShortMax  32767
#define MSUShortMax 65535
#define MSIntMax    2147483647
#define MSIntMin    (-MSIntMax-1)
#define MSUIntMax   4294967295U
#define MSLongMax   9223372036854775807LL
#define MSLongMin   (-MSLongMax-1)
#define MSULongMax  18446744073709551615ULL

typedef enum {
  MSBigEndian= 0,
  MSLittleEndian= 1}
MSByteOrder;

enum {
  NSDOSStringEncoding= 0x20000 // we add a string encoding for DOS
};

///// Definition of mutexes
#ifdef WIN32

#define mutex_t                          CRITICAL_SECTION
#define mutex_init(mutex)                InitializeCriticalSection(&mutex)
#define mutex_lock(mutex)                EnterCriticalSection(&mutex)
#define mutex_trylock(mutex)             TryEnterCriticalSection(&mutex)
#define mutex_unlock(mutex)              LeaveCriticalSection(&mutex)
#define mutex_delete(mutex)              DeleteCriticalSection(&mutex)

#else

#define mutex_t                          pthread_mutex_t
#define mutex_init(mutex)                pthread_mutex_init(&mutex, NULL)
#define mutex_lock(mutex)                pthread_mutex_lock(&mutex)
#define mutex_trylock(mutex)             !pthread_mutex_trylock(&mutex)
#define mutex_unlock(mutex)              pthread_mutex_unlock(&mutex)
#define mutex_delete(mutex)              pthread_mutex_destroy(&mutex)

typedef int SOCKET;

#endif

///// Definition of MSFileHandle
#ifdef WIN32
#define MSFileHandle HANDLE
#define MSInvalidFileHandle INVALID_HANDLE_VALUE
#else
#define MSFileHandle int
#define MSInvalidFileHandle -1
#endif

#endif // MSCORE_TYPES_H

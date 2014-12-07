/* MSCoreSystem.h
 
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

#ifndef MS_CORE_SYSTEM_H
#define MS_CORE_SYSTEM_H

#pragma mark ***** System

// TODO: MHInitSSL
MSCoreExport void MSSystemInitialize(int argc, const char **argv);
#ifndef MSCORE_STANDALONE
MSCoreExport void _MSFoundationCoreSystemInitialize(void);
#endif

//#define MSMacAddressLength 6
//typedef struct {MSByte component[MSMacAddressLength];} MSMacAddress;
//MSCoreExport MSLong MSCurrentHostID(void);

MSCoreExport MSInt  MSCurrentProcessID(void);
MSCoreExport MSInt  MSCurrentThreadID(void);

MSCoreExport MSInt      MSCurrentTimezoneOffset(void);

MSCoreExport NSUInteger MSCapacityForCount(NSUInteger count);

#pragma mark ***** Language

typedef enum {
  MSItalian=          5, // ITALIAN ELF MOD 37
  MSFrench=          17, // FRENCH  ELF MOD 37
  MSSpanish=         20, // SPANISH ELF MOD 37
  MSGerman=          26, // GERMAN  ELF MOD 37
  MSEnglish=         29, // ENGLISH ELF MOD 37
  MSUnknownLanguage= 37}
MSLanguage;

MSCoreExport MSLanguage       MSCurrentLanguage(void);
MSCoreExport NSStringEncoding MSCurrentCStringEncoding(void);
MSCoreExport const char *     MSCStringEncodingName(NSStringEncoding encoding);

#pragma mark ***** Error reporting

// default implementation of error loging write messages on stderr and quit the current process
// with error code if error level is MSFatalError

typedef enum {
  MSLightError= 0,
  MSFatalError}
MSErrorLevel;

typedef enum {
  MSGenericError= 0,
  MSRangeError,
  MSInvalidArgumentError,
  MSInternalInconsistencyError,
  MSMallocError,
  MSMiscalculationError,
  MSMAPMError}
MSErrorDomain;

#define MSUnsignificantErrorCode            -1

// HM 27/08 : added error defines
// Generic errors
#define MSUnimplementedMethod             -100
#define MSMissingCallbackFunction         -200
#define MSNetworkLayerInitializationError -300
#define MSObjectLayerInitializationError  -400

// Allocation errors
#define MSMallocErrorCode     -1000
#define MSCAllocErrorCode     -2000
#define MSReallocErrorCode    -3000
#define MSFreeErrorCode       -4000

// InvalidArgument errors
#define MSTryToInsertNilError  -10000
#define MSIndexOutOfRangeError -20000
#define MSNULLPointerError     -30000
#define MSNotMutableError      -40000

typedef void (*MSErrorCallback)(MSErrorDomain, MSErrorLevel, MSInt, const char *);

MSCoreExport void MSReportError( MSErrorDomain domain, MSErrorLevel level, MSInt errorCode, const char *format, ...);
MSCoreExport void MSReportErrorV(MSErrorDomain domain, MSErrorLevel level, MSInt errorCode, const char *format, va_list argList);
MSCoreExport void MSSetErrorCallBack(MSErrorCallback fn);
  // not thread safe. use once.

#pragma mark ***** Memory

#define MSMalloc(    SZ, C) malloc(SZ)
#define MSRealloc(Z, SZ, C) realloc(Z, SZ)
#define MSCalloc( X, Y, C) calloc(X, Y) // allocated and filled with zeros
#define MSFree(   X   , C) free(X)      // free is ok with NULL

static inline void *MSMallocFatal(size_t sz, char *fct)
{
  void *p= MSMalloc(sz, NULL);
  if (!p) MSReportError(MSMallocError, MSFatalError, MSMallocErrorCode, fct);
  return p;
}

static inline void *MSReallocFatal(void *zone, size_t sz, char *fct)
{
  void *p= MSRealloc(zone, sz, NULL);
  if (!p) MSReportError(MSMallocError, MSFatalError, MSReallocErrorCode, fct);
  return p;
}

#pragma mark ***** Swap

static inline MSUShort MSSwap16(MSUShort s)
{
#ifdef WIN32
  MSUShort result;
  __asm__ volatile("rorw $8,%0" : "=r"  (result) : "0"  (s));
  return result;
#elif defined(__i386__) && defined(__GNUC__)
  __asm__("xchgb %b0, %h0" : "+q" (s));
  return s;
#elif defined(__ppc__) && defined(__GNUC__)
  MSUShort result;
  __asm__("lhbrx %0,0,%1" : "=r" (result) : "r" (&s), "m" (s));
  return result;
#else
  MSUShort result;
  result = ((s << 8) & 0xFF00) | ((s >> 8) & 0xFF);
  return result;
#endif
}

static inline MSUInt MSSwap32(MSUInt l)
{
#ifdef WIN32
  MSUInt result;
  __asm__ volatile("bswap %0" : "=r" (result) : "0"  (l));
  return result;
#elif defined(__i386__) && defined(__GNUC__)
  __asm__("bswap %0" : "+r" (l));
  return l;
#elif defined(__ppc__) && defined(__GNUC__)
  MSUInt result;
  __asm__("lwbrx %0,0,%1" : "=r" (result) : "r" (&l), "m" (l));
  return result;
#else
  MSUInt result;
  result = ((l & 0xFF) << 24) | ((l & 0xFF00) << 8) | ((l >> 8) & 0xFF00) | ((l >> 24) & 0xFF);
  return result;
#endif
}

static inline MSULong MSSwap64(MSULong ll)
{
  union __llconversion {
    MSULong  ull;
    MSUInt  ul[2];}
  *input, retour;
  
  input= (union __llconversion *)&ll;
  
  retour.ul[0]= MSSwap32(input->ul[1]);
  retour.ul[1]= MSSwap32(input->ul[0]);
  
  return (retour.ull);
}

#ifdef __BIG_ENDIAN__
#define MSCurrentByteOrder() MSBigEndian

#define MSFromLittle16(X)    MSSwap16(X)
#define MSFromBig16(X)       (X)
#define MSFromLittle32(X)    MSSwap32(X)
#define MSFromBig32(X)       (X)
#define MSFromLittle64(X)    MSSwap64(X)
#define MSFromBig64(X)       (X)
#else
#define MSCurrentByteOrder()  MSLittleEndian

#define MSFromLittle16(X)    (X)
#define MSFromBig16(X)       MSSwap16(X)
#define MSFromLittle32(X)    (X)
#define MSFromBig32(X)       MSSwap32(X)
#define MSFromLittle64(X)    (X)
#define MSFromBig64(X)       MSSwap64(X)
#endif

static inline MSUShort  MSFromOrder16(MSUShort X, MSByteOrder Y)
{ return (Y == MSBigEndian ? MSFromBig16(X) : MSFromLittle16(X)); }

static inline MSUInt  MSFromOrder32(MSUInt X, MSByteOrder Y)
{ return (Y == MSBigEndian ? MSFromBig32(X) : MSFromLittle32(X)); }

static inline MSULong MSFromOrder64(MSULong X, MSByteOrder Y)
{ return (Y == MSBigEndian ? MSFromBig64(X) : MSFromLittle64(X)); }

#endif // MS_CORE_SYSTEM_H

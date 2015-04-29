/* MSCoreSystem.c
 
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
 
 */

#include "MSCore_Private.h"

#pragma mark ***** Capacity

static NSUInteger _counts[128] = {
  /* 000 */   2,   2,   4,   4,   8,   8,   8,   8,
  /* 008 */  16,  16,  16,  16,  16,  16,  16,  16,
  /* 016 */  32,  32,  32,  32,  32,  32,  32,  32,
  /* 024 */  32,  32,  32,  32,  32,  32,  32,  32,
  /* 032 */  64,  64,  64,  64,  64,  64,  64,  64,
  /* 040 */  64,  64,  64,  64,  64,  64,  64,  64,
  /* 048 */  64,  64,  64,  64,  64,  64,  64,  64,
  /* 056 */ 128, 128, 128, 128, 128, 128, 128, 128,
  /* 064 */ 128, 128, 128, 128, 128, 128, 128, 128,
  /* 072 */ 128, 128, 128, 128, 128, 128, 128, 128,
  /* 080 */ 128, 128, 128, 128, 128, 128, 128, 128,
  /* 088 */ 128, 128, 128, 128, 128, 128, 128, 128,
  /* 096 */ 128, 128, 128, 128, 128, 128, 128, 128,
  /* 104 */ 256, 256, 256, 256, 256, 256, 256, 256,
  /* 112 */ 256, 256, 256, 256, 256, 256, 256, 256,
  /* 120 */ 256, 256, 256, 256, 256, 256, 256, 256};

NSUInteger MSCapacityForCount(NSUInteger count)
{ return (count < 128 ? _counts[count] : ((count + (count >> 1)) & (NSUInteger)~255) + 256); }

#pragma mark ***** Language

static const char *__encodingNames[15] = {
  "ASCII",
  "NEXTSTEP",
  "Japanese EUC",
  "UTF8",
  "ISO Latin 1",
  "Symbol",
  "Non-lossy ASCII",
  "Shift JIS",
  "ISO Latin 2",
  "UTF16",
  "Windows CP 1251 (Cyrillic)",
  "Windows CP 1252 (WinLatin 1)",
  "Windows CP 1253 (Greek)",
  "Windows CP 1254 (Turkish)",
  "Windows CP 1250 (WinLatin 2)"};

MSLanguage  MSCurrentLanguage(void)
{
#ifdef WIN32_NOTWORKING
  unsigned wcl = (unsigned)GetUserDefaultUILanguage();
  switch ((wcl & 0xff)) {
    case 0x09: return MSEnglish;
    case 0x0A: return MSSpanish;
    case 0x07: return MSGerman;
    case 0x0c: return MSFrench;
    case 0x10: return MSItalian;
    default:   return MSFrench; /* Microstep comes from France, right ?*/
      break;
  }
#else
  return MSFrench; /* TODO: find a way to get the current language on MacOSX or Unix */
#endif
}

NSStringEncoding  MSCurrentCStringEncoding(void)
{
#if defined(WIN32)
  return NSWindowsCP1252StringEncoding;
#elif defined(__APPLE__)
  return NSMacOSRomanStringEncoding;
#else
  return NSISOLatin1StringEncoding;
#endif
}

const char *MSCStringEncodingName(NSStringEncoding e)
{
  if ((int)e < 16) { return __encodingNames[(int)e - 1]; }
  switch (e) {
    case NSISO2022JPStringEncoding:      return (const char *)"ISO 2022 JP";
    case NSMacOSRomanStringEncoding:    return (const char *)"Mac Roman";
    case NSUTF16StringEncoding:        return __encodingNames[9];
    case NSUTF16BigEndianStringEncoding:  return (const char *)"UTF16 (Big endian)";
    case NSUTF16LittleEndianStringEncoding:  return (const char *)"UTF16 (Little endian)";
/*
#ifndef MSCORE_STANDALONE
#ifdef __APPLE__
    case NSUTF32StringEncoding:        return (const char *)"UTF32";
    case NSUTF32BigEndianStringEncoding:  return (const char *)"UTF32 (Big endian)";
    case NSUTF32LittleEndianStringEncoding:  return (const char *)"UTF32 (Little endian)";
#endif
#endif
*/
    default:                return (const char *)"";
  }
}

#pragma mark ***** Error reporting

static char *__errorDomains[7] = {
  "generic error",
  "range error",
  "invalid argument error",
  "internal inconsistency error",
  "allocation error",
  "miscalculation error",
  "MAPM library error"
};

void MSReportError(MSErrorDomain domain, MSErrorLevel level, MSInt errorCode, const char *format, ...)
{
  va_list ap;
  va_start (ap, format);
  MSReportErrorV(domain, level, errorCode, format, ap);
  va_end(ap);
}

static MSErrorCallback __errorCallback = NULL;

void MSReportErrorV(MSErrorDomain domain, MSErrorLevel level, MSInt errorCode, const char *format, va_list ap)
{
  char buf[1024];
  if (format) { vsnprintf(buf, 1023, format, ap); }
  else { buf[0] = '\0'; }
  
  if (__errorCallback) {
    __errorCallback(domain, level, errorCode, buf);
  }
  else {
    fprintf(stderr, "MSCore %s #%d:%s\n", __errorDomains[domain], errorCode, buf);
    fflush(stderr);
    if (level == MSFatalError) { exit(errorCode); }
  }
}

void MSSetErrorCallBack(MSErrorCallback fn) { __errorCallback = fn; }

#pragma mark ***** Date and time

#ifdef WIN32
MSInt MSCurrentTimezoneOffset(void)
{
  SYSTEMTIME stm, ltm;
  GetSystemTime(&stm);
  GetLocalTime(&ltm);
  return (ltm.wSecond - stm.wSecond) + (ltm.wMinute - stm.wMinute) * 60 + (ltm.wHour - stm.wHour) * 3600;
}
#else
MSInt MSCurrentTimezoneOffset(void)
{
  struct tm tm;
  time_t t = time(NULL);
  (void)localtime_r(&t, &tm);
  return (int)(tm.tm_gmtoff);
}
#endif

#pragma mark ***** System

MSInt MSCurrentProcessID(void)
{
    return (MSInt)getpid();
}

MSInt  MSCurrentThreadID(void)
{
    return (MSInt)gettid();
}
/*
MSLong MSCurrentHostID(void)
{
#ifdef WIN32
  // OK, that's not a real gethostid bur we have a "unique" ID for this host.
  MSMacAddress addr = MSMacAddressFromInterfaceName(NULL);
  MSLong ret = 0;
  unsigned len = MIN(MSMacAddressLength,8);
  memcpy(((MSByte *)&ret)+8-len, &addr, len);
  return ret;
#else
  return gethostid();
#endif
}
*/

static void _MS_APM_Log_callback(int m_apm_error, const char *m_apm_log)
{
  MSReportError(MSMAPMError, (m_apm_error > 0 ? MSFatalError : MSLightError),
    m_apm_error, m_apm_log);
}

static M_APM _MS_APM_Allocate(void)
{
  return (M_APM)MSCreateObjectWithClassIndex(CDecimalClassIndex);
}

void _CObjectInitialize();
void _CDateInitialize();
void _MSTEInitialize();
void _CMessageInitialize();

#if defined(WO451)
// WO451 is so old that this is a non existing feature. So call MSFinishLoadingCore by yourself...
#elif defined(MSCORE_STANDALONE)
// This makes MSFinishLoadingCore beeing called when the MSCoreC lib is loaded (before "main call"/"dlopen returns")
// Because it's the only point where MSCoreC lib use lib initialization, it's safe to use any part of MSCore in this
__attribute__((constructor))
#else
// MSFinishLoadingConfigure(foundationClassCount, MSFinishLoadingCore, NULL) is used (see MSCObject.m)
// MSFinishLoadingCore is executed when all the foundation class added via MSFinishLoadingAddClass
// are loaded, but before they receive there finishLoading method. They are nevertheless operational
// for the bridge.
#endif
void MSFinishLoadingCore()
{
  static BOOL done= NO;
  if (!done) {
    M_apm_free_fn freeFct;
    done= YES;
    _CObjectInitialize();
#ifdef MSCORE_STANDALONE
    freeFct= (M_apm_free_fn)_CRelease;
#elif MSCORE_FORFOUNDATION
    freeFct= (M_apm_free_fn)_MRelease;
#endif
    m_apm_set_callbacks(_MS_APM_Allocate, freeFct, _MS_APM_Log_callback, NULL);
    M_init_mapm_constants();
    _CDateInitialize();
    _MSTEInitialize();
    _CMessageInitialize();
    }
}

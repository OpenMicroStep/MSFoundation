/* MSCorePlatform-win32.c
 
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

#ifdef WIN32

#include <Rpc.h>

void uuid_generate_string(char dst[37])
{
  UUID uuid;
  UuidCreate (&uuid);
  const char *str;
  UuidToString(&uuid, &str);
  strncpy(dst, str, 37);
  RpcStringFree(&str);
}

// this **!@** structure count by 100 nanoseconds steps since 1st january 1601
#define _MSTimeIntervalSince1601 12622780800ull

static inline void _FileTimeToMicro(FILETIME ft, MSLong *t)
{
  MSULong d;
  d = (((MSULong) ft.dwHighDateTime) << 32) + ft.dwLowDateTime;
  *t = (MSTimeInterval)(d - _MSTimeIntervalSince1601*10000000) / 10;
}
static inline void _FileTimeToMSTimeInterval(FILETIME ft, MSTimeInterval *t)
{
  MSULong d;
  d = (((MSULong) ft.dwHighDateTime) << 32) + ft.dwLowDateTime;
  d /= 10000000;
  *t = (MSTimeInterval)(d) - _MSTimeIntervalSince1601;
}

static inline void _MSTimeIntervalToFileTime(MSTimeInterval t, FILETIME * ft)
{
  MSULong d;
  d = t + _MSTimeIntervalSince1601;
  d *= 10000000;
  ft->dwLowDateTime  = (MSUInt) (d & 0xFFFFFFFF );
  ft->dwHighDateTime = (MSUInt) (d >> 32 );
}

#ifdef WO451 
// Apple System headers doesn't provide this method because it was introduced in WinXP/WinServer2003
// Linking with Apple won't work either, one workaround is to link with a newer version of libKernel32.a
// A version compatible with the old wo451 linker can be found in the MinGW package.
// The name of the lib for linker can't be Kernel32 due to linker not looking at libKernel32.a with such name.
BOOL WINAPI TzSpecificLocalTimeToSystemTime(void* lpTimeZoneInformation,void* lpLocalTime,void* lpUniversalTime);
#endif

MSLong gmt_micro(void)
{
  MSLong t;
  FILETIME fts;
  GetSystemTimeAsFileTime(&fts);
  _FileTimeToMicro(fts, &t);
  return t;
}

MSTimeInterval gmt_now(void)
{
  MSTimeInterval t;
  FILETIME fts;
  GetSystemTimeAsFileTime(&fts);
  _FileTimeToMSTimeInterval(fts, &t);
  return t;
}

MSTimeInterval gmt_to_local(MSTimeInterval tIn)
{
  MSTimeInterval tOut;
  FILETIME fts, ftl;
  SYSTEMTIME sts, stl;
  _MSTimeIntervalToFileTime(tIn, &fts);
  if (FileTimeToSystemTime(&fts, &sts) && // According to MSDN, this is a necessary conversion to take daylight into account
      SystemTimeToTzSpecificLocalTime(NULL /* uses the currently active time zone */, &sts, &stl) &&
      SystemTimeToFileTime(&stl, &ftl))
    _FileTimeToMSTimeInterval(ftl, &tOut);
  else tOut = tIn;
  return tOut;
}

MSTimeInterval gmt_from_local(MSTimeInterval t)
{
  FILETIME fts, ftl;
  SYSTEMTIME sts, stl;
  _MSTimeIntervalToFileTime(t, &ftl);
  if (FileTimeToSystemTime(&ftl, &stl) && // According to MSDN, this is a necessary conversion to take daylight into account
      TzSpecificLocalTimeToSystemTime(NULL /* uses the currently active time zone */, &stl, &sts) &&
      SystemTimeToFileTime(&sts, &fts))
    _FileTimeToMSTimeInterval(fts, &t);
  return t;
}

#endif


// WIN32 count by 100 nanoseconds steps since 1st january 1601
#define _MSTimeIntervalSince1601 12622780800ULL
#define _UNIXTimeIntervalSince1601 11644473600ULL

static inline uint64_t _FileTimeToUNIX100ns(FILETIME ft)
{
  uint64_t d= ((((uint64_t) ft.dwHighDateTime) << 32) + ft.dwLowDateTime); // in 100ns
  return (int64_t)d - _UNIXTimeIntervalSince1601 * 10000000 /* s -> 100ns (10^7) */;
}
static inline int64_t _FileTimeToMicro(FILETIME ft)
{
  uint64_t d= ((((uint64_t) ft.dwHighDateTime) << 32) + ft.dwLowDateTime) / 10; // in us
  return (int64_t)d - _MSTimeIntervalSince1601 * 1000000 /* s -> us (10^6) */;
}
static inline int64_t _FileTimeToMSTimeInterval(FILETIME ft)
{
  uint64_t d= ((((uint64_t) ft.dwHighDateTime) << 32) + ft.dwLowDateTime) / 10000000;
  return (int64_t)(d) - _MSTimeIntervalSince1601;
}

static inline void _MSTimeIntervalToFileTime(int64_t t, FILETIME * ft)
{
  uint64_t d= (t + _MSTimeIntervalSince1601) * 10000000;
  ft->dwLowDateTime  = (uint32_t) (d & 0xFFFFFFFF );
  ft->dwHighDateTime = (uint32_t) (d >> 32 );
}

#ifdef WO451 
// Apple System headers doesn't provide this method because it was introduced in WinXP/WinServer2003
// Linking with Apple won't work either, one workaround is to link with a newer version of libKernel32.a
// A version compatible with the old wo451 linker can be found in the MinGW package.
// The name of the lib for linker can't be Kernel32 due to linker not looking at libKernel32.a with such name.
BOOL WINAPI TzSpecificLocalTimeToSystemTime(void* lpTimeZoneInformation,void* lpLocalTime,void* lpUniversalTime);
#endif

int timespec_get(struct timespec *ts, int base)
{
  if(base == TIME_UTC) {
    FILETIME ft; uint64_t unixTimeIn100ns;
    GetSystemTimeAsFileTime(&ft);
    unixTimeIn100ns= _FileTimeToUNIX100ns(ft);
    ts->tv_sec = unixTimeIn100ns / 10000000; /* 100ns -> s (10^7) */
    ts->tv_nsec = (long)(unixTimeIn100ns % 10000000); /* 100ns -> s (10^7) */
    return base;
  }
  return 0;
}

int64_t ms_gmt_now_micro(void)
{
  FILETIME fts;
  GetSystemTimeAsFileTime(&fts);
  return _FileTimeToMicro(fts);
}

int64_t ms_gmt_now(void)
{
  FILETIME fts;
  GetSystemTimeAsFileTime(&fts);
  return _FileTimeToMSTimeInterval(fts);
}

int64_t ms_gmt_to_local(int64_t tIn)
{
  int64_t tOut;
  FILETIME fts, ftl;
  SYSTEMTIME sts, stl;
  _MSTimeIntervalToFileTime(tIn, &fts);
  if (FileTimeToSystemTime(&fts, &sts) && // According to MSDN, this is a necessary conversion to take daylight into account
      SystemTimeToTzSpecificLocalTime(NULL /* uses the currently active time zone */, &sts, &stl) &&
      SystemTimeToFileTime(&stl, &ftl))
    tOut= _FileTimeToMSTimeInterval(ftl);
  else tOut = tIn;
  return tOut;
}

int64_t ms_gmt_from_local(int64_t t)
{
  FILETIME fts, ftl;
  SYSTEMTIME sts, stl;
  _MSTimeIntervalToFileTime(t, &ftl);
  if (FileTimeToSystemTime(&ftl, &stl) && // According to MSDN, this is a necessary conversion to take daylight into account
      TzSpecificLocalTimeToSystemTime(NULL /* uses the currently active time zone */, &stl, &sts) &&
      SystemTimeToFileTime(&sts, &fts))
    t= _FileTimeToMSTimeInterval(fts);
  return t;
}

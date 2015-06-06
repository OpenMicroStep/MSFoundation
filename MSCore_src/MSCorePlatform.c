#include "MSCore_Private.h"

int mtx_timedlock(mtx_t *restrict mutex, const struct timespec *restrict time_point)
{
  int ret;
  struct timespec t;
  
  while((ret= mtx_trylock(mutex)) == thrd_busy)
  {
    timespec_get(&t, TIME_UTC);
    if(t.tv_sec >= time_point->tv_sec && t.tv_nsec >= time_point->tv_nsec)
      return thrd_timedout;
    thrd_yield();
  }
  return ret;
}

#if defined(APPLE)
#include "MSCorePlatform-apple.i"
#endif

#if defined(UNIX)
#include "MSCorePlatform-unix.i"
#endif

#if defined(LINUX)
#include "MSCorePlatform-linux.i"
#endif

#if defined(WIN32)
#include "MSCorePlatform-win32.i"
#endif

#if defined(WO451)
#include "MSCorePlatform-wo451.i"
#endif

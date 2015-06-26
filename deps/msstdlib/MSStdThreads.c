#include "MSStd_Private.h"

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

#if defined(UNIX)
#include "MSStdThreads-unix.c"
#elif defined(WIN32)
#include "MSStdThreads-win32.c"
#else
#error MSStdThreads: unsupported platform
#endif

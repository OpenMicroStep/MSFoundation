#include <sys/time.h>

static const int64_t CDateSecondsFrom19700101To20010101 = 978307200LL;

int timespec_get(struct timespec *ts, int base)
{
#ifdef APPLE
  if (base == TIME_UTC) {
      struct timeval now;
      int rv = gettimeofday(&now, NULL);
      if (rv == 0) {
        ts->tv_sec = now.tv_sec;
        ts->tv_nsec= now.tv_usec * 1000;
        return base;
      }
  }
  return 0;
#else
  return (base == TIME_UTC && clock_gettime(CLOCK_REALTIME, ts) == 0) ? base : 0;
#endif
}

int64_t ms_gmt_now_micro(void)
{
  int64_t t;
  struct timeval tv;
  gettimeofday(&tv,NULL);
  t= ((int64_t)tv.tv_sec - CDateSecondsFrom19700101To20010101)*1000000LL + (int64_t)tv.tv_usec;
  return t;
}

int64_t ms_gmt_now(void)
{
  int64_t t;
  time_t timet= time(NULL);
  t= (int64_t)timet - CDateSecondsFrom19700101To20010101;
  return t;
}

int64_t ms_gmt_to_local(int64_t t)
{
  struct tm tm;
  time_t timet= t + CDateSecondsFrom19700101To20010101;
  (void)localtime_r(&timet, &tm);
  return (int64_t)timet - CDateSecondsFrom19700101To20010101 + (int64_t)(tm.tm_gmtoff);
}

int64_t ms_gmt_from_local(int64_t t)
{
  struct tm tm;
  time_t timet= (time_t)(t + CDateSecondsFrom19700101To20010101);
  (void)mktime(gmtime_r(&timet, &tm));
  return t - (int64_t)tm.tm_gmtoff;
}

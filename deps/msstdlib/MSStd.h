// MSStd.h

#ifndef MSSTD_H
#define MSSTD_H

////////
// Platform defines

// Platform detection
#if !defined(LINUX) && defined(__linux__)
#define _GNU_SOURCE 1
#define LINUX 1
#endif

#if !defined(WIN32) && defined(_WIN32)
#define WIN32 1
#endif

#if !defined(WIN64) && defined(_WIN64)
#define WIN64 1
#endif

#if !defined(APPLE) && defined(__APPLE__)
#define APPLE 1
#endif

#if !defined(UNIX) && (defined(LINUX) || defined(APPLE))
#define UNIX 1
#endif

#if !defined(MSVC) && defined(_MSC_VER)
#define MSVC 1
#endif

#if !defined(MINGW) && defined(__MINGW32__)
#define MINGW 1
#endif

// Lib export
#ifdef __cplusplus
    #define EXTERN_C extern "C"
    #define restrict 
    #define register 
#else
    #define EXTERN_C extern
#endif

#ifdef WIN32
    #define LIBEXPORT EXTERN_C __declspec(dllexport)
    #define LIBIMPORT EXTERN_C __declspec(dllimport)
#else
    #define LIBEXPORT EXTERN_C
    #define LIBIMPORT EXTERN_C
#endif

#if defined(MSSTD_PRIVATE_H) || defined(MSSTD_EXPORT)
#define MSStdExtern LIBEXPORT
#else
#define MSStdExtern LIBIMPORT
#endif
// END Platform defines
////////


////////
// Default Includes
#include <stdarg.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <limits.h>
#include <float.h>
#include <math.h>
#include <time.h>

#ifdef WIN32
#  include <windows.h>
#  undef min
#  undef max
#else
#  include <sys/syscall.h>
#  include <unistd.h>
#  include <fcntl.h>
#  include <signal.h>
#endif
// END Default Includes
////////

////////
// Simple platform abstraction

// WO451
#ifdef WO451
  typedef char               int8_t;
  typedef unsigned char      uint8_t;
  typedef short              int16_t;
  typedef unsigned short     uint16_t;
  typedef int                int32_t;
  typedef unsigned int       uint32_t;
  typedef long long          int64_t;
  typedef unsigned long long uint64_t;
  typedef long               intptr_t;
  typedef unsigned long      uintptr_t;
  typedef int64_t            intmax_t;
  typedef uint64_t           uintmax_t;
# define restrict
# ifndef UINT8_MAX
#   define UINT8_MAX 255
# endif
# ifndef LLONG_MIN
#   define LLONG_MIN (-LLONG_MAX-1)
# endif
# ifndef LLONG_MAX
#   define LLONG_MAX 9223372036854775807LL
# endif
# ifndef ULLONG_MAX
#   define ULLONG_MAX 18446744073709551615ULL
# endif
# ifndef INTPTR_MIN
#   define INTPTR_MIN 0
# endif
# ifndef INTPTR_MAX
#   define INTPTR_MAX 2147483647
# endif
# ifndef UINTPTR_MAX
#   define UINTPTR_MAX 4294967295U
# endif
# define __sync_add_and_fetch(X,Y) ({ (*(X))+=Y; *(X);})
# define __sync_sub_and_fetch(X,Y) ({ (*(X))-=Y; *(X);})

  static inline int vsnprintf(char *str, size_t size, const char *format, va_list ap) { return _vsnprintf(str, size, format, ap); }
#endif

#if defined(WIN32) && !defined(__MINGW32__)
MSStdExtern int snprintf(char *str, size_t size, const char *format, ...);
#endif 

#if defined(MSVC)
  static inline float strtof(const char *string, char **endPtr) { return (float)strtod(string, endPtr); }
  MSStdExtern char *strtok_r(char *s, const char *delim, char **save_ptr);
#endif
#if defined(WIN32)
  static inline int usleep(int32_t usec) { usec /= 1000; Sleep(usec > 0 ? usec : 1); return 0; }
#endif

#if !defined(_STRUCT_TIMESPEC) && !defined(__timespec_defined) && !defined(_TIMESPEC_DEFINED)
struct timespec {
  time_t tv_sec;
  long tv_nsec;
};
#endif

// C11 std polyfill
#ifndef WIN32
#include <pthread.h>
#endif

// Threads
enum {
    thrd_success = 0,
    thrd_nomem = 1,
    thrd_timedout = 2,
    thrd_busy = 3,
    thrd_error = 4
};
typedef int(*thrd_start_t)(void*);
#ifdef WIN32
  typedef struct { DWORD id; HANDLE handle; } thrd_t;
#else
  typedef pthread_t thrd_t;
#endif
MSStdExtern int thrd_create(thrd_t *thr, thrd_start_t func, void *arg);
MSStdExtern int thrd_equal(thrd_t lhs, thrd_t rhs);
MSStdExtern thrd_t thrd_current();
MSStdExtern int thrd_sleep(const struct timespec* duration, struct timespec* remaining);
MSStdExtern void thrd_yield();
MSStdExtern int thrd_detach(thrd_t thr);
MSStdExtern int thrd_join(thrd_t thr, int *res);
MSStdExtern _Noreturn void thrd_exit(int res);

// Mutual exclusion
enum {
    mtx_plain = 1,
    mtx_recursive = 2,
    mtx_timed = 4
};
#ifdef WIN32
  typedef CRITICAL_SECTION mtx_t;
#else
  typedef pthread_mutex_t mtx_t;
#endif
MSStdExtern int mtx_init(mtx_t* mutex, int type);
MSStdExtern int mtx_lock(mtx_t* mutex);
MSStdExtern int mtx_timedlock(mtx_t *restrict mutex, const struct timespec *restrict duration );
MSStdExtern int mtx_trylock(mtx_t *mutex);
MSStdExtern int mtx_unlock(mtx_t* handle);
MSStdExtern void mtx_destroy(mtx_t* handle);

// Call one
#ifdef WIN32
  typedef struct { HANDLE event; uint8_t ran; } once_flag;
  #define ONCE_FLAG_INIT {0, 0}
#else
  typedef pthread_once_t once_flag;
  #define ONCE_FLAG_INIT PTHREAD_ONCE_INIT
#endif
MSStdExtern void call_once(once_flag* flag, void (*func)(void));

// Condition variables
#ifdef WIN32
  #ifndef RTL_CONDITION_VARIABLE_INIT
    typedef PVOID CONDITION_VARIABLE, *PCONDITION_VARIABLE;
  #endif
  typedef union {
      CONDITION_VARIABLE native; // >= vista
      struct {
        uint32_t waiters_count;
        HANDLE handles[2];
      } fallback; // <= xp
  } cnd_t;
#else
  typedef pthread_cond_t cnd_t;
#endif
MSStdExtern int cnd_init(cnd_t* cond);
MSStdExtern int cnd_signal(cnd_t *cond);
MSStdExtern int cnd_broadcast(cnd_t *cond);
MSStdExtern int cnd_wait(cnd_t* cond, mtx_t* mutex);
MSStdExtern int cnd_timedwait(cnd_t* restrict cond, mtx_t* restrict mutex, const struct timespec* restrict duration);
MSStdExtern void cnd_destroy(cnd_t* cond);

// Thread-local storage
typedef void(*tss_dtor_t)(void *);
#ifdef WIN32
  typedef DWORD tss_t;
#else
  typedef pthread_key_t tss_t;
#endif
#define TSS_DTOR_ITERATIONS 4
#define thread_local _Thread_local
MSStdExtern int tss_create(tss_t* tss_key, tss_dtor_t destructor);
MSStdExtern void *tss_get(tss_t tss_key);
MSStdExtern int tss_set(tss_t tss_id, void *val);
MSStdExtern void tss_delete(tss_t tss_id);

#ifndef TIME_UTC
#define TIME_UTC 1
MSStdExtern int timespec_get(struct timespec *ts, int base);
#endif // C11 Date & Time polyfill

#define MS_DECLARE_MUTEX(VARNAME) \
  static mtx_t VARNAME; \
  __attribute__((constructor)) static void VARNAME ## __ctor() { mtx_init(&VARNAME, mtx_plain); } \
  __attribute__((destructor))  static void VARNAME ## __dtor() { mtx_destroy(&VARNAME); }

#define MS_DECLARE_THREAD_LOCAL(VARNAME, DESTRUCTOR) \
  static tss_t VARNAME; \
  __attribute__((constructor)) static void VARNAME ## __ctor() { tss_create(&VARNAME, DESTRUCTOR); } \
  __attribute__((destructor))  static void VARNAME ## __dtor() { tss_delete(VARNAME); }

// Process
#ifdef WIN32
  typedef DWORD ms_process_id_t;
  typedef DWORD ms_thread_id_t;
#else
  typedef pid_t ms_process_id_t;
  typedef pid_t ms_thread_id_t;
#endif
MSStdExtern ms_process_id_t ms_get_current_process_id();
MSStdExtern ms_thread_id_t ms_get_current_thread_id();
MSStdExtern const char* ms_get_current_process_path();

// Shared objects (.dll, .dylib, .so, ...)
typedef void* ms_shared_object_t;
MSStdExtern ms_shared_object_t ms_shared_object_open(const char *path);
MSStdExtern int ms_shared_object_close(ms_shared_object_t handle);
MSStdExtern void *ms_shared_object_symbol(ms_shared_object_t handle, const char *symbol);
MSStdExtern const char* ms_shared_object_name(void *addr);
MSStdExtern void ms_shared_object_iterate(void (*callback)(const char *name, void *data), void *data);

MSStdExtern void ms_generate_uuid(char dst[37]);

MSStdExtern int64_t ms_gmt_now();
MSStdExtern int64_t ms_gmt_now_micro();
MSStdExtern int64_t ms_gmt_to_local(int64_t gmt);
MSStdExtern int64_t ms_gmt_from_local(int64_t local);

// END Simple platform abstraction
////////

#endif

// MSCorePlatform.h

#ifndef MSCORE_PLATFORM_H
#define MSCORE_PLATFORM_H

////////
// Platform defines

// Platform detection
#ifndef LINUX
#ifdef __linux__
#define _GNU_SOURCE
#define LINUX 1
#endif
#endif

#ifndef WIN32
#ifdef _WIN32
#define WIN32 1
#endif
#endif

#ifndef WIN64
#ifdef _WIN64
#define WIN64 1
#endif
#endif

#ifndef APPLE
#ifdef __APPLE__
#define APPLE 1
#endif
#endif

#ifndef UNIX
#if defined(LINUX) || defined(APPLE)
#define UNIX 1
#endif
#endif

// Lib export
#ifdef __cplusplus
    #define EXTERN_C extern "C"
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

#if defined(MSCORE_PRIVATE_H) || defined(FOUNDATION_PRIVATE_H) || defined(MSFOUNDATION_PRIVATE_H)
#define MSCoreExtern LIBEXPORT
#else
#define MSCoreExtern LIBIMPORT
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
    #include <windows.h>
#else
    #include <sys/syscall.h>
    #include <unistd.h>
    #include <fcntl.h>
    #include <signal.h>
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

MSCoreExtern float strtof(const char *string, char **endPtr);
MSCoreExtern int snprintf(char *str, size_t size, const char *format, ...);
MSCoreExtern int vsnprintf(char *str, size_t size, const char *format, va_list ap);
#endif

#ifdef WIN32
static inline int usleep(int32_t usec) { usec /= 1000; Sleep(usec > 0 ? usec : 1); return 0; }
#endif

#if defined(__STDC_NO_THREADS__) || __STDC_VERSION__ < 201112L || !__has_include(<threads.h>)
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
MSCoreExtern int thrd_create(thrd_t *thr, thrd_start_t func, void *arg);
MSCoreExtern int thrd_equal(thrd_t lhs, thrd_t rhs);
MSCoreExtern thrd_t thrd_current();
MSCoreExtern int thrd_sleep(const struct timespec* duration, struct timespec* remaining);
MSCoreExtern void thrd_yield();
MSCoreExtern int thrd_detach(thrd_t thr);
MSCoreExtern int thrd_join(thrd_t thr, int *res);
MSCoreExtern _Noreturn void thrd_exit(int res);

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
MSCoreExtern int mtx_init(mtx_t* mutex, int type);
MSCoreExtern int mtx_lock(mtx_t* mutex);
MSCoreExtern int mtx_timedlock(mtx_t *restrict mutex, const struct timespec *restrict duration );
MSCoreExtern int mtx_trylock(mtx_t *mutex);
MSCoreExtern int mtx_unlock(mtx_t* handle);
MSCoreExtern void mtx_destroy(mtx_t* handle);

// Call one
#ifdef WIN32
  typedef struct { HANDLE event; uint8_t ran; } once_flag;
  #define ONCE_FLAG_INIT {0, 0}
#else
  typedef pthread_once_t once_flag;
  #define ONCE_FLAG_INIT PTHREAD_ONCE_INIT
#endif
MSCoreExtern void call_once(once_flag* flag, void (*func)(void));

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
MSCoreExtern int cnd_init(cnd_t* cond);
MSCoreExtern int cnd_signal(cnd_t *cond);
MSCoreExtern int cnd_broadcast(cnd_t *cond);
MSCoreExtern int cnd_wait(cnd_t* cond, mtx_t* mutex);
MSCoreExtern int cnd_timedwait(cnd_t* restrict cond, mtx_t* restrict mutex, const struct timespec* restrict duration);
MSCoreExtern void cnd_destroy(cnd_t* cond);

// Thread-local storage
typedef void(*tss_dtor_t)(void *);
#ifdef WIN32
  typedef struct { DWORD idx; tss_dtor_t dtor; } tss_t;
#else
  typedef pthread_key_t tss_t;
#endif
#define TSS_DTOR_ITERATIONS 4
#define thread_local _Thread_local
MSCoreExtern int tss_create(tss_t* tss_key, tss_dtor_t destructor);
MSCoreExtern void *tss_get(tss_t tss_key);
MSCoreExtern int tss_set(tss_t tss_id, void *val);
MSCoreExtern void tss_delete(tss_t tss_id);

#else // __STDC_NO_THREADS__
#include <threads.h>
#endif

#ifndef TIME_UTC
#define TIME_UTC 1
#if !defined(_STRUCT_TIMESPEC) && !defined(__timespec_defined) && !defined(_TIMESPEC_DEFINED)
struct timespec {
  time_t tv_sec;
  long tv_nsec;
};
#endif
MSCoreExtern int timespec_get(struct timespec *ts, int base);
#endif // C11 Date & Time polyfill

#define MS_DECLARE_MUTEX(VARNAME) \
  static mtx_t VARNAME; \
  __attribute__((constructor)) static void VARNAME ## __ctor() { mtx_init(&VARNAME, mtx_plain); } \
  __attribute__((destructor))  static void VARNAME ## __dtor() { mtx_destroy(&VARNAME); }

#define MS_DECLARE_THREAD_LOCAL(VARNAME, DESTRUCTOR) \
  static tss_t VARNAME; \
  __attribute__((constructor)) static void VARNAME ## __ctor() { tss_create(&VARNAME, DESTRUCTOR); } \
  __attribute__((destructor))  static void VARNAME ## __dtor() { tss_delete(VARNAME); }

// Old mutexes (to be removed)
#ifdef WIN32
    typedef CRITICAL_SECTION      mutex_t;
    #define mutex_init(mutex)     InitializeCriticalSection(&mutex)
    #define mutex_lock(mutex)     EnterCriticalSection(&mutex)
    #define mutex_trylock(mutex)  TryEnterCriticalSection(&mutex)
    #define mutex_unlock(mutex)   LeaveCriticalSection(&mutex)
    #define mutex_delete(mutex)   DeleteCriticalSection(&mutex)
#else
    typedef pthread_mutex_t       mutex_t;
    #define mutex_init(mutex)     pthread_mutex_init(&mutex, NULL)
    #define mutex_lock(mutex)     pthread_mutex_lock(&mutex)
    #define mutex_trylock(mutex)  !pthread_mutex_trylock(&mutex)
    #define mutex_unlock(mutex)   pthread_mutex_unlock(&mutex)
    #define mutex_delete(mutex)   pthread_mutex_destroy(&mutex)
#endif

// Process
#ifdef WIN32
  typedef DWORD ms_process_id_t;
  typedef DWORD ms_thread_id_t;
#else
  typedef pid_t ms_process_id_t;
  typedef pid_t ms_thread_id_t;
#endif
MSCoreExtern ms_process_id_t ms_get_current_process_id();
MSCoreExtern const char* ms_get_current_process_path();

// Shared objects (.dll, .dylib, .so, ...)
typedef void* ms_shared_object_t;
MSCoreExtern ms_shared_object_t ms_shared_object_open(const char *path);
MSCoreExtern int ms_shared_object_close(ms_shared_object_t handle);
MSCoreExtern void *ms_shared_object_symbol(ms_shared_object_t handle, const char *symbol);
MSCoreExtern const char* ms_shared_object_name(void *addr);
MSCoreExtern void ms_shared_object_iterate(void (*callback)(const char *name, void *data), void *data);

// END Simple platform abstraction
////////

#endif

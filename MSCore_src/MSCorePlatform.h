// MSCorePlatform.h

#ifndef MSCORE_PLATFORM_H
#define MSCORE_PLATFORM_H

////////
// Platform defines

// Platform detection
#ifndef LINUX
#ifdef __LINUX__
#define LINUX
#endif
#endif

#ifndef WIN32
#ifdef __WIN32__
#define WIN32
#endif
#endif

#ifndef APPLE
#ifdef __APPLE__
#define APPLE
#endif
#endif

#ifndef UNIX
#if defined(LINUX) || defined(APPLE)
#define UNIX
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

#if defined(MSCORE_PRIVATE_H) || defined(MSFOUNDATION_PRIVATE_H)
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
#include <string.h>
#include <limits.h>
#include <math.h>
#include <time.h>

#ifdef WIN32
    #include <windows.h>
#else
    #include <sys/syscall.h>
    #include <unistd.h>
    #include <pthread.h>
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
#   define INTPTR_MIN (-INTPTR_MAX-1)
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

// Mutexes
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

// dlopen/dlsym/dlclose
#ifdef WIN32
    #define RTLD_LAZY 0
    #define RTLD_NOW  1
    typedef HMODULE dl_handle_t;
    static inline dl_handle_t dlopen(const char *path, int mode)       { return LoadLibrary(path); }
    static inline int dlclose(dl_handle_t *handle)                     { return FreeLibrary(handle) ? 0 : -1; }
    static inline void* dlsym(dl_handle_t *handle, const char *symbol) { return GetProcAddress(handle, symbol); }
#else
    #include <dlfcn.h>
    typedef void* dl_handle_t;
#endif

// getpid/gettid
#ifdef WIN32
    typedef DWORD pid_t;
    static inline pid_t getpid() { return GetCurrentProcessId(); }
    static inline pid_t gettid() { return GetCurrentThreadId(); }
#elif defined(APPLE)
    static inline pid_t gettid() { return syscall(SYS_getpid); }
#endif

// END Simple platform abstraction
////////

#endif

//
//  CommonDefines.h
//  MSFoundation
//
//  Created by Vincent Rouillé on 27/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#ifndef MSFoundation_CommonDefines_h
#define MSFoundation_CommonDefines_h

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

// END Platform defines
////////


////////
// Default Includes
#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <math.h>

#ifdef WIN32
    #include <windows.h>
#else
    #include <sys/syscall.h>
    #include <unistd.h>
    #include <pthread.h>
#endif
// END Default Includes
////////

////////
// Simple platform abstraction

// Atomics
#if defined(APPLE)
#include <libkern/OSAtomic.h>
typedef volatile int32_t atomic_int32_t;
#define atomic_int32_increment(V) OSAtomicIncrement32(V)
#define atomic_int32_decrement(V) OSAtomicDecrement32(V)
#define atomic_int32_fetch(V) (*V)
#elif defined(WIN32)
typedef volatile int32_t atomic_int32_t;
#define atomic_int32_increment(V) InterlockedIncrementNoFence(V)
#define atomic_int32_decrement(V) InterlockedDecrementNoFence(V)
#define atomic_int32_fetch(V) (*V)
#else
// Use GCC & Clang builtins, in case OSs doesn't provide faster implementation
typedef volatile int32_t atomic_int32_t;
inline int32_t atomic_int32_increment(atomic_int32_t *value)
{
    int32_t ret;
    ret= __sync_fetch_and_add(value, 1);
    ++ret;
    return ret;
}
inline int32_t atomic_int32_decrement(atomic_int32_t *value)
{
    int32_t ret;
    ret= __sync_fetch_and_sub(value, 1);
    --ret;
    return ret;
}
#define atomic_int32_fetch(V) (*V)
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


///// Definition of MSFileHandle
#ifdef WIN32
#define MSFileHandle HANDLE
#define MSInvalidFileHandle INVALID_HANDLE_VALUE
#else
#define MSFileHandle int
#define MSInvalidFileHandle -1
#endif

// END Simple platform abstraction
////////

#endif

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

#include <Rpc.h>
#define PSAPI_VERSION 1
#include <psapi.h>
#include <process.h>

#pragma mark UUID 

void uuid_generate_string(char dst[37])
{
  unsigned char *str;
  UUID uuid;
  UuidCreate(&uuid);
  UuidToString(&uuid, &str);
  strncpy(dst, (const char *)str, 37);
  RpcStringFree(&str);
}


#pragma mark Date & Time

// WIN32 count by 100 nanoseconds steps since 1st january 1601
#define _MSTimeIntervalSince1601 12622780800ULL
#define _UNIXTimeIntervalSince1601 11644473600ULL

static inline MSULong _FileTimeToUNIX100ns(FILETIME ft)
{
  MSULong d= ((((MSULong) ft.dwHighDateTime) << 32) + ft.dwLowDateTime); // in 100ns
  return (MSTimeInterval)d - _UNIXTimeIntervalSince1601 * 10000000 /* s -> 100ns (10^7) */;
}
static inline MSLong _FileTimeToMicro(FILETIME ft)
{
  MSULong d= ((((MSULong) ft.dwHighDateTime) << 32) + ft.dwLowDateTime) / 10; // in us
  return (MSTimeInterval)d - _MSTimeIntervalSince1601 * 1000000 /* s -> us (10^6) */;
}
static inline MSTimeInterval _FileTimeToMSTimeInterval(FILETIME ft)
{
  MSULong d= ((((MSULong) ft.dwHighDateTime) << 32) + ft.dwLowDateTime) / 10000000;
  return (MSTimeInterval)(d) - _MSTimeIntervalSince1601;
}

static inline void _MSTimeIntervalToFileTime(MSTimeInterval t, FILETIME * ft)
{
  MSULong d= (t + _MSTimeIntervalSince1601) * 10000000;
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
  FILETIME fts;
  GetSystemTimeAsFileTime(&fts);
  return _FileTimeToMicro(fts);
}

MSTimeInterval gmt_now(void)
{
  FILETIME fts;
  GetSystemTimeAsFileTime(&fts);
  return _FileTimeToMSTimeInterval(fts);
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
    tOut= _FileTimeToMSTimeInterval(ftl);
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
    t= _FileTimeToMSTimeInterval(fts);
  return t;
}


#pragma mark Processes

static CBuffer *__ms_executable_path = NULL;
static __attribute__((constructor)) void ms_executable_path_init() {
  SES ses; MSUInt nSize; wchar_t buffer[MAX_PATH];
  nSize= GetModuleFileNameW(NULL, buffer, MAX_PATH);
  if (nSize == MAX_PATH) --nSize;
  ses= MSMakeSESWithBytes(buffer, nSize, NSUnicodeStringEncoding);
  __ms_executable_path= CCreateBuffer(nSize);
  CBufferAppendSES(__ms_executable_path, ses, NSUTF8StringEncoding);
}

ms_process_id_t ms_get_current_process_id()
{ return GetCurrentProcessId(); }
ms_thread_id_t ms_get_current_thread_id()
{ return GetCurrentThreadId(); }
const char* ms_get_current_process_path()
{ return (const char*)CBufferCString(__ms_executable_path); }

#pragma mark Shared objects

ms_shared_object_t ms_shared_object_open(const char *path)
{ return LoadLibrary(path); }
int ms_shared_object_close(ms_shared_object_t handle)
{ return FreeLibrary(handle) != 0; }
void *ms_shared_object_symbol(ms_shared_object_t handle, const char *symbol)
{ return GetProcAddress(handle, symbol); }
static int _ms_shared_object_name(HANDLE hProcess, HMODULE hmod, char * utf8Buffer, int utf8BufferSize)
{
  wchar_t modName[MAX_PATH];
  DWORD modNameLen, modNameIt;
  int modNameUTF8Len;
  if ((modNameLen= GetModuleFileNameExW(hProcess, hmod, modName, MAX_PATH))) {
    for(modNameIt= 0; modNameIt < modNameLen; ++modNameIt) {
      if(modName[modNameIt] == '\\')
        modName[modNameIt]= '/';
    }
    modNameUTF8Len= WideCharToMultiByte(CP_UTF8, 0, modName, modNameLen, utf8Buffer, utf8BufferSize - 1, NULL, NULL);
    utf8Buffer[modNameUTF8Len]= '\0';
    return 1;
  }
  *utf8Buffer= '\0';
  return 0;
}
void ms_shared_object_iterate(void (*callback)(const char *name, void *data), void *data)
{
  HMODULE hMods[1024];
  HANDLE hProcess;
  DWORD cbNeeded, i;

  hProcess= GetCurrentProcess();
  if (EnumProcessModules(hProcess, hMods, sizeof(hMods), &cbNeeded)) {
    for (i= 0; i < (cbNeeded / sizeof(HMODULE)); i++ ) {
      char modNameUTF8[MAX_PATH * 2];
      if (_ms_shared_object_name(hProcess, hMods[i], modNameUTF8, sizeof(modNameUTF8))) {
        callback(modNameUTF8, data);}
    }
  }
}

MS_DECLARE_THREAD_LOCAL(ms_shared_object_name_buffer, free)
const char* ms_shared_object_name(void *addr)
{
  HMODULE hMods[1024];
  HANDLE hProcess;
  DWORD cbNeeded, i;
  char * modNameUTF8= tss_get(ms_shared_object_name_buffer);
  if (!modNameUTF8) {
    modNameUTF8= malloc(sizeof(char) * MAX_PATH * 2);
    tss_set(ms_shared_object_name_buffer, modNameUTF8);
  }
  *modNameUTF8= '\0';
  hProcess= GetCurrentProcess();
  if (EnumProcessModules(hProcess, hMods, sizeof(hMods), &cbNeeded)) {
    for (i= 0; i < (cbNeeded / sizeof(HMODULE)); i++ ) {
      MODULEINFO info;
      GetModuleInformation(hProcess, hMods[i], &info, sizeof(info));
      if (info.lpBaseOfDll <= addr && addr <= info.lpBaseOfDll + info.SizeOfImage) {
        _ms_shared_object_name(hProcess, hMods[i], modNameUTF8, MAX_PATH * 2);
        i= (cbNeeded / sizeof(HMODULE));}
    }
  }
  return modNameUTF8;
}

int timespec_get(struct timespec *ts, int base)
{
  if(base == TIME_UTC) {
    FILETIME ft; MSULong unixTimeIn100ns;
    GetSystemTimeAsFileTime(&ft);
    unixTimeIn100ns= _FileTimeToUNIX100ns(ft);
    ts->tv_sec = unixTimeIn100ns / 10000000; /* 100ns -> s (10^7) */
    ts->tv_nsec = (long)(unixTimeIn100ns % 10000000); /* 100ns -> s (10^7) */
    return base;
  }
  return 0;
}

static unsigned __stdcall _thrd_create_start(void * arg)
{
  thrd_start_t f= (thrd_start_t)((void **)arg)[0];
  void *a= ((void **)arg)[1];
  free(arg);
  return (unsigned)f(a);
}
int thrd_create(thrd_t *thr, thrd_start_t func, void *arg)
{
  unsigned thrdaddr;
  void **d = malloc(sizeof(void *) * 2);
  if(!d) return thrd_error;
  d[0]= func;
  d[1]= arg;
  HANDLE handle= (HANDLE)_beginthreadex(NULL, 0, _thrd_create_start, d, 0, &thrdaddr);
  if(handle) {
    thr->id= (DWORD)thrdaddr;
    thr->handle= handle;
    return thrd_success;
  }
  else {
    free(d);
  }
  return thrd_error;
}
int thrd_equal(thrd_t lhs, thrd_t rhs)
{
  return lhs.id == rhs.id; // Comparing thread ids is reliable (handle aren't)
}
thrd_t thrd_current()
{
  thrd_t t= {.id=GetCurrentThreadId(), .handle=NULL};
  return t;
}
int thrd_sleep(const struct timespec* duration, struct timespec* remaining)
{
  Sleep((DWORD)(duration->tv_sec * 1000U + duration->tv_nsec / 1000000L));
  return 0;
}
void thrd_yield()
{
  SwitchToThread();
}
int thrd_detach(thrd_t thr)
{
  CloseHandle(thr.handle);
  return thrd_success;
}
int thrd_join(thrd_t thr, int *res)
{
  int ret= (WaitForSingleObject(thr.handle, INFINITE)) == WAIT_OBJECT_0 ? thrd_success : thrd_error;
  if(ret == thrd_success && res) {
    DWORD code;
    ret= GetExitCodeThread(thr.handle, &code) ? thrd_success : thrd_error;
    if(ret == thrd_success)
      *res= (int)code;
  }
  CloseHandle(thr.handle);
  return ret ? thrd_error : thrd_success;
}
_Noreturn void thrd_exit(int res)
{
  _endthreadex((unsigned)res);
}

int mtx_init(mtx_t* mutex, int type) 
{
  // Recursive WIN32 Mutex
  InitializeCriticalSection(mutex);
  return thrd_success;
}
int mtx_lock(mtx_t* mutex) 
{
  EnterCriticalSection(mutex);
  return thrd_success;
}
int mtx_trylock(mtx_t* mutex) 
{
  return TryEnterCriticalSection(mutex) ? thrd_success : thrd_busy;
}
int mtx_unlock(mtx_t* mutex) 
{
  LeaveCriticalSection(mutex);
  return thrd_success;
}
void mtx_destroy(mtx_t* mutex) 
{
  DeleteCriticalSection(mutex);
}

void call_once(once_flag* flag, void (*func)(void)) {
  if (!flag->ran) {
    HANDLE event, previous_event;
    if (!(event= CreateEvent(NULL, 1, 0, NULL)))
      abort();
    
    if (!(previous_event= InterlockedCompareExchangePointer(&flag->event, event, NULL))) {
      func();
      flag->ran = 1;
      SetEvent(event);
    }
    else {
      CloseHandle(event);
      WaitForSingleObject(previous_event, INFINITE);
    }
  }
}

typedef VOID (WINAPI *msvista_InitializeConditionVariable_t)(PCONDITION_VARIABLE ConditionVariable);
static msvista_InitializeConditionVariable_t msvista_InitializeConditionVariable;

typedef VOID (WINAPI *msvista_WakeConditionVariable_t)(PCONDITION_VARIABLE ConditionVariable);
static msvista_WakeConditionVariable_t msvista_WakeConditionVariable;

typedef VOID (WINAPI *msvista_WakeAllConditionVariable_t)(PCONDITION_VARIABLE ConditionVariable);
static msvista_WakeAllConditionVariable_t msvista_WakeAllConditionVariable;

typedef BOOL (WINAPI *msvista_SleepConditionVariableCS_t)(PCONDITION_VARIABLE ConditionVariable, PCRITICAL_SECTION CriticalSection, DWORD dwMilliseconds);
static msvista_SleepConditionVariableCS_t msvista_SleepConditionVariableCS;

#define CND_HANDLE_SIGNAL 0
#define CND_HANDLE_BROADCAST 1
static inline int _cnd_is_native() {
  return msvista_InitializeConditionVariable != NULL;
}
__attribute__((constructor))
static void _cnd_init()
{
  HMODULE k32= GetModuleHandleA("kernel32.dll");
  if(k32) {
    msvista_InitializeConditionVariable= (msvista_InitializeConditionVariable_t)GetProcAddress(k32, "InitializeConditionVariable");
    msvista_WakeConditionVariable= (msvista_WakeConditionVariable_t)GetProcAddress(k32, "WakeConditionVariable");
    msvista_WakeAllConditionVariable= (msvista_WakeAllConditionVariable_t)GetProcAddress(k32, "WakeAllConditionVariable");
    msvista_SleepConditionVariableCS= (msvista_SleepConditionVariableCS_t)GetProcAddress(k32, "SleepConditionVariableCS");
  }
}
int cnd_init(cnd_t* cond) 
{
  if(_cnd_is_native()) {
    msvista_InitializeConditionVariable(&cond->native);
    return thrd_success;
  }
  else {
    int ret= thrd_error;
    cond->fallback.waiters_count= 0;
    if((cond->fallback.handles[CND_HANDLE_SIGNAL]= CreateEvent(NULL, 0, 0, NULL))) {
      if((cond->fallback.handles[CND_HANDLE_BROADCAST]= CreateEvent(NULL, 1, 0, NULL)))
        ret= thrd_success;
      else
        CloseHandle(cond->fallback.handles[CND_HANDLE_SIGNAL]);
    }
    return ret;
  }
}
int cnd_signal(cnd_t *cond) 
{
  if(_cnd_is_native()) {
    msvista_WakeConditionVariable(&cond->native);
  }
  else {
    if (cond->fallback.waiters_count > 0)
      return SetEvent(cond->fallback.handles[CND_HANDLE_SIGNAL]) ? thrd_success : thrd_error;
  }
  return thrd_success;
}
int cnd_broadcast(cnd_t *cond) 
{
  if(_cnd_is_native()) {
    msvista_WakeAllConditionVariable(&cond->native);
  }
  else {
    if (cond->fallback.waiters_count > 0)
      return SetEvent(cond->fallback.handles[CND_HANDLE_BROADCAST]) ? thrd_success : thrd_error;
  }
  return thrd_success;
}
static inline int _cnd_timedwait(cnd_t* cond, mtx_t* mutex, DWORD dwMilliseconds)
{
  if(_cnd_is_native()) {
    return msvista_SleepConditionVariableCS(&cond->native, mutex, dwMilliseconds) ? thrd_success : thrd_error;
  }
  else {
    DWORD ret;
    __sync_add_and_fetch(&cond->fallback.waiters_count, 1);
    LeaveCriticalSection(mutex);
    ret= WaitForMultipleObjects(2, cond->fallback.handles, FALSE, INFINITE);
    if(__sync_sub_and_fetch(&cond->fallback.waiters_count, 1) == 0 && ret == WAIT_OBJECT_0 + 1) {
      ResetEvent(cond->fallback.handles[CND_HANDLE_BROADCAST]);
    }
    EnterCriticalSection(mutex);
    if(ret == WAIT_OBJECT_0 || ret == WAIT_OBJECT_0 + 1)
      return thrd_success;
    if(ret == WAIT_TIMEOUT)
      return thrd_timedout;
    return thrd_error;
  }
}
int cnd_wait(cnd_t* cond, mtx_t* mutex) 
{
  return _cnd_timedwait(cond, mutex, INFINITE);
}
int cnd_timedwait(cnd_t* restrict cond, mtx_t* restrict mutex, const struct timespec* restrict duration)
{
  return _cnd_timedwait(cond, mutex, (DWORD)(duration->tv_sec * 1000U + duration->tv_nsec / 1000000L));
}
void cnd_destroy(cnd_t* cond) 
{
  if(!_cnd_is_native()) {
    CloseHandle(cond->fallback.handles[CND_HANDLE_SIGNAL]);
    CloseHandle(cond->fallback.handles[CND_HANDLE_BROADCAST]);
  }
}

struct _tss_cleanup_s {
  void (*routine)(void *);
  void *arg;
  struct _tss_cleanup_s *next;
};
static struct _tss_cleanup_s *_tss_cleanup_list;
static once_flag _tss_cleanup_list_once = ONCE_FLAG_INIT;
static mtx_t _tss_cleanup_list_mutex;
static void _tss_cleanup_add(void (*routine)(void *), void *arg);
static void _tss_cleanup_remove(void (*routine)(void *), void *arg);
static void _tss_cleanup_cb(void *arg) {
  tss_t* tss_key= (tss_t *)arg;
  tss_key->dtor(tss_get(*tss_key));
}
int tss_create(tss_t* tss_key, tss_dtor_t destructor)
{
  DWORD idx= TlsAlloc();
  if(idx != TLS_OUT_OF_INDEXES) {
    tss_key->idx= idx;
    tss_key->dtor= destructor;
    if(destructor)
      _tss_cleanup_add(_tss_cleanup_cb, tss_key);
    return thrd_success;
  }
  return thrd_error;
}
void *tss_get(tss_t tss_key)
{
  return TlsGetValue(tss_key.idx);
}
int tss_set(tss_t tss_key, void *val)
{
  return TlsSetValue(tss_key.idx, val) ? thrd_success : thrd_error;
}
void tss_delete(tss_t tss_key)
{
  TlsFree(tss_key.idx);
  if(tss_key.dtor)
    _tss_cleanup_remove(_tss_cleanup_cb, (void*)tss_key.idx);
}
static void _tss_cleanup_init()
{
  mtx_init(&_tss_cleanup_list_mutex, mtx_plain);
}
static void _tss_cleanup_add(void (*routine)(void *), void *arg)
{
  struct _tss_cleanup_s *n;
  call_once(&_tss_cleanup_list_once, _tss_cleanup_init);
  mtx_lock(&_tss_cleanup_list_mutex);
  n = malloc(sizeof(struct _tss_cleanup_s));
  n->routine= routine;
  n->arg= arg;
  n->next= NULL;
  if(_tss_cleanup_list)
    _tss_cleanup_list->next= n;
  _tss_cleanup_list= n;
  mtx_unlock(&_tss_cleanup_list_mutex);
}

static void _tss_cleanup_remove(void (*routine)(void *), void *arg)
{
  struct _tss_cleanup_s *n, *p= NULL;
  call_once(&_tss_cleanup_list_once, _tss_cleanup_init);
  mtx_lock(&_tss_cleanup_list_mutex);
  n= _tss_cleanup_list;
  while(n) {
    if(n->routine == routine && n->arg == arg) {
      if(p)
        p->next= n->next;
      if(_tss_cleanup_list == n)
        _tss_cleanup_list= n->next;
      free(n);
    }
    p= n;
    n= n->next;
  }
  mtx_unlock(&_tss_cleanup_list_mutex);
}

static void _tss_cleanup_fire()
{
  struct _tss_cleanup_s *n;
  call_once(&_tss_cleanup_list_once, _tss_cleanup_init);
  mtx_lock(&_tss_cleanup_list_mutex);
  n= _tss_cleanup_list;
  while(n) {
    n->routine(n->arg);
    n= n->next;
  }
  mtx_unlock(&_tss_cleanup_list_mutex);
}

BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved)
{ 
  if(fdwReason == DLL_THREAD_DETACH)
    _tss_cleanup_fire();
  return TRUE; 
  MSUnused(hinstDLL);
  MSUnused(lpvReserved);
}

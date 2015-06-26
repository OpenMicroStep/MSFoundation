#include <process.h>

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
  __builtin_unreachable();
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
  tss_t idx;
  tss_dtor_t dtor;
  struct _tss_cleanup_s *next;
};
static struct _tss_cleanup_s *_tss_cleanup_list;
static once_flag _tss_cleanup_list_once = ONCE_FLAG_INIT;
static mtx_t _tss_cleanup_list_mutex;
static void _tss_cleanup_add(tss_t idx, tss_dtor_t dtor);
static void _tss_cleanup_remove(tss_t idx);
static void _tss_cleanup_cb(tss_t idx, tss_dtor_t dtor) {
  dtor(tss_get(idx));
}
int tss_create(tss_t* tss_key, tss_dtor_t destructor)
{
  DWORD idx= TlsAlloc();
  if(idx != TLS_OUT_OF_INDEXES) {
    *tss_key= idx;
    if(destructor)
      _tss_cleanup_add(idx, destructor);
    return thrd_success;
  }
  return thrd_error;
}
void *tss_get(tss_t tss_key)
{
  return TlsGetValue(tss_key);
}
int tss_set(tss_t tss_key, void *val)
{
  return TlsSetValue(tss_key, val) ? thrd_success : thrd_error;
}
void tss_delete(tss_t tss_key)
{
  TlsFree(tss_key);
  _tss_cleanup_remove(tss_key);
}
static void _tss_cleanup_init()
{
  mtx_init(&_tss_cleanup_list_mutex, mtx_plain);
}
static void _tss_cleanup_add(tss_t idx, tss_dtor_t dtor)
{
  struct _tss_cleanup_s *n;
  call_once(&_tss_cleanup_list_once, _tss_cleanup_init);
  mtx_lock(&_tss_cleanup_list_mutex);
  n = malloc(sizeof(struct _tss_cleanup_s));
  n->idx= idx;
  n->dtor= dtor;
  n->next= NULL;
  if(_tss_cleanup_list)
    _tss_cleanup_list->next= n;
  _tss_cleanup_list= n;
  mtx_unlock(&_tss_cleanup_list_mutex);
}

static void _tss_cleanup_remove(tss_t idx)
{
  struct _tss_cleanup_s *n, *p= NULL;
  call_once(&_tss_cleanup_list_once, _tss_cleanup_init);
  mtx_lock(&_tss_cleanup_list_mutex);
  n= _tss_cleanup_list;
  while(n) {
    if(n->idx == idx) {
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
    _tss_cleanup_cb(n->idx, n->dtor);
    n= n->next;
  }
  mtx_unlock(&_tss_cleanup_list_mutex);
}

BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved)
{ 
  if(fdwReason == DLL_THREAD_DETACH)
    _tss_cleanup_fire();
  return TRUE; 
  (void)(hinstDLL);
  (void)(lpvReserved);
}

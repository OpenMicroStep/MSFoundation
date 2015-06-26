#include <sched.h>
#include <pthread.h>
#include <errno.h>

static void * _thrd_create_start(void * arg)
{
  thrd_start_t f= (thrd_start_t)((void **)arg)[0];
  void *a= ((void **)arg)[1];
  free(arg);
  return (void*)(intptr_t)f(a);
}
int thrd_create(thrd_t *thr, thrd_start_t func, void *arg)
{
  void **d; int ret;
  d= malloc(sizeof(void *) * 2);
  if(!d) return thrd_nomem;
  d[0]= func;
  d[1]= arg;
  if((ret= pthread_create(thr, NULL, _thrd_create_start, d)) != 0) {
    free(d);
    return thrd_error;
  }
  return thrd_success;
}

int thrd_equal(thrd_t lhs, thrd_t rhs)
{
  return pthread_equal(lhs, rhs); // Comparing thread ids
}

thrd_t thrd_current()
{
  return pthread_self();
}

int thrd_sleep(const struct timespec* duration, struct timespec* remaining)
{
  return nanosleep(duration, remaining);
}

int thrd_detach(thrd_t thr)
{
  return pthread_detach(thr) == 0 ? thrd_success : thrd_error;
}

int thrd_join(thrd_t thr, int *res)
{
  void *pthread_res;
  int ret= pthread_join(thr, &pthread_res);
  if (ret == 0 && res) *res = (int)(intptr_t)pthread_res;
  return ret == 0 ? thrd_success : thrd_error;
}

_Noreturn void thrd_exit(int res)
{
  pthread_exit((void*)(intptr_t)res);
}

int mtx_init(mtx_t* mutex, int type) 
{
  int ret;
  pthread_mutexattr_t attr;
  pthread_mutexattr_init(&attr);
  if ((type & mtx_recursive))
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
  ret= pthread_mutex_init(mutex, &attr) ? thrd_error : thrd_success;
  pthread_mutexattr_destroy(&attr);
  return ret;
}
int mtx_lock(mtx_t* mutex) 
{
  return pthread_mutex_lock(mutex) ? thrd_error : thrd_success;
}
int mtx_trylock(mtx_t* mutex) 
{
  return pthread_mutex_trylock(mutex) ? thrd_success : thrd_busy;
}
int mtx_unlock(mtx_t* mutex) 
{
  int ret= pthread_mutex_unlock(mutex);
  return ret == 0 ? thrd_success : (ret == EBUSY ? thrd_busy : thrd_error);
}
void mtx_destroy(mtx_t* mutex) 
{
  pthread_mutex_destroy(mutex);
}

void call_once(once_flag* flag, void (*func)(void)) 
{
  pthread_once(flag, func);
}

int cnd_init(cnd_t* cond) 
{
  int ret= pthread_cond_init(cond, NULL);
  return ret == 0 ? thrd_success : (ret == ENOMEM ? thrd_nomem : thrd_error);
}
int cnd_signal(cnd_t *cond) 
{
  return pthread_cond_signal(cond) == 0 ? thrd_success : thrd_error;
}
int cnd_broadcast(cnd_t *cond) 
{
  return pthread_cond_broadcast(cond) == 0 ? thrd_success : thrd_error;
}
int cnd_wait(cnd_t* cond, mtx_t* mutex) 
{
  return pthread_cond_wait(cond, mutex) == 0 ? thrd_success : thrd_error;
}
int cnd_timedwait(cnd_t* restrict cond, mtx_t* restrict mutex, const struct timespec* restrict duration)
{
  int ret= pthread_cond_timedwait(cond, mutex, duration);
  return ret == 0 ? thrd_success : (ret == ETIMEDOUT ? thrd_timedout : thrd_error);
}
void cnd_destroy(cnd_t* cond) 
{
  pthread_cond_destroy(cond);
}

int tss_create(tss_t* tss_key, tss_dtor_t destructor)
{
  int ret= pthread_key_create(tss_key, destructor);
  return ret == 0 ? thrd_success : (ret == ENOMEM ? thrd_nomem : thrd_error);
}
void *tss_get(tss_t tss_key)
{
  return pthread_getspecific(tss_key);
}
int tss_set(tss_t tss_key, void *val)
{
  int ret= pthread_setspecific(tss_key, val);
  return ret == 0 ? thrd_success : (ret == ENOMEM ? thrd_nomem : thrd_error);
}
void tss_delete(tss_t tss_key)
{
  pthread_key_delete(tss_key);
}

void thrd_yield()
{
  sched_yield();
}

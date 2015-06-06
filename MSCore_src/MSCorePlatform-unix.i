/* MSCorePlatform-unix.c
 
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

#include <sys/time.h>
#include <uuid/uuid.h>
#include <dlfcn.h>
#include <errno.h>

void uuid_generate_string(char dst[37])
{
  uuid_t uuid;
  uuid_generate_random ( uuid );
  uuid_unparse ( uuid, dst );
}

MSLong gmt_micro(void)
{
  MSLong t;
  struct timeval tv;
  gettimeofday(&tv,NULL);
  t= ((MSTimeInterval)tv.tv_sec - CDateSecondsFrom19700101To20010101)*1000000LL + (MSTimeInterval)tv.tv_usec;
  return t;
}

MSTimeInterval gmt_now(void)
{
  MSTimeInterval t;
  time_t timet= time(NULL);
  t= (MSTimeInterval)timet - CDateSecondsFrom19700101To20010101;
  return t;
}

MSTimeInterval gmt_to_local(MSTimeInterval t)
{
  struct tm tm;
  time_t timet= t + CDateSecondsFrom19700101To20010101;
  (void)localtime_r(&timet, &tm);
  return (MSTimeInterval)timet - CDateSecondsFrom19700101To20010101 + (MSTimeInterval)(tm.tm_gmtoff);
}

MSTimeInterval gmt_from_local(MSTimeInterval t)
{
  struct tm tm;
  time_t timet= (time_t)(t + CDateSecondsFrom19700101To20010101);
  (void)mktime(gmtime_r(&timet, &tm));
  return t - (MSTimeInterval)tm.tm_gmtoff;
}

ms_shared_object_t ms_shared_object_open(const char *path)
{ return dlopen(path, RTLD_NOW); }
int ms_shared_object_close(ms_shared_object_t handle)
{ return dlclose(handle) == 0; }
void *ms_shared_object_symbol(ms_shared_object_t handle, const char *symbol)
{ return dlsym(handle, symbol); }
const char* ms_shared_object_name(void *addr)
{ 
  Dl_info info;
  if (dladdr(addr, &info))
    return info.dli_fname;
  return NULL;
}

ms_process_id_t ms_get_current_process_id()
{ return getpid(); }
ms_thread_id_t ms_get_current_thread_id()
{ return syscall(SYS_getpid); }

// C11 STDC polyfill
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

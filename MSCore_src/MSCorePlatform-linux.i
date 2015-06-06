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

#include <link.h>

#if __has_include(<sys/auxv.h>) // recent linux glic have auxiliary channel api
#include <sys/auxv.h>
const char* ms_get_current_process_path()
{
  return (const char*)getauxval(AT_EXECFN);
}
#else
static char __ms_get_current_process_path[PATH_MAX] = {0};
static __attribute__((constructor)) void ms_get_current_process_path_init()
{
  ssize_t sz;
  if ((sz= readlink ("/proc/self/exe", __ms_get_current_process_path, sizeof(__ms_get_current_process_path) - 1)) > 0) {
    __ms_get_current_process_path[sz] = '\0';
  }
}
const char* ms_get_current_process_path()
{
  return __ms_get_current_process_path;
}
#endif

struct ms_shared_object_iterate_data 
{
  void (*callback)(const char *name, void *data);
  void *data;
};

static int ms_shared_object_iterate_cb(struct dl_phdr_info *info, size_t size, void *data)
{
  struct ms_shared_object_iterate_data d = *(struct ms_shared_object_iterate_data*)data;
  d.callback(info->dlpi_name, d.data);
  return 0;
}
 
void ms_shared_object_iterate(void (*callback)(const char *name, void *data), void *data)
{
  struct ms_shared_object_iterate_data d;
  d.callback = callback;
  d.data = data;
  dl_iterate_phdr(ms_shared_object_iterate_cb, &d);
}

int timespec_get(struct timespec *ts, int base)
{
  return (base == TIME_UTC && clock_gettime(CLOCK_REALTIME, ts) == 0) ? base : 0;
}

void thrd_yield()
{
  pthread_yield();
}

#include <dlfcn.h>

ms_shared_object_t ms_shared_object_open(const char *path)                   { return dlopen(path, RTLD_NOW); }
int ms_shared_object_close(ms_shared_object_t handle)                        { return dlclose(handle) == 0;   }
void *ms_shared_object_symbol(ms_shared_object_t handle, const char *symbol) { return dlsym(handle, symbol);  }

const char* ms_shared_object_name(void *addr)
{ 
  Dl_info info;
  if (dladdr(addr, &info))
    return info.dli_fname;
  return NULL;
}

ms_process_id_t ms_get_current_process_id() { return getpid(); }
ms_thread_id_t  ms_get_current_thread_id()  { return syscall(SYS_getpid); }


#if defined(LINUX)

#include <link.h>
#if __has_include(<sys/auxv.h>)
  // recent linux glic have auxiliary channel api
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

#elif defined(APPLE)

#include <libproc.h>
#include <mach-o/dyld.h>

static const char* __ms_executable_path_ptr = NULL;
static char __ms_executable_path[PROC_PIDPATHINFO_MAXSIZE];

static __attribute__((constructor)) void init_ms_executable_path()
{
  int ret; pid_t pid;

  pid= getpid();
  ret= proc_pidpath(pid, __ms_executable_path, sizeof(__ms_executable_path));
  if (ret > 0)
    __ms_executable_path_ptr = __ms_executable_path;
}

const char* ms_get_current_process_path()
{
  return __ms_executable_path_ptr;
}

void ms_shared_object_iterate(void (*callback)(const char *name, void *data), void *data)
{
  uint32_t i, count;
  for (i=0, count= _dyld_image_count(); i < count; ++i) {
    callback(_dyld_get_image_name(i), data);
  }
}

#else
#error MSStdShared: unsupported unix platform
#endif
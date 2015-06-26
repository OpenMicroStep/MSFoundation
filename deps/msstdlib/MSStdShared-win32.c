#include <Psapi.h>

static char __ms_executable_path[MAX_PATH * 2];

static __attribute__((constructor)) void ms_executable_path_init() {
  uint32_t nSize; wchar_t buffer[MAX_PATH]; int len;
  nSize= GetModuleFileNameW(NULL, buffer, MAX_PATH);
  if (nSize == MAX_PATH) --nSize;
  len= WideCharToMultiByte(CP_UTF8, 0, buffer, nSize, __ms_executable_path, sizeof(__ms_executable_path) - 1, NULL, NULL);
  __ms_executable_path[len]= '\0';
}

ms_process_id_t ms_get_current_process_id()
{ return GetCurrentProcessId(); }
ms_thread_id_t ms_get_current_thread_id()
{ return GetCurrentThreadId(); }
const char* ms_get_current_process_path()
{ return __ms_executable_path; }

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

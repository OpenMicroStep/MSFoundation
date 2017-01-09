#include <Windows.h>
#include <Dbghelp.h>

void ms_backtrace_iterate(void (*callback)(const char *symbol, void*addr, void *data), void *data)
{
  ULONG framesToCapture; USHORT captured, i; HANDLE process; int bIsWindowsXPorLater;
  OSVERSIONINFO osvi;
  ZeroMemory(&osvi, sizeof(OSVERSIONINFO));
  osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
  GetVersionEx(&osvi);
  framesToCapture= osvi.dwMajorVersion > 5 ? 1024 : 62; // Windows XP and bellow can only capture up to 62 frames
  void *addr[framesToCapture];
  captured= CaptureStackBackTrace(1, framesToCapture, addr, NULL);
  if (captured > 0) {
    SymSetOptions(SYMOPT_UNDNAME | SYMOPT_DEFERRED_LOADS);
    process = GetCurrentProcess();
    SymInitialize(process, NULL, TRUE);
    for (i= 0; i < captured; ++i) {
      char buffer[sizeof(SYMBOL_INFO) + MAX_SYM_NAME * sizeof(char)];
      PSYMBOL_INFO pSymbol = (PSYMBOL_INFO)buffer;
      pSymbol->SizeOfStruct = sizeof(SYMBOL_INFO);
      pSymbol->MaxNameLen = MAX_SYM_NAME;
      if (SymFromAddr(process, (DWORD64)addr[i], 0, pSymbol)) {
        callback((const char *)pSymbol->Name, addr[i], data);
      }
      else {
        callback("unknown", addr[i], data);
      }
    }
  }
}
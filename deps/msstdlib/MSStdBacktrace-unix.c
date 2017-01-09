#include <execinfo.h>

void ms_backtrace_iterate(void (*callback)(const char *symbol, void*addr, void *data), void *data)
{
  int size= 1024, i, ret; char **symbols;
  void *addr[size];
  ret= backtrace(addr, size);
  symbols= backtrace_symbols(addr, ret);
  if (symbols) {
    for (i= 0; i < ret; ++i) {
      callback(symbols[i], addr[i], data);
    }
    free(symbols);
  }
}
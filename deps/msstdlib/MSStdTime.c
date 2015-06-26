#include "MSStd_Private.h"

#if defined(UNIX)
#include "MSStdTime-unix.c"
#elif defined(WIN32)
#include "MSStdTime-win32.c"
#else
#error MSStdTime: unsupported platform
#endif
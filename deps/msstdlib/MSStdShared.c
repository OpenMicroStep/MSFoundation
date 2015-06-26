#include "MSStd_Private.h"

#if defined(UNIX)
#include "MSStdShared-unix.c"
#elif defined(WIN32)
#include "MSStdShared-win32.c"
#else
#error MSStdShared: unsupported platform
#endif
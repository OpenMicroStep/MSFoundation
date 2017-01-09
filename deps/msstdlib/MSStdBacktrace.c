#include "MSStd_Private.h"

#if defined(UNIX)
#include "MSStdBacktrace-unix.c"
#elif defined(WO451)
// MSStdBacktrace is not supported on WO451
#elif defined(WIN32)
#include "MSStdBacktrace-win32.c"
#else
#error MSStdBacktrace: unsupported platform
#endif

#include "MSCore_Private.h"

#if defined(APPLE)
#include "MSCorePlatform-apple.i"
#endif

#if defined(UNIX)
#include "MSCorePlatform-unix.i"
#endif

#if defined(WIN32)
#include "MSCorePlatform-win32.i"
#endif

#if defined(WO451)
#include "MSCorePlatform-wo451.i"
#endif

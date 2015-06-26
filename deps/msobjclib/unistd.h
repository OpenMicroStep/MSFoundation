/* See http://llvm.org/bugs/show_bug.cgi?id=4746: __block storage qualifier conflicts with variable name in glibc headers */
#ifdef __block
#	undef __block
#	include_next "unistd.h"
#	define __block __attribute__((__blocks__(byref)))
#else
#	include_next "unistd.h"
#endif

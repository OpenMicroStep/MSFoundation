/* MSCoreIncludes.h
 
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
 
 WARNING : this header file IS PRIVATE, don't use it directly
 AND NEVER INCLUDE IT IN MSFoundation framework, it is maint to
 be exclusively used in MSCore standalone mode
 
 */

#ifndef MSCOREINCLUDES_H
#define MSCOREINCLUDES_H ////////////////////////////////// MSCOREINCLUDES_H (1)

#ifndef LINUX
#ifdef __LINUX__
#define LINUX
#endif
#endif

#ifndef WIN32
#ifdef __WIN32__
#define WIN32
#endif
#endif

#ifdef WIN32 //::::::::::::::::::::::::::::::::::::::::::::::::::::::: WIN32 (2)

#include <windows.h>
#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <time.h>
#include <winsock.h>
#include <process.h>
#include <fcntl.h>
#include <math.h>

#ifdef __cplusplus
#define MSExport  extern "C" __declspec(dllexport)
#define MSImport  extern "C" __declspec(dllimport)
#define MSPrivate extern
#else
#define MSExport  __declspec(dllexport) extern
#define MSImport  __declspec(dllimport) extern
#define MSPrivate extern
#endif // __cplusplus

#else //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: !WIN32 (2)

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <limits.h>
#include <string.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/syscall.h>
#include <sys/ioctl.h>
#include <sys/sysctl.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdarg.h>
#include <math.h>
#include <pthread.h>

#ifdef __cplusplus
#define MSExport  extern "C"
#define MSImport  extern "C"
#define MSPrivate extern "C"
#else // !__cplusplus
#define MSExport  extern
#define MSImport  extern
#ifdef __APPLE__
#define MSPrivate extern
#else
#define MSPrivate __private_extern__
#endif
#endif // __cplusplus

#endif //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: WIN32 (2)

#if !defined(MSCORE_STANDALONE) && !defined(_OBJC_OBJC_H_)
#define MSCORE_FORFOUNDATION 1
#endif

#endif //////////////////////////////////////////////////// MSCOREINCLUDES_H (1)

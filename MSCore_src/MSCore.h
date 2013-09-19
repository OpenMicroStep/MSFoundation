/*
 
 MSCore.h
 
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

#ifndef MSCORE_PRIVATE_H
#define MSCORE_PRIVATE_H

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

#ifdef WIN32

#include <windows.h>
#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <winsock.h>
#include <process.h>
#include <fcntl.h>

#else // !WIN32

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
#include <net/if.h>
#include <net/if_dl.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdarg.h>
#include <math.h>
#include <pthread.h>

#endif // WIN32

#ifndef MSCORE_STANDALONE
// On ne peut pas inclure le Foundation quand on compili un .c
// Donc pour compiler le MSCore lui-même pour une utilisation avec le Foundation
// on a besoin de redéfinir Class, id, etc.
// Lorsque l'on compile un .m avec le Foundation, ce dernier doit être inclus
// avant MSCore.h (comme dans MSFoundation.h)
#ifndef _OBJC_OBJC_H_
#define MSCORE_FORFOUNDATION 1
#endif
#endif

#include "MSCoreTypes.h"
#include "MSCoreSystem.h"
#include "MSCoreTools.h"
#include "MSCObject.h"

//#include "MSCoreNetwork.h"
//#include "MSCoreEntropy.h"
//#include "MSCoreCompress.h"
//#include "MSCoreTimeInterval.h"
//#include "MSCoreTLS.h"


#include "MSCoreUnichar.h"
#include "MSCoreSES.h"
#include "MSCUnicodeBuffer.h"

#include "MSCArray.h"
//#include "MSCBuffer.h"
//#include "MSCColor.h"
//#include "MSCCouple.h"
//#include "MSCDate.h"
/* included MAPM library rewritten to match our need */
//#include "../MAPM.subproj/m_apm.h" // MSCDecimal
//#include "MSCDictionary.h"
//#include "MSCMutex.h"
//#include "MSCNaturalArray.h"

#endif // MSCORE_H

/* MSCore_Public.h
 
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

// The same as MSCore.h but for local include

#ifndef MSCORE_PUBLIC_H
#define MSCORE_PUBLIC_H

#include "MSCorePlatform.h"
#include "MSCoreTypes.h"
#include "MSCoreSystem.h"
#include "MSCoreTools.h"
#include "MSCObject.h"
#include "MSCGrow.h"

//#include "MSCoreNetwork.h"
//#include "MSCoreEntropy.h"
//#include "MSCoreCompress.h"
//#include "MSCoreTimeInterval.h"
//#include "MSCoreTLS.h"

// ..ToString functions use MSCString
// so we include it first
#include "MSCoreUnichar.h"
#include "MSCoreSES.h"
#include "MSCString.h"

#include "MSCArray.h"
#include "MSCBuffer.h"
#include "MSCColor.h"
#include "MSCCouple.h"
#include "MSCDate.h"
#include "MSCDecimal.h"
#include "m_apm.h"
#include "MSCDictionary.h"
#include "MSTE.h"
//#include "MSCMutex.h"
//#include "MSCNaturalArray.h"

#include "MSCMessage.h"

#endif // MSCORE_PUBLIC_H

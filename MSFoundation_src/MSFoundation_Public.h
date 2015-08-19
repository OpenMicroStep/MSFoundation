/*   MSFoundation_Public.h
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
 
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
 
 */

// The same as MSFundation.h but for local include

#ifndef MSFOUNDATION_PUBLIC_H
#define MSFOUNDATION_PUBLIC_H

#ifdef MSFOUNDATION_FORCOCOA
#import <Foundation/Foundation.h>
#endif

#import "MSCore_Public.h"

#ifndef MSFOUNDATION_FORCOCOA
#import "FoundationCompatibility_Public.h"
#endif

#import "MSFoundationDefines.h"
#import "MSFoundationPlatform.h"
#import "MSFinishLoading.h"
#import "MSCoderAdditions.h"
#import "MSExceptionAdditions.h"
#import "MSLanguage.h"
#import "MSObjectAdditions.h"

#import "MSBool.h"
#import "MSASCIIString.h"
#import "MSMutex.h"
#import "MSCNaturalArray.h"
#import "MSNaturalArray.h"
#import "MSNaturalArrayEnumerator.h"
#import "MSFileManipulation.h"

#import "MSRow.h"

#import "MSArray.h"
#import "MSBuffer.h"
#import "MSColor.h"
#import "MSCouple.h"
#import "MSDate.h"
#import "MSDecimal.h"
#import "MSDictionary.h"
#import "MSString.h"

#import "MSTDecoder.h"
#import "MSTEncoder.h"

#import "MSStringParsing.h"
#import "MSMSTEDecoder.h"

#define FMT(ARGS...) [MSString stringWithFormat: ARGS]

#endif // MSFOUNDATION_PUBLIC_H

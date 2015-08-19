/*   MSFoundation.h
 
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

#ifndef MSFOUNDATION_H
#define MSFOUNDATION_H

#ifdef MSFOUNDATION_FORCOCOA
#import <Foundation/Foundation.h>
#endif

#import <MSFoundation/MSStd.h>
#import <MSFoundation/MSCoreTypes.h>
#import <MSFoundation/MSCoreSystem.h>
#import <MSFoundation/MSCoreTools.h>
#import <MSFoundation/MSCObject.h>
#import <MSFoundation/MSCGrow.h>

#import <MSFoundation/MSCoreUnichar.h>
#import <MSFoundation/MSCoreSES.h>
#import <MSFoundation/MSCString.h>

#import <MSFoundation/MSCArray.h>
#import <MSFoundation/MSCBuffer.h>
#import <MSFoundation/MSCColor.h>
#import <MSFoundation/MSCCouple.h>
#import <MSFoundation/MSCDate.h>
#import <MSFoundation/MSCDecimal.h>
#import <MSFoundation/m_apm.h>
#import <MSFoundation/MSCDictionary.h>

#import <MSFoundation/MSCMessage.h>

#ifndef MSFOUNDATION_FORCOCOA
#import <MSFoundation/FoundationCompatibility.h>
#endif

#import <MSFoundation/MSFoundationDefines.h>
#import <MSFoundation/MSFoundationPlatform.h>
#import <MSFoundation/MSFinishLoading.h>
#import <MSFoundation/MSCoderAdditions.h>
#import <MSFoundation/MSExceptionAdditions.h>
#import <MSFoundation/MSLanguage.h>
#import <MSFoundation/MSObjectAdditions.h>

#import <MSFoundation/MSBool.h>
#import <MSFoundation/MSASCIIString.h>
#import <MSFoundation/MSMutex.h>
#import <MSFoundation/MSCNaturalArray.h>
#import <MSFoundation/MSNaturalArray.h>
#import <MSFoundation/MSNaturalArrayEnumerator.h>
#import <MSFoundation/MSFileManipulation.h>

#import <MSFoundation/MSRow.h>

#import <MSFoundation/MSArray.h>
#import <MSFoundation/MSBuffer.h>
#import <MSFoundation/MSColor.h>
#import <MSFoundation/MSCouple.h>
#import <MSFoundation/MSDate.h>
#import <MSFoundation/MSDecimal.h>
#import <MSFoundation/MSDictionary.h>
#import <MSFoundation/MSString.h>

#import <MSFoundation/MSTDecoder.h>
#import <MSFoundation/MSTEncoder.h>

#import <MSFoundation/MSStringParsing.h>
#import <MSFoundation/MSMSTEDecoder.h>

#define FMT(ARGS...)  [MSString stringWithFormat: ARGS]

#endif

/* MSTE.h
 
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
 
 WARNING : outside the MSFoundation framework or the MSCore library,
 this header file cannot be included alone, please direclty include
 MSCore.h or MSFoundation.h
 */

// Value means not a reference token

#define MSTE_NULL_VALUE           0
#define MSTE_TRUE_VALUE           1
#define MSTE_FALSE_VALUE          2
#define MSTE_NUMBER         3
#define MSTE_STRING         4
#define MSTE_DATE           5
#define MSTE_COLOR          6
#define MSTE_DICTIONARY     7
#define MSTE_REFERENCE      8
#define MSTE_CHAR_VALUE           9
#define MSTE_UCHAR_VALUE         10
#define MSTE_SHORT_VALUE         11
#define MSTE_USHORT_VALUE        12
#define MSTE_INT_VALUE           13
#define MSTE_UINT_VALUE          14
#define MSTE_LONG_VALUE          15
#define MSTE_ULONG_VALUE         16
#define MSTE_FLOAT_VALUE         17
#define MSTE_DOUBLE_VALUE        18
#define MSTE_ARRAY         19
#define MSTE_NATURAL_ARRAY 20
#define MSTE_COUPLE        21
#define MSTE_BASE64_DATA   22
#define MSTE_DISTANT_PAST_VALUE   23
#define MSTE_DISTANT_FUTURE_VALUE 24
#define MSTE_EMPTY_STRING_VALUE   25

#define MSTE_USER_CLASS    50

// MSTE constants as objects. Can be compared with ==
// Warning: Follow the retain/release rule.
MSExport id MSTENull;
MSExport id MSTETrue;
MSExport id MSTEFalse;
MSExport id MSTEDistantPast;
MSExport id MSTEDistantFuture;
MSExport id MSTEEmptyString;

MSExport id MSTECreateRootObjectFromBuffer(CBuffer *source, CDictionary *options, CDictionary **error);
// The MSTE decoder
// If an error occurs, an error dictionary is created and returned in 'error', with 2 keys: 'code' and 'description'. The caller is responsible for its release.
// On critical error (header, crc... witch may occurs with communication failure), the returned root objet is nil and the value of the 'code' key is always 1
// If both root objet and error are returned, the error comes probably from a malformation of the source.
// 'code' 2: the error has stopped the process.
// 'code' 3: another error.
// Warning: nil may be returned without any error.


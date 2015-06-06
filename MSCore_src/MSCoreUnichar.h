/* MSCoreUnichar.h
 
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

#ifndef MSCORE_UNICHAR_H
#define MSCORE_UNICHAR_H

#if defined(MSCORE_STANDALONE) || defined(MSCORE_FORFOUNDATION) || !defined(MSFOUNDATION_FORCOCOA)
typedef unsigned short unichar;
#endif

MSCoreExtern BOOL CUnicharIsAlnum     (unichar c);
MSCoreExtern BOOL CUnicharIsAlpha     (unichar c);
MSCoreExtern BOOL CUnicharIsControl   (unichar c);
MSCoreExtern BOOL CUnicharIsUpper     (unichar c);
MSCoreExtern BOOL CUnicharIsLower     (unichar c);
MSCoreExtern BOOL CUnicharIsSpace     (unichar c); // warning : character 0x00a0 (&nbsp;) is also a
                                               // white space : should I keep it that way ?
MSCoreExtern BOOL CUnicharIsSolid     (unichar c); // not a space and not and end of line
MSCoreExtern BOOL CUnicharIsDigit     (unichar c);
MSCoreExtern BOOL CUnicharIsPunct     (unichar c);
MSCoreExtern BOOL CUnicharIsWordChar  (unichar c);
MSCoreExtern BOOL CUnicharIsPrintable (unichar c);
MSCoreExtern BOOL CUnicharIsLetter    (unichar c);
MSCoreExtern BOOL CUnicharIsHexa      (unichar c);
MSCoreExtern BOOL CUnicharIsEOL       (unichar c);
MSCoreExtern BOOL CUnicharIsSeparator (unichar c);
MSCoreExtern BOOL CUnicharIsIsoDigit  (unichar c);
MSCoreExtern BOOL CUnicharIsSpaceOrEOL(unichar c);

MSCoreExtern unichar CUnicharToUpper(unichar c);
MSCoreExtern unichar CUnicharToLower(unichar c);

MSCoreExtern BOOL               CUnicharEquals(unichar ca, unichar cb, BOOL insensitive);
MSCoreExtern NSComparisonResult CUnicharCompare(unichar ca, unichar cb, BOOL insensitive);
MSCoreExtern BOOL               CUnicharInsensitiveEquals (unichar ca, unichar cb);
MSCoreExtern NSComparisonResult CUnicharInsensitiveCompare(unichar ca, unichar cb);

MSCoreExtern BOOL               CUnicharsInsensitiveEquals (const unichar *ba, NSUInteger la, const unichar *bb, NSUInteger lb);
MSCoreExtern NSComparisonResult CUnicharsInsensitiveCompare(const unichar *ba, NSUInteger la, const unichar *bb, NSUInteger lb);

MSCoreExtern NSUInteger CUnicharsInsensitiveFind(const unichar *b, NSUInteger l, const unichar *bf, NSUInteger lf);

typedef BOOL (*CUnicharChecker)(unichar);

#endif

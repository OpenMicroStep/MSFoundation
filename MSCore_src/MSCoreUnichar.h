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

#if defined(MSCORE_STANDALONE) || defined(MSCORE_FORFOUNDATION)
typedef unsigned short unichar;
#endif // defined(MSCORE_STANDALONE) || defined(MSCORE_FORFOUNDATION)

MSExport BOOL CUnicharIsAlnum     (unichar c);
MSExport BOOL CUnicharIsAlpha     (unichar c);
MSExport BOOL CUnicharIsControl   (unichar c);
MSExport BOOL CUnicharIsUpper     (unichar c);
MSExport BOOL CUnicharIsLower     (unichar c);
MSExport BOOL CUnicharIsSpace     (unichar c); // warning : character 0x00a0 (&nbsp;) is also a
                                               // white space : should I keep it that way ?
MSExport BOOL CUnicharIsSolid     (unichar c); // not a space and not and end of line
MSExport BOOL CUnicharIsDigit     (unichar c);
MSExport BOOL CUnicharIsPunct     (unichar c);
MSExport BOOL CUnicharIsWordChar  (unichar c);
MSExport BOOL CUnicharIsPrintable (unichar c);
MSExport BOOL CUnicharIsLetter    (unichar c);
MSExport BOOL CUnicharIsHexa      (unichar c);
MSExport BOOL CUnicharIsEOL       (unichar c);
MSExport BOOL CUnicharIsSeparator (unichar c);
MSExport BOOL CUnicharIsIsoDigit  (unichar c);
MSExport BOOL CUnicharIsSpaceOrEOL(unichar c);

MSExport unichar CUnicharToUpper(unichar c);
MSExport unichar CUnicharToLower(unichar c);

MSExport BOOL               CUnicharEquals(unichar ca, unichar cb, BOOL insensitive);
MSExport BOOL               CUnicharInsensitiveEquals (unichar ca, unichar cb);
MSExport NSComparisonResult CUnicharInsensitiveCompare(unichar ca, unichar cb);

MSExport BOOL               CUnicharsInsensitiveEquals (const unichar *ba, NSUInteger la, const unichar *bb, NSUInteger lb);
MSExport NSComparisonResult CUnicharsInsensitiveCompare(const unichar *ba, NSUInteger la, const unichar *bb, NSUInteger lb);

MSExport NSUInteger CUnicharsInsensitiveFind(const unichar *b, NSUInteger l, const unichar *bf, NSUInteger lf);

typedef BOOL (*CUnicharChecker)(unichar);

#endif

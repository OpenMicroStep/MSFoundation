/* MSCColor.h
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
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
 
 WARNING : outside the MSFoundation framework or the MSCore library,
 this header file cannot be included alone, please direclty include
 MSCore.h or MSFoundation.h
 */

#ifndef MSCORE_COLOR_H
#define MSCORE_COLOR_H

typedef struct CColorStruct {
  Class isa;
#ifdef MSCORE_STANDALONE
  NSUInteger refCount;
#endif
#ifdef __BIG_ENDIAN__
  MSUInt r:8;
  MSUInt g:8;
  MSUInt b:8;
  MSUInt a:8;
#else
  MSUInt a:8;
  MSUInt b:8;
  MSUInt g:8;
  MSUInt r:8;
#endif
  }
CColor;

//Already defined in MSCObject.h
//MSExport void       CColorFree(id self);
//MSExport BOOL       CColorIsEqual(id self, id other);
//MSExport NSUInteger CColorHash(id self, unsigned depth);
//MSExport id         CColorCopy(id self);

MSExport BOOL CColorEquals(const CColor *self, const CColor *other);
MSExport NSComparisonResult CColorsCompare(CColor *self, CColor *other);

MSExport CColor *CCreateColor(MSByte r, MSByte g, MSByte b, MSByte a);

MSExport BOOL  CColorIsPale(CColor *self);
MSExport float CColorLuminance(CColor *self);

MSExport MSByte CColorRedValue         (CColor *self);
MSExport MSByte CColorGreenValue       (CColor *self);
MSExport MSByte CColorBlueValue        (CColor *self);
MSExport MSByte CColorOpacityValue     (CColor *self);
MSExport MSByte CColorTransparencyValue(CColor *self);

MSExport MSUInt CColorRGBAValue(CColor *self);
MSExport MSUInt CColorCSSValue (CColor *self);

MSExport void CColorGetCMYKValues(CColor *self, float *Cptr, float *Mptr, float *Yptr, float *Kptr);

#endif /* MSCORE_COLOR_H */

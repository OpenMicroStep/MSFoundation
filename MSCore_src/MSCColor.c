/* MSCColor.c
 
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

#include "MSCore_Private.h"

#pragma mark c-like class methods

void CColorFree(id self)
{
  MSFree(self, "CColorFree() [self]");
}

BOOL CColorIsEqual(id self, id other)
{
  return _CClassIsEqual(self,other,(CObjectEq)CColorEquals);
}

// We take the CColorCSS value in order to have the most significant bits in
// lower places.
NSUInteger CColorHash(id self, unsigned depth)
{
  MSUnused(depth);
  return CColorCSSValue((CColor*)self);
}

id CColorCopy(id self)
{
  CColor *newObject, *original;
  if (!self) return nil;
  newObject= (CColor*)MSCreateObjectWithClassIndex(CColorClassIndex);
  if (newObject) {
    original= (CColor *)self;
    newObject->r= original->r;
    newObject->g= original->g;
    newObject->b= original->b;
    newObject->a= original->a;}
  return (id)newObject;
}

const CString* CColorRetainedDescription(id self)
{
  CString *s; const CColor *a;
  if(!self) return nil;
  a= (CColor *)self;
  CCreateString(0);
  CStringAppendFormat(s, SESFromLiteral("rgba(%3d, %3d, %3d, %3d)"), a->r, a->g, a->b, a->a);
  return s;
}

#pragma mark Equality

BOOL CColorEquals(const CColor *self, const CColor *other)
{
  if (self == other) return YES;
  if (self && other) {
    const CColor *a= self, *b= other;
    return  a->r == b->r && a->g == b->g && a->b == b->b && a->a == b->a;}
  return NO;
}

NSComparisonResult CColorsCompare(CColor *self, CColor *other)
{
  MSUInt a, b;
  if (self == other) return NSOrderedSame;
  
  a= CColorRGBAValue(self);
  b= CColorRGBAValue(other);
  
  if (a < b) return NSOrderedAscending;
  if (b > a) return NSOrderedDescending;
  return NSOrderedSame;
}

#pragma mark Creation

CColor *CCreateColor(MSByte r, MSByte g, MSByte b, MSByte a)
{
  CColor *c= (CColor*)MSCreateObjectWithClassIndex(CColorClassIndex);
  c->r= r; c->g= g; c->b= b; c->a= a;
  return c;
}

#pragma mark Management

static inline float CLuminance(MSByte r, MSByte g, MSByte b, MSByte a)
{
  return (float)((0.3*r + 0.59*g +0.11*b)/255.0);
  MSUnused(a);
}
static inline BOOL CIsPale(MSByte r, MSByte g, MSByte b, MSByte a)
{
  return CLuminance(r, g, b, a) > 0.4 ? YES : NO;
}

BOOL CColorIsPale(CColor *self)
{
  return self ? CIsPale(self->r, self->g, self->b, self->a) : NO;
}

float CColorLuminance(CColor *self)
{
  return self ? CLuminance(self->r, self->g, self->b, self->a) : 0;
}

MSByte CColorRedValue         (CColor *self) {return self ? self->r : 0;}
MSByte CColorGreenValue       (CColor *self) {return self ? self->g : 0;}
MSByte CColorBlueValue        (CColor *self) {return self ? self->b : 0;}
MSByte CColorOpacityValue     (CColor *self) {return self ? self->a : 0;}
MSByte CColorTransparencyValue(CColor *self) {return self ? 255 - self->a : 0;}

MSUInt CColorRGBAValue(CColor *self)
{
  return (((MSUInt)(self->r)) << 24) |
         (((MSUInt)(self->g)) << 16) |
         (((MSUInt)(self->b)) <<  8) |
         (((MSUInt)(self->a))      );
}

MSUInt CColorCSSValue(CColor *self)
{
  return (((MSUInt)(255 - self->a)) << 24) |
         (((MSUInt)(      self->r)) << 16) |
         (((MSUInt)(      self->g)) <<  8) |
         (((MSUInt)(      self->b))      );
}

void CColorGetCMYKValues(CColor *self, float *Cptr, float *Mptr, float *Yptr, float *Kptr)
{
  double C= 0.0, M= 0.0, Y= 0.0, K= 1.0;
  if (self) {
    C= 1.0 - ((double)(self->r))/255.0;
    M= 1.0 - ((double)(self->g))/255.0;
    Y= 1.0 - ((double)(self->b))/255.0;
    K= 1.0;
    if ( C < K ) K= C;
    if ( M < K ) K= M;
    if ( Y < K ) K= Y;}
  if (K >= 1.0) {
    if (*Cptr) *Cptr= 0.;
    if (*Mptr) *Mptr= 0.;
    if (*Yptr) *Yptr= 0.;
    if (*Kptr) *Kptr= 1.;}
  else {
    if (*Cptr) *Cptr= (float)((C - K) / (1. - K));
    if (*Mptr) *Mptr= (float)((M - K) / (1. - K));
    if (*Yptr) *Yptr= (float)((Y - K) / (1. - K));
    if (*Kptr) *Kptr= (float)(K);}
}

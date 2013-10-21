//
//  MSCColor.c
//  MSCore
//
//  Created by Hervé MALAINGRE on 21/08/13.
//  Copyright (c) 2013 Hervé MALAINGRE. All rights reserved.
//

#include "MSCorePrivate_.h"

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
  return CColorCSSValue((CColor*)self);
  depth= 0; //unused parameter
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
  a= 0; // no warning
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

/* MSCArray.c
 
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

void CGrowFreeInside(id self)
{
  if (self) {
    CGrow *g= (CGrow*)self;
    MSFree(g->zone, "CGrowFreeInside() [memory]");
    g->zone= NULL; g->count= 0; g->size= 0;}
}
void CGrowFree(id self)
{
  CGrowFreeInside(self);
  MSFree(self, "CGrowFree() [self]");
}

#pragma mark Management

BOOL CGrowIsForeverImmutable(id self)
{
  return !self ? NO : (((CGrow*)self)->flags.foreverImmutable);
}

BOOL CGrowIsForeverMutable(id self)
{
  return !self ? NO : (((CGrow*)self)->flags.foreverMutable);
}

void CGrowSetForeverImmutable(id self)
{
  if (self && !((CGrow*)self)->flags.foreverMutable) {
    ((CGrow*)self)->flags.foreverImmutable= YES;}
}

void CGrowSetForeverMutable(id self)
{
  if (self && !((CGrow*)self)->flags.foreverImmutable) {
    ((CGrow*)self)->flags.foreverMutable= YES;}
}

void CGrowGrow(id self, NSUInteger n)
{
  CGrow *x; NSUInteger esz;
  if ((x= ((CGrow*)self)) && n && x->count + n > x->size && (esz= CGrowElementSize(self))) {
    NSUInteger newSize= MSCapacityForCount(x->count + n);
    if (!x->zone) x->zone= MSMallocFatal(newSize * esz, "CGrowGrow() alloc");
    else x->zone= MSReallocFatal(x->zone, newSize * esz, "CGrowGrow() realloc");
    x->size= newSize;}
}

void CGrowAdjustSize(id self)
{
  CGrow *x; NSUInteger esz;
  if ((x= ((CGrow*)self)) && x->count < x->size  && (esz= CGrowElementSize(self))) {
    if (x->count) {
      x->zone= MSReallocFatal(x->zone, x->count * esz, "CGrowAdjustSize() realloc");
      x->size= x->count;}
    else {MSFree(x->zone, "CGrowAdjustSize()"); x->zone= NULL; x->size= 0;}}
}

NSUInteger CGrowCount(const id self)
{
  return (self ? ((CGrow*)self)->count : 0);
}

#pragma mark mutability functions

void CGrowMutVerif(id self, NSUInteger idxStart, NSUInteger idxCount, char *where)
{
  CGrow *g= (CGrow*)self;
  if (!g) return;
  if (g->flags.foreverImmutable) MSReportError(MSInvalidArgumentError, MSFatalError,
    MSNotMutableError, "%s: not mutable.", where);
  if (idxStart+idxCount > g->count) MSReportError(MSInvalidArgumentError, MSFatalError,
    MSIndexOutOfRangeError,"%s: out of range.", where);
}

void CGrowMutCompress(id self, NSUInteger idxStart, NSUInteger idxCount)
// Supposed: self != null, idxStart+idxCount <= self->count. No verif
{
  CGrow *g= (CGrow*)self;
  NSUInteger n= g->count, idxEnd= idxStart+idxCount;
  char *p= g->zone; NSUInteger esz= CGrowElementSize(self);
  if (!idxCount) return;
  if (idxEnd < n) memmove(p+(esz*idxStart), p+(esz*idxEnd), esz*(n-idxEnd));
  g->count-= idxCount;
}

void CGrowMutExpand(id self, NSUInteger idxStart, NSUInteger idxCount)
// Supposed: self != null, idxStart <= self->count. No verif
{
  CGrow *g= (CGrow*)self;
  NSUInteger n= g->count, idxEnd= idxStart+idxCount;
  if (!idxCount) return;
  if (g->size < n+idxCount) CGrowGrow(self, idxCount);
  if (idxStart < n) {
    char *p= g->zone; NSUInteger esz= CGrowElementSize(self);
    memmove(p+(esz*idxEnd), p+(esz*idxStart), esz*(n-idxStart));}
  g->count+= idxCount;
}

void CGrowMutFill(id self, NSUInteger idxStart, NSUInteger idxCount, const void *data)
// Supposed: self != null, idxStart+idxCount <= self->count, data != null. No verif
{
  if (idxCount && data) {
    CGrow *g= (CGrow*)self;
    char *p= g->zone; NSUInteger esz= CGrowElementSize(self);
    memmove(p+(esz*idxStart), data, esz*idxCount);
  }
}

void CGrowMutInsert(id self, NSUInteger idxStart, NSUInteger idxCount, const void *data)
// Supposed: self != null, idxStart <= self->count, data != null. No verif
{
  CGrowMutExpand(self, idxStart, idxCount);
  CGrowMutFill(self, idxStart, idxCount, data);
}

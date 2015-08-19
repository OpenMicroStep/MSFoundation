/* MSCGrow.h
 
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

#ifndef MSCORE_GROW_H
#define MSCORE_GROW_H

// CGrow est une classe abstraite utilisée par CArray, CBuffer,
// CString, CDictionary.

// Un objet est mutable tant qu'il n'est pas fixed

// On veut que la structure à 0 soit le default (mutable).
typedef struct CGrowFlagsStruct {
  MSUInt :24;
  MSUInt elementBytes:6; // jusqu'à 63 octets
  MSUInt foreverImmutable:1;
  MSUInt foreverMutable:1;
  }
CGrowFlags;

typedef struct CGrowStruct {
  MSCORE_NSOBJECT_ATTRIBUTES
  CGrowFlags flags;
  void*      zone;   // la zone allouée pour les éléments
  NSUInteger size;   // le nombre d'éléments utilisables
  NSUInteger count;} // le nombre d'éléments utilisés
CGrow;

MSCoreExtern void CGrowFreeInside(id self);

MSCoreExtern BOOL CGrowIsForeverMutable(id self);
MSCoreExtern BOOL CGrowIsForeverImmutable(id self);
MSCoreExtern void CGrowSetForeverMutable(id self);
MSCoreExtern void CGrowSetForeverImmutable(id self);

MSCoreExtern void CGrowGrow(id self, NSUInteger n);
MSCoreExtern void CGrowAdjustSize(id self);

MSCoreExtern NSUInteger CGrowCount(const id self);

MSCoreExtern NSUInteger CGrowElementSize(id self);

#pragma mark mutability functions

void CGrowMutVerif(id self, NSUInteger idxStart, NSUInteger idxCount, char *where);

// Supposed: self != null, idxStart+idxCount <= self->count. No verif
void CGrowMutCompress(id self, NSUInteger idxStart, NSUInteger idxCount);

// Supposed: self != null, idxStart <= self->count. No verif
void CGrowMutExpand(id self, NSUInteger idxStart, NSUInteger idxCount);

// Supposed: self != null, idxStart+idxCount <= self->count, data != null. No verif
void CGrowMutFill(id self, NSUInteger idxStart, NSUInteger idxCount, const void *data);

// Supposed: self != null, idxStart <= self->count, data != null. No verif
void CGrowMutInsert(id self, NSUInteger idxStart, NSUInteger idxCount, const void *data);

#endif // MSCORE_ARRAY_H

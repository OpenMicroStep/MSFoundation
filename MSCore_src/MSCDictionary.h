/* MSCDictionary.h
 
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
 
 Keys are copied. Objects are retained. Both can not be nil.
 */

#ifndef MSCORE_DICTIONARY_H
#define MSCORE_DICTIONARY_H

typedef enum {
  CDictionaryObject= 0,
  CDictionaryPointer,
  CDictionaryNatural}
CDictionaryElementType;

// When objects are naturals, NSNotFound is used instead of nil when no object for key. Even for object enumeration.
// Idem for key enumeration

typedef struct CDictionaryFlagsStruct {
  MSUInt objType:2;  // Use values as simple void* #endif
  MSUInt keyType:2;  // Use keys as simple void* addresses (no object copy/hash) or naturals
  MSUInt :26;
  MSUInt _reserved:2;}
CDictionaryFlags;

typedef struct CDictionaryStruct {
  MSCORE_NSOBJECT_ATTRIBUTES
  void **buckets;
  NSUInteger nBuckets;
  NSUInteger count;
  CDictionaryFlags flags;}
CDictionary;

typedef struct CDictionaryEnumeratorStruct { // not a c-like object, no retain
  const CDictionary *dictionary;
  NSUInteger iBucket;
  void *jnode;}
CDictionaryEnumerator;

MSCoreExtern CDictionaryEnumerator *CDictionaryEnumeratorAlloc(const CDictionary *self);
MSCoreExtern void CDictionaryEnumeratorFree(CDictionaryEnumerator *de);

MSCoreExtern id CDictionaryEnumeratorNextObject   (CDictionaryEnumerator *de);
MSCoreExtern id CDictionaryEnumeratorNextKey      (CDictionaryEnumerator *de);
MSCoreExtern id CDictionaryEnumeratorCurrentObject(CDictionaryEnumerator *de);
MSCoreExtern id CDictionaryEnumeratorCurrentKey   (CDictionaryEnumerator *de);

MSCoreExtern CArray *CCreateArrayOfDictionaryKeys(CDictionary *d);
MSCoreExtern CArray *CCreateArrayOfDictionaryObjects(CDictionary *d);

MSCoreExtern void           CDictionaryFreeInside(id self);
MSCoreExtern BOOL           CDictionaryIsEqual(id self, id other);
MSCoreExtern NSUInteger     CDictionaryHash(id self, unsigned depth);
MSCoreExtern id             CDictionaryCopy(id self);
MSCoreExtern const CString* CDictionaryRetainedDescription(id self);
// TODO: Le BOOL cpy doit être remplacé par un autre paradigme de copie (qui copie la mutability ? Dont on décrit la mutability ?).
// Attention Dnas le Core le COPY copie la mutability et pas dans le .m: pas cohérent. Réécrire un COPY avec un arg ?)
  MSCoreExtern id         CDictionaryInitCopy(CDictionary *self, const CDictionary *copied, BOOL copyItems);
  MSCoreExtern id         CDictionaryInitCopyWithMutability(CDictionary *self, const CDictionary *copied, BOOL isMutable);

MSCoreExtern BOOL CDictionaryEquals(const CDictionary *self, const CDictionary *other);

#pragma mark Creation

MSCoreExtern CDictionary *CCreateDictionary(NSUInteger capacity);
MSCoreExtern CDictionary *CCreateDictionaryWithOptions(NSUInteger capacity, CDictionaryElementType keyType, CDictionaryElementType objType);
MSCoreExtern CDictionary *CCreateDictionaryWithObjectsAndKeys(const id *os, const id *ks, NSUInteger count);

// TODO: Le BOOL cpy doit être remplacé par un autre paradigme de copie (qui copie la mutability ? Dont on décrit la mutability ?).
MSCoreExtern CDictionary *CCreateDictionaryWithDictionaryCopyItems(const CDictionary *src, BOOL cpy);

MSCoreExtern void CDictionaryGrow(CDictionary *self, NSUInteger n);
MSCoreExtern void CDictionaryAdjustSize(CDictionary *self);

#pragma mark Informations

MSCoreExtern NSUInteger CDictionaryCount(const CDictionary *self);
MSCoreExtern id CDictionaryObjectForKey(const CDictionary *self, id k);

#pragma mark Setters

// k!=nil, o=nil => remove
MSCoreExtern void CDictionarySetObjectForKey(CDictionary *self, id o, id k);

// Si !k, retourne nil.
// Si le dico contient déjà un objet pour la clé k, retourne cet objet.
// Sinon retourne o et si o!=nil ajoute l'objet o pour cette clé.
// Si added, retourne par référence *added=YES si l'ajout a eu lieu et *added=NO dans le cas contraire.
MSCoreExtern id CDictionarySetObjectIfKeyAbsent(CDictionary *self, id o, id k, BOOL *added);

// Si !k, retourne nil.
// Si le dico contient déjà un objet pour la clé k, retourne cet objet.
// Sinon demande au handler un object et le retourne et s'il n'est pas nil l'associe à la clé k.
// Si added, retourne par référence *added=YES si l'ajout a eu lieu et *added=NO dans le cas contraire.
// Attention, si le handler crée l'objet (par exemple, le handler est MSCreateObjectWithClassIndex),
// celui-ci doit être releaser.
typedef id (*CDictionarySetHandler)(void*);
MSCoreExtern id CDictionarySetObjectFromHandlerIfKeyAbsent(CDictionary *self, CDictionarySetHandler h, void *arg, id k, BOOL *added);

// TODO: description functions

#endif

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
  CDictionaryPointer,        // Use keys or values as simple void*
  CDictionaryNatural,        // Use keys or values as NSUInteger
  CDictionaryNaturalNotZero}
CDictionaryElementType;

// When objects are naturals, (id)NSNotFound is used instead of nil when no object for key. Also for object enumeration.
// If you want (id)0 instead of (id)NSNotFound, use CDictionaryNaturalNotZero
// Idem for key

typedef struct CDictionaryFlagsStruct {
  MSUInt keyType:2;
  MSUInt objType:2;
  MSUInt :20;
  MSUInt _reserved:8;}
CDictionaryFlags;

struct CDictionaryStruct {
  MSCORE_NSOBJECT_ATTRIBUTES
  CDictionaryFlags flags;
  void **          buckets;
  NSUInteger       nBuckets;
  NSUInteger       count;};

typedef struct CDictionaryEnumeratorStruct { // not a c-like object, no retain
  const CDictionary *dictionary;
  NSUInteger iBucket;
  void *jnode;}
CDictionaryEnumerator;

MSCoreExtern CDictionaryEnumerator CMakeDictionaryEnumerator(const CDictionary *d);
MSCoreExtern id   CDictionaryEnumeratorNextObject   (CDictionaryEnumerator *de);
MSCoreExtern id   CDictionaryEnumeratorNextKey      (CDictionaryEnumerator *de);
MSCoreExtern id   CDictionaryEnumeratorCurrentObject(CDictionaryEnumerator de);
MSCoreExtern id   CDictionaryEnumeratorCurrentKey   (CDictionaryEnumerator de);

MSCoreExtern CArray *CCreateArrayOfDictionaryKeys(CDictionary *d);
MSCoreExtern CArray *CCreateArrayOfDictionaryObjects(CDictionary *d);

MSCoreExtern void           CDictionaryFreeInside(id self);
MSCoreExtern BOOL           CDictionaryIsEqual(id self, id other);
MSCoreExtern NSUInteger     CDictionaryHash(id self, unsigned depth);
MSCoreExtern id             CDictionaryCopy(id self);
MSCoreExtern CArray*        CCreateArrayOfDictionarySubs(id self, mutable CDictionary *context);
MSCoreExtern void           CDictionaryDescribe(id self, id result, int level, mutable CDictionary *ctx);
MSCoreExtern const CString* CDictionaryRetainedDescription(id self);
MSCoreExtern void CStringAppendCDictionaryDescription(CString *s, CDictionary *d); // + context de description ?
// TODO: Le BOOL cpy doit être remplacé par un autre paradigme de copie (qui copie la mutability ? Dont on décrit la mutability ?).
// Attention Dans le Core le COPY copie la mutability et pas dans le .m: pas cohérent. Réécrire un COPY avec un arg ?)
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

static inline id CDictionaryNotAKeyMarker(const CDictionary *self);


#pragma mark Generic

typedef NSUInteger (*gdict_count_f        )(id);
typedef id         (*gdict_objectForKey_f )(id, id);
typedef id         (*gdict_keyEnumerator_f)(id);
typedef id         (*gdict_nextKey_f      )(id);
typedef struct {
  union {
    CDictionaryEnumerator cEnumerator;
    struct {
      id enumerator;
      id dict;
      id key;
    } fs;
  } e;
  id stop;
} GDictionaryEnumerator;

typedef const struct gdict_pfs_s { // type for dict primitive functions
  gdict_count_f         count;
  gdict_objectForKey_f  objectForKey;
  gdict_keyEnumerator_f keyEnumerator;
  gdict_nextKey_f       nextKey;}
*gdict_pfs_t;

static inline NSUInteger GDictionaryCount(gdict_pfs_t fs, const id self);
static inline id GDictionaryObjectForKey(gdict_pfs_t fs, const id self, id k);
static inline id GDictionaryNotAKeyMarker(gdict_pfs_t fs, const id self);

MSCoreExtern GDictionaryEnumerator GMakeDictionaryEnumerator(gdict_pfs_t fs, const id dict);
static inline id GDictionaryEnumeratorNextKey(gdict_pfs_t fs, GDictionaryEnumerator *e);
static inline id GDictionaryEnumeratorCurrentObject(gdict_pfs_t fs, GDictionaryEnumerator *e);

MSCoreExtern NSUInteger GDictionaryHash(gdict_pfs_t fs, const id dict, unsigned depth);
MSCoreExtern BOOL GDictionaryEquals(gdict_pfs_t fs1, const id dd1, gdict_pfs_t fs2, const id dd2);
MSCoreExtern void CStringAppendGDictionaryDescription(CString *s, gdict_pfs_t fs, const id d); // + context de description ?

#pragma mark Inline

static inline id CDictionaryNotAKeyMarker(const CDictionary *self) {
  return self->flags.keyType == CDictionaryNatural ? (id)NSNotFound : nil;
}

static inline NSUInteger GDictionaryCount(gdict_pfs_t fs, const id self) {
  return !fs ? ((CDictionary*)self)->count : fs->count(self);
}

static inline id GDictionaryNotAKeyMarker(gdict_pfs_t fs, const id self) {
  return !fs && CDictionaryNotAKeyMarker((CDictionary*)self) ? (id)NSNotFound : nil;
}

static inline id GDictionaryObjectForKey(gdict_pfs_t fs, const id self, id k) {
  return !fs ? CDictionaryObjectForKey((CDictionary*)self, k) : fs->objectForKey(self, k);
}

static inline id GDictionaryEnumeratorNextKey(gdict_pfs_t fs, GDictionaryEnumerator *e)
{
  return !fs ? CDictionaryEnumeratorNextKey(&e->e.cEnumerator) : (e->e.fs.key= fs->nextKey(e->e.fs.enumerator));
}

static inline id GDictionaryEnumeratorCurrentObject(gdict_pfs_t fs, GDictionaryEnumerator *e)
{
  return !fs ? CDictionaryEnumeratorCurrentObject(e->e.cEnumerator) : fs->objectForKey(e->e.fs.dict, e->e.fs.key);
}

#endif

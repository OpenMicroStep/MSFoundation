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

typedef struct CDictionaryStruct {
  Class isa;
#ifdef MSCORE_STANDALONE
  NSUInteger refCount;
#endif
  NSUInteger count;
  NSUInteger nBuckets;
  void **buckets;}
CDictionary;

typedef struct CDictionaryEnumeratorStruct { // not a c-like object, no retain
  CDictionary *dictionary;
  NSUInteger iBucket;
  void *jnode;}
CDictionaryEnumerator;

MSCoreExport CDictionaryEnumerator *CDictionaryEnumeratorAlloc(const CDictionary *self);
MSCoreExport void CDictionaryEnumeratorFree(CDictionaryEnumerator *de);

MSCoreExport id CDictionaryEnumeratorNextObject   (CDictionaryEnumerator *de);
MSCoreExport id CDictionaryEnumeratorNextKey      (CDictionaryEnumerator *de);
MSCoreExport id CDictionaryEnumeratorCurrentObject(CDictionaryEnumerator *de);
MSCoreExport id CDictionaryEnumeratorCurrentKey   (CDictionaryEnumerator *de);

MSCoreExport CArray *CCreateArrayOfDictionaryKeys(CDictionary *d);
MSCoreExport CArray *CCreateArrayOfDictionaryObjects(CDictionary *d);

  MSCoreExport void       CDictionaryFreeInside(id self);
  MSCoreExport id         CDictionaryInitCopy(CDictionary *self, const CDictionary *copied);
//Already defined in MSCObject.h
//MSCoreExport void       CDictionaryFree(id self);
//MSCoreExport BOOL       CDictionaryIsEqual(id self, id other);
//MSCoreExport NSUInteger CDictionaryHash(id self, unsigned depth);
//MSCoreExport id         CDictionaryCopy(id self);
// CDictionaryCopy: As keys already come from a dictionary, they are not re-copied.

MSCoreExport BOOL CDictionaryEquals(const CDictionary *self, const CDictionary *other);

#pragma mark Creation

MSCoreExport CDictionary *CCreateDictionary(NSUInteger capacity);
MSCoreExport CDictionary *CCreateDictionaryWithObjectsAndKeys(const id *os, const id *ks, NSUInteger count);

MSCoreExport void CDictionaryGrow(CDictionary *self, NSUInteger n);

#pragma mark Informations

MSCoreExport NSUInteger CDictionaryCount(const CDictionary *self);
MSCoreExport id CDictionaryObjectForKey(const CDictionary *self, id k);

#pragma mark Setters

MSCoreExport void CDictionarySetObjectForKey(CDictionary *self, id o, id k);
// k!=nil, o=nil => remove

// TODO: description functions

#endif

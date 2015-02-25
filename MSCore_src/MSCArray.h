/* MSCArray.h
 
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

#ifndef MSCORE_ARRAY_H
#define MSCORE_ARRAY_H

// Un objet est mutable tant qu'il n'est pas fixed
// CArrayCopy préserve la mutabilité (mais pas la méthode copy)

// On veut que la structure à 0 soit le default (mutable, retain/release, no nils).
typedef struct CArrayFlagsStruct {
  MSUInt nilItems:1;
  MSUInt noRetainRelease:1;
  MSUInt :28;
  MSUInt _reserved:2;}
CArrayFlags;

struct CArrayStruct {
  MSCORE_NSOBJECT_ATTRIBUTES
  id *pointers;
  NSUInteger  size;
  NSUInteger  count;
  CArrayFlags flags;};

// HM: 27/08/13 void return and report error to be conform to ObjC error reporting

  MSCoreExtern void CArrayFreeInside(id self); // for MSArray dealloc
  MSCoreExtern id   CArrayInitCopyWithMutability(CArray *self, const CArray *copied, BOOL isMutable);
//Already defined in MSCObject.h
//MSCoreExtern void       CArrayFree(id self);
//MSCoreExtern BOOL       CArrayIsEqual(id self, id other);
//MSCoreExtern NSUInteger CArrayHash(id self, unsigned depth);
//MSCoreExtern id         CArrayCopy(id self);
//  Warning: the copy follows the options of self: if objects are not
//  retained in self, they are not retained in the copy. If nilItems are
//  allowed in self, they are also allowed in the copy.

MSCoreExtern BOOL CArrayEquals(const CArray *self, const CArray *anotherArray);
MSCoreExtern BOOL CArrayIdenticals(const CArray *self, const CArray *anotherArray);

// Returned arrays are retained.
// By default, objects are retained unless you use CCreateArrayWithOptions()
MSCoreExtern CArray *CCreateArrayWithOptions(NSUInteger capacity, BOOL noRetainRelease, BOOL nilItems);
MSCoreExtern CArray *CCreateArray(NSUInteger capacity);
MSCoreExtern CArray *CCreateArrayWithObject(id o);
MSCoreExtern CArray *CCreateArrayWithObjects(const id *os, NSUInteger count, BOOL copyItems);
MSCoreExtern CArray *CCreateSubArrayWithRange(CArray *a, NSRange rg);

MSCoreExtern void CArrayGrow(CArray *self, NSUInteger n);
MSCoreExtern void CArrayAdjustSize(CArray *self);

// Changing retain/release option. Use theses methods very carefully ! You are
// supposed knowing what you're doing !
MSCoreExtern void CArraySetRetainReleaseOptionAndRetainAllObjects(CArray *self, BOOL retain);
// Set the retain/release option to ON and if 'retain' is YES retain all the
// objects in the array.
// You may use this function if for example you have created a no retain/release
// array and need to make a real one from now.
// Or you have created a no retain/release array with objects already retained
// and want a normal behavior from now. In this case, 'retain' is NO.
MSCoreExtern void CArrayUnsetRetainReleaseOptionAndReleaseAllObjects(CArray *self, BOOL release);
// Set the retain/release option to OFF and if 'release' is YES, send a release
// on all the objects in the array.

MSCoreExtern NSUInteger CArrayCount(const CArray *self);
MSCoreExtern id CArrayObjectAtIndex(const CArray *self, NSUInteger i);
MSCoreExtern id CArrayFirstObject(const CArray *self);
MSCoreExtern id CArrayLastObject(const CArray *self);

MSCoreExtern NSUInteger CArrayIndexOfObject(const CArray *self, const id object, NSUInteger start, NSUInteger count);
MSCoreExtern NSUInteger CArrayIndexOfIdenticalObject(const CArray *self, const id object, NSUInteger start, NSUInteger count);

// CArrays are protected from inserting nil to be conform with NSArray paradygm.
// If the array doesn't retain objects, added objects are not retained.
MSCoreExtern void CArrayAddObject( CArray *self, id object);
MSCoreExtern void CArrayAddObjects(CArray *self, const id *objects, NSUInteger nb, BOOL copyItems);
MSCoreExtern void CArrayAddArray(  CArray *self, const CArray *other             , BOOL copyItems);

MSCoreExtern void CArrayRemoveObjectAtIndex(CArray *self, NSUInteger i);
MSCoreExtern void CArrayRemoveLastObject(CArray *self);

// Returns the number of removed objects
MSCoreExtern NSUInteger CArrayRemoveObject(         CArray *self, id object);
MSCoreExtern NSUInteger CArrayRemoveIdenticalObject(CArray *self, id object);
MSCoreExtern NSUInteger CArrayRemoveObjectsInRange( CArray *self, NSRange rg);
MSCoreExtern NSUInteger CArrayRemoveAllObjects(     CArray *self);

MSCoreExtern void CArrayReplaceObjectAtIndex(CArray *self, id object, NSUInteger i);
MSCoreExtern void CArrayReplaceObjectsInRange(CArray *self, const id *objects, NSRange rg, BOOL copyItems);

MSCoreExtern void CArrayInsertObjectAtIndex( CArray *self, id object, NSUInteger i);
MSCoreExtern void CArrayInsertObjectsInRange(CArray *self, const id *objects, NSRange rg, BOOL copyItems);

// Returns the first object at the same index and identical or equal to the
// objet in the other array
// TODO: Pas cohérent avec firstObjectCommonWithArray:
MSCoreExtern id CArrayFirstCommonIdenticalObject(const CArray *self, const CArray *other);
MSCoreExtern id CArrayFirstCommonObject(const CArray *self, const CArray *other);

// Returns NSNotFound if self or objet is nil
// If exact, return the object's index or NSNotFound
// If !exact: if n>ns[nb-1] returns nb-1
//            otherwise returns the smallest i verifying n<=ns[i]
MSCoreExtern NSUInteger CSortedArrayIndexOfObject(CArray *self, id object,
  NSUInteger start, NSUInteger nb,
  MSObjectComparator comparator, void *context,
  BOOL exact);

// Returns the index of the inserted object
MSCoreExtern NSUInteger CSortedArrayAddObject(CArray *self, id object,
  MSObjectComparator comparator, void *context);

/* TODO:
 #ifndef MSCORE_STANDALONE
 // these 2 function should be replaced by "MSCString" functions :
 MSCoreExtern NSString *CArrayToString(CArray *self);
 MSCoreExtern NSString *CArrayJsonRepresentation(CArray *self);
 #endif
 */
MSCoreExtern CString *CArrayToString(CArray *self);

#endif // MSCORE_ARRAY_H

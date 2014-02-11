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

typedef struct CArrayFlagsStruct {
#ifdef __BIG_ENDIAN__
  MSUInt noRetainRelease:1; // no retain / release
  MSUInt nilItems:1;        // accepting NULL or nil items
  MSUInt _pad:30;
#else
  MSUInt _pad:31;
  MSUInt nilItems:1;
  MSUInt noRetainRelease:1;
#endif
  }
CArrayFlags;

typedef struct CArrayStruct {
  Class isa;
#ifdef MSCORE_STANDALONE
  NSUInteger refCount;
#endif
  id *pointers;
  NSUInteger  count;
  NSUInteger  size;
  CArrayFlags flag;}
CArray;

// HM: 27/08/13 void return and report error to be conform to ObjC error reporting

  MSExport void       CArrayFreeInside(id self); // for MSArray dealloc
  MSExport id         CArrayInitCopy(CArray *self, const CArray *copied);
//Already defined in MSCObject.h
//MSExport void       CArrayFree(id self);
//MSExport BOOL       CArrayIsEqual(id self, id other);
//MSExport NSUInteger CArrayHash(id self, unsigned depth);
//MSExport id         CArrayCopy(id self);
//  Warning: the copy follows the options of self: if objects are not
//  retained in self, they are not retained in the copy. If nilItems are
//  allowed in self, they are also allowed in the copy.

MSExport BOOL CArrayEquals(const CArray *self, const CArray *anotherArray);
MSExport BOOL CArrayIdenticals(const CArray *self, const CArray *anotherArray);

// Returned arrays are retained.
// By default, objects are retained unless you use CCreateArrayWithOptions()
MSExport CArray *CCreateArrayWithOptions(NSUInteger capacity, BOOL noRetainRelease, BOOL nilItems);
MSExport CArray *CCreateArray(NSUInteger capacity);
MSExport CArray *CCreateArrayWithObject(id o);
MSExport CArray *CCreateArrayWithObjects(const id *os, NSUInteger count, BOOL copyItems);
MSExport CArray *CCreateSubArrayWithRange(CArray *a, NSRange rg);

MSExport void CArrayGrow(CArray *self, NSUInteger n);
MSExport void CArrayAdjustSize(CArray *self);

// Changing retain/release option. Use theses methods very carefully ! You are
// supposed knowing what you're doing !
MSExport void CArraySetRetainReleaseOptionAndRetainAllObjects(CArray *self, BOOL retain);
// Set the retain/release option to ON and if 'retain' is YES retain all the
// objects in the array.
// You may use this function if for example you have created a no retain/release
// array and need to make a real one from now.
// Or you have created a no retain/release array with objects already retained
// and want a normal behavior from now. In this case, 'retain' is NO.
MSExport void CArrayUnsetRetainReleaseOptionAndReleaseAllObjects(CArray *self, BOOL release);
// Set the retain/release option to OFF and if 'release' is YES, send a release
// on all the objects in the array.

MSExport NSUInteger CArrayCount(const CArray *self);
MSExport id CArrayObjectAtIndex(const CArray *self, NSUInteger i);
MSExport id CArrayFirstObject(const CArray *self);
MSExport id CArrayLastObject(const CArray *self);

MSExport NSUInteger CArrayIndexOfObject(const CArray *self, const id object, NSUInteger start, NSUInteger count);
MSExport NSUInteger CArrayIndexOfIdenticalObject(const CArray *self, const id object, NSUInteger start, NSUInteger count);

// CArrays are protected from inserting nil to be conform with NSArray paradygm.
// If the array doesn't retain objects, added objects are not retained.
MSExport void CArrayAddObject( CArray *self, id object);
MSExport void CArrayAddObjects(CArray *self, const id *objects, NSUInteger nb, BOOL copyItems);
MSExport void CArrayAddArray(  CArray *self, const CArray *other       , BOOL copyItems);

MSExport void CArrayRemoveObjectAtIndex(CArray *self, NSUInteger i);
MSExport void CArrayRemoveLastObject(CArray *self);

// Returns the number of removed objects
MSExport NSUInteger CArrayRemoveObject(         CArray *self, id object);
MSExport NSUInteger CArrayRemoveIdenticalObject(CArray *self, id object);
MSExport NSUInteger CArrayRemoveObjectsInRange( CArray *self, NSRange rg);
MSExport NSUInteger CArrayRemoveAllObjects(     CArray *self);

MSExport void CArrayReplaceObjectAtIndex(CArray *self, id object, NSUInteger i);
MSExport void CArrayReplaceObjectsInRange(CArray *self, const id *objects, NSRange rg, BOOL copyItems);

MSExport void CArrayInsertObjectAtIndex( CArray *self, id object, NSUInteger i);
MSExport void CArrayInsertObjectsInRange(CArray *self, const id *objects, NSRange rg, BOOL copyItems);

// Returns the first object at the same index and identical or equal to the
// objet in the other array
// TODO: Pas cohérent avec firstObjectCommonWithArray:
MSExport id CArrayFirstCommonIdenticalObject(const CArray *self, const CArray *other);
MSExport id CArrayFirstCommonObject(const CArray *self, const CArray *other);

// Returns NSNotFound if self or objet is nil
// If exact, return the object's index or NSNotFound
// If !exact: if n>ns[nb-1] returns nb-1
//            otherwise returns the smallest i verifying n<=ns[i]
MSExport NSUInteger CSortedArrayIndexOfObject(CArray *self, id object,
  NSUInteger start, NSUInteger nb,
  MSObjectComparator comparator, void *context,
  BOOL exact);

// Returns the index of the inserted object
MSExport NSUInteger CSortedArrayAddObject(CArray *self, id object,
  MSObjectComparator comparator, void *context);

/* TODO:
 #ifndef MSCORE_STANDALONE
 // these 2 function should be replaced by "MSCString" functions :
 MSExport NSString *CArrayToString(CArray *self);
 MSExport NSString *CArrayJsonRepresentation(CArray *self);
 #endif
 */
MSExport CString *CArrayToString(CArray *self);

#define MSAAdd(  X, Y) CArrayAddObject((CArray*)(X), (Y))
#define MSAPush( X, Y) MSAAdd(X, Y)
#define MSAIndex(X, Y) ((CArray*)(X))->pointers[(Y)]
#define MSACount(X) CArrayCount((CArray*)(X))
#define MSAFirst(X) CArrayFirstObject((CArray*)(X))
#define MSALast( X) CArrayLastObject((CArray*)(X))
#define MSAPull( X) CArrayRemoveLastObject((CArray*)(X))

#endif // MSCORE_ARRAY_H

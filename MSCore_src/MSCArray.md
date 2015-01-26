MSCArray Reference
==================

Data Types
----------

#### CArrayFlags

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

#### CArray

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

Functions by Task
-----------------

- `CArrayFreeInside`
- `CArrayInitCopy`
- `CArrayEquals`
- `CArrayIdenticals`
- `CCreateArrayWithOptions`
- `CCreateArray`
- `CCreateArrayWithObject`
- `CCreateArrayWithObjects`
- `CCreateSubArrayWithRange`
- `CArrayGrow`
- `CArrayAdjustSize`
- `CArraySetRetainReleaseOptionAndRetainAllObjects`
- `CArrayUnsetRetainReleaseOptionAndReleaseAllObjects`
- `CArrayCount`
- `CArrayObjectAtIndex`
- `CArrayFirstObject`
- `CArrayLastObject`
- `CArrayIndexOfObject`
- `CArrayIndexOfIdenticalObject`
- `CArrayAddObject`
- `CArrayAddObjects`
- `CArrayAddArray`
- `CArrayRemoveObjectAtIndex`
- `CArrayRemoveLastObject`
- `CArrayRemoveObject`
- `CArrayRemoveIdenticalObject`
- `CArrayRemoveObjectsInRange`
- `CArrayRemoveAllObjects`
- `CArrayReplaceObjectAtIndex`
- `CArrayReplaceObjectsInRange`
- `CArrayInsertObjectAtIndex`
- `CArrayInsertObjectsInRange`
- `CArrayFirstCommonIdenticalObject`
- `CArrayFirstCommonObject`
- `CArrayToString`

Functions
---------

#### CArrayFreeInside

    MSCoreExport void       CArrayFreeInside(id self)

#### CArrayInitCopy

    MSCoreExport id         CArrayInitCopy(CArray *self, const CArray *copied)

#### CArrayEquals

    MSCoreExport BOOL CArrayEquals(const CArray *self, const CArray *anotherArray)

#### CArrayIdenticals

    MSCoreExport BOOL CArrayIdenticals(const CArray *self, const CArray *anotherArray)

#### CCreateArrayWithOptions

    MSCoreExport CArray *CCreateArrayWithOptions(NSUInteger capacity, BOOL noRetainRelease, BOOL nilItems)

#### CCreateArray

    MSCoreExport CArray *CCreateArray(NSUInteger capacity)

#### CCreateArrayWithObject

    MSCoreExport CArray *CCreateArrayWithObject(id o)

#### CCreateArrayWithObjects

    MSCoreExport CArray *CCreateArrayWithObjects(const id *os, NSUInteger count, BOOL copyItems)

#### CCreateSubArrayWithRange

    MSCoreExport CArray *CCreateSubArrayWithRange(CArray *a, NSRange rg)

#### CArrayGrow

    MSCoreExport void CArrayGrow(CArray *self, NSUInteger n)

#### CArrayAdjustSize

    MSCoreExport void CArrayAdjustSize(CArray *self)

#### CArraySetRetainReleaseOptionAndRetainAllObjects

    MSCoreExport void CArraySetRetainReleaseOptionAndRetainAllObjects(CArray *self, BOOL retain)

#### CArrayUnsetRetainReleaseOptionAndReleaseAllObjects

    MSCoreExport void CArrayUnsetRetainReleaseOptionAndReleaseAllObjects(CArray *self, BOOL release)

#### CArrayCount

    MSCoreExport NSUInteger CArrayCount(const CArray *self)

#### CArrayObjectAtIndex

    MSCoreExport id CArrayObjectAtIndex(const CArray *self, NSUInteger i)

#### CArrayFirstObject

    MSCoreExport id CArrayFirstObject(const CArray *self)

#### CArrayLastObject

    MSCoreExport id CArrayLastObject(const CArray *self)

#### CArrayIndexOfObject

    MSCoreExport NSUInteger CArrayIndexOfObject(const CArray *self, const id object, NSUInteger start, NSUInteger count)

#### CArrayIndexOfIdenticalObject

    MSCoreExport NSUInteger CArrayIndexOfIdenticalObject(const CArray *self, const id object, NSUInteger start, NSUInteger count)

#### CArrayAddObject

    MSCoreExport void CArrayAddObject( CArray *self, id object)

#### CArrayAddObjects

    MSCoreExport void CArrayAddObjects(CArray *self, const id *objects, NSUInteger nb, BOOL copyItems)

#### CArrayAddArray

    MSCoreExport void CArrayAddArray(  CArray *self, const CArray *other             , BOOL copyItems)

#### CArrayRemoveObjectAtIndex

    MSCoreExport void CArrayRemoveObjectAtIndex(CArray *self, NSUInteger i)

#### CArrayRemoveLastObject

    MSCoreExport void CArrayRemoveLastObject(CArray *self)

#### CArrayRemoveObject

    MSCoreExport NSUInteger CArrayRemoveObject(         CArray *self, id object)

#### CArrayRemoveIdenticalObject

    MSCoreExport NSUInteger CArrayRemoveIdenticalObject(CArray *self, id object)

#### CArrayRemoveObjectsInRange

    MSCoreExport NSUInteger CArrayRemoveObjectsInRange( CArray *self, NSRange rg)

#### CArrayRemoveAllObjects

    MSCoreExport NSUInteger CArrayRemoveAllObjects(     CArray *self)

#### CArrayReplaceObjectAtIndex

    MSCoreExport void CArrayReplaceObjectAtIndex(CArray *self, id object, NSUInteger i)

#### CArrayReplaceObjectsInRange

    MSCoreExport void CArrayReplaceObjectsInRange(CArray *self, const id *objects, NSRange rg, BOOL copyItems)

#### CArrayInsertObjectAtIndex

    MSCoreExport void CArrayInsertObjectAtIndex( CArray *self, id object, NSUInteger i)

#### CArrayInsertObjectsInRange

    MSCoreExport void CArrayInsertObjectsInRange(CArray *self, const id *objects, NSRange rg, BOOL copyItems)

#### CArrayFirstCommonIdenticalObject

    MSCoreExport id CArrayFirstCommonIdenticalObject(const CArray *self, const CArray *other)

#### CArrayFirstCommonObject

    MSCoreExport id CArrayFirstCommonObject(const CArray *self, const CArray *other)

#### CArrayToString

    MSCoreExport CString *CArrayToString(CArray *self)


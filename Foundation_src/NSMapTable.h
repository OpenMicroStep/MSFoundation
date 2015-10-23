@class NSArray, NSString;

typedef CDictionary NSMapTable;
typedef CDictionaryEnumerator NSMapEnumerator;
typedef CDictionaryElementType NSMapTableKeyCallBacks;
typedef CDictionaryElementType NSMapTableValueCallBacks;

#define NSNotAnIntegerMapKey ((const void *)NSNotFound)
#define NSNotAPointerMapKey ((const void *)NSNotFound)

FoundationExtern const NSMapTableKeyCallBacks NSIntegerMapKeyCallBacks;
FoundationExtern const NSMapTableKeyCallBacks NSNonOwnedPointerMapKeyCallBacks;
FoundationExtern const NSMapTableKeyCallBacks NSNonOwnedPointerOrNullMapKeyCallBacks;
FoundationExtern const NSMapTableKeyCallBacks NSNonRetainedObjectMapKeyCallBacks;
FoundationExtern const NSMapTableKeyCallBacks NSObjectMapKeyCallBacks;
FoundationExtern const NSMapTableValueCallBacks NSIntegerMapValueCallBacks;
FoundationExtern const NSMapTableValueCallBacks NSNonOwnedPointerMapValueCallBacks;
FoundationExtern const NSMapTableValueCallBacks NSObjectMapValueCallBacks;
FoundationExtern const NSMapTableValueCallBacks NSNonRetainedObjectMapValueCallBacks;

FoundationExtern void NSFreeMapTable(NSMapTable *table);
FoundationExtern void NSResetMapTable(NSMapTable *table);
FoundationExtern BOOL NSCompareMapTables(NSMapTable *table1, NSMapTable *table2);
FoundationExtern NSMapTable *NSCopyMapTableWithZone(NSMapTable *table, NSZone *zone);
FoundationExtern BOOL NSMapMember(NSMapTable *table, const void *key, void **originalKey, void **value);
FoundationExtern void *NSMapGet(NSMapTable *table, const void *key);
FoundationExtern void NSMapInsert(NSMapTable *table, const void *key, const void *value);
FoundationExtern void NSMapInsertKnownAbsent(NSMapTable *table, const void *key, const void *value);
FoundationExtern void *NSMapInsertIfAbsent(NSMapTable *table, const void *key, const void *value);
FoundationExtern void NSMapRemove(NSMapTable *table, const void *key);
FoundationExtern NSMapEnumerator NSEnumerateMapTable(NSMapTable *table);
FoundationExtern BOOL NSNextMapEnumeratorPair(NSMapEnumerator *enumerator, void **key, void **value);
FoundationExtern void NSEndMapTableEnumeration(NSMapEnumerator *enumerator);
FoundationExtern NSUInteger NSCountMapTable(NSMapTable *table);
FoundationExtern NSString *NSStringFromMapTable(NSMapTable *table);
FoundationExtern NSArray *NSAllMapTableKeys(NSMapTable *table);
FoundationExtern NSArray *NSAllMapTableValues(NSMapTable *table);
FoundationExtern NSMapTable *NSCreateMapTableWithZone(NSMapTableKeyCallBacks keyCallBacks, NSMapTableValueCallBacks valueCallBacks, NSUInteger capacity, NSZone *zone);
FoundationExtern NSMapTable *NSCreateMapTable(NSMapTableKeyCallBacks keyCallBacks, NSMapTableValueCallBacks valueCallBacks, NSUInteger capacity);


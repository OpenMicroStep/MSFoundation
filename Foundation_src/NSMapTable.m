#import "FoundationCompatibility_Private.h"

const NSMapTableKeyCallBacks NSIntegerMapKeyCallBacks= CDictionaryNatural;
const NSMapTableKeyCallBacks NSNonOwnedPointerMapKeyCallBacks= CDictionaryPointer;
const NSMapTableKeyCallBacks NSNonOwnedPointerOrNullMapKeyCallBacks= CDictionaryNatural;
const NSMapTableKeyCallBacks NSNonRetainedObjectMapKeyCallBacks= CDictionaryPointer;
const NSMapTableKeyCallBacks NSObjectMapKeyCallBacks= CDictionaryObject;
//const NSMapTableKeyCallBacks NSOwnedPointerMapKeyCallBacks;
//const NSMapTableKeyCallBacks NSIntMapKeyCallBacks

const NSMapTableValueCallBacks NSIntegerMapValueCallBacks= CDictionaryNatural;
const NSMapTableValueCallBacks NSNonOwnedPointerMapValueCallBacks= CDictionaryPointer;
const NSMapTableValueCallBacks NSObjectMapValueCallBacks= CDictionaryObject;
const NSMapTableValueCallBacks NSNonRetainedObjectMapValueCallBacks= CDictionaryPointer;
//const NSMapTableValueCallBacks NSOwnedPointerMapValueCallBacks;
//const NSMapTableValueCallBacks NSIntMapValueCallBacks NS_DEPRECATED_MAC(10_0, 10_5);

NSMapTable *NSCreateMapTableWithZone(NSMapTableKeyCallBacks keyCallBacks, NSMapTableValueCallBacks valueCallBacks, NSUInteger capacity, NSZone *zone)
{
    return CCreateDictionaryWithOptions(capacity, keyCallBacks, valueCallBacks);
}
NSMapTable *NSCreateMapTable(NSMapTableKeyCallBacks keyCallBacks, NSMapTableValueCallBacks valueCallBacks, NSUInteger capacity)
{
    return CCreateDictionaryWithOptions(capacity, keyCallBacks, valueCallBacks);
}

void NSFreeMapTable(NSMapTable *table)
{ RELEASE((id)table); }
void NSResetMapTable(NSMapTable *table)
{ CDictionaryFreeInside((id)table); }
BOOL NSCompareMapTables(NSMapTable *table1, NSMapTable *table2)
{ return CDictionaryEquals(table1, table2); }
NSMapTable *NSCopyMapTableWithZone(NSMapTable *table, NSZone *zone)
{ return (NSMapTable*)CDictionaryCopy((id)table); }
BOOL NSMapMember(NSMapTable *table, const void *key, void **originalKey, void **value)
{
    id o; BOOL ret;
    o= CDictionaryObjectForKey(table, (id)key);
    ret= o != (table->flags.objType == CDictionaryNatural ? (id)NSNotFound : nil);
    if(ret) {
        if (originalKey)
            *(id*)originalKey= key;
        if (value)
            *(id*)value= o;
    }
    return ret;
}
void * NSMapGet(NSMapTable *table, const void *key)
{
    id o= CDictionaryObjectForKey(table, (id)key);
    return table->flags.objType == CDictionaryNatural ? (o == (id)NSNotFound ? NULL : o) : o;
}
void NSMapInsert(NSMapTable *table, const void *key, const void *value)
{
    CDictionarySetObjectForKey(table, (id)value, (id)key);
}
void NSMapInsertKnownAbsent(NSMapTable *table, const void *key, const void *value)
{
    CDictionarySetObjectForKey(table, (id)value, (id)key);
}
void * NSMapInsertIfAbsent(NSMapTable *table, const void *key, const void *value)
{
    BOOL added; id o;
    o= CDictionarySetObjectIfKeyAbsent(table, (id)value, (id)key, &added);
    return added ? NULL : o;
}
void NSMapRemove(NSMapTable *table, const void *key)
{
    CDictionarySetObjectForKey(table, (table->flags.objType == CDictionaryNatural ? (id)NSNotFound : nil), (id)key);
}
NSMapEnumerator NSEnumerateMapTable(NSMapTable *table)
{
    RETAIN(table);
    return CMakeDictionaryEnumerator(table);
}
BOOL NSNextMapEnumeratorPair(NSMapEnumerator *enumerator, void ** key, void ** value)
{
    id o, k; BOOL ret;
    o= CDictionaryEnumeratorNextObject(enumerator);
    ret= o != (enumerator->dictionary->flags.objType == CDictionaryNatural ? (id)NSNotFound : nil);
    if (ret) {
        k= CDictionaryEnumeratorCurrentKey(*enumerator);
        if (key)
            *(id*)key= k;
        if (value)
            *(id*)value= o;
    }
    return ret;

}
void NSEndMapTableEnumeration(NSMapEnumerator *enumerator)
{
    RELEASE(enumerator->dictionary);
}

NSUInteger NSCountMapTable(NSMapTable *table)
{
    return CDictionaryCount(table);
}
static void _appendMapTableValue(CString *s, void *v, CDictionaryElementType type)
{
    if (type == CDictionaryObject)
        CStringAppendFormat(s, "%@", (id)v);
    else if (type == CDictionaryPointer)
        CStringAppendFormat(s, "%p", v);
    else
        CStringAppendFormat(s, "%lld", (MSLong)v);
}
NSString *NSStringFromMapTable(NSMapTable *table)
{
    CString *s; NSMapEnumerator e; void *k, *v;
    s= CCreateString(0);
    e= NSEnumerateMapTable(table);
    while(NSNextMapEnumeratorPair(&e, &k, &v)) {
        _appendMapTableValue(s, k, table->flags.keyType);
        CStringAppendLiteral(s, " = ");
        _appendMapTableValue(s, k, table->flags.objType);
        CStringAppendCharacter(s, '\n');
    }
    NSEndMapTableEnumeration(&e);
    return AUTORELEASE(s);
}
NSArray *NSAllMapTableKeys(NSMapTable *table)
{
    return AUTORELEASE(CCreateArrayOfDictionaryKeys(table));
}
NSArray *NSAllMapTableValues(NSMapTable *table)
{
    return AUTORELEASE(CCreateArrayOfDictionaryObjects(table));
}
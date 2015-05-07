@class NSEnumerator;

@interface NSArray : NSObject <NSCopying, NSMutableCopying/*, NSSecureCoding, NSFastEnumeration*/>

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;
- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)cnt;

@end

@interface NSArray (NSGenericArray)

- (BOOL)isEqualToArray:(NSArray*)otherArray;
- (NSString*)description;
- (id)firstObject;
- (id)lastObject;
- (BOOL)containsObject:(id)anObject;
- (BOOL)containsObjectIdenticalTo:(id)o;
- (NSUInteger)indexOfObject:(id)anObject;
- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range;
- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject;
- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)range;
- (NSEnumerator*)objectEnumerator;
- (NSEnumerator*)reverseObjectEnumerator;
- (void)getObjects:(id*)objects;
- (void)getObjects:(id*)objects range:(NSRange)range;

- (void)makeObjectsPerformSelector:(SEL)aSelector;
- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument;
- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2;

@end

@interface NSArray (NSGenericNewArray)

- (NSArray*)arrayByAddingObject:(id)anObject;
- (NSArray*)arrayByAddingObjectsFromArray:(NSArray *)otherArray;

@end

@interface NSArray (NSExtendedArrayUndone)

- (NSString *)componentsJoinedByString:(NSString *)separator;
- (NSString *)descriptionWithLocale:(id)locale;
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;
- (id)firstObjectCommonWithArray:(NSArray *)otherArray;
- (NSData *)sortedArrayHint;
- (NSArray *)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context;
- (NSArray *)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context hint:(NSData *)hint;
- (NSArray *)sortedArrayUsingSelector:(SEL)comparator;
- (NSArray *)subarrayWithRange:(NSRange)range;
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;

typedef NS_OPTIONS(NSUInteger, NSBinarySearchingOptions) {
	NSBinarySearchingFirstEqual = (1UL << 8),
	NSBinarySearchingLastEqual = (1UL << 9),
	NSBinarySearchingInsertionIndex = (1UL << 10),
};
@end

@interface NSArray (NSArrayCreation)

+ (instancetype)array;
+ (instancetype)arrayWithObject:(id)anObject;
+ (instancetype)arrayWithObjects:(const id [])objects count:(NSUInteger)cnt;
+ (instancetype)arrayWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)arrayWithArray:(NSArray *)array;

- (instancetype)init;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (instancetype)initWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype)initWithArray:(NSArray *)array;
- (instancetype)initWithArray:(NSArray *)array copyItems:(BOOL)flag;

+ (NSArray *)arrayWithContentsOfFile:(NSString *)path;
- (NSArray *)initWithContentsOfFile:(NSString *)path;

@end

@interface NSMutableArray : NSArray

- (void)addObject:(id)anObject;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeLastObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

@end

@interface NSMutableArray (NSExtendedMutableArray)
    
- (void)addObjectsFromArray:(NSArray *)otherArray;
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (void)removeAllObjects;
- (void)removeObject:(id)anObject inRange:(NSRange)range;
- (void)removeObject:(id)anObject;
- (void)removeObjectIdenticalTo:(id)anObject inRange:(NSRange)range;
- (void)removeObjectIdenticalTo:(id)anObject;
- (void)removeObjectsFromIndices:(NSUInteger *)indices numIndices:(NSUInteger)cnt;
- (void)removeObjectsInArray:(NSArray *)otherArray;
- (void)removeObjectsInRange:(NSRange)range;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray;
- (void)setArray:(NSArray *)otherArray;
- (void)sortUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context;
- (void)sortUsingSelector:(SEL)comparator;

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
@end

@interface NSMutableArray (NSMutableArrayCreation)

+ (instancetype)arrayWithCapacity:(NSUInteger)numItems;
- (instancetype)initWithCapacity:(NSUInteger)numItems;

@end


@interface NSDictionary : NSObject
- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (NSEnumerator*)keyEnumerator;
@end

@interface NSDictionary (NSGenericDictionary)

- (BOOL)isEqualToDictionary:(NSDictionary*)otherDict;

@end

@interface NSDictionary (NSDictionaryCreation)
+ (instancetype)dictionary;
+ (instancetype)dictionaryWithObject:(id)object forKey:(id <NSCopying>)key;
+ (instancetype)dictionaryWithObjects:(const id [])objects forKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt;
+ (instancetype)dictionaryWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)dictionaryWithDictionary:(NSDictionary *)dict;
+ (instancetype)dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys;

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt;
- (instancetype)initWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary;
- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)flag;
- (instancetype)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys;

+ (NSDictionary *)dictionaryWithContentsOfFile:(NSString *)path;
- (NSDictionary *)initWithContentsOfFile:(NSString *)path;
@end

@interface NSMutableDictionary : NSDictionary

- (void)removeObjectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;

@end

@interface NSMutableDictionary (NSMutableDictionaryCreation)

+ (instancetype)dictionaryWithCapacity:(NSUInteger)numItems;
- (instancetype)initWithCapacity:(NSUInteger)numItems;

@end

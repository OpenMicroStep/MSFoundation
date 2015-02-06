
@interface NSDictionary : NSObject
- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (NSEnumerator *)keyEnumerator;
@end

@interface NSDictionary (NSDictionaryCreation)
+ (instancetype)dictionary;
+ (instancetype)dictionaryWithObject:(id)object forKey:(id <NSCopying>)key;
+ (instancetype)dictionaryWithObjects:(const id [])objects forKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt;
+ (instancetype)dictionaryWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)dictionaryWithDictionary:(NSDictionary *)dict;
+ (instancetype)dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys;

- (instancetype)initWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary;
- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)flag;
- (instancetype)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys;

+ (NSDictionary *)dictionaryWithContentsOfFile:(NSString *)path;
- (NSDictionary *)initWithContentsOfFile:(NSString *)path;
@end

@interface NSMutableDictionary : NSDictionary

@end

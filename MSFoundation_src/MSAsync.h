@class MSAsync;

typedef enum {
  MSAsyncDefining,
  MSAsyncStarted,
  MSAsyncAborted,
  MSAsyncFinishing,
  MSAsyncTerminated
} MSAsyncState;

typedef void (*MSAsyncAction)(MSAsync *flux);
typedef void (*MSAsyncSuperAction)(MSAsync *flux, id arg);
typedef BOOL (*MSAsyncCondition)(MSAsync *flux);

@interface MSAsyncElement : NSObject
- (void)action:(MSAsync *)flux;
@end

@interface MSAsyncElement (CreateAsyncElements)
+ (MSAsyncElement *)asyncAction:(MSAsyncAction)action;
+ (MSAsyncElement *)asyncSuperAction:(MSAsyncSuperAction)superAction withObject:(id)object;
+ (MSAsyncElement *)asyncTarget:(id)target action:(SEL)action;
+ (MSAsyncElement *)asyncTarget:(id)target action:(SEL)action withObject:(id)object;
+ (MSAsyncElement *)asyncWhile:(MSAsyncCondition)condition do:(id)elements;
+ (MSAsyncElement *)asyncIf:(MSAsyncCondition)condition then:(id)thenElements;
+ (MSAsyncElement *)asyncIf:(MSAsyncCondition)condition then:(id)thenElements else:(id)elseElements;

+ (MSAsyncElement *)asyncWithParallelElements:(NSArray *)elements;
+ (MSAsyncElement *)asyncWithParallelElements:(NSArray *)elements contexts:(NSArray *)contexts;

+ (MSAsyncElement *)asyncOnce:(id)elements context:(mutable MSDictionary *)context;
+ (MSAsyncElement *)asyncOnce:(id)elements context:(mutable MSDictionary *)context forKey:(id)key;
@end

@interface MSAsync : MSAsyncElement
+ (instancetype)runWithContext:(mutable MSDictionary *)context elements:(id)elements;

+ (instancetype)async;
- (instancetype)init;

+ (instancetype)asyncWithContext:(mutable MSDictionary *)context elements:(id)elements;
- (instancetype)initWithContext:(mutable MSDictionary *)context elements:(id)elements;

- (mutable MSDictionary*)context;
- (MSAsyncState)state;

- (void)setFirstElements:(id)elements;

- (void)continue;
@end

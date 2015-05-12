
@protocol NSLocking

- (void)lock;
- (void)unlock;

@end

@interface NSLock : NSObject <NSLocking> {
@private
  pthread_mutex_t _lock;
}

- (BOOL)tryLock;
- (BOOL)lockBeforeDate:(NSDate *)limit;

@end

@interface NSConditionLock : NSObject <NSLocking> {
@private
  NSInteger _condition;
  pthread_mutex_t _lock;
  pthread_cond_t _cond;
}

- (instancetype)initWithCondition:(NSInteger)condition;

- (NSInteger)condition;
- (void)lockWhenCondition:(NSInteger)condition;
- (BOOL)tryLock;
- (BOOL)tryLockWhenCondition:(NSInteger)condition;
- (void)unlockWithCondition:(NSInteger)condition;
- (BOOL)lockBeforeDate:(NSDate *)limit;
- (BOOL)lockWhenCondition:(NSInteger)condition beforeDate:(NSDate *)limit;

@end

@interface NSRecursiveLock : NSObject <NSLocking> {
@private
  pthread_mutex_t _lock;
}

- (BOOL)tryLock;
- (BOOL)lockBeforeDate:(NSDate *)limit;

@end

@interface NSCondition : NSObject <NSLocking> {
@private
  pthread_mutex_t _lock;
  pthread_cond_t _cond;
}

- (void)wait;
- (BOOL)waitUntilDate:(NSDate *)limit;
- (void)signal;
- (void)broadcast;

@end

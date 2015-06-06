
@interface NSTimer : NSObject {
@private
  void *_uv_timer;
  SEL _selector;
  id _targetOrInvocation;
  id _userInfo;
  NSTimeInterval _date;
  NSTimeInterval _timeInterval;
}
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds
                                 invocation:(NSInvocation *)invocation
                                    repeats:(BOOL)repeats;
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds
                                     target:(id)target
                                   selector:(SEL)aSelector
                                   userInfo:(id)userInfo
                                    repeats:(BOOL)repeats;
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds
                        invocation:(NSInvocation *)invocation
                           repeats:(BOOL)repeats;
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds
                            target:(id)target
                          selector:(SEL)aSelector
                          userInfo:(id)userInfo
                           repeats:(BOOL)repeats;
- (instancetype)initWithFireDate:(NSDate *)date
                        interval:(NSTimeInterval)seconds
                          target:(id)target
                        selector:(SEL)aSelector
                        userInfo:(id)userInfo
                         repeats:(BOOL)repeats;
- (void)fire;
- (NSDate *)fireDate;
- (void)invalidate;
- (BOOL)isValid;
- (NSTimeInterval)timeInterval;
- (id)userInfo;
@end
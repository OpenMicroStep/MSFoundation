#import "FoundationCompatibility_Private.h"

@implementation NSTimer

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds
                                 invocation:(NSInvocation *)invocation
                                    repeats:(BOOL)repeats
{
  NSTimer *timer;
  timer= [self timerWithTimeInterval:seconds invocation:invocation repeats:repeats];
  [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
  return timer;
}
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds
                                     target:(id)target
                                   selector:(SEL)selector
                                   userInfo:(id)userInfo
                                    repeats:(BOOL)repeats
{
  NSTimer *timer;
  timer= [self timerWithTimeInterval:seconds target:target selector:selector userInfo:userInfo repeats:repeats];
  [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
  return timer;
}                                    
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds
                        invocation:(NSInvocation *)invocation
                           repeats:(BOOL)repeats
{
  NSTimer *timer= [ALLOC(NSTimer) 
               _initWithFireDate:GMTNow() + seconds
                        interval:seconds 
              targetOrInvocation:invocation 
                        selector:NULL 
                        userInfo:nil 
                         repeats:repeats];
  return AUTORELEASE(timer);
}
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds
                            target:(id)target
                          selector:(SEL)aSelector
                          userInfo:(id)userInfo
                           repeats:(BOOL)repeats
{
  NSTimer *timer= [ALLOC(NSTimer) 
               _initWithFireDate:GMTNow() + seconds
                        interval:seconds 
              targetOrInvocation:target 
                        selector:aSelector 
                        userInfo:userInfo 
                         repeats:repeats];
  return AUTORELEASE(timer);
}
- (instancetype)initWithFireDate:(NSDate *)date
                        interval:(NSTimeInterval)seconds
                          target:(id)target
                        selector:(SEL)aSelector
                        userInfo:(id)userInfo
                         repeats:(BOOL)repeats
{
  return [self _initWithFireDate:[date timeIntervalSinceReferenceDate]
                        interval:seconds 
              targetOrInvocation:target 
                        selector:aSelector 
                        userInfo:userInfo 
                         repeats:repeats];
}

- (instancetype)_initWithFireDate:(NSTimeInterval)date
                         interval:(NSTimeInterval)seconds
               targetOrInvocation:(id)target
                         selector:(SEL)aSelector
                         userInfo:(id)userInfo
                          repeats:(BOOL)repeats
{
  _date= date;
  _timeInterval= repeats ? MAX(0.001, seconds) : 0;
  _targetOrInvocation= [target retain];
  _selector= aSelector;
  _userInfo= [userInfo retain];
  return self;
}
- (void)dealloc
{
  [self invalidate];
  [super dealloc];
}
- (void)_fire
{
  [self fire];
  if (!_timeInterval) {
    [self invalidate];}
}
- (void)fire
{
  if(_selector) {
    [_targetOrInvocation performSelector:_selector withObject:self];
  }
  else {
    [(NSInvocation*)_targetOrInvocation invoke];
  }
  if(_timeInterval > 0)
    _date= _date + _timeInterval;
}
static void _nstimer_fire_cb(uv_timer_t* handle)
{
  [(id)handle->data _fire];
}
static void _nstimer_close_cb(uv_handle_t* handle)
{
  MSFree(handle, "NSTimer uv_timer_t");
}
- (void)_addToLoop:(uv_loop_t *)uv_loop
{
  if(!_uv_timer) {
    uv_timer_t *t;
    t= (uv_timer_t*)MSMallocFatal(sizeof(uv_timer_t), "NSTimer uv_timer_t");
    _uv_timer=t;
    int r= uv_timer_init(uv_loop, t);
    t->data= [self retain];
    uv_timer_start(t, _nstimer_fire_cb, (uint64_t)MAX(0.0, (_date - GMTNow()) * 1000), (uint64_t)(_timeInterval * 1000));
  }
}
- (void)invalidate
{
  DESTROY(_targetOrInvocation);
  DESTROY(_userInfo);
  if(_uv_timer) {
    [self release];
    uv_timer_stop((uv_timer_t*)_uv_timer);
    uv_close((uv_handle_t*) _uv_timer, _nstimer_close_cb);
    _uv_timer=NULL;
  }
}
- (BOOL)isValid
{ return _targetOrInvocation != nil; }
- (NSDate *)fireDate
{ return [NSDate dateWithTimeIntervalSinceReferenceDate:_date]; }
- (NSTimeInterval)timeInterval
{ return _timeInterval; }
- (id)userInfo
{ return _userInfo; }
@end
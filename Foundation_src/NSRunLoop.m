#import "FoundationCompatibility_Private.h"

NSString* const NSDefaultRunLoopMode= @"default";
NSString* const NSRunLoopCommonModes= @"common";

static void __currentRunLoop_dtor(void *runloop) {
  [(NSRunLoop*)runloop release];
}
MS_DECLARE_THREAD_LOCAL(__currentRunLoop, __currentRunLoop_dtor);

@implementation NSRunLoop

+ (void)load
{
  if (self == [NSRunLoop class]) {
    NSRunLoop *mainRunLoop= [ALLOC(NSRunLoop) initWithLoop:uv_default_loop()];
    tss_set(__currentRunLoop, mainRunLoop);}
}

+ (NSRunLoop *)currentRunLoop
{
  NSRunLoop *loop= tss_get(__currentRunLoop);
  if(!loop) {
    tss_set(__currentRunLoop, loop= [ALLOC(NSRunLoop) initWithLoop:NULL]);}
  return loop;
}
- (instancetype)initWithLoop:(uv_loop_t *)loop {
  if(!loop) {
    loop= (uv_loop_t *)MSMallocFatal(sizeof(uv_loop_t), "NSRunLoop uv_loop_t");
    uv_loop_init(loop);}
  _uv_loop= loop;
  return self;
}
- (void)dealloc {
  if (_uv_loop != uv_default_loop()) {
    uv_loop_close(_uv_loop);
    MSFree(_uv_loop, "NSLoop uv_loop_t");}
  [super dealloc];
}

- (void)addTimer:(NSTimer *)aTimer forMode:(NSString *)mode
{
  [aTimer _addToLoop:_uv_loop];
}

static void _runUntilDate_timer_cb(uv_timer_t* handle)
{
  handle->data= 1;
  uv_stop(handle->loop);
}
- (BOOL)runMode:(NSString *)mode beforeDate:(NSDate *)limitDate
{
  [self runUntilDate:limitDate];
  return YES;
}
- (void)runUntilDate:(NSDate *)limitDate
{
  uv_timer_t timer;
  uv_timer_init(_uv_loop, &timer);
  timer.data = 0;
  uv_timer_start(&timer, _runUntilDate_timer_cb, (uint64_t)([limitDate timeIntervalSinceNow] * 1000.0), 0);
  while(uv_run(_uv_loop, UV_RUN_DEFAULT) && timer.data == 0)
    ;
}
- (void)acceptInputForMode:(NSString *)mode beforeDate:(NSDate *)limitDate
{
  uv_timer_t timer;
  uv_timer_init(_uv_loop, &timer);
  timer.data = 0;
  uv_timer_start(&timer, _runUntilDate_timer_cb, (uint64_t)([limitDate timeIntervalSinceNow] * 1000.0), 0);
  uv_run(_uv_loop, UV_RUN_ONCE);
}

- (void)run
{
  while(uv_run(_uv_loop, UV_RUN_DEFAULT))
    ;
}

- (int)_uv_run
{
  return uv_run(_uv_loop, UV_RUN_DEFAULT);
}

- (void)_uv_stop
{
  return uv_stop(_uv_loop);
}

- (uv_loop_t *)_uv_loop
{
  return _uv_loop;
}
@end
#import "FoundationCompatibility_Private.h"

NSString* const NSDefaultRunLoopMode= @"default";
NSString* const NSRunLoopCommonModes= @"common";

@implementation NSRunLoop

static void __currentRunLoop_dtor(void *runloop) {
  [(NSRunLoop*)runloop release];
}
MS_DECLARE_THREAD_LOCAL(__currentRunLoop, __currentRunLoop_dtor);

+ (NSRunLoop *)currentRunLoop
{
  NSRunLoop *loop= tss_get(__currentRunLoop);
  if(!loop) {
    tss_set(__currentRunLoop, [NSRunLoop new]);
  }
  return loop;
}
- (instancetype)init {
  _uv_loop= MSMallocFatal(sizeof(uv_loop_t), "NSRunLoop uv_loop_t");
  uv_loop_init(_uv_loop);
  return self;
}
- (void)dealloc {
  uv_loop_close(_uv_loop);
  MSFree(_uv_loop, "NSLoop uv_loop_t");
  [super dealloc];
}
- (void)addTimer:(NSTimer *)aTimer forMode:(NSString *)mode
{
  [aTimer _addToLoop:_uv_loop];
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
#import "MSNode_Private.h"

@implementation MSAsyncTask

+ (MSPromise *)runAsyncTask:(MSAsyncTaskHandler)task args:(int)argc, ...
{
  va_list ap; MSAsyncTask* ret;
  va_start(ap, argc);
  ret= AUTORELEASE([ALLOC(self) initWithTask:task argc:argc argv:ap]);
  va_end(ap);
  return [ret start];
}
+ (instancetype)asyncTask:(MSAsyncTaskHandler)task args:(int)argc, ...
{
  va_list ap; MSAsyncTask* ret;
  va_start(ap, argc);
  ret= [ALLOC(self) initWithTask:task argc:argc argv:ap];
  va_end(ap);
  return AUTORELEASE(ret);
}
- (instancetype)initWithTask:(MSAsyncTaskHandler)task args:(int)argc, ...
{
  va_list ap;
  va_start(ap, argc);
  self= [self initWithTask:task argc:argc argv:ap];
  va_end(ap);
  return self;
}
- (instancetype)initWithTask:(MSAsyncTaskHandler)task argc:(int)argc argv:(va_list)ap
{
  if ((self= [super init])) {
    _handler= MSCreateHandlerWithArguments(task, sizeof(uv_work_t), argc, ap);
    ((uv_work_t *)MSHandlerReserved(_handler))->data= [self retain];
  }
  return self;
}
- (instancetype)init
{
  return [self initWithTask:NULL args:0];
}
- (void)dealloc
{
  [_promise release];
  [_ret release];
  MSFree(_handler, "MSAsyncTask");
  [super dealloc];
}
static void _work_cb(uv_work_t* req)
{
  [(MSAsyncTask *)req->data _work];
}
static void _after_work_cb(uv_work_t* req, int status)
{
  [(MSAsyncTask *)req->data _after_work:status];
}
- (void)_work
{
  NEW_POOL;
  _ret= [MSPromise new];
  if (_handler->fn)
    ((MSAsyncTaskHandler)_handler->fn)(_ret, MSHandlerArgs(_handler, sizeof(uv_work_t)));
  else
    [self run:_ret];
  KILL_POOL;
}
- (void)_after_work:(int)status
{
  NEW_POOL;
  if (status == 0) {
    if ([_ret isPending]) {
      [_promise reject:@"The task didn't returned anything"];
    }
    else {
      [_promise resolveWithPromise:_ret];
    }
  }
  else {
    [_promise reject:FMT(@"%s", uv_strerror(status))];
  }
  [self release];
  KILL_POOL;
}
- (MSPromise *)start
{
  if (!_promise) {
    _promise= [MSPromise new];
    uv_queue_work([NSRunLoop currentUvRunLoop], (uv_work_t *)MSHandlerReserved(_handler), _work_cb, _after_work_cb);
  }
  return _promise;
}
- (void)abort
{
  uv_cancel((uv_req_t *)MSHandlerReserved(_handler));
}
- (void)run:(MSPromise *)promise
{
  [promise reject:@"must be implemented by subclasses"];
}
- (BOOL)isRunning
{
  return [_promise isPending];
}
- (BOOL)isFinished
{
  return [_promise isFulfilled];
}
@end

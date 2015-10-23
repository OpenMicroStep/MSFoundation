
typedef void (*MSAsyncTaskHandler)(MSPromise *promise, MSHandlerArg *args);

@interface MSAsyncTask : NSObject {
  MSPromise *_promise;
  MSPromise *_ret;
  MSHandler *_handler;
}
+ (MSPromise *)runAsyncTask:(MSAsyncTaskHandler)task args:(int)argc, ...;
+ (instancetype)asyncTask:(MSAsyncTaskHandler)task args:(int)argc, ...;
- (instancetype)init;
- (instancetype)initWithTask:(MSAsyncTaskHandler)task args:(int)argc, ...;
- (instancetype)initWithTask:(MSAsyncTaskHandler)task argc:(int)argc argv:(va_list)ap;
- (MSPromise *)start;
- (void)abort;
- (BOOL)isRunning;
- (BOOL)isFinished;
@end

@interface MSAsyncTask (Run)
- (void)run:(MSPromise *)promise;
@end

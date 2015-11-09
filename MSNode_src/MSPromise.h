@class MSPromise;

typedef MSPromise* (*MSPromiseSuccessHandler)(id result, MSHandlerArg *args);
typedef MSPromise* (*MSPromiseRejectHandler)(id reason, MSHandlerArg *args);
typedef void (*MSPromiseFinallyHandler)(MSHandlerArg *args);

typedef enum {
  MSPromisePending = 0,
  MSPromiseFulfilled = 1,
  MSPromiseRejected = 2
} MSPromiseState;


@interface MSPromise : NSObject {
  MSPromiseState _state;
  MSHandlerList _listeners;
  id _res;
  MSPromise *_next;
}
+ (MSPromise *)promise;
+ (MSPromise *)promiseResolved:(id)result;
+ (MSPromise *)promiseRejected:(id)reason;
+ (MSPromise *)promiseWithAllResolvedOf:(NSArray *)promises waitForAll:(BOOL)waitForAll;
+ (MSPromise *)promiseWithFirstResultOf:(NSArray *)promises;

- (MSPromise *)then:(MSPromiseSuccessHandler)handler args:(int)argc, ...;
- (MSPromise *)catch:(MSPromiseRejectHandler)handler args:(int)argc, ...;
- (void)finally:(MSPromiseFinallyHandler)handler args:(int)argc, ...;

- (MSPromise *)catch:(id)target action:(SEL)sel context:(id)object;
- (MSPromise *)then:(id)target action:(SEL)sel context:(id)object;
- (void)keepObjectAlive:(id)object;

- (BOOL)isFulfilled;
- (BOOL)isRejected;
- (BOOL)isPending;
- (MSPromiseState)state;

- (void)resolve:(id)result;
- (void)reject:(id)reason;
- (void)resolveWithPromise:(MSPromise *)result;
@end

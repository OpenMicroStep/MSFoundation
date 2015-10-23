@class MSPromise;

typedef void (*MSPromiseSuccessHandler)(MSPromise *instigator, MSPromise *next, id result, MSHandlerArg *args);
typedef void (*MSPromiseRejectHandler)(MSPromise *instigator, id reason, MSHandlerArg *args);

typedef enum {
  MSPromisePending = 0,
  MSPromiseFulfilled = 1,
  MSPromiseRejected = 2
} MSPromiseState;


@interface MSPromise : NSObject {
  MSPromiseState _state;
  MSHandlerList _listeners;
  id _res;
}
+ (MSPromise *)promise;
+ (MSPromise *)promiseWithAllResolvedOf:(NSArray *)promises waitForAll:(BOOL)waitForAll;
+ (MSPromise *)promiseWithFirstResultOf:(NSArray *)promises;

- (MSPromise *)chainableThen:(MSPromiseSuccessHandler)handler args:(int)argc, ...;
- (void)then:(MSPromiseSuccessHandler)handler args:(int)argc, ...;
- (void)catch:(MSPromiseRejectHandler)handler args:(int)argc, ...;

- (BOOL)isFulfilled;
- (BOOL)isRejected;
- (BOOL)isPending;
- (MSPromiseState)state;

- (void)resolve:(id)result;
- (void)reject:(id)reason;
- (void)resolveWithPromise:(MSPromise *)result;
@end


@interface MSNodeWorker : NSObject {
  CArray *_queue;
  mtx_t _queue_mtx;
  cnd_t _queue_cnd;
}
// Run -[target selector] on the thread pool then call -[doneTarget doneSelector] in the nodejs thread
+ (void)workOnTarget:(id)target selector:(SEL)selector notifyTarget:(id)doneTarget selector:(SEL)doneSelector;

// Create a dedicated thread to always run tasks on the same thread
- (instancetype)init;
- (void)workOnTarget:(id)target selector:(SEL)selector notifyTarget:(id)doneTarget selector:(SEL)doneSelector;
@end
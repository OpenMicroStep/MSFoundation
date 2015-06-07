#import "MSNode_Private.h"

typedef struct {
  id workerTarget; SEL workerSelector;
  id doneTarget; SEL doneSelector;
  id result; uv_loop_t *node_loop;
} MSNodeWork;

struct MSNodeWorkerStruct {
  MSCORE_NSOBJECT_ATTRIBUTES
  CArray *_queue;
  mtx_t _queue_mtx;
  cnd_t _queue_cnd;
};

static void _workOnTarget(uv_work_t* req)
{
  MSNodeWork *work= (MSNodeWork *)req->data; 
  work->result= [[work->workerTarget performSelector:work->workerSelector] retain];
}
static void _notifyTarget(uv_handle_t* req)
{
  MSNodeWork *work= (MSNodeWork *)req->data; IMP imp;
  imp= LOOKUP(work->doneTarget, work->doneSelector);
  ((void(*)(id,SEL, id))imp)(work->doneTarget, work->doneSelector, work->result);
  [work->workerTarget release];
  [work->doneTarget release];
  [work->result release];
  free(req->data);
  free(req);
}
static void _asyncNotifyTarget(uv_async_t* req)
{ _notifyTarget((uv_handle_t*)req); }
static void _workNotifyTarget(uv_work_t* req, int status)
{ _notifyTarget((uv_handle_t*)req); }
static int _workThreadMain(void *a)
{
  struct MSNodeWorkerStruct *worker= (struct MSNodeWorkerStruct *)a;
  CArray *_queue= worker->_queue;
  mtx_t _queue_mtx= worker->_queue_mtx;
  cnd_t _queue_cnd= worker->_queue_cnd;
  MSNodeWork *work; BOOL c= YES;
  while (c) {
    mtx_lock(&_queue_mtx);
    while (!CArrayCount(_queue))
      cnd_wait(&_queue_cnd, &_queue_mtx);
    work= (MSNodeWork*)CArrayObjectAtIndex(_queue, 0);
    CArrayRemoveObjectAtIndex(_queue, 0);
    mtx_unlock(&_queue_mtx);

    if (work) {
      work->result= [[work->workerTarget performSelector:work->workerSelector] retain];
      uv_async_t *req= (uv_async_t*)MSMallocFatal(sizeof(uv_async_t), "MSNodeWorker");
      uv_async_init(work->node_loop, req, _asyncNotifyTarget);
      uv_async_send(req);
    }
    c= work != NULL;
  }
  cnd_destroy(&_queue_cnd);
  mtx_destroy(&_queue_mtx);
  RELEASE(_queue);
  return 0;
}

static MSNodeWork * _newWork(id target, SEL selector, id doneTarget, SEL doneSelector)
{
  MSNodeWork *work= (MSNodeWork*)MSMallocFatal(sizeof(MSNodeWork), "MSNodeWorker");
  work->workerTarget=[target retain];
  work->workerSelector=selector;
  work->doneTarget=[doneTarget retain];
  work->doneSelector=doneSelector;
  work->result= nil;
  work->node_loop= uv_default_loop(); // nodejs use the default loop :)
  return work;
}

@implementation MSNodeWorker
// Run -[target selector] on the thread pool then call -[doneTarget doneSelector] in the nodejs thread
+ (void)workOnTarget:(id)target selector:(SEL)selector notifyTarget:(id)doneTarget selector:(SEL)doneSelector
{
  MSNodeWork *work= _newWork(target, selector, doneTarget, doneSelector);
  uv_work_t *req= (uv_work_t*)MSMallocFatal(sizeof(uv_work_t), "MSNodeWorker");
  req->data= work;
  uv_queue_work(work->node_loop, req, _workOnTarget, _workNotifyTarget);
}

// Create a dedicated thread to always run tasks on the same thread
- (instancetype)init
{
  if ((self= [super init])) {
    thrd_t thrd;
    _queue= CCreateArrayWithOptions(0, YES, YES);
    mtx_init(&_queue_mtx, mtx_plain);
    cnd_init(&_queue_cnd);
    thrd_create(&thrd, _workThreadMain, self);
  }
  return self;
}
- (void)dealloc
{
  mtx_lock(&_queue_mtx);
  CArrayAddObject(_queue, nil);
  cnd_signal(&_queue_cnd);
  mtx_unlock(&_queue_mtx);
  [super dealloc];
}
- (void)workOnTarget:(id)target selector:(SEL)selector notifyTarget:(id)doneTarget selector:(SEL)doneSelector
{
  mtx_lock(&_queue_mtx);
  CArrayAddObject(_queue, (id)_newWork(target, selector, doneTarget, doneSelector));
  cnd_signal(&_queue_cnd);
  mtx_unlock(&_queue_mtx);
}
@end
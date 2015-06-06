#import "FoundationCompatibility_Private.h"

#define STATE_NEW 0
#define STATE_STARTING 1
#define STATE_RUNNING 2
#define STATE_CANCELED 3
#define STATE_FINISHED 4

static void __currentThread_dtor(void *thread) {
  [(NSThread*)thread release];
}
MS_DECLARE_THREAD_LOCAL(__currentThread, __currentThread_dtor);

@implementation NSThread 
+ (BOOL)isMultiThreaded
{
	return YES;
}

+ (void)detachNewThreadSelector:(SEL)selector
                       toTarget:(id)target
                     withObject:(id)object
{ 
  NSThread* thread= [[NSThread alloc] initWithTarget:target selector:selector object:object]; 
  [thread start];
  [thread release];
}
- (instancetype)init
{
	_dic= [NSMutableDictionary new];
	return self;
}

- (instancetype)initWithTarget:(id)target
                      selector:(SEL)selector
                        object:(id)argument
{
  if((self= [self init])) {
    _target= [target retain];
    _sel= selector;
    _arg= [argument retain];
  }
  return self;
}
- (void)dealloc
{
  [_dic release];
  [_target release];
  [_arg release];
	[super dealloc];
}

+ (NSThread *)currentThread
{
	NSThread *thread= tss_get(__currentThread);
	if(!thread) {
		thread= [NSThread new];
    thread->_state= STATE_RUNNING;
    tss_set(__currentThread, self);
	}
	return thread;
}

- (NSMutableDictionary *)threadDictionary
{
	return _dic;
}

static int start_routine(void* data)
{
  NSThread *thread= (NSThread*)data;
  if(__sync_bool_compare_and_swap(&thread->_state, STATE_STARTING, STATE_RUNNING)) {
    tss_set(__currentThread, thread);
    [thread main];
  }
  [thread release];
  return 0;
}

- (void)start
{
  if(__sync_bool_compare_and_swap(&_state, STATE_NEW, STATE_STARTING)) {
    thrd_t thread;
    [self retain];
    thrd_create(&thread, start_routine, self);
  }
}

- (void)main
{
  if(_target && _sel) {
    IMP imp= objc_msg_lookup(_target, _sel);
    imp(_target, _sel, _arg);
  }
}

- (void)cancel {
  __sync_bool_compare_and_swap(&_state, STATE_RUNNING, STATE_CANCELED) ||
  __sync_bool_compare_and_swap(&_state, STATE_STARTING, STATE_CANCELED);
}

- (BOOL)executing
{ return _state == STATE_RUNNING;}
- (BOOL)finished
{ return _state == STATE_FINISHED;}
- (BOOL)cancelled 
{ return _state == STATE_CANCELED;}

@end
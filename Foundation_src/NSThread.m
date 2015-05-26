#import "FoundationCompatibility_Private.h"

#define STATE_NEW 0
#define STATE_STARTING 1
#define STATE_RUNNING 2
#define STATE_CANCELED 3
#define STATE_FINISHED 4

static pthread_key_t __currentThread_key;

static void __currentThread_key_free(void *thread)
{
  [(NSThread*)thread release];
}

@implementation NSThread 
+ (void)load
{
  pthread_key_create(&__currentThread_key, __currentThread_key_free);
}

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
	NSThread *thread= pthread_getspecific(__currentThread_key);
	if(!thread) {
		thread= [NSThread new];
    thread->_state= STATE_RUNNING;
    pthread_setspecific(__currentThread_key, self);
	}
	return thread;
}

- (NSMutableDictionary *)threadDictionary
{
	return _dic;
}

static void* start_routine(void* data)
{
  NSThread *thread= (NSThread*)data;
  if(__sync_bool_compare_and_swap(&thread->_state, STATE_STARTING, STATE_RUNNING)) {
    pthread_setspecific(__currentThread_key, thread);
    [thread main];
  }
  [thread release];
  return NULL;
}

- (void)start
{
  if(__sync_bool_compare_and_swap(&_state, STATE_NEW, STATE_STARTING)) {
    pthread_t thread;
    [self retain];
    pthread_create(&thread, NULL, start_routine, self);
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
#import "FoundationCompatibility_Private.h"

static NSNotificationCenter *__defaultCenter;
static once_flag __defaultCenter_once = ONCE_FLAG_INIT;
static void __defaultCenter_init() {
  __defaultCenter= [NSNotificationCenter new];
}

struct observer_s
{
  id observer;
  SEL selector;
  NSString *name;
  id sender;
  struct observer_s *next;
};

@implementation NSNotificationCenter
+ (NSNotificationCenter *)defaultCenter
{
  call_once(&__defaultCenter_once, __defaultCenter_init);
  return __defaultCenter;
}

- (instancetype)init
{
  if ((self= [super init])) {
    mtx_init(&_mtx, mtx_plain);
    _observers= CCreateArrayWithOptions(0, NO, NO);}
  return self;
}
- (void)dealloc
{
  struct observer_s *n, *o= (struct observer_s*)_observers;
  while (o) {
    n= o->next;
    MSFree(o, "NSNotificationCenter dealloc");
    o=n; }
  mtx_destroy(&_mtx);
  [super dealloc];
}

- (void)addObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)sender
{
  mtx_lock(&_mtx);
  struct observer_s *o= (struct observer_s *)MSMallocFatal(sizeof(struct observer_s), "NSNotificationCenter addObserver");
  o->observer= observer;
  o->selector= selector;
  o->name= name;
  o->sender= sender;
  o->next= NULL;
  if (_observers) 
    ((struct observer_s*)_observers)->next= o;
  _observers= o;
  mtx_unlock(&_mtx);
}

- (void)removeObserver:(id)observer
{ [self removeObserver:observer name:nil object:nil]; }
- (void)removeObserver:(id)observer name:(NSString *)name object:(id)sender
{
  mtx_lock(&_mtx);
  struct observer_s *p= NULL, *n, *o= _observers;
  while (o) {
    n= o->next;
    if(o->observer == observer && (!name || [o->name isEqualToString:name]) && (!sender || o->sender == sender)) { 
      MSFree(o, "NSNotificationCenter removeObserver");
      if(p) {
        p->next= n;}
      else {
        _observers= n;}}
    else {
      p= o;}
    o= n;}
  mtx_unlock(&_mtx);
}

static inline void _postNotification(struct observer_s *o, NSNotification *notification, NSString *name, id sender) {
  while (o) {
    if (( !o->sender || o->sender == sender ) && ( !o->name && [o->name isEqualToString:name] )) {
      [o->observer performSelector:o->selector withObject:notification];}
    o= o->next;}
}
- (void)postNotification:(NSNotification *)notification
{ 
  mtx_lock(&_mtx);
  _postNotification((struct observer_s*)_observers, notification, [notification name], [notification object]);
  mtx_unlock(&_mtx);
}
- (void)postNotificationName:(NSString *)name object:(id)sender
{ 
  NSNotification *notification= [ALLOC(NSNotification) initWithName:name object:sender userInfo:nil];
  mtx_lock(&_mtx);
  _postNotification((struct observer_s*)_observers, notification, name, sender);
  mtx_unlock(&_mtx);
  [notification release];
}
- (void)postNotificationName:(NSString *)name object:(id)sender userInfo:(NSDictionary *)userInfo
{ 
  NSNotification *notification= [ALLOC(NSNotification) initWithName:name object:sender userInfo:userInfo];
  mtx_lock(&_mtx);
  _postNotification((struct observer_s*)_observers, notification, name, sender);
  mtx_unlock(&_mtx);
  [notification release];
}
@end

#import "MSNode_Private.h"

@implementation MSAsync
+ (MSAsync*)asyncTo:(void(*)(MSAsync *))handler
{
  MSAsync *async= [MSAsync new];
  async->_handler= handler;
  async->_d= CCreateArray(0);
  return async;
}
- (void)store:(id)v, ...
{
  va_list va; id o;
  va_start(va, v);
  while ((o= va_arg(va, id))) {
    CArrayAddObject(_d, o); }
  va_end(va);
  _idx = CArrayCount(_d);
}
- (void)restore:(id*)pv, ...
{
  va_list va; id* po; NSUInteger i= 0;
  va_start(va, pv);
  while ((po= va_arg(va, id*))) {
    *po= CArrayObjectAtIndex(_d, i++); }
  va_end(va);
}
- (void)result:(id*)pv, ...
{
  va_list va; id* po; NSUInteger i= _idx;
  va_start(va, pv);
  while ((po= va_arg(va, id*))) {
    *po= CArrayObjectAtIndex(_d, i++); }
  va_end(va);
}
- (void)asyncDone
{
  _handler(self);
  [self release];
}
- (void)asyncDone:(id)v1
{
  CArrayAddObject(_d, v1);
  [self asyncDone];
}
- (void)asyncDone:(id)v1 v2:(id)v2
{
  CArrayAddObject(_d, v1);
  CArrayAddObject(_d, v2);
  [self asyncDone];
}
- (void)asyncDone:(id)v1 v2:(id)v2 v3:(id)v3
{
  CArrayAddObject(_d, v1);
  CArrayAddObject(_d, v2);
  CArrayAddObject(_d, v3);
  [self asyncDone];
}
@end
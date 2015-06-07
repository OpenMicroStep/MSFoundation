@interface MSAsync : NSObject {
  void(*_handler)(MSAsync *);
  CArray *_d;
  NSUInteger _idx;
}
+ (MSAsync*)asyncTo:(void(*)(MSAsync *))handler;
- (void)store:(id)v, ...;
- (void)restore:(id*)pv, ...;
- (void)result:(id*)pv, ...;
- (void)asyncDone;
- (void)asyncDone:(id)v1;
- (void)asyncDone:(id)v1 v2:(id)v2;
- (void)asyncDone:(id)v1 v2:(id)v2 v3:(id)v3;
@end
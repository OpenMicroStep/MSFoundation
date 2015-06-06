@interface NSNotificationCenter : NSObject {
@private
  mtx_t _mtx;
  void *_observers;
}
+ (NSNotificationCenter *)defaultCenter;

- (void)addObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)sender;
- (void)removeObserver:(id)observer;
- (void)removeObserver:(id)observer name:(NSString *)name object:(id)sender;

- (void)postNotification:(NSNotification *)notification;
- (void)postNotificationName:(NSString *)name object:(id)sender;
- (void)postNotificationName:(NSString *)name object:(id)sender userInfo:(NSDictionary *)userInfo;
@end

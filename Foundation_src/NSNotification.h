
@interface NSNotification : NSObject <NSCoding, NSCopying> {
@private
  NSString *_name;
  id _object;
  NSDictionary *_userInfo;
}
+ (instancetype)notificationWithName:(NSString *)aName object:(id)anObject;
+ (instancetype)notificationWithName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)userInfo;
- (instancetype)initWithName:(NSString *)aName object:(id)object userInfo:(NSDictionary *)userInfo;

- (NSString *)name;
- (id)object;
- (NSDictionary *)userInfo;
@end

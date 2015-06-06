
@interface NSProcessInfo : NSObject {
@private 
  NSString *_processName;
}
+ (NSProcessInfo *)processInfo;
- (NSArray *)arguments;
- (NSDictionary *)environment;
- (NSString *)globallyUniqueString;
- (NSString *)hostName;
- (unsigned int)operatingSystem;
- (NSString *)operatingSystemName;
- (NSString *)processName;
- (void)setProcessName:(NSString *)newName;
@end

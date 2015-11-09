
FoundationExtern NSString *NSTaskDidTerminateNotification;

@interface NSTask : NSObject {
@private
  NSArray *_arguments;
  NSString *_currentDirectoryPath;
  NSDictionary *_env;
  NSString *_launchPath;
  int _exitStatus;
  void *_uv_process;
}
+ (NSTask *)launchedTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments;
- (instancetype)init;

- (NSArray *)arguments;
- (void)setArguments:(NSArray *)arguments;

- (NSString *)currentDirectoryPath;
- (void)setCurrentDirectoryPath:(NSString *)currentDirectoryPath;

- (NSDictionary *)environment;
- (void)setEnvironment:(NSDictionary *)env;

- (NSString *)launchPath;
- (void)setLaunchPath:(NSString *)launchPath;

- (int)processIdentifier;

- (void)interrupt;

- (void)waitUntilExit;
- (BOOL)isRunning;
- (int)terminationStatus;

@end


@interface MSHttpStaticFilesMiddleware : NSObject <MSHttpMiddleware> {
  NSString *_path;
}
+ (instancetype)staticFilesMiddlewareWithPath:(NSString *)path;
- (instancetype)initWithPath:(NSString *)path;
@end

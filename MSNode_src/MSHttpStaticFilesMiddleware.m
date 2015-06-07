#import "MSNode_Private.h"

@implementation MSHttpStaticFilesMiddleware
+ (instancetype)staticFilesMiddlewareWithPath:(NSString *)path
{ return AUTORELEASE([ALLOC(self) initWithPath:path]); }
- (instancetype)initWithPath:(NSString *)path
{
  if ((self= [super init])) {
    _path= [path copy];
  }
  return self;
}

- (void)onTransaction:(MSHttpTransaction *)tr next:(id <MSHttpNextMiddleware>)next
{
  uv_fs_t req; BOOL handled= NO;
  id path= [_path stringByAppendingPathComponent:[next routeUrl]];
  const char *cpath= [path UTF8String];
  if (cpath && uv_fs_stat(uv_default_loop(), &req, cpath, NULL) == 0) {
    if ((req.statbuf.st_mode & S_IFREG) > 0) {
      [tr writeFile:path];
      handled= YES;}
    uv_fs_req_cleanup(&req);
  }
  if (!handled) {
    [next nextMiddleware];}
}
@end
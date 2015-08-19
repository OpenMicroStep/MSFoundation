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
- (void)dealloc
{
  [_path release];
  [super dealloc];
}

- (void)onTransaction:(MSHttpTransaction *)tr next:(id <MSHttpNextMiddleware>)next
{
  id path= [_path stringByAppendingPathComponent:[next routeUrl]];
  if ([[NSFileManager defaultManager] isReadableFileAtPath:path]) {
    [tr writeFile:path];}
  else {
    [next nextMiddleware];}
}
@end
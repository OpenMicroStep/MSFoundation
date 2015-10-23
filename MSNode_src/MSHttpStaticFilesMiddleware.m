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

static NSString *MSNodeContentTypeForExtension(NSString *ext)
{
  static CDictionary*mimes;
  id ret;
  if (!mimes) {
    mimes= CCreateDictionary(32);
    CDictionarySetObjectForKey(mimes, @"application/json", @"json");
    CDictionarySetObjectForKey(mimes, @"image/gif", @"gif");
    CDictionarySetObjectForKey(mimes, @"image/jpeg", @"jpg");
    CDictionarySetObjectForKey(mimes, @"image/jpeg", @"jpeg");
    CDictionarySetObjectForKey(mimes, @"image/png", @"png");
    CDictionarySetObjectForKey(mimes, @"text/css", @"css");
    CDictionarySetObjectForKey(mimes, @"text/html", @"html");
    CDictionarySetObjectForKey(mimes, @"application/javascript", @"js");
  }
  ret= CDictionaryObjectForKey(mimes, ext);
  if (!ret)
    ret= @"application/octet-stream";
  return ret;
}
- (void)onTransaction:(MSHttpTransaction *)tr
{
  NSDictionary *attrs;
  id path= [_path stringByAppendingPathComponent:[tr urlAfterRouting]];
  attrs= [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
  if (attrs && [NSFileTypeRegular isEqual:[attrs objectForKey:NSFileType]]) {
    [tr setValue:[attrs objectForKey:NSFileSize] forHeader:@"Content-Length"];
    [tr setValue:@"public, max-age=0" forHeader:@"Cache-Control"];
    [tr setValue:MSNodeContentTypeForExtension([[path pathExtension] lowercaseString]) forHeader:@"Content-Type"];
    [tr writeFile:path];}
  else {
    [tr nextRoute];}
}
@end
#import "FoundationCompatibility_Private.h"

enum {
  TYPE_UNKNOWN= 0,
  TYPE_EXE,
  TYPE_FRAMEWORK,
  TYPE_BUNDLE
};
@interface NSBundle (Private)
- (instancetype)_initWithPath:(NSString *)path exepath:(NSString *)exepath;
@end

once_flag __mainBundle_once = ONCE_FLAG_INIT;
static mtx_t __mutex;
static BOOL __refresh= YES;
static CArray *__frameworks= NULL;
static CDictionary *__bundleByIds= NULL;
static CDictionary *__bundleByPath= NULL;
static CDictionary *__bundleByExePath= NULL;
static NSBundle *__mainBundle = nil;

static NSBundle * _createBundleWithExePath(NSString *exepath, BOOL isMainExe);
static void mainBundle_init();
static void _bundleIterator(const char *name, void *data);
static NSString *_absolutepath(NSString *path);

static void mainBundle_init() {
  const char *utf8Path;
  CString *path;

  utf8Path= ms_get_current_process_path();
  //printf("utf8Path=%s\n", utf8Path);
  path= CCreateStringWithBytes(NSUTF8StringEncoding, utf8Path, strlen(utf8Path));
  __mainBundle= _createBundleWithExePath((NSString*)path, YES);
}
static void _bundleIterator(const char *name, void *data)
{
  //printf("name=%s\n", name);
  [_createBundleWithExePath([NSString stringWithUTF8String:name], NO) release];
}
static void _refreshIfNeeded()
{
  call_once(&__mainBundle_once, mainBundle_init);
  if (__refresh) {
    ms_shared_object_iterate(_bundleIterator, NULL);
  }
}

@implementation NSBundle  {
@private
  uint32_t _type;
  uint32_t _state;
  NSDictionary *_info;
  NSString *_path;
  NSString *_exepath;
  NSString *_rscPath;
  mtx_t _mutex;
}
+ (void)initialize {
  if (self == [NSBundle self]) {
    __bundleByIds= CCreateDictionary(32);
    __bundleByPath= CCreateDictionary(32);
    __bundleByExePath= CCreateDictionary(32);
    __frameworks= CCreateArray(32);
    mtx_init(&__mutex, mtx_plain | mtx_recursive);
  }
}
+ (NSBundle *)mainBundle
{
  call_once(&__mainBundle_once, mainBundle_init);
  return __mainBundle;
}

+ (NSArray *)allBundles
{ // ms_shared_object_iterate
  NSArray *bundles;
  mtx_lock(&__mutex);
  _refreshIfNeeded();
  bundles= AUTORELEASE(CCreateArrayOfDictionaryObjects(__bundleByPath));
  mtx_unlock(&__mutex);
  return bundles;
}

+ (NSArray *)allFrameworks
{
  NSArray *frameworks;
  mtx_lock(&__mutex);
  _refreshIfNeeded();
  frameworks= [NSArray arrayWithArray:(id)__frameworks];
  mtx_unlock(&__mutex);
  return frameworks;
}

+ (NSBundle *)bundleWithIdentifier:(NSString *)identifier
{
  NSBundle *bundle;
  mtx_lock(&__mutex);
  _refreshIfNeeded();
  bundle= CDictionaryObjectForKey(__bundleByIds, identifier);
  mtx_unlock(&__mutex);
  return bundle;
}
+ (NSBundle *)bundleForClass:(Class)aClass
{
  NSBundle *bundle;
  const char *name= ms_shared_object_name(aClass);
  //printf("bundleForClass %s %p\n", name, aClass);
  mtx_lock(&__mutex);
  _refreshIfNeeded();
  bundle= CDictionaryObjectForKey(__bundleByExePath, [NSString stringWithUTF8String:name]);
  mtx_unlock(&__mutex);
  //printf("bundle %s\n", [[bundle executablePath] UTF8String]);
  return bundle;
}

// self can be nil, path can be relative, exepath can be nil
static NSBundle* _init(NSBundle *self, NSString *path, NSString *exepath)
{
  id bundle; BOOL ok= YES;
  path= _absolutepath(path);
  ok= path != nil;
  if (ok && exepath && !(exepath= _absolutepath(exepath))) {
    NSLog(@"provided exepath is considered invalid, this should never happen");
    ok= NO;}
  if (ok) {
    //NSLog(@"%p path=%@ exepath=%@", self, path, exepath);
    mtx_lock(&__mutex);
    bundle= CDictionaryObjectForKey(__bundleByPath, path);
    mtx_unlock(&__mutex);
    if (bundle) {
      RELEASE(self);
      self= RETAIN(bundle);}
    else {
      id basePath= path; id identifier; uint32_t type; BOOL loaded= NO, framework= NO;

      if ([@"framework" isEqualToString:[path pathExtension]]) {
        framework= YES;
        type= TYPE_FRAMEWORK;}
      else if (exepath) {
        type= TYPE_EXE;}
      else {
        basePath= [path stringByAppendingPathComponent:@"Contents"];
        type= TYPE_BUNDLE;}

      if (!exepath) {
#       if defined(LINUX)
          exepath= FMT(@"lib%@.so", [[path lastPathComponent] stringByDeletingPathExtension]);
#       elif defined(WIN32)
          exepath= [[[path lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"dll"];
#       elif defined(APPLE)
          exepath= [[path lastPathComponent] stringByDeletingPathExtension];
#       else
#         error Unsupported plaform
#       endif
        exepath= [basePath stringByAppendingPathComponent:exepath];
        exepath= _absolutepath(exepath);
      }
      else {
        loaded= YES;}

      if (exepath) {
        if (!self)
          self= [NSBundle new];
        mtx_init(&self->_mutex, mtx_plain);
        self->_type= type;
        self->_state= loaded ? 2 : 0;
        self->_path= [path retain];
        self->_rscPath= [[basePath stringByAppendingPathComponent:@"Resources"] retain];
        self->_exepath= [exepath retain];
        self->_info= [[NSDictionary dictionaryWithContentsOfFile:[basePath stringByAppendingPathComponent:@"Info.plist"]] retain];
        if (!self->_info)
          self->_info= (id)CCreateDictionary(0);
        mtx_lock(&__mutex);
        if (framework)
          CArrayAddObject(__frameworks, self);
        CDictionarySetObjectForKey(__bundleByExePath, self, self->_exepath);
        CDictionarySetObjectForKey(__bundleByPath, self, self->_path);
        if ((identifier= [self bundleIdentifier]))
          CDictionarySetObjectForKey(__bundleByIds, self, identifier);
        mtx_unlock(&__mutex);
      }
      else { ok= NO; }
    //printf("new bundle path=%s rscPath=%s exepath=%s\n", [_path UTF8String], [_rscPath UTF8String], [_exepath UTF8String]);
    }
  }
  if (!ok) DESTROY(self);
  return self;
}

static NSBundle * _createBundleWithExePath(NSString *exepath, BOOL isMainExe)
{
  NSBundle *bundle; NSString *path, *name, *pathExtension;
  if (![exepath length]) return nil;
  mtx_lock(&__mutex);
  bundle= CDictionaryObjectForKey(__bundleByExePath, exepath);
  mtx_unlock(&__mutex);
  if (!bundle) {
      name= [[exepath lastPathComponent] stringByDeletingPathExtension];
#   ifdef WIN32
      pathExtension= [exepath pathExtension];
      if ([@"dll" isEqual:pathExtension]) { // It's a framework
        path= [exepath stringByDeletingLastPathComponent]; // /bin
        path= [path stringByDeletingLastPathComponent]; // /
        path= [path stringByAppendingPathComponent:[NSString stringWithFormat:@"framework/%@.framework", name]]; // framework/NAME.framework
        if ([[NSFileManager defaultManager] isReadableFileAtPath:path]) { // Framework found
          bundle= _init(nil, path, exepath);}}
#   else
      path= [exepath stringByDeletingLastPathComponent];
      if ([[path lastPathComponent] hasSuffix:@".framework"]) { // Framework found
        bundle= _init(nil, path, exepath);}
#   endif
    if (!bundle && isMainExe) { // it's the main exe
      bundle= _init(nil, exepath, exepath);}}
  else { [bundle retain]; }
  return bundle;
}

+ (NSBundle *)bundleWithPath:(NSString *)path
{
  return [_init(nil, path, nil) autorelease];
}
- (instancetype)initWithPath:(NSString *)path
{
  return _init(self, path, nil);
}
- (instancetype)_initWithPath:(NSString *)path exepath:(NSString *)exepath
{
  return _init(self, path, exepath);
}

- (BOOL)load
{
  mtx_lock(&_mutex);
  if (!_state)
  {
    mtx_lock(&__mutex);
    ms_shared_object_t handle= ms_shared_object_open([_exepath UTF8String]);
    __refresh= YES; // bundle list must be refresh in case some framework where loaded
    _state = handle ? 2 : 1;
    mtx_unlock(&__mutex);
  }
  mtx_unlock(&_mutex);
  return _state == 2;
}
- (BOOL)isLoaded{ return _state == 2; }
- (BOOL)unload{ return NO; }

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)bundlePath
{ return [[self mainBundle] pathForResource:name ofType:ext inDirectory:bundlePath]; }
+ (NSArray *)pathsForResourcesOfType:(NSString *)ext inDirectory:(NSString *)bundlePath
{ return [[self mainBundle] pathsForResourcesOfType:ext inDirectory:bundlePath]; }
- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext
{
  id path= [_rscPath stringByAppendingPathComponent:[name stringByAppendingPathExtension:ext]];
  //printf("pathForResource > %s %s %s %s\n",[name UTF8String], [ext UTF8String], [[name stringByAppendingPathExtension:ext] UTF8String], [path UTF8String]);
  return [[NSFileManager defaultManager] isReadableFileAtPath:path] ? path : nil;
}
- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)bundlePath
{
  id path= [_rscPath stringByAppendingPathComponent:[[bundlePath stringByAppendingPathComponent:name] stringByAppendingPathExtension:ext]];
  return [[NSFileManager defaultManager] isReadableFileAtPath:path] ? path : nil;
}
- (NSArray *)pathsForResourcesOfType:(NSString *)ext inDirectory:(NSString *)bundlePath
{
  NSDirectoryEnumerator *e; CArray *arr; id basePath, o;
  arr= CCreateArray(0);
  basePath= [_rscPath stringByAppendingPathComponent:bundlePath];
  e= [[NSFileManager defaultManager] enumeratorAtPath:basePath];
  [e skipDescendents];
  while ((o= [e nextObject])) {
    if ([ext isEqualToString:[o pathExtension]])
      CArrayAddObject(arr, [basePath stringByAppendingPathComponent:o]);}
  return AUTORELEASE(arr);
}

- (NSString *)bundleIdentifier
{ return [[self infoDictionary] objectForKey:@"CFBundleIdentifier"]; }
- (NSString *)bundlePath
{ return _path; }
- (NSString *)resourcePath
{ return _rscPath; }
- (NSString *)executablePath
{ return _exepath; }

- (NSDictionary *)infoDictionary
{
  [self load];
  return _info;
}
- (NSDictionary *)localizedInfoDictionary
{ return _info; }
- (id)objectForInfoDictionaryKey:(NSString *)key
{ return [_info objectForKey:key]; }
- (Class)classNamed:(NSString *)className
{
  [self load];
  return NSClassFromString(className);
}
- (Class)principalClass
{
  Class cls= NSClassFromString([[self infoDictionary] objectForKey:@"NSPrincipalClass"]);
  if (!cls) {
    // TODO: Find the first class in the bundle
    // so the program can work with undefined bahavior do to randomness in class order :(
  }
  return cls;
}
@end

// Utilities

static NSString *_absolutepath(NSString *path)
{
  id ret= nil;
  if (![path length]) { return nil; }
  if (![path isAbsolutePath]) {
    path= [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:path]; }
# ifdef WIN32
  {
    CBuffer *buf= CCreateBuffer(0); unichar end= 0; unichar result[MAX_PATH + 1]; DWORD len;
    CBufferAppendSES(buf, SESFromString(path), NSUnicodeStringEncoding);
    CBufferAppendBytes(buf, &end, sizeof(unichar));
    len= GetFullPathNameW((unichar*)CBufferBytes(buf), MAX_PATH, result, NULL);
    if (len > 0 && len <= MAX_PATH) {
      ret= AUTORELEASE(CCreateStringWithBytes(NSUnicodeStringEncoding, result, len));}
  }
# else
  {
    char result[PATH_MAX];
    if (realpath([path UTF8String], result) == result) {
      ret= [NSString stringWithUTF8String:result];}
  }
# endif
  return ret;
}

#import "FoundationCompatibility_Private.h"

enum {
  TYPE_UNKNOWN= 0,
  TYPE_EXE,
  TYPE_FRAMEWORK,
  TYPE_BUNDLE
};
@interface NSBundle (Private)
- (instancetype)_initWithPath:(NSString *)path exePath:(NSString *)exePath;
@end

once_flag __mainBundle_once = ONCE_FLAG_INIT;
static mtx_t __mutex;
static BOOL __refresh= YES;
static CArray *__frameworks= NULL;
static CDictionary *__bundleByIds= NULL;
static CDictionary *__bundleByPath= NULL;
static CDictionary *__bundleByExePath= NULL;
static NSBundle *__mainBundle = nil;

static NSBundle * _bundleWithExePath(NSString *exepath, BOOL isMainExe);
static void mainBundle_init();
static void _bundleIterator(const char *name, void *data);

static void mainBundle_init() {
  const char *utf8Path;
  CString *path;

  utf8Path= ms_get_current_process_path();
  path= CCreateStringWithBytes(NSUTF8StringEncoding, utf8Path, strlen(utf8Path));
  __mainBundle= _bundleWithExePath((NSString*)path, YES);
}
static void _bundleIterator(const char *name, void *data)
{
  _bundleWithExePath([NSString stringWithUTF8String:name], NO);
}
static void _refreshIfNeeded()
{
  call_once(&__mainBundle_once, mainBundle_init);
  if (__refresh) {
    ms_shared_object_iterate(_bundleIterator, NULL);
  }
}

@implementation NSBundle 
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
+ (NSBundle *)bundleWithPath:(NSString *)path
{ return [[ALLOC(NSBundle) initWithPath:path] autorelease]; }
- (instancetype)initWithPath:(NSString *)path 
{ 
  if (![path length]) {
    DESTROY(self);}
  else if (![path isAbsolutePath]) {
    path= [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:path];
#   ifdef WIN32
    {
      CBuffer *buf= CCreateBuffer(0); unichar end= 0; unichar result[MAX_PATH + 1]; DWORD len;
      CBufferAppendSES(buf, SESFromString(path), NSUnicodeStringEncoding);
      CBufferAppendBytes(buf, &end, sizeof(unichar));
      len= GetFullPathNameW((unichar*)CBufferBytes(buf), MAX_PATH, result, NULL);
      if (len > 0 && len <= MAX_PATH) {
        path= AUTORELEASE(CCreateStringWithBytes(NSUnicodeStringEncoding, result, len));}
      else {
        DESTROY(self);}
    }
#   else
    {
      char result[PATH_MAX];
      if (realpath([path UTF8String], result) == result) {
        path= [NSString stringWithUTF8String:result];}
      else {
        DESTROY(self);}
    }
#   endif
  }
  return [self _initWithPath:[NSString pathWithComponents:[path pathComponents]] exePath:nil];
}
- (instancetype)_initWithPath:(NSString *)path exePath:(NSString *)exePath
{
  id bundle;
  mtx_lock(&__mutex);
  bundle= CDictionaryObjectForKey(__bundleByPath, path);
  mtx_unlock(&__mutex);
  if (bundle) {
    [self release];
    self= bundle;}
  else if ((self= [super init])) {
    id basePath= path; id identifier;
    mtx_init(&_mutex, mtx_plain);
    _path= [path retain];
    
    if ([@"framework" isEqualToString:[path pathExtension]]) {
      CArrayAddObject(__frameworks, self);
      _type= TYPE_FRAMEWORK;}
    else if (exePath) {
      _type= TYPE_EXE;}
    else {
      basePath= [path stringByAppendingPathComponent:@"Contents"];
      _type= TYPE_BUNDLE;}

    if (!exePath) {
      exePath= [basePath stringByAppendingPathComponent:[[path lastPathComponent] stringByDeletingPathExtension]];
#     ifdef WIN32
        exePath= [exePath stringByAppendingPathExtension:@"dll"];
#     endif
    }
    else {
      _state= 2;}
    _rscPath= [[basePath stringByAppendingPathComponent:@"Resources"] retain];
    _exePath= [exePath retain];
    _info= [[NSDictionary dictionaryWithContentsOfFile:[basePath stringByAppendingPathComponent:@"Info.plist"]] retain];
    if (!_info)
      _info= (id)CCreateDictionary(0);
    mtx_lock(&__mutex);
    CDictionarySetObjectForKey(__bundleByExePath, self, _exePath);
    CDictionarySetObjectForKey(__bundleByPath, self, _path);
    if ((identifier= [self bundleIdentifier])) 
      CDictionarySetObjectForKey(__bundleByIds, self, identifier);
    mtx_unlock(&__mutex);
    //printf("new bundle path=%s rscPath=%s exePath=%s\n", [_path UTF8String], [_rscPath UTF8String], [_exePath UTF8String]);
  }
  return self;
}
static NSBundle * _bundleWithExePath(NSString *exepath, BOOL isMainExe)
{
  NSBundle *bundle; NSString *path, *name, *pathExtension;
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
          bundle= [ALLOC(NSBundle) _initWithPath:path exePath:exepath];}}
#   else
      path= [exepath stringByDeletingLastPathComponent];
      if ([[path lastPathComponent] hasSuffix:@".framework"]) { // Framework found
        bundle= [ALLOC(NSBundle) _initWithPath:path exePath:exepath];}
#   endif
    if (!bundle && isMainExe) { // it's the main exe
      bundle= [ALLOC(NSBundle) _initWithPath:exepath exePath:exepath];}}
  return bundle;
}

- (BOOL)load
{
  mtx_lock(&_mutex);
  if (!_state) 
  {
    mtx_lock(&__mutex);
    ms_shared_object_t handle= ms_shared_object_open([_exePath UTF8String]);
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
{ return _exePath; }

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
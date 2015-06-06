#import "FoundationCompatibility_Private.h"

NSString *NSTaskDidTerminateNotification= @"NSTaskDidTerminateNotification";

@implementation NSTask
+ (NSTask *)launchedTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments
{
  NSTask *task= [NSTask new];
  [task setLaunchPath:path];
  [task setArguments:arguments];
  [task launch];
  return [task autorelease];
}
- (instancetype)init
{
  cnd_init(&_cnd);
  return self;
}
- (void)dealloc
{
  cnd_destroy(&_cnd);
  [_arguments release];
  [_currentDirectoryPath release];
  [_env release];
  [_launchPath release];
  if(_uv_process)
    free(_uv_process + sizeof(uv_process_t));
  free(_uv_process);
  *(id*)(_uv_process + sizeof(id))= nil;
  [super dealloc];
}

- (NSArray *)arguments
{ return _arguments; }
- (void)setArguments:(NSArray *)arguments
{ ASSIGN(_arguments, arguments); }


- (NSString *)currentDirectoryPath
{ return _currentDirectoryPath; }
- (void)setCurrentDirectoryPath:(NSString *)currentDirectoryPath
{ ASSIGN(_currentDirectoryPath, currentDirectoryPath); }

- (NSDictionary *)environment
{ return _env ? _env : [[NSProcessInfo processInfo] environment]; }
- (void)setEnvironment:(NSDictionary *)env
{ ASSIGN(_env, env); }


- (NSString *)launchPath
{ return _launchPath; }
- (void)setLaunchPath:(NSString *)launchPath
{ ASSIGN(_launchPath, launchPath); }


- (int)processIdentifier
{ return _uv_process ? ((uv_process_t*)_uv_process)->pid : 0; }

- (void)interrupt
{
  uv_process_kill((uv_process_t*)_uv_process, SIGINT);
}

static void exit_cb(uv_process_t* process, int64_t exit_status, int term_signal) 
{
  [*(NSTask**)(process + sizeof(id)) _exitedWithStatus:exit_status signal:term_signal];
  uv_close((uv_handle_t*)process, close_cb);
}
void close_cb(uv_handle_t *handle) {
  free(handle);
}

- (void)_exitedWithStatus:(int64_t)exit_status signal:(int)term_signal
{
  _uv_process= NULL;
  [[NSNotificationCenter defaultCenter] postNotificationName:NSTaskDidTerminateNotification object:self];
  [[NSRunLoop currentRunLoop] _uv_stop];
}

- (void)launch
{
  int envCount= [_env count];
  int argsCount= [_arguments count];
  char *env[envCount + 1];
  char *args[argsCount + 1];
  uv_process_options_t options;
  memset(&options, 0, sizeof(options));

  while(argsCount > 0) {
    --argsCount;
    args[argsCount]= (char *)[[_arguments objectAtIndex:argsCount] UTF8String];
  }

  if(_env) {
    NSEnumerator *e; id o, k; NSUInteger i= 0;
    for(e= [_env keyEnumerator]; (k= [e nextObject]) && (o= [_env objectForKey:k]);) {
      env[i++]= (char *)[[NSString stringWithFormat:@"%@=%@", k, o] UTF8String];
    }
  }
  args[argsCount]= NULL;
  env[envCount]= NULL;
  options.exit_cb= exit_cb;
  options.file= [_launchPath UTF8String];
  options.env= env;
  options.args= args;
  options.cwd= [_currentDirectoryPath UTF8String];
  _uv_process= malloc(sizeof(uv_process_t) + sizeof(id));
  *(id*)(_uv_process + sizeof(id))= self;
  uv_spawn([[NSRunLoop currentRunLoop] _uv_loop], (uv_process_t*)_uv_process, &options);
}

- (BOOL)resume
{
#ifdef WIN32
  return NO;
#else
  return uv_process_kill((uv_process_t*)_uv_process, SIGCONT) == 0;
#endif
}

- (BOOL)suspend
{
#ifdef WIN32
  return NO;
#else
  return uv_process_kill((uv_process_t*)_uv_process, SIGSTOP) == 0;
#endif
}

- (void)terminate
{
  uv_process_kill((uv_process_t*)_uv_process, SIGKILL);
}

- (void)waitUntilExit
{
  if(_uv_process) {
    [[NSRunLoop currentRunLoop] _uv_run];
  }
}

- (BOOL)isRunning
{ return _uv_process != NULL; }
- (int)terminationStatus
{ return _exitStatus; }
@end
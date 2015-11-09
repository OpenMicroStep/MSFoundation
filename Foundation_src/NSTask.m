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
  return self;
}
- (void)dealloc
{
  [_arguments release];
  [_currentDirectoryPath release];
  [_env release];
  [_launchPath release];
  MSFree(_uv_process, "-[NSTask launch] -> -[NSTask dealloc]");
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
  NSTask *self= CArrayObjectAtIndex((CArray*)process->data, 0);
  [self _exitedWithStatus:exit_status signal:term_signal];
  RELEASE(process->data);
  uv_close((uv_handle_t*)process, close_cb);
}
void close_cb(uv_handle_t *handle) {
  free(handle);
}

- (void)_exitedWithStatus:(int64_t)exit_status signal:(int)term_signal
{
  _exitStatus= (int)exit_status;
  _uv_process= NULL;
  [[NSNotificationCenter defaultCenter] postNotificationName:NSTaskDidTerminateNotification object:self];
  [[NSRunLoop currentRunLoop] _uv_stop];
}

static const * retainedUTF8String(CArray *retainlist, NSString *str)
{
  id d= [str dataUsingEncoding:NSUTF8StringEncoding];
  if (d) CArrayAddObject(retainlist, d);
  return [d cString];
}
- (void)launch
{
  CArray *retainlist; id d;
  NSUInteger idx;
  NSUInteger envCount= [_env count];
  NSUInteger argsCount= [_arguments count];
  char *env[envCount + 1];
  char *args[argsCount + 2];
  uv_process_t* process;
  uv_process_options_t options;
  memset(&options, 0, sizeof(options));
  retainlist= CCreateArray(0);
  CArrayAddObject(retainlist, self);
  args[0]= retainedUTF8String(retainlist, _launchPath);
  for(idx= 0; idx < argsCount; ++idx) {
    args[idx + 1]= retainedUTF8String(retainlist, [_arguments objectAtIndex:idx]);
  }

  if(_env) {
    NSEnumerator *e; id o, k;
    for(idx= 0, e= [_env keyEnumerator]; (k= [e nextObject]) && (o= [_env objectForKey:k]);) {
      env[idx++]= retainedUTF8String(retainlist, FMT(@"%@=%@", k, o));
    }
  }
  args[argsCount + 1]= NULL;
  env[envCount]= NULL;
  options.exit_cb= exit_cb;
  options.file= args[0];
  options.env= env;
  options.args= args;
  options.cwd= retainedUTF8String(retainlist, _currentDirectoryPath);
  process= MSMalloc(sizeof(uv_process_t) + sizeof(id), "-[NSTask launch] -> -[NSTask dealloc]");
  process->data= retainlist;
  _uv_process= process;
  if (uv_spawn([[NSRunLoop currentRunLoop] _uv_loop], process, &options) != 0) {
    RELEASE(process->data);
    MSFree(process, "-[NSTask launch] -> -[NSTask dealloc]");
    _uv_process= NULL;
    MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"unable to start the task") ;
  }
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
    while ([[NSRunLoop currentRunLoop] _uv_run] && _uv_process);
  }
}

- (BOOL)isRunning
{
  return _uv_process != NULL;
}
- (int)terminationStatus
{
  if (_uv_process)
    MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"the task is still running") ;
  return _exitStatus;
}
@end
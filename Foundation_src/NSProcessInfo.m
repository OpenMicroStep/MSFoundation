#import "FoundationCompatibility_Private.h"

static once_flag __processInfoOnce = ONCE_FLAG_INIT;
static NSProcessInfo *__processInfo;
static void __processInfoInit() {
  __processInfo= [NSProcessInfo new];
}

#ifdef APPLE
#define HOST_NAME_MAX sysconf(_SC_HOST_NAME_MAX)
#endif

#ifdef WIN32
#define HOST_NAME_MAX 256
#endif

#ifdef UNIX
extern char **environ;
#endif

@implementation NSProcessInfo 

+ (NSProcessInfo *)processInfo
{
  call_once(&__processInfoOnce, __processInfoInit);
  return __processInfo;
}

- (instancetype)init
{
  _processName= [[NSString stringWithUTF8String:ms_get_current_process_path()] lastPathComponent];
  return self;
}
- (void)dealloc
{
  [_processName release];
  [super dealloc];
}

- (NSArray *)arguments
{
  // linux: /proc/self/cmdline
  // osx: KERN_PROCARGS2
  // windows: GetCommandLine
  return [self notImplemented:_cmd];
}

- (NSDictionary *)environment
{
  CDictionary *env; CString *key, *value;
  env= CCreateDictionary(0);

#ifdef WIN32
  {
    CString *s; unichar u, *str, *pos;
    pos= str= GetEnvironmentStringsW();
    do {
      key= CCreateString(0);
      value= CCreateString(0);
      s= key;
      while ((u= *(pos++))) {
        if(u == '=')
          s= value;
        else
          CStringAppendCharacter(s, u);
      }
      CDictionarySetObjectForKey(env, (id)value, (id)key);
      RELEASE(value);
      RELEASE(key);
    } while(*pos);
    FreeEnvironmentStringsW(str);
  }
#else
  {
    char **e= environ;
    while(*e) {
      NSUInteger pos; unichar u; CString *s; SES ses;
      key= CCreateString(0);
      value= CCreateString(0);
      s= key;
      ses= MSMakeSESWithBytes(*e, strlen(*e), NSUTF8StringEncoding);
      for(pos= SESStart(ses); pos < SESEnd(ses);) {
        u= SESIndexN(ses, &pos);
        if(u == '=')
          s= value;
        else
          CStringAppendCharacter(s, u);
      }
      CDictionarySetObjectForKey(env, (id)value, (id)key);
      RELEASE(value);
      RELEASE(key);
      ++e;
    }
  }
#endif

  return AUTORELEASE(env);
}

- (NSString *)globallyUniqueString
{
  return AUTORELEASE(CCreateStringWithGeneratedUUID());
}

- (NSString *)hostName
{
  char hn[HOST_NAME_MAX];
  gethostname(hn, sizeof(hn));
  return [NSString stringWithUTF8String:hn];
}

- (unsigned int)operatingSystem
{
  [self notImplemented:_cmd];
  return 0;
}

- (NSString *)operatingSystemName
{
  return [self notImplemented:_cmd];
}

- (NSString *)processName
{
  return _processName;
}
- (void)setProcessName:(NSString *)newName
{
  ASSIGN(_processName, newName);
}
@end
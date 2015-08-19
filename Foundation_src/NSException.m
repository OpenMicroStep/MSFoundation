#import "FoundationCompatibility_Private.h"

NSString * const NSGenericException= @"NSGenericException";
NSString * const NSRangeException= @"NSRangeException";
NSString * const NSInvalidArgumentException= @"NSInvalidArgumentException";
NSString * const NSInternalInconsistencyException= @"NSInternalInconsistencyException";

NSString * const NSMallocException= @"NSMallocException";

NSString * const NSObjectInaccessibleException= @"NSObjectInaccessibleException";
NSString * const NSObjectNotAvailableException= @"NSObjectNotAvailableException";
NSString * const NSDestinationInvalidException= @"NSDestinationInvalidException";

#ifdef WIN32
MS_DECLARE_THREAD_LOCAL(__topExceptionFrame, NULL)
#endif

@implementation NSException

+ (NSException *)exceptionWithName:(NSString *)name reason:(NSString *)reason userInfo:(NSDictionary *)userInfo
{
  return AUTORELEASE([ALLOC(self) initWithName:name reason:reason userInfo:userInfo]);
}

- (instancetype)initWithName:(NSString *)name reason:(NSString *)reason userInfo:(NSDictionary *)userInfo
{
  _name= [name retain];
  _reason= [reason retain];
  _userInfo= [userInfo retain];
  return self;
}

- (NSString *)name         { return _name;}
- (NSString *)reason       { return _reason; }
- (NSDictionary *)userInfo { return _userInfo; }

- (NSArray *)callStackReturnAddresses
{
  return [self notYetImplemented:_cmd];
}
- (NSArray *)callStackSymbols
{
  return [self notYetImplemented:_cmd];
}

- (void)raise
{
#ifdef WIN32
  NSExceptionFrame *top= tss_get(__topExceptionFrame);
  if (top) {
    top->exception= self;
    longjmp(top->state, 1);}
  else {
    abort();}
#else
  @throw self;
#endif
}

+ (void)raise:(NSString *)name format:(NSString *)format, ...
{
  va_list va;
  va_start(va, format);
  [self raise:name format:format arguments:va];
}

+ (void)raise:(NSString *)name format:(NSString *)format arguments:(va_list)argList
{
  [[self exceptionWithName:name reason:AUTORELEASE([ALLOC(NSString) initWithFormat:format arguments:argList]) userInfo:nil] raise];
}

@end

#ifdef WIN32 // win32 exception aren't working yet, falling back to longjmp, badly taken from cocotron
void __NSPushExceptionFrame(NSExceptionFrame *frame)
{
  NSExceptionFrame *top= tss_get(__topExceptionFrame);
  frame->parent= top;
  frame->exception= nil;
  tss_set(__topExceptionFrame, frame);
}
void __NSPopExceptionFrame(NSExceptionFrame *frame)
{
  tss_set(__topExceptionFrame, frame->parent);
}
#endif
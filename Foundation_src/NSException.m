#import "FoundationCompatibility_Private.h"

NSString * const NSGenericException= @"NSGenericException";
NSString * const NSRangeException= @"NSRangeException";
NSString * const NSInvalidArgumentException= @"NSInvalidArgumentException";
NSString * const NSInternalInconsistencyException= @"NSInternalInconsistencyException";

NSString * const NSMallocException= @"NSMallocException";

NSString * const NSObjectInaccessibleException= @"NSObjectInaccessibleException";
NSString * const NSObjectNotAvailableException= @"NSObjectNotAvailableException";
NSString * const NSDestinationInvalidException= @"NSDestinationInvalidException";

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
  @throw self;
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

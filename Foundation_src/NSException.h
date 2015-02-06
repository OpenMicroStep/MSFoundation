
/***************	Generic Exception names		***************/

FoundationExtern NSString * const NSGenericException;
FoundationExtern NSString * const NSRangeException;
FoundationExtern NSString * const NSInvalidArgumentException;
FoundationExtern NSString * const NSInternalInconsistencyException;

FoundationExtern NSString * const NSMallocException;

FoundationExtern NSString * const NSObjectInaccessibleException;
FoundationExtern NSString * const NSObjectNotAvailableException;
FoundationExtern NSString * const NSDestinationInvalidException;

@interface NSException : NSObject <NSCopying, NSCoding> {
    @private
    NSString		*_name;
    NSString		*_reason;
    NSDictionary	*_userInfo;
    id			reserved;
}

+ (NSException *)exceptionWithName:(NSString *)name reason:(NSString *)reason userInfo:(NSDictionary *)userInfo;
- (instancetype)initWithName:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;

- (NSString *)name;
- (NSString *)reason;
- (NSDictionary *)userInfo;

- (NSArray *)callStackReturnAddresses;
- (NSArray *)callStackSymbols;

- (void)raise;

@end

@interface NSException (NSExceptionRaisingConveniences)

+ (void)raise:(NSString *)name format:(NSString *)format, ...;
+ (void)raise:(NSString *)name format:(NSString *)format arguments:(va_list)argList;

@end

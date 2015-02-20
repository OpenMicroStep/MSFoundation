
#ifdef WO451
#define NS_REQUIRES_NIL_TERMINATION
#define NS_FORMAT_FUNCTION(X,Y)
#define NSLocaleDecimalSeparator NSDecimalSeparator

MSFoundationExport IMP method_getImplementation(Method m);
MSFoundationExport NSString *MSFindDLL(NSString *dllName) ;
MSFoundationExport HINSTANCE MSLoadDLL(NSString *dllName) ;
MSFoundationExport NSUInteger MSOperatingSystem(void) ;

enum {
  NSUnknownOperatingSystem=               0,
  NSWindowsNT351OperatingSystem=        100,
  NSWindowsNT4OperatingSystem=          101,
  NSWindows98OperatingSystem=           102,
  NSWindowsMeOperatingSystem=           103,
  NSWindows2000OperatingSystem=         104,
  NSWindowsXPOperatingSystem=           105,
  NSWindowsServer2003OperatingSystem=   106,
  NSWindowsVistaOperatingSystem=        107,
  NSWindowsServer2008OperatingSystem=   108,
  NSWindowsSevenOperatingSystem=        109,
  NSWindowsServer2008R2OperatingSystem= 110,
  NSLinuxOperatingSystem=               200,
  NSCheetahOperatingSystem=             300, // 10.0
  NSPumaOperatingSystem=                301, // 10.1
  NSJaguarOperatingSystem=              302, // 10.2
  NSPantherOperatingSystem=             303, // 10.3
  NSTigerOperatingSystem=               304, // 10.4
  NSLeopardOperatingSystem=             305, // 10.5
  NSSnowLeopardOperatingSystem=         306, // 10.6
  NSLionOperatingSystem=                307  // 10.7
} ;

@interface NSUUID : NSObject <NSCopying, NSCoding>
+ (NSUUID *)UUID;
- (NSString *)UUIDString;
@end

@interface NSNull : NSObject <NSCopying, NSCoding>
+ (NSNull *)null;
@end

@interface NSString (MSCompatibilityLayer)
+ (id)stringWithCString:(const char *)cString encoding:(NSStringEncoding)enc;
- (id)initWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding;
@end

@interface NSArray (MSCompatibilityLayer)
- (id)firstObject;
@end

@interface NSNumber (MSCompatibilityLayer)
+ (NSNumber *)numberWithUnsignedInteger:(NSUInteger)value;
@end

@interface NSError : NSObject <NSCopying, NSCoding>
@end
#endif

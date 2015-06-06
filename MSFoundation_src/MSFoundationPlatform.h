
#ifndef MSFOUNDATION_FORCOCOA
enum {
  NSUnknownOperatingSystem=               0,
  NSWindowsNT351OperatingSystem=        100,
  NSWindowsNT4OperatingSystem=          101,
  NSWindows95OperatingSystem=           102,
  NSWindows98OperatingSystem=           103,
  NSWindowsMeOperatingSystem=           104,
  NSWindows2000OperatingSystem=         105,
  NSWindowsXPOperatingSystem=           106,
  NSWindowsServer2003OperatingSystem=   107,
  NSWindowsVistaOperatingSystem=        108,
  NSWindowsServer2008OperatingSystem=   109,
  NSWindowsSevenOperatingSystem=        110,
  NSWindowsServer2008R2OperatingSystem= 111,
  NSLinuxOperatingSystem=               200,
  NSCheetahOperatingSystem=             300, // 10.0
  NSPumaOperatingSystem=                301, // 10.1
  NSJaguarOperatingSystem=              302, // 10.2
  NSPantherOperatingSystem=             303, // 10.3
  NSTigerOperatingSystem=               304, // 10.4
  NSLeopardOperatingSystem=             305, // 10.5
  NSSnowLeopardOperatingSystem=         306, // 10.6
  NSLionOperatingSystem=                307  // 10.7
};
#endif

#ifdef WO451
#define NS_REQUIRES_NIL_TERMINATION
#define NS_FORMAT_FUNCTION(X,Y)
#define NSLocaleDecimalSeparator NSDecimalSeparator

MSFoundationExtern IMP method_getImplementation(Method m);
MSFoundationExtern NSString *MSFindDLL(NSString *dllName);
MSFoundationExtern NSUInteger MSOperatingSystem(void);

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

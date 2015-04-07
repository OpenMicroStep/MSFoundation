//
//  MSFoundationPlatform.m
//  MSFoundation
//
//  Created by Vincent Rouillé on 19/02/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#import "MSFoundation_Private.h"

#ifdef WO451
static NSNull *__singletonNSNull = nil ;

@implementation NSNull
+ (void)load{ __singletonNSNull= MSCreateObject(self); }
+ (BOOL)supportsSecureCoding{ return YES; }

+ (id)new { return __singletonNSNull ; }
+ (id)allocWithZone:(NSZone *)zone { return __singletonNSNull ; }
+ (id)alloc { return __singletonNSNull ; }
+ (NSNull *)null{ return __singletonNSNull; }

- (id)copyWithZone:(NSZone *)zone { return __singletonNSNull ; }

- (void)encodeWithCoder:(NSCoder *)aCoder {}
- (id)initWithCoder:(NSCoder *)aDecoder { return __singletonNSNull ; }

- (oneway void)release {}
- (id)autorelease { return __singletonNSNull ;}
- (id)retain { return __singletonNSNull ; }
@end

@implementation NSArray (MSCompatibilityLayer)
- (id)firstObject
{
  return [self count] ? [self objectAtIndex:0] : nil;
}
@end

@implementation NSString (MSCompatibilityLayer)
+ (id)stringWithCString:(const char *)cString encoding:(NSStringEncoding)enc {
  return [[self alloc] initWithCString:cString encoding:enc];
}
- (id)initWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding {
  return [self initWithData:[NSData dataWithBytes:nullTerminatedCString length:strlen(nullTerminatedCString)] encoding:encoding];
}

typedef id (*NSPlaceholderString_defimp_initWithFormatType)(id, SEL, NSString*, NSDictionary*, va_list);
static NSPlaceholderString_defimp_initWithFormatType NSPlaceholderString_defimp_initWithFormat = NULL;
static id NSPlaceholderString_myimp_initWithFormat(id self, SEL _cmd, NSString*format, NSDictionary* dict, va_list argList)
{
  id returnValue;
  NSString *replacement;
  NSMutableString *newFormat;
  NSRange range;
  unsigned int pos, length, markerCount;
  unichar c;
  
  newFormat = nil;
  length = [format length];
  range = [format rangeOfString:@"%"];
  while(range.length > 0) {
    pos = range.location;
    markerCount = 0;
    while(++pos < length && [format characterAtIndex:pos] == '%')
      ++markerCount;
    if(markerCount % 2 == 0) {
      c = '\0';
      while(pos < length) {
        c = [format characterAtIndex:pos];
        if((c == '%') || ('A' <= c && c <= 'Z') || ('a' <= c && c <= 'z'))
          break;
        ++pos;
      }
      if(pos + 2 < length && c == 'l' && [format characterAtIndex:pos + 1] == 'l') {
        c = [format characterAtIndex:pos + 2];
        if(c == 'd' || c == 'i')
          replacement = @"qd%.0s";
        else if(c == 'u' || c == 'o' || c == 'x' || c == 'X')
          replacement = @"qu%.0s";
        else
          replacement = nil;
        if(replacement) {
          if(!newFormat)
            newFormat = [format mutableCopy];
          range.location = pos;
          range.length = 3;
          [newFormat replaceCharactersInRange:range withString:replacement];
          format = newFormat;
          length += 3;
        }
      }
    
    }
    range.length = length - ++range.location;
    range = [format rangeOfString:@"%" options:0 range:range];
  }
  returnValue = NSPlaceholderString_defimp_initWithFormat(self, _cmd, format, dict, argList);
  [newFormat release];
  return returnValue;
}

+ (void)load
{
  Method defMethod;
  Class placeholderStringClass;
  
  placeholderStringClass = NSClassFromString(@"NSPlaceholderString");
  if(placeholderStringClass) {
    defMethod = class_getInstanceMethod(placeholderStringClass, @selector(initWithFormat:locale:arguments:));
    if(!defMethod)
      printf("-[NSPlaceholderString initWithFormat:locale:arguments:] isn't fixed, unexpected behavior may occur due to: -[NSPlaceholderString initWithFormat:locale:arguments:] not found\n");
    else {
      NSPlaceholderString_defimp_initWithFormat = (NSPlaceholderString_defimp_initWithFormatType)defMethod->method_imp;
      defMethod->method_imp = (IMP)NSPlaceholderString_myimp_initWithFormat;
    }
  }
  else {
    printf("-[NSPlaceholderString initWithFormat:locale:arguments:] isn't fixed, unexpected behavior may occur due to: NSPlaceholderString not found\n");
  }
}
@end

@implementation NSNumber (MSCompatibilityLayer)
+ (NSNumber *)numberWithUnsignedInteger:(NSUInteger)value
{
  return [self numberWithUnsignedInt:value];
}
@end

@implementation NSData (Compatibility)

+ (id)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b
{ return [MSBuffer dataWithBytesNoCopy:bytes length:length freeWhenDone:b]; }

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b
{ return [MSBuffer dataWithBytesNoCopy:bytes length:length freeWhenDone:b]; }

@end

@implementation NSError
@end

typedef struct _OSVERSIONINFOEX {
  DWORD dwOSVersionInfoSize;
  DWORD dwMajorVersion;
  DWORD dwMinorVersion;
  DWORD dwBuildNumber;
  DWORD dwPlatformId;
  TCHAR szCSDVersion[128];
  WORD wServicePackMajor;
  WORD wServicePackMinor;
  WORD wSuiteMask;
  BYTE wProductType;
  BYTE wReserved;
} OSVERSIONINFOEX,  *POSVERSIONINFOEX,  *LPOSVERSIONINFOEX;

#define VER_NT_WORKSTATION 0x0000001

NSUInteger MSOperatingSystem(void)
{
  unsigned int dwVersion = GetVersion() ;
  unsigned int majorVersion = dwVersion & 0xff ;
  unsigned int minorVersion = (dwVersion >> 8) & 0xff ;
  switch (majorVersion) {
    case 6:
      switch (minorVersion) {
        case 0:
        case 1:{
          OSVERSIONINFOEX osvi;
          SYSTEM_INFO si;
          BOOL bOsVersionInfoEx;
					
          ZeroMemory(&si, sizeof(SYSTEM_INFO));
          ZeroMemory(&osvi, sizeof(OSVERSIONINFOEX));
					
          osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEX);
					
          if( !(bOsVersionInfoEx = GetVersionEx ((OSVERSIONINFO *) &osvi)) )
					{
            osvi.dwOSVersionInfoSize = sizeof (OSVERSIONINFO);
            if (! GetVersionEx ( (OSVERSIONINFO *) &osvi) )
              [NSException raise:NSGenericException
                          format:@"Unable to get Windows version (GetVersionEx)"] ;
					}
					
          if (osvi.dwPlatformId == VER_PLATFORM_WIN32_NT) {
            if ( osvi.dwMajorVersion == 6)
            {
              if (osvi.dwMinorVersion == 0 )
              {
                if( osvi.wProductType == VER_NT_WORKSTATION )
                  return NSWindowsVistaOperatingSystem ;
                else
                  return NSWindowsServer2008OperatingSystem ;
              }
              else if (osvi.dwMinorVersion == 1 )
              {
                if( osvi.wProductType == VER_NT_WORKSTATION )
                  return NSWindowsSevenOperatingSystem ;
                else
                  return NSWindowsServer2008R2OperatingSystem ;
              }
              else
                [NSException raise:NSGenericException
                            format:@"Unable to get Windows version (GetVersionEx)"] ;
            }
            else
              [NSException raise:NSGenericException
                          format:@"Unable to get Windows version (GetVersionEx)"] ;
          }
          else
            [NSException raise:NSGenericException
                        format:@"Unable to get Windows version (GetVersionEx)"] ;
        }
        default: {
          [NSException raise:NSGenericException
                      format:@"Unable to get Windows version (GetVersionEx)"] ;
        }
      }
    case 5:
      switch (minorVersion) {
        case 0: return NSWindows2000OperatingSystem ;
        case 1: return NSWindowsXPOperatingSystem ;
        case 2: return NSWindowsServer2003OperatingSystem ;
        default: return NSWindowsNTOperatingSystem ;
      }
    case 4:
      if (!(dwVersion & 0x80000000)) return NSWindowsNT4OperatingSystem ;
      switch (minorVersion) {
        case 10: return NSWindows98OperatingSystem ;
        case 90: return NSWindowsMeOperatingSystem ;
        case 0: default: return NSWindows95OperatingSystem ;
      }
    case 3: return NSWindowsNT351OperatingSystem ;
    default: return NSUnknownOperatingSystem ;
  }
}

NSString *MSFindDLL(NSString *dll)
{
	if ([dll length]) {
		NSArray *paths = [[[[NSProcessInfo processInfo] environment] objectForKey:@"Path"] componentsSeparatedByString:@";"] ;
		NSEnumerator *e = [paths objectEnumerator] ;
		NSString *path ;
		NSFileManager *fm = [NSFileManager defaultManager] ;
		BOOL isDir = NO ;
		
		while ((path = [e nextObject])) {
      // TODO MSTrim
			path = [/*MSTrim(*/path/*)*/ stringByAppendingPathComponent:dll] ;
			if ([fm fileExistsAtPath:path isDirectory:&isDir] && !isDir) return path ;
		}
	}
  return nil ;
}

HINSTANCE MSLoadDLL(NSString *dllName)
{
	NSString *dllPath = MSFindDLL(dllName) ;
	HINSTANCE dll = (HINSTANCE)NULL ;
	if ([dllPath length]) {
		dll = LoadLibrary([dllPath fileSystemRepresentation]) ;
    
    if (!dll) {
      char *lpMsgBuf;
      int lastError = GetLastError() ;
      
      lpMsgBuf = (LPVOID)"Unknown error";
      if (FormatMessageA(
                         FORMAT_MESSAGE_ALLOCATE_BUFFER |
                         FORMAT_MESSAGE_FROM_SYSTEM |
                         FORMAT_MESSAGE_IGNORE_INSERTS,
                         NULL, lastError,
                         MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                         (LPTSTR)&lpMsgBuf, 0, NULL))
      {
        NSLog(@"MSLoadDLL Error while loading %@ : %d - %s", dllName, lastError, lpMsgBuf) ;
        LocalFree(lpMsgBuf);
      } else
        NSLog(@"MSLoadDLL Error while loading %@ : %d", dllName, lastError) ;
    }
	}
	return dll ;
}

IMP method_getImplementation(Method m)
{
  return m ? m->method_imp : NULL;
}
#endif

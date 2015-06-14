
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


#ifndef WIN32
#define NS_DURING @try {
#define NS_HANDLER } @catch(NSException *localException) {
#define NS_ENDHANDLER }
#define NS_VALUERETURN(val,type) { return val; }
#define NS_VOIDRETURN { return; }
#else // win32 exception aren't working yet, falling back to longjmp, badly taken from cocotron
/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#include <setjmp.h>
typedef struct NSExceptionFrame {
   jmp_buf                  state;
   struct NSExceptionFrame *parent;
   NSException             *exception;
} NSExceptionFrame;

FoundationExtern void __NSPushExceptionFrame(NSExceptionFrame *frame);
FoundationExtern void __NSPopExceptionFrame(NSExceptionFrame *frame);

#define NS_DURING \
  { \
   NSExceptionFrame __exceptionFrame; \
   __NSPushExceptionFrame(&__exceptionFrame); \
   if(setjmp(__exceptionFrame.state)==0){

#define NS_HANDLER \
    __NSPopExceptionFrame(&__exceptionFrame); \
   } \
   else{ \
    NSException *localException=__exceptionFrame.exception;\
    if (localException) { /* caller does not have to read localException */ }

#define NS_ENDHANDLER \
   } \
  }

#define NS_VALUERETURN(val,type) \
  { __NSPopExceptionFrame(&__exceptionFrame); return val; }

#define NS_VOIDRETURN \
  { __NSPopExceptionFrame(&__exceptionFrame); return; }

#endif

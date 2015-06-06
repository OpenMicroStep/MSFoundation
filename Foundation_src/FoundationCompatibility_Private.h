
#ifndef FOUNDATION_PRIVATE_H
#define FOUNDATION_PRIVATE_H

#ifdef _WIN32
#include <fcntl.h>
#include <winsock2.h>
#define O_CREAT  _O_CREAT
#define O_RDONLY _O_RDONLY
#define O_WRONLY _O_WRONLY
#define O_RDWR   _O_RDWR
#endif
#import "MSFoundation_Public.h"
#import "uv.h"
#import <objc/encoding.h>
#import <objc/hooks.h>

void FoundationCompatibilityExtendClass(char type, Class dstClass, SEL dstSel, Class srcClass, SEL srcSel);

@interface NSTimer (Private)
- (void)_addToLoop:(uv_loop_t *)uv_loop;
@end

@interface NSRunLoop (Private)
- (uv_loop_t *)_uv_loop;
- (int)_uv_run;
- (void)_uv_stop;
@end
#endif


#ifndef FOUNDATION_PRIVATE_H
#define FOUNDATION_PRIVATE_H

#ifdef _WIN32
#include <fcntl.h>
#include <winsock2.h>
#define O_CREAT  _O_CREAT
#define O_RDONLY _O_RDONLY
#define O_WRONLY _O_WRONLY
#define O_TRUNC  _O_TRUNC
#define O_RDWR   _O_RDWR
#define S_IFDIR  _S_IFDIR
#endif
#import "MSFoundation_Public.h"
#import "uv.h"
#import <objc/encoding.h>
#import <objc/hooks.h>

void FoundationCompatibilityCopyClassMethod(char type, Class dstClass, Class srcClass, SEL sel);
void FoundationCompatibilityExtendClass(char type, Class dstClass, SEL dstSel, Class srcClass, SEL srcSel);

@interface NSMethodSignature (Private)
- (id)_uniqid;
@end

@interface NSTimer (Private)
- (void)_addToLoop:(uv_loop_t *)uv_loop;
@end

@interface NSRunLoop (Private)
- (uv_loop_t *)_uv_loop;
- (int)_uv_run;
- (void)_uv_stop;
@end

@interface NSDictionary (Private)
- (gdict_pfs_t)_gdict_pfs; // See MSDictionary.m for the implementation
@end

@interface NSArray (Private)
- (garray_pfs_t)_garray_pfs; // See MSArray.m for the implementation
@end

#endif

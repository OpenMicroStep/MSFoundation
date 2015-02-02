#ifndef MSFINISHLOADING_H
#define MSFINISHLOADING_H

@interface NSObject (MSFinishLoading)
+ (void)finishLoading;
@end

typedef void (*MSFinishLoadingMethod)(void);
MSCoreExtern void MSFinishLoadingConfigure(uint8_t nbWaitings, MSFinishLoadingMethod beforeFinishLoading, MSFinishLoadingMethod afterFinishLoading);
MSCoreExtern void MSFinishLoadingAddClass(Class cls);

#endif

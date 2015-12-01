#ifndef MSFINISHLOADING_H
#define MSFINISHLOADING_H

typedef void (*MSFinishLoadingMethod)(void);
MSCoreExtern void MSFinishLoadingConfigure(uint8_t nbWaitings, MSFinishLoadingMethod finishLoading);
MSCoreExtern void MSFinishLoadingDec();

typedef id (*MSGrowInitCopyMethod)(id, const id, BOOL);
id MSGrowCopyWithZone(NSZone *z, id objToCopy, BOOL toMutable, MSGrowInitCopyMethod init);

#endif

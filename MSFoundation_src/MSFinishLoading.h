#ifndef MSFINISHLOADING_H
#define MSFINISHLOADING_H

@interface NSObject (MSFinishLoading)
+ (void)finishLoading;
@end

typedef void (*MSFinishLoadingMethod)(void);
MSCoreExtern void MSFinishLoadingConfigure(uint8_t nbWaitings, MSFinishLoadingMethod beforeFinishLoading, MSFinishLoadingMethod afterFinishLoading);
MSCoreExtern void MSFinishLoadingAddClass(Class cls);

@interface NSObject (MSCopying)
- (Class)_classForCopy; // Used in FoundationCompatibility to copy NSMutableClass to immutable class.
@end

typedef id (*MSGrowInitCopyMethod)(id, const id, BOOL);
id MSGrowCopyWithZone(NSZone *z, id objToCopy, BOOL toMutable, MSGrowInitCopyMethod init);

#endif

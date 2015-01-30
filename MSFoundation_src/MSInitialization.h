#ifndef MSCORE_INIT
#define MSCORE_INIT

@interface NSObject (MSInitialization)
+ (void)msloaded;
@end

typedef void (*MSInitMethod)();
MSCoreExtern void MSInitConfigure(uint8_t nbWaitings, MSInitMethod beforeLoadedInit, MSInitMethod afterLoadedInit);
MSCoreExtern void MSInitSetInitializedClass(Class cls);

#endif

#include "MSFoundation_Private.h"

static uint8_t __counter = 0;
static uint8_t __nbWaitings = 0;

static MSInitMethod __beforeLoaded = NULL;
static MSInitMethod __afterLoaded = NULL;
static Class __initializedClasses[UINT8_MAX];

static void _fireInits()
{
    Class cls;
    __counter= 0;
    if(__beforeLoaded) {
        __beforeLoaded();
        __beforeLoaded= NULL;
    }
    for(uint8_t i = 0; i < __nbWaitings; ++i) {
        if((cls= __initializedClasses[i])) {
            if([cls respondsToSelector:@selector(msloaded)])
                [cls msloaded];
            __initializedClasses[i]= NULL;
        }
    }
    if(__afterLoaded) {
        __afterLoaded();
        __afterLoaded= NULL;
    }
}

void MSInitConfigure(uint8_t nbWaitings, MSInitMethod beforeLoadedInit, MSInitMethod afterLoadedInit)
{
    __nbWaitings= nbWaitings;
    __beforeLoaded= beforeLoadedInit;
    __afterLoaded= afterLoadedInit;
    if(__counter > 0 && __counter == __nbWaitings) {
        _fireInits();
    }
    else if (__counter > __nbWaitings) {
        fprintf(stderr, "MSInitConfigure counter=%d is beyond the nbWaitings, inits won't be fired\n", __counter);
    }
}

void MSInitSetInitializedClass(Class cls)
{
    if(__counter == UINT8_MAX) {
        fprintf(stderr, "MSInitSetInitializedClass counter reached the maximum: %d\n", UINT8_MAX);
        return;
    }
    __initializedClasses[__counter] = cls;
    if(++__counter == __nbWaitings) {
        _fireInits();
    }
}

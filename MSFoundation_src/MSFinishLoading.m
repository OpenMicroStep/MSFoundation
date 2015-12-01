#include "MSFoundation_Private.h"

static uint8_t __counter=    0;
static uint8_t __nbWaitings= 0;

static MSFinishLoadingMethod __beforeMethod= NULL;

static void _fireInits()
{
    __counter= 0;
    if(__beforeMethod) {
        __beforeMethod();
        __beforeMethod= NULL;
    }
}

void MSFinishLoadingConfigure(uint8_t nbWaitings, MSFinishLoadingMethod beforeFinishLoading)
{
    __nbWaitings= nbWaitings;
    __beforeMethod= beforeFinishLoading;
    if(__counter > 0 && __counter == __nbWaitings) {
        _fireInits();
    }
    else if (__counter > __nbWaitings) {
        fprintf(stderr, "MSFinishLoadingConfigure counter=%d is beyond the nbWaitings, inits won't be fired\n", __counter);
    }
}

void MSFinishLoadingDec()
{
  if (++__counter == __nbWaitings) {
    _fireInits();}
}

id MSGrowCopyWithZone(NSZone *z, id objToCopy, BOOL toMutable, MSGrowInitCopyMethod init)
{
  Class cls; id o;
  if (!toMutable && CGrowIsForeverImmutable(objToCopy)) return RETAIN(objToCopy);
  cls= [objToCopy class];
  o= MSAllocateObject(cls, 0, z);
  o= init(o, objToCopy, toMutable);
  if (!toMutable)
    CGrowSetForeverImmutable(o);
  return o;
}

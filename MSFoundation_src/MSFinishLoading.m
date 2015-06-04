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

@implementation NSObject (MSCopying)
- (Class)_classForCopy {return [self class];}
@end

id MSGrowCopyWithZone(NSZone *z, id objToCopy, BOOL toMutable, MSGrowInitCopyMethod init)
  {
  Class cl; id o;
  if (!toMutable && CGrowIsForeverImmutable(objToCopy)) return RETAIN(objToCopy);
  cl= !toMutable ? [objToCopy _classForCopy] : [objToCopy class];
  o= MSAllocateObject(cl, 0, z);
  return init(o, objToCopy, toMutable);
  }

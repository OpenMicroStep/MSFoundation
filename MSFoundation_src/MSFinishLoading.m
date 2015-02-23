#include "MSFoundation_Private.h"

static uint8_t __counter=    0;
static uint8_t __nbWaitings= 0;

static MSFinishLoadingMethod __beforeMethod= NULL;
static MSFinishLoadingMethod __afterMethod=  NULL;
static Class __addedClasses[UINT8_MAX];

static void _fireInits()
{
    Class cls;
    __counter= 0;
    if(__beforeMethod) {
        __beforeMethod();
        __beforeMethod= NULL;
    }
    for(uint8_t i= 0; i < __nbWaitings; ++i) {
        if((cls= __addedClasses[i])) {
            if([cls respondsToSelector:@selector(finishLoading)])
                [cls finishLoading];
            __addedClasses[i]= NULL;
        }
    }
    if(__afterMethod) {
        __afterMethod();
        __afterMethod= NULL;
    }
}

void MSFinishLoadingConfigure(uint8_t nbWaitings, MSFinishLoadingMethod beforeFinishLoading, MSFinishLoadingMethod afterFinishLoading)
{
    __nbWaitings= nbWaitings;
    __beforeMethod= beforeFinishLoading;
    __afterMethod= afterFinishLoading;
    if(__counter > 0 && __counter == __nbWaitings) {
        _fireInits();
    }
    else if (__counter > __nbWaitings) {
        fprintf(stderr, "MSFinishLoadingConfigure counter=%d is beyond the nbWaitings, inits won't be fired\n", __counter);
    }
}

void MSFinishLoadingAddClass(Class cls)
{
//printf("MSFinishLoadingAddClass %d %s\n",__counter,class_getName(cls));
    if(__counter == UINT8_MAX) {
        fprintf(stderr, "MSFinishLoadingAddClass counter reached the maximum: %d\n", UINT8_MAX);
        return;
    }
    __addedClasses[__counter]= cls;
    if(++__counter == __nbWaitings) {
        _fireInits();
    }
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

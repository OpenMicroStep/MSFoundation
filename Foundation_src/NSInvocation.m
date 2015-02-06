#import "FoundationCompatibility_Private.h"
#import <objc/hooks.h>

pthread_key_t __forward_slot_key;

static IMP objc_msg_forward2(id receiver, SEL _cmd)
{
   printf("missing %c[%s %s]\n", class_isMetaClass(object_getClass(receiver))?'+':'-', object_getClassName(receiver), sel_getName(_cmd));
    MSRaise(@"NSInvocation", @"Message forwarding isn't supported yet");
    __builtin_trap();
}

static struct objc_slot *objc_msg_forward3(id receiver, SEL _cmd)
{
    struct objc_slot *slot = pthread_getspecific(__forward_slot_key);
    if(!slot) {
        slot= calloc(1, sizeof(struct objc_slot));
        pthread_setspecific(__forward_slot_key, slot);
    }
    slot->method= objc_msg_forward2(receiver, _cmd);
    return slot;
}

@implementation NSInvocation
+ (void)load
{
    pthread_key_create(&__forward_slot_key, free);
    __objc_msg_forward3= objc_msg_forward3;
    __objc_msg_forward2= objc_msg_forward2;
}
@end

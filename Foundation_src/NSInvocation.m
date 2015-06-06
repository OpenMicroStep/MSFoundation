#import "FoundationCompatibility_Private.h"

MS_DECLARE_THREAD_LOCAL(__forward_slot, free);

static IMP objc_msg_forward2(id receiver, SEL _cmd)
{
  printf("missing2 %c[%s %s]\n", class_isMetaClass(object_getClass(receiver))?'+':'-', object_getClassName(receiver), sel_getName(_cmd));
#ifdef WIN32
  DebugBreak();
#endif
  MSRaise(@"NSInvocation", @"Message forwarding isn't supported yet");
  __builtin_trap();
}

static struct objc_slot *objc_msg_forward3(id receiver, SEL _cmd)
{
  struct objc_slot *slot = tss_get(__forward_slot);
  if(!slot) {
    slot= calloc(1, sizeof(struct objc_slot));
    tss_set(__forward_slot, slot);
  }
  slot->method= objc_msg_forward2(receiver, _cmd);
  return slot;
}

@implementation NSInvocation
+ (void)load
{
  __objc_msg_forward3= objc_msg_forward3;
  __objc_msg_forward2= objc_msg_forward2;
}
@end

//
//  NSObject_test.m
//  MSFoundation
//
//  Created by Vincent Rouillé on 26/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#import "foundation_validate.h"

@protocol NSObjectTestProtocol1 <NSObject>
-(id)protocolMethod1;
-(id)protocolMethod2:(id)obj;
@end


@protocol NSObjectTestProtocol2 <NSObject>
-(id)protocolMethod2:(id)obj;
-(id)protocolMethod3;
@end

@interface NSObjectTests : NSObject <NSObjectTestProtocol1> {
@public
  id _r0, _r1, _r2;
  id _o, _o1, _o2;
  id _p1, _p2, _p2o;
}
-(id)selector;
-(id)selectorWithObject:(id)o;
-(id)selectorWithObject:(id)o1 withObject2:(id)o2;
@end

@implementation NSObjectTests
-(id)protocolMethod1
{
  return _p1;
}
-(id)protocolMethod2:(id)obj
{
  _p2o = obj;
  return _p2;
}
-(id)selector
{
  return _r0;
}
-(id)selectorWithObject:(id)o
{
  _o = o;
  return _r1;
}
-(id)selectorWithObject:(id)o1 withObject2:(id)o2
{
  _o1 = o1;
  _o2 = o2;
  return _r2;
}
@end

@interface NSObjectTestOutTree : NSObject
@end

@implementation NSObjectTestOutTree
@end

static void object_memory(test_t *test)
{
  id obj;
  obj= [NSObject new];
  TASSERT_EQUALS(test, [obj retainCount], 1, "retain count of [NSObject new] must be one: %d != %d");
  [obj release];

  obj= [[NSObject alloc] init];
  TASSERT_EQUALS(test, [obj retainCount], 1, "retain count of [[NSObject allow] init] must be %2$d, got %1$d");
  TASSERT_EQUALS(test, [obj retain], obj, "-retain must return the same object: %p != %p");
  TASSERT_EQUALS(test, [obj retainCount], 2, "retain count must be %2$d, got %1$d");
  [obj release];
  TASSERT_EQUALS(test, [obj retainCount], 1, "retain count must be %2$d, got %1$d");
  [obj release];
}

static void object_classTree(test_t *test)
{
  id obj;
  obj= [NSObjectTests new];

  TASSERT(test, [obj isKindOfClass:[NSObjectTests class]], "NSObjectTests is an NSObjectTests");
  TASSERT(test, [obj isKindOfClass:[NSObject class]], "NSObjectTests is an NSObject");
  TASSERT(test, ![obj isKindOfClass:[NSObjectTestOutTree class]], "NSObjectTests is not an NSObjectTestOutTree");

  TASSERT(test, [obj isMemberOfClass:[NSObjectTests class]], "NSObjectTests is exactly an NSObjectTests");
  TASSERT(test, ![obj isMemberOfClass:[NSObject class]], "NSObjectTests is not exactly an NSObject");
  TASSERT(test, ![obj isMemberOfClass:[NSObjectTestOutTree class]], "NSObjectTests is not exactly an NSObjectTestOutTree");

  TASSERT(test, [obj conformsToProtocol:@protocol(NSObjectTestProtocol1)], "NSObjectTests implements NSObjectTestProtocol1");
  TASSERT(test, ![obj conformsToProtocol:@protocol(NSObjectTestProtocol2)], "NSObjectTests doesn't implements NSObjectTestProtocol2");
  TASSERT(test, [obj conformsToProtocol:@protocol(NSObject)], "NSObjectTests implements NSObjectTestProtocol1");

  [obj release];
}

static void object_perform(test_t *test)
{
  id r0= (id)UINTPTR_MAX, r1= (id)(UINTPTR_MAX-2), r2= (id)(UINTPTR_MAX-1);
  id o= (id)(UINTPTR_MAX-4), o1= (id)(UINTPTR_MAX-7), o2= (id)(UINTPTR_MAX-10);
  NSObjectTests* obj;
  obj= [NSObjectTests new];
  obj->_r0 = r0;
  obj->_r1 = r1;
  obj->_r2 = r2;

  TASSERT_EQUALS(test, [obj performSelector:@selector(selector)], r0, "performSelector failed, must return %2$p, got %1$p");

  TASSERT_EQUALS(test, [obj performSelector:@selector(selectorWithObject:) withObject:o], r1, "performSelector failed, must return %2$p, got %1$p");
  TASSERT_EQUALS(test, obj->_o, o, "performSelector failed, %2$p expected, got %1$p");

  TASSERT_EQUALS(test, [obj performSelector:@selector(selectorWithObject:withObject2:) withObject:o1 withObject:o2], r2, "performSelector failed, must return %2$p, got %1$p");
  TASSERT_EQUALS(test, obj->_o1, o1, "performSelector failed, %2$p expected, got %1$p");
  TASSERT_EQUALS(test, obj->_o2, o2, "performSelector failed, %2$p expected, got %1$p");

  TASSERT(test, [obj respondsToSelector:@selector(selectorWithObject:withObject2:)], "NSObjectTests implements selectorWithObject:withObject2:");
  TASSERT(test, ![obj respondsToSelector:@selector(protocolMethod3)], "NSObjectTests implements selectorWithObject:withObject2:");

  [obj release];
}

#define RCOUNT 1000000
struct thrd_data_t {
  long no;
  id o;
  thrd_t thread;
  long collision;};

int _concurentRetain(void* data)
{
  struct thrd_data_t *d= (struct thrd_data_t *)data;
  id o= d->o;
  NSUInteger r0,r,collision,i;
  r0= [o retainCount]; collision= 0;
  for (i= 0; i<RCOUNT; i++) {
    [o retain];
    if ((r= [o retainCount])>r0+i+1) {
      //printf("-> %d %lu %lu\n", d->no, i, r);
      collision++;
      r0= r-i-1;
    }
    //else printf("   %d %lu %lu\n", d->m==&_m1?1:2, i, r);
  }
  d->collision= collision;
  return 0;
}
int _concurentRelease(void* data)
{
  struct thrd_data_t *d= (struct thrd_data_t *)data;
  id o= d->o;
  NSUInteger r0,r,collision,i;
  r0= [o retainCount]; collision= 0;
  for (i= 0; i<RCOUNT; i++) {
    [o release];
    if ((r= [o retainCount])<r0-i-1) {
      //printf("-> %d %lu %lu\n", d->no, i, r);
      collision++;
      r0= r+i+1;
    }
    //else printf("   %d %lu %lu\n", d->m==&_m1?1:2, i, r);
  }
  d->collision= collision;
  return 0;
}

static BOOL _launchThread(test_t *test, thrd_t *thr, thrd_start_t func, void *arg)
{
  int ret= thrd_create(thr, func, arg);
  return TASSERT(test, ret == thrd_success, "error");
}

#ifdef WO451
@interface NSObjectTestsThreadFakeLauncher : NSObject
- (void)fakeLaunch:(id)parameters ;
@end
@implementation NSObjectTestsThreadFakeLauncher
- (void)fakeLaunch:(id)parameters {}
@end
#endif

static void object_threadRetain(test_t *test)
{
  id o;
  BOOL canWait;
  struct thrd_data_t d1, d2, d3;
#ifdef WO451
  //force some initializations under WO451
  [NSThread detachNewThreadSelector:@selector(fakeLaunch:) toTarget:[NSObjectTestsThreadFakeLauncher new] withObject:nil];
#endif

  o= [[NSObject alloc] init];
  d1.no= 1; d1.o= o;
  d2.no= 2; d2.o= o;
  d3.no= 3; d3.o= o;

  canWait= YES; d1.collision= 0; d2.collision= 0; d3.collision= 0;
  canWait= canWait && _launchThread(test, &d1.thread, _concurentRetain, &d1);
  canWait= canWait && _launchThread(test, &d2.thread, _concurentRetain, &d2);
  canWait= canWait && _launchThread(test, &d3.thread, _concurentRetain, &d3);
  if (canWait) {
    TASSERT(test, thrd_join(d1.thread,NULL) == thrd_success, "thrd_join");
    TASSERT(test, thrd_join(d2.thread,NULL) == thrd_success, "thrd_join");
    TASSERT(test, thrd_join(d3.thread,NULL) == thrd_success, "thrd_join");
    TASSERT_EQUALS(test, [o retainCount], 3*RCOUNT+1, "retainCount %u != expected %u");
    TASSERT(test, d1.collision + d2.collision > 0, "retain  collisions 1:%ld 2:%ld", d1.collision, d2.collision);
    //printf("retain  collisions 1:%ld 2:%ld\n", d1.collision, d2.collision);
  }

  canWait= YES; d1.collision= 0; d2.collision= 0; d3.collision= 0;
  canWait= canWait && _launchThread(test, &d1.thread, _concurentRelease, &d1);
  canWait= canWait && _launchThread(test, &d2.thread, _concurentRelease, &d2);
  canWait= canWait && _launchThread(test, &d3.thread, _concurentRelease, &d3);
  if (canWait) {
    TASSERT(test, thrd_join(d1.thread,NULL) == thrd_success, "thrd_join");
    TASSERT(test, thrd_join(d2.thread,NULL) == thrd_success, "thrd_join");
    TASSERT(test, thrd_join(d3.thread,NULL) == thrd_success, "thrd_join");
    TASSERT_EQUALS(test, [o retainCount], 1, "retainCount %u != expected %u");
    TASSERT(test, d1.collision + d2.collision > 0, "release collisions 1:%ld 2:%ld", d1.collision, d2.collision);
    //printf("release collisions 1:%ld 2:%ld\n", d1.collision, d2.collision);
  }

  RELEASE(o);
}

testdef_t foundation_object[]= {
  {"memory"      ,NULL,object_memory      },
  {"class tree"  ,NULL,object_classTree   },
  {"perform"     ,NULL,object_perform     },
  {"threadRetain",NULL,object_threadRetain},
  {NULL}
};

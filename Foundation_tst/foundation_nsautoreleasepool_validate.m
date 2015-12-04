//
//  NSObject_test.m
//  MSFoundation
//
//  Created by Vincent Rouillé on 26/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#import "foundation_validate.h"

static void pool_some(test_t *test)
{
  NSObject *o1, *o2;
  NSAutoreleasePool *a1, *a2;
  o1= [NSObject new];
  o2= [NSObject new];
  TASSERT_EQUALS(test, [o1 retainCount], 1, "object retainCount should be $2$d, got %1$d");
  TASSERT_EQUALS(test, [o2 retainCount], 1, "object retainCount should be $2$d, got %1$d");
  a1= [[NSAutoreleasePool alloc] init];
  [[o1 retain] autorelease];
  [[o2 retain] autorelease];
  TASSERT_EQUALS(test, [o1 retainCount], 2, "object retainCount should be $2$d, got %1$d");
  TASSERT_EQUALS(test, [o2 retainCount], 2, "object retainCount should be $2$d, got %1$d");
  [[o2 retain] autorelease];
  TASSERT_EQUALS(test, [o2 retainCount], 3, "object retainCount should be $2$d, got %1$d");
  a2= [NSAutoreleasePool new];
  [[o1 retain] autorelease];
  [[o2 retain] autorelease];
  TASSERT_EQUALS(test, [o1 retainCount], 3, "object retainCount should be $2$d, got %1$d");
  TASSERT_EQUALS(test, [o2 retainCount], 4, "object retainCount should be $2$d, got %1$d");
  [a2 release];
  TASSERT_EQUALS(test, [o1 retainCount], 2, "object retainCount should be $2$d, got %1$d");
  TASSERT_EQUALS(test, [o2 retainCount], 3, "object retainCount should be $2$d, got %1$d");
  [a1 release];
  TASSERT_EQUALS(test, [o1 retainCount], 1, "object retainCount should be $2$d, got %1$d");
  TASSERT_EQUALS(test, [o2 retainCount], 1, "object retainCount should be $2$d, got %1$d");
  [o1 release];
  [o2 release];
}


#define RCOUNT 1000000
struct thrd_data_t {
  long no;
  id o;
  thrd_t thread;
  long collision;};

static int _concurentAutorelease(void* data)
{
  struct thrd_data_t *d= (struct thrd_data_t *)data;
  id o= d->o;
  NSAutoreleasePool *pool, *pool2;
  NSUInteger r0,r,collision,i;
  pool= [NSAutoreleasePool new];
  r0= [o retainCount]; collision= 0;
  for (i= 0; i<RCOUNT; i++) {
    [[o retain] autorelease];
    if ((r= [o retainCount])>r0+i+1) {
      collision++;
      r0= r-i-1;
    }
  }
  pool2= [[NSAutoreleasePool alloc] init];
  [[o retain] autorelease];
  [pool2 release];
  [pool release];
  d->collision= collision;
  return 0;
}

#ifdef WO451
@interface NSAutoreleaseTestsThreadFakeLauncher : NSObject
- (void)fakeLaunch:(id)parameters ;
@end
@implementation NSAutoreleaseTestsThreadFakeLauncher
- (void)fakeLaunch:(id)parameters { }
@end
#endif

static BOOL _launchThread(test_t *test, thrd_t *thr, thrd_start_t func, void *arg)
{
  int ret= thrd_create(thr, func, arg);
  return TASSERT(test, ret == thrd_success, "error");
}

static void pool_threadAutorelease(test_t *test)
{
  id o;
  BOOL canWait;
  struct thrd_data_t d1, d2, d3;

#ifdef WO451
  //force some initializations under WO451
  [NSThread detachNewThreadSelector:@selector(fakeLaunch:) toTarget:[NSAutoreleaseTestsThreadFakeLauncher new] withObject:nil];
#endif

  o= [[NSObject alloc] init];
  d1.no= 1; d1.o= o;
  d2.no= 2; d2.o= o;
  d3.no= 3; d3.o= o;

  canWait= YES; d1.collision= 0; d2.collision= 0; d3.collision= 0;
  canWait= canWait && _launchThread(test, &d1.thread, _concurentAutorelease, &d1);
  canWait= canWait && _launchThread(test, &d2.thread, _concurentAutorelease, &d2);
  canWait= canWait && _launchThread(test, &d3.thread, _concurentAutorelease, &d3);
  if (canWait) {
    TASSERT(test, thrd_join(d1.thread,NULL) == thrd_success, "thrd_join");
    TASSERT(test, thrd_join(d2.thread,NULL) == thrd_success, "thrd_join");
    TASSERT(test, thrd_join(d3.thread,NULL) == thrd_success, "thrd_join");
    TASSERT_EQUALS(test, [o retainCount], 1, "retainCount %u != expected %u");
    TASSERT(test, d1.collision + d2.collision > 0, "retain  collisions 1:%ld 2:%ld", d1.collision, d2.collision);
    //printf("retain  collisions 1:%ld 2:%ld\n", d1.collision, d2.collision);
  }

  RELEASE(o);
}

testdef_t foundation_pool[]= {
  {"some"             ,NULL,pool_some             },
  {"threadAutorelease",NULL,pool_threadAutorelease},
  {NULL}};

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

int testNew()
{
    id obj;
    obj= [NSObject new];
    ASSERT_EQUALS([obj retainCount], 1, "retain count of [NSObject new] must be one: %d != %d");
    [obj release];
    
    obj= [[NSObject alloc] init];
    ASSERT_EQUALS([obj retainCount], 1, "retain count of [[NSObject allow] init] must be %2$d, got %1$d");
    ASSERT_EQUALS([obj retain], obj, "-retain must return the same object: %p != %p");
    ASSERT_EQUALS([obj retainCount], 2, "retain count must be %2$d, got %1$d");
    [obj release];
    ASSERT_EQUALS([obj retainCount], 1, "retain count must be %2$d, got %1$d");
    [obj release];
    
    return 0;
}

int testClassTree()
{
    id obj;
    obj= [NSObjectTests new];
    
    ASSERT([obj isKindOfClass:[NSObjectTests class]], "NSObjectTests is an NSObjectTests");
    ASSERT([obj isKindOfClass:[NSObject class]], "NSObjectTests is an NSObject");
    ASSERT(![obj isKindOfClass:[NSObjectTestOutTree class]], "NSObjectTests is not an NSObjectTestOutTree");
    
    ASSERT([obj isMemberOfClass:[NSObjectTests class]], "NSObjectTests is exactly an NSObjectTests");
    ASSERT(![obj isMemberOfClass:[NSObject class]], "NSObjectTests is not exactly an NSObject");
    ASSERT(![obj isMemberOfClass:[NSObjectTestOutTree class]], "NSObjectTests is not exactly an NSObjectTestOutTree");
    
    ASSERT([obj conformsToProtocol:@protocol(NSObjectTestProtocol1)], "NSObjectTests implements NSObjectTestProtocol1");
    ASSERT(![obj conformsToProtocol:@protocol(NSObjectTestProtocol2)], "NSObjectTests doesn't implements NSObjectTestProtocol2");
    ASSERT([obj conformsToProtocol:@protocol(NSObject)], "NSObjectTests implements NSObjectTestProtocol1");
    
    [obj release];
    return 0;
}

int testPerform()
{
    id r0= (id)UINTPTR_MAX, r1= (id)(UINTPTR_MAX-2), r2= (id)(UINTPTR_MAX-1);
    id o= (id)(UINTPTR_MAX-4), o1= (id)(UINTPTR_MAX-7), o2= (id)(UINTPTR_MAX-10);
    NSObjectTests* obj;
    obj= [NSObjectTests new];
    obj->_r0 = r0;
    obj->_r1 = r1;
    obj->_r2 = r2;
    
    ASSERT_EQUALS([obj performSelector:@selector(selector)], r0, "performSelector failed, must return %2$p, got %1$p");
    
    ASSERT_EQUALS([obj performSelector:@selector(selectorWithObject:) withObject:o], r1, "performSelector failed, must return %2$p, got %1$p");
    ASSERT_EQUALS(obj->_o, o, "performSelector failed, %2$p expected, got %1$p");
    
    ASSERT_EQUALS([obj performSelector:@selector(selectorWithObject:withObject2:) withObject:o1 withObject:o2], r2, "performSelector failed, must return %2$p, got %1$p");
    ASSERT_EQUALS(obj->_o1, o1, "performSelector failed, %2$p expected, got %1$p");
    ASSERT_EQUALS(obj->_o2, o2, "performSelector failed, %2$p expected, got %1$p");
    
    ASSERT([obj respondsToSelector:@selector(selectorWithObject:withObject2:)], "NSObjectTests implements selectorWithObject:withObject2:");
    ASSERT(![obj respondsToSelector:@selector(protocolMethod3)], "NSObjectTests implements selectorWithObject:withObject2:");
    
    [obj release];
    return 0;
}


#include <assert.h>
#define RCOUNT 100000
int _w= 0;
struct pdata_t {
  long no;
  id o;
  long collision;};

void* _concurentRetain(void* data)
{
  struct pdata_t *d= (struct pdata_t *)data;
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
  __sync_add_and_fetch(&_w, 1);
  return NULL;
}
void* _concurentRelease(void* data)
{
  struct pdata_t *d= (struct pdata_t *)data;
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
  __sync_add_and_fetch(&_w, 1);
  return NULL;
}

void _launchThread(void *(*start_routine)(void *), void* data)
{
  pthread_attr_t attr;
  pthread_t      posixThreadID;
  int            returnVal, threadError;
 
  returnVal= pthread_attr_init(&attr);
  assert(!returnVal);
  returnVal= pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
  assert(!returnVal);
 
  threadError= pthread_create(&posixThreadID, &attr, start_routine, data);

  returnVal= pthread_attr_destroy(&attr);
  assert(!returnVal);
  if (threadError != 0)
    {
         // Report an error.
    }
}

int testThreadRetain()
{
  int err= 0;
  id o;
  struct pdata_t d1, d2;
  o= [[NSObject alloc] init];
  d1.no= 1; d1.o= o;
  d2.no= 2; d2.o= o;

  _w= 0; d1.collision= 0; d2.collision= 0;
  _launchThread(_concurentRetain, &d1);
  _launchThread(_concurentRetain, &d2);
  while (_w!=2) sleep(1);
  ASSERT_EQUALS([o retainCount], 2*RCOUNT+1, "retainCount %u != expected %u");
  ASSERT(d1.collision + d2.collision > 0, "retain  collisions 1:%ld 2:%ld", d1.collision, d2.collision);
//printf("retain  collisions 1:%ld 2:%ld\n", d1.collision, d2.collision);

  _w= 0; d1.collision= 0; d2.collision= 0;
  _launchThread(_concurentRelease, &d1);
  _launchThread(_concurentRelease, &d2);
  while (_w!=2) sleep(1);
  ASSERT_EQUALS([o retainCount], 1, "retainCount %u != expected %u");
  ASSERT(d1.collision + d2.collision > 0, "release collisions 1:%ld 2:%ld", d1.collision, d2.collision);
//printf("release collisions 1:%ld 2:%ld\n", d1.collision, d2.collision);

  RELEASE(o);
  return err;
}

TEST_FCT_BEGIN(NSObject)
    testRun("memory", testNew);
    testRun("class tree", testClassTree);
    testRun("perform", testPerform);
    testRun("threadRetain", testThreadRetain);
TEST_FCT_END(NSObject)

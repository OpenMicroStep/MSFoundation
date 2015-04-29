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


#include <assert.h>
typedef struct atom_t {
  long            value;
  pthread_mutex_t mutex;
  pthread_cond_t  cond;
}
* atom;
#define STRUCT_ATOM_INITIALIZER(V) {(V),PTHREAD_MUTEX_INITIALIZER,PTHREAD_COND_INITIALIZER}
void atom_set(atom a, long value)
{
  if (a) {
    a->value= value;
    pthread_mutex_init(&(a->mutex), NULL);
    pthread_cond_init(&(a->cond), NULL);}
}
void atom_unset(atom a)
{
  if (a) {
    a->value= 0;
    pthread_mutex_destroy(&(a->mutex));
    pthread_cond_destroy(&(a->cond));}
}
void atom_add_and_signal(atom a, long toBeAdded)
{
  if (a) {
    __sync_add_and_fetch(&(a->value), toBeAdded);
    pthread_cond_signal(&(a->cond));}
}
void atom_wait_count(atom a, long count)
{
  if (a) {
    pthread_mutex_lock(&(a->mutex));
    while (a->value < count) {
      pthread_cond_wait(&(a->cond), &(a->mutex));}
    pthread_mutex_unlock(&(a->mutex));}
}

#define RCOUNT 1000000
struct pthread_data_t {
  long no;
  id o;
  atom atom;
  pthread_t thread;
  long collision;};

void* _concurentRetain(void* data)
{
  struct pthread_data_t *d= (struct pthread_data_t *)data;
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
  atom_add_and_signal(d->atom, 1);
  return NULL;
}
void* _concurentRelease(void* data)
{
  struct pthread_data_t *d= (struct pthread_data_t *)data;
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
  atom_add_and_signal(d->atom, 1);
  return NULL;
}

#define TEST_JOIN  1
#define TEST_SLEEP 2
#define TEST_ATOM  3

pthread_t _launchThread(test_t *test, void *(*start_routine)(void *), void* data, int what)
{
  pthread_attr_t attr;
  pthread_t      thread= 0;
  TASSERT(test, !pthread_attr_init(&attr),"error");
  TASSERT(test, !pthread_attr_setdetachstate(&attr, what==TEST_JOIN?PTHREAD_CREATE_JOINABLE:PTHREAD_CREATE_DETACHED),"error");
  TASSERT(test, !pthread_create(&thread, &attr, start_routine, data), "error");
  TASSERT(test, !pthread_attr_destroy(&attr),"error");
  return thread;
}

static void object_threadRetain(test_t *test)
{
  id o;
  int state;
  struct pthread_data_t d1, d2, d3;
  struct atom_t struct_atom= STRUCT_ATOM_INITIALIZER(0);
  o= [[NSObject alloc] init];
  d1.no= 1; d1.o= o; d1.atom= NULL;
  d2.no= 2; d2.o= o; d2.atom= NULL;
  d3.no= 3; d3.o= o; d3.atom= NULL;
  
  for (state=TEST_JOIN; state<=TEST_ATOM; state++) {
    if (state>TEST_JOIN) {d1.atom= &struct_atom; d2.atom= &struct_atom; d3.atom= &struct_atom;}
    struct_atom.value= 0; d1.collision= 0; d2.collision= 0; d3.collision= 0;
    d1.thread= _launchThread(test, _concurentRetain, &d1, state);
    d2.thread= _launchThread(test, _concurentRetain, &d2, state);
    d3.thread= _launchThread(test, _concurentRetain, &d3, state);
    if (d1.thread && d2.thread && d3.thread) {
      if (state==TEST_JOIN) {
        if (d1.thread) pthread_join(d1.thread,NULL);
        if (d2.thread) pthread_join(d2.thread,NULL);
        if (d3.thread) pthread_join(d3.thread,NULL);}
      else if (state==TEST_SLEEP) {
        while (struct_atom.value!=3) {
          struct timespec t= {0,1000};
          int e= nanosleep(&t, NULL);
          if (e) printf("nanosleep sig abort\n");}}
      else if (state==TEST_ATOM) {
        atom_wait_count(&struct_atom, 3);}}
    TASSERT_EQUALS(test, [o retainCount], 3*RCOUNT+1, "retainCount %u != expected %u");
    TASSERT(test, d1.collision + d2.collision > 0, "retain  collisions 1:%ld 2:%ld", d1.collision, d2.collision);
    //printf("retain  collisions 1:%ld 2:%ld\n", d1.collision, d2.collision);
    
    struct_atom.value= 0; d1.collision= 0; d2.collision= 0; d3.collision= 0;
    d1.thread= _launchThread(test, _concurentRelease, &d1, state);
    d2.thread= _launchThread(test, _concurentRelease, &d2, state);
    d3.thread= _launchThread(test, _concurentRelease, &d3, state);
    if (d1.thread && d2.thread && d3.thread) {
      if (state==TEST_JOIN) {
        if (d1.thread) pthread_join(d1.thread,NULL);
        if (d2.thread) pthread_join(d2.thread,NULL);
        if (d3.thread) pthread_join(d3.thread,NULL);}
      else if (state==TEST_SLEEP) {
        while (struct_atom.value!=3) {
          struct timespec t= {0,1000};
          int e= nanosleep(&t, NULL);
          if (e) printf("nanosleep sig abort\n");}}
      else if (state==TEST_ATOM) {
        atom_wait_count(&struct_atom, 3);}}
    TASSERT_EQUALS(test, [o retainCount], 1, "retainCount %u != expected %u");
    TASSERT(test, d1.collision + d2.collision > 0, "release collisions 1:%ld 2:%ld", d1.collision, d2.collision);
    //printf("release collisions 1:%ld 2:%ld\n", d1.collision, d2.collision);
  }
  RELEASE(o);
}

test_t foundation_object[]= {
  {"memory"      ,NULL,object_memory      ,INTITIALIZE_TEST_T_END},
  {"class tree"  ,NULL,object_classTree   ,INTITIALIZE_TEST_T_END},
  {"perform"     ,NULL,object_perform     ,INTITIALIZE_TEST_T_END},
  {"threadRetain",NULL,object_threadRetain,INTITIALIZE_TEST_T_END},
  {NULL}
};

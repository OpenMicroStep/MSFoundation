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


typedef struct atom_t {
  long            value;
  pthread_mutex_t mutex;
  pthread_cond_t  cond;}
* atom;

#define STRUCT_ATOM_INITIALIZER(V) {(V),PTHREAD_MUTEX_INITIALIZER,PTHREAD_COND_INITIALIZER}
void atom_set(atom a, long value);
void atom_unset(atom a);
void atom_add_and_signal(atom a, long toBeAdded);
void atom_wait_count(atom a, long count);
pthread_t _launchThread(test_t *test, void *(*start_routine)(void *), void* data, int what);

#ifdef WO451
// WO451 fails if RCOUNT is too heavy, the reason for this is still unknown
#define RCOUNT 1000
#else
#define RCOUNT 1000000
#endif

struct pthread_data_t {
  long no;
  id o;
  atom atom;
  pthread_t thread;
  long collision;};

static void* _concurentAutorelease(void* data)
{
  struct pthread_data_t *d= (struct pthread_data_t *)data;
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
  atom_add_and_signal(d->atom, 1);
  return NULL;
}

#define TEST_JOIN  1
#define TEST_SLEEP 2
#define TEST_ATOM  3

#ifdef WO451
@interface NSAutoreleaseTestsThreadFakeLauncher : NSObject
- (void)fakeLaunch:(id)parameters ;
@end
@implementation NSAutoreleaseTestsThreadFakeLauncher
- (void)fakeLaunch:(id)parameters { }
@end
#endif

static void pool_threadAutorelease(test_t *test)
{
  id o;
  int state;
  struct pthread_data_t d1, d2, d3;
  struct atom_t struct_atom= STRUCT_ATOM_INITIALIZER(0);
  
#ifdef WO451
  //force some initializations under WO451
  [NSThread detachNewThreadSelector:@selector(fakeLaunch:) toTarget:[NSAutoreleaseTestsThreadFakeLauncher new] withObject:nil];
#endif

  o= [[NSObject alloc] init];
  d1.no= 1; d1.o= o; d1.atom= NULL;
  d2.no= 2; d2.o= o; d2.atom= NULL;
  d3.no= 3; d3.o= o; d3.atom= NULL;

  for (state=TEST_JOIN; state<=TEST_ATOM; state++) {
    if (state>TEST_JOIN) {d1.atom= &struct_atom; d2.atom= &struct_atom; d3.atom= &struct_atom;}
    struct_atom.value= 0; d1.collision= 0; d2.collision= 0; d3.collision= 0;
    d1.thread= _launchThread(test, _concurentAutorelease, &d1, state);
    d2.thread= _launchThread(test, _concurentAutorelease, &d2, state);
    d3.thread= _launchThread(test, _concurentAutorelease, &d3, state);
    if (d1.thread && d2.thread && d3.thread) {
      if (state==TEST_JOIN) {
        pthread_join(d1.thread,NULL);
        pthread_join(d2.thread,NULL);
        pthread_join(d3.thread,NULL);}
      else if (state==TEST_SLEEP) {
        while (struct_atom.value!=3) {
          usleep(1);}}
      else if (state==TEST_ATOM) {
        atom_wait_count(&struct_atom, 3);}}
    TASSERT_EQUALS(test, [o retainCount], 1, "retainCount %u != expected %u");
    TASSERT(test, d1.collision + d2.collision > 0, "retain  collisions 1:%ld 2:%ld", d1.collision, d2.collision);
    //printf("retain  collisions 1:%ld 2:%ld\n", d1.collision, d2.collision);
    }
  RELEASE(o);
}

test_t foundation_pool[]= {
  {"some"             ,NULL,pool_some             ,INTITIALIZE_TEST_T_END},
  {"threadAutorelease",NULL,pool_threadAutorelease,INTITIALIZE_TEST_T_END},
  {NULL}};

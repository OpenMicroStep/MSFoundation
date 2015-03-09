//
//  NSObject_test.m
//  MSFoundation
//
//  Created by Vincent Rouillé on 26/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#import "foundation_validate.h"

static int pool_some(void)
{
  int err= 0;
  NSObject *o1, *o2;
  NSAutoreleasePool *a1, *a2;
  o1= [NSObject new];
  o2= [NSObject new];
  err+= ASSERT_EQUALS([o1 retainCount], 1, "object retainCount should be $2$d, got %1$d");
  err+= ASSERT_EQUALS([o2 retainCount], 1, "object retainCount should be $2$d, got %1$d");
  a1= [[NSAutoreleasePool alloc] init];
  [[o1 retain] autorelease];
  [[o2 retain] autorelease];
  err+= ASSERT_EQUALS([o1 retainCount], 2, "object retainCount should be $2$d, got %1$d");
  err+= ASSERT_EQUALS([o2 retainCount], 2, "object retainCount should be $2$d, got %1$d");
  [[o2 retain] autorelease];
  err+= ASSERT_EQUALS([o2 retainCount], 3, "object retainCount should be $2$d, got %1$d");
  a2= [NSAutoreleasePool new];
  [[o1 retain] autorelease];
  [[o2 retain] autorelease];
  err+= ASSERT_EQUALS([o1 retainCount], 3, "object retainCount should be $2$d, got %1$d");
  err+= ASSERT_EQUALS([o2 retainCount], 4, "object retainCount should be $2$d, got %1$d");
  [a2 release];
  err+= ASSERT_EQUALS([o1 retainCount], 2, "object retainCount should be $2$d, got %1$d");
  err+= ASSERT_EQUALS([o2 retainCount], 3, "object retainCount should be $2$d, got %1$d");
  [a1 release];
  err+= ASSERT_EQUALS([o1 retainCount], 1, "object retainCount should be $2$d, got %1$d");
  err+= ASSERT_EQUALS([o2 retainCount], 1, "object retainCount should be $2$d, got %1$d");
  [o1 release];
  [o2 release];
  return err;
}

test_t foundation_pool[]= {
  {"some",NULL,pool_some,INTITIALIZE_TEST_T_END},
  {NULL}};

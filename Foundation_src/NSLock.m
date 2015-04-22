//
//  NSLock.m
//  MSFoundation
//
//  Created by Vincent Rouillé on 15/04/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#import "FoundationCompatibility_Private.h"

static struct timespec inline _NSDate_to_timespec(NSDate *limit)
{
  struct timespec timeout;
  NSTimeInterval ti = [limit timeIntervalSince1970];
  timeout.tv_sec = ti;
  timeout.tv_nsec = ((MSLong)(ti * 1000000000)) % 1000000000;
  return timeout;
}

@implementation NSLock

- (void)lock
{
  pthread_mutex_lock(&_lock);
}

- (void)unlock
{
  pthread_mutex_unlock(&_lock);
}

- (instancetype)init
{
  if (pthread_mutex_init(&_lock, NULL))
    DESTROY(self);
  return self;
}

- (void)dealloc
{
  pthread_mutex_destroy(&_lock);
  [super dealloc];
}

- (BOOL)tryLock
{
  return !pthread_mutex_trylock(&_lock);
}

- (BOOL)lockBeforeDate:(NSDate *)limit
{
  struct timespec timeout = _NSDate_to_timespec(limit);
  return !pthread_mutex_timedlock(&_lock, &timeout);
}

@end

@implementation NSRecursiveLock

- (instancetype)init
{
  if (pthread_mutex_init(&_lock, NULL))
    DESTROY(self);
  return self;
}

- (void)dealloc
{
  pthread_mutex_destroy(&_lock);
  [super dealloc];
}

- (void)lock
{
  pthread_mutex_lock(&_lock);
}

- (void)unlock
{
  pthread_mutex_unlock(&_lock);
}

- (BOOL)tryLock
{
  return !pthread_mutex_trylock(&_lock);
}

- (BOOL)lockBeforeDate:(NSDate *)limit
{
  struct timespec timeout = _NSDate_to_timespec(limit);
  return !pthread_mutex_timedlock(&_lock, &timeout);
}

@end

@implementation NSCondition

- (instancetype)init
{
  if (pthread_mutex_init(&_lock, NULL) || pthread_cond_init(&_cond, NULL))
    DESTROY(self);
  return self;
}

- (void)dealloc
{
  pthread_cond_destroy(&_cond);
  pthread_mutex_destroy(&_lock);
  [super dealloc];
}

- (void)lock
{
  pthread_mutex_lock(&_lock);
}

- (void)unlock
{
  pthread_mutex_unlock(&_lock);
}

- (void)wait
{
  pthread_cond_wait(&_cond, &_lock);
}

- (BOOL)waitUntilDate:(NSDate *)limit
{
  struct timespec timeout = _NSDate_to_timespec(limit);
  return !pthread_mutex_timedlock(&_lock, &timeout);
}
- (void)signal
{
  pthread_cond_signal(&_cond);
}
- (void)broadcast
{
  pthread_cond_broadcast(&_cond);
}

@end

@implementation NSConditionLock

- (instancetype)init
{
  return [self initWithCondition:0];
}

- (instancetype)initWithCondition:(NSInteger)condition
{
  if (pthread_mutex_init(&_lock, NULL) || pthread_cond_init(&_cond, NULL))
    DESTROY(self);
  else
    _condition = condition;
  return self;
}

- (void)dealloc
{
  pthread_cond_destroy(&_cond);
  pthread_mutex_destroy(&_lock);
  [super dealloc];
}

- (NSInteger)condition
{
  return _condition;
}

- (void)lock
{
  pthread_mutex_lock(&_lock);
}

- (void)unlock
{
  pthread_mutex_unlock(&_lock);
}

- (void)lockWhenCondition:(NSInteger)condition
{
  pthread_mutex_lock(&_lock);
  while (condition != _condition)
    pthread_cond_wait(&_cond, &_lock);
}

- (BOOL)tryLock
{
  return !pthread_mutex_trylock(&_lock);
}
- (BOOL)tryLockWhenCondition:(NSInteger)condition
{
  BOOL ret= NO;
  if (!pthread_mutex_trylock(&_lock)) {
    if (condition == _condition)
      ret= YES;
    else
      pthread_mutex_unlock(&_lock);
  }
  return ret;
}
- (void)unlockWithCondition:(NSInteger)condition
{
  _condition= condition;
  pthread_cond_broadcast(&_cond);
  pthread_mutex_unlock(&_lock);
}
  
- (BOOL)lockBeforeDate:(NSDate *)limit
{
  struct timespec timeout = _NSDate_to_timespec(limit);
  return !pthread_mutex_timedlock(&_lock, &timeout);
}
- (BOOL)lockWhenCondition:(NSInteger)condition beforeDate:(NSDate *)limit
{
  struct timespec timeout = _NSDate_to_timespec(limit);
  if (!pthread_mutex_timedlock(&_lock, &timeout)) {
    if (condition == _condition)
      return YES;
    while (!pthread_mutex_timedlock(&_lock, &timeout))
      if (condition == _condition)
        return YES;
  }
  pthread_mutex_unlock(&_lock);
  return NO;
}

@end

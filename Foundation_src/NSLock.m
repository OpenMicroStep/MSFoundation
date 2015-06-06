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
  mtx_lock(&_lock);
}

- (void)unlock
{
  mtx_unlock(&_lock);
}

- (instancetype)init
{
  if (mtx_init(&_lock, mtx_plain | mtx_recursive))
    DESTROY(self);
  return self;
}

- (void)dealloc
{
  mtx_destroy(&_lock);
  [super dealloc];
}

- (BOOL)tryLock
{
  return !mtx_trylock(&_lock);
}

- (BOOL)lockBeforeDate:(NSDate *)limit
{
  struct timespec timeout = _NSDate_to_timespec(limit);
  return !mtx_timedlock(&_lock, &timeout);
}

@end

@implementation NSRecursiveLock

- (instancetype)init
{
  if (mtx_init(&_lock, mtx_timed | mtx_recursive))
    DESTROY(self);
  return self;
}

- (void)dealloc
{
  mtx_destroy(&_lock);
  [super dealloc];
}

- (void)lock
{
  mtx_lock(&_lock);
}

- (void)unlock
{
  mtx_unlock(&_lock);
}

- (BOOL)tryLock
{
  return !mtx_trylock(&_lock);
}

- (BOOL)lockBeforeDate:(NSDate *)limit
{
  struct timespec timeout = _NSDate_to_timespec(limit);
  return !mtx_timedlock(&_lock, &timeout);
}

@end

@implementation NSCondition

- (instancetype)init
{
  if (mtx_init(&_lock, mtx_plain) || cnd_init(&_cond))
    DESTROY(self);
  return self;
}

- (void)dealloc
{
  cnd_destroy(&_cond);
  mtx_destroy(&_lock);
  [super dealloc];
}

- (void)lock
{
  mtx_lock(&_lock);
}

- (void)unlock
{
  mtx_unlock(&_lock);
}

- (void)wait
{
  cnd_wait(&_cond, &_lock);
}

- (BOOL)waitUntilDate:(NSDate *)limit
{
  struct timespec timeout = _NSDate_to_timespec(limit);
  return !mtx_timedlock(&_lock, &timeout);
}
- (void)signal
{
  cnd_signal(&_cond);
}
- (void)broadcast
{
  cnd_broadcast(&_cond);
}

@end

@implementation NSConditionLock

- (instancetype)init
{
  return [self initWithCondition:0];
}

- (instancetype)initWithCondition:(NSInteger)condition
{
  if (mtx_init(&_lock, mtx_plain) || cnd_init(&_cond))
    DESTROY(self);
  else
    _condition = condition;
  return self;
}

- (void)dealloc
{
  cnd_destroy(&_cond);
  mtx_destroy(&_lock);
  [super dealloc];
}

- (NSInteger)condition
{
  return _condition;
}

- (void)lock
{
  mtx_lock(&_lock);
}

- (void)unlock
{
  mtx_unlock(&_lock);
}

- (void)lockWhenCondition:(NSInteger)condition
{
  mtx_lock(&_lock);
  while (condition != _condition)
    cnd_wait(&_cond, &_lock);
}

- (BOOL)tryLock
{
  return !mtx_trylock(&_lock);
}
- (BOOL)tryLockWhenCondition:(NSInteger)condition
{
  BOOL ret= NO;
  if (!mtx_trylock(&_lock)) {
    if (condition == _condition)
      ret= YES;
    else
      mtx_unlock(&_lock);
  }
  return ret;
}
- (void)unlockWithCondition:(NSInteger)condition
{
  _condition= condition;
  cnd_broadcast(&_cond);
  mtx_unlock(&_lock);
}
  
- (BOOL)lockBeforeDate:(NSDate *)limit
{
  struct timespec timeout = _NSDate_to_timespec(limit);
  return !mtx_timedlock(&_lock, &timeout);
}
- (BOOL)lockWhenCondition:(NSInteger)condition beforeDate:(NSDate *)limit
{
  struct timespec timeout = _NSDate_to_timespec(limit);
  if (!mtx_timedlock(&_lock, &timeout)) {
    if (condition == _condition)
      return YES;
    while (!mtx_timedlock(&_lock, &timeout))
      if (condition == _condition)
        return YES;
  }
  mtx_unlock(&_lock);
  return NO;
}

@end

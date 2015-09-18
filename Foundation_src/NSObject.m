#import "FoundationCompatibility_Private.h"

@implementation NSObject

// Retain/Release
// Sol 1: _retainCount++; / if (--_retainCount == -1)
//   BAD (not thread safe) and test fails (which proves the goodness of the test)
// Sol 2:
//   pthread_mutex_t _retainReleaseMutex= PTHREAD_MUTEX_INITIALIZER;
//   pthread_mutex_lock(&_retainReleaseMutex); _retainCount++; pthread_mutex_unlock(&_retainReleaseMutex);
//   long r; pthread_mutex_lock(&_retainReleaseMutex); r= --_retainCount; pthread_mutex_unlock(&_retainReleaseMutex); if (r == -1)
//   Very very inefficient
// Sol 3:
//   pthread_mutex_t _retainReleaseMutex= PTHREAD_MUTEX_INITIALIZER;
//   while (pthread_mutex_trylock(&_retainReleaseMutex)) { // already locked
//     struct timespec t= {0,100000}; nanosleep(&t, NULL);}
//   _retainCount++; pthread_mutex_unlock(&_retainReleaseMutex);
//   long r;
//   while (pthread_mutex_trylock(&_retainReleaseMutex)) {
//     struct timespec t= {0,100000}; nanosleep(&t, NULL);}
//   r= --_retainCount; pthread_mutex_unlock(&_retainReleaseMutex); if (r == -1)
//   Good, but sensible to the sleep gap so needs to be callibrated for each architecture.
// Sol 4: __sync_add_and_fetch(&_retainCount, 1); / if (__sync_sub_and_fetch(&_retainCount, 1) == -1)
//   Good, efficient but use more processor resources (clock) than Cocoa (but less time).
//   => retained because more stable, no configuration needed.

+ (instancetype)new
{
  return [[self alloc] init];
}

+ (instancetype)alloc
{
  return [self allocWithZone:NULL];
}

+ (instancetype)allocWithZone:(NSZone *)zone
{
  return NSAllocateObject(self, 0, NULL);
}

- (NSZone *)zone
{
  return nil;
}

- (instancetype)init
{
  return self;
}

- (instancetype)retain
{
  __sync_add_and_fetch(&_retainCount, 1);
  return self;
}

- (oneway void)release
{
  if (__sync_sub_and_fetch(&_retainCount, 1) == -1)
    [self dealloc];
}

- (instancetype)autorelease
{
  [NSAutoreleasePool addObject:self];
  return self;
}

- (NSUInteger)retainCount
{
  return _retainCount + 1;
}

- (void)dealloc
{
  NSDeallocateObject(self);
}

- (BOOL)isEqual:(id)object
{
  return self == object;
}

- (NSUInteger)hash
{
  return MSPointerHash(self);
}

- (NSUInteger)hash:(unsigned)depth
{
  return [self hash];
}

- (instancetype)self
{
  return self;
}

+ (Class)superclass
{
  return class_getSuperclass(self);
}

+ (Class)class
{
  return self;
}

- (Class)superclass
{
  return class_getSuperclass(ISA(self));
}

- (Class)class
{
  return ISA(self);
}

- (BOOL)isKindOfClass:(Class)aClass
{
  Class selfClass= ISA(self);
  while (selfClass && selfClass != aClass) {
    selfClass= class_getSuperclass(selfClass);
  }
  return selfClass == aClass;
}

- (BOOL)isMemberOfClass:(Class)aClass
{
  return ISA(self) == aClass;
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
  return class_conformsToProtocol(ISA(self), aProtocol);
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
  return class_respondsToSelector(ISA(self), aSelector);
}

- (id)performSelector:(SEL)aSelector
{
  IMP imp= objc_msg_lookup(self, aSelector);
  return imp(self, aSelector);
}

- (id)performSelector:(SEL)aSelector withObject:(id)object
{
  IMP imp= objc_msg_lookup(self, aSelector);
  return imp(self, aSelector, object);
}

- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2
{
  IMP imp= objc_msg_lookup(self, aSelector);
  return imp(self, aSelector, object1, object2);
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"<%s %p>", object_getClassName(self), self];
}

- (NSString *)debugDescription
{
  return [self description];
}

- (BOOL)isProxy
{
  return NO;
}

- (id)copy
{
  return [(id <NSCopying>)self copyWithZone:nil];
}

- (id)mutableCopy
{
  return [(id <NSMutableCopying>)self mutableCopyWithZone:nil];
}

+ (instancetype)retain
{
  return self;
}

+ (oneway void)release
{
}

+ (id)copy
{
  return self;
}

+ (id)copyWithZone:(NSZone *)zone
{
  MSUnused(zone);
  return self;
}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
   Method method; const char *types;

   method= class_getInstanceMethod(object_getClass(self), selector);
   types= method_getTypeEncoding(method);

   return types ? [NSMethodSignature signatureWithObjCTypes:types] : nil;
}

@end

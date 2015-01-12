//
//  MHThreadSafeProxy.m
//  _MicroStep
//
//  Created by Vincent Rouillé on 31/12/2014.
//
//

#import "MSNet_Private.h"

@implementation MSThreadSafeProxy
+ (id)threadSafeProxyWithObject:(id)obj
{
    return [[[self alloc] initWithObject:obj] autorelease];
}

- (id)initWithObject:(id)obj
{
    if ((self= [super init])) {
        _obj= [obj retain];
        mutex_init(_mutex);
    }
    return self;
}

- (void)dealloc
{
    [_obj release];
    mutex_delete(_mutex);
    [super dealloc];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *sig = [super methodSignatureForSelector:sel];
    if(!sig) {
        NS_DURING
        mutex_lock(_mutex);
        sig = [_obj methodSignatureForSelector:sel];
        mutex_unlock(_mutex);
        NS_HANDLER
        mutex_unlock(_mutex);
        [localException raise];
        NS_ENDHANDLER
    }
    return sig;
}

- (void)forwardInvocation:(NSInvocation *)inv
{
    NS_DURING
    mutex_lock(_mutex);
    [inv invokeWithTarget:_obj];
    mutex_unlock(_mutex);
    NS_HANDLER
    mutex_unlock(_mutex);
    [localException raise];
    NS_ENDHANDLER
}

@end

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
        mtx_init(&_mutex, mtx_plain);
    }
    return self;
}

- (void)dealloc
{
    [_obj release];
    mtx_destroy(&_mutex);
    [super dealloc];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *sig = [super methodSignatureForSelector:sel];
    if(!sig) {
        NS_DURING
        mtx_lock(&_mutex);
        sig = [_obj methodSignatureForSelector:sel];
        mtx_unlock(&_mutex);
        NS_HANDLER
        mtx_unlock(&_mutex);
        [localException raise];
        NS_ENDHANDLER
    }
    return sig;
}

- (void)forwardInvocation:(NSInvocation *)inv
{
    NS_DURING
    mtx_lock(&_mutex);
    [inv invokeWithTarget:_obj];
    mtx_unlock(&_mutex);
    NS_HANDLER
    mtx_unlock(&_mutex);
    [localException raise];
    NS_ENDHANDLER
}

@end

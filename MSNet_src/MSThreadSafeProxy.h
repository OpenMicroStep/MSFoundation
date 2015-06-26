//
//  MHThreadSafeProxy.h
//  _MicroStep
//
//  Created by Vincent Rouillé on 31/12/2014.
//
//

@interface MSThreadSafeProxy : NSObject {
    id _obj;
    mtx_t _mutex;
}
+ (id)threadSafeProxyWithObject:(id)obj;
- (id)initWithObject:(id)obj;

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel;
- (void)forwardInvocation:(NSInvocation *)inv;
@end

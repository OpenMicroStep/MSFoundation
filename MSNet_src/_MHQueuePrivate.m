//
//  MHQueue.m
//  MASH
//
//  Created by Geoffrey Guilbon on 22/06/12.
//  Copyright (c) 2012 Logitud Solutions. All rights reserved.
//

#import "_MASHPrivate.h"

@implementation MHQueue


+ (id)createQueueWithElementPool:(CElementPool *)pool
{
    return [ALLOC(self) initQueueWithElementPool:pool] ;
}

- (id)initQueueWithElementPool:(CElementPool *)pool
{
    if(!pool) MSRaiseFrom(NSInternalInconsistencyException, self, _cmd, @"MHQueue : pool must be allocated");

    _pool = pool ;
    _count = 0 ;
    _firstElement = _lastElement = NULL ;
    
    return self ;
}

- (void)_enqueueElement:(CQueueElement *)e
{
    e->previousElement = NULL ;
    e->nextElement = _firstElement ;
    _firstElement = e ;
    
    if(e->nextElement)
    {
        e->nextElement->previousElement = e ;
    }
    if(!_count) _lastElement = e ;
    
    _count++ ;
}

- (BOOL)enqueue:(id)object
{
    CQueueElement *e ;
    
    if(!object) return NO ;
    
    e = CElementPoolGetElement(_pool) ;
    if (e) {
        e->object = object ;
        [self _enqueueElement:e] ;
        return YES ;
    }
    return NO ;
}

- (CQueueElement *)_dequeueElement
{
    CQueueElement *e ;
 
    if(_count == 0) return NULL ;
    
    e = _lastElement ;
    
    if(e->previousElement)
    {
        e->previousElement->nextElement = NULL ;
        _lastElement = e->previousElement ;
    }
    else {
        _lastElement = NULL ;
    }
    _count-- ;
    if(!_count) _firstElement = NULL ;
    
    return e ;
}

- (id)dequeue
{
    id object ;
    CQueueElement *e ;
    
    if(!(e = [self _dequeueElement])) return NULL ;
    object = e->object ;
    
    CElementPoolPutElement(_pool,e) ;

    return object ;
}

- (MSUInt)count 
{
    return _count ;
}

@end

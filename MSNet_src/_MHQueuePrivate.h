//
//  MHQueue.h
//  MASH
//
//  Created by Geoffrey Guilbon on 22/06/12.
//  Copyright (c) 2012 Logitud Solutions. All rights reserved.
//
#import "_MASHPrivate.h"

typedef struct CQueueElementStruct CQueueElement ;
struct CQueueElementStruct
{
    CQueueElement *nextElement ;
    CQueueElement *previousElement ;
    CQueueElement *nextPoolElement ;
    CQueueElement *previousPoolElement ;
    id object ;
} ;

typedef struct CElementPoolStruct
{
    MSUInt size ;
    CQueueElement *pool ;
    CQueueElement *freeElements ;
    CQueueElement *usedElements ;
    mutex_t elementPoolMutex ;
} CElementPool ;

static inline CElementPool *CElementPoolCreate(MSUInt size)
{
    CElementPool *self = (CElementPool *)MSMalloc(sizeof(CElementPool), "CElementPoolCreate()") ;
    if  (self)
    {
        mutex_init(self->elementPoolMutex) ;
        if (size > 0)
        {
            if (!(self->pool = (CQueueElement *)MSMalloc(size * sizeof(CQueueElement), "CElementPoolCreate() : elements allocation")))
            {
                MSFree(self, "CElementPoolCreate() : error in elements allocation") ;
                return NULL ;
            }
            else
            {
                MSUInt i ;
                MSUInt lastButOne = size - 1 ;

                CQueueElement *e = NULL ;
                CQueueElement *next = self->pool ;
                self->usedElements = NULL ;
                self->freeElements = self->pool ;

                for(i=0; i<lastButOne; i++)
                {
                    e = next++ ;
                    e->nextPoolElement = next ;
                }
                e->nextPoolElement->nextPoolElement = NULL ;
            }
        }
    }

    self->size = size ;
    return self ;
    return NULL;
}

static inline void CElementPoolFree(CElementPool *self)
{
    if (self) { 
        if (self->pool) free(self->pool) ;  
        mutex_delete(self->elementPoolMutex) ;
        free(self) ; 
    }
}

static inline CQueueElement *CElementPoolGetElement(CElementPool *pool)
{
    if(pool && pool->freeElements)
    {
        CQueueElement *e = NULL ;
        mutex_lock(pool->elementPoolMutex) ;
        e = pool->freeElements;
        pool->freeElements = e->nextPoolElement ;

        e->nextPoolElement = pool->usedElements ;
        e->previousPoolElement = NULL ;
        pool->usedElements = e ;

        if(e->nextPoolElement)
        {
            e->nextPoolElement->previousPoolElement = e ;
        }
        mutex_unlock(pool->elementPoolMutex) ;
        return e;
    }

    return NULL;
}

static inline void CElementPoolPutElement(CElementPool *pool,CQueueElement *e)
{
    if(pool && e)
    {
        mutex_lock(pool->elementPoolMutex) ;
        if(e->nextPoolElement)
        {
            e->nextPoolElement->previousPoolElement = e->previousPoolElement ;
        }
        if(e->previousPoolElement)
        {
            e->previousPoolElement->nextPoolElement = e->nextPoolElement ;
        }

        e->nextPoolElement = pool->freeElements ;
        e->previousPoolElement = NULL ;
        pool->freeElements = e ;
        mutex_unlock(pool->elementPoolMutex) ;
    }
}

#define MHCreatePool(X) CElementPoolCreate(X) ;
#define MHGetPoolElement(X) CElementPoolGetElement(X) ;
#define MHPutPoolElement(X,Y) CElementPoolPutElement(X,Y) ;

@interface MHQueue : NSObject
{
    CQueueElement *_firstElement ;
    CQueueElement *_lastElement ;
    MSUInt _count ;
    CElementPool *_pool ;
}

+ (id)createQueueWithElementPool:(CElementPool *)pool ;
- (id)initQueueWithElementPool:(CElementPool *)pool ;
- (BOOL)enqueue:(id)object ;
- (id)dequeue ;
- (MSUInt)count ;


@end

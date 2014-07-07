//
//  MSThread2.m
//  MSFoundation
//
//  Created by JEAN-MICHEL BERTHEAS on 27/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MSNet_Private.h"

#ifndef WIN32

event_t _create_event(event_t evt, int initval)
{
    evt = (real_event_t *)malloc(sizeof(real_event_t));
    if(evt)
    {
        if(pthread_mutex_init(&evt->mutex, NULL))
        {
            free(evt);
            return NULL;
        }
        if(pthread_cond_init(&evt->condition, NULL))
        {
            free(evt);
            return NULL;
        }
        evt->flag = initval;
    }
    return evt;
}

// renvoyer code != 0 en cas d'echec ?
int event_wait(event_t evt)
{
    pthread_mutex_lock(&evt->mutex);
    while(!evt->flag)
        pthread_cond_wait(&evt->condition, &evt->mutex);
    
    evt->flag = 0;
    pthread_mutex_unlock(&evt->mutex);
    return 0;
}

void event_set(event_t evt)
{
    pthread_mutex_lock(&evt->mutex);
    evt->flag = 1;
    pthread_mutex_unlock(&evt->mutex);
    pthread_cond_signal(&evt->condition);
}

void event_delete(event_t evt)
{
    pthread_mutex_destroy(&evt->mutex);
    pthread_cond_destroy(&evt->condition);
    evt->flag = 0;
    free(evt);
}

#endif

#ifdef __linux__
#elif __APPLE__

semaphore_t _semaphore_init(unsigned int init, const char *name)
{
    semaphore_t x;
    sem_unlink(name);
    x = sem_open(name, O_CREAT, 0, init);
    if(x == SEM_FAILED) return NULL;
    return x;
}

#endif

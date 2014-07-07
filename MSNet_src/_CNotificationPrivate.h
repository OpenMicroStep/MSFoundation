/*
 
 _CNotification.h
 
 This file is is a part of the MicroStep Application Server over Http Framework.
 
 Initial copyright LOGITUD Solutions (logitud@logitud.fr) since 2012
 
 Herve Malaingre : herve@malaingre.com
 Jean-Michel Bertheas :  jean-michel.bertheas@club-internet.fr
 
 
 This software is a computer program whose purpose is to [describe
 functionalities and technical features of your software].
 
 This software is governed by the CeCILL-C license under French law and
 abiding by the rules of distribution of free software.  You can  use, 
 modify and/ or redistribute the software under the terms of the CeCILL-C
 license as circulated by CEA, CNRS and INRIA at the following URL
 "http://www.cecill.info". 
 
 As a counterpart to the access to the source code and  rights to copy,
 modify and redistribute granted by the license, users are provided only
 with a limited warranty  and the software's author,  the holder of the
 economic rights,  and the successive licensors  have only  limited
 liability. 
 
 In this respect, the user's attention is drawn to the risks associated
 with loading,  using,  modifying and/or developing or reproducing the
 software by the user in light of its specific status of free software,
 that may mean  that it is complicated to manipulate,  and  that  also
 therefore means  that it is reserved for developers  and  experienced
 professionals having in-depth computer knowledge. Users are therefore
 encouraged to load and test the software's suitability as regards their
 requirements in conditions enabling the security of their systems and/or 
 data to be ensured and,  more generally, to use and operate it in the 
 same conditions as regards security. 
 
 The fact that you are presently reading this means that you have had
 knowledge of the CeCILL-C license and that you accept its terms.
 
 */

#import "MSNet_Private.h"

static MHBunchAllocator *__notificationBunchAllocator = nil ;

typedef struct CNotificationStruct CNotification ;

struct CNotificationStruct
{
    Class isa ; /* here only to bind this structure to an objective-c object */
    CBunch *bunch ;
    MSULong localRetainCount ;
    MHHTTPMessage *message ;
//    MHContext *context ;
    MHSession *session ;
    id originalTarget ;
    id target ;
    id<MHSocketReceiver> receiverDelegate ;
    NSString *action ;
    NSString *finalAction ;
    NSMutableDictionary *members ;
    MSInt fd ;
    id _secureSocket ;
    MSTimeInterval expirationDate ;
    MSUInt failureReason ;
    MSBuffer *readBuffer ;
    MSBuffer *delayedWriteBuffer ;
    BOOL delayedSSLSocket ;
    MSUInt delayedTimeOutInSeconds ;
    MHNotificationType notificationType ;
    BOOL isAdminNotification ;
} ;

//static inline CNotification *CNotificationCreate(MHHTTPMessage *message, MHContext *context, id retainedTarget, NSString *retainedAction, BOOL isResource, BOOL isAdmin)
static inline CNotification *CNotificationCreate(MHHTTPMessage *message, MHSession *session, id retainedTarget, NSString *retainedAction, MHNotificationType notificationType, BOOL isAdmin)
{
    CNotification *self = NULL;
    CBunch *objectBunch = NULL ;
    Class notificationClass = [MHNotification class] ;

    if (!__notificationBunchAllocator) __notificationBunchAllocator = getBunchAllocatorForClass(notificationClass, [MHNotification defaultBunchSize]) ;
    if (!__notificationBunchAllocator) MSRaise(NSGenericException, @"CNotificationCreate() : Error while getting bunch allocator for class %@", NSStringFromClass(notificationClass)) ;
        
    self = (CNotification *)[__notificationBunchAllocator newBunchObjectIntoBunch:&objectBunch] ;
    if  (self && objectBunch) {
        self->bunch = objectBunch ;
        self->localRetainCount = 1 ;
        self->message = RETAIN(message) ; //retainedMessage must be an already retained object
//        self->context = retainedContext ; //retainedContext must be an already retained object 
        self->session = RETAIN(session) ; //session must NOT be a retained object 
        self->receiverDelegate = nil ; 
        self->originalTarget = retainedTarget ; //retainedTarget must be an already retained object
        self->target = retainedTarget ; //retainedTarget must be an already retained object
        self->action = retainedAction ; //retainedAction must be an already retained object
        self->finalAction = nil ;
        self->members = nil ;
        self->fd = 0 ;
        self->_secureSocket = nil ;
        self->expirationDate = 0 ;
        self->failureReason = MH_FAILURE_REASON_NONE ;
        self->readBuffer = nil ;
        self->delayedWriteBuffer = nil ;
        self->delayedSSLSocket = NO ;
        self->delayedTimeOutInSeconds  = 0;
        self->notificationType = notificationType ;
        self->isAdminNotification = isAdmin ;
    }
    return self ;
}


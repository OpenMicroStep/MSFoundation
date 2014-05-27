/*
 
 _CHTTPMessage.h
 
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
#ifndef MH_HTTP_MAX_MANAGED_HEADERS
#define MH_HTTP_MAX_MANAGED_HEADERS 20
#define MH_HTTP_MAX_HEADERS_SIZE 2048
#endif

static MHBunchAllocator *__httpMessageBunchAllocator = nil ;

typedef struct CHTTPMessageStruct CHTTPMessage ;

@class MHSSLSocket ;

struct CHTTPMessageStruct
{
    Class isa ; /* here only to bind this structure to an objective-c object */
    CBunch *bunch ;
    MSULong localRetainCount ;
    MHSSLSocket *secureSocket ;
    MSShort isHead ;
    MSShort isParsed ;
    char *headers[MH_HTTP_MAX_MANAGED_HEADERS] ;
    char buf[MH_HTTP_MAX_HEADERS_SIZE] ;
    MSUInt bufferLength ;
    MSUInt bodySize ;
    MSUInt fullBodySize ;
    CHTTPMessage *messageContinuation ;
    MSBuffer *completeBody ;
} ;

static inline CHTTPMessage *CHTTPMessageCreateIsHead(MHSSLSocket *secureSocket, const void *bytes, MSUInt length, CHTTPMessage **lastMessage, MSShort isHead)
{
    CHTTPMessage *self = NULL;
    CBunch *objectBunch = NULL ;
    Class httpMessageClass = [MHHTTPMessage class] ;
    
    if (!__httpMessageBunchAllocator) __httpMessageBunchAllocator = getBunchAllocatorForClass(httpMessageClass, [MHHTTPMessage defaultBunchSize]) ;
    if (!__httpMessageBunchAllocator) MSRaise(NSGenericException, @"CHTTPMessageCreateIsHead() : Error while getting bunch allocator for class %@", NSStringFromClass(httpMessageClass)) ;
    
    self = (CHTTPMessage *)[__httpMessageBunchAllocator newBunchObjectIntoBunch:&objectBunch] ;
    if  (self && objectBunch && secureSocket) {
        self->bunch = objectBunch ;
        self->localRetainCount = 1 ;
        self->secureSocket = secureSocket ;
        if (isHead) RETAIN(secureSocket) ;
        self->isHead = isHead ;
        self->isParsed = 0 ;
        self->bodySize = 0 ;
        self->fullBodySize = 0 ;
        self->completeBody = nil ;
        
        if (bytes && length) {
            if (length <= MH_HTTP_MAX_HEADERS_SIZE) {
                //all bytes can enter in the current message
                memcpy(self->buf, bytes, length) ;
                self->bufferLength = length ;
                self->messageContinuation = NULL ;
                if (lastMessage) *lastMessage = NULL ;
            }
            else {
                //only a part of bytes can enter in the current message
                CHTTPMessage *tempLastMessage = NULL ;
                memcpy(self->buf, bytes, MH_HTTP_MAX_HEADERS_SIZE) ;
                self->bufferLength = MH_HTTP_MAX_HEADERS_SIZE ;
                self->messageContinuation = CHTTPMessageCreateIsHead(secureSocket, bytes+MH_HTTP_MAX_HEADERS_SIZE, length-MH_HTTP_MAX_HEADERS_SIZE, &tempLastMessage, 0) ;
                if (lastMessage) {
                    if (tempLastMessage) {
                        *lastMessage = tempLastMessage ;   
                    }
                    else {
                        *lastMessage = self->messageContinuation ; 
                    }   
                }
            }
        }
        else {
            self->bufferLength = 0 ;
            self->messageContinuation = NULL ;
            if (lastMessage) *lastMessage = NULL ;
        }
        return self ;
    }
    return NULL ;
}

//this function returns the head message and the last queued message in the lastMessage parameter
static inline CHTTPMessage *CHTTPMessageCreate(MHSSLSocket *secureSocket, const void *bytes, MSUInt length, CHTTPMessage **lastMessage)
{
    return CHTTPMessageCreateIsHead(secureSocket, bytes, length, lastMessage, 1) ;
}

//this function appends bytes to message parameter and returns the last queued message in the lastMessage parameter
static inline void CHTTPMessageAppendBytes(CHTTPMessage *message, const void *bytes, MSUInt length, CHTTPMessage **lastMessage)
{
    if (message && bytes && length) {
        if (message->bufferLength<MH_HTTP_MAX_HEADERS_SIZE) {
            //we can continue to put some bytes in this message
            if (message->bufferLength) {
                //current message is not empty
                if ((MH_HTTP_MAX_HEADERS_SIZE - message->bufferLength) >= length) {
                    //enought place in current message to store the bytes
                    memcpy(message->buf + message->bufferLength, bytes, length) ;
                    message->bufferLength += length ;
                    message->messageContinuation = NULL ;
                    if(lastMessage) *lastMessage = NULL ;
                }
                else {
                    //not enought place in current message
                    CHTTPMessage *tempLastMessage = NULL ;
                    //fill up the current message
                    memcpy(message->buf + message->bufferLength, bytes, MH_HTTP_MAX_HEADERS_SIZE - message->bufferLength) ;
                    //store the remaining bytes in the next message
                    message->messageContinuation = CHTTPMessageCreateIsHead(message->secureSocket,
                                                                            bytes + (MH_HTTP_MAX_HEADERS_SIZE - message->bufferLength),
                                                                            length - (MH_HTTP_MAX_HEADERS_SIZE - message->bufferLength),
                                                                            &tempLastMessage,
                                                                            0) ;
                    message->bufferLength = MH_HTTP_MAX_HEADERS_SIZE ;
                    
                    if (lastMessage) {
                        if (tempLastMessage) {
                            *lastMessage = tempLastMessage ;   
                        }
                        else {
                            *lastMessage = message->messageContinuation ; 
                        }
                    }
                }
            }
            else {
                //current message is empty
                if (length <= MH_HTTP_MAX_HEADERS_SIZE) {
                    //all bytes can enter in the current message
                    memcpy(message->buf, bytes, length) ;
                    message->bufferLength = length ;
                    message->messageContinuation = NULL ;
                    if(lastMessage) *lastMessage = NULL ;
                }
                else {
                    //only a part of bytes can enter in the current message
                    CHTTPMessage *tempLastMessage = NULL ;
                    memcpy(message->buf, bytes, MH_HTTP_MAX_HEADERS_SIZE) ;
                    message->bufferLength = MH_HTTP_MAX_HEADERS_SIZE ;
                    message->messageContinuation = CHTTPMessageCreateIsHead(message->secureSocket, bytes+MH_HTTP_MAX_HEADERS_SIZE, length-MH_HTTP_MAX_HEADERS_SIZE, &tempLastMessage, 0) ;
                    if (lastMessage) {
                        if (tempLastMessage) {
                            *lastMessage = tempLastMessage ;   
                        }
                        else {
                            *lastMessage = message->messageContinuation ; 
                        }
                    }
                }
            }
        }
        else {
            //we should put bytes in another message
            if (message->messageContinuation) {
                MSRaise(NSGenericException, @"CHTTPMessageAppendBytes() : Error while appending bytes in an already full message") ;
            }
            else {
                CHTTPMessage *tempLastMessage = NULL ;
                message->messageContinuation = CHTTPMessageCreateIsHead(message->secureSocket, bytes, length, &tempLastMessage, 0) ;
                if (lastMessage) {
                    if (tempLastMessage) {
                        *lastMessage = tempLastMessage ;   
                    }
                    else {
                        *lastMessage = message->messageContinuation ; 
                    }
                }
            }
        }
    }
    else {
        MSRaise(NSGenericException, @"CHTTPMessageAppendBytes() : Nothing to append") ;
    }
}

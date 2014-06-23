/*
 
 MHMessengerMessage.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Geoffrey Guilbon : gguilbon@gmail.com
 Jean-Michel Berthéas : jean-michel.bertheas@club-internet.fr
 
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

#import "_MASHPrivate.h"
#import "MHMessengerMessage.h"

//mandatory flags
#define FLAG_FOUND_MAND_ENV_SENDER         0x1
#define FLAG_FOUND_MAND_ENV_RECIPIENTS     0x2
#define FLAG_FOUND_MAND_ENV_THREAD         0x4
#define FLAG_FOUND_MAND_ENV_CREATION_DATE  0x8
#define FLAG_FOUND_MAND_ENV_VALIDITY       0x10
#define FLAG_FOUND_MAND_ENV_PRIORITY       0x20
#define FLAG_FOUND_MAND_ENV_STATUS         0x40
#define FLAG_FOUND_MAND_ENV_CONTENT_TYPE   0x80

#define MANDATORY_FLAGS_SUM             (FLAG_FOUND_MAND_ENV_SENDER \
| FLAG_FOUND_MAND_ENV_RECIPIENTS \
| FLAG_FOUND_MAND_ENV_THREAD \
| FLAG_FOUND_MAND_ENV_CREATION_DATE \
| FLAG_FOUND_MAND_ENV_VALIDITY \
| FLAG_FOUND_MAND_ENV_PRIORITY \
| FLAG_FOUND_MAND_ENV_STATUS \
| FLAG_FOUND_MAND_ENV_CONTENT_TYPE)

//additional flags
#define FLAG_FOUND_ENV_MESSAGE_ID          0x1 //set only on messenger
#define FLAG_FOUND_ENV_RECEIVING_DATE      0x2 //can be set on proxy
#define FLAG_FOUND_ENV_EXTERNAL_REF        0x4 //optional
#define FLAG_FOUND_ENV_ROUTE               0x8 //can be set on proxy

#define ENVELOPE_INIT_BUF_SIZE 256

#define INT_TO_STRING(X) [[NSNumber numberWithInt:X] stringValue]
#define INTERVAL_TO_STRING(X) [[NSNumber numberWithLongLong:X] stringValue]

#define ADD_ASCII_ENVELOPE_PARAMETER_STRING(B,H,S) if(S) { \
    NSString *tmp = [NSString stringWithFormat:@"%@: %@\r\n",H,S] ; \
    CBufferAppendData(B, [tmp dataUsingEncoding:NSASCIIStringEncoding]) ; \
} \

#define ADD_ASCII_ENVELOPE_PARAMETER_INT(B,H,I) ADD_ASCII_ENVELOPE_PARAMETER_STRING(B,H,INT_TO_STRING(I))
#define ADD_ASCII_ENVELOPE_PARAMETER_INTERVAL(B,H,I) ADD_ASCII_ENVELOPE_PARAMETER_STRING(B,H,INTERVAL_TO_STRING(I))

@implementation MHMessengerMessage

+ (id)messageFrom:(NSString *)sender to:(NSString *)recipient thread:(NSString *)thread contentType:(NSString *)contentType content:(MSBuffer *)content
{
    return [[[self alloc] initMessageFrom:sender to:recipient thread:thread contentType:contentType content:content] autorelease] ;
}

- (id)initMessageFrom:(NSString *)sender to:(NSString *)recipient thread:(NSString *)thread contentType:(NSString *)contentType content:(MSBuffer *)content
{
    [self setContent:content] ;
    return [self initMessageFrom:sender to:recipient thread:thread contentType:contentType] ;
}

+ (id)messageFrom:(NSString *)sender to:(NSString *)recipient thread:(NSString *)thread contentType:(NSString *)contentType base64Content:(MSBuffer *)content
{
    return [[[self alloc] initMessageFrom:sender to:recipient thread:thread contentType:contentType base64Content:content] autorelease] ;
}

- (id)initMessageFrom:(NSString *)sender to:(NSString *)recipient thread:(NSString *)thread contentType:(NSString *)contentType base64Content:(MSBuffer *)content
{
    if ([self initMessageFrom:sender to:recipient thread:thread contentType:contentType]) {
        [self setBase64Content:content] ;
        return self ;
    }
    return nil ;
}

+ (id)messageWithBuffer:(MSBuffer *)buffer envelopeType:(MHMessengerEnvelopeType)envelopeType envelopeLength:(MSULong)envelopeLength error:(NSString **)error
{
    return [[[self alloc] initWithBuffer:buffer envelopeType:envelopeType envelopeLength:envelopeLength error:error] autorelease] ;
}

- (void)_setError:(NSString *)value inString:(NSString **)str
{
    if (str) { *str = value ; }
}

- (id)initWithBuffer:(MSBuffer *)buffer envelopeType:(MHMessengerEnvelopeType)envelopeType envelopeLength:(MSULong)envelopeLength error:(NSString **)error
{    
    char  *bytes = (char *)((CBuffer *)buffer)->buf ;
    MSULong length = ((CBuffer *)buffer)->length ;
    
    MHMessengerMessage *message = nil ;
    
    if(length && envelopeType && envelopeLength)
    {
        char *bodyStart = 0 ;
        MSLong bodyLength = 0 ;

        //mandatory
        NSString *sender = nil ;
        MSArray *recipients = nil ;
        NSString *thread = nil ;
        NSString *contentType = nil ;
        MSTimeInterval creationDate ;
        MSTimeInterval validity ;
        MHMessengerPriority priority ;
        MSInt status ;
        MSBuffer *content = nil ;
        
        //addings
        NSString *route = nil ;
        //MSDate *receivingDate = nil ; // Unused
        NSString *messageID = nil ;
        
        //optional
        NSString *externalReference = nil ;

        MSByte mandatoryFoundFlags = 0 ;
        MSByte additionalFoundFlags = 0 ;

        if (envelopeType == MHMEnvelopeTypeMSTE) { //envelopeTypeMSTE
            id value = nil ;
            NSDictionary *envelope = nil ;
            MSBuffer *envelopeBuffer = nil ;
            
            bodyStart = bytes + envelopeLength + 2 ; //pass ," just after the mste envelope
            bodyLength = length - envelopeLength - 4; // decrease the length of ," just after the mste envelope, and the "] at the end
                
            if(!bodyLength || bodyLength>length)
            {
                [self _setError:@"message parsing error : no body found" inString:error] ;
                return nil ;
            }

            envelopeBuffer = MSCreateBufferWithBytesNoCopyNoFree((void *)([buffer bytes]+1),    //after the first '[' character
                                                                 (NSUInteger)(envelopeLength-1) //do not take the first '[' character
                                                                ) ;
                
            NS_DURING
                envelope = (NSDictionary *)[envelopeBuffer MSTDecodedObject] ;
            NS_HANDLER
                envelope = nil ;
            NS_ENDHANDLER
                
            if (![envelope isKindOfClass:[NSDictionary class]]) {
                [self _setError:[NSString stringWithFormat:@"message parsing error : MSTE envelope is not a sub classe of NSDictionary"] inString:error] ;
                return nil ;
            }
                
            //check mandatory envelope headers
            value = [envelope objectForKey:MESSENGER_ENV_SENDER] ;
            if (value && [value isKindOfClass:[NSString class]]) {
                mandatoryFoundFlags |= FLAG_FOUND_MAND_ENV_SENDER ;
                sender = value ;
            }
            
            value = [envelope objectForKey:MESSENGER_ENV_RECIPIENTS] ;
            if (value && [value isKindOfClass:[NSString class]]) {
                mandatoryFoundFlags |= FLAG_FOUND_MAND_ENV_RECIPIENTS ;
                recipients =  [MSArray arrayWithArray:[value componentsSeparatedByString:@","]]  ;
            }

            value = [envelope objectForKey:MESSENGER_ENV_THREAD] ;
            if (value && [value isKindOfClass:[NSString class]]) {
                mandatoryFoundFlags |= FLAG_FOUND_MAND_ENV_THREAD ;
                thread = value ;
            }

            value = [envelope objectForKey:MESSENGER_ENV_CREATION_DATE] ;
            if (value && [value isKindOfClass:[NSString class]]) {
                mandatoryFoundFlags |= FLAG_FOUND_MAND_ENV_CREATION_DATE ;
                creationDate = [value longLongValue] ;
            }
                
            value = [envelope objectForKey:MESSENGER_ENV_VALIDITY] ;
            if (value && [value isKindOfClass:[NSString class]]) {
                mandatoryFoundFlags |= FLAG_FOUND_MAND_ENV_VALIDITY ;
                validity = [value longLongValue] ;
            }
                
            value = [envelope objectForKey:MESSENGER_ENV_PRIORITY] ;
            if (value && [value isKindOfClass:[NSString class]]) {
                mandatoryFoundFlags |= FLAG_FOUND_MAND_ENV_PRIORITY ;
                priority = [value intValue] ;
            }

            value = [envelope objectForKey:MESSENGER_ENV_STATUS] ;
            if (value && [value isKindOfClass:[NSString class]]) {
                mandatoryFoundFlags |= FLAG_FOUND_MAND_ENV_STATUS ;
                status = [value intValue] ;
            }
                
            value = [envelope objectForKey:MESSENGER_ENV_CONTENT_TYPE] ;
            if (value && [value isKindOfClass:[NSString class]]) {
                mandatoryFoundFlags |= FLAG_FOUND_MAND_ENV_CONTENT_TYPE ;
                contentType = value ;
            }
                
            //check additionnal envelope headers
            value = [envelope objectForKey:MESSENGER_ENV_MESSAGE_ID] ;
            if (value && [value isKindOfClass:[NSString class]]) {
                additionalFoundFlags |= FLAG_FOUND_ENV_MESSAGE_ID ;
                messageID = value ;
            }
                
            value = [envelope objectForKey:MESSENGER_ENV_RECEIVING_DATE] ;
            if (value && [value isKindOfClass:[NSString class]]) {
                additionalFoundFlags |= FLAG_FOUND_ENV_RECEIVING_DATE ;
                // receivingDate non utilisée
                //receivingDate = [MSDate dateWithSecondsSince1970:[value longLongValue]] ;
            }
                
            value = [envelope objectForKey:MESSENGER_ENV_EXTERNAL_REF] ;
            if (value && [value isKindOfClass:[NSString class]]) {
                additionalFoundFlags |= FLAG_FOUND_ENV_EXTERNAL_REF ;
                externalReference = value ;
            }
                
            value = [envelope objectForKey:MESSENGER_ENV_ROUTE] ;
            if (value && [value isKindOfClass:[NSString class]]) {
                additionalFoundFlags |= FLAG_FOUND_ENV_ROUTE ;
                route = value ;
            }
        }
        else { //envelopeTypePlain
            char *headerStart = bytes ;
            char *headerEnd = NULL ;
            unsigned long remainingEnvBytes = envelopeLength ;
            MSASCIIString *headerLine ;
            NSArray *split ;
            long headerLineLength ;
            
            bodyStart = bytes + envelopeLength ;
            bodyLength = length - envelopeLength ;
            
            if(!bodyLength || bodyLength>length)
            {
                [self _setError:@"message parsing error : no body found" inString:error] ;
                return nil ;
            }
                
            headerEnd = strnstr(headerStart, "\r\n", remainingEnvBytes) ;
                
            while (headerEnd && (headerEnd < bodyStart)) {
                    
                headerLineLength = headerEnd - headerStart ;
                    
                if (headerLineLength) { //get & split enveloppe header and value
                    headerLine = [MSASCIIString stringWithBytes:headerStart length:headerLineLength] ;
                    split = [headerLine componentsSeparatedByString:@": "] ;
                        
                    if([split count] < 2)
                    {
                        [self _setError:@"message parsing error : invalid header format" inString:error] ;
                        return nil ;
                    } else {
                        NSString *header = [split objectAtIndex:0] ;
                        NSString *value = [split objectAtIndex:1] ;
                            
                            
                        //check mandatory envelope headers
                        if([MESSENGER_ENV_SENDER isEqualToString:header])
                        {
                            if(mandatoryFoundFlags & FLAG_FOUND_MAND_ENV_SENDER) {
                                [self _setError:[NSString stringWithFormat:@"message parsing error : header found twice :'%@'", MESSENGER_ENV_SENDER] inString:error] ;
                                return nil ;
                            }
                            mandatoryFoundFlags |= FLAG_FOUND_MAND_ENV_SENDER ;
                            sender = value ;
                            
                        } else if ([MESSENGER_ENV_RECIPIENTS isEqualToString:header])
                        {
                            if(mandatoryFoundFlags & FLAG_FOUND_MAND_ENV_RECIPIENTS) {
                                [self _setError:[NSString stringWithFormat:@"message parsing error : header found twice :'%@'", MESSENGER_ENV_RECIPIENTS] inString:error] ;
                                return nil ;
                            }
                            mandatoryFoundFlags |= FLAG_FOUND_MAND_ENV_RECIPIENTS ;
                            recipients =  [MSArray arrayWithArray:[value componentsSeparatedByString:@","]]  ;
                                
                        } else if ([MESSENGER_ENV_THREAD isEqualToString:header])
                        {
                            if(mandatoryFoundFlags & FLAG_FOUND_MAND_ENV_THREAD) {
                                [self _setError:[NSString stringWithFormat:@"message parsing error : header found twice :'%@'", MESSENGER_ENV_THREAD] inString:error] ;
                                return nil ;
                            }
                            mandatoryFoundFlags |= FLAG_FOUND_MAND_ENV_THREAD ;
                            thread = value ;
                                
                        } else if ([MESSENGER_ENV_CREATION_DATE isEqualToString:header])
                        {
                            if(mandatoryFoundFlags & FLAG_FOUND_MAND_ENV_CREATION_DATE) {
                                [self _setError:[NSString stringWithFormat:@"message parsing error : header found twice :'%@'", MESSENGER_ENV_CREATION_DATE] inString:error] ;
                                return nil ;
                            }
                            mandatoryFoundFlags |= FLAG_FOUND_MAND_ENV_CREATION_DATE ;
                            creationDate = [value longLongValue] ;
                                
                        } else if ([MESSENGER_ENV_VALIDITY isEqualToString:header])
                        {
                            if(mandatoryFoundFlags & FLAG_FOUND_MAND_ENV_VALIDITY) {
                                [self _setError:[NSString stringWithFormat:@"message parsing error : header found twice :'%@'", MESSENGER_ENV_VALIDITY] inString:error] ;
                                return nil ;
                            }
                            mandatoryFoundFlags |= FLAG_FOUND_MAND_ENV_VALIDITY ;
                            validity = [value longLongValue] ;
                            
                        } else if ([MESSENGER_ENV_PRIORITY isEqualToString:header])
                        {
                            if(mandatoryFoundFlags & FLAG_FOUND_MAND_ENV_PRIORITY) {
                                [self _setError:[NSString stringWithFormat:@"message parsing error : header found twice :'%@'", MESSENGER_ENV_PRIORITY] inString:error] ;
                                return nil ;
                            }
                            mandatoryFoundFlags |= FLAG_FOUND_MAND_ENV_PRIORITY ;
                            priority = [value intValue] ;
                                
                        } else if ([MESSENGER_ENV_STATUS isEqualToString:header])
                        {
                            if(mandatoryFoundFlags & FLAG_FOUND_MAND_ENV_STATUS) {
                                [self _setError:[NSString stringWithFormat:@"message parsing error : header found twice :'%@'", MESSENGER_ENV_STATUS] inString:error] ;
                                return nil ;
                            }
                            mandatoryFoundFlags |= FLAG_FOUND_MAND_ENV_STATUS ;
                            status = [value intValue] ;
                                
                        } else if ([MESSENGER_ENV_CONTENT_TYPE isEqualToString:header])
                        {
                            if(mandatoryFoundFlags & FLAG_FOUND_MAND_ENV_CONTENT_TYPE) {
                                [self _setError:[NSString stringWithFormat:@"message parsing error : message parsing error :header found twice :'%@'", MESSENGER_ENV_CONTENT_TYPE] inString:error] ;
                                return nil ;
                            }
                            mandatoryFoundFlags |= FLAG_FOUND_MAND_ENV_CONTENT_TYPE ;
                            contentType = value ;
                        //check additionnal envelope headers
                        } else if ([MESSENGER_ENV_MESSAGE_ID isEqualToString:header])
                        {
                            if(additionalFoundFlags & FLAG_FOUND_ENV_MESSAGE_ID) {
                                [self _setError:[NSString stringWithFormat:@"message parsing error : message parsing error :header found twice :'%@'", MESSENGER_ENV_MESSAGE_ID] inString:error] ;
                                return nil ;
                            }
                            additionalFoundFlags |= FLAG_FOUND_ENV_MESSAGE_ID ;
                            messageID = value ;
                                
                        } else if ([MESSENGER_ENV_RECEIVING_DATE isEqualToString:header])
                        {
                            if(additionalFoundFlags & FLAG_FOUND_ENV_RECEIVING_DATE) {
                                [self _setError:[NSString stringWithFormat:@"message parsing error : message parsing error :header found twice :'%@'", MESSENGER_ENV_RECEIVING_DATE] inString:error] ;
                                return nil ;
                            }
                            additionalFoundFlags |= FLAG_FOUND_ENV_RECEIVING_DATE ;
                            // receivingDate non utilisée
                            //receivingDate = [MSDate dateWithSecondsSince1970:[value longLongValue]] ;
                            
                        } else if ([MESSENGER_ENV_EXTERNAL_REF isEqualToString:header])
                        {
                            if(additionalFoundFlags & FLAG_FOUND_ENV_EXTERNAL_REF) {
                                [self _setError:[NSString stringWithFormat:@"message parsing error : message parsing error :header found twice :'%@'", MESSENGER_ENV_EXTERNAL_REF] inString:error] ;
                                return nil ;
                            }
                            additionalFoundFlags |= FLAG_FOUND_ENV_EXTERNAL_REF ;
                            externalReference = value ;
                            
                        } else if ([MESSENGER_ENV_ROUTE isEqualToString:header])
                        {
                            if(additionalFoundFlags & FLAG_FOUND_ENV_ROUTE) {
                                [self _setError:[NSString stringWithFormat:@"message parsing error : message parsing error :header found twice :'%@'", MESSENGER_ENV_ROUTE] inString:error] ;
                                return nil ;
                            }
                            additionalFoundFlags |= FLAG_FOUND_ENV_ROUTE ;
                            route = value ;
                        }
                    }
                }
                    
                //get next envelope header
                remainingEnvBytes -= (headerLineLength + 2) ;
                headerStart = MIN(headerEnd + 2, bodyStart) ;
                headerEnd = strnstr(headerStart, "\r\n", remainingEnvBytes) ;
            }
        }
        //test mandatory flags
        if(mandatoryFoundFlags != MANDATORY_FLAGS_SUM) {
            
            if (!(mandatoryFoundFlags & FLAG_FOUND_MAND_ENV_SENDER))        [self _setError:[NSString stringWithFormat:@"message parsing error : missing mandatory flag %@", MESSENGER_ENV_SENDER] inString:error] ;
            if (!(mandatoryFoundFlags & FLAG_FOUND_MAND_ENV_RECIPIENTS))    [self _setError:[NSString stringWithFormat:@"message parsing error : missing mandatory flag %@", MESSENGER_ENV_RECIPIENTS] inString:error] ;
            if (!(mandatoryFoundFlags & FLAG_FOUND_MAND_ENV_THREAD))        [self _setError:[NSString stringWithFormat:@"message parsing error : missing mandatory flag %@", MESSENGER_ENV_THREAD] inString:error] ;
            if (!(mandatoryFoundFlags & FLAG_FOUND_MAND_ENV_CREATION_DATE)) [self _setError:[NSString stringWithFormat:@"message parsing error : missing mandatory flag %@", MESSENGER_ENV_CREATION_DATE] inString:error] ;
            if (!(mandatoryFoundFlags & FLAG_FOUND_MAND_ENV_VALIDITY))      [self _setError:[NSString stringWithFormat:@"message parsing error : missing mandatory flag %@", MESSENGER_ENV_VALIDITY] inString:error] ;
            if (!(mandatoryFoundFlags & FLAG_FOUND_MAND_ENV_PRIORITY))      [self _setError:[NSString stringWithFormat:@"message parsing error : missing mandatory flag %@", MESSENGER_ENV_PRIORITY] inString:error] ;
            if (!(mandatoryFoundFlags & FLAG_FOUND_MAND_ENV_STATUS))        [self _setError:[NSString stringWithFormat:@"message parsing error : missing mandatory flag %@", MESSENGER_ENV_STATUS] inString:error] ;
            if (!(mandatoryFoundFlags & FLAG_FOUND_MAND_ENV_CONTENT_TYPE))  [self _setError:[NSString stringWithFormat:@"message parsing error : missing mandatory flag %@", MESSENGER_ENV_CONTENT_TYPE] inString:error] ;

            return nil ;
        }
        else {
            if([[message route] length] && ![message receivingDate]) { //comes from a proxy, should have a receiving date
                [self _setError:[NSString stringWithFormat:@"message parsing error : proxy message without receiving date"] inString:error] ;
                return nil ;
            }
            
            if (!validity && [recipients count] > 1)
            {
                [self _setError:[NSString stringWithFormat:@"message parsing error : persistant message must have one and only one recipient"] inString:error] ;
                return nil ;
            }
                
            //get content
            ASSIGN(_originalBuffer, buffer) ;
            content = AUTORELEASE(MSCreateBufferWithBytesNoCopyNoFree(bodyStart, bodyLength)) ;
            if (![content containsOnlyBase64Characters]) {
                [self _setError:[NSString stringWithFormat:@"message parsing error : message content does not contain only base64 characters"] inString:error] ;
                return nil ;
            }
                
            //create message here with dummy recipent
            message = [self initMessageFrom:sender to:@"__DUMMY__" thread:thread contentType:contentType base64Content:content] ;
            if ([messageID length]) [message setMessageID:messageID] ;
            [message setRecipients:recipients] ; //add recipients
            [message setValidity:validity] ;
            [message setPriority:priority] ;
            [message setStatus:status] ;
            [message setExternalReference:externalReference] ;
        }
    }

    return message ;
}

- (void)dealloc
{
    DESTROY(_messageID) ;
    DESTROY(_sender) ;
    DESTROY(_recipients) ;
    DESTROY(_thread) ;
    DESTROY(_route) ;
    DESTROY(_externalReference) ;
    DESTROY(_contentType) ;
    DESTROY(_base64Content) ;
    DESTROY(_originalBuffer);
    
    [super dealloc] ;
}

- (NSString *)messageID { return _messageID ; }
- (void)setMessageID:(NSString *)messageID { ASSIGN(_messageID, messageID) ; }

- (NSString *)sender { return _sender ; }
- (void)setSender:(NSString *)sender {
    if(![sender length]) MSRaise(NSInternalInconsistencyException, @"MHMessengerMessage sender must not be empty") ;
    ASSIGN(_sender, sender) ;
}

- (MSArray *)recipients { return (MSArray *)_recipients ; }
- (void)addRecipent:(NSString *)recipient {
    if(![recipient length]) MSRaise(NSInternalInconsistencyException, @"MHMessengerMessage recipient must not be empty") ;
    [_recipients addObject:recipient] ;
}
- (void)setRecipients:(MSArray *)recipients {
    if(![recipients count]) MSRaise(NSInternalInconsistencyException, @"MHMessengerMessage there must be at least one recipient") ;
    else {
        NSEnumerator *recipientsEnum = [recipients objectEnumerator] ;
        NSString *recipient ;
        while ((recipient = [recipientsEnum nextObject]))
        {
            if(![recipient length]) MSRaise(NSInternalInconsistencyException, @"MHMessengerMessage recipients must not be empty") ;
        }
    }
    
    ASSIGN(_recipients, recipients ? recipients : [MSMutableArray array]) ;
}

- (MSTimeInterval)creationDate { return _creationDate ; }
- (void)setCreationDate:(MSTimeInterval )creationDate { _creationDate = creationDate ; }

- (MSTimeInterval)receivingDate { return _receivingDate ; }
- (void)setReceivingDate:(MSTimeInterval )receivingDate { _receivingDate = receivingDate ; }

- (NSString *)thread { return _thread ; }
- (void)setThread:(NSString *)thread {
    if(![thread length]) MSRaise(NSInternalInconsistencyException, @"MHMessengerMessage thread must not be nil") ;
    ASSIGN(_thread, thread) ;
}

- (MSTimeInterval)validity { return _validity ; }
- (void)setValidity:(MSTimeInterval)validity { _validity = validity ; }
- (BOOL)isPersistent { return _validity == 0 ; }

- (MHMessengerPriority)priority { return _priority ; }
- (void)setPriority:(MHMessengerPriority)priority { _priority = priority ; }

- (NSString *)route { return _route ; }
- (void)setRoute:(NSString *)route { ASSIGN(_route, route) ; }
- (void)addRouteComponent:(NSString *)component {
    if([component length]) {
        if([_route length]) {
            NSString *newRoute = [component stringByAppendingFormat:@".%@",_route] ;
            ASSIGN(_route, newRoute) ; }
        else { ASSIGN(_route, component) ; }
    }
}

- (MSInt)status  {  return _status ; }
- (void)setStatus:(MSInt)status { _status = status ; }

- (NSString *)externalReference { return _externalReference ; }
- (void)setExternalReference:(NSString *)externalReference { ASSIGN(_externalReference, externalReference) ; }

- (NSString *)contentType { return _contentType ; }
- (void)setContentType:(NSString *)contentType { ASSIGN(_contentType, contentType) ; }

- (MSBuffer *)base64Content { return _base64Content ; }

- (MSBuffer *)content {
  if (!_base64Content) return nil ;
  return [_base64Content decodedFromBase64] ;
}
- (void)setContent:(MSBuffer *)content {
    MSBuffer *base64Content = nil ;
    if(![content length]) MSRaise(NSInternalInconsistencyException, @"MHMessengerMessage content must not be empty") ;

    base64Content = [content encodedToBase64] ;

    ASSIGN(_base64Content, base64Content) ;
}

- (MHMessengerEnvelopeType)envelopeType { return _envelopeType ; }
- (void)setEnvelopeType:(MHMessengerEnvelopeType)envelopeType { _envelopeType = envelopeType ; }

- (MSBuffer *)_makePlainEnvelope
{
    MSBuffer *envelopeBuffer = AUTORELEASE(MSCreateBuffer(ENVELOPE_INIT_BUF_SIZE)) ;
    CBuffer *cBuf = (CBuffer *)envelopeBuffer ;
    char *finalCRLF = "\r\n" ;
    
    ADD_ASCII_ENVELOPE_PARAMETER_STRING     (cBuf, MESSENGER_ENV_MESSAGE_ID, _messageID) ;
    ADD_ASCII_ENVELOPE_PARAMETER_STRING     (cBuf, MESSENGER_ENV_SENDER, _sender) ;
    ADD_ASCII_ENVELOPE_PARAMETER_STRING     (cBuf, MESSENGER_ENV_RECIPIENTS, [_recipients componentsJoinedByString:@","]) ;
    ADD_ASCII_ENVELOPE_PARAMETER_INTERVAL   (cBuf, MESSENGER_ENV_CREATION_DATE, _creationDate) ;
    ADD_ASCII_ENVELOPE_PARAMETER_INTERVAL   (cBuf, MESSENGER_ENV_RECEIVING_DATE, _receivingDate) ;
    ADD_ASCII_ENVELOPE_PARAMETER_STRING     (cBuf, MESSENGER_ENV_THREAD, _thread) ;
    ADD_ASCII_ENVELOPE_PARAMETER_INTERVAL   (cBuf, MESSENGER_ENV_VALIDITY, _validity) ;
    ADD_ASCII_ENVELOPE_PARAMETER_INT        (cBuf, MESSENGER_ENV_PRIORITY, _priority) ;
    ADD_ASCII_ENVELOPE_PARAMETER_STRING     (cBuf, MESSENGER_ENV_ROUTE, _route) ;
    ADD_ASCII_ENVELOPE_PARAMETER_INT        (cBuf, MESSENGER_ENV_STATUS, _status) ;
    ADD_ASCII_ENVELOPE_PARAMETER_STRING     (cBuf, MESSENGER_ENV_EXTERNAL_REF, _externalReference) ;
    ADD_ASCII_ENVELOPE_PARAMETER_STRING     (cBuf, MESSENGER_ENV_CONTENT_TYPE, _contentType) ;
    CBufferAppendBytes(cBuf, finalCRLF, strlen(finalCRLF)) ;

    return envelopeBuffer ;
}

- (MSBuffer *)_makeMSTEEnvelope
{
    MSBuffer *envelopeBuffer = AUTORELEASE(MSCreateBuffer(ENVELOPE_INIT_BUF_SIZE)) ;
    CBuffer *cBuf = (CBuffer *)envelopeBuffer ;
    MSBuffer *envelopeDatasBuffer = nil ;
    id recipients = [_recipients componentsJoinedByString:@","] ;
    NSMutableDictionary *envelopeDatas = [NSMutableDictionary dictionary] ;

    if (_messageID) [envelopeDatas setObject:_messageID forKey:MESSENGER_ENV_MESSAGE_ID] ;
    if (_sender) [envelopeDatas setObject:_sender forKey:MESSENGER_ENV_SENDER] ;
    if (recipients) [envelopeDatas setObject:recipients forKey:MESSENGER_ENV_RECIPIENTS] ;
    [envelopeDatas setObject:INTERVAL_TO_STRING(_creationDate) forKey:MESSENGER_ENV_CREATION_DATE] ;
    [envelopeDatas setObject:INTERVAL_TO_STRING(_receivingDate) forKey:MESSENGER_ENV_RECEIVING_DATE] ;
    if (_thread) [envelopeDatas setObject:_thread forKey:MESSENGER_ENV_THREAD] ;
    [envelopeDatas setObject:INTERVAL_TO_STRING(_validity) forKey:MESSENGER_ENV_VALIDITY] ;
    [envelopeDatas setObject:INT_TO_STRING(_priority) forKey:MESSENGER_ENV_PRIORITY] ;
    if (_route) [envelopeDatas setObject:_route forKey:MESSENGER_ENV_ROUTE] ;
    [envelopeDatas setObject:INT_TO_STRING(_status) forKey:MESSENGER_ENV_STATUS] ;
    if (_externalReference) [envelopeDatas setObject:_externalReference forKey:MESSENGER_ENV_EXTERNAL_REF] ;
    [envelopeDatas setObject:_contentType forKey:MESSENGER_ENV_CONTENT_TYPE] ;
    
    envelopeDatasBuffer = [envelopeDatas MSTEncodedBuffer] ;
    CBufferAppendBytes(cBuf, "[", 1) ;
    CBufferAppendBytes(cBuf, (void *)[envelopeDatasBuffer bytes], [envelopeDatasBuffer length]) ;
    
    return envelopeBuffer ;
}

- (MSBuffer *)dataWithEnvelopeType:(MHMessengerEnvelopeType)envelopeType envelopeLength:(MSULong *)envelopeLength contentType:(NSString **)contentType
{
    MSBuffer *data = nil ;
    
    //create envelope
    if (envelopeLength && contentType) {

        switch (envelopeType) {
            case MHMEnvelopeTypePlain:
                data = [self _makePlainEnvelope] ;
                if(envelopeLength) *envelopeLength = (MSULong)[data length] ;
                
                //add message content in base 64 for plain mode
                CBufferAppendBuffer((CBuffer *)data, (CBuffer *)_base64Content) ;
                CBufferAppendBytes((CBuffer *)data, "\r\n", 2) ;
                
                *contentType = MESSENGER_MESSAGE_FORMAT_PLAIN;
                break;
            case MHMEnvelopeTypeMSTE:
                data = [self _makeMSTEEnvelope] ;
                if(envelopeLength) *envelopeLength = (MSULong)[data length] ;

                //add message content in base 64 for mste mode
                CBufferAppendBytes((CBuffer *)data, ",\"", 2) ;
                CBufferAppendBuffer((CBuffer *)data, (CBuffer *)_base64Content) ;
                CBufferAppendBytes((CBuffer *)data, "\"]", 2) ;

                *contentType = MESSENGER_MESSAGE_FORMAT_JSON;
                break;
            default:
                MSRaise(NSInternalInconsistencyException, @"dataWithEnvelopeType : Envelope type not supported") ;
                break;
        }
        
    }
    else MSRaise(NSInternalInconsistencyException, @"dataWithEnvelopeType : envelopeLength or contentType not specified") ;

    return data ;
}

@end

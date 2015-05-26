//
//  MessengerClient.m
//  MessengerTest
//
//  Created by Geoffrey Guilbon on 18/09/13.
//  Copyright (c) 2013 Geoffrey Guilbon. All rights reserved.
//
//#import <MASH/MASH.h>
//#import "MSNet_Private.h"
//#import "MHMessengerClient.h"

#import "MHMessenger_Private.h"

@implementation MHMessengerClient

+ (NSString *)applicationName { return @"MessengerForMunicipolMobileServerApp" ; }
- (NSString *)applicationFullName { return @"Messenger Municipol Mobile Server application" ; }

- (id)initWithServerParameters:(NSDictionary *)parameters
{
    if ([super initWithServerParameters:parameters])
    {
        _responseFormat = MHMResponseFormatMSTE ; //default response format
        return self ;
    }
    return nil ;
}

- (NSString *)_responseFormatToString
{
    NSString *format = nil ;
    
    switch (_responseFormat) {
        case MHMResponseFormatMSTE:
            format = MESSENGER_RESPONSE_FORMAT_MSTE ;
            break ;
        case MHMResponseFormatJSON:
            format = MESSENGER_RESPONSE_FORMAT_JSON ;
            break ;
            
        default:
            format = MESSENGER_RESPONSE_FORMAT_MSTE ;
            break;
    }
    
    return format ;
}

- (id)_decodedObjectFromBuffer:(MSBuffer *)buffer
{
    id decodedObject = nil ;
    
    switch (_responseFormat) {
        case MHMResponseFormatJSON:
            decodedObject = nil ;
            MSRaise(NSGenericException, @"JSON decodeObject not implemented yet...") ;
            break ;
        
            case MHMResponseFormatMSTE:
            decodedObject = [buffer MSTDecodedObject] ;
            break ;
            
        default:
            decodedObject = [buffer MSTDecodedObject] ;
            break;
    }
    
    return decodedObject ;
}

- (MSHTTPResponse *)performRequest:(MSHTTPRequest *)request errorString:(NSString **)error
{
    NSString *responseFormatStr = [self _responseFormatToString] ;
    
    [request addAdditionalHeaderValue:responseFormatStr forKey:@"Accept"] ;
    
    return [super performRequest:request errorString:error] ;
}

- (void)setResponseFormat:(MHMessengerResponseFormat)responseFormat { _responseFormat = responseFormat ; }
- (MHMessengerResponseFormat)responseFormat { return _responseFormat ; }

- (BOOL)sendMessage:(MHMessengerMessage *)message
{
    return [self sendMessage:message envelopeType:MHMEnvelopeTypeMSTE] ;
}

- (BOOL)sendMessage:(MHMessengerMessage *)message envelopeType:(MHMessengerEnvelopeType)envelopeType
{
    BOOL sent = NO ;
    
    if(message)
    {
        MSHTTPRequest *request = nil ;
        MSHTTPResponse *response = nil ;
        MSULong envelopeLength = 0 ;
        NSString *contentType = nil ;
        MSBuffer *messageBuf = [message dataWithEnvelopeType:envelopeType envelopeLength:&envelopeLength contentType:&contentType] ;
        
        request = [self request:POST onSubURL:MESSENGER_SUB_URL_SEND_MSG] ;
        
        [request addBytes:(void *)[messageBuf bytes] length:[messageBuf length]] ;
        [request addAdditionalHeaderValue:[NSNumber numberWithLongLong:envelopeLength] forKey:MESSENGER_HEAD_ENVELOPPE_LENGTH] ;
        [request addAdditionalHeaderValue:(envelopeType == MHMEnvelopeTypePlain) ? MESSENGER_ENV_TYPE_PLAIN : MESSENGER_ENV_TYPE_MSTE forKey:MESSENGER_HEAD_ENVELOPPE_TYPE] ;
        [request setContentType:contentType] ; //GEO TODO REVIEW
        
        response = [self performRequest:request errorString:NULL] ;
        sent = ([response HTTPStatus] == 200) ;
    }
    
    return sent ;
}

- (BOOL)existMessageForIdentifier:(NSString *)mid
{
    BOOL exist = NO ;
    
    if ([mid length])
    {
        MSHTTPRequest *request = nil ;
        MSHTTPResponse *response = nil ;
        NSDictionary *responseDic = nil ;
        
        request = [self request:GET onSubURL:MESSENGER_SUB_URL_FIND_MSG] ;
        [request addQueryParameter:mid forKey:MESSENGER_QUERY_PARAM_MESSAGE_ID] ;
        
        response = [self performRequest:request errorString:NULL] ;
        responseDic = [self _decodedObjectFromBuffer:[response content]] ;
        
        if ([responseDic count])
        {
            NSArray *messages = [responseDic objectForKey:@"messages"] ;
            exist = ([messages count] == 1) ;
        }
    }
    
    return exist ;
}

- (NSArray *)findMessagesForThread:(NSString *)thread status:(MSUInt)status externalIdentifier:(NSString *)xid maxResponses:(MSUInt)maxResponses hasMore:(BOOL *)hasMore
{
    NSArray *messagesFound = nil ;
    
    if ([thread length])
    {
        MSHTTPRequest *request = nil ;
        MSHTTPResponse *response = nil ;
        NSDictionary *responseDic = nil ;
        
        request = [self request:GET onSubURL:MESSENGER_SUB_URL_FIND_MSG] ;
        [request addQueryParameter:thread forKey:MESSENGER_QUERY_PARAM_THREAD_ID] ;
        [request addQueryParameter:xid forKey:MESSENGER_QUERY_PARAM_EXTERNAL_REF] ;
        [request addQueryParameter:[NSNumber numberWithInt:maxResponses] forKey:MESSENGER_QUERY_PARAM_MAX] ;
        
        response = [self performRequest:request errorString:NULL] ;
        responseDic = [self _decodedObjectFromBuffer:[response content]] ;
        
        if ([responseDic count])
        {
            messagesFound = [responseDic objectForKey:MESSENGER_RESPONSE_FIND_MESSAGES] ;
            if (hasMore) { *hasMore = [[responseDic objectForKey:MESSENGER_RESPONSE_FIND_HAS_MORE] boolValue] ; }
        }
    }
    
    return messagesFound ;
}

- (BOOL)setStatus:(MSUInt)status onMessageIdentifiedBy:(NSString *)mid
{
    BOOL statusSet = NO ;
    
    if (status && [mid length])
    {
        MSHTTPRequest *request = nil ;
        MSHTTPResponse *response = nil ;
        request = [self request:GET onSubURL:MESSENGER_SUB_URL_SET_MSG_STATUS] ;
        [request addQueryParameter:mid forKey:MESSENGER_QUERY_PARAM_MESSAGE_ID] ;
        [request addQueryParameter:[NSString stringWithFormat:@"%d",status] forKey:MESSENGER_QUERY_PARAM_STATUS] ;
        response = [self performRequest:request errorString:NULL] ;
        
        statusSet = ([response HTTPStatus] == 200) ;
    }
    
    return statusSet ;
}

- (MSUInt)statusFromMessageIdentifiedBy:(NSString *)mid
{
    MSUInt status = 0 ;
    
    if ([mid length])
    {
        MSHTTPRequest *request = nil ;
        MSHTTPResponse *response = nil ;
        NSDictionary *responseDic = nil ;

        request = [self request:GET onSubURL:MESSENGER_SUB_URL_GET_MSG_STATUS] ;
        [request addQueryParameter:mid forKey:MESSENGER_QUERY_PARAM_MESSAGE_ID] ;
        
        response = [self performRequest:request errorString:NULL] ;
        responseDic = [self _decodedObjectFromBuffer:[response content]] ;
        
        if ([responseDic count])
        {
            status = [[responseDic objectForKey:MESSENGER_RESPONSE_GET_STATUS] intValue] ;
        }
    }
    
    return status ;
}

- (BOOL)deleteMessageIdentifiedBy:(NSString *)mid
{
    BOOL deleted = NO ;
    
    if ([mid length])
    {
        MSHTTPRequest *request = nil ;
        MSHTTPResponse *response = nil ;
        
        request = [self request:GET onSubURL:MESSENGER_SUB_URL_DEL_MSG] ;
        [request addQueryParameter:mid forKey:MESSENGER_QUERY_PARAM_MESSAGE_ID] ;

        response = [self performRequest:request errorString:NULL] ;
        deleted = ([response HTTPStatus] == 200) ;
    }
    
    return deleted ;
}

- (NSString *)_envelopeTypeStringForEnum:(MHMessengerEnvelopeType)envelopeType
{
    NSString *envelopeTypeStr = nil ;
    
    switch (envelopeType) {
        case MHMEnvelopeTypePlain:
            envelopeTypeStr = MESSENGER_ENV_TYPE_PLAIN ;
            break;
            
        case MHMEnvelopeTypeMSTE:
            envelopeTypeStr = MESSENGER_ENV_TYPE_MSTE ;
        default:
            break;
    }
    
    return envelopeTypeStr ;
}

- (MHMessengerEnvelopeType)_envelopeEnumValueForString:(NSString *)envTypeStr
{
    MHMessengerEnvelopeType envType = 0 ;
    
    if ([MESSENGER_ENV_TYPE_MSTE isEqualToString:envTypeStr])
    {
        envType = MHMEnvelopeTypeMSTE ;
    }
    else if ([MESSENGER_ENV_TYPE_PLAIN isEqualToString:envTypeStr])
    {
        envType = MHMEnvelopeTypePlain ;
    } else
    {
        MSRaise(NSGenericException, @"_envelopeEnumValueForString: envelopeType not supported : '%@'", envTypeStr) ;
    }
    
    return envType ;
}

- (MHMessengerMessage *)messageIdentifiedBy:(NSString *)mid error:(NSString **)error
{
    return [self messageIdentifiedBy:mid envelopeType:MHMEnvelopeTypeMSTE error:error] ;
}

- (MHMessengerMessage *)messageIdentifiedBy:(NSString *)mid envelopeType:(MHMessengerEnvelopeType)envelopeType error:(NSString **)error
{
    MHMessengerMessage *message = nil ;
    
    if ([mid length])
    {
        MSHTTPRequest *request = nil ;
        MSHTTPResponse *response = nil ;
        MSBuffer *buffer = nil ;
        NSString *envelopeTypeStr = [self _envelopeTypeStringForEnum:envelopeType] ;
        
        request = [self request:GET onSubURL:MESSENGER_SUB_URL_GET_MSG] ;
        [request addQueryParameter:mid forKey:MESSENGER_QUERY_PARAM_MESSAGE_ID] ;
        [request addQueryParameter:envelopeTypeStr forKey:MESSENGER_QUERY_PARAM_MESSAGE_ENV] ;
        
        response = [self performRequest:request errorString:NULL] ;
        buffer = [response content] ;
                
        if([buffer length])
        {
            NSString *envelopeTypeHeader = [response headerValueForKey:@"Envelope-Type"] ;
            MSULong envelopeLength = [[response headerValueForKey:@"Envelope-Length"] longLongValue] ;
            MHMessengerEnvelopeType envelopeTypeFound = [self _envelopeEnumValueForString:envelopeTypeHeader] ;
            
            if(envelopeTypeFound)
            {
                message = [MHMessengerMessage messageWithBuffer:buffer envelopeType:envelopeTypeFound envelopeLength:envelopeLength error:error] ;
            }
        }
    }
    
    return message ;
}

@end

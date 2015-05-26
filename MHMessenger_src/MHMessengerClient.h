//
//  MessengerClient.h
//  MessengerTest
//
//  Created by Geoffrey Guilbon on 18/09/13.
//  Copyright (c) 2013 Geoffrey Guilbon. All rights reserved.
//

#import <MSNet/MSNet.h>

@interface MHMessengerClient : MHApplicationClient
{
    MHMessengerResponseFormat _responseFormat ;
}

- (BOOL)sendMessage:(MHMessengerMessage *)message ; // default : send mste envelope
- (BOOL)sendMessage:(MHMessengerMessage *)message envelopeType:(MHMessengerEnvelopeType)envelopeType ;

- (MHMessengerMessage *)messageIdentifiedBy:(NSString *)mid error:(NSString **)error ; // default : get mste envelope
- (MHMessengerMessage *)messageIdentifiedBy:(NSString *)mid envelopeType:(MHMessengerEnvelopeType)envelopeType error:(NSString **)error ;

- (BOOL)deleteMessageIdentifiedBy:(NSString *)mid ;

- (BOOL)existMessageForIdentifier:(NSString *)mid ;
- (NSArray *)findMessagesForThread:(NSString *)thread status:(MSUInt)status externalIdentifier:(NSString *)xid maxResponses:(MSUInt)maxResponses hasMore:(BOOL *)hasMore ;

- (MSUInt)statusFromMessageIdentifiedBy:(NSString *)mid ;
- (BOOL)setStatus:(MSUInt)status onMessageIdentifiedBy:(NSString *)mid ;

- (void)setResponseFormat:(MHMessengerResponseFormat)responseFormat ;
- (MHMessengerResponseFormat)responseFormat ;

@end

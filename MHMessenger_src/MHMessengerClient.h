//
//  MessengerClient.h
//  MessengerTest
//
//  Created by Geoffrey Guilbon on 18/09/13.
//  Copyright (c) 2013 Geoffrey Guilbon. All rights reserved.
//

@interface MHMessengerClient : MSHttpApplicationClient

- (MSHttpClientRequest *)sendMessage:(MHMessengerMessage *)message;
- (MSHttpClientRequest *)getMessage:(NSString *)mid;
- (MSHttpClientRequest *)deleteMessage:(NSString *)mid;
- (MSHttpClientRequest *)findMessages:(NSString *)filter;
- (MSHttpClientRequest *)getMessageStatus:(NSString *)mid;
- (MSHttpClientRequest *)setMessage:(NSString *)mid status:(MSUInt)status;
@end

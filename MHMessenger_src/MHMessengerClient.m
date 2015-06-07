#import "MHMessenger_Private.h"

@implementation MHMessengerClient

- (MSHttpClientRequest *)sendMessage:(MHMessengerMessage *)message
{
  MSHttpClientRequest *request;
  request= [self postRequest:@"sendMessage"];
  [request setResponseClass:[MSHttpMSTEClientResponse class]];
  [request writeMessengerMessage:message];
  return request;
}

- (MSHttpClientRequest *)getMessage:(NSString *)mid
{
  MSHttpClientRequest *request;
  request= [self getRequest:FMT(@"getMessage?%@=%@", MESSENGER_QUERY_PARAM_MESSAGE_ID, mid)];
  [request setResponseClass:[MHMessengerMessageClientResponse class]];
  [request writeEnd];
  return request;
}
- (MSHttpClientRequest *)deleteMessage:(NSString *)mid
{
  MSHttpClientRequest *request;
  request= [self getRequest:FMT(@"deleteMessage?%@=%@", MESSENGER_QUERY_PARAM_MESSAGE_ID, mid)];
  [request writeEnd];
  return request; 
}
- (MSHttpClientRequest *)findMessages:(NSString *)filter
{
  MSHttpClientRequest *request;
  request= [self getRequest:FMT(@"findMessages?%@", filter)];
  [request setResponseClass:[MSHttpMSTEClientResponse class]];
  [request writeEnd];
  return request; 
}
- (MSHttpClientRequest *)getMessageStatus:(NSString *)mid
{
  MSHttpClientRequest *request;
  request= [self getRequest:FMT(@"getMessageStatus?%@=%@", MESSENGER_QUERY_PARAM_MESSAGE_ID, mid)];
  [request setResponseClass:[MSHttpMSTEClientResponse class]];
  [request writeEnd];
  return request;
}
- (MSHttpClientRequest *)setMessage:(NSString *)mid status:(MSUInt)status
{
  MSHttpClientRequest *request;
  request= [self getRequest:FMT(@"setMessageStatus?%@=%@&%@=%d", 
    MESSENGER_QUERY_PARAM_MESSAGE_ID, mid,
    MESSENGER_QUERY_PARAM_STATUS    , status)];
  [request writeEnd];
  return request;
}

@end

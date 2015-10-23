#import "MHMessenger_Private.h"

static NSString* _messengerMessageSource(NSString *key, id message)
{
  return [message valueForHeader:key];
}

static void _messengerMessageOutput(id value, NSString *key, id request)
{
  if (value)
    [request setValue:[value description] forHeader:key];
}

@implementation MHMessengerMessageClientResponse

- (instancetype)init
{
  if ((self= [super init])) {
    _message= [MHMessengerMessage new];
    _buffer= [MSBuffer new];
    [_message fillPropertiesWithSource:_messengerMessageSource context:self];
  }
  return self;
}
- (void)dealloc
{
  [_message release];
  [_buffer release];
  [super dealloc];
}
- (void)onResponseData:(NSData *)data
{ 
  [_buffer appendBytes:[data bytes] length:[data length]];
}
- (void)onResponseEnd
{ 
  [_message setBase64Content:_buffer];
  [self handledWithError:nil];
}
- (MHMessengerMessage *)messengerMessage
{
  return _message;
}
@end

@implementation MHMessengerMessageMiddleware
+ (instancetype)messengerMessageMiddleware
{ return AUTORELEASE([ALLOC(self) init]); }

static BOOL _onTransactionReceiveData(MSHttpTransaction *tr, NSData *data, MSHandlerArg *args)
{
  mutable MSBuffer *buffer= args[0].id;
  [buffer appendBytes:[data bytes] length:[data length]];
  return YES;
}
static BOOL _onTransactionReceiveEnd(MSHttpTransaction *tr, NSString *err, MSHandlerArg *args)
{
  mutable MSBuffer *buffer= args[0].id;
  MHMessengerMessage *message;
  message= [MHMessengerMessage message];
  [message fillPropertiesWithSource:_messengerMessageSource context:tr];
  [message setBase64Content:buffer];
  [tr setObject:message forKey:@"MHMessengerMessageMiddleware"];
  [tr nextRoute];
  RELEASE(buffer);
  return YES;
}
- (void)onTransaction:(MSHttpTransaction *)tr
{
  mutable MSBuffer *buffer= [MSBuffer new];
  [tr addReceiveDataHandler:_onTransactionReceiveData args:1, MSMakeHandlerArg(buffer)];
  [tr addReceiveEndHandler:_onTransactionReceiveEnd args:1, MSMakeHandlerArg(buffer)];
}
@end

@implementation MSHttpTransaction (MHMessengerMessageMiddleware)
- (id)messengerMessage
{ return [self objectForKey:@"MHMessengerMessageMiddleware"]; }
- (void)write:(MSUInt)statusCode messengerMessage:(MHMessengerMessage*)message
{
  [message exportPropertiesWithOutput:_messengerMessageOutput context:self asString:YES];
  [self writeData:[message base64Content]];
  [self writeEnd];
}
@end

@implementation MSHttpClientRequest (MHMessengerMessageMiddleware)
- (void)writeMessengerMessage:(MHMessengerMessage *)message
{
  [message exportPropertiesWithOutput:_messengerMessageOutput context:self asString:YES];
  [self writeData:[message base64Content]];
  [self writeEnd];
}
@end

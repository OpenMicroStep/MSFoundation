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
- (void)onTransaction:(MSHttpTransaction *)tr next:(id <MSHttpNextMiddleware>)next
{
  [tr setObject:[MSBuffer mutableBuffer] forKey:@"MHMessengerMessageMiddleware_buffer"];
  [tr setObject:next forKey:@"MHMessengerMessageMiddleware_next"];
  [tr setDelegate:self];
}
- (void)onTransaction:(MSHttpTransaction*)tr receiveData:(MSBuffer *)data
{
  MSBuffer *b;
  b= [tr objectForKey:@"MHMessengerMessageMiddleware_buffer"];
  [b appendBytes:[data bytes] length:[data length]];
}
- (void)onTransactionEnd:(MSHttpTransaction*)tr
{
  MSBuffer *b; id <MSHttpNextMiddleware> n; MHMessengerMessage *message;
  b= [tr objectForKey:@"MHMessengerMessageMiddleware_buffer"];
  n= [tr objectForKey:@"MHMessengerMessageMiddleware_next"];
  message= [MHMessengerMessage message];
  [message fillPropertiesWithSource:_messengerMessageSource context:tr];
  [message setBase64Content:b];
  [tr setObject:message forKey:@"MHMessengerMessageMiddleware"];
  [tr removeObjectForKey:@"MHMessengerMessageMiddleware_buffer"];
  [tr removeObjectForKey:@"MHMessengerMessageMiddleware_next"];
  [n nextMiddleware];
}
- (void)onTransaction:(MSHttpTransaction *)tr error:(NSString*)err
{ }
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

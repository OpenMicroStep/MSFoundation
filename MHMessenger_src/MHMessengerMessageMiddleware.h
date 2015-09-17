
@interface MHMessengerMessageClientResponse : MSHttpClientResponse {
  MHMessengerMessage *_message;
  MSBuffer *_buffer;
}
- (MHMessengerMessage *)messengerMessage;
@end
@interface MSHttpClientRequest (MHMessengerMessageMiddleware)
- (void)writeMessengerMessage:(MHMessengerMessage *)message;
@end

@interface MHMessengerMessageMiddleware : NSObject <MSHttpMiddleware>
+ (instancetype)messengerMessageMiddleware;
@end
@interface MSHttpTransaction (MHMessengerMessageMiddleware)
- (MHMessengerMessage *)messengerMessage;
- (void)write:(MSUInt)statusCode messengerMessage:(MHMessengerMessage *)message;
@end

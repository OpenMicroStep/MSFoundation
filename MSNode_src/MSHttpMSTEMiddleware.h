
@interface MSHttpMSTEClientResponse : MSHttpClientResponse {
  MSBuffer *_buffer;
  id _decodedObject;
}
- (id)msteDecodedObject;
@end
@interface MSHttpClientRequest (MSHttpMSTEMiddleware)
- (void)writeMSTE:(id)rootObject;
@end

@interface MSHttpMSTEMiddleware : NSObject <MSHttpMiddleware, MSHttpRequestDelegate>
+ (instancetype)msteMiddleware;
@end
@interface MSHttpTransaction (MSHttpMSTEMiddleware)
- (id)msteDecodedObject;
- (void)write:(MSUInt)statusCode mste:(id)rootObject;
@end


@interface MSHttpJSONClientResponse : MSHttpClientResponse {
  id _decoder;
  id _decodedObject;
}
- (id)jsonDecodedObject;
@end
@interface MSHttpClientRequest (MSHttpJSONMiddleware)
- (void)writeJSON:(id)rootObject;
@end

@interface MSHttpJSONMiddleware : NSObject <MSHttpMiddleware>
+ (instancetype)jsonMiddleware;
@end
@interface MSHttpTransaction (MSHttpJSONMiddleware)
- (id)jsonDecodedObject;
- (void)write:(MSUInt)statusCode json:(id)rootObject;
@end

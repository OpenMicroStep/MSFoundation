
@class MSHttpClientRequest;

@interface MSHttpClientResponse : NSObject {
  void *_res;
  MSHttpClientRequest *_request;
}
- (MSUInt)statusCode;
- (NSString *)statusMessage;
- (NSString*)httpVersion;
- (NSDictionary*)headers;
- (NSString *)valueForHeader:(NSString *)header;
- (NSDictionary*)rawHeaders;
@end

@interface MSHttpClientResponse (SubClasses)
- (instancetype)init;
- (void)onResponseData:(MSBuffer *)data;
- (void)onResponseEnd;
- (void)onResponseError:(NSString*)err;
- (void)handledWithError:(NSString *)err;
@end

@interface MSHttpStringClientResponse : MSHttpClientResponse {
	id _str, _buf;
}
- (NSString *)stringValue;
@end

typedef BOOL (*MSHttpClientRequestHandler)(MSHttpClientResponse *response, NSString *error, void *arg);
@interface MSHttpClientRequest : NSObject {
  void *_eventFirst, *_eventLast;
  void *_req, *_options, *_headers;
  Class _cls;
}

+ (instancetype)httpClientRequest:(MSHttpMethod)method url:(NSString *)url;
- (instancetype)initWithMethod:(MSHttpMethod)method url:(NSString *)url;

- (Class)responseClass;
- (void)setResponseClass:(Class)cls;

- (void)addHandler:(MSHttpClientRequestHandler)handler context:(void*)arg;

- (void)setValue:(NSString*)name forHeader:(NSString*)value;
- (void)writeData:(NSData*)data;
- (void)writeEnd;
@end

@interface MSHttpsAgent : NSObject {
  void *_agent;
}
+ (MSHttpsAgent*)httpsAgent;
@end

@interface MSHttpsClientRequest : MSHttpClientRequest

+ (instancetype)httpsClientRequest:(MSHttpMethod)method url:(NSString *)url;

- (void)setAgent:(MSHttpsAgent *)agent;
- (void)setPFX:(NSData *)pfx;
- (void)setCertificateAutority:(NSData *)ca;
- (void)setCertificate:(NSData *)cert privateKey:(NSData *)key;
- (void)setCertificate:(NSData *)cert privateKey:(NSData *)key passphrase:(NSString *)passphrase;
@end

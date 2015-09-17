#import "MSNode_Private.h"

using namespace v8;


@interface MSHttpClientResponse (Private)
- (instancetype)initWithRequest:(MSHttpClientRequest*)request withError:(NSString *)error;
- (instancetype)initWithRequest:(MSHttpClientRequest*)request v8res:(v8::Local<v8::Value>)res isolate:(v8::Isolate *)isolate;
@end

static void onResponseCallback(id object, const FunctionCallbackInfo<Value> &args)
{
  MSHttpClientRequest*  self= object;
  Local<Object> v8res= args[0]->ToObject();
  [ALLOC([self responseClass]) initWithRequest:self v8res:v8res isolate:args.GetIsolate()];
  //printf("MSHttpClientRequest %p onResponseCallback\n", self);
}
static void onErrorCallback(id object, const FunctionCallbackInfo<Value> &args)
{
  MSHttpClientRequest* self= object;
  id error= nodejs_to_objc(args.GetIsolate(), args[0]);
  //printf("MSHttpClientRequest %p onErrorCallback:%s\n", self, [[error description] UTF8String]);
  [ALLOC([self responseClass]) initWithRequest:self withError:error ? error : @"not converted"];
}
static void _registerRequestEvents(id self, Local<Object> request, Isolate *isolate) {
  Local<Function> on= nodejs_method(isolate, request, "on");
  on->Call(request, 2, (Local<Value>[]){String::NewFromUtf8(isolate, "response"), nodejs_callback(isolate, self, onResponseCallback)});
  on->Call(request, 2, (Local<Value>[]){String::NewFromUtf8(isolate, "error"), nodejs_callback(isolate, self, onErrorCallback)});
}
static void _createRequestOnModule(id self, const char *module, void** req, void *opts)
{
  Isolate *isolate = Isolate::GetCurrent();
  Local<Object> https= nodejs_require(module);
  Local<Object> options = Local<Object>::New(isolate, *(Persistent<Object>*)opts);
  Local<Object> request= nodejs_call(isolate, https, "request", 1, (Local<Value>[]) { options })->ToObject();
  _registerRequestEvents(self, request, isolate);
  *req= nodejs_persistent_new(isolate, request);
  //printf("MSHttpClientRequest %p _createRequestOnModule\n", self);
  [self retain];
}

@implementation MSHttpClientRequest

+ (instancetype)httpClientRequest:(MSHttpMethod)method url:(NSString *)url
{
  return AUTORELEASE([ALLOC(self) initWithMethod:method url:url]);
}
- (instancetype)initWithMethod:(MSHttpMethod)method url:(NSString *)url
{
  Isolate *isolate = Isolate::GetCurrent();
  Local<Object> headers= Object::New(isolate);
  Local<Object> options = nodejs_call_with_ids(isolate, nodejs_require("url"), "parse", url, nil)->ToObject();
  options->Set(String::NewFromUtf8(isolate, "method"), [MSHttpMethodName(method) toV8:isolate]);
  options->Set(String::NewFromUtf8(isolate, "headers"), headers);
  _options = nodejs_persistent_new(isolate, options);
  _headers = nodejs_persistent_new(isolate, headers);
  _url = [url copy];
  return self;
}
- (void)_createRequest
{ _createRequestOnModule(self, "http", &_req, _options); }
- (void)dealloc
{
  //printf("MSHttpClientRequest %p dealloc\n", self);
  nodejs_persistent_delete(_req);
  nodejs_persistent_delete(_options);
  nodejs_persistent_delete(_headers);
  MSHandlerListFreeInside(&_handlers);
  RELEASE(_url);
  [super dealloc];
}
- (Class)responseClass
{ return _cls ? _cls : [MSHttpClientResponse class]; }
- (void)setResponseClass:(Class)cls
{ _cls= cls; }

- (MSHandler*)addHandler:(MSHttpClientRequestHandler)handler args:(int)argc, ...
{ return MSHandlerListAdd(&_handlers, handler, argc, argc); }

- (void)onReponseHandled:(MSHttpClientResponse *)response withError:(NSString *)err
{
  NSLog(@"HTTP Request %@: %@", _url, err ? err : @"OK");
  MSHandlerListCallUntilNO(&_handlers, BOOL, YES, MSHttpClientRequestHandler, response, err);
  [self release];
}

- (void)setValue:(NSString*)value forHeader:(NSString*)name
{
  Isolate *isolate = Isolate::GetCurrent();
  Local<Object> options = nodejs_persistent_value(isolate, _headers);
  options->Set([name toV8:isolate], [value toV8:isolate]);
}
- (void)writeData:(NSData*)data
{
  if (!_req) [self _createRequest];
  nodejs_call_with_ids(NULL, _req, "write", data, nil);
}
- (void)writeEnd
{
  if (!_req) [self _createRequest];
  nodejs_call(NULL, _req, "end");
}
@end

@implementation MSHttpsAgent
+ (MSHttpsAgent*)httpsAgent
{
  Isolate *isolate = Isolate::GetCurrent();
  Local<Object> https= nodejs_require("https");
  Local<Object> Agent= https->Get(String::NewFromUtf8(isolate, "Agent"))->ToObject();
  Local<Object> agent= Agent->CallAsConstructor(0, NULL)->ToObject();
  return AUTORELEASE([ALLOC(MSHttpsAgent) initWithV8Agent:nodejs_persistent_new(isolate, agent)]);
}
- (instancetype)initWithV8Agent:(void*)agent
{
  _agent= agent;
  return self;
}
- (void)dealloc
{
  nodejs_persistent_delete(_agent);
  [super dealloc];
}
- (void *)v8agent
{ return _agent; }
@end

@implementation MSHttpsClientRequest


+ (instancetype)httpsClientRequest:(MSHttpMethod)method url:(NSString *)url
{
  return AUTORELEASE([ALLOC(self) initWithMethod:method url:url]);
}
- (void)_createRequest
{
  //Isolate *isolate = Isolate::GetCurrent();
  //Local<Object> options = nodejs_persistent_value(isolate, _options);
  //options->Set(String::NewFromUtf8(isolate, "rejectUnauthorized"), v8::False(isolate)); // TODO: fix ca handling
  _createRequestOnModule(self, "https", &_req, _options);
}

- (void)setAgent:(MSHttpsAgent *)agent
{
  Isolate *isolate = Isolate::GetCurrent();
  Local<Object> v8agent = nodejs_persistent_value(isolate, [agent v8agent]);
  Local<Object> options = nodejs_persistent_value(isolate, _options);
  options->Set(String::NewFromUtf8(isolate, "agent"), v8agent);
}
- (void)setPFX:(NSData *)pfx
{
  Isolate *isolate = Isolate::GetCurrent();
  Local<Object> options = nodejs_persistent_value(isolate, _options);
  options->Set(String::NewFromUtf8(isolate, "pfx"), [pfx toV8:isolate]);
}
- (void)setCertificateAutority:(NSData *)ca
{
  Isolate *isolate = Isolate::GetCurrent();
  Local<Object> options = nodejs_persistent_value(isolate, _options);
  options->Set(String::NewFromUtf8(isolate, "ca"), [@[ ca ] toV8:isolate]);
}
- (void)setCertificate:(NSData *)cert privateKey:(NSData *)key
{ [self setCertificate:cert privateKey:key passphrase:nil]; }
- (void)setCertificate:(NSData *)cert privateKey:(NSData *)key passphrase:(NSString *)passphrase
{
  Isolate *isolate = Isolate::GetCurrent();
  Local<Object> options = nodejs_persistent_value(isolate, _options);
  options->Set(String::NewFromUtf8(isolate, "cert"), [cert toV8:isolate]);
  options->Set(String::NewFromUtf8(isolate, "key"), [key toV8:isolate]);
  if (passphrase) {
    options->Set(String::NewFromUtf8(isolate, "passphrase"), [passphrase toV8:isolate]);}
}
@end

static void onResponseDataCallback(id object, const FunctionCallbackInfo<Value> &args)
{ [(MSHttpClientResponse*)object onResponseData:nodejs_to_objc(args.GetIsolate(), args[0])]; }
static void onResponseEndCallback(id object, const FunctionCallbackInfo<Value> &args)
{ [(MSHttpClientResponse*)object onResponseEnd]; }
static void onResponseErrorCallback(id object, const FunctionCallbackInfo<Value> &args)
{ [(MSHttpClientResponse*)object onResponseError:nodejs_to_objc(args.GetIsolate(), args[0])]; }
static void _registerResponseEvents(id self, Local<Object> response, Isolate *isolate) {
  Local<Function> on= nodejs_method(isolate, response, "on");
  on->Call(response, 2, (Local<Value>[]){String::NewFromUtf8(isolate, "data" ), nodejs_callback(isolate, self, onResponseDataCallback )});
  on->Call(response, 2, (Local<Value>[]){String::NewFromUtf8(isolate, "end"  ), nodejs_callback(isolate, self, onResponseEndCallback  )});
  on->Call(response, 2, (Local<Value>[]){String::NewFromUtf8(isolate, "error"), nodejs_callback(isolate, self, onResponseErrorCallback)});
}

@implementation MSHttpClientResponse

- (instancetype)initWithRequest:(MSHttpClientRequest*)request withError:(NSString *)error
{
  _request= [request retain];
  self= [self init];
  [self handledWithError:error];
  return self;
}
- (instancetype)initWithRequest:(MSHttpClientRequest*)request v8res:(Local<Value>)res isolate:(v8::Isolate *)isolate
{
  Local<Object> response= res->ToObject();
  _res= nodejs_persistent_new(isolate, response);
  _request= [request retain];
  _registerResponseEvents(self, response, isolate);
  return [self init];
}
- (void)dealloc
{
  nodejs_persistent_delete(_res);
  [_request release];
  [super dealloc];
}
- (void)onResponseData:(NSData *)data
{ }
- (void)onResponseEnd
{ [self handledWithError:nil]; }
- (void)onResponseError:(NSString*)err
{ [self handledWithError:err]; }
- (void)handledWithError:(NSString *)err
{
  [_request onReponseHandled:self withError:err];
  [self release];
}
- (MSUInt)statusCode
{ return (MSUInt)[nodejs_get(NULL, _res, "statusCode") longValue]; }
- (NSString *)statusMessage
{ return nodejs_get(NULL, _res, "statusMessage"); }
- (NSString *)httpVersion
{ return nodejs_get(NULL, _res, "httpVersion"); }
- (NSDictionary *)headers
{ return nodejs_get(NULL, _res, "headers"); }
- (NSString *)valueForHeader:(NSString *)header
{ return [nodejs_get(NULL, _res, "headers") objectForKey:header]; }
- (NSDictionary *)rawHeaders
{ return nodejs_get(NULL, _res, "rawHeaders"); }

@end

@implementation MSHttpStringClientResponse
- (instancetype)init
{
  if ((self= [super init])) {
    _buf= [MSBuffer new];
  }
  return self;
}
- (void)dealloc
{
  [_buf release];
  [_str release];
  [super dealloc];
}
- (void)onResponseData:(NSData *)data
{
  [_buf appendBytes:[data bytes] length:[data length]];
}
- (void)onResponseEnd
{
  id str= [ALLOC(MSString) initWithData:_buf encoding:NSUTF8StringEncoding];
  DESTROY(_buf);
  ASSIGN(_str, str);
  [self handledWithError:nil];
}
- (NSString *)stringValue
{
  return _str;
}
@end

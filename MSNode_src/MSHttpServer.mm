#import "MSNode_Private.h"

using namespace v8;

static void onListeningCallback(id object, const FunctionCallbackInfo<Value> &args)
{
  MSHttpServer*  self= object;
  [[self delegate] onServerListening:self];
}

static void onRequestCallback(id object, const FunctionCallbackInfo<Value> &args)
{
  MSHttpServer*  self= object;
  Local<Object> v8req= args[0]->ToObject();
  Local<Object> v8res= args[1]->ToObject();
  MSHttpTransaction* tr= [ALLOC(MSHttpTransaction) initWithServer:self v8Req:v8req v8res:v8res isolate:args.GetIsolate()];
  [[self delegate] onServer:self transaction:tr];
}

static void onCloseCallback(id object, const FunctionCallbackInfo<Value> &args)
{
  MSHttpServer*  self= object;
  [[self delegate] onServerClose:self];
}

/*
- (void)onError:(NSString*)err;
- (void)onClientError:(NSString*)err;
*/
static void _registerEvents(id self, Local<Object> server, Isolate *isolate) {

  Local<Function> on= nodejs_method(isolate, server, "on");
  on->Call(server, 2, (Local<Value>[]){String::NewFromUtf8(isolate, "listening"), nodejs_callback(isolate, self, onListeningCallback)});
  on->Call(server, 2, (Local<Value>[]){String::NewFromUtf8(isolate, "request")  , nodejs_callback(isolate, self, onRequestCallback)});
  on->Call(server, 2, (Local<Value>[]){String::NewFromUtf8(isolate, "close")    , nodejs_callback(isolate, self, onCloseCallback)});
}

@implementation MSHttpServer

+ (instancetype)httpServer
{
  return [[ALLOC(self) init] autorelease];
}

- (instancetype)init
{
  Isolate *isolate = Isolate::GetCurrent();
  Local<Object> http= nodejs_require("http");
  Local<Value> serverRet = nodejs_call(isolate, http, "createServer");
  if (!serverRet.IsEmpty()) {
    Local<Object> server= serverRet->ToObject();
    _registerEvents(self, server, isolate);
    _priv= nodejs_persistent_new(isolate, server);
  }
  else DESTROY(self);
  return self;
}

- (void)dealloc
{
  nodejs_persistent_delete(_priv);
  RELEASE(_delegate);
  [super dealloc];
}

- (void)listenAtPort:(MSUInt)port hostname:(NSString *)hostname
{
  Isolate *isolate = Isolate::GetCurrent();
  if (hostname)
    nodejs_call(isolate, _priv, "listen", 2, (Local<Value>[]){Number::New(isolate, (double)port), [hostname toV8:isolate]});
  else
    nodejs_call(isolate, _priv, "listen", 1, (Local<Value>[]){Number::New(isolate, (double)port)});
}

- (void)listenAtPath:(NSString*)path
{
  Isolate *isolate = Isolate::GetCurrent();
  nodejs_call(isolate, _priv, "listen", 1, (Local<Value>[]){[path toV8:isolate]});
}

- (void)setDelegate:(id<MSHttpServerDelegate>)delegate
{
  ASSIGN(_delegate, delegate);
}

- (id <MSHttpServerDelegate>)delegate
{
  return _delegate;
}

- (void)close
{
  nodejs_call(NULL, _priv, "close");
}

- (void)onServerListening:(MSHttpServer*)server
{ NSLog(@"Server is listening: %@", server); }
- (void)onServer:(MSHttpServer*)server transaction:(MSHttpTransaction *)tr
{ NSLog(@"%@ %@", server, tr); }
- (void)onServerClose:(MSHttpServer*)server
{ NSLog(@"Server is closed: %@", server); }
- (void)onServer:(MSHttpServer*)server error:(NSString*)err
{ NSLog(@"%@ server error:%@", server, err); }
- (void)onServer:(MSHttpServer*)server clientError:(NSString*)err
{ NSLog(@"%@ client error:%@", server, err); }

@end

@implementation MSHttpsServer {
  id _cert;
}

static BOOL _loadBuffer(mutable MSDictionary *d, id key, NSString *path)
{
  id o;
  o= [d objectForKey:key];
  if ([o isKindOfClass:[NSString class]]) {
    if (path && ![o isAbsolutePath])
      o= [path stringByAppendingPathComponent:o];
    o= [MSBuffer bufferWithContentsOfFile:o];
    [d setObject:o forKey:key];}
  return [o isKindOfClass:[NSData class]];
}

+ (instancetype)httpsServerWithCertificate:(NSData *)crt withKey:(NSData *)key
{ return AUTORELEASE([ALLOC(self) initWithCertificate:crt withKey:key]); }
- (instancetype)initWithCertificate:(NSData *)crt withKey:(NSData *)key
{ return [self initWithParameters:[MSDictionary mutableDictionaryWithObjectsAndKeys:crt, @"cert", key, @"key", nil]]; }
+ (instancetype)httpsServerWithParameters:(NSDictionary *)parameters
{ return [self httpsServerWithParameters:parameters withPath:nil error:NULL]; }
+ (instancetype)httpsServerWithParameters:(NSDictionary *)parameters withPath:(NSString *)path error:(NSString **)perror
{ return AUTORELEASE([ALLOC(self) initWithParameters:parameters withPath:path error:perror]); }
- (instancetype)initWithParameters:(NSDictionary *)parameters
{ return [self initWithParameters:parameters withPath:nil error:NULL]; }
- (instancetype)initWithParameters:(NSDictionary *)parameters withPath:(NSString *)rootPath error:(NSString **)perror
{
  id port, path;
  mutable MSDictionary *params= [MSDictionary mutableDictionaryWithDictionary:parameters];
  Isolate *isolate = Isolate::GetCurrent();
  Local<Object> https= nodejs_require("https");
  _loadBuffer(params, @"pfx", rootPath);
  _loadBuffer(params, @"cert", rootPath);
  _loadBuffer(params, @"key", rootPath);
  ASSIGN(_cert, [params objectForKey:@"cert"]);
  Local<Value> serverRet= nodejs_call_with_ids(isolate, https, "createServer", params, nil);
  if (!serverRet.IsEmpty()) {
    Local<Object> server= serverRet->ToObject();
    _registerEvents(self, server, isolate);
    _priv= nodejs_persistent_new(isolate, server);

    if ((port= [params objectForKey:@"port"])) {
      [self listenAtPort:(MSUInt)[port intValue] hostname:[params objectForKey:@"hostname"]];}
    else if ((path= [params objectForKey:@"path"])) {
      [self listenAtPath:path];}}
  else {
    DESTROY(self);}
  return self;
}

- (void)dealloc {
  DESTROY(_cert);
  [super dealloc];
}

- (MSCertificate *)certificate
{
  return [MSCertificate certificateWithData:_cert];
}
@end

#import "MSNode_Private.h"

using namespace v8;

@interface MSHttpTransaction (PrivateEvents)
- (void)emitReceiveData:(NSData *)data;
- (void)emitReceiveEnd:(NSString *)error;
@end

enum {
  STATE_HEAD= 0,
  STATE_HEAD_HANDLER,
  STATE_DATA,
  STATE_DATA_HANDLER,
  STATE_END
};
static CDictionary *__methodMap;

static void onDataCallback(id object, const FunctionCallbackInfo<Value> &args)
{
  MSHttpTransaction*  self= object;
  [self emitReceiveData:nodejs_to_objc(args.GetIsolate(), args[0])];
}
static void onEndCallback(id object, const FunctionCallbackInfo<Value> &args)
{
  MSHttpTransaction*  self= object;
  [self emitReceiveEnd:nil];
}
static void onErrorCallback(id object, const FunctionCallbackInfo<Value> &args)
{
  MSHttpTransaction*  self= object;
  [self emitReceiveEnd:nodejs_to_objc(args.GetIsolate(), args[0])];
}
static void _registerEvents(id self, Local<Object> request, Isolate *isolate) {
  Local<Function> on= nodejs_method(isolate, request, "on");
  on->Call(request, 2, (Local<Value>[]){String::NewFromUtf8(isolate, "data" ), nodejs_callback(isolate, self, onDataCallback )});
  on->Call(request, 2, (Local<Value>[]){String::NewFromUtf8(isolate, "end"  ), nodejs_callback(isolate, self, onEndCallback  )});
  on->Call(request, 2, (Local<Value>[]){String::NewFromUtf8(isolate, "error"), nodejs_callback(isolate, self, onErrorCallback)});
}

static id _urlParse(void *req, BOOL parseQuery, const char *prop)
{
  Isolate *isolate = Isolate::GetCurrent();
  Local<Object> http= nodejs_require("url");
  Local<Object> request= Local<Object>::New(isolate, *(Persistent<Object>*)req);
  return nodejs_to_objc(isolate, nodejs_call(isolate, http, "parse", 2, (Local<Value>[]){ request->Get(String::NewFromUtf8(isolate, "url")),
    parseQuery ? (Local<Value>)v8::True(isolate) : (Local<Value>)v8::Undefined(isolate)
  })->ToObject()->Get(String::NewFromUtf8(isolate, prop)));
}

@implementation MSHttpTransaction
+ (void)load {
  __methodMap= CCreateDictionaryWithOptions(0, CDictionaryObject, CDictionaryNaturalNotZero);
  CDictionarySetObjectForKey(__methodMap, (id)(intptr_t)MSHttpMethodGET    , @"GET"    );
  CDictionarySetObjectForKey(__methodMap, (id)(intptr_t)MSHttpMethodPOST   , @"POST"   );
  CDictionarySetObjectForKey(__methodMap, (id)(intptr_t)MSHttpMethodPUT    , @"PUT"    );
  CDictionarySetObjectForKey(__methodMap, (id)(intptr_t)MSHttpMethodCONNECT, @"CONNECT");
  CDictionarySetObjectForKey(__methodMap, (id)(intptr_t)MSHttpMethodTRACE  , @"TRACE"  );
  CDictionarySetObjectForKey(__methodMap, (id)(intptr_t)MSHttpMethodOPTIONS, @"OPTIONS");
  CDictionarySetObjectForKey(__methodMap, (id)(intptr_t)MSHttpMethodDELETE , @"DELETE" );
  CDictionarySetObjectForKey(__methodMap, (id)(intptr_t)MSHttpMethodHEAD   , @"HEAD"   );
  CDictionarySetObjectForKey(__methodMap, (id)(intptr_t)MSHttpMethodALL    , @"ALL"    );
}

- (Local<Value>)_v8request:(Isolate *)isolate
{ return Local<Object>::New(isolate, *(Persistent<Object>*)_req); }
- (Local<Value>)_v8response:(Isolate *)isolate
{ return Local<Object>::New(isolate, *(Persistent<Object>*)_res); }

- (instancetype)initWithV8Req:(Local<Value>)req v8res:(Local<Value>)res isolate:(v8::Isolate *)isolate
{
  if ((self= [self init])) {
    Local<Object> request= req->ToObject();
    _req = nodejs_persistent_new(isolate, request);
    _registerEvents(self, request, isolate);
    _res = nodejs_persistent_new(isolate, res->ToObject());
    _context= CCreateDictionary(0);
  }
  return self;
}
- (void)dealloc
{
  nodejs_call(NULL, _req, "removeAllListeners");
  nodejs_persistent_delete(_req);
  nodejs_persistent_delete(_res);
  MSHandlerListFreeInside(&_onReceiveData);
  MSHandlerListFreeInside(&_onReceiveEnd);
  MSHandlerListFreeInside(&_onWriteHead);
  MSHandlerListFreeInside(&_onWriteData);
  RELEASE(_context);
  [super dealloc];
}


// Events
- (MSHandler*)addReceiveDataHandler:(MSHttpTransactionReceiveDataHandler)handler args:(int)argc, ...
{ return MSHandlerListAdd(&_onReceiveData, handler, argc, argc); }
- (MSHandler*)addReceiveEndHandler:(MSHttpTransactionEndHandler)handler args:(int)argc, ...
{ return MSHandlerListAdd(&_onReceiveEnd, handler, argc, argc); }
- (MSHandler*)addWriteHeadHandler:(MSHttpTransactionWriteHeadHandler)handler args:(int)argc, ...
{ return MSHandlerListAdd(&_onWriteHead, handler, argc, argc); }
- (MSHandler*)addWriteDataHandler:(MSHttpTransactionWriteDataHandler)handler args:(int)argc, ...
{ return MSHandlerListAdd(&_onWriteData, handler, argc, argc); }
- (void)emitReceiveData:(NSData *)data
{ MSHandlerListCall(&_onReceiveData, MSHttpTransactionReceiveDataHandler, self, data); }
- (void)emitReceiveEnd:(NSString *)error
{ MSHandlerListCall(&_onReceiveEnd, MSHttpTransactionEndHandler, self, error); }

- (id)objectForKey:(id)key
{ return CDictionaryObjectForKey(_context, key); }
- (void)setObject:(id)object forKey:(id)key
{ CDictionarySetObjectForKey(_context, object, key); }
- (void)removeObjectForKey:(id)key
{ CDictionarySetObjectForKey(_context, nil, key);  }

- (MSHttpMethod)method
{ return (MSHttpMethod)(intptr_t)CDictionaryObjectForKey(__methodMap, nodejs_get(NULL, _req, "method")); }
- (NSString *)rawMethod
{ return nodejs_get(NULL, _req, "method"); }
- (NSString *)httpVersion
{ return nodejs_get(NULL, _req, "httpVersion"); }
- (NSString *)url
{ return nodejs_get(NULL, _req, "url"); }
- (NSString*)urlPath
{ return _urlParse(_req, NO, "pathname"); }
- (NSString*)urlQuery
{ return _urlParse(_req, NO, "query"); }
- (NSDictionary*)urlQueryParameters
{ return _urlParse(_req, YES, "query"); }
- (NSDictionary *)headers
{ return nodejs_get(NULL, _req, "headers"); }
- (NSString *)valueForHeader:(NSString *)header
{ return [nodejs_get(NULL, _req, "headers") objectForKey:header]; }
- (NSDictionary *)rawHeaders
{ return nodejs_get(NULL, _req, "rawHeaders"); }
- (BOOL)isXMLHttpRequest
{ return [@"XMLHttpRequest" isEqual:[self valueForHeader:@"x-requested-with"]]; }

- (void)setValue:(NSString*)value forHeader:(NSString*)name
{
  if (_state <= STATE_HEAD_HANDLER && name && value) {
    Isolate *isolate= Isolate::GetCurrent();
    nodejs_call(isolate, _res, "setHeader", 2, (Local<Value>[]){ [name toV8:isolate], [value toV8:isolate] });}
}
- (void)writeHead:(MSUInt)statusCode
{
  BOOL handle= YES;
  if (_state < STATE_HEAD_HANDLER) {
    _state= STATE_HEAD_HANDLER;
    handle= MSHandlerListCallUntilNO(&_onWriteHead, BOOL, YES, MSHttpTransactionWriteHeadHandler, self, statusCode); }
  if (handle && _state == STATE_HEAD_HANDLER) {
    Isolate *isolate= Isolate::GetCurrent();
    NSLog(@"HTTP Transaction %@ -> %d", [self url], (int)statusCode);
    nodejs_call(isolate, _res, "writeHead", 1, (Local<Value>[]){ Number::New(isolate, (double)statusCode) });
    _state= STATE_DATA;}
}
- (void)writeHead:(MSUInt)statusCode headers:(MSDictionary*)headers
{
  MSDictionaryEnumerator *e; id k, o;
  for (e= [headers dictionaryEnumerator]; (k= [e nextKey]) && (o= [e currentObject]); ) {
    [self setValue:o forHeader:k];}
  [self writeHead:statusCode];
}
- (void)writeData:(NSData *)chunk
{
  BOOL handle= YES;
  if (!chunk) return;
  if (_state < STATE_HEAD_HANDLER) {
    [self writeHead:MSHttpCodeOk];}
  if (chunk) {
    if (_state < STATE_DATA_HANDLER) {
      _state= STATE_DATA_HANDLER;
      handle= MSHandlerListCallUntilNO(&_onWriteData, BOOL, YES, MSHttpTransactionWriteDataHandler, self, chunk); }
    if (handle && _state == STATE_DATA_HANDLER) {
      Isolate *isolate= Isolate::GetCurrent();
      nodejs_call(isolate, _res, "write", 1, (Local<Value>[]){ [chunk toV8:isolate] } );}
  }
}
- (void)writeEnd
{
  if (_state < STATE_HEAD_HANDLER) {
    [self writeHead:MSHttpCodeOk];}
  if (_state < STATE_END) {
    nodejs_call(NULL, _res, "end");
    _state= STATE_END;
    [self autorelease];}
  else {
    NSLog(@"Trying to write end an ended HTTP transaction, %p", self);
  }
}
- (void)writeFile:(NSString *)path
{
  if (_state < STATE_HEAD_HANDLER) {
    [self writeHead:MSHttpCodeOk];}
  if (_state < STATE_END) {
    Isolate *isolate = Isolate::GetCurrent();
    Local<Object> http= nodejs_require("fs");
    Local<Value> stream= nodejs_call_with_ids(isolate, http, "createReadStream", path, nil);
    nodejs_call(isolate, stream->ToObject(), "pipe", 1, (Local<Value>[]){ nodejs_persistent_value(isolate, _res) });
    _state= STATE_END;
    [self autorelease];}
  else {
    NSLog(@"Trying to write file to an ended HTTP transaction, %p", self);}
}
- (void)write:(MSUInt)statusCode headers:(NSDictionary *)headers response:(NSData *)chunk
{
  [self writeHead:statusCode headers:headers];
  [self writeData:chunk];
  [self writeEnd];
}
- (void)write:(MSUInt)statusCode
{
  [self writeHead:statusCode];
  [self writeData:[MSHttpCodeName((MSHttpCode)statusCode) dataUsingEncoding:NSUTF8StringEncoding]];
  [self writeEnd];
}
- (void)write:(MSUInt)statusCode response:(NSData *)chunk
{
  [self writeHead:statusCode];
  [self writeData:chunk];
  [self writeEnd];
}
- (void)write:(MSUInt)statusCode string:(NSString *)string
{
  [self writeHead:statusCode];
  [self writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
  [self writeEnd];
}
- (void)redirect:(NSString *)to
{
  [self writeHead:302 headers:@{ @"Location": to }];
  [self writeEnd];
}
@end

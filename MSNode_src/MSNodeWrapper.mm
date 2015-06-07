//
//  MSCNodeWrapper.cpp
//  MSNet
//
//  Created by Vincent Rouillé on 16/04/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#import "MSNode_Private.h"
#include <vector>
using namespace v8;

const FunctionCallbackInfo<Value> *MSNetArgs= NULL;

static Persistent<Function> __nodejs_require_fct;

@implementation V8String

- (instancetype)initWithV8:(Local<Value>)value isolate:(Isolate *)isolate
{
  if(value->IsString())
    _handle.Reset(isolate, value->ToString());
  else
    DESTROY(self);
  return self;
}

- (void)dealloc
{
  _handle.Reset();
  [super dealloc];
}

- (Local<Value>)toV8:(Isolate *)isolate
{
  return Local<String>::New(isolate, _handle);
}

- (NSUInteger)length
{
  return Local<String>::New(Isolate::GetCurrent(), _handle)->Length();
}

- (unichar)characterAtIndex:(NSUInteger)index
{
  uint16_t c;
  Local<String>::New(Isolate::GetCurrent(), _handle)->Write(&c, (uint32_t)index, 1, String::HINT_MANY_WRITES_EXPECTED | String::NO_NULL_TERMINATION);
  return c;
}

static unichar _v8StringChaiN (const void *src, NSUInteger *pos) {
  uint16_t c;
  ((String*)src)->Write(&c, (uint32_t)(*pos)++, 1, String::HINT_MANY_WRITES_EXPECTED | String::NO_NULL_TERMINATION);
  return c;
}
static unichar _v8StringChaiP (const void *src, NSUInteger *pos) {
  uint16_t c;
  ((String*)src)->Write(&c, (uint32_t)(--(*pos)), 1, String::HINT_MANY_WRITES_EXPECTED | String::NO_NULL_TERMINATION);
  return c;
}
- (SES)stringEnumeratorStructure
{
  // str will be release at the end of the current v8 scope, making it valid the whole SES usage duration
  Local<String> str= Local<String>::New(Isolate::GetCurrent(), _handle);
  return MSMakeSES(*str, _v8StringChaiN, _v8StringChaiP, 0, str->Length(), 0);
}

@end

@implementation V8Buffer

- (instancetype)initWithV8:(Local<Value>)value isolate:(Isolate *)isolate
{
  if(node::Buffer::HasInstance(value))
    _handle.Reset(isolate, value->ToObject());
  else
    DESTROY(self);
  return self;
}

- (void)dealloc
{
  _handle.Reset();
  [super dealloc];
}

- (Local<Value>)toV8:(Isolate *)isolate
{
  return Local<Object>::New(isolate, _handle);
}

- (NSUInteger)length
{
  return node::Buffer::Length(Local<Object>::New(Isolate::GetCurrent(), _handle));
}
- (const void *)bytes
{
  return node::Buffer::Data(Local<Object>::New(Isolate::GetCurrent(), _handle));
}

@end

@implementation V8Dictionary
- (instancetype)initWithV8:(Local<Value>)value isolate:(Isolate *)isolate
{
  if(value->IsObject())
    _handle.Reset(isolate, value->ToObject());
  else
    DESTROY(self);
  return self;
}

- (void)dealloc
{
  _handle.Reset();
  [super dealloc];
}

- (Local<Value>)toV8:(Isolate *)isolate
{
  return Local<Object>::New(isolate, _handle);
}

- (NSUInteger)count
{
  return Local<Object>::New(Isolate::GetCurrent(), _handle)->GetOwnPropertyNames()->Length();
}
- (id)objectForKey:(id)aKey
{
  Isolate *isolate= Isolate::GetCurrent();
  return nodejs_to_objc(isolate, Local<Object>::New(isolate, _handle)->Get([aKey toV8:isolate]));
}
- (NSEnumerator *)keyEnumerator
{
  Isolate *isolate= Isolate::GetCurrent();
  return [[[ALLOC(V8Array) initWithV8:Local<Object>::New(isolate, _handle)->GetOwnPropertyNames() isolate:isolate] autorelease] objectEnumerator];
}
- (void)removeObjectForKey:(id)aKey
{
  Isolate *isolate= Isolate::GetCurrent();
  Local<Object>::New(isolate, _handle)->Delete([aKey toV8:isolate]);
}
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey
{
  Isolate *isolate= Isolate::GetCurrent();
  Local<Object>::New(isolate, _handle)->Set([(id <V8ObjectInterface>)aKey toV8:isolate], [anObject toV8:isolate]);
}
@end

@implementation V8Array
- (instancetype)initWithV8:(Local<Value>)value isolate:(Isolate *)isolate
{
  if(value->IsArray())
    _handle.Reset(isolate, Local<Array>::Cast(value));
  else
    DESTROY(self);
  return self;
}

- (void)dealloc
{
  _handle.Reset();
  [super dealloc];
}

- (Local<Value>)toV8:(Isolate *)isolate
{
  return Local<Array>::New(isolate, _handle);
}

- (NSUInteger) count
{
  Isolate *isolate= Isolate::GetCurrent();
  return Local<Array>::New(isolate, _handle)->Length();
}
- (id)objectAtIndex:(NSUInteger)index
{
  Isolate *isolate= Isolate::GetCurrent();
  return nodejs_to_objc(isolate, Local<Array>::New(isolate, _handle)->Get((uint32_t)index));
}
- (void)addObject:(id)anObject
{
  Isolate *isolate= Isolate::GetCurrent();
  Local<Array> arr= Local<Array>::New(isolate, _handle);
  arr->Set(arr->Length(), [anObject toV8:isolate]);
}
@end



@implementation NSString (V8Conversion)
- (Local<Value>)toV8:(Isolate *)isolate
{
  return String::NewFromUtf8(isolate, [self UTF8String]);
}
@end

class V8ExternalMSStringResource : public String::ExternalStringResource {
public:
  V8ExternalMSStringResource(CString *str) : String::ExternalStringResource() {
    RETAIN(str);
    _str= str;
  }
  virtual ~V8ExternalMSStringResource() {
    RELEASE(_str);
  }

  const uint16_t* data() const {
    return _str->buf;
  }
  size_t length() const {
    return _str->length;
  }

private:
  CString *_str;
};


@implementation MSString (V8Conversion)
- (Local<Value>)toV8:(Isolate *)isolate
{
  if(CGrowIsForeverImmutable(self))
    return String::NewExternal(isolate, new V8ExternalMSStringResource((CString*)self));
  return String::NewFromTwoByte(isolate, _buf, String::kNormalString, (int)_length);
}
@end

@implementation NSData (V8Conversion)
- (Local<Value>)toV8:(Isolate *)isolate
{
  return node::Buffer::New(isolate, (const char*)[self bytes], (size_t)[self length]);
}
@end

static void V8MSBufferFreeCallback(char* data, void* hint)
{
  RELEASE(hint);
}
@implementation MSBuffer (V8Conversion)
- (Local<Value>)toV8:(Isolate *)isolate
{
  return node::Buffer::New(isolate, (char*)_buf, (size_t)_length, V8MSBufferFreeCallback, (void*)RETAIN(self));
}
@end

@implementation NSDictionary (V8Conversion)
- (Local<Value>)toV8:(Isolate *)isolate
{
  Local<Object> d= Object::New(isolate);
  NSEnumerator *e; id key, o;
  for(e= [self keyEnumerator]; (key= [e nextObject]) && (o= [self objectForKey:key]);) {
    d->Set([key toV8:isolate], [o toV8:isolate]);
  }
  return d;
}
@end

@implementation NSArray (V8Conversion)
- (Local<Value>)toV8:(Isolate *)isolate
{
  uint32_t length= (uint32_t)[self count];
  Local<Array> a= Array::New(isolate, length);
  for(uint32_t i= 0; i < length; ++i) {
    a->Set(i, [[self objectAtIndex:(NSUInteger)i] toV8:isolate]);
  }
  return a;
}
@end

@implementation NSNumber (V8Conversion)
- (instancetype)initWithV8:(Local<Value>)v isolate:(Isolate *)isolate
{
  if (v->IsNumber())
    self= [self initWithDouble:v->ToNumber()->Value()];
  else DESTROY(self);
  return self;
}
- (Local<Value>)toV8:(Isolate *)isolate
{
  return Number::New(isolate, [self doubleValue]);
}

@end

static Class nodejs_to_objc_class( Local<Value> v)
{
  Class cls= nil;
  if(v->IsString())
    cls= [V8String class];
  else if(node::Buffer::HasInstance(v))
    cls= [V8Buffer class];
  else if(v->IsArray())
    cls= [V8Array class];
  else if(v->IsObject())
    cls= [V8Dictionary class];
  return cls;
}
id nodejs_to_objc(Isolate *isolate, Local<Value> v)
{
  if (!isolate) isolate= Isolate::GetCurrent();
  if(v->IsNumber())
    return [NSNumber numberWithDouble:v->ToNumber()->Value()];
  return [[ALLOC(nodejs_to_objc_class(v)) initWithV8:v isolate:isolate] autorelease];
}

Local<Value> parseJson(Local<Value> jsonString) {
  Isolate *isolate= Isolate::GetCurrent();
  EscapableHandleScope handle_scope(isolate);
  Local<Object> global = isolate->GetCurrentContext()->Global();
  Local<Object> JSON = global->Get(String::NewFromUtf8(isolate, "JSON"))->ToObject();
  Local<Function> JSON_parse = Local<Function>::Cast(JSON->Get(String::NewFromUtf8(isolate, "parse")));
  
  // return JSON.parse.apply(JSON, jsonString);
  return handle_scope.Escape(JSON_parse->Call(JSON, 1, &jsonString));
}

static inline void nodejs_debug(Local<Value> value)
{
  NSLog(@"%@", nodejs_to_objc(Isolate::GetCurrent(), parseJson(value)));
}

Local<Function> nodejs_method(Isolate *isolate, Local<Object> object, const char *methodname)
{
  if (!isolate) isolate= Isolate::GetCurrent();
  return Local<Function>::Cast(object->Get(String::NewFromUtf8(isolate, methodname)));;
}

Local<Value> nodejs_call_with_ids(Isolate *isolate, Local<Object> object, const char *methodname, ...)
{
  if (!isolate) isolate= Isolate::GetCurrent();
  std::vector< Local<Value> > argv;
  va_list ap;
  va_start(ap, methodname);
  id o;
  while((o= va_arg(ap, id))) {
    argv.push_back([o toV8:isolate]);
  }
  va_end(ap);
  return nodejs_call(isolate, object, methodname, (int)argv.size(), argv.data());
}
Local<Value> nodejs_call_with_ids(Isolate *isolate, void* object, const char *methodname, ...)
{
  if (!isolate) isolate= Isolate::GetCurrent();
  std::vector< Local<Value> > argv;
  va_list ap;
  va_start(ap, methodname);
  id o;
  while((o= va_arg(ap, id))) {
    argv.push_back([o toV8:isolate]);
  }
  va_end(ap);
  return nodejs_call(isolate, object, methodname, (int)argv.size(), argv.data());
}

Local<Value> nodejs_call(Isolate *isolate, void* pobject, const char *methodname, int argc , Local<Value> *argv)
{
  if (!isolate) isolate= Isolate::GetCurrent();
  Local<Object> object= Local<Object>::New(isolate, *(Persistent<Object>*)pobject);
  return nodejs_call(isolate, object, methodname, argc, argv);
}

Local<Value> nodejs_call(Isolate *isolate, Local<Object> object, const char *methodname, int argc, Local<Value> *argv)
{
  if (!isolate) isolate= Isolate::GetCurrent();
  TryCatch trycatch;
  Local<Value> m= object->Get(String::NewFromUtf8(isolate, methodname));
  assert(m->IsFunction());
  Local<Value> ret=Local<Function>::Cast(m)->Call(object, argc, argv);
  if (trycatch.HasCaught()) {
    Local<Value> exception = trycatch.Exception();
    String::Utf8Value exception_str(exception);
    printf("Exception: %s\n", *exception_str);
  }
  return ret;
}

id nodejs_get(Isolate *isolate, void *pobject, const char *attrname)
{
  if (!pobject) return nil;
  if (!isolate) isolate= Isolate::GetCurrent();
  Local<Object> object= Local<Object>::New(isolate, *(Persistent<Object>*)pobject);
  return nodejs_to_objc(isolate, object->Get(String::NewFromUtf8(isolate, attrname)));
}

typedef void (*nodejs_callback_t)(id self, const FunctionCallbackInfo<Value> &args);

void nodejs_callback_fct(const FunctionCallbackInfo<Value> &args)
{
  /*int64_t start, end;
  start= time_usec();*/
  
  Isolate* isolate= args.GetIsolate();
  HandleScope handle_scope(isolate);
  NEW_POOL;
  Local<Object> data = Local<Object>::Cast(args.Data());
  assert(data->InternalFieldCount() == 2);
  id object= (id)Local<External>::Cast(data->GetInternalField(0))->Value();
  nodejs_callback_t cb= (nodejs_callback_t)Local<External>::Cast(data->GetInternalField(1))->Value();
  cb(object, args);
  KILL_POOL;
  
  /*end = time_usec();
  double elapsed = (end - start) / 1000;
  printf("nodejs event handled in %f ms\n", elapsed);*/
}
void nodejs_callback_simple_fct(const FunctionCallbackInfo<Value> &args)
{
  Isolate* isolate= args.GetIsolate();
  HandleScope handle_scope(isolate);
  NEW_POOL;
  Local<Object> data = Local<Object>::Cast(args.Data());
  assert(data->InternalFieldCount() == 2);
  void* object= (void*)Local<External>::Cast(data->GetInternalField(0))->Value();
  void(*cb)(void*)= (void(*)(void*))Local<External>::Cast(data->GetInternalField(1))->Value();
  cb(object);
  KILL_POOL;
}

Local<Function> nodejs_callback(Isolate* isolate, id object, nodejs_callback_t cb)
{
  Local<ObjectTemplate> data_templ = ObjectTemplate::New(isolate);
  data_templ->SetInternalFieldCount(2);
  Local<Object> data = data_templ->NewInstance();
  data->SetInternalField(0, External::New(isolate, (void*)object));
  data->SetInternalField(1, External::New(isolate, (void*)cb));
  return Function::New(isolate, nodejs_callback_fct, data);
}
Local<Function> nodejs_callback_simple(Isolate* isolate, void* object, void(*cb)(void*))
{
  Local<ObjectTemplate> data_templ = ObjectTemplate::New(isolate);
  data_templ->SetInternalFieldCount(2);
  Local<Object> data = data_templ->NewInstance();
  data->SetInternalField(0, External::New(isolate, (void*)object));
  data->SetInternalField(1, External::New(isolate, (void*)cb));
  return Function::New(isolate, nodejs_callback_simple_fct, data);
}
Local<Object> nodejs_require(const char *module)
{
  Isolate *isolate =Isolate::GetCurrent();
  Local<Function> require= Local<Function>::New(isolate,  __nodejs_require_fct);
  Local<Value> requireArgs[]= { String::NewFromUtf8(isolate, module) };
  return Local<Object>::Cast(require->Call(require, 1, requireArgs));
}

static void * _MSNodeSetTimer(void (*cb)(void* context), double delay, void *context, const char *m)
{
  Isolate *isolate =Isolate::GetCurrent();
  Local<Object> timers= nodejs_require("timers");
  Local<Value> r= nodejs_call(isolate, timers, m, 2, (Local<Value>[]){ nodejs_callback_simple(isolate, context, cb), Number::New(isolate, delay) });
  return (void*)new Persistent<Value>(isolate, r);
}
static void _MSNodeClearTimer(void *timeout, const char *m)
{
  Isolate *isolate =Isolate::GetCurrent();
  Persistent<Value> *r= (Persistent<Value> *)timeout;
  Local<Object> timers= nodejs_require("timers");
  nodejs_call(isolate, timers, m, 1, (Local<Value>[]){ Local<Value>::New(isolate, *r) });
  delete r;
}
void* MSNodeSetTimeout(void (*cb)(void* context), double delay, void *context)
{ return _MSNodeSetTimer(cb, delay, context, "setTimeout"); }
void MSNodeClearTimeout(void *timeout)
{ _MSNodeClearTimer(timeout, "clearTimeout"); }
void* MSNodeSetInterval(void (*cb)(void* context), double delay, void *context)
{ return _MSNodeSetTimer(cb, delay, context, "setInterval"); }
void MSNodeClearInterval(void *timeout)
{ _MSNodeClearTimer(timeout, "clearInterval"); }

typedef struct {
  void (*cb)(void* context);
  void *context;
} Instance;

static void MSNodeStartCallback(const FunctionCallbackInfo<Value> &args, void *context)
{
  NEW_POOL;
  MSNetArgs= &args;
  Isolate* isolate= args.GetIsolate();
  HandleScope handle_scope(isolate);
  Local<Object> global= Local<Object>::Cast(args[0]);
  Local<Function> require= Local<Function>::Cast(global->Get(String::NewFromUtf8(isolate, "require")));
  __nodejs_require_fct.Reset(isolate, require);
  
  Instance *instance= (Instance*)context;
  instance->cb(instance->context);
  KILL_POOL;
}
extern "C" int MSNodeStart(void (*cb)(void* context), void* context)
{
  Instance instance;
  instance.cb= cb;
  instance.context= context;
  char args[]= "node\0--eval\0process._runAtStart(global)";
  char *argv[]= {args, args + 5, args + 5 + 7};
  node::AtStart(MSNodeStartCallback, (void*)&instance);
  int ret= node::Start(3, argv);
  return ret;
}

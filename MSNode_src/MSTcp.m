#import "MSNode_Private.h"

const int STATE_READING = 0x1;

@interface _MSTcpConnection : MSTcpConnection {
  uv_stream_t* _stream;
  MSHandlerList _onData, _onClose;
}
- (instancetype)initWithStream:(uv_stream_t*)stream;
- (MSHandler *)addOnDataHandler:(MSTcpConnectionDataHandler)handler args:(int)argc, ...;
- (MSHandler *)addOnCloseHandler:(MSTcpConnectionCloseHandler)handler args:(int)argc, ...;
- (void)emitData:(NSData *)data;
- (void)emitClose:(NSString *)error;
- (void)write:(MSBuffer *)buffer;
- (void)writeBytes:(void *)bytes length:(NSUInteger)length;
- (void)writeEnd;
@end

@interface _MSTcpServer : MSTcpServer {
@public
  uv_tcp_t _handle;
  MSHandlerList _onListening, _onConnection, _onClose;
}
- (instancetype)initWithPort:(MSUInt)port hostname:(NSString *)hostname;
@end

@implementation _MSTcpConnection
/////
// callbacks

static void _alloc_cb(uv_handle_t* handle, size_t suggested_size, uv_buf_t* buf)
{
  buf->base = (char *)MSMalloc(suggested_size, "MSTcpConnection read");
  buf->len = suggested_size;
}
static void _read_cb(uv_stream_t* stream, ssize_t nread, const uv_buf_t* buf)
{
  if (nread > 0) {
    NEW_POOL;
    CBuffer *b= CCreateBufferWithBytesNoCopy(buf->base, nread);
    [((_MSTcpConnection *)stream->data) emitData:(id)b];
    RELEASE(b);
    KILL_POOL;}
  else if (nread < 0) {
    [(id)stream->data emitClose:nread == UV_EOF ? nil : FMT(@"uv_read error:%s", uv_strerror((int)nread))];}
}
static void _write_cb(uv_write_t* req, int status)
{
  RELEASE((id)req->data);
  MSFree(req, "MSTcpConnection write");
}
static void _shutdown_cb(uv_shutdown_t* req, int status)
{
  uv_stream_t *stream= req->data;
  uv_read_stop(stream);
  RELEASE((id)stream->data);
  MSFree(stream, "MSTcpConnection shutdown");
  MSFree(req, "MSTcpConnection shutdown");
}
//
/////

/////
// init
- (instancetype)initWithStream:(uv_stream_t*)stream
{
  if ((self= [self init])) {
    _stream= stream;
    stream->data= [self retain];
    uv_read_start(stream, _alloc_cb, _read_cb);
    [self retain];
  }
  return self;
}
- (void)dealloc
{
  // assert(!(_state & STATE_READING));
  MSHandlerListFreeInside(&_onData);
  MSHandlerListFreeInside(&_onClose);
  [super dealloc];
}
//
/////

/////
// events
- (MSHandler *)addOnDataHandler:(MSTcpConnectionDataHandler)handler args:(int)argc, ...
{ return MSHandlerListAdd(&_onData, handler, argc, argc); }
- (MSHandler *)addOnCloseHandler:(MSTcpConnectionCloseHandler)handler args:(int)argc, ...
{ return MSHandlerListAdd(&_onClose, handler, argc, argc); }

- (void)emitData:(NSData *)data
{ MSHandlerListCall(&_onData, MSTcpConnectionDataHandler, self, data); }
- (void)emitClose:(NSString *)error
{ MSHandlerListCall(&_onClose, MSTcpConnectionCloseHandler, self, error); }
//
/////

/////
// write
- (void)writeBytes:(void *)bytes length:(NSUInteger)length
{
  [self write:AUTORELEASE(CCreateBufferWithBytes(bytes, length))];
}

- (void)write:(NSData *)data
{
  uv_buf_t buf; int ret; uv_write_t *req;

  if (!_stream) return;
  if (![data isKindOfClass:[MSBuffer class]]) {
    data= [MSBuffer bufferWithData:data];}

  buf.base = (char *)CBufferBytes((CBuffer*)data);
  buf.len = CBufferLength((CBuffer*)data);

  ret= uv_try_write(_stream, &buf, 1);
  if (ret == UV_ENOSYS || ret == UV_EAGAIN)
    ret= 0;
  if (ret >= 0) {
    buf.base += ret;
    buf.len -= ret;
    req= MSMalloc(sizeof(uv_write_t), "MSTcpConnection write");
    req->data = RETAIN(data);
    uv_write(req, _stream, &buf, 1, _write_cb);}
}

- (void)writeEnd
{
  if (_stream) {
    uv_shutdown_t *req;
    req= (uv_shutdown_t*)MSMalloc(sizeof(uv_shutdown_t), "MSTcpConnection shutdown");
    req->data= _stream;
    uv_shutdown(req, _stream, _shutdown_cb);
    _stream= NULL;}
}
//
/////

@end

@implementation _MSTcpServer
/////
// callbacks
static void _connection_cb(uv_stream_t* server, int status)
{
  NEW_POOL;
  MSTcpConnection *conn; uv_tcp_t *handle;
  handle= (uv_tcp_t*)MSMalloc(sizeof(uv_tcp_t), "MSTcp _connection_cb");
  status= uv_tcp_init(server->loop, handle);
  if (status == 0) {
    status= uv_accept(server, (uv_stream_t*)handle);}
  if (status == 0) {
    conn= [ALLOC(_MSTcpConnection) initWithStream:(uv_stream_t*)handle];
    [(_MSTcpServer*)server->data emitConnection:conn];
    RELEASE(conn);}
  if (status != 0) {
    MSFree(handle, "MSTcp _connection_cb");}
  KILL_POOL;
}

static void _listen_getaddrinfo_cb(uv_getaddrinfo_t* req, int status, struct addrinfo* res)
{
  NEW_POOL;
  struct sockaddr* addr; uv_tcp_t* handle; uv_loop_t *loop; _MSTcpServer *self; const char *errtype;
  errtype= "uv_getaddrinfo";
  self= (_MSTcpServer*)req->data;
  if (status == 0) {
    loop= req->loop;
    handle= &self->_handle;
    addr= req->addrinfo->ai_addr;
    errtype= "uv_tcp_bind";
    status= uv_tcp_bind(handle, addr, 0);
    if (status == 0) {
      errtype= "uv_listen";
      status= uv_listen((uv_stream_t *)handle, 5000, _connection_cb);}}
  uv_freeaddrinfo(req->addrinfo);
  MSFree(req, "MSTcp listenAtPort");
  [self emitListening:status == 0 ? nil : FMT(@"%s, [%d]%s", errtype, status, uv_strerror(status))];
  KILL_POOL;
}
static void _server_shutdown_cb(uv_shutdown_t* req, int status)
{
  RELEASE((id)req->data);
  MSFree(req, "_MSTcpServer shutdown");
}
//
/////

/////
// init
- (instancetype)initWithPort:(MSUInt)port hostname:(NSString *)hostname
{
  if ((self= [super init])) {
    int err= 0;

    err= uv_tcp_init([NSRunLoop currentUvRunLoop], &_handle);
    if (!err) {
      [self listenAtPort:port hostname:hostname];}
    if (err) {
      DESTROY(self);}
    else {
      _handle.data= RETAIN(self);}
  }
  return self;
}
- (void)listenAtPort:(MSUInt)port hostname:(NSString *)hostname
{
  uv_getaddrinfo_t *req; char strport[16];

  req= (uv_getaddrinfo_t*)MSMalloc(sizeof(uv_getaddrinfo_t), "MSTcp listenAtPort");
  req->data = [self retain];
  snprintf(strport, 16, "%u", port);
  uv_getaddrinfo(_handle.loop, req, _listen_getaddrinfo_cb, [hostname UTF8String], strport, NULL);
}

- (void)dealloc
{
  [super dealloc];
}
//
/////

/////
// events
- (MSHandler *)addOnListeningHandler:(MSTcpServerListeningHandler)handler args:(int)argc, ...
{ return MSHandlerListAdd(&_onListening, handler, argc, argc); }
- (MSHandler *)addOnConnectionHandler:(MSTcpServerConnectionHandler)handler args:(int)argc, ...
{ return MSHandlerListAdd(&_onConnection, handler, argc, argc); }
- (MSHandler *)addOnCloseHandler:(MSTcpServerCloseHandler)handler args:(int)argc, ...
{ return MSHandlerListAdd(&_onClose, handler, argc, argc); }

- (void)emitListening:(NSString *)error
{ MSHandlerListCall(&_onListening, MSTcpServerListeningHandler, self, error); }
- (void)emitConnection:(MSTcpConnection *)connection
{ MSHandlerListCall(&_onConnection, MSTcpServerConnectionHandler, self, connection); }
- (void)emitClose:(NSString *)error
{ MSHandlerListCall(&_onClose, MSTcpServerCloseHandler, self, error); }
//
/////

- (void)close
{
  if (_handle.data) {
    uv_shutdown_t *req;
    req= (uv_shutdown_t*)MSMalloc(sizeof(uv_shutdown_t), "_MSTcpServer shutdown");
    req->data= self;
    uv_shutdown(req, (uv_stream_t *)&_handle, _server_shutdown_cb);
    _handle.data= NULL;}
}
@end

@implementation MSTcpConnection
- (void)write:(MSBuffer *)buffer{}
- (void)writeBytes:(void *)bytes length:(NSUInteger)length{}
- (void)writeEnd{}

- (MSHandler *)addOnDataHandler:(MSTcpConnectionDataHandler)handler args:(int)argc, ...{ return NULL; }
- (MSHandler *)addOnCloseHandler:(MSTcpConnectionCloseHandler)handler args:(int)argc, ...{ return NULL; }
@end

@implementation MSTcpServer
+ (MSTcpServer*)tcpServerAtPort:(MSUInt)port hostname:(NSString *)hostname
{
  return AUTORELEASE([ALLOC(_MSTcpServer) initWithPort:port hostname:hostname]);
}

- (void)close { }
- (MSHandler *)addOnListeningHandler:(MSTcpServerListeningHandler)handler args:(int)argc, ... { return NULL; }
- (MSHandler *)addOnConnectionHandler:(MSTcpServerConnectionHandler)handler args:(int)argc, ... { return NULL; }
- (MSHandler *)addOnCloseHandler:(MSTcpServerCloseHandler)handler args:(int)argc, ... { return NULL; }

typedef struct
{
  uv_getaddrinfo_t getaddr;
  uv_connect_t connect;
  MSTcpConnectHandler handler;
  // ... args
} _tcp_connect_t;

static void _connect_cb(uv_connect_t* req, int status)
{
  NEW_POOL;
  MSTcpConnection *conn= nil; _tcp_connect_t* d;
  d= (_tcp_connect_t*)req->data;
  if (status == 0) {
    conn= [ALLOC(_MSTcpConnection) initWithStream:req->handle];}
  d->handler(conn, status == 0 ? nil : FMT(@"connect, [%d]%s", status, uv_strerror(status)), (MSHandlerArg *)(d + 1));
  MSFree(d, "MSTcp tcpConnectAtPort");
  RELEASE(conn);
  KILL_POOL;
}

static void _connect_getaddrinfo_cb(uv_getaddrinfo_t* req, int status, struct addrinfo* res)
{
  NEW_POOL;
  _tcp_connect_t* d; struct sockaddr* addr; uv_tcp_t* handle; uv_loop_t *loop; const char *errtype;
  //MSTcpConnection *stream= nil; NSString *error= nil;
  errtype= "uv_getaddrinfo";
  d= (_tcp_connect_t*)req->data;
  if (status == 0) {
    loop= req->loop;
    addr= req->addrinfo->ai_addr;
    d->connect.data= d;
    handle= (uv_tcp_t*)MSMalloc(sizeof(uv_tcp_t), "MSTcp _connect_getaddrinfo_cb");
    errtype= "uv_tcp_init";
    status= uv_tcp_init(req->loop, handle);
    if (status == 0) {
      errtype= "uv_tcp_connect";
      status= uv_tcp_connect(&d->connect, handle, addr, _connect_cb);}
    if (status != 0) {
      MSFree(handle, "MSTcp _connect_getaddrinfo_cb");}}
  if (status != 0) {
    uv_freeaddrinfo(req->addrinfo);
    d->handler(nil, FMT(@"%s, [%d]%s", errtype, status, uv_strerror(status)), (MSHandlerArg *)(d + 1));
    MSFree(d, "MSTcp tcpConnectAtPort");}
  KILL_POOL;
}

+ (void)tcpConnectAtPort:(MSUInt)port hostname:(NSString *)hostname onConnect:(MSTcpConnectHandler)handler args:(int)argc, ...;
{
  uv_loop_t *loop; uv_getaddrinfo_t* req; _tcp_connect_t* d; va_list ap; char strport[16];

  loop= [NSRunLoop currentUvRunLoop];
  d= (_tcp_connect_t*)MSMalloc(sizeof(_tcp_connect_t) + argc * sizeof(MSHandlerArg), "MSTcp tcpConnectAtPort");
  req= &d->getaddr;
  req->data= d;
  d->handler= handler;
  va_start(ap, argc);
  MSHandlerFillArguments((MSHandlerArg *)(d + 1), argc, ap);
  va_end(ap);
  snprintf(strport, 16, "%u", port);
  uv_getaddrinfo(loop, req, _connect_getaddrinfo_cb, [hostname UTF8String], strport, NULL);
}
@end


#import "msnode_validate.h"

static BOOL _tcpServerListeningHandler(MSTcpServer *server, NSString *error, MSHandlerArg *args)
{
  test_t *test= (test_t *)args[0].ptr;
  TASSERT(test, server, "server must not be nil");
  TASSERT(test, !error, "error must be nil, got:%s", [error UTF8String]);
  (*args[1].i4Ptr)++;
  [[args[2].id retain] autorelease];
  return YES;
}

static BOOL _tcpServerConnectionHandler(MSTcpServer *server, MSTcpConnection *connection, MSHandlerArg *args)
{
  test_t *test= (test_t *)args[0].ptr;
  TASSERT(test, server, "server must not be nil");
  TASSERT(test, connection, "connection must not be nil");
  (*args[1].i4Ptr)++;
  [[args[2].id retain] autorelease];
  *args[3].idPtr= [connection retain];
  return YES;
}

static BOOL _tcpConnectHandler(MSTcpConnection *stream, NSString *error, MSHandlerArg *args)
{
  test_t *test= (test_t *)args[0].ptr;
  TASSERT(test, stream, "stream must not be nil");
  TASSERT(test, !error, "error must be nil, got:%s", [error UTF8String]);
  (*args[1].i4Ptr)++;
  [[args[2].id retain] autorelease];
  *args[3].idPtr= [stream retain];
  return YES;
}

static BOOL _tcpDataHandler(MSTcpConnection *stream, NSData *data, MSHandlerArg *args)
{
  test_t *test= (test_t *)args[0].ptr;
  TASSERT(test, stream, "stream must not be nil");
  TASSERT(test, data, "data must not be nil");
  TASSERT(test, [data length] > 0, "data must not be empty");
  (*args[1].i4Ptr)++;
  [[args[2].id retain] autorelease];
  [args[3].id appendData:data];
  return YES;
}
static BOOL _tcpCloseHandler(MSTcpConnection *stream, NSString *error, MSHandlerArg *args)
{
  return YES;
}

static void tcp_server(test_t *test)
{
  NEW_POOL;
  MSTcpServer *server; MSTcpConnection *clientToServer= nil, *serverToClient= nil;
  int pass0= 0, pass1=0, pass2=0, pass3= 0, pass4= 0;
  MSBuffer *clientToServerData, *serverToClientData;
  MSBuffer *clientToServerExpectedData, *serverToClientExpectedData;
  NSUInteger poolcheckRC; id poolcheck;

  poolcheck= [[NSObject new] autorelease];
  poolcheckRC= [poolcheck retainCount];

  /////
  // connection
  server= [MSTcpServer tcpServerAtPort:12345 hostname:@"127.0.0.1"];
  [server addOnListeningHandler:_tcpServerListeningHandler args:3,
    MSMakeHandlerArg(test), MSMakeHandlerArg(&pass0), MSMakeHandlerArg(poolcheck)];
  [server addOnConnectionHandler:_tcpServerConnectionHandler args:4,
    MSMakeHandlerArg(test), MSMakeHandlerArg(&pass2), MSMakeHandlerArg(poolcheck), MSMakeHandlerArg(&serverToClient)];
  TASSERT(test, server != nil, "server must not be nil");
  TASSERT(test, pass0 == 0, "server listening event was fired too soon");
  TASSERT(test, pass2 == 0, "server connection event was fired too soon");
  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
  TASSERT(test, pass0 > 0, "server listening event was not fired");
  TASSERT(test, pass0 < 2, "server listening event was fired multiple times");
  TASSERT_EQUALS_LLD(test, [poolcheck retainCount], poolcheckRC);
  TASSERT(test, pass2 == 0, "server connection event was fired too soon");

  [MSTcpServer tcpConnectAtPort:12345 hostname:@"127.0.0.1" onConnect:_tcpConnectHandler args:4,
    MSMakeHandlerArg(test), MSMakeHandlerArg(&pass1), MSMakeHandlerArg(poolcheck), MSMakeHandlerArg(&clientToServer)];
  TASSERT(test, pass1 == 0, "connect event was fired too soon");
  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
  TASSERT(test, pass1 > 0, "connect event was not fired");
  TASSERT(test, pass1 < 2, "connect event was fired multiple times");
  TASSERT_EQUALS_LLD(test, [poolcheck retainCount], poolcheckRC);
  //
  ////

  ////
  // data exchanges
  TASSERT(test, serverToClient, "serverToClient must not be nil");
  TASSERT(test, clientToServer, "clientToServer must not be nil");

  clientToServerData= [MSBuffer mutableBuffer];
  serverToClientData= [MSBuffer mutableBuffer];
  [serverToClient addOnDataHandler:_tcpDataHandler args:4,
    MSMakeHandlerArg(test), MSMakeHandlerArg(&pass3), MSMakeHandlerArg(poolcheck), MSMakeHandlerArg(clientToServerData)];
  [clientToServer addOnDataHandler:_tcpDataHandler args:4,
    MSMakeHandlerArg(test), MSMakeHandlerArg(&pass4), MSMakeHandlerArg(poolcheck), MSMakeHandlerArg(serverToClientData)];
  [serverToClient write:(serverToClientExpectedData= [MSBuffer bufferWithCString:"tcp server to client data test"])];
  [clientToServer write:(clientToServerExpectedData= [MSBuffer bufferWithCString:"tcp client to server data test"])];
  TASSERT(test, pass3 == 0, "server to client data event was fired too soon");
  TASSERT(test, pass4 == 0, "client to server data event was fired too soon");
  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
  TASSERT(test, pass3 > 0, "server to client data event was not fired");
  TASSERT(test, pass4 > 0, "client to server data event was not fired");
  TASSERT_EQUALS_OBJ(test, serverToClientData, serverToClientExpectedData);
  TASSERT_EQUALS_OBJ(test, clientToServerData, clientToServerExpectedData);
  TASSERT_EQUALS_LLD(test, [poolcheck retainCount], poolcheckRC);
  //
  /////

  /////
  // shutdown
  [serverToClient writeEnd];
  [clientToServer writeEnd];
  [server close];

  [serverToClient release];
  [clientToServer release];
  //
  /////

  KILL_POOL;
}

testdef_t msnode_tcp[]= {
  {"server", NULL, tcp_server},
  {NULL}};

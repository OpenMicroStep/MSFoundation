@class MSTcpServer, MSTcpConnection;

typedef BOOL (*MSTcpConnectHandler)(MSTcpConnection *stream, NSString *error, MSHandlerArg *args);
typedef BOOL (*MSTcpServerListeningHandler)(MSTcpServer *server, NSString *error, MSHandlerArg *args);
typedef BOOL (*MSTcpServerConnectionHandler)(MSTcpServer *server, MSTcpConnection *connection, MSHandlerArg *args);
typedef BOOL (*MSTcpServerCloseHandler)(MSTcpServer *server, NSString *error, MSHandlerArg *args);

typedef BOOL (*MSTcpConnectionDataHandler)(MSTcpConnection *stream, NSData *data, MSHandlerArg *args);
typedef BOOL (*MSTcpConnectionCloseHandler)(MSTcpConnection *stream, NSString *error, MSHandlerArg *args);

@interface MSTcpConnection : NSObject
- (void)write:(NSData *)data;
- (void)writeBytes:(void *)bytes length:(NSUInteger)length;
- (void)writeEnd;

- (MSHandler *)addOnDataHandler:(MSTcpConnectionDataHandler)handler args:(int)argc, ...;
- (MSHandler *)addOnCloseHandler:(MSTcpConnectionCloseHandler)handler args:(int)argc, ...;
@end

@interface MSTcpServer : NSObject
+ (void)tcpConnectAtPort:(MSUInt)port hostname:(NSString *)hostname onConnect:(MSTcpConnectHandler)handler args:(int)argc, ...;
+ (MSTcpServer*)tcpServerAtPort:(MSUInt)port hostname:(NSString *)hostname;
- (void)close;

- (MSHandler *)addOnListeningHandler:(MSTcpServerListeningHandler)handler args:(int)argc, ...;
- (MSHandler *)addOnConnectionHandler:(MSTcpServerConnectionHandler)handler args:(int)argc, ...;
- (MSHandler *)addOnCloseHandler:(MSTcpServerCloseHandler)handler args:(int)argc, ...;
@end


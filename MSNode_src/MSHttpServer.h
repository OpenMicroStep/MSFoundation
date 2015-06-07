@class MSHttpServer, MSHttpTransaction;

@protocol MSHttpServerDelegate
- (void)onServerListening:(MSHttpServer*)server;
- (void)onServer:(MSHttpServer*)server transaction:(MSHttpTransaction *)tr;
- (void)onServerClose:(MSHttpServer*)server;
- (void)onServer:(MSHttpServer*)server error:(NSString*)err;
- (void)onServer:(MSHttpServer*)server clientError:(NSString*)err;
@end

@interface MSHttpServer : NSObject {
@protected
  void *_priv;
  id <MSHttpServerDelegate> _delegate;
}

+ (instancetype)httpServer;
- (void)listenAtPort:(MSUInt)port hostname:(NSString *)hostname;
- (void)listenAtPath:(NSString*)path;
- (void)close;

- (void)setDelegate:(id <MSHttpServerDelegate>)delegate;
- (id <MSHttpServerDelegate>)delegate;

- (void)onServerListening:(MSHttpServer*)server;
- (void)onServer:(MSHttpServer*)server transaction:(MSHttpTransaction *)tr;
- (void)onServerClose:(MSHttpServer*)server;
- (void)onServer:(MSHttpServer*)server error:(NSString*)err;
- (void)onServer:(MSHttpServer*)server clientError:(NSString*)err;
@end

@interface MSHttpsServer : MSHttpServer {
}

/**
 pfx is mutually exclusive with cert, key and ca.
 either pfx or cert and key must be provided.
 port, path, hostname, passphare are optionals.
 parameters= {
	pfx= path to/buffer of the pfx (if provided, cert, key and ca are ignored)

	cert= path to/buffer of the certificat
	key= path to/buffer of the private key

	passphrase= passphrase

	port= port to listen to
	hostname= hostname to listen to
	path= path to listen to
 }
*/
+ (instancetype)httpsServerWithCertificate:(NSData *)crt withKey:(NSData *)key;
- (instancetype)initWithCertificate:(NSData *)crt withKey:(NSData *)key;
+ (instancetype)httpsServerWithParameters:(NSDictionary *)parameters;
+ (instancetype)httpsServerWithParameters:(NSDictionary *)parameters withPath:(NSString *)path error:(NSString **)perror;
- (instancetype)initWithParameters:(NSDictionary *)parameters;
- (instancetype)initWithParameters:(NSDictionary *)parameters withPath:(NSString *)path error:(NSString **)perror;
@end

@protocol MSHttpMiddleware;

@interface MSHttpApplicationClient : NSObject {
  MSHttpCookieManager *_cookieManager;
  NSDictionary *_parameters;
  BOOL _https;
  NSData *_pfx, *_ca, *_cert, *_key;
  NSString *_passphrase, *_url;
  MSHttpsAgent *_agent;
}
+ (instancetype)clientWithParameters:(NSDictionary *)parameters withPath:(NSString *)path;
- (instancetype)initWithParameters:(NSDictionary *)parameters withPath:(NSString *)path;
- (MSHttpCookieManager *)cookieManager;

- (NSString*)baseURL;
- (void)setBaseURL:(NSString*)baseurl;
- (void)setHttps:(BOOL)https;
- (void)setPFX:(NSData *)pfx;
- (void)setCertificateAutority:(NSData *)ca;
- (void)setCertificate:(NSData *)cert privateKey:(NSData *)key;
- (void)setCertificate:(NSData *)cert privateKey:(NSData *)key passphrase:(NSString *)passphrase;

- (MSHttpClientRequest *)request:(MSHttpMethod)method at:(NSString *)at;
- (MSHttpClientRequest *)getRequest:(NSString *)at;
- (MSHttpClientRequest *)postRequest:(NSString *)at;
@end

@interface MSHttpApplication : MSHttpRouter {
  CArray *_servers;
  NSString *_path;
  NSDictionary *_parameters;
}
- (NSString *)path;
- (NSDictionary *)parameters;
/*
  parameters= {
    class= application class name
    ...app parameters
    applications= [
      {
        class= application class name
        route= "route"
        ...app parameters
      }
    ]
    servers= [
      { * see MSHttpsServer initWithParameters * }
    ]
  }
*/
+ (NSArray *)applicationsWithParameters:(NSDictionary *)parameters withPath:(NSString *)path error:(NSString **)perror;

/*
  parameters= {
    servers= [
      { * see MSHttpsServer initWithParameters * }
    ]
  }
*/
- (instancetype)initWithParameters:(NSDictionary *)parameters withPath:(NSString *)path error:(NSString **)perror;
@end
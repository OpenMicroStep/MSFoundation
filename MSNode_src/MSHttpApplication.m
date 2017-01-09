#import "MSNode_Private.h"

@implementation MSHttpApplicationClient
+ (instancetype)clientWithParameters:(NSDictionary *)parameters withPath:(NSString *)path
{ return AUTORELEASE([ALLOC(self) initWithParameters:parameters withPath:path]); }
- (instancetype)initWithParameters:(NSDictionary *)parameters withPath:(NSString *)path
{
  _parameters= [parameters retain];
  _cookieManager= [MSHttpCookieManager new];
  _url= [[parameters objectForKey:@"url"] retain];
  _https= ![_url hasPrefix:@"http://"];
  _pfx= [MSHttpLoadBuffer([parameters objectForKey:@"pfx" ], path) retain];
  _ca=  [MSHttpLoadBuffer([parameters objectForKey:@"ca"  ], path) retain];
  _cert=[MSHttpLoadBuffer([parameters objectForKey:@"cert"], path) retain];
  _key= [MSHttpLoadBuffer([parameters objectForKey:@"key" ], path) retain];
  _passphrase= [[parameters objectForKey:@"passphrase"] retain];
  _agent= _https ? [[MSHttpsAgent httpsAgent] retain] : nil;
  return self;
}
- (void)dealloc
{
  [_url release];
  [_parameters release];
  [_cookieManager release];
  [_pfx release];
  [_ca release];
  [_cert release];
  [_key release];
  [_passphrase release];
  [super dealloc];
}

- (MSHttpCookieManager *)cookieManager
{ return _cookieManager; }

- (NSString*)baseURL
{ return _url; }
- (void)setBaseURL:(NSString*)baseurl
{ return ASSIGN(_url, baseurl); }

- (void)setHttps:(BOOL)https
{ _https= https; }
- (void)setPFX:(NSData *)pfx
{ ASSIGN(_pfx, [pfx copy]); }
- (void)setCertificateAutority:(NSData *)ca
{ ASSIGN(_ca, [ca copy]); }
- (void)setCertificate:(NSData *)cert privateKey:(NSData *)key
{ [self setCertificate:cert privateKey:key passphrase:nil]; }
- (void)setCertificate:(NSData *)cert privateKey:(NSData *)key passphrase:(NSString *)passphrase
{
  ASSIGN(_cert, [cert copy]);
  ASSIGN(_key, [key copy]);
  ASSIGN(_passphrase, [passphrase copy]);
}

static BOOL MSHttpApplicationClientEventHandler(MSHttpClientResponse *response, NSString *error, MSHandlerArg *args)
{
  MSHttpCookieManager *manager= [(MSHttpApplicationClient*)args[0].id cookieManager];
  [manager updateWithClientResponse:response];
  return YES;
}
- (MSHttpClientRequest *)request:(MSHttpMethod)method at:(NSString *)at
{
  id request;
  if (_url)
    at= [_url stringByAppendingPathComponent:at];
  if (_https) {
    request= [MSHttpsClientRequest httpsClientRequest:method url:at];
    if (_pfx)
      [request setPFX:_pfx];
    if (_ca)
      [request setCertificateAutority:_ca];
    if (_cert && _key)
      [request setCertificate:_cert privateKey:_key passphrase:_passphrase];
    if (_agent)
      [request setAgent:_agent];
  }
  else {
    request= [MSHttpClientRequest httpClientRequest:method url:at];
  }
  [_cookieManager sendOnClientRequest:request];
  [request addHandler:MSHttpApplicationClientEventHandler args:1, MSMakeHandlerArg(self)];
  return request;
}
- (MSHttpClientRequest *)getRequest:(NSString *)at
{ return [self request:MSHttpMethodGET at:at]; }
- (MSHttpClientRequest *)postRequest:(NSString *)at
{ return [self request:MSHttpMethodPOST at:at]; }
@end

@implementation MSHttpApplication
static void _appWithParameters(CArray *apps, NSDictionary *parameters, NSString *path, NSString **perror, MSHttpApplication *parent)
{
  id className, bundlePath, bundle; MSHttpApplication *app= nil; Class cls; id error= nil;

  if ((bundlePath= [parameters objectForKey:@"bundle"])) {
    //if (![bundlePath isAbsolutePath])
    //  bundlePath= [bundlePath stringByAppendingPathComponent:bundle];
    if (!(bundle= [NSBundle bundleWithPath:bundlePath])) {
      error= FMT(@"Unable to find bundle: %@", bundlePath);}
    if (!error && ![bundle load]) {
      error= FMT(@"Unable to load bundle: %@", bundlePath); }
    if (!error && !(cls= [bundle principalClass])) {
      error= FMT(@"Unable to find bundle principalClass: %@", bundlePath); }
  }

  if (!error && !cls && !(className= [parameters objectForKey:@"class"])) {
    error= @"'class' is not provided";}
  if (!error && !cls && !(cls= NSClassFromString(className))) {
    error= FMT(@"Unable to find application %@", className);}
  if (!error && parent && [parameters objectForKey:@"servers"]) {
    error= FMT(@"Unable to create application %@: servers is not allowed for sub applications", className); }
  if (!error && parent && ![parameters objectForKey:@"baseURL"]) {
    error= FMT(@"Unable to create application %@: baseURL is required for sub applications", className); }
  if (!error && !(app= [ALLOC(cls) initWithParameters:parameters withPath:path error:&error])) {
    error= FMT(@"Unable to create application %@: %@", className, error ? error : @"unknown error");}
  if (!error) {
    NSEnumerator *e; id params;
    if (parent)
      [parent addRoute:app];
    CArrayAddObject(apps, app);
    for (e= [[parameters objectForKey:@"applications"] objectEnumerator]; !error && (params= [e nextObject]); ) {
      _appWithParameters(apps, params, path, &error, app);}
  }
  RELEASE(app);
  *perror= error;
}
+ (NSArray *)applicationsWithParameters:(NSDictionary *)parameters withPath:(NSString *)path error:(NSString **)perror
{
  CArray *apps; id error= nil;
  apps= CCreateArray(0);
  _appWithParameters(apps, parameters, path, &error, nil);
  if (error) {
    if (perror) {
      *perror= error;}
    DESTROY(apps);}
  return AUTORELEASE(apps);
}
+ (instancetype)applicationWithParameters:(NSDictionary *)parameters withPath:(NSString *)path error:(NSString **)perror
{
  return AUTORELEASE([ALLOC(self) initWithParameters:parameters withPath:path error:perror]);
}
- (instancetype)initWithParameters:(NSDictionary *)parameters withPath:(NSString *)path error:(NSString **)perror
{
  if ((self= [super initWithPath:[parameters objectForKey:@"baseURL"] method:MSHttpMethodALL])) {
    NSEnumerator *e; id server;
    _fsPath= [path copy];
    _parameters= [parameters copy];
    _servers= CCreateArray(0);
    for (e= [[parameters objectForKey:@"servers"] objectEnumerator]; self && (server= [e nextObject]); ) {
      server= [MSHttpsServer httpsServerWithParameters:server withPath:path error:perror];
      if (!server)
        DESTROY(self);
      else {
        CArrayAddObject(_servers, server);
        [(MSHttpsServer*)server setDelegate:self];
      }
    }
    NSLog(@"Application started: %@", parameters);
  }
  return self;
}
- (void)dealloc
{
  RELEASE(_servers);
  RELEASE(_fsPath);
  RELEASE(_parameters);
  [super dealloc];
}

- (void)close
{
  for (NSUInteger i= 0, len= CArrayCount(_servers); i < len; i++) {
    MSHttpsServer *server= CArrayObjectAtIndex(_servers, i);
    [server close];
  }
}

- (NSString *)fileSystemPath
{ return _fsPath; }
- (NSDictionary *)parameters
{ return _parameters; }
@end
typedef enum  {
  MSHttpMethodUNKNOWN = 0x00,
  MSHttpMethodGET     = 0x01,
  MSHttpMethodPOST    = 0x02,
  MSHttpMethodPUT     = 0x04,
  MSHttpMethodCONNECT = 0x08,
  MSHttpMethodTRACE   = 0x10,
  MSHttpMethodOPTIONS = 0x20,
  MSHttpMethodDELETE  = 0x40,
  MSHttpMethodHEAD    = 0x80,
  MSHttpMethodALL     = 0xFF
} MSHttpMethod;

typedef enum  {
  MSHttpCodeContinue                    = 100,
  MSHttpCodeSwitchingProtocols          = 101,

  MSHttpCodeOk                          = 200,
  MSHttpCodeCreated                     = 201,
  MSHttpCodeAccepted                    = 202,
  MSHttpCodeNonAuthoritativeInformation = 203,
  MSHttpCodeNoContent                   = 204,
  MSHttpCodeResetContent                = 205,
  MSHttpCodePartialContent              = 206,

  MSHttpCodeMovedPermanently            = 301,
  MSHttpCodeFound                       = 302,
  MSHttpCodeSeeOther                    = 303,
  MSHttpCodeNotModified                 = 304,
  MSHttpCodeUseProxy                    = 305,
  MSHttpCodeTemporaryRedirect           = 307,

  MSHttpCodeBadRequest                  = 400,
  MSHttpCodeUnauthorized                = 401,
  MSHttpCodePaymentRequired             = 402,
  MSHttpCodeForbidden                   = 403,
  MSHttpCodeNotFound                    = 404,
  MSHttpCodeMethodNotAllowed            = 405,
  MSHttpCodeNotAcceptable               = 406,
  MSHttpCodeProxyAuthenticationRequired = 407,
  MSHttpCodeRequestTimeout              = 408,
  MSHttpCodeConflict                    = 409,
  MSHttpCodeGone                        = 410,
  MSHttpCodeLengthRequired              = 411,
  MSHttpCodePreconditionFailed          = 412,
  MSHttpCodeRequestEntityTooLarge       = 413,
  MSHttpCodeRequestURITooLong           = 414,
  MSHttpCodeUnsupportedMediaType        = 415,
  MSHttpCodeRequestedRangeNotSatisfiable= 416,
  MSHttpCodeExpectationFailed           = 417,

  MSHttpCodeInternalServerError         = 500,
  MSHttpCodeNotImplemented              = 501,
  MSHttpCodeBadGateway                  = 502,
  MSHttpCodeServiceUnavailable          = 503,
  MSHttpCodeGatewayTimeout              = 504,
  MSHttpCodeHTTPVersionNotSupported     = 505,
} MSHttpCode;

@class MSHttpTransaction;

@protocol MSHttpRequestDelegate
- (void)onTransaction:(MSHttpTransaction*)tr receiveData:(MSBuffer *)data;
- (void)onTransactionEnd:(MSHttpTransaction*)tr;
- (void)onTransaction:(MSHttpTransaction *)tr error:(NSString*)err;
@end
typedef BOOL (*MSHttpTransactionWriteHeadHandler)(MSHttpTransaction *tr, MSUInt statusCode, void *arg);
typedef BOOL (*MSHttpTransactionWriteDataHandler)(MSHttpTransaction *tr, NSData *data, void *arg);

// MSHttpTransaction objects are created by MSHttpServer or MSHttpsServer once they receive a request.
// This object hold the link between the request and the response, we call that an http transaction.
// Http transaction are usually routed by MSHttpApplication and pre handled by one or many middlewares.
@interface MSHttpTransaction : NSObject {
@private
  int _state;
  void *_req;
  void *_res;
  id <MSHttpRequestDelegate> _delegate;
  void *_writeHeadFirst, *_writeHeadLast;
  void *_writeDataFirst, *_writeDataLast;
  CDictionary * _context;
}

// Request info
- (MSHttpMethod)method;
- (NSString *)rawMethod;
- (NSString*)url;
- (NSString*)urlPath;
- (NSString*)urlQuery;
- (NSDictionary*)urlQueryParameters;
- (NSString*)httpVersion;
- (NSDictionary*)headers;
- (NSString *)valueForHeader:(NSString *)header;
- (NSDictionary*)rawHeaders;
- (BOOL)isXMLHttpRequest;

// Response
- (void)setValue:(NSString*)name forHeader:(NSString*)value;
- (void)writeHead:(MSUInt)statusCode;
- (void)writeHead:(MSUInt)statusCode headers:(NSDictionary*)headers;
- (void)writeData:(NSData *)chunk;
- (void)writeEnd;
- (void)writeFile:(NSString *)path;
- (void)write:(MSUInt)statusCode headers:(NSDictionary *)headers response:(NSData *)chunk;
- (void)write:(MSUInt)statusCode;
- (void)write:(MSUInt)statusCode response:(NSData *)chunk;
- (void)write:(MSUInt)statusCode string:(NSString *)string;
- (void)redirect:(NSString *)to;

// Get/store some stuffs (middleware results, ...)
- (void)addWriteHeadHandler:(MSHttpTransactionWriteHeadHandler)handler context:(void*)arg;
- (void)addWriteDataHandler:(MSHttpTransactionWriteDataHandler)handler context:(void*)arg;
- (id)objectForKey:(id)key;
- (void)setObject:(id)object forKey:(id)key;
- (void)removeObjectForKey:(id)key;

// Set/get/change/proxy http request events
- (void)setDelegate:(id <MSHttpRequestDelegate>)delegate;
- (id <MSHttpRequestDelegate>)delegate;
@end

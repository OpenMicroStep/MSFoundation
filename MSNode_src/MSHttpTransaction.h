@class MSHttpTransaction;

typedef BOOL (*MSHttpTransactionReceiveDataHandler)(MSHttpTransaction *tr, NSData *data, MSHandlerArg *args);
typedef BOOL (*MSHttpTransactionEndHandler)(MSHttpTransaction *tr, NSString *error, MSHandlerArg *args);
typedef BOOL (*MSHttpTransactionWriteHeadHandler)(MSHttpTransaction *tr, MSUInt statusCode, MSHandlerArg *args);
typedef BOOL (*MSHttpTransactionWriteDataHandler)(MSHttpTransaction *tr, NSData *data, MSHandlerArg *args);

// MSHttpTransaction objects are created by MSHttpServer or MSHttpsServer once they receive a request.
// This object hold the link between the request and the response, we call that an http transaction.
// Http transaction are usually routed by MSHttpApplication and pre handled by one or many middlewares.
@interface MSHttpTransaction : NSObject {
@private
  int _state;
  void *_req;
  void *_res;
  MSHandlerList _onReceiveData, _onReceiveEnd;
  MSHandlerList _onWriteHead, _onWriteData;
  CDictionary * _context;
}

// Events
- (MSHandler*)addReceiveDataHandler:(MSHttpTransactionReceiveDataHandler)handler args:(int)argc, ...;
- (MSHandler*)addReceiveEndHandler:(MSHttpTransactionEndHandler)handler args:(int)argc, ...;
- (MSHandler*)addWriteHeadHandler:(MSHttpTransactionWriteHeadHandler)handler args:(int)argc, ...;
- (MSHandler*)addWriteDataHandler:(MSHttpTransactionWriteDataHandler)handler args:(int)argc, ...;

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
- (id)objectForKey:(id)key;
- (void)setObject:(id)object forKey:(id)key;
- (void)removeObjectForKey:(id)key;

@end

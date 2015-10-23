@class MSHttpTransaction;

@protocol MSHttpMiddleware
// tr is autoreleased, if you want to keep them alive for async task don't forget to retain them
- (void)onTransaction:(MSHttpTransaction *)tr;
@end

@interface MSHttpRoute : NSObject <MSHttpServerDelegate> {
  CArray *_routes;
  CString *_path;
  int _method;
  SEL _sel;
  id _target;
}
- (instancetype)initWithPath:(NSString *)path method:(int)method;
- (instancetype)initWithPath:(NSString *)path method:(int)method target:(id)target selector:(SEL)s;
- (instancetype)initWithPath:(NSString *)path method:(int)method middleware:(id <MSHttpMiddleware>)middleware;

- (MSArray *)routes;
- (void)insertRoute:(MSHttpRoute *)route at:(NSUInteger)idx;
- (void)addRoute:(MSHttpRoute *)route;
- (void)addRouteToMiddleware:(id <MSHttpMiddleware>)middleware;
- (void)addRoute:(NSString *)path method:(int)method toMiddleware:(id <MSHttpMiddleware>)middleware;
- (void)addRoute:(NSString *)path method:(int)method toTarget:(id)target selector:(SEL)sel;

- (void)startRoutingTransaction:(MSHttpTransaction *)tr;
- (void)applyWithTransaction:(MSHttpTransaction *)tr;
- (NSUInteger)tryWithPath:(MSString *)path forTransaction:(MSHttpTransaction *)tr;
@end

@interface MSHttpTransaction (MSNetRouting)
/** part url that remains after routing the transaction */
- (NSString *)urlAfterRouting;
/** part of the url that has been routed */
- (NSString *)urlRouted;

- (void)nextRoute;
@end

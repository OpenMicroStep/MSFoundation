@class MSHttpTransaction;

@protocol MSHttpNextMiddleware
- (void)nextMiddleware;
- (NSString *)route;
- (NSString *)routeUrl;
- (MSHttpTransaction *)transaction;
@end

@protocol MSHttpMiddleware
// Both tr and next are autoreleased, if you want to keep them alive for async task don't forget to retain them
// Note: MSHttpNextMiddleware allow you find the transaction again.
- (void)onTransaction:(MSHttpTransaction *)tr next:(id <MSHttpNextMiddleware>)next;
@end

@interface MSHttpRouter : NSObject <MSHttpServerDelegate> {
@private
	CArray *_routes;
	NSString *_baseURL;
}
- (NSString *)baseURL;
- (void)setBaseURL:(NSString *)baseURL;

- (void)route:(MSHttpTransaction*)tr;
- (void)onTransactionLost:(MSHttpTransaction*)tr;
- (void)addRoute:(NSString *)path toRouter:(MSHttpRouter*)router;
- (void)addRouteToMiddleware:(id <MSHttpMiddleware>)middleware;
- (void)addRoute:(NSString *)path method:(int)method toMiddleware:(id <MSHttpMiddleware>)middleware;
- (void)addRoute:(NSString *)path method:(int)method toTarget:(id)target selector:(SEL)sel;

@end
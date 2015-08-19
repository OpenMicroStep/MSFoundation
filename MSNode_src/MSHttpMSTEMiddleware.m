#import "MSNode_Private.h"

@implementation MSHttpMSTEClientResponse
- (instancetype)init
{
  if ((self= [super init])) {
    _decoder= [MSMSTEDecoder new];
  }
  return self;
}
- (void)dealloc
{
  [_decoder release];
  [_decodedObject release];
  [super dealloc];
}
- (void)onResponseData:(NSData *)data
{ 
  [_decoder parseBytes:[data bytes] length:[data length]];
}
- (void)onResponseEnd
{ 
  id error= nil;
  _decodedObject= [[_decoder parseResult:&error] retain];
  [[error retain] autorelease];
  DESTROY(_decoder);
  [self handledWithError:error];
}
- (id)msteDecodedObject
{
  return _decodedObject;
}
@end

@implementation MSHttpMSTEMiddleware
+ (instancetype)msteMiddleware
{ return AUTORELEASE([ALLOC(self) init]); }
- (void)onTransaction:(MSHttpTransaction *)tr next:(id <MSHttpNextMiddleware>)next
{
  [tr setObject:[[MSMSTEDecoder new] autorelease] forKey:@"MSHttpMSTEMiddleware_decoder"];
  [tr setObject:next forKey:@"MSHttpMSTEMiddleware_next"];
  [tr setDelegate:self];
}
- (void)onTransaction:(MSHttpTransaction*)tr receiveData:(MSBuffer *)data
{
  MSMSTEDecoder *d;
  d= [tr objectForKey:@"MSHttpMSTEMiddleware_decoder"];
  [d parseBytes:[data bytes] length:[data length]];
}
- (void)onTransactionEnd:(MSHttpTransaction*)tr
{
  MSMSTEDecoder *d; id <MSHttpNextMiddleware> n; id error= nil;
  d= [tr objectForKey:@"MSHttpMSTEMiddleware_decoder"];
  n= [tr objectForKey:@"MSHttpMSTEMiddleware_next"];
  [tr setObject:[d parseResult:&error] forKey:@"MSHttpMSTEMiddleware"];
  [tr removeObjectForKey:@"MSHttpMSTEMiddleware_decoder"];
  [tr removeObjectForKey:@"MSHttpMSTEMiddleware_next"];
  if (error)
    [tr write:MSHttpCodeBadRequest string:error];
  else
    [n nextMiddleware];
}
- (void)onTransaction:(MSHttpTransaction *)tr error:(NSString*)err
{ 
  [tr write:MSHttpCodeBadRequest];
}
@end

@implementation MSHttpTransaction (MSHttpMSTEMiddleware)
- (id)msteDecodedObject
{ return [self objectForKey:@"MSHttpMSTEMiddleware"]; }
- (void)write:(MSUInt)statusCode mste:(id)rootObject
{
  [self writeHead:statusCode];
  [self writeData:[rootObject MSTEncodedBuffer]];
  [self writeEnd];
}
@end

@implementation MSHttpClientRequest (MSHttpMSTEMiddleware)
- (void)writeMSTE:(id)rootObject
{
  [self writeData:[rootObject MSTEncodedBuffer]];
  [self writeEnd];
}
@end

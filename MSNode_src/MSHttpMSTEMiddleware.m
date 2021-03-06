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

static BOOL _onTransactionReceiveData(MSHttpTransaction *tr, NSData *data, MSHandlerArg *args)
{
  MSMSTEDecoder *decoder= args[0].id;
  [decoder parseBytes:[data bytes] length:[data length]];
  return YES;
}
static BOOL _onTransactionReceiveEnd(MSHttpTransaction *tr, NSString *err, MSHandlerArg *args)
{
  MSMSTEDecoder *decoder= args[0].id;
  id error= nil;

  [tr setObject:[decoder parseResult:&error] forKey:@"MSHttpMSTEMiddleware"];
  if (error)
    [tr write:MSHttpCodeBadRequest string:error];
  else
    [tr nextRoute];
  RELEASE(decoder);
  return YES;
}
- (void)onTransaction:(MSHttpTransaction *)tr
{
  MSMSTEDecoder *decoder;
  decoder= [MSMSTEDecoder new];
  [tr addReceiveDataHandler:_onTransactionReceiveData args:1, MSMakeHandlerArg(decoder)];
  [tr addReceiveEndHandler:_onTransactionReceiveEnd args:1, MSMakeHandlerArg(decoder)];
}
@end

@implementation MSHttpTransaction (MSHttpMSTEMiddleware)
- (id)msteDecodedObject
{ return [self objectForKey:@"MSHttpMSTEMiddleware"]; }
- (void)write:(MSUInt)statusCode mste:(id)rootObject
{
  [self setValue:@"application/json" forHeader:@"Content-Type"];
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

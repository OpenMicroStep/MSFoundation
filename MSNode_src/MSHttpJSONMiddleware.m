#import "MSNode_Private.h"

@implementation MSHttpJSONClientResponse
- (instancetype)init
{
  if ((self= [super init])) {
    _decoder= [MSJSONDecoder new];
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
- (id)jsonDecodedObject
{
  return _decodedObject;
}
@end

@implementation MSHttpJSONMiddleware
+ (instancetype)jsonMiddleware
{ return AUTORELEASE([ALLOC(self) init]); }

static BOOL _onTransactionReceiveData(MSHttpTransaction *tr, NSData *data, MSHandlerArg *args)
{
  MSJSONDecoder *decoder= args[0].id;
  [decoder parseBytes:[data bytes] length:[data length]];
  return YES;
}
static BOOL _onTransactionReceiveEnd(MSHttpTransaction *tr, NSString *err, MSHandlerArg *args)
{
  MSJSONDecoder *decoder= args[0].id;
  id error= nil;

  [tr setObject:[decoder parseResult:&error] forKey:@"MSHttpJSONMiddleware"];
  if (error)
    [tr write:MSHttpCodeBadRequest string:error];
  else
    [tr nextRoute];
  RELEASE(decoder);
  return YES;
}
- (void)onTransaction:(MSHttpTransaction *)tr
{
  MSJSONDecoder *decoder;
  decoder= [MSJSONDecoder new];
  [tr addReceiveDataHandler:_onTransactionReceiveData args:1, MSMakeHandlerArg(decoder)];
  [tr addReceiveEndHandler:_onTransactionReceiveEnd args:1, MSMakeHandlerArg(decoder)];
}
@end

@implementation MSHttpTransaction (MSHttpJSONMiddleware)
- (id)jsonDecodedObject
{ return [self objectForKey:@"MSHttpJSONMiddleware"]; }
- (void)write:(MSUInt)statusCode json:(id)rootObject
{
  [self setValue:@"application/json" forHeader:@"Content-Type"];
  [self writeHead:statusCode];
  [self writeData:[rootObject JSONEncodedBuffer]];
  [self writeEnd];
}
@end

@implementation MSHttpClientRequest (MSHttpJSONMiddleware)
- (void)writeJSON:(id)rootObject
{
  [self writeData:[rootObject JSONEncodedBuffer]];
  [self writeEnd];
}
@end

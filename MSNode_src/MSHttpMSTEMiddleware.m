#import "MSNode_Private.h"

@implementation MSHttpMSTEClientResponse
- (instancetype)init
{
  if ((self= [super init])) {
    _buffer= [MSBuffer new];
  }
  return self;
}
- (void)dealloc
{
  [_decodedObject release];
  [_buffer release];
  [super dealloc];
}
- (void)onResponseData:(NSData *)data
{ 
  [_buffer appendBytes:[data bytes] length:[data length]];
}
- (void)onResponseEnd
{ 
  _decodedObject= [[_buffer MSTDecodedObject] retain];
  DESTROY(_buffer);
  [self handledWithError:nil];
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
  [tr setObject:[MSBuffer mutableBuffer] forKey:@"MSHttpMSTEMiddleware_buffer"];
  [tr setObject:next forKey:@"MSHttpMSTEMiddleware_next"];
  [tr setDelegate:self];
}
- (void)onTransaction:(MSHttpTransaction*)tr receiveData:(MSBuffer *)data
{
  MSBuffer *b;
  b= [tr objectForKey:@"MSHttpMSTEMiddleware_buffer"];
  [b appendBytes:[data bytes] length:[data length]];
}
- (void)onTransactionEnd:(MSHttpTransaction*)tr
{
  MSBuffer *b; id <MSHttpNextMiddleware> n;
  b= [tr objectForKey:@"MSHttpMSTEMiddleware_buffer"];
  n= [tr objectForKey:@"MSHttpMSTEMiddleware_next"];
  [tr setObject:[b MSTDecodedObject] forKey:@"MSHttpMSTEMiddleware"];
  printf("%.*s\n", (int)[b length], (char *)[b bytes]);
  NSLog(@"%@", [tr msteDecodedObject]);
  [tr removeObjectForKey:@"MSHttpMSTEMiddleware_buffer"];
  [tr removeObjectForKey:@"MSHttpMSTEMiddleware_next"];
  [n nextMiddleware];
}
- (void)onTransaction:(MSHttpTransaction *)tr error:(NSString*)err
{ }
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

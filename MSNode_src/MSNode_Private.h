#ifndef MSNODE_PRIVATE_H
#define MSNODE_PRIVATE_H

#ifdef _WIN32
#include <winsock2.h>
#endif
#import <openssl/ssl.h>
#import <openssl/evp.h>
#import <openssl/crypto.h>
#import <openssl/err.h>
#import <openssl/rand.h>
#import <openssl/ssl.h>
#import <openssl/hmac.h>

#import "uv.h"

#ifdef __cplusplus
#import "node.h"
#import "node_buffer.h"
#import <vector>
#endif

#import "MSNode_Public.h"


#import "_MSDigest.h"
#import "_MSCipherPrivate.h"
#import "_SymmetricCipher.h"
#import "_SymmetricRSACipher.h"
#import "_RSACipher.h"

#ifdef __cplusplus
#import "MSNodeWrapper.h"

@interface MSHttpTransaction (Private)
- (instancetype)initWithServer:(MSHttpServer*)server v8Req:(v8::Local<v8::Value>)req v8res:(v8::Local<v8::Value>)res isolate:(v8::Isolate *)isolate;
@end
#endif //__cplusplus

@interface NSRunLoop (libuv)
+ (uv_loop_t *)currentUvRunLoop;
@end

static inline MSBuffer *MSHttpLoadBuffer(id o, NSString *path)
{
  if ([o isKindOfClass:[NSString class]]) {
    if (path && ![o isAbsolutePath])
      o= [path stringByAppendingPathComponent:o];
    o= [MSBuffer bufferWithContentsOfFile:o];}
  else if(![o isKindOfClass:[NSData class]]) {
    o= nil;}
  return o;
}

void MSRaiseCryptoOpenSSLException();
NSString *MSGetOpenSSLErrStr();
NSString *MSGetOpenSSL_SSLErrStr(void *ssl, int ret);

#endif // MSNODE_PRIVATE_H

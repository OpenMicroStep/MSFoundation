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
- (instancetype)initWithV8Req:(v8::Local<v8::Value>)req v8res:(v8::Local<v8::Value>)res isolate:(v8::Isolate *)isolate;
@end
#endif //__cplusplus

typedef struct MSHandlerStruct {
  struct MSHandlerStruct *next; // =list.first
  struct MSHandlerStruct *prev; // =list.last
  void *fn;
  // args
} MSHandler;

MSNodeExtern void MSHandlerFillArguments(MSHandlerArg *args, int argc, va_list ap);
MSNodeExtern MSHandler* MSCreateHandlerWithArguments(void *fn, int argc, va_list ap);
MSNodeExtern MSHandler* _MSHandlerInsertBefore(MSHandler *n, void *fn, int argc, va_list ap);
MSNodeExtern void MSHandlerListFreeInside(MSHandlerList *list);

#define MSHandlerListCallUntilNO(LIST, RETURNTYPE, DEFAULT, T, ARGS...) ({      \
  MSHandler *__h, *__l; RETURNTYPE __c;                                         \
  __l= (MSHandler *)(LIST);                                                     \
  __h= __l->prev;                                                               \
  __c= DEFAULT;                                                                 \
  while (__c && __h != __l) {                                                   \
    __c= ((T)__h->fn)(ARGS, (MSHandlerArg *)(__h + 1));                         \
    __h= __h->next; }                                                           \
  __c;                                                                          \
})

#define MSHandlerListCall(LIST, T, ARGS...) ({                                  \
  MSHandler *__h, *__l;                                                         \
  __l= (MSHandler *)(LIST);                                                     \
  __h= __l->prev;                                                               \
  while (__h != __l) {                                                          \
    ((T)__h->fn)(ARGS, (MSHandlerArg *)(__h + 1));                              \
    __h= __h->next; }                                                           \
})

#define MSHandlerListAdd(LIST, FN, COUNT, LAST_ARG) ({                          \
  MSHandler *__h;                                                               \
  va_list ap;                                                                   \
  va_start(ap, LAST_ARG);                                                       \
  __h= _MSHandlerInsertBefore((MSHandler *)LIST, (void *)FN, COUNT, ap);        \
  va_end(ap);                                                                   \
  __h;                                                                          \
})

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

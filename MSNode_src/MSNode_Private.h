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

typedef struct MSHttpHandlerStruct {
  void *fn;
  void *arg;
  struct MSHttpHandlerStruct *next;
} MSHttpHandler;

#define MSHttpHandlerSend(LAST, RETURNTYPE, DEFAULT, T, ARGS...) ({ \
  MSHttpHandler *__h= (MSHttpHandler *)LAST; RETURNTYPE __c= DEFAULT; IMP __i; \
  while (__c && __h) { \
    __i= LOOKUP(__h->fn, __h->arg); \
    if (__i) { \
      __c= ((T)__i)(__h->fn, __h->arg, ARGS);} \
    __h= __h->next; } \
  __c; \
})

#define MSHttpHandlerCall(LAST, RETURNTYPE, DEFAULT, T, ARGS...) ({ \
  MSHttpHandler *__h= (MSHttpHandler *)LAST; RETURNTYPE __c= DEFAULT; \
  while (__c && __h) { \
    __c= ((T)__h->fn)(ARGS, __h->arg); \
    __h= __h->next; } \
  __c; \
})

#define MSHttpHandlerAdd(FIRST, LAST, FN, ARG) _MSHttpHandlerAdd(FIRST, LAST, (void*)FN, ARG)
static inline void _MSHttpHandlerAdd(void **first, void **last, void *fn, void *arg)
{
  MSHttpHandler *n;
  n= (MSHttpHandler*)MSMallocFatal(sizeof(MSHttpHandler), "MSHttpHandlerAdd");
  n->fn= fn;
  n->arg= arg;
  n->next= NULL;
  if (*last)
    ((MSHttpHandler*)*last)->next= n;
  *last= n;
  if (!*first)
    *first= n;
}

static inline void MSHttpHandlerDealloc(void *handlerEnd)
{
  MSHttpHandler *c, *n;
  c= (MSHttpHandler *)handlerEnd;
  while (c) {
    n= c->next;
    MSFree(c, "MSHttpHandlerDealloc");
    c= n;}
}
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

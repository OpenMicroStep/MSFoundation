#ifndef MSNODETYPES_H
#define MSNODETYPES_H

#ifdef MSNODE_H
#define MSNodeExtern LIBIMPORT
#else
#define MSNodeExtern LIBEXPORT
#endif

typedef enum  {
  MSHttpMethodUNKNOWN = 0x00,
  MSHttpMethodGET     = 0x01,
  MSHttpMethodPOST    = 0x02,
  MSHttpMethodPUT     = 0x04,
  MSHttpMethodCONNECT = 0x08,
  MSHttpMethodTRACE   = 0x10,
  MSHttpMethodOPTIONS = 0x20,
  MSHttpMethodDELETE  = 0x40,
  MSHttpMethodHEAD    = 0x80,
  MSHttpMethodALL     = 0xFF,
  MSHttpMethodGETorPOST= MSHttpMethodGET | MSHttpMethodPOST
} MSHttpMethod;

typedef enum  {
  MSHttpCodeContinue                    = 100,
  MSHttpCodeSwitchingProtocols          = 101,

  MSHttpCodeOk                          = 200,
  MSHttpCodeCreated                     = 201,
  MSHttpCodeAccepted                    = 202,
  MSHttpCodeNonAuthoritativeInformation = 203,
  MSHttpCodeNoContent                   = 204,
  MSHttpCodeResetContent                = 205,
  MSHttpCodePartialContent              = 206,

  MSHttpCodeMovedPermanently            = 301,
  MSHttpCodeFound                       = 302,
  MSHttpCodeSeeOther                    = 303,
  MSHttpCodeNotModified                 = 304,
  MSHttpCodeUseProxy                    = 305,
  MSHttpCodeTemporaryRedirect           = 307,

  MSHttpCodeBadRequest                  = 400,
  MSHttpCodeUnauthorized                = 401,
  MSHttpCodePaymentRequired             = 402,
  MSHttpCodeForbidden                   = 403,
  MSHttpCodeNotFound                    = 404,
  MSHttpCodeMethodNotAllowed            = 405,
  MSHttpCodeNotAcceptable               = 406,
  MSHttpCodeProxyAuthenticationRequired = 407,
  MSHttpCodeRequestTimeout              = 408,
  MSHttpCodeConflict                    = 409,
  MSHttpCodeGone                        = 410,
  MSHttpCodeLengthRequired              = 411,
  MSHttpCodePreconditionFailed          = 412,
  MSHttpCodeRequestEntityTooLarge       = 413,
  MSHttpCodeRequestURITooLong           = 414,
  MSHttpCodeUnsupportedMediaType        = 415,
  MSHttpCodeRequestedRangeNotSatisfiable= 416,
  MSHttpCodeExpectationFailed           = 417,

  MSHttpCodeInternalServerError         = 500,
  MSHttpCodeNotImplemented              = 501,
  MSHttpCodeBadGateway                  = 502,
  MSHttpCodeServiceUnavailable          = 503,
  MSHttpCodeGatewayTimeout              = 504,
  MSHttpCodeHTTPVersionNotSupported     = 505,
} MSHttpCode;

typedef union {
  int8_t i1;
  int16_t i2;
  int32_t i4;
  int64_t i8;
  uint8_t u1;
  uint16_t u2;
  uint32_t u4;
  uint64_t u8;
  id *idPtr;
  id id;
  void *ptr;
  char * str;
  int8_t *i1Ptr;
  int16_t *i2Ptr;
  int32_t *i4Ptr;
  int64_t *i8Ptr;
  uint8_t *u1Ptr;
  uint16_t *u2Ptr;
  uint32_t *u4Ptr;
  uint64_t *u8Ptr;
  SEL sel;
} MSHandlerArg; // 64bits union

#define MSMakeHandlerArg(arg) ({ MSHandlerArg __a; __a.u8= (MSULong)arg; __a; })

typedef struct MSHandlerStruct {
  struct MSHandlerStruct *next; // =list.first
  struct MSHandlerStruct *prev; // =list.last
  void *fn;
  // args
} MSHandler;

typedef struct MSHandlerListStruct {
  MSHandler *first;
  MSHandler *last;
} MSHandlerList;

typedef struct {
  MSHandler *list;
  MSHandler *current;
} MSHandlerListEnumerator;

static inline void* MSHandlerReserved(MSHandler *h)
{
  return (void *)(h + 1);
}
static inline MSHandlerArg* MSHandlerArgs(MSHandler *h, int reserved)
{
  return (MSHandlerArg *)((char *)MSHandlerReserved(h) + reserved);
}

static inline MSHandlerListEnumerator MSMakeHandlerEnumerator(MSHandlerList *list) {
  MSHandlerListEnumerator ret;
  ret.list= (MSHandler *)list;
  ret.current= NULL;
  return ret;
}
static inline MSHandler* MSHandlerEnumeratorNext(MSHandlerListEnumerator *e) {
  MSHandler *ret;
  ret= e->current ? e->current->next : e->list->next;
  if (ret == e->list)
    ret= NULL;
  e->current= ret;
  return ret;
}
static inline MSHandler* MSHandlerEnumeratorPrev(MSHandlerListEnumerator *e) {
  MSHandler *ret;
  ret= e->current ? e->current->prev : e->list->prev;
  if (ret == e->list)
    ret= NULL;
  e->current= ret;
  return ret;
}

MSNodeExtern void MSHandlerFillArguments(MSHandlerArg *args, int argc, va_list ap);
MSNodeExtern MSHandler* MSCreateHandlerWithArguments(void *fn, int reserved, int argc, va_list ap);
MSNodeExtern MSHandler* _MSHandlerInsertBefore(MSHandler *n, void *fn, int reserved, int argc, va_list ap);
MSNodeExtern void MSHandlerListMove(MSHandler *before, MSHandler *first, MSHandler *last);
MSNodeExtern void MSHandlerListFreeInside(MSHandlerList *list);
// Detach and destroy the given handler
// The previous handler will replace it
MSNodeExtern void MSHandlerDetach(MSHandler *first, MSHandler *last, BOOL freeHandlers);
MSNodeExtern void MSHandlerAttach(MSHandler *before, MSHandler *first, MSHandler *last);

#define MSHandlerListCallUntilNO(LIST, RETURNTYPE, DEFAULT, T, ARGS...) ({      \
  MSHandlerListEnumerator __e; MSHandler *__h; RETURNTYPE __c;                  \
  __e= MSMakeHandlerEnumerator(LIST);                                           \
  __c= DEFAULT;                                                                 \
  while (__c && (__h= MSHandlerEnumeratorNext(&__e))) {                         \
    __c= ((T)__h->fn)(ARGS, MSHandlerArgs(__h, 0)); }                           \
  __c;                                                                          \
})

#define MSHandlerListCall(LIST, T, ARGS...) ({                                  \
  MSHandlerListEnumerator __e; MSHandler *__h;                                  \
  __e= MSMakeHandlerEnumerator(LIST);                                           \
  while ((__h= MSHandlerEnumeratorNext(&__e))) {                                \
    ((T)__h->fn)(ARGS, MSHandlerArgs(__h, 0)); }                                \
})

#define MSHandlerListAdd(LIST, FN, COUNT, LAST_ARG) ({                          \
  MSHandler *__h;                                                               \
  va_list ap;                                                                   \
  va_start(ap, LAST_ARG);                                                       \
  __h= _MSHandlerInsertBefore((MSHandler *)LIST, (void *)FN, 0, COUNT, ap);     \
  va_end(ap);                                                                   \
  __h;                                                                          \
})

#define MSHandlerListAddEx(LIST, FN, RESERVED, COUNT, LAST_ARG) ({              \
  MSHandler *__h;                                                               \
  va_list ap;                                                                   \
  va_start(ap, LAST_ARG);                                                       \
  __h= _MSHandlerInsertBefore((MSHandler *)LIST, (void *)FN, RESERVED, COUNT, ap);\
  va_end(ap);                                                                   \
  __h;                                                                          \
})

MSNodeExtern NSString* MSHttpCodeName(MSHttpCode code);
MSNodeExtern NSString* MSHttpMethodName(MSHttpMethod method);
MSNodeExtern void* MSNodeSetTimeout(void (*cb)(void* context), double delay, void *context);
MSNodeExtern void MSNodeClearTimeout(void *timeout);
MSNodeExtern void* MSNodeSetInterval(void (*cb)(void* context), double delay, void *context);
MSNodeExtern void MSNodeClearInterval(void *interval);
MSNodeExtern int MSNodeStart(void (*cb)(void* context), void* context);
MSNodeExtern int MSNodeStartApplication(Class application, NSString *path, NSDictionary *parameters);
MSNodeExtern int MSNodeStartApplicationWithParametersPath(Class application, NSString *parametersPath);

MSNodeExtern unichar utf8URIStringChaiN(const void *src, NSUInteger *pos);
MSNodeExtern unichar utf8URIStringChaiP(const void *src, NSUInteger *pos);
MSNodeExtern NSString *MSHttpMimeTypeFromExtension(NSString *extension);
MSNodeExtern BOOL MSHttpParseMimeType(NSString * mimetype, mutable MSString *type, mutable MSDictionary *parameters);
MSNodeExtern BOOL MSHttpParseContentDisposition(NSString * contentDisposition, mutable MSString *type, mutable MSDictionary *parameters);

#endif
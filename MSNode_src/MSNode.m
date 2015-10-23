#import "MSNode_Private.h"

static NSString* __methods[] = {
  [MSHttpMethodGET    ]= @"GET"    ,
  [MSHttpMethodPOST   ]= @"POST"   ,
  [MSHttpMethodPUT    ]= @"PUT"    ,
  [MSHttpMethodCONNECT]= @"CONNECT",
  [MSHttpMethodTRACE  ]= @"TRACE"  ,
  [MSHttpMethodOPTIONS]= @"OPTIONS",
  [MSHttpMethodDELETE ]= @"DELETE" ,
  [MSHttpMethodHEAD   ]= @"HEAD"   ,
};

static NSString* __codes[] = {
  [100]= @"Continue"                       ,
  [101]= @"Switching Protocols"            ,
  [200]= @"OK"                             ,
  [201]= @"Created"                        ,
  [202]= @"Accepted"                       ,
  [203]= @"Non-Authoritative Information"  ,
  [204]= @"No Content"                     ,
  [205]= @"Reset Content"                  ,
  [206]= @"Partial Content"                ,
  [301]= @"Moved Permanently"              ,
  [302]= @"Found"                          ,
  [303]= @"See Other"                      ,
  [304]= @"Not Modified"                   ,
  [305]= @"Use Proxy"                      ,
  [307]= @"Temporary Redirect"             ,
  [400]= @"Bad Request"                    ,
  [401]= @"Unauthorized"                   ,
  [402]= @"Payment Required"               ,
  [403]= @"Forbidden"                      ,
  [404]= @"Not Found"                      ,
  [405]= @"Method Not Allowed"             ,
  [406]= @"Not Acceptable"                 ,
  [407]= @"Proxy Authentication Required"  ,
  [408]= @"Request Timeout"                ,
  [409]= @"Conflict"                       ,
  [410]= @"Gone"                           ,
  [411]= @"Length Required"                ,
  [412]= @"Precondition Failed"            ,
  [413]= @"Request Entity Too Large"       ,
  [414]= @"Request-URI Too Long"           ,
  [415]= @"Unsupported Media Type"         ,
  [416]= @"Requested Range Not Satisfiable",
  [417]= @"Expectation Failed"             ,
  [500]= @"Internal Server Error"          ,
  [501]= @"Not Implemented"                ,
  [502]= @"Bad Gateway"                    ,
  [503]= @"Service Unavailable"            ,
  [504]= @"Gateway Timeout"                ,
  [505]= @"HTTP Version Not Supported"     ,
};

// TODO: Move this to MSFoundation
#ifdef MSFOUNDATION_FORCOCOA
static void __currentUvRunLoop_dtor(void *uv_loop) {
  uv_loop_close((uv_loop_t *)uv_loop);
}
MS_DECLARE_THREAD_LOCAL(__currentUvRunLoop, __currentUvRunLoop_dtor);
@implementation NSRunLoop (libuv)
+ (uv_loop_t *)currentUvRunLoop
{
  uv_loop_t *loop= tss_get(__currentUvRunLoop);
  if(!loop) {
    loop= (uv_loop_t *)MSMallocFatal(sizeof(uv_loop_t), "NSRunLoop uv_loop_t");
    uv_loop_init(loop);
    tss_set(__currentUvRunLoop, loop);}
  return loop;
}
@end
#else
@interface NSRunLoop (msfoundation_libuv)
- (uv_loop_t *)_uv_loop;
@end
@implementation NSRunLoop (libuv)
+ (uv_loop_t *)currentUvRunLoop
{
  return [[NSRunLoop currentRunLoop] _uv_loop];
}
@end
#endif

NSString* MSHttpMethodName(MSHttpMethod method)
{
  return method < sizeof(__methods)/sizeof(NSString*) ? __methods[method] : nil;
}

NSString* MSHttpCodeName(MSHttpCode code)
{
  return code < sizeof(__codes)/sizeof(NSString*) ? __codes[code] : nil;
}
int MSNodeStartApplicationWithParametersPath(Class application, NSString *parametersPath)
{
  NSDictionary *parameters= nil;
  if (parametersPath) {
    parameters= [NSDictionary dictionaryWithContentsOfFile:parametersPath];}
  if (parameters) {
    return MSNodeStartApplication(application, [parametersPath stringByDeletingLastPathComponent], parameters);}
  else {
    fprintf(stderr, "Unable to read plist configuration file: %s\n", [parametersPath UTF8String]);
    return 1;}
}
static void MSNodeStartApplicationCallback(void *arg)
{
  NSString *error= nil; id app;
  CDictionary* d= (CDictionary*)arg;
  Class cls= (Class)CDictionaryObjectForKey(d, @"class");
  NSDictionary *parameters= CDictionaryObjectForKey(d, @"parameters");
  NSString *path= CDictionaryObjectForKey(d, @"path");
  app= [ALLOC(cls) initWithParameters:parameters withPath:path error:&error]; //< TODO: fix the leak, with node cleanup handlers
  if (!app) {
    NSLog(@"Error while starting application %@: %@", cls, error ? error : @"unknown error");}
  RELEASE(d);
}
int MSNodeStartApplication(Class application, NSString *path, NSDictionary *parameters)
{
  CDictionary* d= CCreateDictionary(0);
  CDictionarySetObjectForKey(d, application, @"class");
  CDictionarySetObjectForKey(d, parameters, @"parameters");
  CDictionarySetObjectForKey(d, path, @"path");
  return MSNodeStart(MSNodeStartApplicationCallback, d);
}

NSString *MSGetOpenSSLErrStr()
{
  char err_buff[1024];
  ERR_error_string_n(ERR_get_error(),err_buff,1024);
  return [NSString stringWithUTF8String:err_buff];
}

NSString *MSGetOpenSSL_SSLErrStr(void *ssl, int ret)
{
    NSString *errorStr ;
    int errnum = SSL_get_error(ssl, ret) ;

    switch (errnum) {
        case SSL_ERROR_NONE:                errorStr = @"SSL_ERROR_NONE" ; break;
        case SSL_ERROR_ZERO_RETURN:         errorStr = @"SSL_ERROR_ZERO_RETURN" ; break;
        case SSL_ERROR_WANT_READ:           errorStr = @"SSL_ERROR_WANT_READ" ; break;
        case SSL_ERROR_WANT_WRITE:          errorStr = @"SSL_ERROR_WANT_WRITE" ; break;
        case SSL_ERROR_WANT_CONNECT:        errorStr = @"SSL_ERROR_WANT_CONNECT" ; break;
        case SSL_ERROR_WANT_ACCEPT:         errorStr = @"SSL_ERROR_WANT_ACCEPT" ; break;
        case SSL_ERROR_WANT_X509_LOOKUP:    errorStr = @"SSL_ERROR_WANT_X509_LOOKUP" ; break;
        case SSL_ERROR_SYSCALL:             errorStr = [NSString stringWithFormat:@"SSL_ERROR_SYSCALL : %@", MSGetOpenSSLErrStr()] ; break;
        case SSL_ERROR_SSL:                 errorStr = [NSString stringWithFormat:@"SSL_ERROR_SSL : %@", MSGetOpenSSLErrStr()] ; break;

        default: errorStr = @"MSGetOpenSSL_SSLErrStr Error"; break;
    }

    return errorStr ;
}

void MSRaiseCryptoOpenSSLException()
{
  MSRaise(NSGenericException, @"Error using crypto openssl function '%@'", MSGetOpenSSLErrStr()) ;
}

/* Fast mimetype parser
media-type     = type "/" subtype *( ";" parameter )
parameter      = attribute "=" value
attribute      = token
value          = token | quoted-string
quoted-string  = ( <"> *(qdtext | quoted-pair ) <"> )
qdtext         = <any TEXT except <">>
quoted-pair    = "\" CHAR
type           = token
subtype        = token
token          = 1*<any CHAR except CTLs or separators>
separators     = "(" | ")" | "<" | ">" | "@"
               | "," | ";" | ":" | "\" | <">
               | "/" | "[" | "]" | "?" | "="
               | "{" | "}" | SP | HT
CTL            = <any US-ASCII ctl chr (0-31) and DEL (127)>
*/
static BOOL __isTokenChar[96] = { // 32
  0,1,0,1, 1,1,1,1, 0,0,1,1, 0,1,1,0,
  1,1,1,1, 1,1,1,1, 1,1,0,0, 0,0,0,0, // 64
  0,1,1,1, 1,1,1,1, 1,1,1,1, 1,1,1,1,
  1,1,1,1, 1,1,1,1, 1,1,1,0, 0,0,1,1,
  1,1,1,1, 1,1,1,1, 1,1,1,1, 1,1,1,1,
  1,1,1,1, 1,1,1,1, 1,1,1,0, 1,0,1,0, // 128
};
static inline BOOL _isISOSpace(unichar u) {
  return u == ' ' || u == '\t';
}
static inline BOOL _isTokenChar(unichar u) {
  return u > 31 && u < 127 && __isTokenChar[u - 32];
}
static BOOL _parseHeaderValue(NSString *header, mutable MSString *type, mutable MSDictionary *parameters, BOOL isMimeType)
{
  BOOL ok= YES, neol; SES ses, sub; NSUInteger s, se, i, e; unichar u; CString *attr, *value;

  ses= SESFromString(header);
  i= SESStart(ses);
  e= SESEnd(ses);

  // \s*(\w+/\w+)\s*
  while((s= i) < e && _isISOSpace(u = SESIndexN(ses, &i)));
  if (isMimeType && (ok= _isTokenChar(u))) while(i < e && _isTokenChar(u = SESIndexN(ses, &i)));
  if (isMimeType && (ok= ok && u == '/' && (se= i) < e)) u= SESIndexN(ses, &i);
  if ((ok= ok && _isTokenChar(u))) while((neol= (se= i) < e) && _isTokenChar(u = SESIndexN(ses, &i)));
  ok= ok && (!neol || _isISOSpace(u) || u == ';');
  if (ok && type) {
    sub= ses;
    SESSetStart(sub, s);
    SESSetEnd(sub, se);
    CStringAppendSES((CString *)type, sub);}

  while(ok && i < e) {
    // \s*(;\s*(\w+)\s*=\s*(\w+|"(\.|[^"])*"))?
    if (_isISOSpace(u)) while((neol= i < e) && _isISOSpace(u = SESIndexN(ses, &i)));
    if (u == ';') {
      if (ok) while((s= i) < e && _isISOSpace(u = SESIndexN(ses, &i)));
      if ((ok= _isTokenChar(u))) while((se= i) < e && _isTokenChar(u = SESIndexN(ses, &i)));
      if (ok && parameters) {
        sub= ses;
        SESSetStart(sub, s);
        SESSetEnd(sub, se);}
      if (ok && _isISOSpace(u)) while(i < e && _isISOSpace(u = SESIndexN(ses, &i)));
      if ((ok= ok && u == '=')) while((s= i) < e && _isISOSpace(u = SESIndexN(ses, &i)));
      if (ok) {
        value= parameters ? CCreateString(0) : NULL;
        if (u == '"') { // "(\.|[^"])*"
          while(i < e && (u= SESIndexN(ses, &i)) != '"') {
            if (u == '\\' && (ok= i < e))
              CStringAppendCharacter(value, SESIndexN(ses, &i));
            else
              CStringAppendCharacter(value, u);
          }
          if (i < e) u= SESIndexN(ses, &i);
        }
        else if ((ok= _isTokenChar(u))) {
          CStringAppendCharacter(value, u);
          while(i < e && _isTokenChar(u= SESIndexN(ses, &i)))
              CStringAppendCharacter(value, u);
        }
        if (ok && parameters) {
          attr= CCreateStringWithSES(sub);
          CDictionarySetObjectForKey((CDictionary*)parameters, (id)value, (id)attr);
          RELEASE(attr);
        }
        DESTROY(value);
      }
    }
    else if (neol) {
      ok= NO;
    }
  }

  return ok;
}

BOOL MSHttpParseContentDisposition(NSString * contentDisposition, mutable MSString *type, mutable MSDictionary *parameters)
{
  return _parseHeaderValue(contentDisposition, type, parameters, NO);
}
BOOL MSHttpParseMimeType(NSString *mimetype, mutable MSString *type, mutable MSDictionary *parameters)
{
  return _parseHeaderValue(mimetype, type, parameters, YES);
}

NSString *MSHttpMimeTypeFromExtension(NSString *extension)
{
  return nil;
}

void MSHandlerListFreeInside(MSHandlerList *list)
{
  MSHandlerDetach(list->first, list->last, YES);
}

void MSHandlerFillArguments(MSHandlerArg *args, int argc, va_list ap)
{
  while (argc > 0) {
   *args= va_arg (ap, MSHandlerArg);
   ++args;
   --argc; }
}

MSHandler* MSCreateHandlerWithArguments(void *fn, int reserved, int argc, va_list ap)
{
  MSHandler *h; MSHandlerArg *args;
  h= (MSHandler*)MSMallocFatal(sizeof(MSHandler) + reserved + argc * sizeof(MSHandlerArg), "MSCreateHandlerWithArguments");
  h->fn= fn;
  args= MSHandlerArgs(h, reserved);
  MSHandlerFillArguments(args, argc, ap);
  return h;
}


void MSHandlerDetach(MSHandler *first, MSHandler *last, BOOL freeHandlers)
{
  if (!first || !last) return;
  // Detach
  first->prev->next= last->next;
  last->next->prev= first->prev;
  first->prev= NULL;
  last->next= NULL;

  if (freeHandlers) {
    MSHandler *c, *n;
    c= first;
    while(c) {
      n= c->next;
      MSFree(c, "MSHandlerDetach");
      c= n;}}
}

void MSHandlerAttach(MSHandler *before, MSHandler *first, MSHandler *last)
{
  if (!before->prev) {
    // before->prev is before (=list) at initialisation
    before->prev= before;
    before->next= before;}

  first->prev= before->prev;
  first->prev->next= first;
  last->next= before;
  before->prev= last;
}

static inline char _hexaCharValue(char c)
{
  if ('0' <= c && c <= '9') c= c - '0';
  else if ('a' <= c && c <= 'f') c= 10 + c - 'a';
  else if ('A' <= c && c <= 'F') c= 10 + c - 'A';
  else c= 0;
  return c;
}
unichar utf8URIStringChaiN(const void *src, NSUInteger *pos)
{
  const char *s= (const char *)src + *pos;
  if (*s == '%') {
    char buf[4]; NSUInteger i= 0; unichar u;
    do {
      buf[i++]= _hexaCharValue(s[1]) * 16 + _hexaCharValue(s[2]);
      s += 3;
    } while(*s == '%' && i < 4);
    i= 0;
    u= utf8ChaiN(buf, &i);
    *pos += i * 3;
    return u;
  }
  else {
    ++(*pos);
    return (unichar)*s;
  }
}
unichar utf8URIStringChaiP(const void *src, NSUInteger *pos)
{
  const char *s= src;
  NSUInteger p= *pos;
  if (p >= 3 && s[p - 3] == '%') {
    char buf[4]; NSUInteger i= 4, si; unichar u;
    do {
      buf[--i]= _hexaCharValue(s[p - 2]) * 16 + _hexaCharValue(s[p - 1]);
      p -= 3;
    } while(p >= 3 && i > 0 && s[p - 3] == '%');
    si= 4 - i;
    u= utf8ChaiP(buf + i, &si);
    *pos -= (4 - i - si) * 3;
    return u;
  }
  else {
    return (unichar)s[--(*pos)];
  }
}

MSHandler* _MSHandlerInsertBefore(MSHandler *n, void *fn, int reserved, int argc, va_list ap)
{
  MSHandler *h;
  h= MSCreateHandlerWithArguments(fn, reserved, argc, ap);
  MSHandlerAttach(n, h, h);
  return h;
}

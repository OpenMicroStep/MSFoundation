#import "MSNode_Private.h"

static BOOL MSHttpCookieMiddlewareWriteHead(MSHttpTransaction *tr, MSUInt statusCode, void *arg)
{
  MSHttpCookieManager *cookies= [tr objectForKey:@"MSHttpCookieMiddleware"];
  [cookies sendOnTransaction:tr];
  return YES;
}
@implementation MSHttpCookieMiddleware
+ (instancetype)cookieMiddleware
{ return AUTORELEASE([ALLOC(self) init]); }
- (void)onTransaction:(MSHttpTransaction *)tr next:(id <MSHttpNextMiddleware>)next
{
  MSHttpCookieManager *cookies= [MSHttpCookieManager new];
  [tr addWriteHeadHandler:MSHttpCookieMiddlewareWriteHead context:self];
  [tr setObject:cookies forKey:@"MSHttpCookieMiddleware"];
  [cookies updateWithTransaction:tr];
  [cookies release];
  [next nextMiddleware];
}
@end

@implementation MSHttpTransaction (MSHttpCookieMiddleware)
- (MSHttpCookieManager*)cookies
{ return [self objectForKey:@"MSHttpCookieMiddleware"]; }
- (NSString *)cookieValueForName:(NSString *)name
{ return [[self cookies] cookieValueForName:name]; }
- (MSHttpCookie *)cookieForName:(NSString *)name
{ return [[self cookies] cookieForName:name]; }
- (void)setCookie:(MSHttpCookie *)cookie forName:(NSString *)name
{ [[self cookies] setCookie:cookie forName:name]; }
@end

@implementation MSHttpCookie
+ (instancetype)cookieWithValue:(NSString *)value
{ return AUTORELEASE([ALLOC(self) initWithValue:value]); }
- (instancetype)initWithValue:(NSString *)value
{ 
  _value= [value retain];
  return self;
}
- (NSString *)value  { return _value; }
- (NSDate *)expires  { return _expires; }
- (NSString *)path   { return _path; }
- (NSString *)domain { return _domain; }
- (BOOL)secure       { return _secure; }
- (BOOL)httpOnly     { return !_notOnlyHttp; }
- (BOOL)sent         { return _sent; }
- (void)setValue:(NSString *)value   { ASSIGN(_value, value); }
- (void)setExpires:(NSDate *)expires { ASSIGN(_expires, expires); }
- (void)setPath:(NSString *)path     { ASSIGN(_path, path); }
- (void)setDomain:(NSString *)domain { ASSIGN(_domain, domain); }
- (void)setSecure:(BOOL)secure       { _secure= secure; }
- (void)setHttpOnly:(BOOL)httpOnly   { _notOnlyHttp= !httpOnly; }
- (void)setSent:(BOOL)sent           { _sent= sent; }
@end

@implementation MSHttpCookieManager
- (instancetype)init
{
  if ((self= [super init])) {
    _cookies= CCreateDictionary(0);
  }
  return self;
}
- (void)dealloc
{
  RELEASE(_cookies);
  [super dealloc];
}

static void _parseCookie(CDictionary *cookies, NSString *setCookie)
{
  // cookie: key1=value1; key2=value2;
  SES ses, key, value; NSUInteger i; BOOL ok= YES; 
  MSHttpCookie *cookie; CString *sKey, *sValue;
  ok= SESOK(ses= SESFromString(setCookie));
  i= SESStart(ses);
  while (ok) {
    SESSetStart(ses, i);
    ok= SESOK(key= SESExtractToken(ses, CUnicharIsAlnum, NULL));
    if (ok) {
      i=SESEnd(key);
      ok= i < SESEnd(ses) && SESIndexN(ses, &i) == '=';}
    if (ok) {
      SESSetStart(ses, i);
      ok= SESOK(value= SESExtractToken(ses, CUnicharIsAlnum, NULL));}
    if (ok) {
      i=SESEnd(value);
      ok= i == SESEnd(ses) || SESIndexN(ses, &i) == ';';}
    if (ok) {
      sKey= CCreateStringWithSES(key);
      sValue= CCreateStringWithSES(value);
      cookie= [MSHttpCookie new];
      [cookie setValue:(id)sValue];
      printf("%s=%s\n", [(id)sKey UTF8String], [(id)sValue UTF8String]);
      CDictionarySetObjectForKey(cookies, cookie, (id)sKey);
      RELEASE(sKey);
      RELEASE(sValue);
      RELEASE(cookie);
    }
  }
}
- (void)updateWithTransaction:(MSHttpTransaction *)tr
{
  id value; NSEnumerator *e;
  value= [tr valueForHeader:@"cookie"]; 
  if ([value isKindOfClass:[NSArray class]]) {
    for (e= [value objectEnumerator]; (value= [e nextObject]);) {
      _parseCookie(_cookies, value);}
  }
  else {
    _parseCookie(_cookies, value);}
}
- (void)sendOnTransaction:(MSHttpTransaction *)tr
{
  // set-cookie: key=value; Expires=value; Path=path; ...
  // Cookie: key1=value1; key2=value2;
  CString *str; CDictionaryEnumerator e; NSString *key, *value;
  e= CMakeDictionaryEnumerator(_cookies);
  while ((key= CDictionaryEnumeratorNextKey(&e))) {
    str= CCreateString(0);
    value= [CDictionaryEnumeratorCurrentObject(e) value];
    CStringAppendSES(str, SESFromString(key));
    CStringAppendCharacter(str, '=');
    CStringAppendSES(str, SESFromString(value));
    CStringAppendCharacter(str, ';');
    // TODO: support Expires, ...
    [tr setValue:(id)str forHeader:@"Set-Cookie"];
    RELEASE(str);
  }
}
static void _parseSetCookie(CDictionary *cookies, NSString *setCookie)
{
  // set-cookie: key=value; Expires=value; Path=path; ...
  SES ses, key, value; NSUInteger i; BOOL ok= YES; 
  MSHttpCookie *cookie; CString *name= NULL, *sValue;
  ok= SESOK(ses= SESFromString(setCookie));
  i= SESStart(ses);
  cookie= [MSHttpCookie new];
  while (ok) {
    ok= SESOK(key= SESExtractToken(ses, CUnicharIsAlnum, NULL));
    if (ok) {
     i=SESEnd(key);
     ok= SESIndexN(ses, &i) == '=';}
    if (ok) {
      SESSetStart(ses, i);
      ok= SESOK(value= SESExtractToken(ses, CUnicharIsAlnum, NULL));}
    if (ok) {
      i=SESEnd(value);
      ok= SESIndexN(ses, &i) == ';';}
    if (ok) {
      sValue= CCreateStringWithSES(value);
      if(!name) {
        name= CCreateStringWithSES(key);
        [cookie setValue:(id)sValue];}
      else {
        // TODO
      }
      RELEASE(sValue);  
    }
  }
  if(name) {
    CDictionarySetObjectForKey(cookies, cookie, (id)name);
    RELEASE(name);}
  RELEASE(cookie);
}
- (void)updateWithClientResponse:(MSHttpClientResponse *)response
{
  // set-cookie: key=value; Expires=value; Path=path; ...
  // the set-cookie header is special and can be an array sometimes
  id value; NSEnumerator *e;
  value= [response valueForHeader:@"set-cookie"]; 
  if ([value isKindOfClass:[NSArray class]]) {
    for (e= [value objectEnumerator]; (value= [e nextObject]);) {
      _parseSetCookie(_cookies, value);}}
  else {
    _parseSetCookie(_cookies, value);}
}
- (void)sendOnClientRequest:(MSHttpClientRequest *)request
{
  // Cookie: key1=value1; key2=value2;
  CString *str; CDictionaryEnumerator e; NSString *key, *value;
  str= CCreateString(0);
  e= CMakeDictionaryEnumerator(_cookies);
  while ((key= CDictionaryEnumeratorNextKey(&e))) {
    value= [CDictionaryEnumeratorCurrentObject(e) value];
    CStringAppendSES(str, SESFromString(key));
    CStringAppendCharacter(str, '=');
    CStringAppendSES(str, SESFromString(value));
    CStringAppendCharacter(str, ';');
  }
  [request setValue:(id)str forHeader:@"Cookie"];
  RELEASE(str);
}
- (NSString *)cookieValueForName:(NSString *)name
{
  return [[self cookieForName:name] value];
}
- (MSHttpCookie *)cookieForName:(NSString *)name
{
  return CDictionaryObjectForKey(_cookies, name);
}
- (void)setCookie:(MSHttpCookie *)cookie forName:(NSString *)name
{
  CDictionarySetObjectForKey(_cookies, cookie, name);
}
@end

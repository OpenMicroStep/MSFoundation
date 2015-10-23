#import "msnode_validate.h"



static void util_mimetype(test_t *test)
{
  NEW_POOL;
  NSString *str; mutable MSString *type; mutable MSDictionary *parameters;

  type= [MSString mutableString];
  parameters= [MSDictionary mutableDictionary];
  str= @"text/plain";
  TASSERT(test, MSHttpParseMimeType(str, type, parameters), "\"%s\" is a valid mime type", [str UTF8String]);
  TASSERT_EQUALS_OBJ(test, type, @"text/plain");
  TASSERT_EQUALS_LLD(test, [parameters count], 0);

  type= [MSString mutableString];
  parameters= [MSDictionary mutableDictionary];
  str= @"multipart/mixed; boundary=\"qzerty\"";
  TASSERT(test, MSHttpParseMimeType(str, type, parameters), "\"%s\" is a valid mime type", [str UTF8String]);
  TASSERT_EQUALS_OBJ(test, type, @"multipart/mixed");
  TASSERT_EQUALS_LLD(test, [parameters count], 1);
  TASSERT_EQUALS_OBJ(test, [parameters objectForKey:@"boundary"], @"qzerty");

  type= [MSString mutableString];
  parameters= [MSDictionary mutableDictionary];
  str= @"  multipart/form-data   ;   azerty  =   ytreza  ;  boundary  = \"()-[]\" ";
  TASSERT(test, MSHttpParseMimeType(str, type, parameters), "\"%s\" is a valid mime type", [str UTF8String]);
  TASSERT_EQUALS_OBJ(test, type, @"multipart/form-data");
  TASSERT_EQUALS_LLD(test, [parameters count], 2);
  TASSERT_EQUALS_OBJ(test, [parameters objectForKey:@"azerty"], @"ytreza");
  TASSERT_EQUALS_OBJ(test, [parameters objectForKey:@"boundary"], @"()-[]");
  type= [MSString mutableString];
  parameters= [MSDictionary mutableDictionary];
  TASSERT(test, MSHttpParseMimeType(str, NULL, NULL), "\"%s\" is a valid mime type", [str UTF8String]);
  TASSERT(test, MSHttpParseMimeType(str, type, NULL), "\"%s\" is a valid mime type", [str UTF8String]);
  TASSERT_EQUALS_OBJ(test, type, @"multipart/form-data");
  TASSERT(test, MSHttpParseMimeType(str, NULL, parameters), "\"%s\" is a valid mime type", [str UTF8String]);
  TASSERT_EQUALS_LLD(test, [parameters count], 2);
  TASSERT_EQUALS_OBJ(test, [parameters objectForKey:@"azerty"], @"ytreza");
  TASSERT_EQUALS_OBJ(test, [parameters objectForKey:@"boundary"], @"()-[]");

  str= @"text";
  TASSERT(test, !MSHttpParseMimeType(str, NULL, NULL), "\"%s\" isn't a valid mime type", [str UTF8String]);
  str= @"text/";
  TASSERT(test, !MSHttpParseMimeType(str, NULL, NULL), "\"%s\" isn't a valid mime type", [str UTF8String]);
  str= @"text/plain ; azer(ty = 123 ";
  TASSERT(test, !MSHttpParseMimeType(str, NULL, NULL), "\"%s\" isn't a valid mime type", [str UTF8String]);
  str= @"text/plain ; azerty =  ";
  TASSERT(test, !MSHttpParseMimeType(str, NULL, NULL), "\"%s\" isn't a valid mime type", [str UTF8String]);

  KILL_POOL;
}

static void util_contentdisposition(test_t *test)
{
  NEW_POOL;
  NSString *str; mutable MSString *type; mutable MSDictionary *parameters;

  type= [MSString mutableString];
  parameters= [MSDictionary mutableDictionary];
  str= @"form-data";
  TASSERT(test, MSHttpParseContentDisposition(str, type, parameters), "\"%s\" is a valid content disposition", [str UTF8String]);
  TASSERT_EQUALS_OBJ(test, type, @"form-data");
  TASSERT_EQUALS_LLD(test, [parameters count], 0);

  type= [MSString mutableString];
  parameters= [MSDictionary mutableDictionary];
  str= @"form-data; name=\"textfield-1172-inputEl\"";
  TASSERT(test, MSHttpParseContentDisposition(str, type, parameters), "\"%s\" is a valid content disposition", [str UTF8String]);
  TASSERT_EQUALS_OBJ(test, type, @"form-data");
  TASSERT_EQUALS_LLD(test, [parameters count], 1);
  TASSERT_EQUALS_OBJ(test, [parameters objectForKey:@"name"], @"textfield-1172-inputEl");

  type= [MSString mutableString];
  parameters= [MSDictionary mutableDictionary];
  str= @"form-data; name=\"wibfilefield-1171-inputEl\"; filename=\"cashbox-s64.png\"";
  TASSERT(test, MSHttpParseContentDisposition(str, type, parameters), "\"%s\" is a valid content disposition", [str UTF8String]);
  TASSERT_EQUALS_OBJ(test, type, @"form-data");
  TASSERT_EQUALS_LLD(test, [parameters count], 2);
  TASSERT_EQUALS_OBJ(test, [parameters objectForKey:@"name"], @"wibfilefield-1171-inputEl");
  TASSERT_EQUALS_OBJ(test, [parameters objectForKey:@"filename"], @"cashbox-s64.png");

  KILL_POOL;
}

test_t msnode_utils[]= {
  {"mimetype", NULL, util_mimetype},
  {"contentdisposition", NULL, util_contentdisposition},
  {NULL}};

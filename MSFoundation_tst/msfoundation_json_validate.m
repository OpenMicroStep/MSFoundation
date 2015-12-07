// msfoundation_string_validate.m, ecb, 130911

#include "msfoundation_validate.h"

#define TASSERT_DECODE(W, SRC, OBJ) _decode(W, SRC, OBJ, #OBJ)

static void _decode(test_t *test, const char *src, id sobj, const char *objCode)
{
  MSBuffer *ssrc= [MSBuffer bufferWithCString:src], *enc;
  id o0, o1; NSString *error= nil;

  o0= [ssrc JSONDecodedObject:&error];
  TASSERT_ISEQUAL(test, error, nil, "JSON decode error: %s\njson=%s", [error UTF8String], src);
  if (!error) {
    TASSERT_ISEQUAL(test, o0, sobj,
      "JSON decoded object differ\njson=    %s\ncode=    %s\ndecoded= %s\nexpected=%s",
      src, objCode, [[o0 description] UTF8String], [[sobj description] UTF8String]);

    error= nil;
    enc= [o0 JSONEncodedBuffer];
    o1= [enc JSONDecodedObject:&error];
    TASSERT_ISEQUAL(test, error, nil, "JSON decode error of newly encoded object: %s\n\nsrc json='%s'\nout json='%s'", [error UTF8String], src, [enc cString]);
    if (!error) {
      TASSERT_ISEQUAL(test, o1, sobj,
        "JSON decoded object of reencoded object differ\nsrc json='%s'\nout json='%s'\ncode=    %s\ndecoded0=%s\ndecoded1=%s\nexpected=%s",
        src, [enc cString], objCode, [[o0 description] UTF8String], [[o1 description] UTF8String], [[sobj description] UTF8String]);}
  }
}

static void json_decode(test_t *test)
{
  TASSERT_DECODE(test, "null", [NSNull null]);
  TASSERT_DECODE(test, "true", [NSNumber numberWithBool:YES]);
  TASSERT_DECODE(test, "false", [NSNumber numberWithBool:NO]);
  TASSERT_DECODE(test, "\"\"", @"");
  TASSERT_DECODE(test, "[]", [NSArray array]);
  TASSERT_DECODE(test, "{}", [NSDictionary dictionary]);
  TASSERT_DECODE(test, "12.34", [MSDecimal decimalWithString:@"12.34"]);
  TASSERT_DECODE(test, "\"My beautiful string \\u00E9\\u00E8\"", @"My beautiful string éè");
  TASSERT_DECODE(test, "\"Json \\\\a\\/b\\\"c\\u00C6\"", @"Json \\a/b\"cÆ");
  TASSERT_DECODE(test, "{\"key1\": \"First object\", \"key2\": \"Second object\"}", ([NSDictionary dictionaryWithObjectsAndKeys:@"First object", @"key1", @"Second object", @"key2", nil]));
  TASSERT_DECODE(test, "[\"First object\",\"Second object\"]", ([NSArray arrayWithObjects:@"First object", @"Second object", nil]));
  TASSERT_DECODE(test, "\n{ \"web-app\": {\n  \"abcdefgh\": [ \t { \"-name\": \"+value\", \n  \"servlet-class\": 50, \"dec\" \t:\t0.1 } ]\t}\n}\n"
                     , (@{ @"web-app": @{ @"abcdefgh" : @[ @{ @"-name" : @"+value", @"servlet-class": [MSDecimal decimalWithString:@"50"], @"dec": [MSDecimal decimalWithString:@"0.1"]}]}} ));

}

testdef_t msfoundation_json[]= {
  {"decode",NULL,json_decode},
  {NULL}
};

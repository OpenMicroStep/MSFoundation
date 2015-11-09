// msfoundation_string_validate.m, ecb, 130911

#include "msfoundation_validate.h"

#define TASSERT_DECODE(W, SRC, OBJ) _decode(W, SRC, OBJ, #OBJ)

static void _decode(test_t *test, const char *src, id sobj, const char *objCode)
{
  MSBuffer *ssrc= [MSBuffer bufferWithCString:src], *enc;
  id o0, o1; NSString *error= nil;
  NEW_POOL;

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

  KILL_POOL;
}

static void json_decode(test_t *test)
{
  NEW_POOL;

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
  //TASSERT_DECODE(test, "{\"miflist\":[{\"mif\":{\"completed\":true,\"offenseDate\":\"21/09/2015 16:30\",\"type\":\"STA\",\"natinf\":{\"code\":7505,\"addInfo\":\"Infraction aux règles sur l'arrêt et le stationnement des véhicules\"},\"location\":{\"number\":\"8\",\"label\":\"Rue Roger Brechan\",\"city\":\"Lyon\",\"department\":\"Rhône\",\"postalCode\":\"69003\",\"inseeCode\":\"69383\",\"country\":\"FRA\",\"pkpr\":null},\"vehicle\":{\"type\":\"VP\",\"registration\":\"CQ967QY\",\"country\":\"FRA\",\"model\":\"Peugeot\"},\"comments\":\"Généré par l'utilisateur Logitud AGL (c) AFS2R: référence RIFP: id [124 843] Matricule 6543 / CS: 02032012017\"},\"idrifp\":124843,\"matricule\":\"6543\"},{\"mif\":{\"completed\":true,\"offenseDate\":\"21/09/2015 16:31\",\"type\":\"STA\",\"natinf\":{\"code\":7505,\"addInfo\":\"Infraction aux règles sur l'arrêt et le stationnement des véhicules\"},\"location\":{\"number\":\"20\",\"label\":\"Rue Roger Brechan\",\"city\":\"Lyon\",\"department\":\"Rh"
  //   "ne\",\"postalCode\":\"69003\",\"inseeCode\":\"69383\",\"country\":\"FRA\",\"pkpr\":null},\"vehicle\":{\"type\":\"VP\",\"registration\":\"CR050LK\",\"country\":\"FRA\",\"model\":\"Renault\"},\"comments\":\"Généré par l'utilisateur Logitud AGL (c) AFS2R: référence RIFP: id [124 855] Matricule 6543 / CS: 02032012017\"},\"idrifp\":124855,\"matricule\":\"6543\"},{\"mif\":{\"completed\":true,\"offenseDate\":\"21/09/2015 16:31\",\"type\":\"STA\",\"natinf\":{\"code\":7505,\"addInfo\":\"Infraction aux règles sur l'arrêt et le stationnement des véhicules\"},\"location\":{\"number\":\"16\",\"label\":\"Rue Professeur Paul Sisley\",\"city\":\"Lyon\",\"department\":\"Rhône\",\"postalCode\":\"69003\",\"inseeCode\":\"69383\",\"country\":\"FRA\",\"pkpr\":null},\"vehicle\":{\"type\":\"VP\",\"registration\":\"BL132ZM\",\"country\":\"FRA\",\"model\":\"Ford\"},\"comments\":\"Généré par l'utilisateur Logitud AGL (c) AFS2R: référence RIFP: id [124 856] Matricule 6543 / CS: 02032012017\"},\"idrifp\":124856,\"matricule\":\"6543\"},{\"mif\":{\"completed\":true,\"offenseDate\":\"21/09/2015 16:31\",\"type\":\"STA\",\"natinf\":{\"code\":7505,\"addInfo\":\"Infr"
  //   "action aux règles sur l'arrêt et le stationnement des véhicules\"},\"location\":{\"number\":\"20\",\"label\":\"Rue Roger Brechan\",\"city\":\"Lyon\",\"department\":\"69\",\"postalCode\":\"69003\",\"inseeCode\":\"69383\",\"country\":\"FRA\",\"pkpr\":null},\"vehicle\":{\"type\":\"VP\",\"registration\":\"CE272JW\",\"country\":\"FRA\",\"model\":\"Renault\"},\"comments\":\"Généré par l'utilisateur Logitud AGL (c) AFS2R: référence RIFP: id [124 861] Matricule 6543 / CS: 02032012017\"},\"idrifp\":124861,\"matricule\":\"6543\"},{\"mif\":{\"completed\":true,\"offenseDate\":\"21/09/2015 16:30\",\"type\":\"STA\",\"natinf\":{\"code\":7505,\"addInfo\":\"Infraction aux règles sur l'arrêt et le stationnement des véhicules\"},\"location\":{\"number\":\"21\",\"label\":\"Rue du Dauphiné\",\"city\":\"Lyon\",\"department\":\"Rhône\",\"postalCode\":\"69003\",\"inseeCode\":\"69383\",\"country\":\"FRA\",\"pkpr\":null},\"vehicle\":{\"type\":\"VP\",\"registration\":\"BY595ST\",\"country\":\"FRA\",\"model\":\"Citroen\"},\"comments\":\"Généré par l'utilisateur Logitud AGL (c) AFS2R: référence RIFP: id [124 830] Matricule 6543 / CS: 02032012017\"},\""
  //   "idrifp\":124830,\"matricule\":\"6543\"},{\"mif\":{\"completed\":true,\"offenseDate\":\"21/09/2015 16:27\",\"type\":\"STA\",\"natinf\":{\"code\":7505,\"addInfo\":\"Infraction aux règles sur l'arrêt et le stationnement des véhicules\"},\"location\":{\"number\":\"59\",\"label\":\"Rue Saint-Philippe\",\"city\":\"Lyon\",\"department\":\"Rhône\",\"postalCode\":\"69003\",\"inseeCode\":\"69383\",\"country\":\"FRA\",\"pkpr\":null},\"vehicle\":{\"type\":\"VP\",\"registration\":\"CA109NB\",\"country\":\"FRA\",\"model\":\"Renault\"},\"comments\":\"Généré par l'utilisateur Logitud AGL (c) AFS2R: référence RIFP: id [124 822] Matricule 6543 / CS: 02032012017\"},\"idrifp\":124822,\"matricule\":\"6543\"}]}", nil);
  KILL_POOL;
}

test_t msfoundation_json[]= {
  {"decode",NULL,json_decode,INTITIALIZE_TEST_T_END},
  {NULL}
};

// mscore_cbuffer_validate.c, ecb, 130911

#include "mscore_validate.h"

static void cbuffer_create(test_t *test)
  {
  CBuffer *b;
  b= CCreateBuffer(0);
  TASSERT_EQUALS(test, RETAINCOUNT(b), 1, "A1-Bad retain count: %lu",WLU(RETAINCOUNT(b)));
  CBufferAppendBytes  (b,"123456789 123456789 123456789 123456789 123456789 123456789 ",60);
  CBufferAppendCString(b,"-********** Test of the Microstep MSCore Library **********-");
  TASSERT_EQUALS(test, CBufferLength(b), 120, "A2-Bad length: %lu",WLU(CBufferLength(b)));
  TASSERT_EQUALS(test, CBufferByteAtIndex(b,72), 'T', "A3-Bad byte: %c",CBufferByteAtIndex(b,72));
  TASSERT_EQUALS(test, CBufferIndexOfByte(b,'M'), 84, "A4-Bad index: %lu",WLU(CBufferIndexOfByte(b,'M')));
  TASSERT_EQUALS(test, CBufferIndexOfBytes(b,"MS-",2), 94, "A5-Bad index: %lu",WLU(CBufferIndexOfBytes(b,"MS-",2)));
  TASSERT_EQUALS(test, CBufferIndexOfCStringInRange(b,"Lib",NSMakeRange(60, 1000)), 101,
    "A6-Bad index: %lu",WLU(CBufferIndexOfCStringInRange(b,"Lib",NSMakeRange(60, 1000))));
  TASSERT_EQUALS(test, CBufferIndexOfCString(b,"**********"), 61,
    "A7-Bad index: %lu",WLU(CBufferIndexOfCString(b,"**********")));
  TASSERT_EQUALS(test, CBufferIndexOfCStringInRange(b,"**********",NSMakeRange(61, 1000)), 61,
    "A8-Bad index: %lu",WLU(CBufferIndexOfCStringInRange(b,"**********",NSMakeRange(61, 1000))));
  TASSERT_EQUALS(test, CBufferIndexOfCStringInRange(b,"**********",NSMakeRange(62, 1000)), 109,
    "A9-Bad index: %lu",WLU(CBufferIndexOfCStringInRange(b,"**********",NSMakeRange(62, 1000))));
  RELEASE(b);
  }

static void cbuffer_b64_(test_t *test, int no, char *str, NSUInteger lstr, char *enc)
  {
  CBuffer *b,*c; NSUInteger lc,lenc;
  lenc= strlen(enc);
  b= CCreateBuffer(0);
  CBufferBase64EncodeAndAppendBytes(b, str, lstr);
  TASSERT_EQUALS(test, CBufferLength(b), lenc, "%d Bad encode: %s %s",no,enc,CBufferCString(b));
  TASSERT(test, memcmp(b->buf, enc, lenc)==0, "%d Bad encode: %s %s",no,enc,CBufferCString(b));
  c= CCreateBuffer(0);
  TASSERT(test, CBufferBase64DecodeAndAppendBytes(c, enc, lenc), "%d Bad decode: %s %s",no,enc,CBufferCString(c));
  lc= CBufferLength(c);
  TASSERT_EQUALS(test, lc, lstr, "%d %llu %llu", no);
  TASSERT(test, memcmp(c->buf, str, lstr)==0, "%d Bad decode: %s %s",no,str,CBufferCString(c));
  RELEASE(b);
  RELEASE(c);
  }
static void cbuffer_b64(test_t *test)
  {
  int i; char str[257], *enc1,*enc2;
  enc1= "ICEiIyQlJicoKSorLC0uLzAxMjM0NTY3ODk6Ozw9Pj9AQUJDREVGR0hJSktMTU5PUFFSU"
  "1RVVldYWVpbXF1eX2BhYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ent8fSAhIiMkJSYnKCkqKywt"
  "Li8wMTIzNDU2Nzg5Ojs8PT4/QEFCQ0RFRkdISUpLTE1OT1BRUlNUVVZXWFlaW1xdXl9gYWJjZGV"
  "mZ2hpamtsbW5vcHFyc3R1dnd4eXp7fH0gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0"
  "BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiYw==";
  enc2= "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIj"
  "JCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZH"
  "SElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWpr"
  "bG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6P"
  "kJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKz"
  "tLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX"
  "2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7"
  "/P3+/w==";
  cbuffer_b64_(test, 0, ""    , 0, "");
  cbuffer_b64_(test, 1, "A"   , 1, "QQ==");
  cbuffer_b64_(test, 2, "AB"  , 2, "QUI=");
  cbuffer_b64_(test, 3, "ABC" , 3, "QUJD");
  cbuffer_b64_(test, 4, "ABCD", 4, "QUJDRA==");
  for (i=0; i<256; i++) str[i]= ' '+i%('~'-' ');
  str[256]= 0x00;
  cbuffer_b64_(test, 5, str, 256, enc1);
  for (i=0; i<256; i++) str[i]= (char)i;
  cbuffer_b64_(test, 6, str, 256, enc2);
  }

static void cbuffer_compress_(test_t *test, int no, char *str, NSUInteger lstr, NSUInteger cstr)
  {
  CBuffer *b,*c;
  b= CCreateBuffer(0);
  TASSERT(test, CBufferCompressAndAppendBytes(b, str, lstr), "B%d-%d-Bad compress: %s",no,1,str);
  TASSERT_EQUALS(test, b->length, cstr, "B%d-%d-Bad compress: %s %s",no,2,str,CBufferCString(b));
//fprintf(stdout, "B%d-%d-Compress: %lu %lu\n",no,1,lstr,b->length);
  c= CCreateBuffer(0);
  TASSERT(test, CBufferDecompressAndAppendBytes(c, b->buf, b->length), "B%d-%d-Bad decompress: %s",no,3,CBufferCString(c));
  TASSERT_EQUALS(test, c->length, lstr, "B%d-%d-Bad decompress: %s %s",no,4,str,CBufferCString(c));
  memcmp(c->buf, str, lstr);
  RELEASE(b);
  RELEASE(c);
  }
static void cbuffer_compress(test_t *test)
  {
  int i; char str[257];
  cbuffer_compress_(test, 0, ""    , 0, 0);
  cbuffer_compress_(test, 1, "A"   , 1, 12);
  cbuffer_compress_(test, 2, "AB"  , 2, 13);
  cbuffer_compress_(test, 3, "ABC" , 3, 14);
  cbuffer_compress_(test, 4, "ABCD", 4, 15);
  for (i=0; i<256; i++) str[i]= ' '+i%('~'-' ');
  str[256]= 0x00;
  cbuffer_compress_(test, 5, str, 256, 110);
  for (i=0; i<256; i++) str[i]= (char)i;
  cbuffer_compress_(test, 6, str, 256, 267);
  }

test_t mscore_cbuffer[]= {
  {"create"  ,NULL,cbuffer_create  ,INTITIALIZE_TEST_T_END},
  {"b64"     ,NULL,cbuffer_b64     ,INTITIALIZE_TEST_T_END},
  {"compress",NULL,cbuffer_compress,INTITIALIZE_TEST_T_END},
  {NULL}
};

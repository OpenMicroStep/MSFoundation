// msfoundation_buffer_validate.m, ecb, 130911

#include "msfoundation_validate.h"

static void buffer_create(test_t *test)
  {
  MSBuffer *b;
  b= MSCreateBuffer(0);
  TASSERT_EQUALS(test, RETAINCOUNT(b), 1, "A1-Bad retain count: %lu",WLU(RETAINCOUNT(b)));
  CBufferAppendBytes  ((CBuffer*)b,"123456789 123456789 123456789 123456789 123456789 123456789 ",60);
  CBufferAppendCString((CBuffer*)b,"-********** Test of the Microstep MSCore Library **********-");
  TASSERT_EQUALS(test, [b length], 120, "A2-Bad length: %lu",WLU([b length]));
  TASSERT_EQUALS(test, CBufferByteAtIndex((CBuffer*)b,72), 'T', "A3-Bad byte: %c",CBufferByteAtIndex((CBuffer*)b,72));
  TASSERT_EQUALS(test, CBufferIndexOfByte((CBuffer*)b,'M'), 84, "A4-Bad index: %lu",WLU(CBufferIndexOfByte((CBuffer*)b,'M')));
  TASSERT_EQUALS(test, CBufferIndexOfBytes((CBuffer*)b,"MS-",2), 94, "A5-Bad index: %lu",WLU(CBufferIndexOfBytes((CBuffer*)b,"MS-",2)));
  TASSERT_EQUALS(test, CBufferIndexOfCStringInRange((CBuffer*)b,"Lib",NSMakeRange(60, 1000)), 101, "A6-Bad index: %lu",WLU(CBufferIndexOfCStringInRange((CBuffer*)b,"Lib",NSMakeRange(60, 1000))));
  TASSERT_EQUALS(test, CBufferIndexOfCString((CBuffer*)b,"**********"), 61, "A7-Bad index: %lu",WLU(CBufferIndexOfCString((CBuffer*)b,"**********")));
  TASSERT_EQUALS(test, CBufferIndexOfCStringInRange((CBuffer*)b,"**********",NSMakeRange(61, 1000)), 61, "A8-Bad index: %lu",WLU(CBufferIndexOfCStringInRange((CBuffer*)b,"**********",NSMakeRange(61, 1000))));
  TASSERT_EQUALS(test, CBufferIndexOfCStringInRange((CBuffer*)b,"**********",NSMakeRange(62, 1000)), 109, "A9-Bad index: %lu",WLU(CBufferIndexOfCStringInRange((CBuffer*)b,"**********",NSMakeRange(62, 1000))));
  TASSERT(test, ISA(b), "A10-Bad isa");
  TASSERT(test, NAMEOFCLASS(b), "A11-Bad nameof");
  RELEASE(b);
  }

static void cbuffer_b64_(test_t *test, int no, char *str, NSUInteger lstr, char *enc)
  {
  MSBuffer *a,*b,*c; NSUInteger lb,lc,lenc;
  lenc= strlen(enc);
  a= MSCreateBufferWithBytesNoCopyNoFree(str, lstr);
  b= [a encodedToBase64];
  lb= [b length];
  TASSERT(test, lb==lenc && memcmp(((CBuffer*)b)->buf, enc, lenc)==0, "B%d-%d-Bad encode: %s %s",no,2,enc,CBufferCString((CBuffer*)b));
  c= [b decodedFromBase64];
  TASSERT(test, c, "B%d-%d-Bad decode: %s %s",no,3,enc,CBufferCString((CBuffer*)c));
  lc= [c length];
  TASSERT(test, lc==lstr && !(c && memcmp(((CBuffer*)c)->buf, str, lstr)), "B%d-%d-Bad decode: %s %s",no,4,str,CBufferCString((CBuffer*)c));
  RELEASE(a);
  }
static void buffer_b64(test_t *test)
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

static void buffer_compress_(test_t *test, int no, char *str, NSUInteger lstr, NSUInteger cstr)
  {
  MSBuffer *a,*b,*c;
  a= MSCreateBufferWithBytesNoCopyNoFree(str, lstr);
  b= [a compressed];
  TASSERT(test, b, "%d Bad compress: %s",no,str);
  TASSERT_EQUALS(test, [b length], cstr, "%d Bad compress: %s %s",no,str,CBufferCString((CBuffer*)b));
  c= [b decompressed];
  TASSERT(test, c, "%d Bad decompress: %s",no,CBufferCString((CBuffer*)c));
  TASSERT(test, [c length]==lstr && memcmp(((CBuffer*)c)->buf, str, lstr)==0, "%d Bad decompress: %s %s",no,str,CBufferCString((CBuffer*)c));
  RELEASE(a);
  }
static void buffer_compress(test_t *test)
  {
  int i; char str[257];
  buffer_compress_(test, 0, ""    , 0, 0);
  buffer_compress_(test, 1, "A"   , 1, 12);
  buffer_compress_(test, 2, "AB"  , 2, 13);
  buffer_compress_(test, 3, "ABC" , 3, 14);
  buffer_compress_(test, 4, "ABCD", 4, 15);
  for (i=0; i<256; i++) str[i]= ' '+i%('~'-' ');
  str[256]= 0x00;
  buffer_compress_(test, 5, str, 256, 110);
  for (i=0; i<256; i++) str[i]= (char)i;
  buffer_compress_(test, 6, str, 256, 267);
  }

static void buffer_replace(test_t *test)
  {
  MSBuffer *b,*c;
  b= [[MSBuffer alloc] mutableInitWithBytes:"ACBDE" length:5];
  [b appendBytes:"F" length:1];
  c= [[MSBuffer alloc] initWithBytesNoCopyNoFree:"ACBDEF" length:6];
  TASSERT_ISEQUAL(test, b, c, "not equals");
  TASSERT(test, strcmp((char*)[b cString], (char*)[c cString])==0, "cStrings not equals");
  RELEASE(c);
  [b replaceBytesInRange:NSMakeRange(3, 2) withBytes:"G" length:1];
  c= [[MSBuffer alloc] initWithBytesNoCopyNoFree:"ACBGF" length:5];
  TASSERT_ISEQUAL(test, b, c, "not equals %s %s",[b cString],[c cString]);
  RELEASE(c);
  [b replaceBytesInRange:NSMakeRange(2, 2) withBytes:"HIJ" length:3];
  c= [[MSBuffer alloc] initWithBytesNoCopyNoFree:"ACHIJF" length:6];
  TASSERT_ISEQUAL(test, b, c, "not equals %s %s",[b cString],[c cString]);
  RELEASE(c);
  RELEASE(b);
  }

testdef_t msfoundation_buffer[]= {
  {"create"  ,NULL,buffer_create  },
  {"b64"     ,NULL,buffer_b64     },
  {"compress",NULL,buffer_compress},
  {"replace" ,NULL,buffer_replace },
  {NULL}
};

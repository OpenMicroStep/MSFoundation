// mscore_cbuffer_validate.c, ecb, 130911

#include "mscore_validate.h"

static inline int cbuffer_create(void)
  {
  int err= 0;
  CBuffer *b;
  b= CCreateBuffer(0);
  if (RETAINCOUNT(b)!=1) {
    fprintf(stdout, "A1-Bad retain count: %lu\n",WLU(RETAINCOUNT(b)));
    err++;}
  CBufferAppendBytes  (b,"123456789 123456789 123456789 123456789 123456789 123456789 ",60);
  CBufferAppendCString(b,"-********** Test of the Microstep MSCore Library **********-");
  if (CBufferLength(b)!=120) {
    fprintf(stdout, "A2-Bad length: %lu\n",WLU(CBufferLength(b)));
    err++;}
  if (CBufferByteAtIndex(b,72)!='T') {
    fprintf(stdout, "A3-Bad byte: %c\n",CBufferByteAtIndex(b,72));
    err++;}
  if (CBufferIndexOfByte(b,'M')!=84) {
    fprintf(stdout, "A4-Bad index: %lu\n",WLU(CBufferIndexOfByte(b,'M')));
    err++;}
  if (CBufferIndexOfBytes(b,"MS-",2)!=94) {
    fprintf(stdout, "A5-Bad index: %lu\n",WLU(CBufferIndexOfBytes(b,"MS-",2)));
    err++;}
  if (CBufferIndexOfCStringInRange(b,"Lib",NSMakeRange(60, 1000))!=101) {
    fprintf(stdout, "A6-Bad index: %lu\n",WLU(CBufferIndexOfCStringInRange(b,"Lib",NSMakeRange(60, 1000))));
    err++;}
  if (CBufferIndexOfCString(b,"**********")!=61) {
    fprintf(stdout, "A7-Bad index: %lu\n",WLU(CBufferIndexOfCString(b,"**********")));
    err++;}
  if (CBufferIndexOfCStringInRange(b,"**********",NSMakeRange(61, 1000))!=61) {
    fprintf(stdout, "A8-Bad index: %lu\n",WLU(CBufferIndexOfCStringInRange(b,"**********",NSMakeRange(61, 1000))));
    err++;}
  if (CBufferIndexOfCStringInRange(b,"**********",NSMakeRange(62, 1000))!=109) {
    fprintf(stdout, "A9-Bad index: %lu\n",WLU(CBufferIndexOfCStringInRange(b,"**********",NSMakeRange(62, 1000))));
    err++;}
  RELEASE(b);
  return err;
  }

static inline int cbuffer_b64_(int no, char *str, NSUInteger lstr, char *enc)
  {
  int err= 0;
  CBuffer *b,*c; NSUInteger lb,lc,lenc;
  lenc= strlen(enc);
  b= CCreateBuffer(0);
  CBufferBase64EncodeAndAppendBytes(b, str, lstr);
  if ((lb= CBufferLength(b))!=lenc || memcmp(b->buf, enc, lenc)) {
    fprintf(stdout, "B%d-%d-Bad encode: %s %s\n",no,2,enc,CBufferCString(b));
    err++;}
  c= CCreateBuffer(0);
  if (!CBufferBase64DecodeAndAppendBytes(c, enc, lenc)) {
    fprintf(stdout, "B%d-%d-Bad decode: %s %s\n",no,3,enc,CBufferCString(c));
    err++;}
  if ((lc= CBufferLength(c))!=lstr || memcmp(c->buf, str, lstr)) {
    fprintf(stdout, "B%d-%d-Bad decode: %s %s\n",no,4,str,CBufferCString(c));
    err++;}
  RELEASE(b);
  RELEASE(c);
  return err;
  }
static inline int cbuffer_b64(void)
  {
  int err= 0;
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
  err+= cbuffer_b64_(0, ""    , 0, "");
  err+= cbuffer_b64_(1, "A"   , 1, "QQ==");
  err+= cbuffer_b64_(2, "AB"  , 2, "QUI=");
  err+= cbuffer_b64_(3, "ABC" , 3, "QUJD");
  err+= cbuffer_b64_(4, "ABCD", 4, "QUJDRA==");
  for (i=0; i<256; i++) str[i]= ' '+i%('~'-' ');
  str[256]= 0x00;
  err+= cbuffer_b64_(5, str, 256, enc1);
  for (i=0; i<256; i++) str[i]= (char)i;
  err+= cbuffer_b64_(6, str, 256, enc2);
  return err;
  }

static inline int cbuffer_compress_(int no, char *str, NSUInteger lstr, NSUInteger cstr)
  {
  int err= 0;
  CBuffer *b,*c;
  b= CCreateBuffer(0);
  if (!CBufferCompressAndAppendBytes(b, str, lstr)) {
    fprintf(stdout, "B%d-%d-Bad compress: %s\n",no,1,str);
    err++;}
  if (b->length!=cstr) {
    fprintf(stdout, "B%d-%d-Bad compress: %s %s\n",no,2,str,CBufferCString(b));
    err++;}
//fprintf(stdout, "B%d-%d-Compress: %lu %lu\n",no,1,lstr,b->length);
  c= CCreateBuffer(0);
  if (!CBufferDecompressAndAppendBytes(c, b->buf, b->length)) {
    fprintf(stdout, "B%d-%d-Bad decompress: %s\n",no,3,CBufferCString(c));
    err++;}
  if (c->length!=lstr || memcmp(c->buf, str, lstr)) {
    fprintf(stdout, "B%d-%d-Bad decompress: %s %s\n",no,4,str,CBufferCString(c));
    err++;}
  RELEASE(b);
  RELEASE(c);
  return err;
  }
static inline int cbuffer_compress(void)
  {
  int err= 0;
  int i; char str[257];
  err+= cbuffer_compress_(0, ""    , 0, 0);
  err+= cbuffer_compress_(1, "A"   , 1, 12);
  err+= cbuffer_compress_(2, "AB"  , 2, 13);
  err+= cbuffer_compress_(3, "ABC" , 3, 14);
  err+= cbuffer_compress_(4, "ABCD", 4, 15);
  for (i=0; i<256; i++) str[i]= ' '+i%('~'-' ');
  str[256]= 0x00;
  err+= cbuffer_compress_(5, str, 256, 110);
  for (i=0; i<256; i++) str[i]= (char)i;
  err+= cbuffer_compress_(6, str, 256, 267);
  return err;
  }

int mscore_cbuffer_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  err+= cbuffer_create();
  err+= cbuffer_b64();
  err+= cbuffer_compress();

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","CBuffer",(err?"FAIL":"PASS"),seconds);
  return err;
  }

// mscore_mste_validate.c, ecb, 140222

#include "MSCore_Private.h"
#include "mscore_validate.h"

static inline int _test(void)
  {
  int err= 0;
  CBuffer *src,*buf;
  CDictionary *error;
  CString *ke,*kd;
  id o,v,d;
  
  ke= MSSCreate("error");
  kd= MSSCreate("description");
  // Decode sans source
  o= MSTECreateRootObjectFromBuffer(nil, nil, &error);
  if (!o) {
    if (!error) {
      printf("A1: no error\n"); err++;}
    v= CDictionaryObjectForKey(error, (id)ke);
    if (!v) {
      printf("A2: no error value\n"); err++;}
    else if (!CDecimalEquals((CDecimal*)v, MM_One)) {
      printf("A3: %ld\n",(long)CDecimalIntegerValue((CDecimal*)v)); err++;}}
  RELEAZEN(o); RELEAZEN(error);
  // Decode erreur MSTE0102      "MSTE0101" ,9, "CRC00000000", 1,\"C\",Z,KKK,T]"
  src= CCreateBufferWithBytes("[\"MSTE0102\",X,\"CRC00000000\",Y,\"C\",Z,KKK,T]", 42);
  o= MSTECreateRootObjectFromBuffer(src, nil, &error);
  v= CDictionaryObjectForKey(error, (id)ke);
  if (!CDecimalEquals((CDecimal*)v, MM_One)) {
    printf("A4: %ld\n",(long)CDecimalIntegerValue((CDecimal*)v)); err++;}
  RELEAZEN(o); RELEAZEN(error);
  MSBIndex(src, 9)= '1';
  // Decode X au lieu d'un nombre
  o= MSTECreateRootObjectFromBuffer(src, nil, &error);
  v= CDictionaryObjectForKey(error, (id)ke);
  d= CDictionaryObjectForKey(error, (id)kd);
  if (!CDecimalEquals((CDecimal*)v, MM_One)) {
    buf= CCreateBufferWithString((CString*)d, NSUTF8StringEncoding);
    printf("A5: %ld %s\n",(long)CDecimalIntegerValue((CDecimal*)v), CBufferCString(buf)); err++;
    RELEAZEN(buf);}
  RELEAZEN(o); RELEAZEN(error);
  MSBIndex(src, 12)= '9';
  // Decode Y->0, "C" pas un nombre: bad number of keys
  o= MSTECreateRootObjectFromBuffer(src, nil, &error);
  v= CDictionaryObjectForKey(error, (id)ke);
  d= CDictionaryObjectForKey(error, (id)kd);
  if (!CDecimalEquals((CDecimal*)v, MM_One)) {
    buf= CCreateBufferWithString((CString*)d, NSUTF8StringEncoding);
    printf("A6: %ld %s\n",(long)CDecimalIntegerValue((CDecimal*)v), CBufferCString(buf)); err++;
    RELEAZEN(buf);}
  RELEAZEN(o); RELEAZEN(error);
  MSBIndex(src, 28)= '1';
  // Decode Z->1, KKK pas une chaine
  MSBIndex(src, 34)= '1'; // Z
  o= MSTECreateRootObjectFromBuffer(src, nil, &error);
  v= CDictionaryObjectForKey(error, (id)ke);
  d= CDictionaryObjectForKey(error, (id)kd);
  if (!CDecimalEquals((CDecimal*)v, MM_One)) {
    buf= CCreateBufferWithString((CString*)d, NSUTF8StringEncoding);
    printf("A7: %ld %s\n",(long)CDecimalIntegerValue((CDecimal*)v), CBufferCString(buf)); err++;
    RELEAZEN(buf);}
  RELEAZEN(o); RELEAZEN(error);
  // Decode Z->1, "K" une chaine, T->0 : ok
  MSBIndex(src, 36)= '"';
  MSBIndex(src, 38)= '"';
  o= MSTECreateRootObjectFromBuffer(src, nil, &error);
  v= CDictionaryObjectForKey(error, (id)ke);
  d= CDictionaryObjectForKey(error, (id)kd);
  if (error) {
    buf= CCreateBufferWithString((CString*)d, NSUTF8StringEncoding);
    printf("A9: %ld %s\n",(long)CDecimalIntegerValue((CDecimal*)v), CBufferCString(buf)); err++;
    RELEAZEN(buf);}
  RELEAZEN(o); RELEAZEN(error);
  // End
  RELEAZEN(ke); RELEAZEN(kd);
//printf("SZ %lu %lu\n",sizeof(float),sizeof(double));
  return err;
  }

static inline int _decode(char *ssrc, id ret)
  {
  int err= 0;
  CDictionary *error; CBuffer *src,*buf; id ke,kd,v,d;
  id o;
printf("B0: %s\n",ssrc);
  src= CCreateBufferWithBytes(ssrc, strlen(ssrc));
  o= MSTECreateRootObjectFromBuffer(src, nil, &error);
  if (error) {
    ke= (id)MSSCreate("error");
    kd= (id)MSSCreate("description");
    v= CDictionaryObjectForKey(error, (id)ke);
    d= CDictionaryObjectForKey(error, (id)kd);
    buf= CCreateBufferWithString((CString*)d, NSUTF8StringEncoding);
    printf("B1: %ld %s\n",(long)CDecimalIntegerValue((CDecimal*)v), CBufferCString(buf)); err++;
    RELEAZEN(ke); RELEAZEN(o); RELEAZEN(buf);}
  else if (!ISEQUAL(ret, o)) {
    printf("B2: Bad result for %s\n",ssrc); err++;}
  RELEAZEN(src); RELEAZEN(error); RELEAZEN(o);
  return err;
  }

int mscore_mste_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;
  id o1; char b[1024]; MSUInt col; CBuffer *buf= NULL;

  err+= _test();
  err+= _decode("[\"MSTE0101\",6,\"CRC00000000\",0,0]",nil);
  err+= _decode("[\"MSTE0101\",7,\"CRC00000000\",0,0,0]",MSTENull);
  err+= _decode("[\"MSTE0101\",8,\"CRC00000000\",1,\"FirstClass\",0,1]",MSTETrue);
  err+= _decode("[\"MSTE0101\",9,\"CRC00000000\",1,\"FirstClass\",1,\"OneKey\",2]",MSTEFalse);
  o1= (id)CCreateDecimalFromUTF8String("12.34");
  err+= _decode("[\"MSTE0101\",9,\"CRC00000000\",1,\"FirstClass\",1,\"OneKey\",3,12.34]",o1);
  err+= _decode("[\"MSTE0101\",9,\"CRC00000000\",1,\"FirstClass\",1,\"OneKey\",3,\"12.34\"]",o1);
  RELEAZEN(o1);
  o1= (id)MSSCreate("My beautiful string éè");
  err+= _decode("[\"MSTE0101\",9,\"CRC00000000\",1,\"FirstClass\",1,\"OneKey\",4,\"My beautiful string éè\"]",o1);
  RELEAZEN(o1);
  o1= (id)MSSCreate("Json \\a/b\"cÆ"); // Json \a/b"cÆ
  buf= CCreateBufferWithString((CString*)o1, NSUTF8StringEncoding);
//printf("B %s\n",CBufferCString(buf));
  RELEAZEN(buf);
  err+= _decode("[\"MSTE0101\",9,\"CRC00000000\",1,\"FirstClass\",1,\"OneKey\",4,\"Json \\\\a\\/b\\\"c\\u00C6\"]",o1);
  RELEAZEN(o1);
  o1= (id)CCreateDateFromYMD(2001, 1, 1);
  err+= _decode("[\"MSTE0101\",9,\"CRC00000000\",1,\"FirstClass\",1,\"OneKey\",5,978307200]",o1);
  RELEAZEN(o1);
  o1= (id)CCreateColor(1, 2, 3, 4); col= (1 << 16) | (2 << 8) | (3 << 0) | ((255U-4U) << 24);
  sprintf(b, "[\"MSTE0101\",7,\"CRC00000000\",0,0,6,%u]",col);
  err+= _decode(b,o1);
  RELEAZEN(o1);

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","MSTE",(err?"FAIL":"PASS"),seconds);
  return err;
  }

// mscore_mste_validate.c, ecb, 140222

#include "mscore_validate.h"
#include "MSTE.h" // A supprimer quand intégré dans le Core

static CString *_ke,*_kd;
static int _testError(CBuffer *src_, char *errLoc_,int errNo_)
  {
  int err= 0;
  CDictionary *error;
  id o,v,d;
  SES ses1,ses2,ses3;
  CBuffer *buf;

  o= MSTECreateRootObjectFromBuffer(src_, nil, &error);
  v= CDictionaryObjectForKey(error, (id)_ke);
  d= CDictionaryObjectForKey(error, (id)_kd);
  if (errLoc_) {
    ses1= MSMakeSESWithBytes(errLoc_, strlen(errLoc_), NSUTF8StringEncoding);
    ses2= CStringSES((CString*)d);
    ses3= SESCommonPrefix(ses1, ses2);}
  if ((!errLoc_ && error) ||
      (errLoc_ && (!CDecimalEquals((CDecimal*)v, MM_One) || ses1.length!=ses3.length))) {
    buf= CCreateBufferWithString((CString*)d, NSUTF8StringEncoding);
    printf("A%d: %ld %s\n",errNo_,(long)CDecimalLongValue((CDecimal*)v), CBufferCString(buf)); err++;
    RELEAZEN(buf);}
  RELEAZEN(o); RELEAZEN(error);
  return err;
  }
// convertion hex <-> decimal
//http://www.statman.info/conversions/hexadecimal.html
static int _test(void)
  {
  int err= 0;
  CBuffer *src;
  
  _ke= MCSCreate("error");
  _kd= MCSCreate("description");
  // Decode sans source
  err+= _testError(nil, "MSTE-1-", 1);
  // Decode erreur MSTE0102    [ "MSTE0101" ,8, "CRCbda1803f", 1,\"C\",Z,KKK,T]"
  src= CCreateBufferWithBytes("[\"MSTE0102\",X,\"CRCbda1803f\",Y,\"C\",Z,KKK,T]", 42);
  err+= _testError(src, "MSTE-11-", 2);
  MSBIndex(src, 9)= '1';
  // Decode X au lieu d'un nombre: -> 0: trop petit
  err+= _testError(src, "MSTE-16-", 3);
  MSBIndex(src, 12)= '1';
  // Decode nbToken = 1: trop petit
  err+= _testError(src, "MSTE-16-", 4);
  MSBIndex(src, 12)= '8';
  // Decode Y->0, "C" pas un nombre: bad number of keys
  err+= _testError(src, "MSTE-25-", 5);
  MSBIndex(src, 28)= '1'; // Y
  MSBIndex(src, 34)= '1'; // Z
//memmove(src->buf+18, "bda18000", 8);
  // Decode Z->1, KKK pas une chaine
  err+= _testError(src, "MSTE-30-", 6);
  MSBIndex(src, 36)= '"';
  MSBIndex(src, 38)= '"';
  // Decode Z->1, "K" une chaine, T->0 : ok
  err+= _testError(src, NULL, 7);
  // End
  RELEAZEN(src);
  RELEAZEN(_ke); RELEAZEN(_kd);
//printf("SZ %lu %lu\n",sizeof(float),sizeof(double));
  return err;
  }

static int _decode(char *ssrc, id ret)
  {
  int err= 0;
  CDictionary *error; CBuffer *src,*buf; id ke,kd,v,d;
  id o,s;
//printf("B0: %s\n",ssrc);
  src= CCreateBufferWithBytes(ssrc, strlen(ssrc));
  o= MSTECreateRootObjectFromBuffer(src, nil, &error);
  if (error) {
    ke= (id)MCSCreate("error");
    kd= (id)MCSCreate("description");
    v= CDictionaryObjectForKey(error, (id)ke);
    d= CDictionaryObjectForKey(error, (id)kd);
    buf= CCreateBufferWithString((CString*)d, NSUTF8StringEncoding);
    printf("B1: %ld %s\n",(long)CDecimalLongValue((CDecimal*)v), CBufferCString(buf)); err++;
    RELEAZEN(ke); RELEAZEN(o); RELEAZEN(buf);}
  else if (!ISEQUAL(ret, o)) {
    s= (id)MCSCreate(NULL);
    if (ISEQUAL(ISA(o), ISA(s))) {
      buf= CCreateBufferWithString((CString*)o, NSUTF8StringEncoding);
      printf("B2: %s\n",CBufferCString(buf));
      RELEAZEN(buf);}
    RELEAZEN(s);
    printf("B3: Bad result for %s\n",ssrc); err++;}
  RELEAZEN(src);
  RELEAZEN(error);
  RELEAZEN(o);
  return err;
  }

int mscore_mste_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;
  id o1; char b[1024]; MSUInt col; CBuffer *buf= NULL;

  err+= _test();
  err+= _decode("[\"MSTE0101\",5,\"CRCac1d7833\",0,0]",nil);
  err+= _decode("[\"MSTE0101\",6,\"CRC2709142b\",0,0,0]",MSTENull);
  err+= _decode("[\"MSTE0101\",7,\"CRCb8b8b932\",1,\"FirstClass\",0,1]",MSTETrue);
  err+= _decode("[\"MSTE0101\",8,\"CRC2fe08843\",1,\"FirstClass\",1,\"OneKey\",2]",MSTEFalse);

  o1= (id)CCreateDecimalWithUTF8String("12.34");
  err+= _decode("[\"MSTE0101\",9,\"CRCe52c2946\",1,\"FirstClass\",1,\"OneKey\",3,12.34]",o1);
  err+= _decode("[\"MSTE0101\",9,\"CRC63ee54c2\",1,\"FirstClass\",1,\"OneKey\",3,\"12.34\"]",o1);
  RELEAZEN(o1);

  o1= (id)MCSCreate("My beautiful string éè");
  err+= _decode("[\"MSTE0101\",9,\"CRC3108fd09\",1,\"FirstClass\",1,\"OneKey\",4,\"My beautiful string éè\"]",o1);
  RELEAZEN(o1);

  o1= (id)MCSCreate("Json \\a/b\"cÆ"); // Json \a/b"cÆ
  buf= CCreateBufferWithString((CString*)o1, NSUTF8StringEncoding);
//printf("B %s\n",CBufferCString(buf));
  RELEAZEN(buf);
//["MSTE0101",9,"CRCc8e768a6",1,"FirstClass",1,"OneKey",4,"Json \\a\/b\"c\u00C6"]
  err+= _decode("[\"MSTE0101\",9,\"CRCc8e768a6\",1,\"FirstClass\",1,\"OneKey\",4,\"Json \\\\a\\/b\\\"c\\u00C6\"]",o1);
  RELEAZEN(o1);

  o1= (id)MCSCreate("Æ?"); // Badly-formed last character
//["MSTE0101",7,"CRC609231cb",0,0,4,"\u00C6\u"]
  err+= _decode("[\"MSTE0101\",7,\"CRC609231cb\",0,0,4,\"\\u00C6\\u\"]",o1);
  RELEAZEN(o1);

  o1= (id)CCreateDateWithYMD(2001, 1, 1);
  err+= _decode("[\"MSTE0101\",9,\"CRCfa465229\",1,\"FirstClass\",1,\"OneKey\",5,978307200]",o1);
  RELEAZEN(o1);

  o1= (id)CCreateColor(1, 2, 3, 4); col= (1 << 16) | (2 << 8) | (3 << 0) | ((255U-4U) << 24);
  sprintf(b, "[\"MSTE0101\",7,\"CRC609231cb\",0,0,6,%u]",col);
  err+= _decode(b,o1);
  RELEAZEN(o1);

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","MSTE (Core)",(err?"FAIL":"PASS"),seconds);
  return err;
  }

// mscore_cdecimal_validate.c, ecb, 130911

#include "mscore_validate.h"

static inline void cdecimal_print(CDecimal *d)
  {
  char str[256];
  m_apm_to_string(str, 6, d);
  fprintf(stdout, "%s\n",str);
  }

static int cdecimal_create(void)
  {
  int err= 0;
  CDecimal *c,*d,*e,*f;
  c= (CDecimal*)MSCreateObjectWithClassIndex(CDecimalClassIndex);
  m_apm_init(c);
  d= CCreateDecimalWithLongLong(0LL);
  if (RETAINCOUNT(c)!=1) {
    fprintf(stdout, "A1 Bad retain count: %lu\n",WLU(RETAINCOUNT(c))); err++;}
  if (RETAINCOUNT(d)!=1) {
    fprintf(stdout, "A2 Bad retain count: %lu\n",WLU(RETAINCOUNT(d))); err++;}
  if (!CDecimalEquals(c, d)) {
    fprintf(stdout, "A3 c & d are not equals\n"); err++;}
  RELEASE(c);
  RELEASE(d);
  c= CCreateDecimalWithUTF8String("3.14");
  d= CCreateDecimalWithDouble(3.14);
//cdecimal_print(c);
//cdecimal_print(d);
  if (RETAINCOUNT(c)!=1) {
    fprintf(stdout, "A5 Bad retain count: %lu\n",WLU(RETAINCOUNT(c))); err++;}
  if (RETAINCOUNT(d)!=1) {
    fprintf(stdout, "A6 Bad retain count: %lu\n",WLU(RETAINCOUNT(d))); err++;}
  if (!CDecimalEquals(c, d)) {
    fprintf(stdout, "A7 c & d are not equals\n"); err++;}
  e= CCreateDecimalWithLongLong(3LL);
  if (CDecimalEquals(d, e)) {
    fprintf(stdout, "A8 d & e are equals\n"); err++;}
  f= CCreateDecimalFloor(d);
  if (!CDecimalEquals(e, f)) {
    fprintf(stdout, "A9 e & f are not equals\n"); err++;}
  RELEASE(c);
  RELEASE(d);
  RELEASE(e);
  RELEASE(f);
  return err;
  }

static int cdecimal_op(void)
  {
  int err= 0, i;
  CDecimal *c[10],*d;
  c[0]= CCreateDecimalWithUTF8String("3.");
  c[1]= CCreateDecimalWithUTF8String("3.1");
  c[2]= CCreateDecimalWithUTF8String("3.14");
  c[3]= CCreateDecimalWithUTF8String("3.141");
  c[4]= CCreateDecimalWithUTF8String("3.1415");
  c[5]= CCreateDecimalWithUTF8String("3.14159");
  c[6]= CCreateDecimalWithUTF8String("3.141592");
  c[7]= CCreateDecimalWithUTF8String("3.1415926");
  c[8]= CCreateDecimalWithUTF8String("3.14159265");
  c[9]= CCreateDecimalWithUTF8String("3.141592653");
  for (i=1; i<10; i++) {
    d= CCreateDecimalDivide(MM_PI, MM_One, i-1); // TODO: look why -1
    if (!CDecimalEquals(c[i], d)) {
      cdecimal_print(c[i]); cdecimal_print(d);
      fprintf(stdout, "B1-%d c & d are not equals\n",i); err++;}
    RELEASE(d);}
  for (i=0; i<10; i++) RELEASE(c[i]);
  return err;
  }

static int cdecimal_value(void)
  {
  int err= 0, i;
  CDecimal *c[10];
  MSLong l[10]= {0,0,0,0,1,1,-1,-1,12,100};
  c[0]= CCreateDecimalWithUTF8String("0");
  c[1]= CCreateDecimalWithUTF8String("-0");
  c[2]= CCreateDecimalWithUTF8String("0.44");
  c[3]= CCreateDecimalWithUTF8String("-0.49");
  c[4]= CCreateDecimalWithUTF8String("0.5");
  c[5]= CCreateDecimalWithUTF8String("1.499999");
  c[6]= CCreateDecimalWithUTF8String("-0.5");
  c[7]= CCreateDecimalWithUTF8String("-1.499999");
  c[8]= CCreateDecimalWithUTF8String("12");
  c[9]= CCreateDecimalWithUTF8String("99.99");
  for (i=1; i<10; i++) {
    if (CDecimalLongValue(c[i])!=l[i]) {
      cdecimal_print(c[i]);
      fprintf(stdout, "B2-%d bad %lld\n",i,(MSLong)l[i]); err++;}}
  for (i=0; i<10; i++) RELEASE(c[i]);
  return err;
  }

static int cdecimal_fromSES(void)
  {
  int err= 0, i;
  CDecimal *c; SES sesIn,sesOut;
  char *txt [10]= {"0","-1.2","3.","   45.e13x","1.8.1",   ".34",".8","+.1e+2.1","+.1E+5"," .3e4 "};
  char *terr[10]= {".","e","1.E","   +. ","+.e",".e","+E","+a","+E+5"," .e4 "};
  NSUInteger start[10]= {0, 0,0,              3,0,   0,0, 0,    0,   1};
  NSUInteger lg   [10]= {1, 2,1,              2,1,   0,0, 1,    1,   0};
  NSUInteger lgd  [10]= {1, 4,2,              6,3,   3,2, 6,    6,   4};
  MSLong     val  [10]= {0,-1,3,             45,1,   0,0, 0,    0,   0};
  MSLong     vald [10]= {0,-1,3,450000000000000,2,   0,1,10,10000,3000};

  NSUInteger estart[10]= {0,0,0,3,0,0,0,0,0,1};
  NSUInteger elg   [10]= {0,0,1,1,1,0,1,1,1,0};
  NSUInteger elgd  [10]= {1,0,3,2,2,1,1,1,1,1};
  for (i=0; i<10; i++) {
    sesIn= MSMakeSESWithBytes(txt[i], strlen(txt[i]), NSUTF8StringEncoding);
    c= CCreateDecimalWithSES(sesIn, YES, NULL, &sesOut);
    if (SESStart(sesOut)!=start[i] || SESLength(sesOut)!=lg[i]) {
      fprintf(stdout, "D1-%d-%lu %lu\n",i,SESStart(sesOut),SESLength(sesOut)); err++;}
    if (i<5) {
      if (!c || CDecimalLongValue(c)!=val[i]) {
        fprintf(stdout, "D2-%d-%lld\n",i,!c?0:CDecimalLongValue(c)); err++;}}
    else {
      if (c) {
        fprintf(stdout, "D2-%d-%lld\n",i,CDecimalLongValue(c)); err++;}}
    RELEASE(c);
    c= CCreateDecimalWithSES(sesIn, NO, NULL, &sesOut);
    if (SESStart(sesOut)!=start[i] || SESLength(sesOut)!=lgd[i]) {
      fprintf(stdout, "D3-%d-%lu %lu\n",i,SESStart(sesOut),SESLength(sesOut)); err++;}
    if (!c || CDecimalLongValue(c)!=vald[i]) {
      fprintf(stdout, "D4-%d-%lld %f\n",i,!c?0:CDecimalLongValue(c),strtod(txt[i], NULL)); err++;}
    RELEASE(c);}
  for (i=0; i<10; i++) {
    sesIn= MSMakeSESWithBytes(terr[i], strlen(terr[i]), NSUTF8StringEncoding);
    c= CCreateDecimalWithSES(sesIn, YES, NULL, &sesOut);
    if (SESStart(sesOut)!=estart[i] || SESLength(sesOut)!=elg[i]) {
      fprintf(stdout, "D11-%d-%lu %lu\n",i,SESStart(sesOut),SESLength(sesOut)); err++;}
    if (i!=2 && c) {
      fprintf(stdout, "D12-%d-%lld\n",i,CDecimalLongValue(c)); err++;}
    RELEASE(c);
    c= CCreateDecimalWithSES(sesIn, NO, NULL, &sesOut);
    if (SESStart(sesOut)!=estart[i] || SESLength(sesOut)!=elgd[i]) {
      fprintf(stdout, "D13-%d-%lu %lu %s\n",i,SESStart(sesOut),SESLength(sesOut),terr[i]); err++;}
    if (c) {
      fprintf(stdout, "D14-%d-%lld %s\n",i,CDecimalLongValue(c),terr[i]); err++;}
    RELEASE(c);}
  return err;
  }

static int cdecimal_cast(void)
  {
#define __UIntMaxU ((MSULong)MSUIntMax)

  int err= 0, i;
  MSLong val  [12]=  {MSLongMin    ,MSIntMin    ,MSShortMin  ,MSCharMin  , 0,MSCharMax  ,MSByteMax  ,MSShortMax  ,MSUShortMax  ,MSIntMax    ,MSUIntMax    ,MSLongMax    };
  MSLong rcm1 [12]=  {MSCharMin    ,MSCharMin   ,MSCharMin   ,MSCharMin  ,-1,MSCharMax-1,MSCharMax  ,MSCharMax   ,MSCharMax    ,MSCharMax   ,MSCharMax    ,MSCharMax    };
  MSLong rc   [12]=  {MSCharMin    ,MSCharMin   ,MSCharMin   ,MSCharMin  , 0,MSCharMax  ,MSCharMax  ,MSCharMax   ,MSCharMax    ,MSCharMax   ,MSCharMax    ,MSCharMax    };
  MSLong rcp1[ 12]=  {MSCharMin    ,MSCharMin   ,MSCharMin   ,MSCharMin+1, 1,MSCharMax  ,MSCharMax  ,MSCharMax   ,MSCharMax    ,MSCharMax   ,MSCharMax    ,MSCharMax    };
  MSLong rucm1[12]=  {        0    ,        0   ,        0   ,        0  , 0,MSCharMax-1,MSByteMax-1,MSByteMax   ,MSByteMax    ,MSByteMax   ,MSByteMax    ,MSByteMax    };
  MSLong ruc  [12]=  {        0    ,        0   ,        0   ,        0  , 0,MSCharMax  ,MSByteMax  ,MSByteMax   ,MSByteMax    ,MSByteMax   ,MSByteMax    ,MSByteMax    };
  MSLong rucp1[12]=  {        0    ,        0   ,        0   ,        0  , 1,MSCharMax+1,MSByteMax  ,MSByteMax   ,MSByteMax    ,MSByteMax   ,MSByteMax    ,MSByteMax    };
  MSLong rsm1 [12]=  {MSShortMin   ,MSShortMin  ,MSShortMin  ,MSCharMin-1,-1,MSCharMax-1,MSByteMax-1,MSShortMax-1,MSShortMax   ,MSShortMax  ,MSShortMax   ,MSShortMax   };
  MSLong rs   [12]=  {MSShortMin   ,MSShortMin  ,MSShortMin  ,MSCharMin  , 0,MSCharMax  ,MSByteMax  ,MSShortMax  ,MSShortMax   ,MSShortMax  ,MSShortMax   ,MSShortMax   };
  MSLong rsp1[ 12]=  {MSShortMin   ,MSShortMin  ,MSShortMin+1,MSCharMin+1, 1,MSCharMax+1,MSByteMax+1,MSShortMax  ,MSShortMax   ,MSShortMax  ,MSShortMax   ,MSShortMax   };
  MSLong rusm1[12]=  {         0   ,         0  ,         0  ,        0  , 0,MSCharMax-1,MSByteMax-1,MSShortMax-1,MSUShortMax-1,MSUShortMax ,MSUShortMax  ,MSUShortMax  };
  MSLong rus  [12]=  {         0   ,         0  ,         0  ,        0  , 0,MSCharMax  ,MSByteMax  ,MSShortMax  ,MSUShortMax  ,MSUShortMax ,MSUShortMax  ,MSUShortMax  };
  MSLong rusp1[12]=  {         0   ,         0  ,         0  ,        0  , 1,MSCharMax+1,MSByteMax+1,MSShortMax+1,MSUShortMax  ,MSUShortMax ,MSUShortMax  ,MSUShortMax  };
  MSLong rim1 [12]=  {MSIntMin     ,MSIntMin    ,MSShortMin-1,MSCharMin-1,-1,MSCharMax-1,MSByteMax-1,MSShortMax-1,MSUShortMax-1,MSIntMax-1LL,MSIntMax     ,MSIntMax     };
  MSLong ri   [12]=  {MSIntMin     ,MSIntMin    ,MSShortMin  ,MSCharMin  , 0,MSCharMax  ,MSByteMax  ,MSShortMax  ,MSUShortMax  ,MSIntMax    ,MSIntMax     ,MSIntMax     };
  MSLong rip1[ 12]=  {MSIntMin     ,MSIntMin+1  ,MSShortMin+1,MSCharMin+1, 1,MSCharMax+1,MSByteMax+1,MSShortMax+1,MSUShortMax+1,MSIntMax    ,MSIntMax     ,MSIntMax     };
  MSLong ruim1[12]=  {       0     ,       0    ,         0  ,        0  , 0,MSCharMax-1,MSByteMax-1,MSShortMax-1,MSUShortMax-1,MSIntMax-1UL,MSUIntMax-1UL,MSUIntMax    };
  MSLong rui  [12]=  {       0     ,       0    ,         0  ,        0  , 0,MSCharMax  ,MSByteMax  ,MSShortMax  ,MSUShortMax  ,MSIntMax    ,MSUIntMax    ,MSUIntMax    };
  MSLong ruip1[12]=  {       0     ,       0    ,         0  ,        0  , 1,MSCharMax+1,MSByteMax+1,MSShortMax+1,MSUShortMax+1,MSIntMax+1UL,MSUIntMax    ,MSUIntMax    };
  MSLong rlm1 [12]=  {MSLongMin    ,MSIntMin-1LL,MSShortMin-1,MSCharMin-1,-1,MSCharMax-1,MSByteMax-1,MSShortMax-1,MSUShortMax-1,MSIntMax-1LL,MSUIntMax-1LL,MSLongMax-1LL};
  MSLong rl   [12]=  {MSLongMin    ,MSIntMin    ,MSShortMin  ,MSCharMin  , 0,MSCharMax  ,MSByteMax  ,MSShortMax  ,MSUShortMax  ,MSIntMax    ,MSUIntMax    ,MSLongMax    };
  MSLong rlp1[ 12]=  {MSLongMin+1LL,MSIntMin+1LL,MSShortMin+1,MSCharMin+1, 1,MSCharMax+1,MSByteMax+1,MSShortMax+1,MSUShortMax+1,MSIntMax+1LL,MSUIntMax+1LL,MSLongMax    };
  MSULong rulm1[12]= {       0     ,       0    ,         0  ,        0  , 0,MSCharMax-1,MSByteMax-1,MSShortMax-1,MSUShortMax-1,MSIntMax-1ULL,__UIntMaxU-1ULL,MSLongMax-1ULL};
  MSULong rul  [12]= {       0     ,       0    ,         0  ,        0  , 0,MSCharMax  ,MSByteMax  ,MSShortMax  ,MSUShortMax  ,MSIntMax    ,__UIntMaxU    ,MSLongMax    };
  MSULong rulp1[12]= {       0     ,       0    ,         0  ,        0  , 1,MSCharMax+1,MSByteMax+1,MSShortMax+1,MSUShortMax+1,MSIntMax+1ULL,__UIntMaxU+1ULL,MSLongMax+1ULL};
  CDecimal *c,*minus1,*cm1,*cp1;
  const CString *s; CBuffer *b;
  minus1= CCreateDecimalWithLongLong(-1);
  for (i=0; i<12; i++) {
    c= CCreateDecimalWithLongLong(val[i]);
    cm1= CCreateDecimalAdd(c, minus1);
    cp1= CCreateDecimalAdd(c, MM_One);
    if ((MSLong)CDecimalCharValue(  cm1)!=rcm1 [i]) {err++; printf("E11-%d %hhd %lld\n",i,CDecimalCharValue(   cm1),rcm1 [i]);}
    if ((MSLong)CDecimalCharValue(  c  )!=rc   [i]) {err++; printf("E12-%d %hhd %lld\n",i,CDecimalCharValue(   c  ),rc   [i]);}
    if ((MSLong)CDecimalCharValue(  cp1)!=rcp1 [i]) {err++; printf("E13-%d %hhd %lld\n",i,CDecimalCharValue(   cp1),rcp1 [i]);}
    if ((MSLong)CDecimalByteValue(  cm1)!=rucm1[i]) {err++; printf("E21-%d %hhu %lld\n",i,CDecimalByteValue(   cm1),rucm1[i]);}
    if ((MSLong)CDecimalByteValue(  c  )!=ruc  [i]) {err++; printf("E22-%d %hhu %lld\n",i,CDecimalByteValue(   c  ),ruc  [i]);}
    if ((MSLong)CDecimalByteValue(  cp1)!=rucp1[i]) {err++; printf("E23-%d %hhu %lld\n",i,CDecimalByteValue(   cp1),rucp1[i]);}
    if ((MSLong)CDecimalShortValue( cm1)!=rsm1 [i]) {err++; printf("E31-%d %hd %lld\n" ,i,CDecimalShortValue(  cm1),rsm1 [i]);}
    if ((MSLong)CDecimalShortValue( c  )!=rs   [i]) {err++; printf("E32-%d %hd %lld\n" ,i,CDecimalShortValue(  c  ),rs   [i]);}
    if ((MSLong)CDecimalShortValue( cp1)!=rsp1 [i]) {err++; printf("E33-%d %hd %lld\n" ,i,CDecimalShortValue(  cp1),rsp1 [i]);}
    if ((MSLong)CDecimalUShortValue(cm1)!=rusm1[i]) {err++; printf("E41-%d %hu %lld\n" ,i,CDecimalUShortValue( cm1),rusm1[i]);}
    if ((MSLong)CDecimalUShortValue(c  )!=rus  [i]) {err++; printf("E42-%d %hu %lld\n" ,i,CDecimalUShortValue( c  ),rus  [i]);}
    if ((MSLong)CDecimalUShortValue(cp1)!=rusp1[i]) {err++; printf("E43-%d %hu %lld\n" ,i,CDecimalUShortValue( cp1),rusp1[i]);}
    if ((MSLong)CDecimalIntValue(   cm1)!=rim1 [i]) {err++; printf("E51-%d %d %lld\n"  ,i,CDecimalIntValue(    cm1),rim1 [i]);}
    if ((MSLong)CDecimalIntValue(   c  )!=ri   [i]) {err++; printf("E52-%d %d %lld\n"  ,i,CDecimalIntValue(    c  ),ri   [i]);}
    if ((MSLong)CDecimalIntValue(   cp1)!=rip1 [i]) {err++; printf("E53-%d %d %lld\n"  ,i,CDecimalIntValue(    cp1),rip1 [i]);}
    if ((MSLong)CDecimalUIntValue(  cm1)!=ruim1[i]) {err++; printf("E61-%d %u %llu\n"  ,i,CDecimalUIntValue(   cm1),ruim1[i]);}
    if ((MSLong)CDecimalUIntValue(  c  )!=rui  [i]) {err++; printf("E62-%d %u %llu\n"  ,i,CDecimalUIntValue(   c  ),rui  [i]);}
    if ((MSLong)CDecimalUIntValue(  cp1)!=ruip1[i]) {err++; printf("E63-%d %u %llu\n"  ,i,CDecimalUIntValue(   cp1),ruip1[i]);}
    if ((MSLong)CDecimalLongValue(  cm1)!=rlm1 [i]) {err++; printf("E71-%d %lld %lld\n",i,CDecimalLongValue(   cm1),rlm1 [i]);}
    if ((MSLong)CDecimalLongValue(  c  )!=rl   [i]) {err++; printf("E72-%d %lld %lld\n",i,CDecimalLongValue(   c  ),rl   [i]);}
    if ((MSLong)CDecimalLongValue(  cp1)!=rlp1 [i]) {err++; printf("E73-%d %lld %lld\n",i,CDecimalLongValue(   cp1),rlp1 [i]);}
    if (        CDecimalULongValue( cm1)!=rulm1[i]) {err++; printf("E81-%d %llu %llu\n",i,CDecimalULongValue(  cm1),rulm1[i]);}
    if (        CDecimalULongValue( c  )!=rul  [i]) {err++; printf("E82-%d %llu %llu\n",i,CDecimalULongValue(  c  ),rul  [i]);}
    if (        CDecimalULongValue( cp1)!=rulp1[i]) {err++; printf("E83-%d %llu %llu\n",i,CDecimalULongValue(  cp1),rulp1[i]);}
    s= CDecimalRetainedDescription((id)cp1);
    b= CCreateBufferWithString(s, NSUTF8StringEncoding);
  //printf("E99-%d %s\n",i,CBufferCString(b));
    RELEASE(b); RELEASE(s);
    RELEASE(c); RELEASE(cm1); RELEASE(cp1);}
  RELEASE(minus1);
  return err;
  }

static int cdecimal_strto(void)
  {
  int err= 0,i; char t[256]; MSLong l; MSULong u;
  i= 0;
  sprintf(t,"\t %lld.89",(l= MSLongMax));
  if (l!=CStrToLongLong(t, NULL)) {
    err++; printf("F1-%d %lld %s\n",i,l,t);}
  sprintf(t,"  %llu+34d",(u= MSULongMax));
  if (u!=CStrToULongLong(t, NULL)) {
    err++; printf("F2-%d %llu %s\n",i,u,t);}
  if (MSLongMax!=CStrToLongLong(t, NULL)) {
    err++; printf("F3-%d %llu %s\n",i,MSLongMax,t);}
  return err;
  }

int mscore_cdecimal_validate(void)
  {
  int err= 0;
  err+= cdecimal_create();
  err+= cdecimal_op();
  err+= cdecimal_value();
  err+= cdecimal_fromSES();
  err+= cdecimal_cast();
  err+= cdecimal_strto();
  return err;
  }

test_t mscore_cdecimal[]= {
  {"create" ,NULL,cdecimal_create ,INTITIALIZE_TEST_T_END},
  {"op"     ,NULL,cdecimal_op     ,INTITIALIZE_TEST_T_END},
  {"values" ,NULL,cdecimal_value  ,INTITIALIZE_TEST_T_END},
  {"fromSES",NULL,cdecimal_fromSES,INTITIALIZE_TEST_T_END},
  {"cast"   ,NULL,cdecimal_cast   ,INTITIALIZE_TEST_T_END},
  {"strto"  ,NULL,cdecimal_strto  ,INTITIALIZE_TEST_T_END},
  {NULL}
};

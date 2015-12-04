// mscore_cdecimal_validate.c, ecb, 130911

#include "mscore_validate.h"

static void cdecimal_create(test_t *test)
  {
  CDecimal *c,*d,*e,*f;
  c= (CDecimal*)MSCreateObjectWithClassIndex(CDecimalClassIndex);
  m_apm_init(c);
  d= CCreateDecimalWithLongLong(0LL);
  TASSERT_EQUALS(test, RETAINCOUNT(c), 1, "A1 Bad retain count: %lu",WLU(RETAINCOUNT(c)));
  TASSERT_EQUALS(test, RETAINCOUNT(d), 1, "A2 Bad retain count: %lu",WLU(RETAINCOUNT(d)));
  TASSERT(test, CDecimalEquals(c, d), "A3 c & d are not equals");
  RELEASE(c);
  RELEASE(d);
  c= CCreateDecimalWithUTF8String("3.14");
  d= CCreateDecimalWithDouble(3.14);
//cdecimal_print(c);
//cdecimal_print(d);
  TASSERT_EQUALS(test, RETAINCOUNT(c), 1, "A5 Bad retain count: %lu",WLU(RETAINCOUNT(c)));
  TASSERT_EQUALS(test, RETAINCOUNT(d), 1, "A6 Bad retain count: %lu",WLU(RETAINCOUNT(d)));
  TASSERT(test, CDecimalEquals(c, d), "A7 c & d are not equals");
  e= CCreateDecimalWithLongLong(3LL);
  TASSERT(test, !CDecimalEquals(d, e), "A8 d & e are equals");
  f= CCreateDecimalFloor(d);
  TASSERT(test, CDecimalEquals(e, f), "A9 e & f are not equals");
  RELEASE(c);
  RELEASE(d);
  RELEASE(e);
  RELEASE(f);
  }

static void cdecimal_op(test_t *test)
  {
  int i;
  CDecimal *c[10],*d; CBuffer *bc,*bd;
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
  for (i= 1; i<10; i++) {
    d= CCreateDecimalDivide(MM_PI, MM_One, i-1); // TODO: look why -1
    bc= CCreateUTF8BufferWithObjectDescription((id)c[i]);
    bd= CCreateUTF8BufferWithObjectDescription((id)d);
    TASSERT(test, CDecimalEquals(c[i], d), "%d %s %s",i,CBufferCString(bc),CBufferCString(bd));
    RELEASE(bc); RELEASE(bd); RELEASE(d);}
  for (i=0; i<10; i++) RELEASE(c[i]);
  }

static void cdecimal_value(test_t *test)
  {
  int i;
  CDecimal *c[10]; CBuffer *b;
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
  for (i= 1; i<10; i++) {
    b= CCreateUTF8BufferWithObjectDescription((id)c[i]);
    TASSERT_EQUALS(test, CDecimalLongValue(c[i]), l[i], "%d %s %lld != %lld",i,CBufferCString(b));
    RELEASE(b);}
  for (i= 0; i<10; i++) RELEASE(c[i]);
  }

static void cdecimal_fromSES(test_t *test)
  {
  int i;
  CDecimal *c; SES sesIn,sesOut;
  char *txt [10]= {"0","-1.2","3.","   45.e13x","1.8.1",   ".34",".8","+.1e+2.1","+.1E+5"," .3e4 "};
  char *terr[10]= {".","e","1.E","   +. ","+.e",".e","+E","+a","+E+5"," .e4 "};
  NSUInteger start[10]= {0, 0,0,              3,0,   0,0, 0,    0,   1};
  NSUInteger lg   [10]= {1, 2,1,              2,1,   0,0, 1,    1,   0};
  NSUInteger lgd  [10]= {1, 4,2,              6,3,   3,2, 6,    6,   4};
  MSLong     val  [10]= {0,-1,3,             45,1,   0,0, 0,    0,   0};
  MSLong     vald [10]= {0,-1,3,450000000000000LL,2,   0,1,10,10000,3000};

  NSUInteger estart[10]= {0,0,0,3,0,0,0,0,0,1};
  NSUInteger elg   [10]= {0,0,1,1,1,0,1,1,1,0};
  NSUInteger elgd  [10]= {1,0,3,2,2,1,1,1,1,1};
  for (i=0; i<10; i++) {
    sesIn= MSMakeSESWithBytes(txt[i], strlen(txt[i]), NSUTF8StringEncoding);
    c= CCreateDecimalWithSES(sesIn, YES, NULL, &sesOut);
    TASSERT_EQUALS(test, SESStart( sesOut), start[i], "%d %lu != %lu",i);
    TASSERT_EQUALS(test, SESLength(sesOut),    lg[i], "%d %lu != %lu",i);
    if (i<5) {
      if (TASSERT(test, c, "%d c is NULL",i))
        TASSERT_EQUALS(test, CDecimalLongValue(c), val[i], "%d %lld %lld",i);}
    else {
      TASSERT(test, !c, "%d  %lld",i,CDecimalLongValue(c));}
    RELEASE(c);
    c= CCreateDecimalWithSES(sesIn, NO, NULL, &sesOut);
    TASSERT_EQUALS(test, SESStart( sesOut), start[i], "%d %lu != %lu",i);
    TASSERT_EQUALS(test, SESLength(sesOut),   lgd[i], "%d %lu != %lu",i);
    if (TASSERT(test, c, "%d c is NULL",i))
      TASSERT_EQUALS(test, CDecimalLongValue(c), vald[i], "%d %f %lld %lld",i,strtod(txt[i], NULL));
    RELEASE(c);}
  for (i=0; i<10; i++) {
    sesIn= MSMakeSESWithBytes(terr[i], strlen(terr[i]), NSUTF8StringEncoding);
    c= CCreateDecimalWithSES(sesIn, YES, NULL, &sesOut);
    TASSERT_EQUALS(test, SESStart( sesOut), estart[i], "%d %lu != %lu",i);
    TASSERT_EQUALS(test, SESLength(sesOut),    elg[i], "%d %lu != %lu",i);
    if (i==2) TASSERT(test,  c, "%d c is NULL",i);
    else      TASSERT(test, !c, "%d %lld",i,CDecimalLongValue(c));
    RELEASE(c);
    c= CCreateDecimalWithSES(sesIn, NO, NULL, &sesOut);
    TASSERT_EQUALS(test, SESStart( sesOut), estart[i], "%d %lu != %lu",i);
    TASSERT_EQUALS(test, SESLength(sesOut),   elgd[i], "%d %lu != %lu",i);
    TASSERT(test, !c, "%d %lld %s",i,CDecimalLongValue(c),terr[i]);
    RELEASE(c);}
  }

static void cdecimal_cast(test_t *test)
  {
#define __UIntMaxU ((MSULong)MSUIntMax)

  int i;
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
  for (i= 0; i<12; i++) {
    c= CCreateDecimalWithLongLong(val[i]);
    cm1= CCreateDecimalAdd(c, minus1);
    cp1= CCreateDecimalAdd(c, MM_One);
    TASSERT_EQUALS(test, (MSLong)CDecimalCharValue(  cm1), rcm1 [i], "%d %hhd %lld",i);
    TASSERT_EQUALS(test, (MSLong)CDecimalCharValue(  c  ), rc   [i], "%d %hhd %lld",i);
    TASSERT_EQUALS(test, (MSLong)CDecimalCharValue(  cp1), rcp1 [i], "%d %hhd %lld",i);
    TASSERT_EQUALS(test, (MSLong)CDecimalByteValue(  cm1), rucm1[i], "%d %hhu %lld",i);
    TASSERT_EQUALS(test, (MSLong)CDecimalByteValue(  c  ), ruc  [i], "%d %hhu %lld",i);
    TASSERT_EQUALS(test, (MSLong)CDecimalByteValue(  cp1), rucp1[i], "%d %hhu %lld",i);
    TASSERT_EQUALS(test, (MSLong)CDecimalShortValue( cm1), rsm1 [i], "%d %hd %lld" ,i);
    TASSERT_EQUALS(test, (MSLong)CDecimalShortValue( c  ), rs   [i], "%d %hd %lld" ,i);
    TASSERT_EQUALS(test, (MSLong)CDecimalShortValue( cp1), rsp1 [i], "%d %hd %lld" ,i);
    TASSERT_EQUALS(test, (MSLong)CDecimalUShortValue(cm1), rusm1[i], "%d %hu %lld" ,i);
    TASSERT_EQUALS(test, (MSLong)CDecimalUShortValue(c  ), rus  [i], "%d %hu %lld" ,i);
    TASSERT_EQUALS(test, (MSLong)CDecimalUShortValue(cp1), rusp1[i], "%d %hu %lld" ,i);
    TASSERT_EQUALS(test, (MSLong)CDecimalIntValue(   cm1), rim1 [i], "%d %d %lld"  ,i);
    TASSERT_EQUALS(test, (MSLong)CDecimalIntValue(   c  ), ri   [i], "%d %d %lld"  ,i);
    TASSERT_EQUALS(test, (MSLong)CDecimalIntValue(   cp1), rip1 [i], "%d %d %lld"  ,i);
    TASSERT_EQUALS(test, (MSLong)CDecimalUIntValue(  cm1), ruim1[i], "%d %u %llu"  ,i);
    TASSERT_EQUALS(test, (MSLong)CDecimalUIntValue(  c  ), rui  [i], "%d %u %llu"  ,i);
    TASSERT_EQUALS(test, (MSLong)CDecimalUIntValue(  cp1), ruip1[i], "%d %u %llu"  ,i);
    TASSERT_EQUALS(test, (MSLong)CDecimalLongValue(  cm1), rlm1 [i], "%d %lld %lld",i);
    TASSERT_EQUALS(test, (MSLong)CDecimalLongValue(  c  ), rl   [i], "%d %lld %lld",i);
    TASSERT_EQUALS(test, (MSLong)CDecimalLongValue(  cp1), rlp1 [i], "%d %lld %lld",i);
    TASSERT_EQUALS(test,         CDecimalULongValue( cm1), rulm1[i], "%d %llu %llu",i);
    TASSERT_EQUALS(test,         CDecimalULongValue( c  ), rul  [i], "%d %llu %llu",i);
    TASSERT_EQUALS(test,         CDecimalULongValue( cp1), rulp1[i], "%d %llu %llu",i);
    s= CDecimalRetainedDescription((id)cp1);
    b= CCreateBufferWithString(s, NSUTF8StringEncoding);
  //printf("E99-%d %s\n",i,CBufferCString(b));
    RELEASE(b); RELEASE(s);
    RELEASE(c); RELEASE(cm1); RELEASE(cp1);}
  RELEASE(minus1);
  }

static void cdecimal_strto(test_t *test)
  {
  int i; char t[256]; MSLong l; MSULong u;
  i= 0;
  sprintf(t,"\t %lld.89",(l= MSLongMax));
  TASSERT_EQUALS(test, l, CStrToLongLong(t, NULL), "%d %lld %s",i,l,t);
  sprintf(t,"  %llu+34d",(u= MSULongMax));
  TASSERT_EQUALS(test, u, CStrToULongLong(t, NULL), "%d %llu %s",i,u,t);
  TASSERT_EQUALS(test, MSLongMax, CStrToLongLong(t, NULL), "%d %llu %s",i,MSLongMax,t);
  }

testdef_t mscore_cdecimal[]= {
  {"create" ,NULL,cdecimal_create },
  {"op"     ,NULL,cdecimal_op     },
  {"values" ,NULL,cdecimal_value  },
  {"fromSES",NULL,cdecimal_fromSES},
  {"cast"   ,NULL,cdecimal_cast   },
  {"strto"  ,NULL,cdecimal_strto  },
  {NULL}
};

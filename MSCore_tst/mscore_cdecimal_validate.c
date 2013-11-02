// mscore_cdecimal_validate.c, ecb, 130911

#include "MSCorePrivate_.h"
#include "mscore_validate.h"

static inline void cdecimal_print(CDecimal *d)
  {
  char str[256];
  m_apm_to_string(str, 6, d);
  fprintf(stdout, "%s\n",str);
  }

static inline int cdecimal_create(void)
  {
  int err= 0;
  CDecimal *c,*d,*e,*f;
  c= (CDecimal*)MSCreateObjectWithClassIndex(CDecimalClassIndex);
  m_apm_init(c);
  d= CCreateDecimalFromLong(0LL);
  if (RETAINCOUNT(c)!=1) {
    fprintf(stdout, "A1 Bad retain count: %lu\n",WLU(RETAINCOUNT(c))); err++;}
  if (RETAINCOUNT(d)!=1) {
    fprintf(stdout, "A2 Bad retain count: %lu\n",WLU(RETAINCOUNT(d))); err++;}
  if (!CDecimalEquals(c, d)) {
    fprintf(stdout, "A3 c & d are not equals\n"); err++;}
  RELEASE(c);
  RELEASE(d);
  c= CCreateDecimalFromUTF8String("3.14");
  d= CCreateDecimalFromDouble(3.14);
//cdecimal_print(c);
//cdecimal_print(d);
  if (RETAINCOUNT(c)!=1) {
    fprintf(stdout, "A5 Bad retain count: %lu\n",WLU(RETAINCOUNT(c))); err++;}
  if (RETAINCOUNT(d)!=1) {
    fprintf(stdout, "A6 Bad retain count: %lu\n",WLU(RETAINCOUNT(d))); err++;}
  if (!CDecimalEquals(c, d)) {
    fprintf(stdout, "A7 c & d are not equals\n"); err++;}
  e= CCreateDecimalFromLong(3LL);
  if (CDecimalEquals(d, e)) {
    fprintf(stdout, "A8 d & e are equals\n"); err++;}
  f= CDecimalFloor(d);
  if (!CDecimalEquals(e, f)) {
    fprintf(stdout, "A9 e & f are not equals\n"); err++;}
  RELEASE(c);
  RELEASE(d);
  RELEASE(e);
  RELEASE(f);
  return err;
  }

static inline int cdecimal_op(void)
  {
  int err= 0, i;
  CDecimal *c[10],*d;
  c[0]= CCreateDecimalFromUTF8String("3.");
  c[1]= CCreateDecimalFromUTF8String("3.1");
  c[2]= CCreateDecimalFromUTF8String("3.14");
  c[3]= CCreateDecimalFromUTF8String("3.141");
  c[4]= CCreateDecimalFromUTF8String("3.1415");
  c[5]= CCreateDecimalFromUTF8String("3.14159");
  c[6]= CCreateDecimalFromUTF8String("3.141592");
  c[7]= CCreateDecimalFromUTF8String("3.1415926");
  c[8]= CCreateDecimalFromUTF8String("3.14159265");
  c[9]= CCreateDecimalFromUTF8String("3.141592653");
  for (i=1; i<10; i++) {
    d= CDecimalDivide(MM_PI, MM_One, i-1); // TODO: look why -1
    if (!CDecimalEquals(c[i], d)) {
      cdecimal_print(c[i]); cdecimal_print(d);
      fprintf(stdout, "B1-%d c & d are not equals\n",i); err++;}
    RELEASE(d);}
  for (i=1; i<10; i++) RELEASE(c[i]);
  return err;
  }

int mscore_cdecimal_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  err+= cdecimal_create();
  err+= cdecimal_op();

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","CDecimal",(err?"FAIL":"PASS"),seconds);
  return err;
  }

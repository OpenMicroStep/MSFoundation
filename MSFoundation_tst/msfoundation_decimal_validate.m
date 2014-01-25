// msfoundation_decimal_validate.m, ecb, 130911

#include "MSFoundation_Private.h"
#include "msfoundation_validate.h"

static inline void decimal_print(MSDecimal *d)
  {
  char str[256];
  m_apm_to_string(str, 6, (CDecimal*)d);
  fprintf(stdout, "%s\n",str);
  }

static inline int decimal_create(void)
  {
  int err= 0;
  MSDecimal *c,*d,*e,*f;
  c= MSCreateObjectWithClassIndex(CDecimalClassIndex);
  m_apm_init((CDecimal*)c);
  d= RETAIN(DECIMALL(0LL));
  if (RETAINCOUNT(c)!=1) {
    fprintf(stdout, "A1 Bad retain count: %lu\n",WLU(RETAINCOUNT(c))); err++;}
  if (RETAINCOUNT(d)!=2) {
    fprintf(stdout, "A2 Bad retain count: %lu\n",WLU(RETAINCOUNT(d))); err++;}
  if (![c isEqualToDecimal:d]) {
    fprintf(stdout, "A3 c & d are not equals\n"); err++;}
  RELEASE(c);
  RELEASE(d);
  c= RETAIN(DECIMALU("3.14"));
  d= RETAIN(DECIMALD( 3.14 ));
//decimal_print(c);
//decimal_print(d);
  if (RETAINCOUNT(c)!=2) {
    fprintf(stdout, "A5 Bad retain count: %lu\n",WLU(RETAINCOUNT(c))); err++;}
  if (RETAINCOUNT(d)!=2) {
    fprintf(stdout, "A6 Bad retain count: %lu\n",WLU(RETAINCOUNT(d))); err++;}
  if (![c isEqualToDecimal:d]) {
    fprintf(stdout, "A7 c & d are not equals\n"); err++;}
  e= RETAIN(DECIMALL(3LL));
  if ([d isEqualToDecimal:e]) {
    fprintf(stdout, "A8 d & e are equals\n"); err++;}
  f= RETAIN([d floorDecimal]);
  if (![e isEqual:f]) {
    fprintf(stdout, "A9 e & f are not equals\n"); err++;}
  RELEASE(c);
  RELEASE(d);
  RELEASE(e);
  RELEASE(f);
  return err;
  }

static inline int decimal_op(void)
  {
  int err= 0, i;
  MSDecimal *c[10],*d;
  c[0]= RETAIN(DECIMALU("3."));
  c[1]= RETAIN(DECIMALU("3.1"));
  c[2]= RETAIN(DECIMALU("3.14"));
  c[3]= RETAIN(DECIMALU("3.141"));
  c[4]= RETAIN(DECIMALU("3.1415"));
  c[5]= RETAIN(DECIMALU("3.14159"));
  c[6]= RETAIN(DECIMALU("3.141592"));
  c[7]= RETAIN(DECIMALU("3.1415926"));
  c[8]= RETAIN(DECIMALU("3.14159265"));
  c[9]= RETAIN(DECIMALU("3.141592653"));
  for (i=1; i<10; i++) {
    d= [MSD_PI decimalByDividingBy:MSD_One decimalPlaces:i-1]; // TODO: look why -1
    if (![c[i] isEqual:d]) {
      decimal_print(c[i]); decimal_print(d);
      fprintf(stdout, "B1-%d c & d are not equals\n",i); err++;}
    }
  for (i=1; i<10; i++) RELEASE(c[i]);
  return err;
  }

int msfoundation_decimal_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  err+= decimal_create();
  err+= decimal_op();

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","MSDecimal",(err?"FAIL":"PASS"),seconds);
  return err;
  }

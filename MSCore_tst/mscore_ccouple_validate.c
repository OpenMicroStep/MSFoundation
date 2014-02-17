// mscore_ccouple_validate.c, ecb, 130911

#include "MSCore_Private.h"
#include "mscore_validate.h"

static inline int ccouple_create(void)
  {
  int err= 0;
  CCouple *c,*d,*e;
  c= CCreateCouple(  nil,  nil);
  d= CCreateCouple((id)c,  nil);
  e= CCreateCouple((id)c,(id)d);
  if (RETAINCOUNT(c)!=3) {
    fprintf(stdout, "A1-Bad retain count: %lu\n",WLU(RETAINCOUNT(c)));
    err++;}
  if (RETAINCOUNT(d)!=2) {
    fprintf(stdout, "A2-Bad retain count: %lu\n",WLU(RETAINCOUNT(d)));
    err++;}
  if (CCoupleEquals(c, d)) {
    fprintf(stdout, "A3-c & d are equals\n");
    err++;}
  if (CCoupleEquals(d, e)) {
    fprintf(stdout, "A4-d & e are equals\n");
    err++;}
  if (!ISEQUAL(MSC1(d), c)) {
    fprintf(stdout, "A5-MSC1(d) & c not equals\n");
    err++;}
  if (!ISEQUAL(d, CCoupleSecondMember(e))) {
    fprintf(stdout, "A6-d & CCoupleSecondMember(e) not equals\n");
    err++;}
  RELEASE(c);
  RELEASE(d);
  RELEASE(e);
  return err;
  }

int mscore_ccouple_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  err+= ccouple_create();

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","CCouple",(err?"FAIL":"PASS"),seconds);
  return err;
  }
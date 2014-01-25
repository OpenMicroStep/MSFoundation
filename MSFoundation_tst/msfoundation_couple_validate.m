// msfoundation_couple_validate.m, ecb, 130911

#include "MSFoundation_Private.h"
#include "msfoundation_validate.h"

static inline int couple_create(void)
  {
  int err= 0;
  MSCouple *c,*d,*e;
  c= MSCreateCouple(  nil,  nil);
  d= MSCreateCouple((id)c,  nil);
  if (RETAINCOUNT(c)!=2) {
    fprintf(stdout, "A1-Bad retain count: %lu\n",WLU(RETAINCOUNT(c)));
    err++;}
  if (RETAINCOUNT(d)!=1) {
    fprintf(stdout, "A2-Bad retain count: %lu\n",WLU(RETAINCOUNT(d)));
    err++;}
  e= MSCreateCouple((id)c,(id)d);
  if (RETAINCOUNT(c)!=3) {
    fprintf(stdout, "A1'-Bad retain count: %lu\n",WLU(RETAINCOUNT(c)));
    err++;}
  if (RETAINCOUNT(d)!=2) {
    fprintf(stdout, "A2'-Bad retain count: %lu\n",WLU(RETAINCOUNT(d)));
    err++;}
  if (ISEQUAL(c, d)) {
    fprintf(stdout, "A3-c & d are equals\n");
    err++;}
  if (ISEQUAL(d, e)) {
    fprintf(stdout, "A4-d & e are equals\n");
    err++;}
  if (!ISEQUAL([d firstMember], c)) {
    fprintf(stdout, "A5-MSC1(d) & c not equals\n");
    err++;}
  if (!ISEQUAL(d, [e secondMember])) {
    fprintf(stdout, "A6-d & CCoupleSecondMember(e) not equals\n");
    err++;}
  if (!ISEQUAL([d allObjects], ARRAY c END)) {
    NSLog(@"A7-d allObjects %@ not equals c",[d allObjects]);
    err++;}
  RELEASE(c);
  RELEASE(d);
  RELEASE(e);
  return err;
  }

int msfoundation_couple_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  err+= couple_create();

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","MSCouple",(err?"FAIL":"PASS"),seconds);
  return err;
  }

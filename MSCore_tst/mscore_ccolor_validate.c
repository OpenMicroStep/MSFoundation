// mscore_ccolor_validate.c, ecb, 130911

#include "MSCorePrivate_.h"
#include "mscore_validate.h"

static inline int ccolor_create(void)
  {
  int err= 0;
  CColor *c,*d;
  c= CCreateColor(  0, 100, 200, 255);
  d= CCreateColor(249, 217, 178,   0);
  if (RETAINCOUNT(c)!=1) {
    fprintf(stdout, "A1-Bad retain count: %lu\n",WLU(RETAINCOUNT(c)));
    err++;}
  if (RETAINCOUNT(d)!=1) {
    fprintf(stdout, "A2-Bad retain count: %lu\n",WLU(RETAINCOUNT(d)));
    err++;}
  if (CColorIsPale(c)) {
    fprintf(stdout, "A3-c is pale: %f\n",CColorLuminance(c));
    err++;}
  if (!CColorIsPale(d)) {
    fprintf(stdout, "A4-d is not pale: %f\n",CColorLuminance(d));
    err++;}
  if (CColorIsEqual((id)c,(id)d)) {
    fprintf(stdout, "A5-c and d are equals\n");
    err++;}
  if (CColorsCompare(c,d)!=NSOrderedAscending) {
    fprintf(stdout, "A6-c and d are not ascending\n");
    err++;}
  RELEASE(d);
  d= (CColor*)CColorCopy((id)c);
  if (!CColorIsEqual((id)c,(id)d)) {
    fprintf(stdout, "A7-c and d are NOT equals\n");
    err++;}
  if (CColorsCompare(c,d)!=NSOrderedSame) {
    fprintf(stdout, "A8-c and d are not same\n");
    err++;}
  if (CColorRedValue(c)!=0) {
    fprintf(stdout, "A11-r %d\n",CColorRedValue(c));
    err++;}
  if (CColorGreenValue(c)!=100) {
    fprintf(stdout, "A11-r %d\n",CColorGreenValue(c));
    err++;}
  if (CColorBlueValue(c)!=200) {
    fprintf(stdout, "A11-r %d\n",CColorBlueValue(c));
    err++;}
  if (CColorOpacityValue(c)!=255) {
    fprintf(stdout, "A11-r %d\n",CColorOpacityValue(c));
    err++;}
  if (CColorTransparencyValue(c)!=0) {
    fprintf(stdout, "A11-r %d\n",CColorTransparencyValue(c));
    err++;}
  RELEASE(c);
  RELEASE(d);
  return err;
  }

int mscore_ccolor_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  err+= ccolor_create();

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","CColor",(err?"FAIL":"PASS"),seconds);
  return err;
  }

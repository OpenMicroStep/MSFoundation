// msfoundation_color_validate.m, ecb, 130911

#include "msfoundation_validate.h"

static inline int color_create(void)
  {
  int err= 0;
  MSColor *c1,*c2,*c3;
  c1= MSCreateColor(0xf0f8ffff);
  if (RETAINCOUNT(c1)!=1) {
    fprintf(stdout, "A1-Bad retain count: %lu\n",WLU(RETAINCOUNT(c1)));
    err++;}
  c2= MSAliceBlue;
  if (RETAINCOUNT(c2)!=1) {
    fprintf(stdout, "A2-Bad retain count: %lu\n",WLU(RETAINCOUNT(c2)));
    err++;}
  c3= MSYellowGreen;
  if (RETAINCOUNT(c3)!=1) {
    fprintf(stdout, "A3-Bad retain count: %lu\n",WLU(RETAINCOUNT(c3)));
    err++;}
  if ([c1 red]!=[c2 red]) {
    fprintf(stdout, "A4-Bad red: %u %u\n",[c1 red],[c2 red]);
    err++;}
  if ([c1 green]!=[c2 green]) {
    fprintf(stdout, "A5-Bad green: %u %u\n",[c1 green],[c2 green]);
    err++;}
  if ([c1 blue]!=[c2 blue]) {
    fprintf(stdout, "A6-Bad blue: %u %u\n",[c1 blue],[c2 blue]);
    err++;}
  if ([c1 opacity]!=[c2 opacity]) {
    fprintf(stdout, "A7-Bad opacity: %u %u\n",[c1 opacity],[c2 opacity]);
    err++;}
  if (!ISEQUAL(c1, c2)) {
    fprintf(stdout, "A8-Bad equals: %u %u\n",[c1 rgbaValue],[c2 rgbaValue]);
    err++;}
  if (ISEQUAL(c1, c3)) {
    fprintf(stdout, "A9-Bad equals: %u %u\n",[c1 rgbaValue],[c3 rgbaValue]);
    err++;}
  RELEASE(c1);
  RELEASE(c2);
  RELEASE(c3);
  return err;
  }

int msfoundation_color_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  err+= color_create();

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","MSColor",(err?"FAIL":"PASS"),seconds);
  return err;
  }

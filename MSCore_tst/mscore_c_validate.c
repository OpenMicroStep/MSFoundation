// mscore_c_validate.c, ecb, 11/09/13

#include "MSCorePrivate_.h"
#include "mscore_validate.h"

static inline int c_isa(CClassIndex classIndex)
  {
  int err= 0;
  id x,y;
  x= (id)MSCreateObjectWithClassIndex(classIndex);
  y= COPY(x);
  if (RETAINCOUNT(x)!=1) {
    fprintf(stdout, "A1-Bad retain count: %lu\n",WLU(RETAINCOUNT(x)));
    err++;}
  if (RETAINCOUNT(y)!=1) {
    fprintf(stdout, "A2-Bad retain count: %lu\n",WLU(RETAINCOUNT(y)));
    err++;}
  if (!ISEQUAL(x, y)) {
    fprintf(stdout, "A3-Bad equal\n");
    err++;}
  if (!ISEQUAL(ISA(x), ISA(y))) {
    fprintf(stdout, "A4-Bad isa equal\n");
    err++;}
  if (!ISEQUAL(NAMEOF(x), NAMEOF(y))) {
    fprintf(stdout, "A5-Bad class name equal\n");
    err++;}
  RELEASE(x);
  RELEASE(y);
  return err;
  }

int mscore_c_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  err+= c_isa(CArrayClassIndex);
  err+= c_isa(CBufferClassIndex);

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> C       validate: %s (%.3f s)\n",(err?"FAIL":"PASS"),seconds);
  return err;
  }


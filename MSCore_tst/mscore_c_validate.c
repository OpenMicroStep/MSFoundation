// mscore_c_validate.c, ecb, 130911

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
  if (!ISA(x)) {
    fprintf(stdout, "A4-Bad isa\n");
    err++;}
  if (!ISEQUAL(ISA(x), ISA(y))) {
    fprintf(stdout, "A5-Bad isa equal\n");
    err++;}
  if (!NAMEOFCLASS(x)) {
    fprintf(stdout, "A6-Bad nameof\n");
    err++;}
  if (memcmp(NAMEOFCLASS(x), NAMEOFCLASS(y),strlen(NAMEOFCLASS(x)))) {
    fprintf(stdout, "A7-Bad class name equal\n");
    err++;}
  RELEASE(x);
  RELEASE(y);
  return err;
  }

static inline int c_classEqual(void)
  {
  int err= 0;
  id x,y;
  x= (id)MSCreateObjectWithClassIndex(CArrayClassIndex);
  y= (id)MSCreateObjectWithClassIndex(CBufferClassIndex);
  if (ISEQUAL(ISA(x), ISA(y))) {
    fprintf(stdout, "B1-Bad isa equal\n");
    err++;}
  RELEASE(x);
  RELEASE(y);
  return err;
  }

int mscore_c_validate(void)
  {
  int err= 0;
  err+= c_isa(CArrayClassIndex);
  err+= c_isa(CBufferClassIndex);
  err+= c_classEqual();
  return err;
  }

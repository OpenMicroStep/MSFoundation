// mste_test.c, ecb, 140211

#include "MSCore_Private.h"
//#include "mscore_validate.h"

int mste_validate(void);

int main(int argc, const char *argv[])
  {
  int err= 0;
  argc= 0;
  argv= NULL;
  MSSystemInitialize(0, NULL);
  err= mste_validate();
  return err;
  }

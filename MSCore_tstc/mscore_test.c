// mscore_test.c, ecb, 130904

#include "mscore_validate.h"

int main(int argc, const char *argv[])
  {
  argc= 0;
  argv= NULL;
  MSSystemInitialize(0, NULL);
  return testCore(YES);
  }

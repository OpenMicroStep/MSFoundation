// main.m of MSCore_test_m, ecb, 04/09/13.

#include <Foundation/Foundation.h>
#import "MSCore.h"
#import "mscore_validate.h"

int main(int argc, const char *argv[])
  {
  NSAutoreleasePool *pool= [NSAutoreleasePool new];
  int err;
  argc= 0;
  argv= NULL;
  err= test();
  [pool release];
  return err;
  }

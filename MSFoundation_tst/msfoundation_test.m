// msfoundation_test.m, ecb, 04/09/13

#import "MSFoundationPrivate_.h"
#import "msfoundation_validate.h"

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

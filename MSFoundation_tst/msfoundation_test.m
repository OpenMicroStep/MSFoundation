// msfoundation_test.m, ecb, 130904

#import "MSFoundationPrivate_.h"
#import "msfoundation_validate.h"

int main(int argc, const char *argv[])
  {
  NSAutoreleasePool *pool= [NSAutoreleasePool new];
  int err;
  argc= 0;
  argv= NULL;
  err= testFoundation(YES);
  [pool release];
  return err;
  }

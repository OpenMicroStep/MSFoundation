// msfoundation_test.m, ecb, 130904

#import "MSFoundation_Private.h"
#import "msfoundation_validate.h"

int main(int argc, const char *argv[])
  {
  NSAutoreleasePool *pool= [NSAutoreleasePool new];
  int err;
  argc= 0;
  argv= NULL;
  MSSystemInitialize(0, NULL);
  err= testFoundation(YES);
  [pool release];
  return err;
  }

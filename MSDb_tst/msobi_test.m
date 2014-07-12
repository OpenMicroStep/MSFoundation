// msobi_test.m, ecb, 140101

#import "MSDb_Private.h"
#import "msobi_validate.h"

int main(int argc, const char *argv[])
  {
  NSAutoreleasePool *pool= [NSAutoreleasePool new];
  int err;
  argc= 0;
  argv= NULL;
  MSSystemInitialize(0, NULL);
  err= testObi(YES);
  [pool release];
  return err;
  }

// mscore_test.m, ecb, 130904

#import <Foundation/Foundation.h>
#import "MSCore_Private.h"
#import "mscore_validate.h"

int main(int argc, const char *argv[])
  {
  NSAutoreleasePool *pool= [NSAutoreleasePool new];
  int err;
  argc= 0;
  argv= NULL;
  MSSystemInitialize(0, NULL);
  err= testCore(YES);
  [pool release];
  return err;
  }

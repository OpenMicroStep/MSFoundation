// mscore_test.m, ecb, 04/09/13

#import <Foundation/Foundation.h>
#import "MSCorePrivate_.h"
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

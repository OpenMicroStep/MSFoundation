// msdb_test.m, ecb, 140101

#import "msdb_validate.h"

int main(int argc, const char *argv[])
  {
  NSAutoreleasePool *pool= [NSAutoreleasePool new];
  int err;
  argc= 0;
  argv= NULL;
  MSSystemInitialize(0, NULL);
  err= testDb(YES);
  [pool release];
  return err;
}

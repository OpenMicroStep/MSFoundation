// msfoundation_string_validate.m, ecb, 130911

#include "MSFoundation_Private.h"
#include "msfoundation_validate.h"

static inline int ms_ns(void)
  {
  int err= 0;
  NSString *s,*sl1,*sl2;
  s= MSCreateString("MSString");
  sl1= [(MSString*)s lowercaseString];
  sl2= MSCreateString("msstring");
  if (!ISEQUAL(sl1, sl2)) {
    NSLog(@"A1 not equal %@ %@",sl1,sl2); err++;}
  RELEASE(s);
  RELEASE(sl2);
  return err;
  }

static inline int ms_trim(void)
  {
  int err= 0;
  NSString *s,*st1,*st2;
  s=   MSCreateString(" MSString ");
  st1= MSCreateString( "MSString" );
  st2= [(MSString*)s trim];
  if (!ISEQUAL(st1, st2)) {
    NSLog(@"A2 not equal %@ %@",st1,st2); err++;}
  RELEASE(s);
  RELEASE(st1);
  return err;
  }

static int ms_toNs(void)
  {
  int err= 0;
  NSString *s1,*s2; id x1,x2;
  s1= @"/opt/microstep/support/MASHRepositoryServer/MHNetRepositoryServer.config";
  s2= MSCreateString("/opt/microstep/support/MASHRepositoryServer/MHNetRepositoryServer.config");
  x1= [NSDictionary dictionaryWithContentsOfFile:s1];
  x2= [NSDictionary dictionaryWithContentsOfFile:s2];
  if (!s1) {
    NSLog(@"A3 file not found %@",s1); err++;}
  if (!ISEQUAL(x1, x2)) {
    NSLog(@"A4 not equal\nAvec NS\n%@\nAvec MS\n%@",x1,x2); err++;}
  RELEASE(s1);
  RELEASE(s2);
  return err;
  }

int msfoundation_string_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  err+= ms_ns();
  err+= ms_trim();
  err+= ms_toNs();

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","MSString",(err?"FAIL":"PASS"),seconds);
  return err;
  }

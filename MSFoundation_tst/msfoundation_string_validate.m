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
    NSLog(@"A1 not equal %@ != %@",sl1,sl2); err++;}
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
    NSLog(@"A2 not equal %@ != %@",st1,st2); err++;}
  RELEASE(s);
  RELEASE(st1);
  return err;
  }

static int ms_toNs(void)
  {
  int err= 0;
  NSString *s1,*s2; id x1,x2;
  NSFileManager *fileManager; NSDirectoryEnumerator *e1,*e2; NSString *f1,*f2; BOOL end;
  s1= @"/opt/microstep/support/MASHRepositoryServer/MHNetRepositoryServer.config";
  s2= MSCreateString("/opt/microstep/support/MASHRepositoryServer/MHNetRepositoryServer.config");
  x1= [NSDictionary dictionaryWithContentsOfFile:s1];
  x2= [NSDictionary dictionaryWithContentsOfFile:s2];
  if (!x1) {
    NSLog(@"A3 file not found %@",s1); err++;}
  if (!ISEQUAL(x1, x2)) {
    NSLog(@"A4 not equal\nAvec NS\n%@\nAvec MS\n%@",x1,x2); err++;}
  ASSIGN(s1, [s1 stringByDeletingLastPathComponent]);
  ASSIGN(s2, [MSString stringWithString:[s2 stringByDeletingLastPathComponent]]);
  if (![s2 isKindOfClass:[MSString class]]) {
    NSLog(@"A5 s2 not a MSString %@ %@",[s2 class],s2); err++;}
  fileManager= [[[NSFileManager alloc] init] autorelease];
  e1= [fileManager enumeratorAtPath:s1];
  e2= [fileManager enumeratorAtPath:s2];
  for (end= NO; !end; end= !f1 || !f2) {
    f1= [e1 nextObject]; f2= [e2 nextObject];
    if (!ISEQUAL(f1, f2)) {
      NSLog(@"A6 not equal %@ != %@",f1,f2); err++;}}
  RELEASE(s1);
  RELEASE(s2);
  return err;
  }

static inline int ms_eq(void)
  {
  int err= 0;
  NSString *ns,*ms;
  ns= ms= nil;
  ASSIGN(ns, @"");
  ASSIGN(ms, [MSString stringWithCString:"" encoding:NSUTF8StringEncoding]);
  if (!ISEQUAL(ns, ms)) {
    NSLog(@"A20 not equal %@ != %@",ns,ms); err++;}
  if (!ISEQUAL(ms, ns)) {
    NSLog(@"A21 not equal %@ != %@",ms,ns); err++;}
  ASSIGN(ms, [MSString stringWithCString:"a string" encoding:NSUTF8StringEncoding]);
  if (ISEQUAL(ns, ms)) {
    NSLog(@"A22 equal %@ == %@",ns,ms); err++;}
  if (ISEQUAL(ms, ns)) {
    NSLog(@"A23 equal %@ == %@",ms,ns); err++;}
  ASSIGN(ns, @"a string");
  if (!ISEQUAL(ns, ms)) {
    NSLog(@"A24 not equal %@ != %@",ns,ms); err++;}
  if (!ISEQUAL(ms, ns)) {
    NSLog(@"A25 not equal %@ != %@",ms,ns); err++;}
  ASSIGN(ms, [MSString stringWithCString:"" encoding:NSUTF8StringEncoding]);
  if (ISEQUAL(ns, ms)) {
    NSLog(@"A26 equal %@ == %@",ns,ms); err++;}
  if (ISEQUAL(ms, ns)) {
    NSLog(@"A27 equal %@ == %@",ms,ns); err++;}
  RELEASE(ns);
  RELEASE(ms);
  return err;
  }

int msfoundation_string_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  err+= ms_ns();
  err+= ms_trim();
  err+= ms_toNs();
  err+= ms_eq();

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","MSString",(err?"FAIL":"PASS"),seconds);
  return err;
  }

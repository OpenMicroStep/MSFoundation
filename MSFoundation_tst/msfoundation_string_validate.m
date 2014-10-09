// msfoundation_string_validate.m, ecb, 130911

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


static inline int ms_cast(void)
{
  int err= 0;
  int intValue;
  NSInteger integerValue;
  long long longLongValue;
  
  // intValue test
  intValue = [@"123456789" intValue];
  if(intValue != 123456789) {
    NSLog(@"A28 not equal %d != %d",intValue, 123456789); err++;}
  
  intValue = [@"-123456789" intValue];
  if(intValue != -123456789) {
    NSLog(@"A29 not equal %d != %d",intValue, -123456789); err++;}
  
  intValue = [@"123456789123456789" intValue];
  if(intValue != INT_MAX) {
    NSLog(@"A30 not equal %d != %d",intValue, INT_MAX); err++;}
  
  intValue = [@"-123456789123456789" intValue];
  if(intValue != INT_MIN) {
    NSLog(@"A31 not equal %d != %d",intValue, INT_MIN); err++;}
  
  intValue = [@"Not an int" intValue];
  if(intValue != 0) {
    NSLog(@"A32 not equal %d != %d",intValue, 0); err++;}
  
  // longLongValue test
  longLongValue = [@"123456789123456789" longLongValue];
  if(longLongValue != 123456789123456789LL) {
    NSLog(@"A33 not equal %lld != %lld",longLongValue, 123456789123456789LL); err++;}
  
  longLongValue = [@"-123456789123456789" longLongValue];
  if(longLongValue != -123456789123456789LL) {
    NSLog(@"A34 not equal %lld != %lld",longLongValue, -123456789123456789LL); err++;}
  
  longLongValue = [@"123456789123456789123456789" longLongValue];
  if(longLongValue != LLONG_MAX) {
    NSLog(@"A35 not equal %lld != %lld",longLongValue, LLONG_MAX); err++;}
  
  longLongValue = [@"-123456789123456789123456789" longLongValue];
  if(longLongValue != LLONG_MIN) {
    NSLog(@"A36 not equal %lld != %lld",longLongValue, LLONG_MIN); err++;}
  
  longLongValue = [@"Not an long long" longLongValue];
  if(longLongValue != 0) {
    NSLog(@"A37 not equal %lld != %lld",longLongValue, 0LL); err++;}
  
  // integerValue test
  integerValue = [@"123456789" integerValue];
  if(integerValue != 123456789) {
    NSLog(@"A38 not equal %ld != %d",integerValue, 123456789); err++;}
  
  integerValue = [@"-123456789" integerValue];
  if(integerValue != -123456789) {
    NSLog(@"A39 not equal %ld != %d",integerValue, -123456789); err++;}
  
  integerValue = [@"Not an integer" integerValue];
  if(integerValue != 0) {
    NSLog(@"A40 not equal %ld != %d",integerValue, 0); err++;}
  
  return err;
}

int msfoundation_string_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  err+= ms_ns();
  err+= ms_trim();
  err+= ms_toNs();
  err+= ms_eq();
  err+= ms_cast();

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","MSString",(err?"FAIL":"PASS"),seconds);
  return err;
  }

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

static inline int ms_formatlld(void)
{
  int err= 0;
  int intValue = 2;
  long long max = LLONG_MAX;
  long long min = LLONG_MIN;
  long long negvalue1 = -1LL;
  long long posvalue1 = 1LL;
  long long negvalue2 = -2332036854779808LL;
  long long posvalue2 = 22337236854775808LL;
  unsigned long long umax = ULLONG_MAX;
  unsigned long long uposvalue1 = 1ULL;
  unsigned long long uposvalue2 = 22337236854775808ULL;
  NSString *f, *s;
  
  f = [ALLOC(NSString) initWithFormat:@"%lld", posvalue2];
  s = @"22337236854775808";
  if (!ISEQUAL(f, s)) {
    NSLog(@"A41 not equal %@ != %@",f,s); err++;}
  RELEASE(f);
  
  f = [ALLOC(NSString) initWithFormat:@"%s %lld %lld %lld", "start", min, negvalue2, negvalue1];
  s = @"start -9223372036854775808 -2332036854779808 -1";
  if (!ISEQUAL(f, s)) {
    NSLog(@"A42 not equal %@ != %@",f,s); err++;}
  RELEASE(f);
  
  f = [ALLOC(NSString) initWithFormat:@"%s %lld %lld %lld %d %lld %lld %lld %s", "start", min, negvalue2, negvalue1, intValue, posvalue1, posvalue2, max, "end"];
  s = @"start -9223372036854775808 -2332036854779808 -1 2 1 22337236854775808 9223372036854775807 end";
  if (!ISEQUAL(f, s)) {
    NSLog(@"A43 not equal %@ != %@",f,s); err++;}
  RELEASE(f);
  
  f = [ALLOC(NSString) initWithFormat:@"%llu", posvalue2];
  s = @"22337236854775808";
  if (!ISEQUAL(f, s)) {
    NSLog(@"A44 not equal %@ != %@",f,s); err++;}
  RELEASE(f);
  
  f = [ALLOC(NSString) initWithFormat:@"%s %llu %llu %llu", "start", umax, uposvalue2, uposvalue1];
  s = @"start 18446744073709551615 22337236854775808 1";
  if (!ISEQUAL(f, s)) {
    NSLog(@"A45 not equal %@ != %@",f,s); err++;}
  RELEASE(f);
  
  f = [ALLOC(NSString) initWithFormat:@"%s %llu %d %llu %llu %s", "start", umax, intValue, uposvalue1, uposvalue2, "end"];
  s = @"start 18446744073709551615 2 1 22337236854775808 end";
  if (!ISEQUAL(f, s)) {
    NSLog(@"A46 not equal %@ != %@",f,s); err++;}
  RELEASE(f);
  
  return err;
}

@interface NSString (HashPrivate)
- (NSUInteger)hash:(unsigned)depth;
@end

static inline int ms_hash(void)
{
  int err= 0;
  NSString *nsStr;
  MSString *msStr;
  NSUInteger nsHash, msHash;
  
  nsStr = [[NSString alloc] initWithString:@"AgentVerbalisateur"];
  msStr = [[MSString alloc] initWithString:@"AgentVerbalisateur"];
  nsHash = [nsStr hash:0];
  msHash = [msStr hash:0];
  if(nsHash != msHash) {
    NSLog(@"A47 not equal %lu != %lu",(unsigned long)nsHash,(unsigned long)msHash); err++;}
  RELEASE(nsStr);
  RELEASE(msStr);
  
  nsStr = [[NSString alloc] initWithString:@"CasInfraction"];
  msStr = [[MSString alloc] initWithString:@"CasInfraction"];
  nsHash = [nsStr hash:0];
  msHash = [msStr hash:0];
  if(nsHash != msHash) {
    NSLog(@"A48 not equal %lu != %lu",(unsigned long)nsHash,(unsigned long)msHash); err++;}
  RELEASE(nsStr);
  RELEASE(msStr);
  
  return err;
}

static int ms_ascii(void)
{
  int err= 0;
  const char *ascii, *expected;
  NSString *expectedStr;
  MSASCIIString *asciiStr;
  NEW_POOL;
  ascii= [@"test" asciiCString];
  expected= "test";
  if(strcmp(expected, ascii) != 0){
    NSLog(@"B1 ascii string '%s' not equals to '%s'",ascii, expected); err++;}
  ascii= [[MSString stringWithString:@"test"] asciiCString];
  if(strcmp(expected, ascii) != 0){
    NSLog(@"B2 ascii string '%s' not equals to '%s'",ascii, expected); err++;}
    
  ascii= [@"testé\"'(§è!çà" asciiCString];
  expected= "teste\"'(e!ca";
  if(strcmp(expected, ascii) != 0){
    NSLog(@"B3 ascii string '%s' not equals to '%s'",ascii, expected); err++;}
  ascii= [[MSString stringWithString:@"testé\"'(§è!çà"] asciiCString];
  if(strcmp(expected, ascii) != 0){
    NSLog(@"B4 ascii string '%s' not equals to '%s'",ascii, expected); err++;}
    
  expected= "test";
  asciiStr= [MSASCIIString stringWithBytes:expected length:strlen(expected)];
  expectedStr= @"test";
  if(![expectedStr isEqual:asciiStr]){
    NSLog(@"B5 ascii string '%@' not equals to '%@'",asciiStr, expectedStr); err++;}
    
  expectedStr=asciiStr;
  asciiStr= [expectedStr copy];
  if(![expectedStr isEqual:asciiStr]){
    NSLog(@"B6 ascii string '%@' not equals to '%@'",asciiStr, expectedStr); err++;}
  
  KILL_POOL;
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
  err+= ms_formatlld();
  err+= ms_hash();
  err+= ms_ascii();

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","MSString",(err?"FAIL":"PASS"),seconds);
  return err;
  }

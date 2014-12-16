// msfoundation_dictionary_validate.m, ecb, 130911

#include "msfoundation_validate.h"
/*
static inline void cdictionary_print(MSDictionary *d)
  {
  fprintf(stdout, "%lu\n",WLU([d count]));
  }
*/
static inline int cdictionary_create(void)
  {
  int err= 0;
  MSDictionary *c,*m; MSDictionary *d; id k,o,x; int i;
  c= [MSDictionary new];
  d= [[MSDictionary alloc] init];
  if (RETAINCOUNT(c)!=1) {
    fprintf(stdout, "A1 Bad retain count: %lu\n",WLU(RETAINCOUNT(c))); err++;}
  if (RETAINCOUNT(d)!=1) {
    fprintf(stdout, "A2 Bad retain count: %lu\n",WLU(RETAINCOUNT(d))); err++;}
  if (![c isEqual:d]) {
    fprintf(stdout, "A3 c & d are not equals\n"); err++;}
  RELEASE(d);
  k= [[MSBuffer alloc] initWithBytes:"key1" length:4];
  o= [[MSBuffer alloc] initWithBytes:"obj1" length:4];
  [c setObject:o forKey:k];
  if (RETAINCOUNT(k)!=1) {
    fprintf(stdout, "A10 Bad retain count: %lu\n",WLU(RETAINCOUNT(k))); err++;}
  if (RETAINCOUNT(o)!=2) {
    fprintf(stdout, "A11 Bad retain count: %lu\n",WLU(RETAINCOUNT(o))); err++;}
//d= [MSDictionary new]; [d setObject:k forKey:k];
//d= [[MSDictionary alloc] initWithObject:k forKey:k];
  d= [[MSDictionary alloc] initWithObjects:&k forKeys:&k count:1];
  if (RETAINCOUNT(d)!=1) {
    fprintf(stdout, "A12 Bad retain count: %lu\n",WLU(RETAINCOUNT(d))); err++;}
  if (RETAINCOUNT(k)!=2) {
    fprintf(stdout, "A13 Bad retain count: %lu\n",WLU(RETAINCOUNT(k))); err++;}
  if ([c isEqual:d]) {
    fprintf(stdout, "A14 c & d are equals\n"); err++;}
  m= [d mutableCopy]; RELEASE(d); [m setObject:o forKey:k]; d= [m copy]; RELEASE(m);
  if (RETAINCOUNT(k)!=1) {
    fprintf(stdout, "A15 Bad retain count: %lu\n",WLU(RETAINCOUNT(k))); err++;}
  if (RETAINCOUNT(o)!=3) {
    fprintf(stdout, "A16 Bad retain count: %lu\n",WLU(RETAINCOUNT(o))); err++;}
  if (![c isEqual:d]) {
    fprintf(stdout, "A17 c & d are not equals\n"); err++;}
  m= [d mutableCopy];
  RELEASE(d);
  x= [[MSBuffer alloc] initWithBytes:"a key" length:5];
  [m setObject:o forKey:x];
  if ([m count]!=2) {
    fprintf(stdout, "A20 Bad count: %lu\n",WLU([m count])); err++;}
  if ([c isEqual:m]) {
    fprintf(stdout, "A21 c & d are equals\n"); err++;}
  [m removeObjectForKey:x];
  if (![c isEqual:m]) {
    fprintf(stdout, "A22 c & d are not equals\n"); err++;}
  for (i= 0; i<100; i++) {
    CBufferAppendByte((CBuffer*)x, (MSByte)i);
    [m setObject:o forKey:x];}
  if (RETAINCOUNT(o)!=103) {
    fprintf(stdout, "A23 Bad retain count: %lu\n",WLU(RETAINCOUNT(o))); err++;}
//printf("1\n");
  RELEASE(x);
  RELEASE(c);
  if (RETAINCOUNT(m)!=1) {
    fprintf(stdout, "A41 Bad retain count: %lu\n",WLU(RETAINCOUNT(m))); err++;}
  RELEASE(m);
  if (RETAINCOUNT(k)!=1) {
    fprintf(stdout, "A42 Bad retain count: %lu\n",WLU(RETAINCOUNT(k))); err++;}
  if (RETAINCOUNT(o)!=1) {
    fprintf(stdout, "A43 Bad retain count: %lu\n",WLU(RETAINCOUNT(o))); err++;}
  RELEASE(k);
  RELEASE(o);
  return err;
  }

static inline int cdictionary_enum(void)
  {
  int err= 0;
  MSDictionary *c,*d; id ks[1000],os[1000],k,o; int i,n,fd; MSDictionaryEnumerator *de;
  k= [[MSBuffer alloc] initWithBytes:"a key" length:5];
  o= [[MSBuffer alloc] initWithBytes:"an object" length:9];
  for (i=0; i<1000; i++) {
    CBufferAppendByte((CBuffer*)k, (MSByte)i); ks[i]= COPY(k);
    CBufferAppendByte((CBuffer*)o, (MSByte)i); os[i]= COPY(o);}
  RELEASE(k);
  RELEASE(o);
  d= [[MSDictionary alloc] initWithObjects:os forKeys:ks count:1000];
  if ([d count]!=1000) {
    fprintf(stdout, "B1 Bad count: %lu\n",WLU([d count])); err++;}

  c= [d copy];
  RELEASE(d);
  d= [c copy];
  RELEASE(c);

  de= [d dictionaryEnumerator];
  for (n= 0, fd= 0; (o= [de nextObject]); n++) {
    k= [de currentKey];
    for (i= 0; i<1000; i++) {
      if (ISEQUAL(k, ks[i])) fd++;}
    if (fd!=n+1) {
      fprintf(stdout, "B2 Bad fd: %lu %lu\n",WLI(fd),WLI(n)); err++;}}
  if (n!=1000) {
    fprintf(stdout, "B3 Bad n: %lu\n",WLI(n)); err++;}

  de= [d dictionaryEnumerator];
  for (n= 0, fd= 0; (k= [de nextKey]); n++) {
    o= [de currentObject];
    for (i= 0; i<1000; i++) {
      if (ISEQUAL(o, os[i])) fd++;}
    if (fd!=n+1) {
      fprintf(stdout, "B4 Bad fd: %lu %lu\n",WLI(fd),WLI(n)); err++;}}
  if (n!=1000) {
    fprintf(stdout, "B5 Bad n: %lu\n",WLI(n)); err++;}

  for (i= 0; i<1000; i++) {
    RELEASE(ks[i]); RELEASE(os[i]);}
  RELEASE(d);
  return err;
  }

static int cdictionary_init(void)
  {
  int err= 0;
  NSDictionary *o;
  MSDictionary *d, *d2;
  
  o= [NSDictionary dictionaryWithObjectsAndKeys:@"obj1", @"key1", @"obj2", @"key2", nil];
  if([o count] != 2) {
    fprintf(stdout, "C1: %d != 2\n",(int)[o count]); err++;}
  d= [MSDictionary dictionaryWithDictionary:o];
  if([d count] != 2) {
    fprintf(stdout, "C2: %d != 2\n",(int)[o count]); err++;}
  if(![d isEqual:o]) {
    fprintf(stdout, "C3: dictionary missmatch\n"); err++;}
  if(![o isEqual:d]) {
    fprintf(stdout, "C4: dictionary missmatch\n"); err++;}
    
  d2= [MSDictionary dictionaryWithDictionary:d];
  if([d2 count] != 2) {
    fprintf(stdout, "C5: %d != 2\n",(int)[o count]); err++;}
  if(![d2 isEqual:o]) {
    fprintf(stdout, "C6: dictionary missmatch\n"); err++;}
  if(![o isEqual:d2]) {
    fprintf(stdout, "C7: dictionary missmatch\n"); err++;}
  if(![d2 isEqual:d]) {
    fprintf(stdout, "C8: dictionary missmatch\n"); err++;}
  if(![d isEqual:d2]) {
    fprintf(stdout, "C9: dictionary missmatch\n"); err++;}
  return err;
  }

int msfoundation_dictionary_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  err+= cdictionary_create();
  err+= cdictionary_enum();
  err+= cdictionary_init();

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","MSDictionary",(err?"FAIL":"PASS"),seconds);
  return err;
  }

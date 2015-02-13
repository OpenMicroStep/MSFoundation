#import "foundation_validate.h"

static int nsdictionary_create(void)
{
  int err= 0;
  NSMutableDictionary *c,*m; NSDictionary *d; id k,o,x; int i;
  c= [NSMutableDictionary new];
  d= [[NSDictionary alloc] init];
  //ASSERT_EQUALS(RETAINCOUNT(c), 1, "[NSDictionary new] retain count must be %2$d, got %1$d");
  //ASSERT_EQUALS(RETAINCOUNT(d), 1, "[[NSDictionary alloc] init] retain count must be %2$d, got %1$d");
  ASSERT_ISEQUAL(c, d, "[NSMutableDictionary new] is equal to [[NSDictionary alloc] init] (both empty)");
  RELEASE(d);
  k= [[NSData alloc] initWithBytes:"key1" length:4];
  o= [[NSData alloc] initWithBytes:"obj1" length:4];
  [c setObject:o forKey:k];
  ASSERT_OP(RETAINCOUNT(o), >=, 2, "values are retained, so the retain count must be greater or equal than %2$d, got %1$d");
  d= [[NSDictionary alloc] initWithObjects:&k forKeys:&k count:1];
  ASSERT_ISNOTEQUAL(c, d, "c & d aren't equals");
  m= [d mutableCopy]; RELEASE(d); [m setObject:o forKey:k]; d= [m copy]; RELEASE(m);
  ASSERT_OP(RETAINCOUNT(o), >=, 3, "values are retained, so the retain count must be greater or equal than %2$d, got %1$d");
  ASSERT_ISEQUAL(c, d, "c & d are now equals");
  m= [d mutableCopy];
  RELEASE(d);
  x= [[NSMutableData alloc] initWithBytes:"a key" length:5];
  RELEASE(x);
  x= [[NSMutableData alloc] initWithBytes:"a key" length:5];
  [m setObject:o forKey:x];
  ASSERT_EQUALS([m count], 2, "m contains %2$d values, got %1$d");
  ASSERT_ISNOTEQUAL(c, m, "c & m aren't equals");
  [m removeObjectForKey:x];
  ASSERT_ISEQUAL(c, m, "c & m are now equals");
  for (i= 0; i<100; i++) {
    MSByte b[1] = {i};
    [x appendBytes:b length:1];
    [m setObject:o forKey:x];}
  ASSERT_EQUALS(RETAINCOUNT(o), 103, "values are retained, so the retain count must increase to %2$d, got %1$d");
  RELEASE(x);
  RELEASE(c);
  ASSERT_EQUALS(RETAINCOUNT(m), 1, "m is still alive");
  RELEASE(m);
  ASSERT_EQUALS(RETAINCOUNT(k), 1, "k is still alive");
  ASSERT_EQUALS(RETAINCOUNT(o), 1, "o is still alive");
  RELEASE(k);
  RELEASE(o);
  return err;
}

static int nsdictionary_init(void)
{
  NSDictionary *o;
  NSDictionary *d, *d2;
  o= [NSDictionary dictionaryWithObjectsAndKeys:@"obj1", @"key1", @"obj2", @"key2", nil];
  d= [NSDictionary dictionaryWithDictionary:o];
  ASSERT_ISEQUAL([d objectForKey:@"key1"], @"obj1", "dictionary are equals");
  ASSERT_ISEQUAL([d objectForKey:@"key2"], @"obj2", "dictionary are equals");
  ASSERT_ISEQUAL([o objectForKey:@"key1"], @"obj1", "dictionary are equals");
  ASSERT_ISEQUAL([o objectForKey:@"key2"], @"obj2", "dictionary are equals");
  ASSERT_EQUALS([d count], [o count], "dictionary are equals");
  ASSERT([d isEqual:o], "dictionary are equals");
  ASSERT([o isEqual:d], "dictionary are equals");
  
  d2= [NSDictionary dictionaryWithDictionary:d];
  ASSERT_EQUALS([d2 count], [o count], "dictionary are equals");
  ASSERT([d2 isEqual:o], "dictionary are equals");
  ASSERT([o isEqual:d2], "dictionary are equals");
  ASSERT([d2 isEqual:d], "dictionary are equals");
  ASSERT([d isEqual:d2], "dictionary are equals");
  return 0;
}

static int nsdictionary_enum(void)
{
  NSDictionary *c,*d; id ks[1000],os[1000],k,o; int i,n,fdk, fdo; NSEnumerator *ke, *oe;
  k= [[NSMutableData alloc] initWithBytes:"a key" length:5];
  o= [[NSMutableData alloc] initWithBytes:"an object" length:9];
  for (i=0; i<1000; i++) {
    MSByte b[1] = {i};
    [k appendBytes:b length:1]; ks[i]= COPY(k);
    [o appendBytes:b length:1]; os[i]= COPY(o);}
  RELEASE(k);
  RELEASE(o);
  d= [[NSDictionary alloc] initWithObjects:os forKeys:ks count:1000];
  ASSERT_EQUALS([d count], 1000, "%2$d objects were inserted, got %1$d");
  c= [d copy];
  RELEASE(d);
  d= [c copy];
  RELEASE(c);
  ke= [d keyEnumerator];
  oe= [d objectEnumerator];
  o= [oe nextObject];
  k= [ke nextObject];
  for (n= 0, fdk= 0, fdo= 0; o && k; n++) {
    ASSERT_ISEQUAL(o, [d objectForKey:k], "same object from different sources");
    for (i= 0; i<1000; i++) {
      if (ISEQUAL(k, ks[i])) fdk++;
      if (ISEQUAL(o, os[i])) fdo++;}
    ASSERT_EQUALS(fdk, n+1, "one and no more key must matches k");
    ASSERT_EQUALS(fdo, n+1, "one and no more object must matches o");
    o= [oe nextObject];
    k= [ke nextObject];}
  ASSERT_EQUALS(n, 1000, "d contains %2$d objects, iterated over %1$d");
  ASSERT_EQUALS(o, nil, "No more object");
  ASSERT_EQUALS(k, nil, "No more key");
  
  for (i= 0; i<1000; i++) {
    RELEASE(ks[i]); RELEASE(os[i]);}
  RELEASE(d);
  return 0;
}

TEST_FCT_BEGIN(NSDictionary)
  int err=0;
  NEW_POOL;
  err+= nsdictionary_create();
  err+= nsdictionary_init();
  err+=nsdictionary_enum();
  KILL_POOL;
  return err;
TEST_FCT_END(NSDictionary)

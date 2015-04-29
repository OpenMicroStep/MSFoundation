// msfoundation_dictionary_validate.m, ecb, 130911

#include "msfoundation_validate.h"

static void dictionary_create(test_t *test)
  {
  MSDictionary *c,*m; MSDictionary *d; id k,o,x; int i;
  c= [MSDictionary new];
  d= [[MSDictionary alloc] init];
  TASSERT_EQUALS(test, RETAINCOUNT(c), 1, "A1 Bad retain count: %lu",WLU(RETAINCOUNT(c)));
  TASSERT_EQUALS(test, RETAINCOUNT(d), 1, "A2 Bad retain count: %lu",WLU(RETAINCOUNT(d)));
  TASSERT(test, [c isEqual:d], "A3 c & d are not equals");
  RELEASE(d);
  k= [[MSBuffer alloc] initWithBytes:"key1" length:4];
  o= [[MSBuffer alloc] initWithBytes:"obj1" length:4];
  [c setObject:o forKey:k];
  // k copied but immutable => retained
  TASSERT_EQUALS(test, RETAINCOUNT(k), 2, "A10 Bad retain count: %lu",WLU(RETAINCOUNT(k)));
  TASSERT_EQUALS(test, RETAINCOUNT(o), 2, "A11 Bad retain count: %lu",WLU(RETAINCOUNT(o)));
//d= [MSDictionary new]; [d setObject:k forKey:k];
//d= [[MSDictionary alloc] initWithObject:k forKey:k];
  d= [[MSDictionary alloc] initWithObjects:&k forKeys:&k count:1];
  TASSERT_EQUALS(test, RETAINCOUNT(d), 1, "A12 Bad retain count: %lu",WLU(RETAINCOUNT(d)));
  TASSERT_EQUALS(test, RETAINCOUNT(k), 4, "A13 Bad retain count: %lu",WLU(RETAINCOUNT(k)));
  TASSERT(test, ![c isEqual:d], "A14 c & d are equals");
  m= [d mutableCopy]; RELEASE(d); [m setObject:o forKey:k]; d= [m copy]; RELEASE(m);
  TASSERT_EQUALS(test, RETAINCOUNT(k), 3, "A15 Bad retain count: %lu",WLU(RETAINCOUNT(k)));
  TASSERT_EQUALS(test, RETAINCOUNT(o), 3, "A16 Bad retain count: %lu",WLU(RETAINCOUNT(o)));
  TASSERT(test, [c isEqual:d], "A17 c & d are not equals");
  m= [d mutableCopy];
  RELEASE(d);
  x= [[MSBuffer alloc] mutableInitWithBytes:"a key" length:5];
  [m setObject:o forKey:x];
  TASSERT_EQUALS(test, [m count], 2, "A20 Bad count: %lu",WLU([m count]));
  TASSERT(test, ![c isEqual:m], "A21 c & d are equals");
  [m removeObjectForKey:x];
  TASSERT(test, [c isEqual:m], "A22 c & d are not equals");
  for (i= 0; i<100; i++) {
    CBufferAppendByte((CBuffer*)x, (MSByte)i);
    [m setObject:o forKey:x];}
  TASSERT_EQUALS(test, RETAINCOUNT(o), 103, "A23 Bad retain count: %lu",WLU(RETAINCOUNT(o)));
//printf("1\n");
  RELEASE(x);
  RELEASE(c);
  TASSERT_EQUALS(test, RETAINCOUNT(m), 1, "A41 Bad retain count: %lu",WLU(RETAINCOUNT(m)));
  RELEASE(m);
  TASSERT_EQUALS(test, RETAINCOUNT(k), 1, "A42 Bad retain count: %lu",WLU(RETAINCOUNT(k)));
  TASSERT_EQUALS(test, RETAINCOUNT(o), 1, "A43 Bad retain count: %lu",WLU(RETAINCOUNT(o)));
  RELEASE(k);
  RELEASE(o);
  }

static void dictionary_enum(test_t *test)
  {
  MSDictionary *c,*d; id ks[1000],os[1000],k,o; int i,n,fd; MSDictionaryEnumerator *de;
  k= [[MSBuffer alloc] mutableInitWithBytes:"a key" length:5];
  o= [[MSBuffer alloc] mutableInitWithBytes:"an object" length:9];
  for (i=0; i<1000; i++) {
    CBufferAppendByte((CBuffer*)k, (MSByte)i); ks[i]= COPY(k);
    CBufferAppendByte((CBuffer*)o, (MSByte)i); os[i]= COPY(o);}
  RELEASE(k);
  RELEASE(o);
  d= [[MSDictionary alloc] initWithObjects:os forKeys:ks count:1000];
  TASSERT_EQUALS(test, [d count], 1000, "B1 Bad count: %lu",WLU([d count]));

  c= [d copy];
  RELEASE(d);
  d= [c copy];
  RELEASE(c);

  de= [d dictionaryEnumerator];
  for (n= 0, fd= 0; (o= [de nextObject]); n++) {
    k= [de currentKey];
    for (i= 0; i<1000; i++) {
      if (ISEQUAL(k, ks[i])) fd++;}
    TASSERT_EQUALS(test, fd, n+1, "B2 Bad fd: %lu %lu",WLI(fd),WLI(n));}
  TASSERT_EQUALS(test, n, 1000, "B3 Bad n: %lu",WLI(n));

  de= [d dictionaryEnumerator];
  for (n= 0, fd= 0; (k= [de nextKey]); n++) {
    o= [de currentObject];
    for (i= 0; i<1000; i++) {
      if (ISEQUAL(o, os[i])) fd++;}
    TASSERT_EQUALS(test, fd, n+1, "B4 Bad fd: %lu %lu",WLI(fd),WLI(n));}
  TASSERT_EQUALS(test, n, 1000, "B5 Bad n: %lu",WLI(n));

  for (i= 0; i<1000; i++) {
    RELEASE(ks[i]); RELEASE(os[i]);}
  RELEASE(d);
  }

static void dictionary_init(test_t *test)
  {
  NSDictionary *o;
  MSDictionary *d, *d2;
  o= [NSDictionary dictionaryWithObjectsAndKeys:@"obj1", @"key1", @"obj2", @"key2", nil];
  d= [MSDictionary dictionaryWithDictionary:o];
  TASSERT_ISEQUAL(test, [d objectForKey:@"key1"], @"obj1", "dictionary are equals");
  TASSERT_ISEQUAL(test, [d objectForKey:@"key2"], @"obj2", "dictionary are equals");
  TASSERT_ISEQUAL(test, [o objectForKey:@"key1"], @"obj1", "dictionary are equals");
  TASSERT_ISEQUAL(test, [o objectForKey:@"key2"], @"obj2", "dictionary are equals");
  TASSERT_EQUALS(test, [d count], [o count], "dictionary are equals");
  TASSERT(test, [d isEqual:o], "dictionary are equals");
  TASSERT(test, [o isEqual:d], "dictionary are equals");
  
  d2= [MSDictionary dictionaryWithDictionary:d];
  TASSERT_EQUALS(test, [d2 count], [o count], "dictionary are equals");
  TASSERT(test, [d2 isEqual:o], "dictionary are equals");
  TASSERT(test, [o isEqual:d2], "dictionary are equals");
  TASSERT(test, [d2 isEqual:d], "dictionary are equals");
  TASSERT(test, [d isEqual:d2], "dictionary are equals");
  }

test_t msfoundation_dictionary[]= {
  {"create",NULL,dictionary_create,INTITIALIZE_TEST_T_END},
  {"enum"  ,NULL,dictionary_enum  ,INTITIALIZE_TEST_T_END},
  {"init"  ,NULL,dictionary_init  ,INTITIALIZE_TEST_T_END},
  {NULL}
};

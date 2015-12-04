#import "foundation_validate.h"

static void dictionary_create(test_t *test)
{
  NSMutableDictionary *c,*m; NSDictionary *d; id k,o,x; int i;
  c= [NSMutableDictionary new];
  d= [[NSDictionary alloc] init];
  TASSERT(test, [c isKindOfClass:[NSMutableDictionary class]], "NSMutableDictionary is king of itself");
  TASSERT_EQUALS(test, RETAINCOUNT(c), 1, "[NSDictionary new] retain count must be %2$d, got %1$d");
// TODO: got 2 with COCOA. Why ?
//TASSERT_EQUALS(test, RETAINCOUNT(d), 1, "[[NSDictionary alloc] init] retain count must be %2$d, got %1$d");
  TASSERT_ISEQUAL(test, c, d, "[NSMutableDictionary new] is equal to [[NSDictionary alloc] init] (both empty)");
  RELEASE(d);
  k= [[NSData alloc] initWithBytes:"key1" length:4];
  o= [[NSData alloc] initWithBytes:"obj1" length:4];
  [c setObject:o forKey:k];
  TASSERT_OP(test, RETAINCOUNT(o), >=, 2, "values are retained, so the retain count must be greater or equal than %2$d, got %1$d");
  d= [[NSDictionary alloc] initWithObjects:&k forKeys:&k count:1];
  TASSERT_ISNOTEQUAL(test, c, d, "c & d aren't equals");
  m= [d mutableCopy]; RELEASE(d); [m setObject:o forKey:k]; d= [m copy]; RELEASE(m);
  TASSERT_OP(test, RETAINCOUNT(o), >=, 3, "values are retained, so the retain count must be greater or equal than %2$d, got %1$d");
  TASSERT_ISEQUAL(test, c, d, "c & d are now equals");
  m= [d mutableCopy];
  RELEASE(d);
  x= [[NSMutableData alloc] initWithBytes:"a key" length:5];
  RELEASE(x);
  x= [[NSMutableData alloc] initWithBytes:"a key" length:5];
  [m setObject:o forKey:x];
  TASSERT_EQUALS(test, [m count], 2, "m contains %2$d values, got %1$d");
  TASSERT_ISNOTEQUAL(test, c, m, "c & m aren't equals");
  [m removeObjectForKey:x];
  TASSERT_ISEQUAL(test, c, m, "c & m are now equals");
  for (i= 0; i<100; i++) {
    MSByte b[1] = {i};
    [x appendBytes:b length:1];
    [m setObject:o forKey:x];}
  TASSERT_EQUALS(test, RETAINCOUNT(o), 103, "values are retained, so the retain count must increase to %2$d, got %1$d");
  RELEASE(x);
  RELEASE(c);
  TASSERT_EQUALS(test, RETAINCOUNT(m), 1, "m is still alive");
  RELEASE(m);
  TASSERT_EQUALS(test, RETAINCOUNT(k), 1, "k is still alive");
  TASSERT_EQUALS(test, RETAINCOUNT(o), 1, "o is still alive");
  RELEASE(k);
  RELEASE(o);
}

static void dictionary_init(test_t *test)
{
  NSDictionary *o;
  NSDictionary *d, *d2;
  o= [NSDictionary dictionaryWithObjectsAndKeys:@"obj1", @"key1", @"obj2", @"key2", nil];
  d= [NSDictionary dictionaryWithDictionary:o];
  TASSERT_ISEQUAL(test, [d objectForKey:@"key1"], @"obj1", "dictionary are equals");
  TASSERT_ISEQUAL(test, [d objectForKey:@"key2"], @"obj2", "dictionary are equals");
  TASSERT_ISEQUAL(test, [o objectForKey:@"key1"], @"obj1", "dictionary are equals");
  TASSERT_ISEQUAL(test, [o objectForKey:@"key2"], @"obj2", "dictionary are equals");
  TASSERT_EQUALS(test, [d count], [o count], "dictionary are equals");
  TASSERT(test, [d isEqual:o], "dictionary are equals");
  TASSERT(test, [o isEqual:d], "dictionary are equals");

  d2= [NSDictionary dictionaryWithDictionary:d];
  TASSERT_EQUALS(test, [d2 count], [o count], "dictionary are equals");
  TASSERT(test, [d2 isEqual:o], "dictionary are equals");
  TASSERT(test, [o isEqual:d2], "dictionary are equals");
  TASSERT(test, [d2 isEqual:d], "dictionary are equals");
  TASSERT_S(test, d, isEqual:, d2, "%s != %s",[[d description] UTF8String],[[d2 description] UTF8String]);
}

static void dictionary_enum(test_t *test)
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
  TASSERT_EQUALS(test, [d count], 1000, "%2$d objects were inserted, got %1$d");
  c= [d copy];
  RELEASE(d);
  d= [c copy];
  RELEASE(c);
  ke= [d keyEnumerator];
  oe= [d objectEnumerator];
  o= [oe nextObject];
  k= [ke nextObject];
  for (n= 0, fdk= 0, fdo= 0; o && k; n++) {
    TASSERT_ISEQUAL(test, o, [d objectForKey:k], "same object from different sources");
    for (i= 0; i<1000; i++) {
      if (ISEQUAL(k, ks[i])) fdk++;
      if (ISEQUAL(o, os[i])) fdo++;}
    TASSERT_EQUALS(test, fdk, n+1, "one and no more key must matches k");
    TASSERT_EQUALS(test, fdo, n+1, "one and no more object must matches o");
    o= [oe nextObject];
    k= [ke nextObject];}
  TASSERT_EQUALS(test, n, 1000, "d contains %2$d objects, iterated over %1$d");
  TASSERT_EQUALS(test, o, nil, "No more object");
  TASSERT_EQUALS(test, k, nil, "No more key");

  for (i= 0; i<1000; i++) {
    RELEASE(ks[i]); RELEASE(os[i]);}
  RELEASE(d);
}

#pragma mark Subclass

@interface MyDict : NSDictionary
@end
@interface MyDictEnum : NSEnumerator
{ int _idx; }
@end

static id _k1= @"key 1";
static id _k2= @"key 2";
static id _o1= @"first object";
static id _o2= @"second object";
@implementation MyDict
- (NSUInteger)count
{ return 2; }
- (id)objectForKey:(id)k
{ return k==_k1 ? _o1 : k==_k2 ? _o2 : nil; }
- (NSEnumerator*)keyEnumerator
{ return [[[MyDictEnum alloc] init] autorelease]; }
@end
@implementation MyDictEnum
- (id)init
{ _idx= 0; return self; }
- (id)nextObject
{ _idx++; return _idx==1 ? _k1 : _idx==2 ? _k2 : nil; }
@end

static void _dictionary_subclass(test_t *test, Class cl)
{
  id o,d,e,x,y,m; int i;
  o= [[cl alloc] init];
  if (cl==[MyDict class]) TASSERT_EQUALS(test, [o count], 2, "count is %llu, expected %llu");
  d= [o description];
  x= @"{\n    \"key 1\" = \"first object\";\n    \"key 2\" = \"second object\";\n}"; // Cocoa
  y= @"{\n  key 1 = first object\n  key 2 = second object\n}";
  TASSERT(test, [d isEqual:x] || [d isEqual:y], "%s",[d UTF8String]);
  TASSERT_ISEQUAL(test, [o objectForKey:_k1], _o1, "%s != %s",[[o objectForKey:_k1] UTF8String],"first object");
  TASSERT_ISEQUAL(test, [o objectForKey:_k2], _o2, "%s != %s",[[o objectForKey:_k2] UTF8String],"second object");
  e= [o keyEnumerator];
  for (i= 0; (x= [e nextObject]); i++) {
    TASSERT_ISEQUAL(test, x, (i==0?_k1:_k2), "%s %d",[x UTF8String],i);}
  m= [MSDictionary dictionaryWithObjectsAndKeys:_o1,_k1,_o2,_k2,nil];
  TASSERT_ISEQUAL(test, o, m, "%s != %s",[o UTF8String],[m UTF8String]);
  TASSERT_ISEQUAL(test, m, o, "%s != %s",[m UTF8String],[o UTF8String]);
  RELEASE(o);
}

static void dictionary_subclass(test_t *test)
{
  _dictionary_subclass(test, [MyDict class]);
}

@implementation NSDictionary (NSDictionaryTestsCategory)
- (NSString *)myCustomSelectorOnNSDictionary
{
  return @"SelectorOnNSDictionary";
}
@end
@implementation NSMutableDictionary (NSDictionaryTestsCategory)
- (NSString *)myCustomSelectorOnNSMutableDictionary
{
  return @"SelectorOnNSMutableDictionary";
}
@end
static void dictionary_category(test_t *test)
{
  NEW_POOL;
  NSDictionary *dictStatic= [[NSDictionary dictionaryWithObjectsAndKeys:@"o1", @"k1", @"o2", @"k2", nil] copy];
  NSMutableDictionary *dictMutable= [dictStatic mutableCopy];

  TASSERT_EQUALS_OBJ(test, [dictStatic myCustomSelectorOnNSDictionary], @"SelectorOnNSDictionary");
  TASSERT_EQUALS_OBJ(test, [dictMutable myCustomSelectorOnNSDictionary], @"SelectorOnNSDictionary");
  TASSERT_EQUALS_OBJ(test, [dictMutable myCustomSelectorOnNSMutableDictionary], @"SelectorOnNSMutableDictionary");

  RELEASE(dictStatic);
  RELEASE(dictMutable);
  KILL_POOL;
}

testdef_t foundation_dictionary[]= {
  {"create"  ,NULL,dictionary_create  },
  {"init"    ,NULL,dictionary_init    },
  {"enum"    ,NULL,dictionary_enum    },
  {"subclass",NULL,dictionary_subclass},
  {"category",NULL,dictionary_category},
  {NULL}};

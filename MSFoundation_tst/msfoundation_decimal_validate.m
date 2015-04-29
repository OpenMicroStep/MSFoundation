// msfoundation_decimal_validate.m, ecb, 130911

#include "msfoundation_validate.h"

static void decimal_create(test_t *test)
  {
  MSDecimal *c,*d,*e,*f;
  c= MSCreateObjectWithClassIndex(CDecimalClassIndex);
  m_apm_init((CDecimal*)c);
  d= [[MSDecimal alloc] initWithLongLong:0LL];
  TASSERT_EQUALS(test, RETAINCOUNT(c), 1, "A1 Bad retain count: %lu",WLU(RETAINCOUNT(c)));
  TASSERT_EQUALS(test, RETAINCOUNT(d), 1, "A2 Bad retain count: %lu",WLU(RETAINCOUNT(d)));
  TASSERT(test, [c isEqualToDecimal:d], "A3 c & d are not equals");
  RELEASE(c);
  RELEASE(d);
  c= [[MSDecimal alloc] initWithUTF8String:"3.14"];
  d= [[MSDecimal alloc] initWithDouble:3.14];
//decimal_print(c);
//decimal_print(d);
  TASSERT_EQUALS(test, RETAINCOUNT(c), 1, "A5 Bad retain count: %lu",WLU(RETAINCOUNT(c)));
  TASSERT_EQUALS(test, RETAINCOUNT(d), 1, "A6 Bad retain count: %lu",WLU(RETAINCOUNT(d)));
  TASSERT(test, [c isEqualToDecimal:d], "A7 c & d are not equals");
  e= [[MSDecimal alloc] initWithLongLong:3LL];
  TASSERT(test, ![d isEqualToDecimal:e], "A8 d & e are equals");
  f= RETAIN([d floorDecimal]);
  TASSERT(test, [e isEqual:f], "A9 e & f are not equals");
  RELEASE(c);
  RELEASE(d);
  RELEASE(e);
  RELEASE(f);
  }

static void decimal_op(test_t *test)
  {
  int i; MSDecimal *c[10],*d;
  c[0]= [[MSDecimal alloc] initWithUTF8String:"3."];
  c[1]= [[MSDecimal alloc] initWithUTF8String:"3.1"];
  c[2]= [[MSDecimal alloc] initWithUTF8String:"3.14"];
  c[3]= [[MSDecimal alloc] initWithUTF8String:"3.141"];
  c[4]= [[MSDecimal alloc] initWithUTF8String:"3.1415"];
  c[5]= [[MSDecimal alloc] initWithUTF8String:"3.14159"];
  c[6]= [[MSDecimal alloc] initWithUTF8String:"3.141592"];
  c[7]= [[MSDecimal alloc] initWithUTF8String:"3.1415926"];
  c[8]= [[MSDecimal alloc] initWithUTF8String:"3.14159265"];
  c[9]= [[MSDecimal alloc] initWithUTF8String:"3.141592653"];
  for (i=1; i<10; i++) {
    d= [MSD_PI decimalByDividingBy:MSD_One decimalPlaces:i-1]; // TODO: look why -1
    TASSERT(test, [c[i] isEqual:d], "B1-%d c & d are not equals %s %s",i,
      [[c[i] description] UTF8String],[[d description] UTF8String]);}
  for (i=0; i<10; i++) RELEASE(c[i]);
  }

test_t msfoundation_decimal[]= {
  {"create",NULL,decimal_create,INTITIALIZE_TEST_T_END},
  {"op"    ,NULL,decimal_op    ,INTITIALIZE_TEST_T_END},
  {NULL}
};

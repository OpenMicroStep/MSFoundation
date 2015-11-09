// mscore_ccouple_validate.c, ecb, 130911

#include "mscore_validate.h"

static void ccouple_create(test_t *test)
  {
  CCouple *c,*d,*e, *f;
  c= CCreateCouple(  nil,  nil);
  d= CCreateCouple((id)c,  nil);
  e= CCreateCouple((id)c,(id)d);
  f= CCreateCouple((id)c,(id)d);

  TASSERT_EQUALS(test, RETAINCOUNT(c), 4, "A1-Bad retain count: %lu",WLU(RETAINCOUNT(c)));
  TASSERT_EQUALS(test, RETAINCOUNT(d), 3, "A2-Bad retain count: %lu",WLU(RETAINCOUNT(d)));
  TASSERT(test, !CCoupleEquals(c, d), "A3-c & d are equals");
  TASSERT(test, !CCoupleEquals(d, e), "A4-d & e are equals");
  TASSERT(test, CCoupleEquals(e, f), "f & e are equals");
  TASSERT(test, CCoupleEquals(f, e), "f & e are equals");
  TASSERT_ISEQUAL(test, CCoupleFirstMember(d), c, "A5-MSC1(d) & c not equals");
  TASSERT_ISEQUAL(test, d, CCoupleSecondMember(e), "A6-d & CCoupleSecondMember(e) not equals");

  CCoupleSetFirstMember(e, (id)d);
  TASSERT(test, !CCoupleEquals(f, e), "f & e are not equals anymore");
  TASSERT_EQUALS_PTR(test, CCoupleFirstMember(e), (id)d);
  TASSERT_EQUALS_PTR(test, CCoupleSecondMember(e), (id)d);
  TASSERT_EQUALS_LLD(test, RETAINCOUNT(c), 3);
  TASSERT_EQUALS_LLD(test, RETAINCOUNT(d), 4);

  CCoupleSetSecondMember(e, (id)c);
  TASSERT(test, !CCoupleEquals(f, e), "f & e are not equals anymore");
  TASSERT_EQUALS_PTR(test, CCoupleFirstMember(e), (id)d);
  TASSERT_EQUALS_PTR(test, CCoupleSecondMember(e), (id)c);
  TASSERT_EQUALS_LLD(test, RETAINCOUNT(c), 4);
  TASSERT_EQUALS_LLD(test, RETAINCOUNT(d), 3);

  CCoupleSetFirstMember(f, (id)d);
  CCoupleSetSecondMember(f, (id)c);
  TASSERT(test, CCoupleEquals(f, e), "f & e are equals again");

  RELEASE(c);RELEASE(d);RELEASE(e);RELEASE(f);
  }

static void ccouple_toarray(test_t *test)
{
  CCouple *c0,*c1,*c2; CArray *a0,*a1,*a2;
  c0= CCreateCouple(  nil,  nil);
  c1= CCreateCouple((id)c0,  nil);
  c2= CCreateCouple((id)c0,(id)c1);
  a0= CCreateArrayOfCoupleSubs((id)c0, nil);
  a1= CCreateArrayOfCoupleSubs((id)c1, nil);
  a2= CCreateArrayOfCoupleSubs((id)c2, nil);

  TASSERT_EQUALS_LLD(test, CArrayCount(a0), 0);

  TASSERT_EQUALS_LLD(test, CArrayCount(a1), 1);
  TASSERT_EQUALS_PTR(test, CArrayObjectAtIndex(a1, 0), (id)c0);

  TASSERT_EQUALS_LLD(test, CArrayCount(a2), 2);
  TASSERT_EQUALS_PTR(test, CArrayObjectAtIndex(a2, 0), (id)c0);
  TASSERT_EQUALS_PTR(test, CArrayObjectAtIndex(a2, 1), (id)c1);

  RELEASE(c0);RELEASE(c1);RELEASE(c2);
  RELEASE(a0);RELEASE(a1);RELEASE(a2);
}

test_t mscore_ccouple[]= {
  {"create"  ,NULL,ccouple_create,INTITIALIZE_TEST_T_END},
  {"toarray" ,NULL,ccouple_toarray,INTITIALIZE_TEST_T_END},
  {NULL}
};

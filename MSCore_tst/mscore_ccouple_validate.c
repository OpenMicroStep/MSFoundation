// mscore_ccouple_validate.c, ecb, 130911

#include "mscore_validate.h"

static void ccouple_create(test_t *test)
  {
  CCouple *c,*d,*e;
  c= CCreateCouple(  nil,  nil);
  d= CCreateCouple((id)c,  nil);
  e= CCreateCouple((id)c,(id)d);
  TASSERT_EQUALS(test, RETAINCOUNT(c), 3, "A1-Bad retain count: %lu",WLU(RETAINCOUNT(c)));
  TASSERT_EQUALS(test, RETAINCOUNT(d), 2, "A2-Bad retain count: %lu",WLU(RETAINCOUNT(d)));
  TASSERT(test, !CCoupleEquals(c, d), "A3-c & d are equals");
  TASSERT(test, !CCoupleEquals(d, e), "A4-d & e are equals");
  TASSERT_ISEQUAL(test, CCoupleFirstMember(d), c, "A5-MSC1(d) & c not equals");
  TASSERT_ISEQUAL(test, d, CCoupleSecondMember(e), "A6-d & CCoupleSecondMember(e) not equals");
  RELEASE(c);
  RELEASE(d);
  RELEASE(e);
  }

test_t mscore_ccouple[]= {
  {"create"  ,NULL,ccouple_create,INTITIALIZE_TEST_T_END},
  {NULL}
};

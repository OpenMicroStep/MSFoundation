// msfoundation_couple_validate.m, ecb, 130911

#include "msfoundation_validate.h"

static void couple_create(test_t *test)
  {
  MSCouple *c,*d,*e; id ds,x;
  c= MSCreateCouple(  nil,  nil);
  d= MSCreateCouple((id)c,  nil);
  TASSERT_EQUALS(test, RETAINCOUNT(c), 2, "A1-Bad retain count: %lu",WLU(RETAINCOUNT(c)));
  TASSERT_EQUALS(test, RETAINCOUNT(d), 1, "A2-Bad retain count: %lu",WLU(RETAINCOUNT(d)));
  e= MSCreateCouple((id)c,(id)d);
  TASSERT_EQUALS(test, RETAINCOUNT(c), 3, "A1'-Bad retain count: %lu",WLU(RETAINCOUNT(c)));
  TASSERT_EQUALS(test, RETAINCOUNT(d), 2, "A2'-Bad retain count: %lu",WLU(RETAINCOUNT(d)));
  TASSERT_ISNOTEQUAL(test, c, d, "A3-c & d are equals");
  TASSERT_ISNOTEQUAL(test, d, e, "A4-d & e are equals");
  TASSERT_ISEQUAL(test, [d firstMember], c, "A5-MSC1(d) & c not equals");
  TASSERT_ISEQUAL(test, d, [e secondMember], "A6-d & CCoupleSecondMember(e) not equals");
  ds= [d allObjects]; x= ARRAY c END;
  TASSERT_ISEQUAL(test, ds, x, "A7-d allObjects %s not equals c",[[ds description] UTF8String]);
  RELEASE(c);
  RELEASE(d);
  RELEASE(e);
  }

test_t msfoundation_couple[]= {
  {"create",NULL,couple_create,INTITIALIZE_TEST_T_END},
  {NULL}
};

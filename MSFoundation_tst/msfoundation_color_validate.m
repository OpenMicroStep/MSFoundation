// msfoundation_color_validate.m, ecb, 130911

#include "msfoundation_validate.h"

static void color_create(test_t *test)
  {
  MSColor *c1,*c2,*c3;
  c1= MSCreateColor(0xf0f8ffff);
  TASSERT_EQUALS(test, RETAINCOUNT(c1), 1, "A1-Bad retain count: %lu",WLU(RETAINCOUNT(c1)));
  c2= MSAliceBlue;
  TASSERT_EQUALS(test, RETAINCOUNT(c2), 1, "A2-Bad retain count: %lu",WLU(RETAINCOUNT(c2)));
  c3= MSYellowGreen;
  TASSERT_EQUALS(test, RETAINCOUNT(c3), 1, "A3-Bad retain count: %lu",WLU(RETAINCOUNT(c3)));
  TASSERT_EQUALS(test, [c1 red], [c2 red], "A4-Bad red: %u %u",[c1 red],[c2 red]);
  TASSERT_EQUALS(test, [c1 green], [c2 green], "A5-Bad green: %u %u",[c1 green],[c2 green]);
  TASSERT_EQUALS(test, [c1 blue], [c2 blue], "A6-Bad blue: %u %u",[c1 blue],[c2 blue]);
  TASSERT_EQUALS(test, [c1 opacity], [c2 opacity], "A7-Bad opacity: %u %u",[c1 opacity],[c2 opacity]);
  TASSERT_ISEQUAL(test, c1, c2, "A8-Bad equals: %u %u",[c1 rgbaValue],[c2 rgbaValue]);
  TASSERT_ISNOTEQUAL(test, c1, c3, "A9-Bad equals: %u %u",[c1 rgbaValue],[c3 rgbaValue]);
  RELEASE(c1);
  RELEASE(c2);
  RELEASE(c3);
  }

testdef_t msfoundation_color[]= {
  {"create",NULL,color_create},
  {NULL}
};

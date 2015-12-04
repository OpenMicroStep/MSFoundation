// mscore_ccolor_validate.c, ecb, 130911

#include "mscore_validate.h"

static void ccolor_create(test_t *test)
  {
  CColor *c,*d;
  c= CCreateColor(  0, 100, 200, 255);
  d= CCreateColor(249, 217, 178,   0);
  TASSERT_EQUALS(test, RETAINCOUNT(c), 1, "A1-Bad retain count: %lu",WLU(RETAINCOUNT(c)));
  TASSERT_EQUALS(test, RETAINCOUNT(d), 1, "A2-Bad retain count: %lu",WLU(RETAINCOUNT(d)));
  TASSERT(test, !CColorIsPale(c), "A3-c is pale: %f",CColorLuminance(c));
  TASSERT(test, CColorIsPale(d), "A4-d is not pale: %f",CColorLuminance(d));
  TASSERT(test, !CColorIsEqual((id)c,(id)d), "A5-c and d are equals");
  TASSERT_EQUALS(test, CColorsCompare(c,d), NSOrderedAscending, "A6-c and d are not ascending");
  RELEASE(d);
  d= (CColor*)CColorCopy((id)c);
  TASSERT(test, CColorIsEqual((id)c,(id)d), "A7-c and d are NOT equals");
  TASSERT_EQUALS(test, CColorsCompare(c,d), NSOrderedSame, "A8-c and d are not same");
  TASSERT_EQUALS(test, CColorRedValue(c), 0, "A11-r %d",CColorRedValue(c));
  TASSERT_EQUALS(test, CColorGreenValue(c), 100, "A11-r %d",CColorGreenValue(c));
  TASSERT_EQUALS(test, CColorBlueValue(c), 200, "A11-r %d",CColorBlueValue(c));
  TASSERT_EQUALS(test, CColorOpacityValue(c), 255, "A11-r %d",CColorOpacityValue(c));
  TASSERT_EQUALS(test, CColorTransparencyValue(c), 0, "A11-r %d",CColorTransparencyValue(c));
  RELEASE(c);
  RELEASE(d);
  }

testdef_t mscore_ccolor[]= {
  {"create"  ,NULL,ccolor_create},
  {NULL}
};

// mscore_c_validate.c, ecb, 130911

#include "mscore_validate.h"

static int c_isa_for(CClassIndex classIndex)
{
  int err= 0;
  id x,y;
  x= (id)MSCreateObjectWithClassIndex(classIndex);
  y= COPY(x);
  ASSERT_EQUALS(RETAINCOUNT(x), 1, "A1-Bad retain count: %lu != %lu");
  ASSERT_EQUALS(RETAINCOUNT(y), 1, "A2-Bad retain count: %lu != %lu");
  ASSERT_ISEQUAL(x, y, "A3-Bad equal");
  ASSERT(ISA(x), "A4-Bad isa");
  ASSERT_ISEQUAL(ISA(x), ISA(y), "A5-Bad isa equal");
  ASSERT(NAMEOFCLASS(x), "A6-Bad nameof");
  ASSERT(strcmp(NAMEOFCLASS(x), NAMEOFCLASS(y)) == 0, "A7-Bad class name equal");
  RELEASE(x);
  RELEASE(y);
  return err;
}

static int c_classEqual(void)
{
  int err= 0;
  id x,y;
  x= (id)MSCreateObjectWithClassIndex(CArrayClassIndex);
  y= (id)MSCreateObjectWithClassIndex(CBufferClassIndex);
  ASSERT_ISNOTEQUAL(ISA(x), ISA(y), "B1-Bad isa equal");
  RELEASE(x);
  RELEASE(y);
  return err;
}

static int c_isa()
{
  int err= 0;
  err+= c_isa_for(CArrayClassIndex);
  err+= c_isa_for(CBufferClassIndex);
  return err;
}

test_t mscore_c[]= {
  {"isa"     ,NULL,c_isa        ,INTITIALIZE_TEST_T_END},
  {"isEqual" ,NULL,c_classEqual ,INTITIALIZE_TEST_T_END},
  {NULL}
};

// mscore_c_validate.c, ecb, 130911

#include "mscore_validate.h"

static void c_isa_for(test_t *test, CClassIndex classIndex)
{
  id x,y;
  x= (id)MSCreateObjectWithClassIndex(classIndex);
  y= COPY(x);
  TASSERT_EQUALS( test, RETAINCOUNT(x), 1, "A1-classIndex %d %s Bad retain count: %lu != %lu",classIndex,test->name);
  TASSERT_EQUALS( test, RETAINCOUNT(x), 1, "A1-Bad retain count: %lu != %lu");
  TASSERT_EQUALS( test, RETAINCOUNT(y), 1, "A2-Bad retain count: %lu != %lu");
  TASSERT_ISEQUAL(test, x, y, "A3-Bad equal");
  TASSERT(        test, ISA(x), "A4-Bad isa");
  TASSERT_ISEQUAL(test, ISA(x), ISA(y), "A5-Bad isa equal");
  TASSERT(        test, NAMEOFCLASS(x), "A6-Bad nameof");
  TASSERT(        test, strcmp(NAMEOFCLASS(x), NAMEOFCLASS(y)) == 0, "A7-Bad class name equal");
  RELEASE(x);
  RELEASE(y);
}

static void c_isa(test_t *test)
{
  c_isa_for(test, CArrayClassIndex);
  c_isa_for(test, CBufferClassIndex);
}

static void c_classEqual(test_t *test)
{
  id x,y,z;
  x= (id)MSCreateObjectWithClassIndex(CArrayClassIndex);
  y= (id)MSCreateObjectWithClassIndex(CArrayClassIndex);
  z= (id)MSCreateObjectWithClassIndex(CBufferClassIndex);
  TASSERT_ISEQUAL(   test, ISA(x), ISA(y), "B1-Bad isa equal");
  TASSERT_ISNOTEQUAL(test, ISA(x), ISA(z), "B2-Bad isa equal");
  RELEASE(x);
  RELEASE(y);
  RELEASE(z);
}

static void c_msg(test_t *test)
{
  CMessageAdvise(CMessageAnalyse    , CTXF, "message %d", 7);
//CMessageAdvise(CMessageInformation, CTXF, "message %d", 8);
//CMessageAdvise(CMessageWarning,     CTXF, "message %d", 9);
//CMessageAdvise(CMessageFatalError,  CTXF, "message %d", 1);
}

test_t mscore_c[]= {
  {"isa"        ,NULL,c_isa        ,INTITIALIZE_TEST_T_END},
  {"classEqual" ,NULL,c_classEqual ,INTITIALIZE_TEST_T_END},
  {"msg"        ,NULL,c_msg        ,INTITIALIZE_TEST_T_END},
  {NULL}
};

// mscore_tools_validate.c, ecb, 130911

#include "mscore_validate.h"

//http://www.fileformat.info/tool/hash.htm?text=A
//http://www.statman.info/conversions/hexadecimal.html
static inline void crc(test_t *test, char *txt, MSUInt r)
  {
  MSUInt crc;
  crc= MSBytesLargeCRC(txt, strlen(txt));
  TASSERT_EQUALS(test, crc, r, "A1-Bad crc. Expected:%3$u Calculated:%2$u for %1$s",txt);
  }

static void tools_crc(test_t *test)
  {
  crc(test, "A",3554254475U);
  crc(test, "[\"MSTE0101\",5,\"CRC00000000\",0,0]",945492452U);
  }

testdef_t mscore_tools[]= {
  {"crc",NULL,tools_crc},
  {NULL}
};

// mscore_tools_validate.c, ecb, 130911

#include "mscore_validate.h"

//http://www.fileformat.info/tool/hash.htm?text=A
//http://www.statman.info/conversions/hexadecimal.html
static inline int crc(char *txt, MSUInt r)
  {
  int err= 0;
  MSUInt crc;
  crc= MSBytesLargeCRC(txt, strlen(txt));
  err+= ASSERT_EQUALS(crc, r, "A1-Bad crc. Expected:%3$u Calculated:%2$u for %1$s",txt);
  return err;
  }

static int tools_crc(void)
  {
  int err= 0;
  err+= crc("A",3554254475U);
  err+= crc("[\"MSTE0101\",5,\"CRC00000000\",0,0]",945492452U);
  return err;
  }

test_t mscore_tools[]= {
  {"crc",NULL,tools_crc,INTITIALIZE_TEST_T_END},
  {NULL}
};

// mscore_tools_validate.c, ecb, 130911

#include "mscore_validate.h"

//http://www.fileformat.info/tool/hash.htm?text=A
//http://www.statman.info/conversions/hexadecimal.html
static inline int crc(char *txt, MSUInt r)
  {
  int err= 0;
  MSUInt crc;
  crc= MSBytesLargeCRC(txt, strlen(txt));
  if (crc!=r) {
    fprintf(stdout, "A1-Bad crc. Expected:%u Calculated:%u %s\n",r,crc,txt);
    err++;}
  return err;
  }

int mscore_tools_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  err+= crc("A",3554254475U);
  err+= crc("[\"MSTE0101\",5,\"CRC00000000\",0,0]",945492452U);

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","Tools",(err?"FAIL":"PASS"),seconds);
  return err;
  }

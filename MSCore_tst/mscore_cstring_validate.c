// mscore_cstring_validate.c, ecb, 130911

#include "mscore_validate.h"

static void unichar_test(test_t *test)
  {
  int r;
  CString *a;
  CBuffer *b;
  char *s,c1,c2; NSUInteger l,i,usn; unichar us[20],u1,u2; SES ses;
  
  a= CCreateString(0);
  s= "éèàô"; l= strlen(s);
  CStringAppendBytes(a, NSUTF8StringEncoding, s, l);
  ses= MSMakeSESWithBytes(s, l, NSUTF8StringEncoding);
  for (usn= i= 0; i<l;) us[usn++]= SESIndexN(ses, &i);
  i= 0; u1= CStringCharacterAtIndex(a, 0); u2= us[0];
  TASSERT_EQUALS(test, u1, u2, "A1 Bad equal: %hu %hu",u1,u2);
  TASSERT(test, CUnicharEquals(u1,u2,NO), "A2 Bad equal: %hu %hu",u1,u2);
  u1= 101; // e
  TASSERT(test, !CUnicharEquals(u1,u2, NO), "A3 Bad equal: %hu %hu",u1,u2); // e != é
  TASSERT(test, !CUnicharEquals(u1,u2,YES), "A4 Bad equal: %hu %hu",u1,u2); // e !insensitive= é
  u1= CUnicharToUpper(233); // 201 É
  TASSERT(test,  CUnicharEquals(u1,u2,YES), "A5 Bad equal: %hu %hu",u1,u2); // É insensitive= é
  TASSERT(test,  CUnicharsInsensitiveEquals(a->buf,CStringLength(a),us,usn), "A6 Bad equal: %hu %hu",u1,u2);
  RELEASE(a);
  s= "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫"; l= strlen(s);
  a= CCreateStringWithBytes(NSUTF8StringEncoding, s, l);
  us[0]= 233; us[1]= 232; us[2]= 224; us[3]= 244; us[4]= 161;
  us[5]= 174; us[6]= 339; us[7]= 177; us[8]= 256; us[9]= 1023;
  us[10]= 7680; us[11]= 9471; us[12]= 10495; us[13]= 12991; us[14]= 65131;
  usn= 15;
  TASSERT(test, CUnicharsInsensitiveEquals(a->buf,CStringLength(a),us,usn), "A7 Bad equal: %s",s);
  for (i= 0; i<usn; i++) {
    u1= CStringCharacterAtIndex(a, i);
    TASSERT_EQUALS(test, CStringIndexOfCharacter(a,u1), i, "A7 Bad index: %lu %hu",i,u1);}
  b= CCreateBuffer(0);
  CBufferAppendString(b, a, NSUTF8StringEncoding);
  for (i= 0; i<l; i++) {
    c1= s[i]; c2= (char)CBufferByteAtIndex(b,i);
    u1= CStringCharacterAtIndex(a, i);
    TASSERT_EQUALS(test, c1, c2, "A8 Bad index: %hhu %hhu",c1,c2);}
  TASSERT_EQUALS(test, (r= strncmp(s, (char*)(b->buf), l)), 0, "A9 Bad equal: %s %s %d",s,CBufferCString(b),r);
  RELEASE(b);
  RELEASE(a);
  }
/*
static inline void cstring_print(CString *d)
  {
  }
*/
static void cstring_create(test_t *test)
  {
  CString *c,*d;
  unsigned char cs[10];
  c= (CString*)MSCreateObjectWithClassIndex(CStringClassIndex);
  d= CCreateString(0);
  TASSERT_EQUALS(test, RETAINCOUNT(c), 1, "B1 Bad retain count: %lu",WLU(RETAINCOUNT(c)));
  TASSERT_EQUALS(test, RETAINCOUNT(d), 1, "B2 Bad retain count: %lu",WLU(RETAINCOUNT(d)));
  TASSERT(test, CStringEquals(c, d), "B3 c & d are not equals");
  CStringAppendCharacter(c, 60);
  CStringAppendCharacterSuite(d, 60, 1);
  TASSERT(test, CStringEquals(c, d), "B4 c & d are not equals");
  CStringAppendCharacterSuite(c, 161, 2);
  cs[0]= cs[1]= 193; // 0xC1 ¡
  CStringAppendBytes(d, NSMacOSRomanStringEncoding, cs, 2);
  TASSERT(test, CStringEquals(c, d), "B5 c & d are not equals");
  RELEASE(d);
  RELEASE(c);
  }

test_t mscore_cstring[]= {
  {"unichar",NULL,unichar_test  ,INTITIALIZE_TEST_T_END},
  {"create" ,NULL,cstring_create,INTITIALIZE_TEST_T_END},
  {NULL}
};

// mscore_cstring_validate.c, ecb, 130911

#include "mscore_validate.h"

static int unichar_test(void)
  {
  int err= 0,r;
  CString *a;
  CBuffer *b;
  char *s,c1,c2; NSUInteger l,i,usn; unichar us[20],u1,u2; SES ses;
  
  a= CCreateString(0);
  s= "éèàô"; l= strlen(s);
  CStringAppendBytes(a, NSUTF8StringEncoding, s, l);
  ses= MSMakeSESWithBytes(s, l, NSUTF8StringEncoding);
  for (usn= i= 0; i<l;) us[usn++]= SESIndexN(ses, &i);
  i= 0; u1= CStringCharacterAtIndex(a, 0); u2= us[0];
  if (u1 != u2) {
    fprintf(stdout, "A1 Bad equal: %hu %hu\n",u1,u2); err++;}
  if (!CUnicharEquals(u1,u2,NO)) {
    fprintf(stdout, "A2 Bad equal: %hu %hu\n",u1,u2); err++;}
  u1= 101; // e
  if (CUnicharEquals(u1,u2,NO)) { // e != é
    fprintf(stdout, "A3 Bad equal: %hu %hu\n",u1,u2); err++;}
  if (CUnicharEquals(u1,u2,YES)) { // e !insensitive= é
    fprintf(stdout, "A4 Bad equal: %hu %hu\n",u1,u2); err++;}
  u1= CUnicharToUpper(233); // 201 É
  if (!CUnicharEquals(u1,u2,YES)) { // É insensitive= é
    fprintf(stdout, "A5 Bad equal: %hu %hu\n",u1,u2); err++;}
  if (!CUnicharsInsensitiveEquals(a->buf,CStringLength(a),us,usn)) {
    fprintf(stdout, "A6 Bad equal: %hu %hu\n",u1,u2); err++;}
  RELEASE(a);
  s= "éèàô¡®œ±ĀϿḀ⓿⣿㊿﹫"; l= strlen(s);
  a= CCreateStringWithBytes(NSUTF8StringEncoding, s, l);
  us[0]= 233; us[1]= 232; us[2]= 224; us[3]= 244; us[4]= 161;
  us[5]= 174; us[6]= 339; us[7]= 177; us[8]= 256; us[9]= 1023;
  us[10]= 7680; us[11]= 9471; us[12]= 10495; us[13]= 12991; us[14]= 65131;
  usn= 15;
  if (!CUnicharsInsensitiveEquals(a->buf,CStringLength(a),us,usn)) {
    fprintf(stdout, "A7 Bad equal: %s\n",s); err++;}
  for (i= 0; i<usn; i++) {
    u1= CStringCharacterAtIndex(a, i);
    if (CStringIndexOfCharacter(a,u1)!=i) {
      fprintf(stdout, "A7 Bad index: %lu %hu\n",i,u1); err++;}}
  b= CCreateBuffer(0);
  CBufferAppendString(b, a, NSUTF8StringEncoding);
  for (i= 0; i<l; i++) {
    c1= s[i]; c2= (char)CBufferByteAtIndex(b,i);
    u1= CStringCharacterAtIndex(a, i);
    if (c1!=c2) {
      fprintf(stdout, "A8 Bad index: %hhu %hhu\n",c1,c2); err++;}}
  if ((r= strncmp(s, (char*)(b->buf), l))!=0) {
    fprintf(stdout, "A9 Bad equal: %s %s %d\n",s,CBufferCString(b),r); err++;}
  RELEASE(b);
  RELEASE(a);
  return err;
  }
/*
static inline void cstring_print(CString *d)
  {
  fprintf(stdout, "%lu\n",WLU(CStringLength(d)));
  }
*/
static int cstring_create(void)
  {
  int err= 0;
  CString *c,*d;
  unsigned char cs[10];
  c= (CString*)MSCreateObjectWithClassIndex(CStringClassIndex);
  d= CCreateString(0);
  if (RETAINCOUNT(c)!=1) {
    fprintf(stdout, "B1 Bad retain count: %lu\n",WLU(RETAINCOUNT(c))); err++;}
  if (RETAINCOUNT(d)!=1) {
    fprintf(stdout, "B2 Bad retain count: %lu\n",WLU(RETAINCOUNT(d))); err++;}
  if (!CStringEquals(c, d)) {
    fprintf(stdout, "B3 c & d are not equals\n"); err++;}
  CStringAppendCharacter(c, 60);
  CStringAppendCharacterSuite(d, 60, 1);
  if (!CStringEquals(c, d)) {
    fprintf(stdout, "B4 c & d are not equals\n"); err++;}
  CStringAppendCharacterSuite(c, 161, 2);
  cs[0]= cs[1]= 193; // 0xC1 ¡
  CStringAppendBytes(d, NSMacOSRomanStringEncoding, cs, 2);
  if (!CStringEquals(c, d)) {
    fprintf(stdout, "B5 c & d are not equals\n"); err++;}
  RELEASE(d);
  RELEASE(c);
  return err;
  }

test_t mscore_cstring[]= {
  {"unichar",NULL,unichar_test  ,INTITIALIZE_TEST_T_END},
  {"create" ,NULL,cstring_create,INTITIALIZE_TEST_T_END},
  {NULL}
};

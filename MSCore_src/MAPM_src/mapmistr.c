/*
 *   THIS FILE HAS BEEN MODIFIED FROM THE OFFICIAL MAPM DISTRIBUTION
 *   BY 'Herve Malaingre/Logitud Solutions' on 2013/06/18.
 *
 *   THIS FILE IS ORIGINALLY FROM MAPM VERSION 4.9.5.
 *
 *   This file is part of MicroStep/MSCore library & Microstep/MSFoundation framework
 *   The modifications are :
 
 *   1) added const to necessary function parameters
 */

/*
 *  M_APM  -  mapmistr.c
 *
 *  Copyright (C) 1999 - 2007   Michael C. Ring
 *
 *  Permission to use, copy, and distribute this software and its
 *  documentation for any purpose with or without fee is hereby granted,
 *  provided that the above copyright notice appear in all copies and
 *  that both that copyright notice and this permission notice appear
 *  in supporting documentation.
 *
 *  Permission to modify the software is granted. Permission to distribute
 *  the modified code is granted. Modifications are to be distributed by
 *  using the file 'license.txt' as a template to modify the file header.
 *  'license.txt' is available in the official MAPM distribution.
 *
 *  This software is provided "as is" without express or implied warranty.
 */

/*
 *      $Id: mapmistr.c,v 1.9 2007/12/03 01:55:27 mike Exp $
 *
 *      This file contains M_APM -> integer string function
 *
 *      $Log: mapmistr.c,v $
 *      Revision 1.9  2007/12/03 01:55:27  mike
 *      Update license
 *
 *      Revision 1.8  2003/07/21 20:37:09  mike
 *      Modify error messages to be in a consistent format.
 *
 *      Revision 1.7  2003/03/31 21:52:07  mike
 *      call generic error handling function
 *
 *      Revision 1.6  2002/11/03 22:28:02  mike
 *      Updated function parameters to use the modern style
 *
 *      Revision 1.5  2001/08/06 16:58:20  mike
 *      improve the new function
 *
 *      Revision 1.4  2001/08/05 23:18:48  mike
 *      fix function when input is not an integer but the
 *      number is close to rounding upwards (NNN.9999999999....)
 *
 *      Revision 1.3  2000/02/03 22:48:38  mike
 *      use MAPM_* generic memory function
 *
 *      Revision 1.2  1999/07/18 01:33:04  mike
 *      minor tweak to code alignment
 *
 *      Revision 1.1  1999/07/12 02:06:08  mike
 *      Initial revision
 */

#include "m_apm_lc.h"

/****************************************************************************/
void m_apm_to_integer_string(char *s, const M_APM mtmp)
{
  void    *vp;
  UCHAR *ucp, numdiv, numrem;
  char *cp, *p, sbuf[128];
  int ct, dl, numb, ii;
  
  vp = NULL;
  ct = mtmp->m_apm_exponent;
  dl = mtmp->m_apm_datalength;
  
  /*
   *  if |input| < 1, result is "0"
   */
  
  if (ct <= 0 || mtmp->m_apm_sign == 0)
  {
    s[0] = '0';
    s[1] = '\0';
    return;
  }
  
  if (ct > 112) {
    if ((vp = (void *)MAPM_MALLOC((size_t)(ct + 32) * sizeof(char))) == NULL) {
      /* fatal, this does not return */
      
      M_apm_log_error_msg(M_APM_MALLOC_ERROR,
                          "\'m_apm_to_integer_string\', Out of memory");
      return;
    }
    
    cp = (char *)vp;
  }
  else {
    cp = sbuf;
  }
  
  p  = cp;
  ii = 0;
  
  /* handle a negative number */
  
  if (mtmp->m_apm_sign == -1)
  {
    ii = 1;
    *p++ = '-';
  }
  
  /* get num-bytes of data (#digits / 2) to use in the string */
  
  if (ct > dl)
    numb = (dl + 1) >> 1;
  else
    numb = (ct + 1) >> 1;
  
  ucp = mtmp->m_apm_data;
  
  while (TRUE)
  {
    M_get_div_rem_10((int)(*ucp++), &numdiv, &numrem);
    
    *p++ = (char)(numdiv + '0');
    *p++ = (char)(numrem + '0');
    
    if (--numb == 0)
      break;
  }
  
  /* pad with trailing zeros if the exponent > datalength */
  
  if (ct > dl)
    memset(p, '0', (ct + 1 - dl));
  
  cp[ct + ii] = '\0';
  strcpy(s, cp);
  
  if (vp != NULL) MAPM_FREE(vp);
}
/****************************************************************************/
static M_APM _m_apm_new_cast(const M_APM src, const M_APM min, const M_APM max)
{
  M_APM m= m_apm_new();
  if (!m_apm_is_integer(src)) {
    if (src->m_apm_sign >= 0) m_apm_add(     m, src, MM_0_5);
    else                      m_apm_subtract(m, src, MM_0_5);}
  else m_apm_copy(m, src);
  if      (m_apm_compare(m, min) <= 0) m_apm_copy(m, min);
  else if (m_apm_compare(max, m) <= 0) m_apm_copy(m, max);
  return m;
}
static MSULong _m_apm_to_value(const M_APM src)
{
  MSULong ul;
  int exp, dl, numb;
  UCHAR *ucp, numdiv, numrem;
  exp= src->m_apm_exponent;
  dl=  src->m_apm_datalength;

  // if |input| < 1, result is "0"
  if (exp <= 0 || src->m_apm_sign == 0) return 0;
  numb= MIN(exp,dl);
  ucp= src->m_apm_data;
  ul= 0;
  while (numb > 0) {
    M_get_div_rem_10((int)(*ucp++), &numdiv, &numrem);
    ul= 10*ul + numdiv;
    if (--numb > 0) {
      ul= 10*ul + numrem;
      --numb;}}
  while (exp > dl) {ul*= 10; dl++;}
  if (src->m_apm_sign == -1) { // neg
    ul= (MSULong)(-ul);}
  return ul;
}

/*
Implémentation de:
MSChar     m_apm_to_char(    const M_APM);
MSByte     m_apm_to_uchar(   const M_APM);
MSShort    m_apm_to_short(   const M_APM);
MSUShort   m_apm_to_ushort(  const M_APM);
MSInt      m_apm_to_int(     const M_APM);
MSUInt     m_apm_to_uint(    const M_APM);
MSLong     m_apm_to_long(    const M_APM);
MSULong    m_apm_to_ulong(   const M_APM);
NSInteger  m_apm_to_integer( const M_APM);
NSUInteger m_apm_to_uinteger(const M_APM);
Exemple:
MSChar m_apm_to_char(const M_APM src)
{
  MSChar x; M_APM m;
  m= _m_apm_new_cast(src, MM_CharMin, MM_CharMax);
  x= (MSChar)_m_apm_to_value(m);
  MAPM_FREE(m);
  return x;
}
*/
#define _m_apm_to_(PRE, TYPEM, TYPE) PRE ## TYPE m_apm_to_ ## TYPEM(const M_APM src) \
{ \
  PRE ## TYPE x; M_APM m; \
  m= _m_apm_new_cast(src, MM_ ## TYPE ## Min, MM_ ## TYPE ## Max); \
  x= (PRE ## TYPE)_m_apm_to_value(m); \
  MAPM_FREE(m); \
  return x; \
}
_m_apm_to_(MS, char,     Char)
_m_apm_to_(MS, byte,     Byte)
_m_apm_to_(MS, short,    Short)
_m_apm_to_(MS, ushort,   UShort)
_m_apm_to_(MS, int,      Int)
_m_apm_to_(MS, uint,     UInt)
_m_apm_to_(MS, long,     Long)
_m_apm_to_(MS, ulong,    ULong)
_m_apm_to_(NS, integer,  Integer)
_m_apm_to_(NS, uinteger, UInteger)
/*
long long m_apm_to_longlong(const M_APM mtmp)
{
  long long ll;
  M_APM  ctmp; BOOL freeCtmp,neg;
  void  *vp;
  UCHAR *ucp, numdiv, numrem;
  char  *cp, *p, sbuf[128];
  int    ct, dl, numb;

  ll= 0;
  freeCtmp= NO;
  if (!m_apm_is_integer(mtmp)) {
    ctmp= m_apm_new(); freeCtmp= TRUE;
    if (mtmp->m_apm_sign >= 0)
      m_apm_add(ctmp, mtmp, MM_0_5);
    else
      m_apm_subtract(ctmp, mtmp, MM_0_5);}
  else {ctmp= mtmp; freeCtmp= FALSE;}

  vp = NULL;
  ct = ctmp->m_apm_exponent;
  dl = ctmp->m_apm_datalength;

  // if |input| < 1, result is "0"
  if (ct <= 0 || ctmp->m_apm_sign == 0) return 0;
  
  if (ct > 112) {
    if ((vp = (void *)MAPM_MALLOC((size_t)(ct + 32) * sizeof(char))) == NULL) {
      // fatal, this does not return
      
      M_apm_log_error_msg(M_APM_MALLOC_ERROR,
                          "\'m_apm_to_integer_string\', Out of memory");
      return 0;}
    cp= (char *)vp;}
  else cp= sbuf;
  
  p= cp;
  
  neg= (ctmp->m_apm_sign == -1); // handle a negative number
  
  // get num-bytes of data (#digits / 2) to use in the string
  
  if (ct > dl)
    numb = (dl + 1) >> 1;
  else
    numb = (ct + 1) >> 1;
  
  ucp = ctmp->m_apm_data;
  
  while (TRUE)
  {
    M_get_div_rem_10((int)(*ucp++), &numdiv, &numrem);
    
    // TODO: optimisation just something like ll= (ll*10+numdiv)*10+numrem; ?
    *p++ = (char)(numdiv + '0');
    *p++ = (char)(numrem + '0');
    
    if (--numb == 0)
      break;
  }
  
  // pad with trailing zeros if the exponent > datalength
  
  if (ct > dl)
    memset(p, '0', (ct + 1 - dl));
  
  cp[ct] = '\0';
  ll= strtoll(cp, NULL, 10);
  
  if (vp != NULL) MAPM_FREE(vp);
  if (freeCtmp) MAPM_FREE(ctmp);
  return neg?-ll:ll;
}
*/
/****************************************************************************/

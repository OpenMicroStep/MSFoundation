/*
 *   THIS FILE HAS BEEN MODIFIED FROM THE OFFICIAL MAPM DISTRIBUTION
 *   BY 'Herve Malaingre/Logitud Solutions' on 2013/06/18.
 *
 *   THIS FILE IS ORIGINALLY FROM MAPM VERSION 4.9.5.
 *
 *   This file is part of MicroStep/MSCore library & Microstep/MSFoundation framework
 *   The modifications are :
 
 *   1) all statics used for calculation are transformed in context defines and initialized in context creation function
 *   2) all functions have now a context parameter
 *   3) removed M_free_all_set() since the context deallocation takes care of that
 *   4) M_lbuf max size put to 16000
 *   5) added const to necessary function parameters
 *   6) changed m_long_2_ascii in m_ulong_2_ascii
 *   7) added function set_ulong_with_sign() and make m_apm_set_long() to use it
 */

/*
 *  M_APM  -  mapm_set.c
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
 *      $Id: mapm_set.c,v 1.18 2007/12/03 01:47:50 mike Exp $
 *
 *      This file contains the functions necessary to get C 'longs' and
 * 'strings' into the MAPM number system. It also contains the function
 * to get a string from a MAPM number.
 *
 *      $Log: mapm_set.c,v $
 *      Revision 1.18  2007/12/03 01:47:50  mike
 *      Update license
 *
 *      Revision 1.17  2003/07/21 20:25:06  mike
 *      Modify error messages to be in a consistent format.
 *
 *      Revision 1.16  2003/03/31 21:59:52  mike
 *      call generic error handling function
 *
 *      Revision 1.15  2002/11/05 23:31:54  mike
 *      use new set_to_zero call instead of copy
 *
 *      Revision 1.14  2002/11/03 22:24:19  mike
 *      Updated function parameters to use the modern style
 *
 *      Revision 1.13  2001/07/16 19:34:16  mike
 *      add function M_free_all_set
 *
 *      Revision 1.12  2001/02/11 22:33:27  mike
 *      modify parameters to REALLOC
 *
 *      Revision 1.11  2001/01/23 21:16:03  mike
 *      use dedicated call to long->ascii instead of sprintf
 *
 *      Revision 1.10  2000/10/25 22:57:25  mike
 *      add cast which really wasn't needed
 *
 *      Revision 1.9  2000/10/25 19:57:01  mike
 *      add free call to end of set string if the temp
 *      string gets too big
 *
 *      Revision 1.8  2000/05/04 23:49:19  mike
 *      put in more efficient set_long function
 *
 *      Revision 1.7  2000/02/03 22:47:15  mike
 *      use MAPM_* generic memory function
 *
 *      Revision 1.6  1999/07/12 22:23:17  mike
 *      tweak output string when input == 0
 *
 *      Revision 1.5  1999/07/12 02:07:56  mike
 *      fix dec_places error (was == -1, should be < 0)
 *
 *      Revision 1.4  1999/06/19 21:36:57  mike
 *      added some comments
 *
 *      Revision 1.3  1999/06/19 21:35:19  mike
 *      changed local static variables to MAPM stack variables
 *
 *      Revision 1.2  1999/05/13 21:32:41  mike
 *      added check for illegal chars in string parse
 *
 *      Revision 1.1  1999/05/10 20:56:31  mike
 *      Initial revision
 */

#include "m_apm_lc.h"

#define M_set_string_error_msg "\'M_restore_stack(3, context)\', Out of memory"

/****************************************************************************/
void m_apm_set_long(M_APM atmp, long mm) { set_mantissa_exponent_sign(atmp, (unsigned long long)(mm < 0 ? -mm : mm), 0, (mm < 0 ? -1 : 1)) ; }

/****************************************************************************/
void    set_mantissa_exponent_sign(M_APM atmp, unsigned long long mm, int exponent, int sign)
{
  int     len, ii, nbytes;
  char *p, *buf, ch, buf2[64];
  
  /* if zero, return right away */
  
  if (mm == 0 || sign == 0)
  {
    M_set_to_zero(atmp);
    return;
  }
  
  M_ulong_2_ascii(buf2, mm, 1);     /* convert long -> ascii in base 10 */
  buf = buf2;
  
  atmp->m_apm_sign = sign ;
  
  len = (int)strlen(buf);
  atmp->m_apm_exponent = len + exponent ;
  
  /* least significant nibble of ODD data-length must be 0 */
  
  if ((len & 1) != 0)
  {
    buf[len] = '0';
  }
  
  /* remove any trailing '0' ... */
  
  while (TRUE)
  {
    if (buf[--len] != '0')
      break;
  }
  
  atmp->m_apm_datalength = ++len;
  
  nbytes = (len + 1) >> 1;
  p = buf;
  
  for (ii=0; ii < nbytes; ii++)
  {
    ch = *p++ - '0';
    atmp->m_apm_data[ii] = (UCHAR)(10 * ch + *p++ - '0');
  }
}
/****************************************************************************/
void m_apm_set_string(M_APM ctmp, const char *s_in)
{
  char ch, *cp, *s, *p;
  void *vp;
  int i, j, zflag, exponent, sign;
  size_t len = strlen(s_in) + 32 ;
  
  if (!(s = (char *)MAPM_MALLOC(len))) {
    M_apm_log_error_msg(M_APM_MALLOC_ERROR, M_set_string_error_msg);
    return ;
  }
  strcpy(s,s_in);
  
  /* default == zero ... */
  
  M_set_to_zero(ctmp);
  
  p = s;
  
  while (TRUE)
  {
    if (*p == ' ' || *p == '\t')
      p++;
    else
      break;
  }
  
  if (*p == '\0')
    return;
  
  sign = 1;             /* assume number is positive */
  
  if (*p == '+')        /* scan by optional '+' sign */
    p++;
  else {
    if (*p == '-')     /* check if number negative */
    {
      sign = -1;
      p++;
    }
  }
  
  M_lowercase(p);       /* convert string to lowercase */
  exponent = 0;         /* default */
  
  if ((cp = strstr(p,"e")) != NULL) {
    exponent = atoi(cp + sizeof(char));
    *cp = '\0';          /* erase the exponent now */
  }
  
  j = M_strposition(p,".");        /* is there a decimal point ?? */
  if (j == -1)
  {
    strcat(p,".");                /* if not, append one */
    j = M_strposition(p,".");     /* now find it ... */
  }
  
  if (j > 0)                       /* normalize number and adjust exponent */
  {
    exponent += j;
    memmove((p+1),p,((size_t)j * sizeof(char)));
  }
  
  p++;        /* scan past implied decimal point now in column 1 (index 0) */
  
  i = (int)strlen(p);
  ctmp->m_apm_datalength = i;
  
  if ((i & 1) != 0)   /* if odd number of digits, append a '0' to make it even */
    strcat(p,"0");
  
  j = (int)strlen(p) >> 1;  /* number of bytes in encoded M_APM number */
  
  /* do we need more memory to hold this number */
  
  if (j > ctmp->m_apm_malloclength)
  {
    if ((vp = MAPM_REALLOC(ctmp->m_apm_data, (size_t)(j + 32))) == NULL)
    {
      MAPM_FREE(s) ;
      M_apm_log_error_msg(M_APM_MALLOC_ERROR, M_set_string_error_msg);
      return ;
    }
    
    ctmp->m_apm_malloclength = j + 28;
    ctmp->m_apm_data = (UCHAR *)vp;
  }
  
  zflag = TRUE;
  
  for (i=0; i < j; i++)
  {
    ch = *p++ - '0';
    if ((ch = (10 * ch + *p++ - '0')) != 0)
      zflag = FALSE;
    
    if (((int)ch & 0xFF) >= 100)
    {
      M_set_to_zero(ctmp);
      MAPM_FREE(s) ;
      M_apm_log_error_msg(M_APM_RETURN, "\'m_apm_set_string()\', Non-digit char found in parse");
      
      //   M_apm_log_error_msg(M_APM_RETURN, "Text =");
      //   M_apm_log_error_msg(M_APM_RETURN, s_in);
      
      return;
    }
    
    ctmp->m_apm_data[i]   = (UCHAR)ch;
    ctmp->m_apm_data[i+1] = 0;
  }
  
  ctmp->m_apm_exponent = exponent;
  ctmp->m_apm_sign     = sign;
  
  if (zflag)
  {
    ctmp->m_apm_exponent   = 0;
    ctmp->m_apm_sign       = 0;
    ctmp->m_apm_datalength = 1;
  }
  else {
    M_apm_normalize(ctmp);
  }
  
  MAPM_FREE(s) ;
}
/****************************************************************************/
void m_apm_to_string(char *s, int places, const M_APM mtmp)
{
  M_APM   ctmp;
  char *cp;
  int i, index, first, max_i, num_digits, dec_places;
  UCHAR numdiv, numrem;
  
  ctmp = m_apm_init();
  dec_places = places;
  
  if (dec_places < 0)
    m_apm_copy(ctmp, mtmp);
  else
    m_apm_round(ctmp, dec_places, mtmp);
  
  if (ctmp->m_apm_sign == 0) {
    if (dec_places < 0) { strcpy(s,"0.0E+0"); }
    else {
      strcpy(s,"0");
      
      if (dec_places > 0)
        strcat(s,".");
      
      for (i=0; i < dec_places; i++)
        strcat(s,"0");
      
      strcat(s,"E+0");
    }
    
    m_apm_free(ctmp);
    return;
  }
  
  max_i = (ctmp->m_apm_datalength + 1) >> 1;
  
  if (dec_places < 0) num_digits = ctmp->m_apm_datalength;
  else num_digits = dec_places + 1;
  
  cp = s;
  
  if (ctmp->m_apm_sign == -1) *cp++ = '-';
  
  first = TRUE;
  
  i = 0;
  index = 0;
  
  while (TRUE) {
    if (index >= max_i) {
      numdiv = 0;
      numrem = 0;
    }
    else M_get_div_rem_10((int)ctmp->m_apm_data[index],&numdiv,&numrem);
    
    index++;
    
    *cp++ = (char)numdiv + '0';
    
    if (++i == num_digits) break;
    
    if (first) {
      first = FALSE;
      *cp++ = '.';
    }
    
    *cp++ = (char)numrem + '0';
    
    if (++i == num_digits) break;
  }
  
  i = ctmp->m_apm_exponent - 1;
  
  if (i >= 0) sprintf(cp,"E+%d",i);
  else sprintf(cp,"E%d",i);
  
  m_apm_free(ctmp);
}
/****************************************************************************/

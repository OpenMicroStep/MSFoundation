/*
 *   THIS FILE HAS BEEN MODIFIED FROM THE OFFICIAL MAPM DISTRIBUTION
 *   BY 'Herve Malaingre/Logitud Solutions' on 2013/06/18.
 *
 *   THIS FILE IS ORIGINALLY FROM MAPM VERSION 4.9.5.
 *
 *   This file is part of MicroStep/MSCore library & Microstep/MSFoundation framework
 *   The modifications are :
 
 *   1) added const to necessary function parameters
 *   2) replaces local stacked vars with local initialized vars
 */

/*
 *  M_APM  -  mapmpwr2.c
 *
 *  Copyright (C) 2002 - 2007   Michael C. Ring
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
 *      $Id: mapmpwr2.c,v 1.4 2007/12/03 01:56:21 mike Exp $
 *
 *      This file contains the Integer Power function and the result
 * is NOT ROUNDED. The exponent must be an integer >= zero.
 *
 *      This will typically be used in an application where full integer
 * precision is required to be maintained.
 *
 *      $Log: mapmpwr2.c,v $
 *      Revision 1.4  2007/12/03 01:56:21  mike
 *      Update license
 *
 *      Revision 1.3  2003/07/21 20:38:06  mike
 *      Modify error messages to be in a consistent format.
 *
 *      Revision 1.2  2003/03/31 21:51:23  mike
 *      call generic error handling function
 *
 *      Revision 1.1  2002/11/03 21:02:04  mike
 *      Initial revision
 */

#include "m_apm_lc.h"

/****************************************************************************/
void m_apm_integer_pow_nr(M_APM rr, const M_APM aa, int mexp)
{
  M_APM   tmp0, tmpy, tmpz;
  int nexp, ii;
  
  if (mexp == 0)
  {
    m_apm_copy(rr, MM_One);
    return;
  }
  else
  {
    if (mexp < 0)
    {
      M_apm_log_error_msg(M_APM_RETURN,
                          "\'m_apm_integer_pow_nr\', Negative exponent");
      
      M_set_to_zero(rr);
      return;
    }
  }
  
  if (mexp == 1)
  {
    m_apm_copy(rr, aa);
    return;
  }
  
  if (mexp == 2)
  {
    m_apm_multiply(rr, aa, aa);
    return;
  }
  
  nexp = mexp;
  
  if (aa->m_apm_sign == 0)
  {
    M_set_to_zero(rr);
    return;
  }
  
  tmp0 = m_apm_init();
  tmpy = m_apm_init();
  tmpz = m_apm_init();
  
  m_apm_copy(tmpy, MM_One);
  m_apm_copy(tmpz, aa);
  
  while (TRUE)
  {
    ii   = nexp & 1;
    nexp = nexp >> 1;
    
    if (ii != 0)                       /* exponent -was- odd */
    {
      m_apm_multiply(tmp0, tmpy, tmpz);
      
      if (nexp == 0)
        break;
      
      m_apm_copy(tmpy, tmp0);
    }
    
    m_apm_multiply(tmp0, tmpz, tmpz);
    m_apm_copy(tmpz, tmp0);
  }
  
  m_apm_copy(rr, tmp0);
  
  m_apm_free(tmp0); m_apm_free(tmpy); m_apm_free(tmpz);
}
/****************************************************************************/


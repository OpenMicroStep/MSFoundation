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
 *  M_APM  -  mapm_lg4.c
 *
 *  Copyright (C) 2003 - 2007   Michael C. Ring
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
 *      $Id: mapm_lg4.c,v 1.3 2007/12/03 01:43:32 mike Exp $
 *
 *      This file contains the LOG_NEAR_1 function.
 *
 *      $Log: mapm_lg4.c,v $
 *      Revision 1.3  2007/12/03 01:43:32  mike
 *      Update license
 *
 *      Revision 1.2  2003/06/02 18:08:45  mike
 *      tweak decimal places and add comments
 *
 *      Revision 1.1  2003/06/02 17:27:26  mike
 *      Initial revision
 */

#include "m_apm_lc.h"

/****************************************************************************/
/*
 *  calculate log (1 + x) with the following series:
 *
 *        x
 *  y = -----      ( |y| < 1 )
 *      x + 2
 *
 *
 *      [ 1 + y ]                 y^3     y^5     y^7
 *  log [-------]  =  2 * [ y  +  ---  +  ---  +  ---  ... ]
 *      [ 1 - y ]                  3       5       7
 *
 */
void M_log_near_1(M_APM rr, int places, const M_APM xx)
{
  M_APM   tmp0, tmp1, tmp2, tmpS, term;
  int tolerance, dplaces, local_precision;
  long    m1;
  
  tmp0  = m_apm_init();
  tmp1  = m_apm_init();
  tmp2  = m_apm_init();
  tmpS  = m_apm_init();
  term  = m_apm_init();
  
  tolerance = xx->m_apm_exponent - (places + 6);
  dplaces   = (places + 12) - xx->m_apm_exponent;
  
  m_apm_add(tmp0, xx, MM_Two);
  m_apm_divide(tmpS, (dplaces + 6), xx, tmp0);
  
  m_apm_copy(term, tmpS);
  m_apm_multiply(tmp0, tmpS, tmpS);
  m_apm_round(tmp2, (dplaces + 6), tmp0);
  
  m1 = 3L;
  
  while (TRUE)
  {
    m_apm_multiply(tmp0, term, tmp2);
    
    if ((tmp0->m_apm_exponent < tolerance) || (tmp0->m_apm_sign == 0))
      break;
    
    local_precision = dplaces + tmp0->m_apm_exponent;
    
    if (local_precision < 20)
      local_precision = 20;
    
    m_apm_set_long(tmp1, m1);
    m_apm_round(term, local_precision, tmp0);
    m_apm_divide(tmp0, local_precision, term, tmp1);
    m_apm_add(tmp1, tmpS, tmp0);
    m_apm_copy(tmpS, tmp1);
    m1 += 2;
  }
  
  m_apm_multiply(tmp0, MM_Two, tmpS);
  m_apm_round(rr, places, tmp0);
  
  m_apm_free(tmp0) ; m_apm_free(tmp1) ; m_apm_free(tmp2) ; m_apm_free(tmpS) ;
  m_apm_free(term) ;
}
/****************************************************************************/

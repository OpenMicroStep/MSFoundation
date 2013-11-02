/*
 *   THIS FILE HAS BEEN MODIFIED FROM THE OFFICIAL MAPM DISTRIBUTION
 *   BY 'Herve Malaingre/Logitud Solutions' on 2013/06/18.
 *
 *   THIS FILE IS ORIGINALLY FROM MAPM VERSION 4.9.5.
 *
 *   This file is part of MicroStep/MSCore library & Microstep/MSFoundation framework
 *   The modifications are :
 
 *   1) removed the statics for stacking calculation results : so the function is slower
 *   2) removed M_free_all_pow() since there is no more statics here
 *   3) added const to necessary function parameters
 *   4) replaces local stacked vars with local initialized vars
 */

/*
 *  M_APM  -  mapm_pow.c
 *
 *  Copyright (C) 2000 - 2007   Michael C. Ring
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
 *      $Id: mapm_pow.c,v 1.10 2007/12/03 01:46:07 mike Exp $
 *
 *      This file contains the POW function.
 *
 *      $Log: mapm_pow.c,v $
 *      Revision 1.10  2007/12/03 01:46:07  mike
 *      Update license
 *
 *      Revision 1.9  2002/11/05 23:39:42  mike
 *      use new set_to_zero call
 *
 *      Revision 1.8  2002/11/03 22:20:59  mike
 *      Updated function parameters to use the modern style
 *
 *      Revision 1.7  2001/07/16 19:24:26  mike
 *      add function M_free_all_pow
 *
 *      Revision 1.6  2000/09/05 22:15:03  mike
 *      minor tweak
 *
 *      Revision 1.5  2000/08/22 21:22:29  mike
 *      if parameter yy is an integer, call the more
 *      efficient _integer_pow function
 *
 *      Revision 1.4  2000/08/22 20:42:08  mike
 *      compute more digits in the log calculation
 *
 *      Revision 1.3  2000/05/24 20:08:21  mike
 *      update some comments
 *
 *      Revision 1.2  2000/05/23 23:20:11  mike
 *      return 1 when input is 0^0.
 *
 *      Revision 1.1  2000/05/18 22:10:43  mike
 *      Initial revision
 */

#include "m_apm_lc.h"

/****************************************************************************/
/*
 Calculate the POW function by calling EXP :
 
 Y      A
 X   =  e    where A = Y * log(X)
 */
void m_apm_pow(M_APM rr, int places, const M_APM xx, const M_APM yy)
{
  int iflag ;
  char    sbuf[64];
  M_APM   tmp8, tmp9;
  
  /* if yy == 0, return 1 */
  
  if (yy->m_apm_sign == 0)
  {
    m_apm_copy(rr, MM_One);
    return;
  }
  
  /* if xx == 0, return 0 */
  
  if (xx->m_apm_sign == 0)
  {
    M_set_to_zero(rr);
    return;
  }
  
  /*
   *  if 'yy' is a small enough integer, call the more
   *  efficient _integer_pow function.
   */
  
  if (m_apm_is_integer(yy))
  {
    iflag = FALSE;
    
    if (MM_SIZEOF_INT == 2)            /* 16 bit compilers */
    {
      if (yy->m_apm_exponent <= 4)
        iflag = TRUE;
    }
    else                             /* >= 32 bit compilers */
    {
      if (yy->m_apm_exponent <= 7)
        iflag = TRUE;
    }
    
    if (iflag)
    {
      m_apm_to_integer_string(sbuf, yy);
      m_apm_integer_pow(rr, places, xx, atoi(sbuf));
      return;
    }
  }
  
  tmp8 = m_apm_new();
  tmp9 = m_apm_new();
  
  
  
  m_apm_log(tmp9, (places + 8), xx);
  m_apm_multiply(tmp8, tmp9, yy);
  m_apm_exp(rr, places, tmp8);
  m_apm_free(tmp8) ; m_apm_free(tmp9) ;
}
/****************************************************************************/

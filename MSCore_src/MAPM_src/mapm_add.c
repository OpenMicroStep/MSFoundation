/*
 *   THIS FILE HAS BEEN MODIFIED FROM THE OFFICIAL MAPM DISTRIBUTION
 *   BY 'Herve Malaingre/Logitud Solutions' on 2013/06/18.
 *
 *   THIS FILE IS ORIGINALLY FROM MAPM VERSION 4.9.5.
 *
 *   This file is part of MicroStep/MSCore library & Microstep/MSFoundation framework
 *   The modifications are :
 
 *   1) removed M_free_all_add() since there is no more statics
 *   2) added const to necessary function parameters
 *   3) removed temporary variables M_work1, M_work2 and other statics (replaced by locals)
 */

/*
 *  M_APM  -  mapm_add.c
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
 *      $Id: mapm_add.c,v 1.5 2007/12/03 01:33:39 mike Exp $
 *
 *      This file contains basic addition/subtraction functions
 *
 *      $Log: mapm_add.c,v $
 *      Revision 1.5  2007/12/03 01:33:39  mike
 *      Update license
 *
 *      Revision 1.4  2003/12/04 01:15:42  mike
 *      redo math with 'borrow'
 *
 *      Revision 1.3  2002/11/03 22:03:31  mike
 *      Updated function parameters to use the modern style
 *
 *      Revision 1.2  2001/07/16 18:59:25  mike
 *      add function M_free_all_add
 *
 *      Revision 1.1  1999/05/10 20:56:31  mike
 *      Initial revision
 */

#include "m_apm_lc.h"

/****************************************************************************/
void m_apm_add(M_APM r, const M_APM a, const M_APM b)
{
  int j, carry, sign, aexp, bexp, adigits, bdigits;
  M_APM M_work1, M_work2;
  
  
  if (a->m_apm_sign == 0)
  {
    m_apm_copy(r,b);
    return;
  }
  
  if (b->m_apm_sign == 0)
  {
    m_apm_copy(r,a);
    return;
  }
  
  if (a->m_apm_sign == 1 && b->m_apm_sign == -1)
  {
    b->m_apm_sign = 1;
    m_apm_subtract(r,a,b);
    b->m_apm_sign = -1;
    return;
  }
  
  if (a->m_apm_sign == -1 && b->m_apm_sign == 1)
  {
    a->m_apm_sign = 1;
    m_apm_subtract(r,b,a);
    a->m_apm_sign = -1;
    return;
  }
  
  sign = a->m_apm_sign;         /* signs are the same, result will be same */
  
  aexp = a->m_apm_exponent;
  bexp = b->m_apm_exponent;
  
  M_work1 = m_apm_new();
  M_work2 = m_apm_new();
  
  m_apm_copy(M_work1, a);
  m_apm_copy(M_work2, b);
  
  /*
   *  scale by at least 1 factor of 10 in case the MSB carrys
   */
  
  if (aexp == bexp)
  {
    M_apm_scale(M_work1, 2);   /* shift 2 digits == 1 byte for efficiency */
    M_apm_scale(M_work2, 2);
  }
  else
  {
    if (aexp > bexp)
    {
      M_apm_scale(M_work1, 2);
      M_apm_scale(M_work2, (aexp + 2 - bexp));
    }
    else            /*  aexp < bexp  */
    {
      M_apm_scale(M_work2, 2);
      M_apm_scale(M_work1, (bexp + 2 - aexp));
    }
  }
  
  adigits = M_work1->m_apm_datalength;
  bdigits = M_work2->m_apm_datalength;
  
  if (adigits >= bdigits)
  {
    m_apm_copy(r, M_work1);
    j = (bdigits + 1) >> 1;
    carry = 0;
    
    while (TRUE)
    {
      j--;
      r->m_apm_data[j] += carry + M_work2->m_apm_data[j];
      
      if (r->m_apm_data[j] >= 100)
      {
        r->m_apm_data[j] -= 100;
        carry = 1;
      }
      else
        carry = 0;
      
      if (j == 0)
        break;
    }
  }
  else
  {
    m_apm_copy(r, M_work2);
    j = (adigits + 1) >> 1;
    carry = 0;
    
    while (TRUE)
    {
      j--;
      r->m_apm_data[j] += carry + M_work1->m_apm_data[j];
      
      if (r->m_apm_data[j] >= 100)
      {
        r->m_apm_data[j] -= 100;
        carry = 1;
      }
      else
        carry = 0;
      
      if (j == 0)
        break;
    }
  }
  
  r->m_apm_sign = sign;
  
  M_apm_normalize(r);
  m_apm_free(M_work1); m_apm_free(M_work2);
}
/****************************************************************************/
void m_apm_subtract(M_APM r, const M_APM a, const M_APM b)
{
  M_APM M_work1, M_work2;
  int itmp, j, flag, icompare, sign, aexp, bexp;
  int borrow, adigits, bdigits;
  
  if (b->m_apm_sign == 0)
  {
    m_apm_copy(r,a);
    return;
  }
  
  if (a->m_apm_sign == 0)
  {
    m_apm_copy(r,b);
    r->m_apm_sign = -(r->m_apm_sign);
    return;
  }
  
  if (a->m_apm_sign == 1 && b->m_apm_sign == -1)
  {
    b->m_apm_sign = 1;
    m_apm_add(r,a,b);
    b->m_apm_sign = -1;
    return;
  }
  
  if (a->m_apm_sign == -1 && b->m_apm_sign == 1)
  {
    b->m_apm_sign = -1;
    m_apm_add(r,a,b);
    b->m_apm_sign = 1;
    return;
  }
  
  /* now, the signs are the same  */
  /* make a positive working copy */
  
  M_work1 = m_apm_new();
  M_work2 = m_apm_new();
  m_apm_absolute_value(M_work1, a);
  m_apm_absolute_value(M_work2, b);
  
  /* are they the same??  if so, the result is zero */
  
  if ((icompare = m_apm_compare(M_work1, M_work2)) == 0)
  {
    M_set_to_zero(r);
    m_apm_free(M_work1); m_apm_free(M_work2);
    return;
  }
  
  if (icompare == 1)             /*  |a| > |b|  (do A-B)  */
  {
    flag = TRUE;
    sign = a->m_apm_sign;
  }
  else                           /*  |b| > |a|  (do B-A)  */
  {
    flag = FALSE;
    sign = -(a->m_apm_sign);
  }
  
  aexp = M_work1->m_apm_exponent;
  bexp = M_work2->m_apm_exponent;
  
  if (aexp > bexp)
    M_apm_scale(M_work2, (aexp - bexp));
  
  if (aexp < bexp)
    M_apm_scale(M_work1, (bexp - aexp));
  
  adigits = M_work1->m_apm_datalength;
  bdigits = M_work2->m_apm_datalength;
  
  if (adigits > bdigits)
    M_apm_pad(M_work2, adigits);
  
  if (adigits < bdigits)
    M_apm_pad(M_work1, bdigits);
  
  if (flag)  /* perform A-B,  M_work1 - M_work2 */
  {
    m_apm_copy(r, M_work1);
    j = (r->m_apm_datalength + 1) >> 1;
    borrow = 0;
    
    while (TRUE)
    {
      j--;
      itmp = (int)r->m_apm_data[j] - ((int)M_work2->m_apm_data[j] + borrow);
      
      if (itmp >= 0)
      {
        r->m_apm_data[j] = (UCHAR)itmp;
        borrow = 0;
      }
      else
      {
        r->m_apm_data[j] = (UCHAR)(100 + itmp);
        borrow = 1;
      }
      
      if (j == 0)
        break;
    }
  }
  else     /* perform B-A,  M_work2 - M_work1 */
  {
    m_apm_copy(r, M_work2);
    j = (r->m_apm_datalength + 1) >> 1;
    borrow = 0;
    
    while (TRUE)
    {
      j--;
      itmp = (int)r->m_apm_data[j] - ((int)M_work1->m_apm_data[j] + borrow);
      
      if (itmp >= 0)
      {
        r->m_apm_data[j] = (UCHAR)itmp;
        borrow = 0;
      }
      else
      {
        r->m_apm_data[j] = (UCHAR)(100 + itmp);
        borrow = 1;
      }
      
      if (j == 0)
        break;
    }
  }
  
  r->m_apm_sign = sign;
  
  M_apm_normalize(r);
  m_apm_free(M_work1); m_apm_free(M_work2);
}
/****************************************************************************/

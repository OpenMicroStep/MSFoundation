/*
 *   THIS FILE HAS BEEN MODIFIED FROM THE OFFICIAL MAPM DISTRIBUTION
 *   BY 'Herve Malaingre/Logitud Solutions' on 2013/06/18.
 *
 *   THIS FILE IS ORIGINALLY FROM MAPM VERSION 4.9.5.
 *
 *   This file is part of MicroStep/MSCore library & Microstep/MSFoundation framework
 *   The modifications are :
 
 *   1) add a callback setter m_apm_set_log_callback() in order to change the way we log information
 *   2) we change the FATAL semantic. all the >0 codes are fatal in the common log function
 *   3) added const to necessary function parameters
 *   4) added all necessary functions to have basic callbacks
 */


/*
 *  M_APM  -  mapmutl1.c
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
 *      $Id: mapmutl1.c,v 1.4 2007/12/03 01:59:27 mike Exp $
 *
 *      This file contains the utility function 'M_apm_log_error_msg'
 *
 * This is the only function in this file so a user can supply
 * their own custom version easily without changing the base library.
 *
 *      $Log: mapmutl1.c,v $
 *      Revision 1.4  2007/12/03 01:59:27  mike
 *      Update license
 *
 *      Revision 1.3  2003/07/21 21:00:34  mike
 *      Modify error messages to be in a consistent format.
 *
 *      Revision 1.2  2003/05/05 18:38:27  mike
 *      fix comment
 *
 *      Revision 1.1  2003/05/04 18:19:14  mike
 *      Initial revision
 */

#include "m_apm_lc.h"

static M_apm_alloc_fn             __alloc_callback_fn=             NULL ;
static M_apm_free_fn              __free_callback_fn=              NULL ;
static M_apm_log_fn               __log_callback_fn=               NULL ;
static M_apm_string_components_fn __string_components_callback_fn= NULL ;

/****************************************************************************/
M_APM m_apm_allocate(void)
{
  if (__alloc_callback_fn) {
    return __alloc_callback_fn() ;
  }
  return (M_APM)MAPM_MALLOC(sizeof(CDecimal)) ;
}

/****************************************************************************/
void m_apm_free(void *atmp)
{
  if (__free_callback_fn) {
    __free_callback_fn(atmp) ;
  }
  else if (m_apm_deallocate((M_APM)atmp)) {
    MAPM_FREE(atmp);
  }
}

/****************************************************************************/
void M_apm_log_error_msg(int code, const char *message)
{
  if (__log_callback_fn) __log_callback_fn(code, message) ;
  if (code > 0) {
    fprintf(stderr, "MAPM Error: %s\n", message);
    exit(code);
  }
  else {
    fprintf(stderr, "MAPM Warning: %s\n", message);
  }
}
/****************************************************************************/
void    m_apm_set_callbacks(M_apm_alloc_fn fnalloc, M_apm_free_fn fndealloc, M_apm_log_fn fnlog, M_apm_string_components_fn fnsc)
{
  // this function should be thread protected
  __alloc_callback_fn = fnalloc ;
  __free_callback_fn = fndealloc ;
  __log_callback_fn = fnlog ;
  __string_components_callback_fn = fnsc ;
}
/****************************************************************************/

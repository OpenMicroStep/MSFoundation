
/*
 *   THIS FILE HAS BEEN MODIFIED FROM THE OFFICIAL MAPM DISTRIBUTION
 *   BY 'Herve Malaingre/Logitud Solutions' on 2013/06/18.
 *
 *   THIS FILE IS ORIGINALLY FROM MAPM VERSION 4.9.5.
 *
 *   This file is part of MSFoundation framework 
 *   The modifications are :
 
 *   1) all C++ IFDEFs are removed since we don't need any C++ here
 *   2) m_apm_cpp_precision() function is removed
 *   3) removed m_apm_refcount from the M_APM structure
 *   4) add more error types here than M_APM_RETURN and M_APM_FATAL
 *   5) add a callback function of type M_apm_log_fn to be used in spite of standard one
 *   6) adding necessary const to all functions which need it
 *   7) remove all random functions
 *   8) removed all function for clearing memory since all memory management is now dynamic
 *   9) add a callback function in order to interpret unicode openstep strings and make the same
 *      function interpret strings in all the framework
 
 *   This file is maint to be used inside the MSFoundation framework.
 *   Access to M_APM wil be made through the MSDecimal class
 */

/* 
 *  M_APM  -  m_apm.h
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
 *      This is the header file that the user will include.
 *
 *      $Log: m_apm.h,v $
 *      Revision 1.42  2007/12/03 02:28:25  mike
 *      update copyright
 *
 *      Revision 1.41  2007/12/03 01:21:35  mike
 *      Update license
 *      Update version to 4.9.5
 *
 *      Revision 1.40  2004/05/31 22:06:02  mike
 *      add % operator to C++ wrapper
 *
 *      Revision 1.39  2004/05/24 04:11:41  mike
 *      updated version to 4.9.2
 *
 *      Revision 1.38  2004/04/01 03:17:19  mike
 *      update version to 4.9.1
 *
 *      Revision 1.37  2004/01/02 20:40:49  mike
 *      fix date on copyright
 *
 *      Revision 1.36  2004/01/02 00:52:38  mike
 *      update version to 4.9
 *
 *      Revision 1.35  2003/11/23 05:12:46  mike
 *      update version
 *
 *      Revision 1.34  2003/07/21 20:59:54  mike
 *      update version to 4.8
 *
 *      Revision 1.33  2003/05/14 21:19:23  mike
 *      change version string
 *
 *      Revision 1.32  2003/05/06 21:29:11  mike
 *      add defines for lib versions (and prototypes)
 *
 *      Revision 1.31  2002/11/04 20:46:33  mike
 *      change definition of the M_APM structure
 *
 *      Revision 1.30  2002/11/03 23:36:24  mike
 *      added new function, m_apm_integer_pow_nr
 *
 *      Revision 1.29  2002/02/14 21:43:00  mike
 *      add set_random_seed prototype
 *
 *      Revision 1.28  2001/08/28 18:29:32  mike
 *      fix fixptstringexp
 *
 *      Revision 1.27  2001/08/27 22:45:03  mike
 *      fix typo
 *
 *      Revision 1.26  2001/08/27 22:43:06  mike
 *      add new fix pt functions to C++ wrapper
 *
 *      Revision 1.25  2001/08/26 22:09:13  mike
 *      add new prototype
 *
 *      Revision 1.24  2001/08/25 16:48:21  mike
 *      add new prototypes
 *
 *      Revision 1.23  2001/07/16 18:40:27  mike
 *      add free_all_mem, trim_mem_usage prototypes
 *
 *      Revision 1.22  2001/07/15 20:49:21  mike
 *      added is_odd, is_even, gcd, lcm functions
 *
 *      Revision 1.21  2001/03/25 21:24:55  mike
 *      add floor and ceil functions
 *
 *      Revision 1.20  2000/09/23 19:05:29  mike
 *      add _reciprocal prototype
 *
 *      Revision 1.19  2000/08/21 23:30:13  mike
 *      add _is_integer function
 *
 *      Revision 1.18  2000/07/06 00:10:15  mike
 *      redo declare for MM_cpp_min_precision
 *
 *      Revision 1.17  2000/07/04 20:59:43  mike
 *      move MM_cpp_min_precision into cplusplus block below
 *
 *      Revision 1.16  2000/07/04 20:49:04  mike
 *      move 'MM_cpp_min_precision' inside the extern "C"
 *      brackets
 *
 *      Revision 1.15  2000/04/06 21:19:38  mike
 *      minor final tweaks from Orion
 *
 *      Revision 1.14  2000/04/05 20:15:25  mike
 *      add cpp_min_precision
 *
 *      Revision 1.13  2000/04/04 22:20:09  mike
 *      updated some comments from Orion
 *
 *      Revision 1.12  2000/04/04 19:46:36  mike
 *      fix preincrement, postincrement operators
 *      added some comments
 *      added 'ipow' operators
 *
 *      Revision 1.11  2000/04/03 22:08:35  mike
 *      added MAPM C++ wrapper class
 *      supplied by Orion Sky Lawlor (olawlor@acm.org)
 *
 *      Revision 1.10  2000/04/03 18:40:28  mike
 *      add #define atan2 for alias
 *
 *      Revision 1.9  2000/04/03 18:05:23  mike
 *      added hyperbolic functions
 *
 *      Revision 1.8  2000/04/03 17:26:57  mike
 *      add cbrt prototype
 *
 *      Revision 1.7  1999/09/18 03:11:23  mike
 *      add new prototype
 *
 *      Revision 1.6  1999/09/18 03:08:25  mike
 *      add new prototypes
 *
 *      Revision 1.5  1999/09/18 01:37:55  mike
 *      added new prototype
 *
 *      Revision 1.4  1999/07/12 02:04:30  mike
 *      added new function prototpye (m_apm_integer_string)
 *
 *      Revision 1.3  1999/05/15 21:04:08  mike
 *      added factorial prototype
 *
 *      Revision 1.2  1999/05/12 20:50:12  mike
 *      added more constants
 *
 *      Revision 1.1  1999/05/12 20:48:25  mike
 *      Initial revision
 *
 *      $Id: m_apm.h,v 1.42 2007/12/03 02:28:25 mike Exp $
 */

#ifndef M__APM__INCLUDED
#define M__APM__INCLUDED

#ifndef WIN32 // Already defined in windef.h
typedef unsigned char UCHAR;
#endif

typedef CDecimal *M_APM;
// can be uses as M_APM or CDecimal *

// === added by HM ===

// non fatal errors
#define M_APM_BAD_GCD        -7
#define M_APM_BAD_TRIGO      -6
#define M_APM_BAD_SQRT       -5
#define M_APM_BAD_LOGARITHM  -4
#define M_APM_UNDERFLOW      -3
#define M_APM_OVERFLOW       -2
#define M_APM_DIVIDE_BY_ZERO -1
// standard undefined error
#define M_APM_RETURN          0
// fatals errors
#define M_APM_FATAL           1 // global fatal error
#define M_APM_MALLOC_ERROR    2
#define M_APM_INIT_ERROR      3 // memory erro in a specific M_APM iniside initialization

typedef void  (*M_apm_log_fn)(int, const char *);
typedef M_APM  (*M_apm_alloc_fn)(void);
typedef void  (*M_apm_free_fn)(void *);
typedef void  (*M_apm_string_components_fn)(int, const char *);

// === end of addition ===


#define MAPM_LIB_VERSION \
    "MAPM Library for MSFoundation - derived from version 4.9.5 - Copyright (C) 1999-2007, Michael C. Ring"
#define MAPM_LIB_SHORT_VERSION "4.9.5"


/*
 * convienient predefined constants
 */

MSExport M_APM MM_Zero;
MSExport M_APM MM_One;
MSExport M_APM MM_Two;
MSExport M_APM MM_Three;
MSExport M_APM MM_Four;
MSExport M_APM MM_Five;
MSExport M_APM MM_Ten;

MSExport M_APM MM_PI;
MSExport M_APM MM_HALF_PI;
MSExport M_APM MM_2_PI;
MSExport M_APM MM_E;

MSExport M_APM MM_LOG_E_BASE_10;
MSExport M_APM MM_LOG_10_BASE_E;
MSExport M_APM MM_LOG_2_BASE_E;
MSExport M_APM MM_LOG_3_BASE_E;


/*
 * function prototypes
 */

MSExport void M_init_mapm_constants(void); // You should  call this function only once and after m_apm_set_callbacks() if you intend to use it

// with this new "objec oriented" function, you can use RETAIN() AUTORELEASE() and RELEASE() on a M_APM
MSExport M_APM m_apm_allocate(void);
MSExport M_APM m_apm_new(void);         // m_apm_allocate() m_apm_init()
MSExport M_APM m_apm_init(M_APM atmp);  // init alone
MSExport BOOL  m_apm_deallocate(M_APM); // clear the M_APM number content
MSExport void  m_apm_free(void *);      // uses the m_apm_deallocate() function

MSExport char *m_apm_lib_version(char *);
MSExport char *m_apm_lib_short_version(char *);
MSExport void  m_apm_set_callbacks(M_apm_alloc_fn fn1, M_apm_free_fn fn2, M_apm_log_fn fn3, M_apm_string_components_fn fn4); // if null uses the standards functions

MSExport void m_apm_set_string(M_APM, const char *);
MSExport void m_apm_set_double(M_APM, double);
MSExport void m_apm_set_long(M_APM, long);
MSExport void set_mantissa_exponent_sign(M_APM atmp, unsigned long long mm, int exponent, int sign);

MSExport void  m_apm_to_string(char *, int, const M_APM);
MSExport void  m_apm_to_fixpt_string(char *, int, M_APM);
MSExport void  m_apm_to_fixpt_stringex(char *, int, M_APM, char, char, int);
MSExport char *m_apm_to_fixpt_stringexp(int, M_APM, char, char, int);
MSExport void  m_apm_to_integer_string(char *, M_APM);

MSExport void m_apm_absolute_value(M_APM, const M_APM);
MSExport void m_apm_negate(M_APM, const M_APM);
MSExport void m_apm_copy(M_APM, const M_APM);
MSExport void m_apm_round(M_APM, int, const M_APM);
MSExport int  m_apm_compare(const M_APM, const M_APM);
MSExport int  m_apm_sign(const M_APM);
MSExport int  m_apm_exponent(const M_APM);
MSExport int  m_apm_significant_digits(const M_APM);
MSExport int  m_apm_is_integer(const M_APM);
MSExport int  m_apm_is_even(const M_APM);
MSExport int  m_apm_is_odd(const M_APM);

MSExport void m_apm_gcd(M_APM, const M_APM, const M_APM);
MSExport void m_apm_lcm(M_APM, const M_APM, const M_APM);

MSExport void m_apm_add(M_APM, const M_APM, const M_APM);
MSExport void m_apm_subtract(M_APM, const M_APM, const M_APM);
MSExport void m_apm_multiply(M_APM, const M_APM, const M_APM);
MSExport void m_apm_divide(M_APM, int, const M_APM, const M_APM);
MSExport void m_apm_integer_divide(M_APM, const M_APM, const M_APM);
MSExport void m_apm_integer_div_rem(M_APM, M_APM, const M_APM, const M_APM);
MSExport void m_apm_reciprocal(M_APM, int, const M_APM);
MSExport void m_apm_factorial(M_APM, const M_APM);
MSExport void m_apm_floor(M_APM, const M_APM);
MSExport void m_apm_ceil(M_APM, const M_APM);

MSExport void m_apm_sqrt(M_APM, int, const M_APM);
MSExport void m_apm_cbrt(M_APM, int, const M_APM);
MSExport void m_apm_log(M_APM, int, const M_APM);
MSExport void m_apm_log10(M_APM, int, const M_APM);
MSExport void m_apm_exp(M_APM, int, const M_APM);
MSExport void m_apm_pow(M_APM, int, const M_APM, const M_APM);
MSExport void m_apm_integer_pow(M_APM, int, const M_APM, int);
MSExport void m_apm_integer_pow_nr(M_APM, const M_APM, int);

MSExport void m_apm_sin_cos(M_APM, M_APM, int, const M_APM);
MSExport void m_apm_sin(M_APM, int, const M_APM);
MSExport void m_apm_cos(M_APM, int, const M_APM);
MSExport void m_apm_tan(M_APM, int, const M_APM);
MSExport void m_apm_arcsin(M_APM, int, const M_APM);
MSExport void m_apm_arccos(M_APM, int, const M_APM);
MSExport void m_apm_arctan(M_APM, int, const M_APM);
MSExport void m_apm_arctan2(M_APM, int, const M_APM, const M_APM);

MSExport void m_apm_sinh(M_APM, int, const M_APM);
MSExport void m_apm_cosh(M_APM, int, const M_APM);
MSExport void m_apm_tanh(M_APM, int, const M_APM);
MSExport void m_apm_arcsinh(M_APM, int, const M_APM);
MSExport void m_apm_arccosh(M_APM, int, const M_APM);
MSExport void m_apm_arctanh(M_APM, int, const M_APM);

/* more intuitive alternate names for the ARC functions ... */

#define m_apm_asin m_apm_arcsin
#define m_apm_acos m_apm_arccos
#define m_apm_atan m_apm_arctan
#define m_apm_atan2 m_apm_arctan2

#define m_apm_asinh m_apm_arcsinh
#define m_apm_acosh m_apm_arccosh
#define m_apm_atanh m_apm_arctanh
#endif

/*
 *   THIS FILE HAS BEEN MODIFIED FROM THE OFFICIAL MAPM DISTRIBUTION
 *   BY 'Herve Malaingre/Logitud Solutions' on 2013/06/18.
 *
 *   THIS FILE IS ORIGINALLY FROM MAPM VERSION 4.9.5.
 *
 *   This file is part of MSFoundation framework
 *   The modifications are :
 
 *   1) M_APM_FMC in order to hold fast multiplication stack
 *   2) remaining statics (i.e MM_lc_PI_digits to MM_lc_log10R are not bound to
 *      a context and never deallocated. initialization of the first context
 *      create them.
 *   3) function M_free_all_cnst() is removed since the remaining statics are not deallocated any more
 *   4) transfert of error types in public header file
 *   5) added const in function parameters
 *   6) add MM_EXP_LOG2R, MM_EXP_512R, MM_RND_AA and MM_RND_MM in constant section
 *   7) removed the M_get_sizeof_int function (we can use sizeof(int) where we want instead
 *   8) constants M_STACK_SIZE and M_ISTACK_SIZE are removed from mapmfmul.c to be accessible here

 *   This file is maint to be used inside the MSFoundation framework.
 *   Access to M_APM wil be made through the MSDecimal class
 */

/*
 *  M_APM  -  m_apm_lc.h
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
 *      This is the local header file needed to build the library
 *
 *      $Log: m_apm_lc.h,v $
 *      Revision 1.45  2007/12/04 01:26:02  mike
 *      add support for Digital Mars compiler
 *
 *      Revision 1.44  2007/12/03 01:23:54  mike
 *      Update license
 *
 *      Revision 1.43  2004/05/28 19:30:16  mike
 *      add new prototype
 *
 *      Revision 1.42  2003/10/25 22:36:01  mike
 *      add support for National Instruments CVI
 *
 *      Revision 1.41  2003/07/21 19:42:50  mike
 *      rename M_APM_EXIT to M_APM_FATAL
 *      change M_APM_RETURN to 0, set M_APM_FATAL to 1
 *
 *      Revision 1.40  2003/07/21 19:14:29  mike
 *      add new prototype
 *
 *      Revision 1.39  2003/05/04 20:09:10  mike
 *      add support for Open Watcom 1.0
 *
 *      Revision 1.38  2003/05/01 21:54:04  mike
 *      add math.h, add new prototype
 *
 *      Revision 1.37  2003/04/01 23:19:01  mike
 *      add new log constants and prototypes
 *
 *      Revision 1.36  2003/03/30 23:02:49  mike
 *      add new log constants and new prototypes
 *
 *      Revision 1.35  2002/11/03 23:21:28  mike
 *      add new prototype, M_set_to_zero
 *
 *      Revision 1.34  2002/05/18 15:38:52  mike
 *      add MINGW compiler #define
 *
 *      Revision 1.33  2002/02/14 19:42:59  mike
 *      add conditional compiler stuff for Metrowerks Codewarrior compiler
 *
 *      Revision 1.32  2001/08/25 16:45:40  mike
 *      add new prototype
 *
 *      Revision 1.31  2001/07/24 18:13:31  mike
 *      add new prototype
 *
 *      Revision 1.30  2001/07/16 18:38:04  mike
 *      add 'free_all' prototypes
 *
 *      Revision 1.29  2001/02/07 19:13:27  mike
 *      eliminate MM_skip_limit_PI_check
 *
 *      Revision 1.28  2001/01/23 21:10:24  mike
 *      add new prototype for M_long_2_ascii
 *
 *      Revision 1.27  2000/12/10 14:30:52  mike
 *      added ifdef for LCC-WIN32 compiler
 *
 *      Revision 1.26  2000/12/02 19:41:45  mike
 *      add arc functions near 0
 *
 *      Revision 1.25  2000/11/14 22:48:29  mike
 *      add BORLANDC to pre-processor stuff
 *
 *      Revision 1.24  2000/10/22 21:17:56  mike
 *      add _MSC_VER check for VC++ compilers
 *
 *      Revision 1.23  2000/10/18 23:09:27  mike
 *      add new prototype
 *
 *      Revision 1.22  2000/09/23 18:55:30  mike
 *      add new prototype fpr M_apm_sdivide
 *
 *      Revision 1.21  2000/08/01 22:21:55  mike
 *      add prototype
 *
 *      Revision 1.20  2000/07/19 17:21:26  mike
 *      add ifdef for older Borland compilers
 *
 *      Revision 1.19  2000/07/11 20:09:30  mike
 *      add new prototype
 *
 *      Revision 1.18  2000/05/19 17:09:57  mike
 *      add local copies for PI variables
 *
 *      Revision 1.17  2000/05/04 23:21:56  mike
 *      change/add new global internal MAPM values
 *
 *      Revision 1.16  2000/04/11 18:44:43  mike
 *      no longer need the constant 'Fifteen'
 *
 *      Revision 1.15  2000/04/03 17:27:08  mike
 *      added cbrt prototype
 *
 *      Revision 1.14  2000/02/03 22:41:34  mike
 *      add MAPM_* memory function defines
 *
 *      Revision 1.13  1999/07/09 22:46:10  mike
 *      add skip limit integer
 *
 *      Revision 1.12  1999/07/08 23:35:20  mike
 *      change constant
 *
 *      Revision 1.11  1999/07/08 22:55:38  mike
 *      add new constant
 *
 *      Revision 1.10  1999/06/23 01:08:11  mike
 *      added constant '15'
 *
 *      Revision 1.9  1999/06/20 23:38:11  mike
 *      updated for new prototypes
 *
 *      Revision 1.8  1999/06/20 23:30:03  mike
 *      added new constants
 *
 *      Revision 1.7  1999/06/20 19:23:12  mike
 *      delete constants no longer needed
 *
 *      Revision 1.6  1999/06/20 18:50:21  mike
 *      added more constants
 *
 *      Revision 1.5  1999/06/19 20:37:30  mike
 *      add stack prototypes
 *
 *      Revision 1.4  1999/05/31 23:01:38  mike
 *      delete some unneeded constants
 *
 *      Revision 1.3  1999/05/15 02:23:28  mike
 *      fix define for M_COS
 *
 *      Revision 1.2  1999/05/15 02:16:56  mike
 *      add check for number of decimal places
 *
 *      Revision 1.1  1999/05/12 20:51:22  mike
 *      Initial revision
 *
 *      $Id: m_apm_lc.h,v 1.45 2007/12/04 01:26:02 mike Exp $
 */

#ifndef M__APM_LOCAL_INC
#define M__APM_LOCAL_INC

#include "MSCore_Private.h"

/* 
 *   this supports older (and maybe newer?) Borland compilers.
 *   these Borland compilers define __MSDOS__
 */

#ifndef MSDOS
#ifdef __MSDOS__
#define MSDOS
#endif
#endif

/* 
 *   this supports some newer Borland compilers (i.e., v5.5).
 */

#ifndef MSDOS
#ifdef __BORLANDC__
#define MSDOS
#endif
#endif

/* 
 *   this supports the LCC-WIN32 compiler
 */

#ifndef MSDOS
#ifdef __LCC__
#define MSDOS
#endif
#endif

/* 
 *   this supports Micro$oft Visual C++ and also possibly older
 *   straight C compilers as well.
 */

#ifndef MSDOS
#ifdef _MSC_VER
#define MSDOS
#endif
#endif

/* 
 *   this supports the Metrowerks CodeWarrior 7.0 compiler (I think...)
 */

#ifndef MSDOS
#ifdef __MWERKS__
#define MSDOS
#endif
#endif

/* 
 *   this supports the MINGW 32 compiler
 */

#ifndef MSDOS
#ifdef __MINGW_H
#define MSDOS
#endif
#endif

/* 
 *   this supports the Open Watcom 1.0 compiler
 */

#ifndef MSDOS
#ifdef __WATCOMC__
#define MSDOS
#endif
#endif

/* 
 *   this supports the Digital Mars compiler
 */

#ifndef MSDOS
#ifdef __DMC__
#define MSDOS
#endif
#endif

/* 
 *   this supports National Instruments LabWindows CVI
 */

#ifndef _HAVE_NI_LABWIN_CVI_
#ifdef _CVI_
#define _HAVE_NI_LABWIN_CVI_
#warning supports National Instruments LabWindows CVI
#endif
#endif

/*
 *  If for some reason (RAM limitations, slow floating point, whatever) 
 *  you do NOT want to use the FFT multiply algorithm, un-comment the 
 *  #define below, delete mapm_fft.c and remove mapm_fft from the build.
 */

/*  #define NO_FFT_MULTIPLY  */

/*
 *      use your own memory management functions if desired.
 *      re-define MAPM_* below to point to your functions.
 *      an example is shown below.
 */

/*
extern   void   *memory_allocate(unsigned int);
extern   void   *memory_reallocate(void *, unsigned int);
extern   void   memory_free(void *);

#define  MAPM_MALLOC memory_allocate
#define  MAPM_REALLOC memory_reallocate
#define  MAPM_FREE memory_free
*/

/* default: use the standard C library memory functions ... */

#define  MAPM_MALLOC malloc
#define  MAPM_REALLOC realloc
#define  MAPM_FREE free

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#define M_APM_IDENT 0x6BCC9AE5

/* number of digits in the global constants, PI, E, etc */

#define VALID_DECIMAL_PLACES 128

extern  int     MM_lc_PI_digits;
extern  int     MM_lc_log_digits;

/*
 *   constants not in m_apm.h
 */

extern M_APM MM_0_5;
extern M_APM MM_0_85;
extern M_APM MM_5x_125R;
extern M_APM MM_5x_64R;
extern M_APM MM_5x_256R;
extern M_APM MM_5x_Eight;
extern M_APM MM_5x_Sixteen;
extern M_APM MM_5x_Twenty;
extern M_APM MM_lc_PI;
extern M_APM MM_lc_HALF_PI;
extern M_APM MM_lc_2_PI;
extern M_APM MM_lc_log2;
extern M_APM MM_lc_log10;
extern M_APM MM_lc_log10R;
extern M_APM MM_RND_AA;
extern M_APM MM_RND_MM;
extern M_APM MM_EXP_LOG2R;
extern M_APM MM_EXP_512R;

extern M_APM MM_CharMin;
extern M_APM MM_CharMax;
extern M_APM MM_ByteMax;
extern M_APM MM_ShortMin;
extern M_APM MM_ShortMax;
extern M_APM MM_UShortMax;
extern M_APM MM_IntMin;
extern M_APM MM_IntMax;
extern M_APM MM_UIntMax;
extern M_APM MM_LongMin;
extern M_APM MM_LongMax;
extern M_APM MM_ULongMax;
extern M_APM MM_IntegerMin;
extern M_APM MM_IntegerMax;
extern M_APM MM_UIntegerMax;

#define MM_ByteMin     MM_Zero
#define MM_UShortMin   MM_Zero
#define MM_UIntMin     MM_Zero
#define MM_ULongMin    MM_Zero
#define MM_UIntegerMin MM_Zero

extern UCHAR MM_MUL_DIV[10000];
extern UCHAR MM_MUL_REM[10000];
extern UCHAR MM_MUL_DIV_10[100];
extern UCHAR MM_MUL_REM_10[100];

extern int MM_BIT_LIMIT;
extern int MM_SIZEOF_INT;

/*
 *   type for holding fast multiplication context
 */

#ifdef NO_FFT_MULTIPLY
#define M_STACK_SIZE 240
#define M_ISTACK_SIZE 100
#else
#define M_STACK_SIZE 164
#define M_ISTACK_SIZE 72
#endif

// the context is not thread safe. Never use a context in two different threads
typedef struct {
  int    _exp_stack[M_ISTACK_SIZE];
  int    _exp_stack_ptr;

  UCHAR *_mul_stack_data[M_STACK_SIZE];
  int    _mul_stack_data_size[M_STACK_SIZE];
  int    _M_mul_stack_ptr;
} M_APM_FMC_struct;

typedef M_APM_FMC_struct *M_APM_FMC;

/*
 *   prototypes for internal functions
 */

extern M_APM_FMC M_init_fmul_context(void);
extern void      M_free_fmul_context(M_APM_FMC);

extern int  M_exp_compute_nn(int *, const M_APM, const M_APM);
extern void M_raw_exp(M_APM, int, const M_APM);
extern void M_raw_sin(M_APM, int, const M_APM);
extern void M_raw_cos(M_APM, int, const M_APM);
extern void M_5x_sin(M_APM, int, const M_APM);
extern void M_4x_cos(M_APM, int, const M_APM);
extern void M_5x_do_it(M_APM, int, const M_APM);
extern void M_4x_do_it(M_APM, int, const M_APM);

extern void M_apm_sdivide(M_APM, int, M_APM, M_APM);
extern void M_cos_to_sin(M_APM, int, M_APM);
extern void M_limit_angle_to_pi(M_APM, int, const M_APM);
extern void M_log_near_1(M_APM, int, const M_APM);
extern void M_get_sqrt_guess(M_APM, const M_APM);
extern void M_get_cbrt_guess(M_APM, const M_APM);
extern void M_get_log_guess(M_APM, const M_APM);
extern void M_get_asin_guess(M_APM, const M_APM);
extern void M_get_acos_guess(M_APM, const M_APM);
extern void M_arcsin_near_0(M_APM, int, const M_APM);
extern void M_arccos_near_0(M_APM, int, const M_APM);
extern void M_arctan_near_0(M_APM, int, const M_APM);
extern void M_arctan_large_input(M_APM, int, const M_APM);
extern void M_log_basic_iteration(M_APM, int, const M_APM);
extern void M_log_solve_cubic(M_APM, int, const M_APM);
extern void M_check_log_places(int);
MSCoreExtern void M_log_AGM_R_func(M_APM, int, M_APM, M_APM);
extern void M_get_div_rem(int,UCHAR *, UCHAR *);
extern void M_get_div_rem_10(int, UCHAR *, UCHAR *);
extern void M_apm_normalize(M_APM);
extern void M_apm_scale(M_APM, int);
extern void M_apm_pad(M_APM, int);
extern void M_ulong_2_ascii(char *, unsigned long long, int sign);
extern void M_check_PI_places(int);
extern void M_calculate_PI_AGM(M_APM, int);

extern void  M_set_to_zero(M_APM);
extern int   M_strposition(const char *, const char *);
extern char *M_lowercase(char *);
extern void  M_apm_log_error_msg(int, const char *);
extern void  M_apm_round_fixpt(M_APM, int, const M_APM);

#endif


/*
 *   THIS FILE HAS BEEN MODIFIED FROM THE OFFICIAL MAPM DISTRIBUTION
 *   BY 'Herve Malaingre/Logitud Solutions' on 2013/06/18.
 *
 *   THIS FILE IS ORIGINALLY FROM MAPM VERSION 4.9.5.
 *
 *   This file is part of MicroStep/MSCore library & Microstep/MSFoundation framework
 *   It is the last file containing any statics which are the
 *   common constants used by the library both internal and external
 *
 *   The modifications are :
 
 *   1) the function M_init_trig_globals() is replaced by M_init_mapm_constants()
 *   2) we did supress the M_free_all_cnst() function since we don't want these constants to be freed.
 *   3) we did supress the m_apm_cpp_precision() function and MM_cpp_min_precision static since we don't want any C++ here
 *   4) added all possible constants in this section
 */


/*
 *  M_APM  -  mapmcnst.c
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
 *      $Id: mapmcnst.c,v 1.24 2007/12/03 01:51:16 mike Exp $
 *
 *      This file contains declarations and initializes the constants
 * used throughout the library.
 *
 *      $Log: mapmcnst.c,v $
 *      Revision 1.24  2007/12/03 01:51:16  mike
 *      Update license
 *
 *      Revision 1.23  2003/05/06 21:28:53  mike
 *      add lib version functions
 *
 *      Revision 1.22  2003/03/30 21:14:16  mike
 *      add local copies of log(2) and log(10)
 *
 *      Revision 1.21  2002/11/03 22:45:29  mike
 *      Updated function parameters to use the modern style
 *
 *      Revision 1.20  2002/05/17 22:40:25  mike
 *      call m_apm_new from cpp_precision to init the library
 *      if it hasn't been done yet.
 *
 *      Revision 1.19  2001/07/16 19:40:12  mike
 *      add function M_free_all_cnst
 *
 *      Revision 1.18  2001/02/07 19:17:58  mike
 *      eliminate MM_skip_limit_PI_check
 *
 *      Revision 1.17  2000/05/19 16:31:02  mike
 *      add local copies for PI variables
 *
 *      Revision 1.16  2000/05/04 23:52:03  mike
 *      added new constant, 256R.
 *      renamed _008 to _125R
 *
 *      Revision 1.15  2000/04/11 18:44:21  mike
 *      no longer need the constant 'Fifteen'
 *
 *      Revision 1.14  2000/04/05 20:12:53  mike
 *      add C++ min precision function
 *
 *      Revision 1.13  1999/07/09 22:47:48  mike
 *      add skip limit PI check
 *
 *      Revision 1.12  1999/07/08 23:34:50  mike
 *      change constant
 *
 *      Revision 1.11  1999/07/08 22:58:08  mike
 *      add new constant
 *
 *      Revision 1.10  1999/06/23 01:09:53  mike
 *      added new constant 15
 *
 *      Revision 1.9  1999/06/20 23:32:30  mike
 *      added new constants
 *
 *      Revision 1.8  1999/06/20 19:24:14  mike
 *      delete constants no longer needed
 *
 *      Revision 1.7  1999/06/20 18:57:29  mike
 *      fixed missing init for new constants
 *
 *      Revision 1.6  1999/06/20 18:53:44  mike
 *      added more constants
 *
 *      Revision 1.5  1999/05/31 23:50:30  mike
 *      delete constants no longer needed
 *
 *      Revision 1.4  1999/05/14 19:50:22  mike
 *      added more constants with more digits
 *
 *      Revision 1.3  1999/05/12 20:53:08  mike
 *      added more constants
 *
 *      Revision 1.2  1999/05/10 21:52:24  mike
 *      added some comments
 *
 *      Revision 1.1  1999/05/10 20:56:31  mike
 *      Initial revision
 */

#include "m_apm_lc.h"

int MM_lc_PI_digits = 0;
int MM_lc_log_digits;

M_APM MM_Zero=          NULL;
M_APM MM_One=           NULL;
M_APM MM_Two=           NULL;
M_APM MM_Three=         NULL;
M_APM MM_Four=          NULL;
M_APM MM_Five=          NULL;
M_APM MM_Ten=           NULL;
M_APM MM_0_5=           NULL;
M_APM MM_E=             NULL;
M_APM MM_PI=            NULL;
M_APM MM_HALF_PI=       NULL;
M_APM MM_2_PI=          NULL;
M_APM MM_lc_PI=         NULL;
M_APM MM_lc_HALF_PI=    NULL;
M_APM MM_lc_2_PI=       NULL;
M_APM MM_lc_log2=       NULL;
M_APM MM_lc_log10=      NULL;
M_APM MM_lc_log10R=     NULL;
M_APM MM_0_85=          NULL;
M_APM MM_5x_125R=       NULL;
M_APM MM_5x_64R=        NULL;
M_APM MM_5x_256R=       NULL;
M_APM MM_5x_Eight=      NULL;
M_APM MM_5x_Sixteen=    NULL;
M_APM MM_5x_Twenty=     NULL;
M_APM MM_LOG_E_BASE_10= NULL;
M_APM MM_LOG_10_BASE_E= NULL;
M_APM MM_LOG_2_BASE_E=  NULL;
M_APM MM_LOG_3_BASE_E=  NULL;
M_APM MM_RND_AA=        NULL;
M_APM MM_RND_MM=        NULL;
M_APM MM_EXP_LOG2R=     NULL;
M_APM MM_EXP_512R=      NULL;

M_APM MM_CharMin=     NULL;
M_APM MM_CharMax=     NULL;
M_APM MM_ByteMax=     NULL;
M_APM MM_ShortMin=    NULL;
M_APM MM_ShortMax=    NULL;
M_APM MM_UShortMax=   NULL;
M_APM MM_IntMin=      NULL;
M_APM MM_IntMax=      NULL;
M_APM MM_UIntMax=     NULL;
M_APM MM_LongMin=     NULL;
M_APM MM_LongMax=     NULL;
M_APM MM_ULongMax=    NULL;
M_APM MM_IntegerMin=  NULL;
M_APM MM_IntegerMax=  NULL;
M_APM MM_UIntegerMax= NULL;

UCHAR MM_MUL_DIV[10000];
UCHAR MM_MUL_REM[10000];
UCHAR MM_MUL_DIV_10[100];
UCHAR MM_MUL_REM_10[100];

int  MM_BIT_LIMIT =  8 * sizeof(int) + 1;
int  MM_SIZEOF_INT = sizeof(int);

static char MM_cnst_PI[] =
"3.1415926535897932384626433832795028841971693993751058209749445923078\
1640628620899862803482534211706798214808651328230664709384460955";

static char MM_cnst_E[] =
"2.7182818284590452353602874713526624977572470936999595749669676277240\
76630353547594571382178525166427427466391932003059921817413596629";

static char MM_cnst_log_2[] =
"0.6931471805599453094172321214581765680755001343602552541206800094933\
93621969694715605863326996418687542001481020570685733685520235758";

static char MM_cnst_log_3[] =
"1.0986122886681096913952452369225257046474905578227494517346943336374\
9429321860896687361575481373208878797002906595786574236800422593";

static char MM_cnst_log_10[] =
"2.3025850929940456840179914546843642076011014886287729760333279009675\
7260967735248023599720508959829834196778404228624863340952546508";

static char MM_cnst_1_log_10[] =
"0.4342944819032518276511289189166050822943970058036665661144537831658\
64649208870774729224949338431748318706106744766303733641679287159";

/*
 *     the following constants have ~520 digits each, if needed
 */

/*
 static char MM_cnst_PI[] =
 "3.1415926535897932384626433832795028841971693993751058209749445923078\
 164062862089986280348253421170679821480865132823066470938446095505822\
 317253594081284811174502841027019385211055596446229489549303819644288\
 109756659334461284756482337867831652712019091456485669234603486104543\
 266482133936072602491412737245870066063155881748815209209628292540917\
 153643678925903600113305305488204665213841469519415116094330572703657\
 595919530921861173819326117931051185480744623799627495673518857527248\
 91227938183011949129833673362440656643";
 
 static char MM_cnst_E[] =
 "2.7182818284590452353602874713526624977572470936999595749669676277240\
 766303535475945713821785251664274274663919320030599218174135966290435\
 729003342952605956307381323286279434907632338298807531952510190115738\
 341879307021540891499348841675092447614606680822648001684774118537423\
 454424371075390777449920695517027618386062613313845830007520449338265\
 602976067371132007093287091274437470472306969772093101416928368190255\
 151086574637721112523897844250569536967707854499699679468644549059879\
 3163688923009879312773617821542499923";
 
 static char MM_cnst_log_2[] =
 "0.6931471805599453094172321214581765680755001343602552541206800094933\
 936219696947156058633269964186875420014810205706857336855202357581305\
 570326707516350759619307275708283714351903070386238916734711233501153\
 644979552391204751726815749320651555247341395258829504530070953263666\
 426541042391578149520437404303855008019441706416715186447128399681717\
 845469570262716310645461502572074024816377733896385506952606683411372\
 738737229289564935470257626520988596932019650585547647033067936544325\
 47632744951250406069438147104689946506";
 
 static char MM_cnst_log_3[] =
 "1.0986122886681096913952452369225257046474905578227494517346943336374\
 942932186089668736157548137320887879700290659578657423680042259305198\
 210528018707672774106031627691833813671793736988443609599037425703167\
 959115211455919177506713470549401667755802222031702529468975606901065\
 215056428681380363173732985777823669916547921318181490200301038236301\
 222486527481982259910974524908964580534670088459650857484441190188570\
 876474948670796130858294116021661211840014098255143919487688936798494\
 3022557315353296853452952514592138765";
 
 static char MM_cnst_log_10[] =
 "2.3025850929940456840179914546843642076011014886287729760333279009675\
 726096773524802359972050895982983419677840422862486334095254650828067\
 566662873690987816894829072083255546808437998948262331985283935053089\
 653777326288461633662222876982198867465436674744042432743651550489343\
 149393914796194044002221051017141748003688084012647080685567743216228\
 355220114804663715659121373450747856947683463616792101806445070648000\
 277502684916746550586856935673420670581136429224554405758925724208241\
 31469568901675894025677631135691929203";
 
 static char MM_cnst_1_log_10[] =
 "0.4342944819032518276511289189166050822943970058036665661144537831658\
 646492088707747292249493384317483187061067447663037336416792871589639\
 065692210646628122658521270865686703295933708696588266883311636077384\
 905142844348666768646586085135561482123487653435434357317253835622281\
 395603048646652366095539377356176323431916710991411597894962993512457\
 934926357655469077671082419150479910989674900103277537653570270087328\
 550951731440674697951899513594088040423931518868108402544654089797029\
 86328682876262414401345704354613292060";
 */


/****************************************************************************/
char *m_apm_lib_version(char *v)
{
  strcpy(v, MAPM_LIB_VERSION);
  return(v);
}
/****************************************************************************/
char *m_apm_lib_short_version(char *v)
{
  strcpy(v, MAPM_LIB_SHORT_VERSION);
  return(v);
}
/****************************************************************************/
void M_init_mapm_constants(void)
{
  int i;
  UCHAR ndiv, nrem;
  
  ndiv = 0;
  nrem = 0;
  for (i = 0; i < 100; i++) {
    MM_MUL_DIV_10[i] = ndiv;
    MM_MUL_REM_10[i] = nrem;
 
    if (++nrem == 10) {
      nrem = 0;
      ndiv++;
    }
  }
  
  ndiv = 0;
  nrem = 0;
  for (i = 0; i < 10000; i++) {
    MM_MUL_DIV[i] = ndiv;
    MM_MUL_REM[i] = nrem;
    
    if (++nrem == 100)
    {
      nrem = 0;
      ndiv++;
    }
  }
  
  MM_lc_PI_digits  = VALID_DECIMAL_PLACES;
  MM_lc_log_digits = VALID_DECIMAL_PLACES;
  
  
  MM_Zero          = m_apm_new();
  MM_One           = m_apm_new();
  MM_Two           = m_apm_new();
  MM_Three         = m_apm_new();
  MM_Four          = m_apm_new();
  MM_Five          = m_apm_new();
  MM_Ten           = m_apm_new();
  MM_0_5           = m_apm_new();
  MM_LOG_2_BASE_E  = m_apm_new();
  MM_LOG_3_BASE_E  = m_apm_new();
  MM_E             = m_apm_new();
  MM_PI            = m_apm_new();
  MM_HALF_PI       = m_apm_new();
  MM_2_PI          = m_apm_new();
  MM_lc_PI         = m_apm_new();
  MM_lc_HALF_PI    = m_apm_new();
  MM_lc_2_PI       = m_apm_new();
  MM_lc_log2       = m_apm_new();
  MM_lc_log10      = m_apm_new();
  MM_lc_log10R     = m_apm_new();
  MM_0_85          = m_apm_new();
  MM_5x_125R       = m_apm_new();
  MM_5x_64R        = m_apm_new();
  MM_5x_256R       = m_apm_new();
  MM_5x_Eight      = m_apm_new();
  MM_5x_Sixteen    = m_apm_new();
  MM_5x_Twenty     = m_apm_new();
  MM_LOG_E_BASE_10 = m_apm_new();
  MM_LOG_10_BASE_E = m_apm_new();
  MM_RND_AA        = m_apm_new();
  MM_RND_MM        = m_apm_new();
  MM_EXP_LOG2R     = m_apm_new();
  MM_EXP_512R      = m_apm_new();

  MM_CharMin       = m_apm_new();
  MM_CharMax       = m_apm_new();
  MM_ByteMax       = m_apm_new();
  MM_ShortMin      = m_apm_new();
  MM_ShortMax      = m_apm_new();
  MM_UShortMax     = m_apm_new();
  MM_IntMin        = m_apm_new();
  MM_IntMax        = m_apm_new();
  MM_UIntMax       = m_apm_new();
  MM_LongMin       = m_apm_new();
  MM_LongMax       = m_apm_new();
  MM_ULongMax      = m_apm_new();
  MM_IntegerMin    = m_apm_new();
  MM_IntegerMax    = m_apm_new();
  MM_UIntegerMax   = m_apm_new();
  
  m_apm_set_string(MM_One  ,  "1");
  m_apm_set_string(MM_Two  ,  "2");
  m_apm_set_string(MM_Three,  "3");
  m_apm_set_string(MM_Four ,  "4");
  m_apm_set_string(MM_Five ,  "5");
  m_apm_set_string(MM_Ten  , "10");
  m_apm_set_string(MM_0_5  ,  "0.5");
  m_apm_set_string(MM_0_85 ,  "0.85");
  
  m_apm_set_string(MM_5x_125R   , "8.0E-3");
  m_apm_set_string(MM_5x_64R    , "1.5625E-2");
  m_apm_set_string(MM_5x_256R   , "3.90625E-3");
  m_apm_set_string(MM_5x_Eight  ,  "8");
  m_apm_set_string(MM_5x_Sixteen, "16");
  m_apm_set_string(MM_5x_Twenty , "20");
  
  m_apm_set_string(MM_LOG_2_BASE_E , MM_cnst_log_2);
  m_apm_set_string(MM_LOG_3_BASE_E , MM_cnst_log_3);
  m_apm_set_string(MM_LOG_10_BASE_E, MM_cnst_log_10);
  m_apm_set_string(MM_LOG_E_BASE_10, MM_cnst_1_log_10);
  
  m_apm_set_string(MM_lc_log2  , MM_cnst_log_2);
  m_apm_set_string(MM_lc_log10 , MM_cnst_log_10);
  m_apm_set_string(MM_lc_log10R, MM_cnst_1_log_10);
  
  m_apm_set_string(MM_E , MM_cnst_E);
  m_apm_set_string(MM_PI, MM_cnst_PI);
  
  m_apm_set_string(MM_RND_AA   , "716805947629621");
  m_apm_set_string(MM_RND_MM   , "1.0E15");
  m_apm_set_string(MM_EXP_LOG2R, "1.44269504089");   /* ~ 1 / log(2) */
  m_apm_set_string(MM_EXP_512R , "1.953125E-3");     /*   1 / 512    */
  
  m_apm_set_long( MM_CharMin,     MSCharMin);
  m_apm_set_long( MM_CharMax,     MSCharMax);
  m_apm_set_long( MM_ByteMax,     MSByteMax);
  m_apm_set_long( MM_ShortMin,    MSShortMin);
  m_apm_set_long( MM_ShortMax,    MSShortMax);
  m_apm_set_long( MM_UShortMax,   MSUShortMax);
  m_apm_set_long( MM_IntMin,      MSIntMin);
  m_apm_set_long( MM_IntMax,      MSIntMax);
  m_apm_set_long( MM_UIntMax,     MSUIntMax);
  m_apm_set_long( MM_LongMin,     MSLongMin);
  m_apm_set_long( MM_LongMax,     MSLongMax);
  m_apm_set_ulong(MM_ULongMax,    MSULongMax);
  m_apm_set_long( MM_IntegerMin,  NSIntegerMin);
  m_apm_set_long( MM_IntegerMax,  NSIntegerMax);
  m_apm_set_ulong(MM_UIntegerMax, NSUIntegerMax);

  m_apm_multiply(MM_HALF_PI, MM_PI, MM_0_5);
  m_apm_multiply(MM_2_PI, MM_PI, MM_Two);
  
  m_apm_copy(MM_lc_PI     , MM_PI);
  m_apm_copy(MM_lc_HALF_PI, MM_HALF_PI);
  m_apm_copy(MM_lc_2_PI   , MM_2_PI);
}
/****************************************************************************/

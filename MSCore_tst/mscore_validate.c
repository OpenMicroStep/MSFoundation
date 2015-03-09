//
//  mscore_validate.c
//  MSFoundation
//
//  Created by Vincent Rouillé on 26/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#include "mscore_validate.h"

test_t MSCoreTests[]= {
  {"c"          ,mscore_c          ,NULL,INTITIALIZE_TEST_T_END},
  {"tools"      ,mscore_tools      ,NULL,INTITIALIZE_TEST_T_END},
  {"carray"     ,mscore_carray     ,NULL,INTITIALIZE_TEST_T_END},
  {"cbuffer"    ,mscore_cbuffer    ,NULL,INTITIALIZE_TEST_T_END},
  {"ccolor"     ,mscore_ccolor     ,NULL,INTITIALIZE_TEST_T_END},
  {"ccouple"    ,mscore_ccouple    ,NULL,INTITIALIZE_TEST_T_END},
  {"cdate"      ,mscore_cdate      ,NULL,INTITIALIZE_TEST_T_END},
  {"mapm"       ,mscore_mapm       ,NULL,INTITIALIZE_TEST_T_END},
  {"cdecimal"   ,mscore_cdecimal   ,NULL,INTITIALIZE_TEST_T_END},
  {"cdictionary",mscore_cdictionary,NULL,INTITIALIZE_TEST_T_END},
  {"ses"        ,mscore_ses        ,NULL,INTITIALIZE_TEST_T_END},
  {"cstring"    ,mscore_cstring    ,NULL,INTITIALIZE_TEST_T_END},
//{"mste"       ,mscore_mste       ,NULL,INTITIALIZE_TEST_T_END},
  {NULL}};

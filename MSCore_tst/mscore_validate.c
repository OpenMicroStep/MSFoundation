//
//  mscore_validate.c
//  MSFoundation
//
//  Created by Vincent Rouillé on 26/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#include "mscore_validate.h"

testdef_t MSCoreTests[]= {
  {"c"          ,mscore_c          ,NULL},
  {"tools"      ,mscore_tools      ,NULL},
  {"carray"     ,mscore_carray     ,NULL},
  {"cbuffer"    ,mscore_cbuffer    ,NULL},
  {"ccolor"     ,mscore_ccolor     ,NULL},
  {"ccouple"    ,mscore_ccouple    ,NULL},
  {"cdate"      ,mscore_cdate      ,NULL},
  {"mapm"       ,mscore_mapm       ,NULL},
  {"cdecimal"   ,mscore_cdecimal   ,NULL},
  {"cdictionary",mscore_cdictionary,NULL},
  {"ses"        ,mscore_ses        ,NULL},
  {"cstring"    ,mscore_cstring    ,NULL},
  {"ctraverse"  ,mscore_ctraverse  ,NULL},
//{"mste"       ,mscore_mste       ,NULL},
  {NULL}};

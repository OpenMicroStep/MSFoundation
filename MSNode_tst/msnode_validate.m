//
//  mscore_validate.c
//  MSFoundation
//
//  Created by Vincent Rouillé on 26/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#include "msnode_validate.h"

EXTERN_TESTS_BASE

testdef_t RootTests[]= {
  {"utils"       ,msnode_utils      ,NULL},
  {"promise"     ,msnode_promise    ,NULL},
  {"tcp"         ,msnode_tcp        ,NULL},
  {"form"        ,msnode_form       ,NULL},
  {NULL}};

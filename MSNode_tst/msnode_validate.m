//
//  mscore_validate.c
//  MSFoundation
//
//  Created by Vincent Rouillé on 26/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#include "msnode_validate.h"

EXTERN_TESTS_BASE

LIBEXPORT test_t RootTests[];

test_t RootTests[]= {
  {"utils"       ,msnode_utils      ,NULL,INTITIALIZE_TEST_T_END},
  {"promise"     ,msnode_promise    ,NULL,INTITIALIZE_TEST_T_END},
  {"tcp"         ,msnode_tcp        ,NULL,INTITIALIZE_TEST_T_END},
  {"form"        ,msnode_form       ,NULL,INTITIALIZE_TEST_T_END},
  {NULL}};

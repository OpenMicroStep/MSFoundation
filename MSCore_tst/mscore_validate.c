//
//  mscore_validate.c
//  MSFoundation
//
//  Created by Vincent Rouillé on 26/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#include "mscore_validate.h"

int testCore(BOOL alone)
{
  int err= 0;
  if (alone) {
    printf("********** Test of the Microstep MSCore Library **********\n");
    #ifdef MSCORE_STANDALONE
    printf("********** MSCORE_STANDALONE\n\n");
    #else
    printf("********** MSCORE\n\n");
    #endif
  }
  err= mscore_c_validate          () +
       mscore_tools_validate      () +
       mscore_carray_validate     () +
       mscore_cbuffer_validate    () +
       mscore_ccolor_validate     () +
       mscore_ccouple_validate    () +
       mscore_cdate_validate      () +
       mapm_validate              () +
       mscore_cdecimal_validate   () +
       mscore_cdictionary_validate() +
       mscore_cstring_validate    () +
       //mscore_mste_validate       () +
       0;
  if (alone) {
    if (!err)
      printf("\n********** ALL THE TESTS ARE SUCCESSFUL !!!     **********\n\n");
    else
      printf("\n**** FAIL *** FAIL *** FAIL *** FAIL *** FAIL *** FAIL ***\n\n");}
  return err;
}

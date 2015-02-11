//
//  mscore_validate.c
//  MSFoundation
//
//  Created by Vincent Rouillé on 26/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#include "mscore_validate.h"

TEST_FCT_BEGIN(MSCore)
    testRun("c", mscore_c_validate);
    testRun("tools", mscore_tools_validate);
    testRun("carray", mscore_carray_validate);
    testRun("cbuffer", mscore_cbuffer_validate);
    testRun("ccolor", mscore_ccolor_validate);
    testRun("ccouple", mscore_ccouple_validate);
    testRun("cdate", mscore_cdate_validate);
    testRun("mapm", mapm_validate);
    testRun("cdecimal", mscore_cdecimal_validate);
    testRun("cdictionary", mscore_cdictionary_validate);
    testRun("ses", mscore_ses_validate);
    testRun("cstring", mscore_cstring_validate);
TEST_FCT_END(MSCore)

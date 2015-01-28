//
//  NSObject_test.m
//  MSFoundation
//
//  Created by Vincent Rouillé on 26/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#import "foundation_validate.h"

TEST_FCT_BEGIN(retain)
    id obj = [NSObject new];
    ASSERT_EQUALS([obj retainCount], 1, "retain count of [NSObject new] must be one: %d != %d");
    [obj release];
TEST_FCT_END(retain)

TEST_FCT_BEGIN(NSObject)
    TEST_FCT(retain);
TEST_FCT_END(NSObject)

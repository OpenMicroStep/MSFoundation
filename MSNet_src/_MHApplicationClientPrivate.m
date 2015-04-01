//
//  MHApplicationClient.m
//
//
//  Created by Geoffrey Guilbon on 29/10/13.
//  Copyright (c) 2013 Geoffrey Guilbon. All rights reserved.
//

#import "MSNet_Private.h"

@implementation MHApplicationClient (Private)

- (MSInt)authenticationLevel
{
    MSInt level = AUTH_0_STEP ;
    
    switch (_authenticationType) {
        case MHAuthCustom:
        case MHAuthSimpleGUIPasswordAndLogin:
            level = AUTH_1_STEP ;
            break;
            
        case MHAuthChallengedPasswordLogin:
        case MHAuthChallengedPasswordLoginOnTarget:
        case MHAuthPKChallengeAndURN:
            level = AUTH_2_STEPS ;
            break ;
            
        default:
            level = AUTH_0_STEP ;
            break;
    }
    
    return level ;
}

@end

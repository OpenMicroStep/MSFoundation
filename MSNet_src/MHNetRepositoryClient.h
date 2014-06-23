//
//  MHRepositoryClient.h
//  testRepository
//
//  Created by Geoffrey Guilbon on 25/10/13.
//  Copyright (c) 2013 Geoffrey Guilbon. All rights reserved.
//

@class TID ;

@interface MHNetRepositoryClient : MHApplicationClient

- (NSString *)publicKeyForURN:(NSString *)urn ;
- (BOOL)verifyChallengedPassword:(NSString *)password
                        forLogin:(NSString *)login
                    andChallenge:(NSString *)challenge ;

@end

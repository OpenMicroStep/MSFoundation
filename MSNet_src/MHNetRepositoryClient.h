//
//  MHRepositoryClient.h
//  testRepository
//
//  Created by Geoffrey Guilbon on 25/10/13.
//  Copyright (c) 2013 Geoffrey Guilbon. All rights reserved.
//

@class TID ;

@interface MHNetRepositoryClient : MHApplicationClient

- (TID *)identifierForUrn:(NSString *)urn ;
- (NSDictionary *)getPublicInformationsForKeys:(NSArray *)keys inTree:(NSString *)tree underIdentifier:(TID *)identifier ;

@end

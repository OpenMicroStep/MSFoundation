//
//  MHRepositoryAdditions.h
//  MSFoundation
//
//  Created by Geoffrey Guilbon on 05/06/2014.
//
//

@interface MHRepository (MHRepositoryAdditions)

//Authentication interface methods
+ (MSInt)openRepositoryDataBaseWithParameters:(NSDictionary *)parameters ;
+ (NSString *)challengedPublicKeyForURN:(NSString *)urn ;

- (id)initWithDecodedChallenge:(NSString *)decodedChallenge forURN:(NSString *)urn ;

- (id)initWithChallenge:(NSString *)challenge
     challengedPassword:(NSString *)challengedPassword
               forLogin:(NSString *)login ;

- (BOOL)verifyChallenge:(NSString *)challenge
     challengedPassword:(NSString *)challengedPassword
               forLogin:(NSString *)login ;

- (id)rightsForEid:(EID *)eid onEid:(EID *)targetEid ;

//other methods
+ (NSString *)publicKeyForURN:(NSString *)urn ;

- (NSString *)hashedPasswordForLogin:(NSString *)login ;
- (EID *)eidForLogin:(NSString *)login ;
- (EID *)eid ;

@end

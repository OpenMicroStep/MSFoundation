//
//  _MHNetRepository.h
//  MSFoundation
//
//  Created by Geoffrey Guilbon on 28/10/13.
//
//

@class TID ;

@interface MHNetRepository : NSObject
{
    NSDictionary *_database ;
}

+ (NSDictionary *)loadDatabaseFromFile:(NSString *)file ;

+ (id)repositoryWithDatabase:(NSDictionary *)database ;
- (id)initWithDatabase:(NSDictionary *)database ;

- (BOOL)validateAuthenticationWithCertificate:(MSCertificate *)certificate notification:(MHNotification *)notification ;
- (TID *)identifierForURN:(NSString *)urn notification:(MHNotification *)notification ;
- (NSDictionary *)getPublicInformationsForKeys:(NSArray *)keys inTree:(NSString *)tree underIdentifier:(TID *)tid notification:(MHNotification *)notification ;

@end

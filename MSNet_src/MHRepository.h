//  MHRepository.h, ecb, 131010

#define EID NSNumber

@interface MHRepository : NSObject
{
@private
    EID *_connectedEid;
    EID *_representativeEid;
}

//----------
+ (void)setDatabase:(NSDictionary *)database ;
+ (NSDictionary *)database ;

+ (NSString *)generateAndStoreChallengeForURN:(NSString *)urn ;
+ (NSString *)plainStoredChallengeForURN:(NSString *)urn ;


//----------
+ (EID*)eidForURN:(NSString*)name ;


/*

- (id)initForEid:(EID*)eid withCertificate:(MSCertificate*)certif inRepositoryDatabase:(NSDictionary *)database;
// Pour ouvrir une session, il faut être un eid avec un certificat valide.
- (id)initForEid:(EID*)eid withRepresentativeEid:(EID*)coEid withCertificate:(MSCertificate*)certif inRepositoryDatabase:(NSDictionary *)database;
// Ou avoir un représentant (connu de l'annuaire) avec un certificat valide.


- (BOOL)isCertificate:(MSCertificate*)certif verifiedForEid:(EID*)eid;
*/
 
- (NSArray*)eidsGraphOf:(NSString*)k startingAt:(EID*)eid;
// Values for attribute k must be eids.

+ (NSDictionary*)publicInformationsWithKey: (NSString*)k forEid: (EID*)eid;

- (NSDictionary*)publicInformationsWithKey: (NSString*)k forEid: (EID*)eid;
- (NSDictionary*)publicInformationsWithKey: (NSString*)k forEids:(NSArray*)eids;
- (NSDictionary*)publicInformationsWithKeys:(NSArray*)ks forEid: (EID*)eid;
- (NSDictionary*)publicInformationsWithKeys:(NSArray*)ks forEids:(NSArray*)eids;
// eid1= {k1= [v]; k2= [v1, v2];}
// En k=0 on obtient le type (ID|STR) et la cardinalité (single|multi) de chaque clé:
//   0= {k1= {type= STR; cardinality= single;}; k2= {type= ID; cardinality= multi;};}
// Les clés de ks doivent être connues de l'annuaire.

- (NSDictionary*)informationsWithKey:(NSString*)k;
- (NSDictionary*)informationsWithKeys:(NSArray*)ks;
@end

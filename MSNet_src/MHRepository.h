//  MHRepository.h, ecb, 131010

#define MHRElementId NSNumber

@interface MHRepository : NSObject
{
@private
    NSMutableDictionary *_db;
    MHRElementId *_connectedEid;
    MHRElementId *_representativeEid;
}

+ (MHRElementId*)eidForUniqueRepositoryName:(NSString*)name inRepositoryDatabase:(NSDictionary *)database;

- (id)initForEid:(MHRElementId*)eid withCertificate:(MSCertificate*)certif inRepositoryDatabase:(NSDictionary *)database;
// Pour ouvrir une session, il faut être un eid avec un certificat valide.
- (id)initForEid:(MHRElementId*)eid withRepresentativeEid:(MHRElementId*)coEid withCertificate:(MSCertificate*)certif inRepositoryDatabase:(NSDictionary *)database;
// Ou avoir un représentant (connu de l'annuaire) avec un certificat valide.

- (BOOL)isCertificate:(MSCertificate*)certif verifiedForEid:(MHRElementId*)eid;

- (NSArray*)eidsGraphOf:(NSString*)k startingAt:(MHRElementId*)eid;
// Values for attribute k must be eids.

- (NSDictionary*)publicInformationsWithKey: (NSString*)k forEid: (MHRElementId*)eid;
- (NSDictionary*)publicInformationsWithKey: (NSString*)k forEids:(NSArray*)eids;
- (NSDictionary*)publicInformationsWithKeys:(NSArray*)ks forEid: (MHRElementId*)eid;
- (NSDictionary*)publicInformationsWithKeys:(NSArray*)ks forEids:(NSArray*)eids;
// eid1= {k1= [v]; k2= [v1, v2];}
// En k=0 on obtient le type (ID|STR) et la cardinalité (single|multi) de chaque clé:
//   0= {k1= {type= STR; cardinality= single;}; k2= {type= ID; cardinality= multi;};}
// Les clés de ks doivent être connues de l'annuaire.

- (NSDictionary*)informationsWithKey:(NSString*)k;
- (NSDictionary*)informationsWithKeys:(NSArray*)ks;
@end

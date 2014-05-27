//  MHRepository.m, ecb, 131010

#import "MHRepositoryKit.h"

NSMutableDictionary *__certificateTimeout;

static inline NSArray *_infos(NSDictionary *db, id e, id k)
{
    NSArray *o;
    if ((o= [(NSDictionary*)[db objectForKey:e] objectForKey:k])) {
        if (![o isKindOfClass:[NSArray class]]) o=[NSArray arrayWithObject:o];}
    return o;
}

@implementation MHRepository

+ (void)initialize
{
    __certificateTimeout= [NSMutableDictionary new];
}

- (id)init
{
    return [self initForEid:nil withCertificate:nil inRepositoryDatabase:nil];
}

- (MSCertificate *)_certificateFromString:(NSString *)certificateString
{
    MSCertificate *cert= nil;
    
    if ([certificateString length])
    {
        void *bytes;
        MSBuffer *buf;
        
        bytes= (void *)[certificateString UTF8String];
        buf= AUTORELEASE(MSCreateBufferWithBytes(bytes, strlen(bytes)));
        
        cert= [MSCertificate certificateWithBuffer:buf];
    }
    
    return cert;
}

- (id)initForEid:(MHRElementId*)eid withCertificate:(MSCertificate*)certif inRepositoryDatabase:(NSDictionary *)database
{
    ASSIGN(_db, database) ;
    if ([self isCertificate:certif verifiedForEid:eid]) {
        _connectedEid= [eid retain];}
    else {
        [self release]; self= nil;}
    return self;
}

static inline BOOL _isRepresentativeFor(NSDictionary *db, id r, id e)
{
    return [_infos(db, e, @"representative eid") containsObject:r];
}

- (id)initForEid:(MHRElementId*)eid withRepresentativeEid:(MHRElementId*)coEid
 withCertificate:(MSCertificate*)certif inRepositoryDatabase:(NSDictionary *)database
{
    ASSIGN(_db, database) ;
    if (_isRepresentativeFor(_db,coEid,eid) &&
        [self isCertificate:certif verifiedForEid:coEid]) {
        // et vérifier aussi que coEid est un représentat valide pour eid
        _connectedEid=      [eid   retain];
        _representativeEid= [coEid retain];}
    else {
        [self release]; self= nil;}
    return self;
}

- (void)dealloc
{
    DESTROY(_db) ;
    DESTROY(_connectedEid) ;
    DESTROY(_representativeEid) ;
    [super dealloc];
}

+ (MHRElementId*)eidForUniqueRepositoryName:(NSString*)name inRepositoryDatabase:(NSDictionary *)database
{
    MHRElementId *eid= nil;
    NSDictionary *o; id ke,k,urn;
    for (ke= [database keyEnumerator]; !eid && (k= [ke nextObject]);) {
        if ([k intValue]) // do not check eid 0
        {
            o= [database objectForKey:k];
            urn= [o objectForKey:@"urn"];
            if ([name isEqualToString:urn]) eid= k ;
        }
    }
    return eid;
}

- (BOOL)isCertificate:(MSCertificate*)givenCertif verifiedForEid:(MHRElementId*)eid
{
    BOOL ret= NO;
    NSDate *tOut; id now,later;
    MSCertificate *knownCertif;
    if (!eid) return NO;
    tOut= [__certificateTimeout objectForKey:eid];
    now= [NSDate date];
    if (tOut && [tOut compare:now]==NSOrderedDescending) {
        ret= YES;}
    else {
        NSString *certStr= [(NSDictionary*)[_db objectForKey:eid] objectForKey:@"certificate"];
        knownCertif= [self _certificateFromString:certStr];
        // S'il y a un certificat, le vérifier !
        // Pour l'instant, sa seule présence nous suffit.
        if (isCertificateVerified(givenCertif, knownCertif)) {
            later= [now dateByAddingTimeInterval:24*3600];
            [__certificateTimeout setObject:later forKey:eid];
            ret= YES;}}
    return ret;
}

static inline void _recTree(id db, id k, id currentNodes, id allNodes)
{
    id ne,n,xs,xe,x;
    NSMutableArray *subs= [NSMutableArray array];
    // subs est l'ensemble de tous les sous-nœuds (non vus) de currentNodes.
    for (ne= [currentNodes objectEnumerator]; (n= [ne nextObject]);) {
        xs= _infos(db, n, k);
        for (xe= [xs objectEnumerator]; (x= [xe nextObject]);) {
            if (![allNodes containsObject:x]) {
                [subs addObject:x]; [allNodes addObject:x];}}}
    if ([subs count]) _recTree(db, k, subs, allNodes);
}
- (NSArray*)eidsGraphOf:(NSString*)k startingAt:(MHRElementId*)eid
{
    // TODO: utiliser des sorted arrays
    id publicKeys,currentNodes,allNodes;
    publicKeys= [(NSDictionary*)[_db objectForKey:[MHRElementId numberWithInt:0]]
                 objectForKey:@"repository public key"];
    currentNodes= [NSArray arrayWithObject:eid];
    allNodes= [NSMutableArray arrayWithObject:eid];
    if ([publicKeys containsObject:k]) {
        _recTree(_db, k, currentNodes, allNodes);}
    return allNodes;
}

static inline BOOL _carTypeAndCardinality(NSString* k, NSString** t, NSString** c, NSDictionary *_db)
// Si on demande le type, il doit exister.
// Si on demande la cardinalité, elle doit exister.
// Sinon retourne NO.
{
  NSDictionary *def;
  BOOL ret;
  def= [(NSDictionary*)[_db objectForKey:[MHRElementId numberWithInt:0]]
    objectForKey:k];
  ret= def &&
       (!t || (*t= [def objectForKey:@"type"])) &&
       (!c || (*c= [def objectForKey:@"cardinality"]));
  return ret;
}
- (NSDictionary*)_infosWithKeys:(NSArray*)ks forEids:(NSArray*)eids
{
    NSMutableDictionary *d, *ret;
    id ee,e,ks2,ke,k,t,c;
    ret= [NSMutableDictionary dictionary];
    //NSLog(@"%@ %@",ks,eids);
    // On vérifie tout d'abord les clés.
    ks2= [NSMutableArray array];
    d= [NSMutableDictionary dictionary];
    for (ke= [ks objectEnumerator]; (k= [ke nextObject]);) {
        if (_carTypeAndCardinality(k,&t,&c,_db)) {
            [ks2 addObject:k];
            [d setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                t,@"type",c, @"cardinality",nil] forKey:k];}}
    if ([d count]) [ret setObject:d forKey:[MHRElementId numberWithInt:0]];
    // Recherche des infos pour tous les éléments et toutes les clés valides.
    for (ee= [eids objectEnumerator]; (e= [ee nextObject]);) {
        d= [NSMutableDictionary dictionary];
        for (ke= [ks2 objectEnumerator]; (k= [ke nextObject]);) {
            NSArray *o= _infos(_db, e, k);
            if ([o count]) [d setObject:o forKey:k];}
        if ([d count]) [ret setObject:d forKey:e];}
    return ret;
}

static inline NSArray *_publicKeysOnly(NSArray *ks, NSDictionary *_db)
{
    NSMutableArray *nks;
    id publicKeys,ke,k;
    // reduce ks to public keys
    nks= [NSMutableArray array];
    publicKeys= [(NSDictionary*)[_db objectForKey:[MHRElementId numberWithInt:0]]
                 objectForKey:@"repository public key"];
    for (ke= [ks objectEnumerator]; (k= [ke nextObject]);) {
        if ([publicKeys containsObject:k]) [nks addObject:k];}
    return nks;
}
- (NSDictionary*)publicInformationsWithKeys:(NSArray*)ks forEids:(NSArray*)eids
{
    return [self _infosWithKeys:_publicKeysOnly(ks, _db) forEids:eids];
}
- (NSDictionary*)publicInformationsWithKey:(NSString*)k forEid:(MHRElementId*)eid
{
    return [self _infosWithKeys:_publicKeysOnly([NSArray arrayWithObject:k], _db)
                        forEids:[NSArray arrayWithObject:eid]];
}
- (NSDictionary*)publicInformationsWithKey:(NSString*)k forEids:(NSArray*)eids
{
    return [self _infosWithKeys:_publicKeysOnly([NSArray arrayWithObject:k], _db)
                        forEids:eids];
}
- (NSDictionary*)publicInformationsWithKeys:(NSArray*)ks forEid:(MHRElementId*)eid
{
    return [self _infosWithKeys:_publicKeysOnly(ks, _db)
                        forEids:[NSArray arrayWithObject:[NSArray arrayWithObject:eid]]];
}

- (NSDictionary*)informationsWithKey:(NSString*)k
{
    return [self _infosWithKeys:[NSArray arrayWithObject:k]
                        forEids:[NSArray arrayWithObject:_connectedEid]];
}
- (NSDictionary*)informationsWithKeys:(NSArray*)ks
{
    return [self _infosWithKeys:ks
                        forEids:[NSArray arrayWithObject:_connectedEid]];
}

@end

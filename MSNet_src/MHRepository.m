//  MHRepository.m, ecb, 131010

#import "MHRepositoryKit.h"

static NSMutableDictionary *__db = nil ;
static NSMutableDictionary * __plainChallengeForURN = nil ;

NSMutableDictionary *__certificateTimeout;

static inline NSArray *_infos(NSDictionary *db, id e, id k)
{
    NSArray *o;
    if ((o= [(NSDictionary*)[db objectForKey:e] objectForKey:k])) {
        if (![o isKindOfClass:[NSArray class]]) o=[NSArray arrayWithObject:o];}
    
    return o;
}

@implementation MHRepository

+ (void)setDatabase:(NSDictionary *)database
{
    if (!__db) { __db = (NSMutableDictionary *)[database retain] ; }
}

+ (NSDictionary *)database { return __db ; }

+ (NSMutableDictionary *)_challengeDictionary
{
    if (!__plainChallengeForURN)
    {
        __plainChallengeForURN = [[NSMutableDictionary dictionary] retain] ;
    }
    
    return __plainChallengeForURN ;
}

+ (void)initialize
{
    __certificateTimeout= [NSMutableDictionary new];
}

/*- (id)init
{
    return [self initForEid:nil withCertificate:nil inRepositoryDatabase:nil];
}*/

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

/*- (id)initForEid:(EID*)eid withCertificate:(MSCertificate*)certif inRepositoryDatabase:(NSDictionary *)database
{
    [isa setDatabase:database] ;
    
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

- (id)initForEid:(EID*)eid withRepresentativeEid:(EID*)coEid
 withCertificate:(MSCertificate*)certif inRepositoryDatabase:(NSDictionary *)database
{
    [isa setDatabase:database] ;
    
    if (_isRepresentativeFor(__db,coEid,eid) &&
        [self isCertificate:certif verifiedForEid:coEid]) {
        // et vérifier aussi que coEid est un représentat valide pour eid
        _connectedEid=      [eid   retain];
        _representativeEid= [coEid retain];}
    else {
        [self release]; self= nil;}
    return self;
}*/

- (void)dealloc
{
    if (__db) { [__db release] ; }
    DESTROY(_connectedEid) ;
    DESTROY(_representativeEid) ;
    [super dealloc];
}

+ (EID*)eidForURN:(NSString*)name
{
    EID *eid= nil;
    NSDictionary *database = [self database] ;
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

/*- (BOOL)isCertificate:(MSCertificate*)givenCertif verifiedForEid:(EID*)eid
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
        NSString *certStr= [(NSDictionary*)[__db objectForKey:eid] objectForKey:@"certificate"];
        knownCertif= [self _certificateFromString:certStr];
        // S'il y a un certificat, le vérifier !
        // Pour l'instant, sa seule présence nous suffit.
        if (isCertificateVerified(givenCertif, knownCertif)) {
            later= [now dateByAddingTimeInterval:24*3600];
            [__certificateTimeout setObject:later forKey:eid];
            ret= YES;}}
    return ret;
}*/

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
- (NSArray*)eidsGraphOf:(NSString*)k startingAt:(EID*)eid
{
    // TODO: utiliser des sorted arrays
    id publicKeys,currentNodes,allNodes;
    publicKeys= [(NSDictionary*)[__db objectForKey:[EID numberWithInt:0]]
                 objectForKey:@"repository public key"];
    currentNodes= [NSArray arrayWithObject:eid];
    allNodes= [NSMutableArray arrayWithObject:eid];
    if ([publicKeys containsObject:k]) {
        _recTree(__db, k, currentNodes, allNodes);}
    return allNodes;
}

static inline BOOL _carTypeAndCardinality(NSString* k, NSString** t, NSString** c, NSDictionary *db)
// Si on demande le type, il doit exister.
// Si on demande la cardinalité, elle doit exister.
// Sinon retourne NO.
{
  NSDictionary *def;
  BOOL ret;
  def= [(NSDictionary*)[db objectForKey:[EID numberWithInt:0]]
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
        if (_carTypeAndCardinality(k,&t,&c,__db)) {
            [ks2 addObject:k];
            [d setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                t,@"type",c, @"cardinality",nil] forKey:k];}}
    if ([d count]) [ret setObject:d forKey:[EID numberWithInt:0]];
    // Recherche des infos pour tous les éléments et toutes les clés valides.
    for (ee= [eids objectEnumerator]; (e= [ee nextObject]);) {
        d= [NSMutableDictionary dictionary];
        for (ke= [ks2 objectEnumerator]; (k= [ke nextObject]);) {
            NSArray *o= _infos(__db, e, k);
            if ([o count]) [d setObject:o forKey:k];}
        if ([d count]) [ret setObject:d forKey:e];}
    return ret;
}

static inline NSArray *_publicKeysOnly(NSArray *ks, NSDictionary *db)
{
    NSMutableArray *nks;
    id publicKeys,ke,k;
    // reduce ks to public keys
    nks= [NSMutableArray array];
    publicKeys= [(NSDictionary*)[db objectForKey:[EID numberWithInt:0]]
                 objectForKey:@"repository public key"];
    for (ke= [ks objectEnumerator]; (k= [ke nextObject]);) {
        if ([publicKeys containsObject:k]) [nks addObject:k];}
    return nks;
}

- (NSDictionary*)publicInformationsWithKeys:(NSArray*)ks forEids:(NSArray*)eids
{
    return [self _infosWithKeys:_publicKeysOnly(ks, __db) forEids:eids];
}
- (NSDictionary*)publicInformationsWithKey:(NSString*)k forEid:(EID*)eid
{
    return [self _infosWithKeys:_publicKeysOnly([NSArray arrayWithObject:k], __db)
                        forEids:[NSArray arrayWithObject:eid]];
}
- (NSDictionary*)publicInformationsWithKey:(NSString*)k forEids:(NSArray*)eids
{
    return [self _infosWithKeys:_publicKeysOnly([NSArray arrayWithObject:k], __db)
                        forEids:eids];
}
- (NSDictionary*)publicInformationsWithKeys:(NSArray*)ks forEid:(EID*)eid
{
    return [self _infosWithKeys:_publicKeysOnly(ks, __db)
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

+ (NSString *)_generatePlainChallenge
{
    MSBuffer *randBuff = AUTORELEASE(MSCreateRandomBuffer(8)) ;
    MSBuffer *b64Buf = [randBuff encodedToBase64] ;
  
    return AUTORELEASE(MSCreateASCIIStringWithBytes((void *)[b64Buf bytes], [b64Buf length], YES, YES)) ;
}

+ (NSString *)generateAndStoreChallengeForURN:(NSString *)urn
{
    NSString *plainChallenge = [self _generatePlainChallenge] ;
    EID *eid = [self eidForURN:urn] ;
    
    if (eid)
    {
        [[self _challengeDictionary] setObject:plainChallenge forKey:urn] ;
    }

    return plainChallenge ;
}

+ (NSString *)plainStoredChallengeForURN:(NSString *)urn
{
    return [[self _challengeDictionary] objectForKey:urn] ;
}

/////////////// ADDED

+ (NSDictionary*)_infosWithKeys:(NSArray*)ks forEids:(NSArray*)eids
{
    NSMutableDictionary *d, *ret;
    id ee,e,ks2,ke,k,t,c;
    ret= [NSMutableDictionary dictionary];
    // On vérifie tout d'abord les clés.
    ks2= [NSMutableArray array];
    d= [NSMutableDictionary dictionary];
    for (ke= [ks objectEnumerator]; (k= [ke nextObject]);) {
        if (_carTypeAndCardinality(k,&t,&c,__db)) {
            [ks2 addObject:k];
            [d setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                          t,@"type",c, @"cardinality",nil] forKey:k];}}
    if ([d count]) [ret setObject:d forKey:[EID numberWithInt:0]];
    // Recherche des infos pour tous les éléments et toutes les clés valides.
    for (ee= [eids objectEnumerator]; (e= [ee nextObject]);) {
        d= [NSMutableDictionary dictionary];
        for (ke= [ks2 objectEnumerator]; (k= [ke nextObject]);) {
            NSArray *o= _infos(__db, e, k);
            if ([o count]) [d setObject:o forKey:k];}
        if ([d count]) [ret setObject:d forKey:e];}
    return ret;
}

+ (NSDictionary*)publicInformationsWithKey:(NSString*)k forEid:(EID*)eid
{
    return [self _infosWithKeys:_publicKeysOnly([NSArray arrayWithObject:k], __db)
                       forEids:[NSArray arrayWithObject:eid]];
}

@end

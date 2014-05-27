//
//  _MHNetRepository.m
//  MSFoundation
//
//  Created by Geoffrey Guilbon on 28/10/13.
//
//

#import "_MASHPrivate.h"
#import "MHRepositoryKit.h"
#import "_MHNetRepository.h"

#define TID_SIZE  32

#define SESSION_REPOSITORY             @"__repository__"
#define SESSION_D_TID_URN              @"__D_TID_URN__"
#define SESSION_D_TID_EID              @"__D_TID_EID__"
#define SESSION_D_EID_TID              @"__D_EID_TID__"

#define REPOSITORY              GET_SESSION_MEMBER(SESSION_REPOSITORY)
#define SET_REPOSITORY(R)       SET_SESSION_MEMBER(R, SESSION_REPOSITORY)

#define D_TID_URN               GET_SESSION_MEMBER(SESSION_D_TID_URN)
#define SET_D_URN_TID(D)        SET_SESSION_MEMBER(D, SESSION_D_TID_URN)
#define G_TID_URN(U)            [D_TID_URN objectForKey:U]
#define S_TID_URN(T,U)          [D_TID_URN setObject:T forKey:U]

#define D_TID_EID               GET_SESSION_MEMBER(SESSION_D_TID_EID)
#define SET_D_TID_EID(D)        SET_SESSION_MEMBER(D, SESSION_D_TID_EID)
#define G_TID_EID(E)            [D_TID_EID objectForKey:E]
#define S_TID_EID(T,E)          [D_TID_EID setObject:T forKey:E]

#define D_EID_TID               GET_SESSION_MEMBER(SESSION_D_EID_TID)
#define SET_D_EID_TID(D)        SET_SESSION_MEMBER(D, SESSION_D_EID_TID)
#define G_EID_TID(T)            [D_EID_TID objectForKey:T]
#define S_EID_TID(E,T)          [D_EID_TID setObject:E forKey:T]


static NSString *_generateNewTID(MSUShort size)
{
    MSUInt newID = fabs(floor(GMTNow())) ;
    MSUInt addrID = (MSUInt)rand() ;
    return [NSString stringWithFormat:@"T%04X%08X%04X", addrID & 0x0000FFFF, newID, (addrID >> 16)  & 0x0000FFFF] ;
}

@implementation MHNetRepository

+ (NSDictionary *)loadDatabaseFromFile:(NSString *)file
{
    NSMutableDictionary *database = [NSMutableDictionary new] ;
    MSBuffer *buf= [MSBuffer bufferWithContentsOfFile:file];
    NSMutableDictionary *plist;
    id ke,k,o; unsigned long long v;
    plist= [[[NSString alloc] initWithData:buf encoding:NSUTF8StringEncoding] dictionaryValue];
    //NSLog(@"%@",plist);
    for (ke= [plist keyEnumerator]; (k= [ke nextObject]);) {
        o= [plist objectForKey:k];
        v= (unsigned long long)[k longLongValue];
        k= [MHRElementId numberWithUnsignedLongLong:v];
        [database setObject:o forKey:k];
    }
    //NSLog(@"%@",__db);*/
    return database ;
}

+ (id)repositoryWithDatabase:(NSDictionary *)database
{
    return [[ALLOC(self) initWithDatabase:database] autorelease] ;
}

- (id)initWithDatabase:(NSDictionary *)database
{
    if ((self = [super init])) {
        ASSIGN(_database, database) ;
    }
    return self ;
}

- (void)dealloc
{
    DESTROY(_database);
    [super dealloc] ;
}

- (BOOL)validateAuthenticationWithCertificate:(MSCertificate *)certificate notification:(MHNotification *)notification
{
    BOOL validateOK = NO ;
    MHRepository *repository = nil ;
    MHRElementId *eid = [MHRepository eidForUniqueRepositoryName:[certificate uniqueRepositoryName] inRepositoryDatabase:_database] ;
    
    if (eid) {
        repository = [[MHRepository alloc] initForEid:eid withCertificate:certificate inRepositoryDatabase:_database] ;
        if (repository) {
            SET_REPOSITORY(repository) ;
            SET_D_URN_TID([NSMutableDictionary dictionary]) ;
            SET_D_TID_EID([NSMutableDictionary dictionary]) ;
            SET_D_EID_TID([NSMutableDictionary dictionary]) ;
            validateOK =  YES ;
        }
    }
    return validateOK  ;
}

- (TID *)_makeTIDFromEID:(MHRElementId *)eid andStoreInSessionFromNotification:(MHNotification *)notification
{
    NSString *tid = G_TID_EID(eid) ;
    
    if (!tid)
    {
        do {
            tid = _generateNewTID(TID_SIZE) ;
        } while ((G_EID_TID(tid))) ;
        
        S_EID_TID(eid, tid) ;
        S_TID_EID(tid, eid) ;
    }
    
    return tid ;
}

- (TID *)identifierForURN:(NSString *)urn notification:(MHNotification *)notification
{
    TID *tid = G_TID_URN(urn) ;
    
    if (!tid)
    {
        MHRElementId *eid = [MHRepository eidForUniqueRepositoryName:urn inRepositoryDatabase:_database] ;
        if(eid)
        {
            tid = [self _makeTIDFromEID:eid andStoreInSessionFromNotification:notification] ;
            S_TID_URN(tid, urn) ;
        }
    }
    return tid ;
}

- (NSArray *)_eidsGraphOf:(NSString *)tree startingAt:(MHRElementId *)eid notification:(MHNotification *)notification
{
    NSArray *TIDLeaves = [REPOSITORY eidsGraphOf:tree startingAt:eid] ;
    NSEnumerator *leavesEnum = [TIDLeaves objectEnumerator] ;
    MHRElementId *element ;
    while ((element = [leavesEnum nextObject]))
    {
        if(!G_TID_EID(element))
        {
            [self _makeTIDFromEID:element andStoreInSessionFromNotification:notification] ;
        }
    }
    
    return TIDLeaves ;
}

- (NSDictionary *)_publicInformationsWithKeys:(NSArray*)ks forEids:(NSArray*)eids notification:(MHNotification *)notification
{   
    NSDictionary *publicInformationsWithEIDs = [REPOSITORY publicInformationsWithKeys:ks forEids:eids] ;
    NSMutableDictionary *publicInformationsWithTIDs = [NSMutableDictionary dictionary] ;
    NSEnumerator *eidEnum = [publicInformationsWithEIDs keyEnumerator] ;

    MHRElementId *eid ;
    TID *tid ;
    id value ;
    
    while((eid = [eidEnum nextObject])) //replace eid by tid
    {
        if ([eid intValue]) //do not check eid 0
        {
            tid = G_TID_EID(eid) ;
            value = [publicInformationsWithEIDs objectForKey:eid] ;
            [publicInformationsWithTIDs setObject:value forKey:tid] ;
        }
    }

    return publicInformationsWithTIDs ;
}

- (NSDictionary *)getPublicInformationsForKeys:(NSArray *)keys inTree:(NSString *)tree underIdentifier:(TID *)tid notification:(MHNotification *)notification
{
    MHRElementId *eid = [D_EID_TID objectForKey:tid] ;
    NSArray *EIDleaves = [self _eidsGraphOf:tree startingAt:eid notification:notification] ;

    return [self _publicInformationsWithKeys:keys forEids:EIDleaves notification:notification] ;
}

@end

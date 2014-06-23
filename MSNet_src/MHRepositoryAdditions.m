//
//  MHRepositoryAdditions.m
//  MSFoundation
//
//  Created by Geoffrey Guilbon on 05/06/2014.
//
//

#import "MHRepositoryKit.h"

@implementation MHRepository (MHRepositoryAdditions)

+ (NSDictionary *)_loadDatabaseFromFile:(NSString *)file
{
    NSMutableDictionary *database = [NSMutableDictionary new] ;
    MSBuffer *buf= [MSBuffer bufferWithContentsOfFile:file];
    NSMutableDictionary *plist;
    id ke,k,o; unsigned long long v;
    plist= [[[NSString alloc] initWithData:buf encoding:NSUTF8StringEncoding] dictionaryValue];
    
    for (ke= [plist keyEnumerator]; (k= [ke nextObject]);) {
        o= [plist objectForKey:k];
        v= (unsigned long long)[k longLongValue];
        k= [EID numberWithUnsignedLongLong:v];
        [database setObject:o forKey:k];
    }
    
    [self setDatabase:database] ;
    
    return database ;
}

+ (MSInt)openRepositoryDataBaseWithParameters:(NSDictionary *)parameters
{
    NSString *dbFileName = [parameters objectForKey:@"database"] ;
    NSDictionary *db = [self _loadDatabaseFromFile:dbFileName] ;
    
    return (db != nil) ;
}

+ (NSString *)challengedPublicKeyForURN:(NSString *)urn
{
    NSString *plainChallenge = [self generateAndStoreChallengeForURN:urn] ;
    NSString *pk = [self publicKeyForURN:urn] ;
    MSBuffer *base64Buf = nil ;
    NSData *encryptedChallengeData ;
    
    if (pk)
    {
#warning TODO: NON [pk length] n'est pas strlen([pk UTF8String])
        MSBuffer *pkBuf = AUTORELEASE(MSCreateBufferWithBytesNoCopyNoFree((void *)[pk UTF8String], [pk length])) ;
        MSBuffer *challengeBuf = nil ;
        MSCipher *cypher = nil ;
        
        //convert challenge to data
        challengeBuf = AUTORELEASE(MSCreateBufferWithBytesNoCopyNoFree((void *)[plainChallenge UTF8String], [plainChallenge length])) ;
        
        //encrypt challenge
        cypher = [MSCipher cipherWithKey:pkBuf type:RSAEncoder] ;
        encryptedChallengeData = [cypher encryptData:challengeBuf] ;
    } else
    {
        encryptedChallengeData = [plainChallenge dataUsingEncoding:NSUTF8StringEncoding] ;
    }
    
    //return plain and encrypted challenge
    base64Buf = [[MSBuffer bufferWithBytesNoCopyNoFree:(void*)[encryptedChallengeData bytes] length:[encryptedChallengeData length]] encodedToBase64] ;
  
    return AUTORELEASE(MSCreateASCIIStringWithBytes((void *)[base64Buf bytes], [base64Buf length], YES, YES)) ;
}

- (id)initWithDecodedChallenge:(NSString *)decodedChallenge forURN:(NSString *)urn
{
    NSString *storedPlainChallenge = [ISA(self) plainStoredChallengeForURN:urn] ;
    
    if ([decodedChallenge isEqualToString:storedPlainChallenge])
    {
        return self ;
    }
    
    return nil ;
}

+ (NSString *)publicKeyForURN:(NSString *)urn ;
{
    NSString *pk = nil ;
    EID *eid = [self eidForURN:urn] ;
    
    if (eid)
    {
        NSDictionary *keys = [self publicInformationsWithKey:@"public key" forEid:eid] ;
        NSArray *values = [[keys objectForKey:eid] objectForKey:@"public key"] ;
        pk = ([values count]) ? [values objectAtIndex:0] : nil ;
        
    }
    
    return pk ;
}

- (NSString *)hashedPasswordForLogin:(NSString *)login
{
    NSString *hashedPassword = nil ;
    EID *eid = [self eidForLogin:login] ;
    
    if (eid)
    {
        NSDictionary *keys = [self publicInformationsWithKey:@"password" forEid:eid] ;
        NSArray *values = [[keys objectForKey:eid] objectForKey:@"password"] ;
        hashedPassword = ([values count]) ? [values objectAtIndex:0] : nil ;
        
    }
    
    return hashedPassword ;
}

- (EID *)eidForLogin:(NSString *)login ;
{
    EID *eid= nil;
    NSDictionary *database = [ISA(self) database] ;
    NSDictionary *o; id ke,k,urn;
    for (ke= [database keyEnumerator]; !eid && (k= [ke nextObject]);) {
        if ([k intValue]) // do not check eid 0
        {
            o= [database objectForKey:k];
            urn= [o objectForKey:@"login"];
            if ([login isEqualToString:urn]) eid= k ;
        }
    }
    return eid;
}

- (EID *)eid
{
    return [NSNumber numberWithInt:0] ;
}


- (id)initWithChallenge:(NSString *)challenge
     challengedPassword:(NSString *)challengedPassword
               forLogin:(NSString *)login
{
    if ([self verifyChallenge:challenge
           challengedPassword:challengedPassword
                     forLogin:login])
    {
        return self ;
    }
    return nil ;
}

- (BOOL)verifyChallenge:(NSString *)challenge
     challengedPassword:(NSString *)challengedPassword
               forLogin:(NSString *)login
{
    BOOL auth = NO ;
    NSString *dbHashedPassword = [self hashedPasswordForLogin:login] ;  //fetch password for unique login in database
    
    if ([dbHashedPassword length] && [challenge length])
    {
        const void *tmp = [[challenge stringByAppendingString:dbHashedPassword] UTF8String] ;   //CHALLENGE + HASHED PWD
        NSString *dbHashedChallengedPassword = MSDigestData(MS_SHA512, tmp, strlen(tmp)) ;      //SHA512(CHALLENGE + HASHED PWD)
        
        if ([dbHashedChallengedPassword isEqualToString:challengedPassword])
        {
            auth = YES ;
        }
    }
    
    return auth ;
}

- (id)rightsForEid:(EID *)eid onEid:(EID *)targetEid
{
    return [NSDictionary dictionary] ;
}

@end

/*
 
 MHAdminApplication.h
 
 This file is is a part of the MicroStep Application Server over Http Framework.
 
 Initial copyright LOGITUD Solutions (logitud@logitud.fr) since 2012
 
 Herve Malaingre : herve@malaingre.com
 Jean-Michel Bertheas :  jean-michel.bertheas@club-internet.fr
 
 
 This software is a computer program whose purpose is to [describe
 functionalities and technical features of your software].
 
 This software is governed by the CeCILL-C license under French law and
 abiding by the rules of distribution of free software.  You can  use, 
 modify and/ or redistribute the software under the terms of the CeCILL-C
 license as circulated by CEA, CNRS and INRIA at the following URL
 "http://www.cecill.info". 
 
 As a counterpart to the access to the source code and  rights to copy,
 modify and redistribute granted by the license, users are provided only
 with a limited warranty  and the software's author,  the holder of the
 economic rights,  and the successive licensors  have only  limited
 liability. 
 
 In this respect, the user's attention is drawn to the risks associated
 with loading,  using,  modifying and/or developing or reproducing the
 software by the user in light of its specific status of free software,
 that may mean  that it is complicated to manipulate,  and  that  also
 therefore means  that it is reserved for developers  and  experienced
 professionals having in-depth computer knowledge. Users are therefore
 encouraged to load and test the software's suitability as regards their
 requirements in conditions enabling the security of their systems and/or 
 data to be ensured and,  more generally, to use and operate it in the 
 same conditions as regards security. 
 
 The fact that you are presently reading this means that you have had
 knowledge of the CeCILL-C license and that you accept its terms.
 
 */

#import "MHRepositoryKit.h"
#import "_MASHPrivate.h"

#define REPO_SESSION_MEMBER_NAME    @"__SESS_REPOSITORY__"

@implementation MHNetRepositoryApplication

+ (NSString *)applicationName { return @"MHNetRepositoryApp" ; }
+ (NSString *)applicationFullName { return @"MASH Net Repository application" ; }

+ (MSUInt)defaultAuthenticationMethods { return MHAuthPKChallengeAndURN | MHAuthChallengedPasswordLoginOnTarget ; }

- (BOOL)mustUpdateLastActivity { return NO ; }
- (BOOL)canVerifyPeerCertificate { return YES ; }

- (id)initOnBaseURL:(NSString *)url instanceName:(NSString *)instanceName withLogger:(id)logger parameters:(NSDictionary *)parameters
{
    if ([super initOnBaseURL:url instanceName:instanceName withLogger:logger parameters:parameters])
    {
        if(![MHRepository openRepositoryDataBaseWithParameters:parameters])
        {
            MSRaise(NSInternalInconsistencyException, @"MHNetRepositoryApplication : could not open database with parameters : %@", parameters) ;
        }
        return self ;
    }
    return nil ;
}

- (NSString *)generatePKChallengeURN:(NSString *)urn storedPlainChallenge:(NSString **)plainChallenge
{
    *plainChallenge = nil ; // do not store challenge in MASH session, keep it in repository
    
    return [MHRepository challengedPublicKeyForURN:urn] ;
}

- (void)validateAuthentication:(MHNotification *)notification
                     challenge:(NSString *)challenge
              sessionChallenge:(NSString *)storedChallenge
                           urn:(NSString *)urn
                   certificate:(MSCertificate *)certificate
{
    //ignore storedChallenge because it is stored in MHRepository, not in MASH
    if ([challenge length])
    {
        MHRepository *repository = [[ALLOC(MHRepository) initWithDecodedChallenge:challenge forURN:urn] autorelease] ;
        
        if (repository) //authentication success, store repository object in session
        {
            SET_SESSION_MEMBER(repository,REPO_SESSION_MEMBER_NAME) ;
            
            [self logWithLevel:MHAppDebug log:@"Challenge Authentication success for URN '%@'", urn] ;
            MHVALIDATE_AUTHENTICATION(YES, nil) ;
        }
    }
    
    [self logWithLevel:MHAppDebug log:@"Challenge Authentication failure for URN '%@' : stored challenge not found", urn] ;
    MHVALIDATE_AUTHENTICATION(NO, nil) ;
}

- (MSCouple *)_actionAndParametersFromPostedMessage:(MHHTTPMessage *)message
{
    MSCouple *actionAndParameters = nil ;
    id decodedMessage = [[message getCompleteBody] MSTDecodedObject] ;

    if ([decodedMessage isKindOfClass:[NSDictionary class]])
    {
        id action = [decodedMessage objectForKey:@"method"] ;
        id parameters = [decodedMessage objectForKey:@"parameters"] ;
        
        if ([parameters isKindOfClass:[NSDictionary class]] &&
            [action isKindOfClass:[NSString class]] &&
            [action length])
        {
            action = [action stringByAppendingString:@":parameters:"] ;
            actionAndParameters = AUTORELEASE(MSCreateCouple(action, parameters)) ;
        }
    }
    
    return actionAndParameters ;
}

- (void)awakeOnRequest:(MHNotification *)notification
{
    MHCHANGE_SESSION_ID_ON_RESPONSE() ;
    
    
    if ([MHHTTPMethodPOST isEqualToString:[[notification message] getHeader:MHHTTPMethod]]) //POST + MSTE
    {
        MSCouple *actionAndParameters = [self _actionAndParametersFromPostedMessage:[notification message]] ;
        
        NSString *action = [actionAndParameters firstMember] ;
        NSDictionary *parameters = [actionAndParameters secondMember] ;
        
        SEL actionSEL = NSSelectorFromString(action) ;
        
        if(!actionSEL) {
            [self logWithLevel:MHAppError log:@"awakeOnRequest: cannot create action selector from action name : %@", action] ;
            MHRESPOND_TO_CLIENT_AND_CLOSE_SESSION(nil, HTTPBadRequest, nil) ;
        }
        else {
            if([self respondsToSelector:actionSEL])
            {
                [self logWithLevel:MHAppDebug log:@"awakeOnRequest: perform action on %@", action] ;
                [self performSelector:actionSEL withObject:notification withObject:parameters] ;
            } else
            {
                [self logWithLevel:MHAppError log:@"awakeOnRequest: action not supported : %@", action] ;
                MHRESPOND_TO_CLIENT_AND_CLOSE_SESSION(nil, HTTPBadRequest, nil) ;
            }
        }
        
    } else //GET
    {
        [super awakeOnRequest:notification] ;
    }
}


- (void)verifyChallenge:(MHNotification *)notification
{
    MHHTTPMessage *message = [notification message] ;
    NSString *password  = [message getHeader:MHHTTPAuthPassword] ;
    NSString *login     = [message getHeader:MHHTTPAuthLogin] ;
    NSString *challenge = [message getHeader:MHHTTPAuthChallenge] ;
    NSMutableDictionary *headers = [NSMutableDictionary dictionary] ;
    NSString *authResponse = nil ;
    BOOL auth = NO ;
    
    if (password && [login length] && [challenge length])
    {
        MHRepository *repository = GET_SESSION_MEMBER(REPO_SESSION_MEMBER_NAME) ;
        auth = [repository verifyChallenge:challenge challengedPassword:password forLogin:login] ;
    }
    
    authResponse = auth ? MHAUTH_HEADER_RESPONSE_OK : MHAUTH_HEADER_RESPONSE_FAIL ;
    [headers setObject:authResponse forKey:MHAUTH_HEADER_RESPONSE] ;

    MHRESPOND_TO_CLIENT(nil, HTTPOK, headers) ;
}

- (void)getPublicKey:(MHNotification *)notification
{
    MHHTTPMessage *message = [notification message] ;
    NSString *urn  = [message getHeader:MHHTTPAuthURN] ;
    MSBuffer *pkBuf = nil ;
    
    if ([urn length])
    {
        NSString *pk = [MHRepository publicKeyForURN:urn] ;
        if (pk)
        {
            pkBuf = AUTORELEASE(MSCreateBufferWithBytes((void *)[pk UTF8String], [pk length])) ;
        }
    }
    MHRESPOND_TO_CLIENT(pkBuf, HTTPOK, nil) ;
}

- (void)validateAuthentication:(MHNotification *)notification
                         login:(NSString *)login
            challengedPassword:(NSString *)challengedPassword
              sessionChallenge:(NSString *)storedChallenge
                        target:(NSString *)target
                   certificate:(MSCertificate *)certificate
{
    BOOL auth = NO ;
    MSBuffer *rigthsBuf = nil ;
    MHRepository *repository = [[[MHRepository alloc] initWithChallenge:storedChallenge challengedPassword:challengedPassword forLogin:login] autorelease] ;
    
    if (repository)
    {
        EID *targetEID = nil ;
        EID *loginEID = nil ;
        MSBuffer *rights = nil ;
        
        SET_SESSION_MEMBER(repository,REPO_SESSION_MEMBER_NAME) ;
        
        targetEID = [MHRepository eidForURN:target] ;
        loginEID = [repository eidForLogin:login] ;
        rights = [repository rightsForEid:loginEID onEid:targetEID] ;
        
        rigthsBuf = [rights MSTEncodedBuffer] ;

        auth = YES ;
        [self logWithLevel:MHAppDebug log:@"Challenge Authentication success for login '%@' on target '%@'", login, target] ;
    } else
    {
        [self logWithLevel:MHAppDebug log:@"Challenge Authentication failure for login '%@' on target '%@'", login, target] ;
    }
    
    MHVALIDATE_AUTHENTICATION(auth, rigthsBuf) ;
}

@end

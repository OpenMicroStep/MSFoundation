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

#import "_MASHPrivate.h"
#import "_MHNetRepository.h"

@implementation MHNetRepositoryApplication

+ (NSString *)applicationName { return @"MHNetRepositoryApp" ; }
+ (NSString *)applicationFullName { return @"MASH Net Repository application" ; }

- (BOOL)mustUpdateLastActivity { return NO ; }
- (BOOL)canVerifyPeerCertificate { return YES ; }

- (MSBuffer *)loginInterfaceWithMessage:(MHHTTPMessage *)message errorMessage:(NSString *)error { return nil ; }

- (id)initOnBaseURL:(NSString *)url instanceName:(NSString *)instanceName withLogger:(id)logger parameters:(NSDictionary *)parameters
{
    if((self = [super initOnBaseURL:url instanceName:instanceName withLogger:logger parameters:parameters]))
    {
        id repositoryDatabase = [parameters objectForKey:@"database"] ;
        [self setAuthenticationMethods:MHAuthCustom] ;
        
        if (repositoryDatabase) {
            if ([repositoryDatabase isKindOfClass:[NSString class]] && MSIsValidFile((NSString *)repositoryDatabase)) {
                NSDictionary *database= [MHNetRepository loadDatabaseFromFile:(NSString *)repositoryDatabase];
                if (database) {
                    ASSIGN(_repository, [MHNetRepository repositoryWithDatabase:database]) ;
                }
                else {
                    MSRaise(NSInternalInconsistencyException, @"MHNetRepositoryApplication : wrong format for repository database!") ;
                }
            }
            else {
                MSRaise(NSInternalInconsistencyException, @"MHNetRepositoryApplication : unable to find repository database!") ;
            }
        }
        else {
            MSRaise(NSInternalInconsistencyException, @"MHNetRepositoryApplication : no repository database specified!") ;
        }
        
        return self ;
    }
    
    return nil ;
}

- (MSBuffer *)loginInterfaceWithParameters:(NSDictionary *)params
{
    MSBuffer *ret = nil ;
    NSString *error = [params objectForKey:@"errorMessage"] ;
    
    if ([error length]) {
        char *str = (void *)[error UTF8String] ;
        ret = AUTORELEASE(MSCreateBufferWithBytes(str, strlen(str))) ;
    }
    return ret ;
}

- (void)validateAuthentication:(MHNotification *)notification certificate:(MSCertificate *)certificate
{
    if ([_repository validateAuthenticationWithCertificate:certificate notification:notification]) {
        MHVALIDATE_AUTHENTICATION(YES, nil) ;
        [self logWithLevel:MHAppDebug log:@"validateAuthentication succeeded"] ;
    }
    else {
        [self logWithLevel:MHAppDebug log:@"validateAuthentication failed"] ;
        MHVALIDATE_AUTHENTICATION(NO, nil) ;
    }
}

- (void)awakeOnRequest:(MHNotification *)notification
{
    MHCHANGE_SESSION_ID_ON_RESPONSE() ;
    return [super awakeOnRequest:notification] ;
}

- (MSBuffer *)_makeResponseWithTID:(TID *)tid
{
    NSString *tidResponse = [NSString stringWithFormat:@"%@\r\n",tid] ;
    void *str = (void *)[tidResponse UTF8String] ;
    
    return AUTORELEASE(MSCreateBufferWithBytes(str, strlen(str))) ;
}

- (void)identifierForURN:(MHNotification *)notification
{
    NSString *urn = [[notification message] parameterNamed:MHNR_QUERY_PARAM_URN] ;
    
    if ([urn length])
    {
        TID *tid ;
        
        if ((tid = [_repository identifierForURN:urn notification:notification]))
        {
            MSBuffer *response = [self _makeResponseWithTID:tid] ;
            MHRESPOND_TO_CLIENT(response, HTTPOK, nil) ;
        } else {
            MHRESPOND_TO_CLIENT(nil, HTTPNotFound, nil) ;
        }
    } else {
        [self logWithLevel:MHAppError log:@"/%@ : no URN specified in query string", MHNR_SUB_URL_ID_FOR_URN] ;
        MHRESPOND_TO_CLIENT(nil, HTTPBadRequest, nil) ;
    }
}


- (MSBuffer *)_makeResponseForPublicInformation:(NSDictionary *)informations
{
    NSString *reponse = [NSString stringWithFormat:@"%@\r\n",informations] ;
    void *str = (void *)[reponse UTF8String] ;
    
    return AUTORELEASE(MSCreateBufferWithBytes(str, strlen(str))) ;
}

- (void)getPublicInformations:(MHNotification *)notification
{   
    TID *tid = [[notification message] parameterNamed:MHNR_QUERY_PARAM_UNDER_ID] ;
    NSArray *keys = [[[notification message] parameterNamed:MHNR_QUERY_PARAM_KEY] componentsSeparatedByString:MHNR_QUERY_PARAM_SEPARATOR] ;
    NSString *tree = [[notification message] parameterNamed:MHNR_QUERY_PARAM_IN_TREE] ; ;

    
    if ([tid length] && [keys count] && [tree length])
    {
        NSDictionary *publicInformations = [_repository getPublicInformationsForKeys:keys inTree:tree underIdentifier:tid notification:notification] ;
        MSBuffer *response = [self _makeResponseForPublicInformation:publicInformations] ;
        MHRESPOND_TO_CLIENT(response, HTTPOK, nil) ;
    } else {
        if (![tid length]) { [self logWithLevel:MHAppError log:@"/%@ : no TID specified in query string", MHNR_SUB_URL_GET_PUB_INFOS] ; }
        if (![keys count]) { [self logWithLevel:MHAppError log:@"/%@ : no key specified in query string", MHNR_SUB_URL_GET_PUB_INFOS] ; }
        if (![tree length]) { [self logWithLevel:MHAppError log:@"/%@ : no tree specified in query string", MHNR_SUB_URL_GET_PUB_INFOS] ; }
        MHRESPOND_TO_CLIENT(nil, HTTPBadRequest, nil) ;
    }
}


@end

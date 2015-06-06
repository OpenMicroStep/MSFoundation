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

#import "MSNet_Private.h"

static NSComparisonResult compareApplications(id obj1, id obj2, void *c)
{
    MHAdminApplication *app1 = (MHAdminApplication *)obj1 ;
    MHAdminApplication *app2 = (MHAdminApplication *)obj2 ;
    
    if ([app1 isAdminApplication]) return NSOrderedAscending ;
    if ([app2 isAdminApplication]) return NSOrderedDescending ;
    return [[app1 applicationFullName] compare:[app2 applicationFullName]] ;
    c= NULL; // Unused parameter
}

static NSComparisonResult compareSessions(id obj1, id obj2, void *c)
{
    MHSession *session1 = (MHSession *)obj1 ;
    MHSession *session2 = (MHSession *)obj2 ;
    
    if ([session1 status] > [session2 status]) return NSOrderedAscending ;
    else if ([session1 status] < [session2 status]) return NSOrderedDescending ;
    
    if ([session1 lastActivity] > [session2 lastActivity]) return NSOrderedAscending ;
    else if ([session1 lastActivity] < [session2 lastActivity]) return NSOrderedAscending ;
    
    return NSOrderedSame ;
    c= NULL; // Unused parameter
}

@implementation MHAdminApplication

+ (MSUInt)defaultAuthenticationMethods { return MHAuthSimpleGUIPasswordAndLogin ; }

- (id)initOnBaseURL:(NSString *)url instanceName:(NSString *)instanceName withLogger:(id)logger parameters:(NSDictionary *)parameters
{
    ASSIGN(_adminLogin, [parameters objectForKey:@"adminLogin"]) ;
    ASSIGN(_adminPassword, [parameters objectForKey:@"adminPassword"]) ;
    return [super initOnBaseURL:url instanceName:@"Admin Application" withLogger:logger parameters:parameters] ;
    instanceName= NULL; // Unused parameter
}

- (NSString *)baseURL { return @"" ; }

+ (NSString *)applicationName { return @"MHAdminApp" ; }
+ (NSString *)applicationFullName { return @"MASH Server administration application" ; }

+ (BOOL)isAdminApplication {return YES ; }
- (BOOL)isAdminApplication {return YES ; }

- (NSString *)htmlDescriptionForResourceCache
{
    NSMutableString *htmlCacheTable = [NSMutableString string] ;
    NSEnumerator *resourceEnum = [allResources() objectEnumerator] ;
    MHResource *resource ;
    
    [htmlCacheTable appendString:@"<table border=\"1\"><tr> <th>Name</th> <th>URL</th>  <th>Path on disk</th>  <th>Class</th>  <th>Status</th>  <th>Validity duration</th>   </tr>"] ;
    
    while ((resource = [resourceEnum nextObject])) {
        [htmlCacheTable appendFormat:@"<tr> <td>%@</td> <td>%@</td> <td>%@</td> <td>%@</td> <td>%@</td> <td>%@</td> </tr>",
         [resource name] ,
         [resource url] ,
         [resource resourcePathOndisk] ,
         [resource className] ,
         [NSNumber numberWithBool:[resource isValid]] ,
         [NSNumber numberWithUnsignedLong:[resource validityDuration]]] ;
    }
    
    
    [htmlCacheTable appendString:@"</table>"] ;
    
    return htmlCacheTable ;
}

- (NSArray *)descriptionsForSessions
{
    NSArray * allSession = nil ;
    NSMutableArray *descriptionArray = nil ;
    NSEnumerator *e = nil ;
    MHSession *session = nil ;
    lock_sessions_mutex() ;

    allSession = [allSessions() sortedArrayUsingFunction:compareSessions context:nil] ;
    descriptionArray = [NSMutableArray arrayWithCapacity:[allSession count]] ;

    e = [allSession objectEnumerator] ;
    while ((session = [e nextObject])) {
#ifdef WO541
         [descriptionArray addObject:[NSString stringWithFormat:@"ID=%@ url=%@ status=%@ lastActivity=%@ login=%@ (%lu context%@\n",
#else
         [descriptionArray addObject:[NSString stringWithFormat:@"ID=%@ url=%@ status=%@ lastActivity=%@ login=%@ (%llu context%@\n",
#endif
         [session sessionID],
         [[session application] baseURL],
         [session statusDescription],
         [MSDate dateWithSecondsSinceLocalReferenceDate:[session lastActivity]],
         [session userLogin],
         [session contextCount],
         [session contextCount]>1 ? @"s)" : @")"]] ;
    }

    unlock_sessions_mutex() ;
    return descriptionArray;
}

- (NSString *)htmlDescriptionForGeneralStatistics
{
    NSMutableString *htmlDescription = [NSMutableString string] ;

    [htmlDescription appendFormat:@"Client accepted requests : current %u / max %u<br>", currentClientProcessingRequestCount(), maxClientProcessingRequests() ] ;
    [htmlDescription appendFormat:@"Client reading threads : used %u / running %u<br>", usedClientReadingThreads(), maxClientReadingThreads() ] ;
    [htmlDescription appendFormat:@"Client processing threads : used %u / running %u<br>", usedClientProcessingThreads(), maxClientProcessingThreads() ] ;
    [htmlDescription appendFormat:@"Client separated unique processing threads : used %@>", usedClientSeparatedUniqueProcessingThread() ? @"YES" : @"NO"] ;
    [htmlDescription appendFormat:@"Client waiting threads : used %u / running %u<br>", usedClientWaitingThreads(), maxClientWaitingThreads() ] ;
    [htmlDescription appendFormat:@"Admin listening port : %d<br>", adminPort() ] ;
    [htmlDescription appendFormat:@"Admin accepted requests : current %u / max %u<br>", currentAdminProcessingRequestCount(), maxAdminProcessingRequests() ] ;
    [htmlDescription appendFormat:@"Admin reading threads : used %u / running %u<br>", usedAdminReadingThreads(), maxAdminReadingThreads() ] ;
    [htmlDescription appendFormat:@"Admin processing threads : used %u / running %u<br>", usedAdminProcessingThreads(), maxAdminProcessingThreads() ] ;
    [htmlDescription appendFormat:@"Admin waiting threads : used %u / running %u<br>", usedAdminWaitingThreads(), maxAdminWaitingThreads() ] ;

    return htmlDescription ;
}

- (NSString *)htmlDescriptionForApplications:(NSArray*)applications {
    NSMutableString *htmlDescription = [NSMutableString string] ;
    NSEnumerator *e = [applications objectEnumerator] ;
    MHApplication *app = nil ;

    while ((app = [e nextObject])) {
        [htmlDescription appendFormat:@"Application name = %@<br>", [[app applicationFullName] htmlRepresentation]] ;
    }
    return htmlDescription ;
}

- (void)validateSimpleGUIAuthentication:(MHNotification *)notification login:(NSString *)login password:(NSString *)password certificate:(MSCertificate *)certificate
{
    BOOL isAuthenticated = ([_adminLogin isEqual:login] && [_adminPassword isEqual:password]) ;
    
    if (isAuthenticated) {
        NSMutableString *htmlBody = nil; NSString *temp = nil ;
        NSArray *applications = [allApplicationsForPort([[[notification message] clientSecureSocket] localPort]) sortedArrayUsingFunction:compareApplications context:nil] ;
        NSArray *sessionsDescriptions = (NSArray *)[self descriptionsForSessions] ;
        NSEnumerator *e = nil ;
        NSString *sessionDescription = nil ;
        MSBuffer *buf = nil ;
        
        htmlBody = [NSMutableString stringWithFormat:@"<b>%@</b><br>%@<br><b>%@</b><br>%@<br><br><b>%@</b><br><br>",
                    @"G&eacute;n&eacute;ral :", [self htmlDescriptionForGeneralStatistics], 
                    [@"Applications :" htmlRepresentation], [self htmlDescriptionForApplications:applications], 
                    //@"Adresses IP blacklist&eacute;es :", [self htmlDescriptionForBlacklistedIPs],
                    [@"Sessions :" htmlRepresentation]];
        
        e = [sessionsDescriptions objectEnumerator] ;
        while((sessionDescription = [e nextObject])) {
            [htmlBody appendFormat:@"%@<br>", [sessionDescription htmlRepresentation]] ;
        }
        
        [htmlBody appendFormat:@"<br><br><b>%@</b><br>%@",[@"Cache :" htmlRepresentation], [self htmlDescriptionForResourceCache]] ;
        temp = [NSString stringWithFormat:@"<html><head><title>%@</title></head><body><p>%@</body></html>", [[self applicationFullName] htmlRepresentation], htmlBody] ;
        buf = [MSBuffer bufferWithCString:(char *)[temp UTF8String]] ;

        MHVALIDATE_AUTHENTICATION(YES, buf) ;
    }
    else {
        MHVALIDATE_AUTHENTICATION(NO, nil) ;
    }
}

- (NSString *)jsonDescriptionForBlacklistedIPs
{
    NSMutableArray * ips = [NSMutableArray array] ;
    int i;
    unsigned long ip;
    
    lock_blacklist_mutex();
    for(i=0; i<BLACKLIST_SIZE; i++)
    {
        ip = *blacklistAtIndex(i);
        if(ip !=0 && ip != 0xFFFFFFFF)
        {
#ifdef WO451
            [ips addObject:[NSString stringWithCString:inet_ntoa(*(struct in_addr *)&ip)]] ;
#else
            [ips addObject:[NSString stringWithUTF8String:inet_ntoa(*(struct in_addr *)&ip)]] ;
#endif
        }
    }
    
    unlock_blacklist_mutex();
    return [NSString stringWithFormat:@"[%@]", [ips componentsJoinedByString:@","]];
}

- (void)awakeOnRequest:(MHNotification *)notification
{
    NSMutableString *htmlBody = nil; NSString *temp = nil ;
    NSArray *applications = [allApplicationsForPort([[[notification message] clientSecureSocket] localPort]) sortedArrayUsingFunction:compareApplications context:nil] ;
    NSArray *sessionsDescriptions = (NSArray *)[self descriptionsForSessions] ;
    NSEnumerator *e = nil ;
    NSString *sessionDescription = nil ;
    MSBuffer *buf = nil ;
    
    htmlBody = [NSMutableString stringWithFormat:@"<b>%@</b><br>%@<br><b>%@</b><br>%@<br><b>%@</b><br>%@<br><br><b>%@</b><br>",
                @"G&eacute;n&eacute;ral :", [self htmlDescriptionForGeneralStatistics], 
                [@"Applications :" htmlRepresentation], [self htmlDescriptionForApplications:applications], 
                @"Adresses IP blacklist&eacute;es :", [self jsonDescriptionForBlacklistedIPs],
                [@"Sessions :" htmlRepresentation]];

    e = [sessionsDescriptions objectEnumerator] ;
    while((sessionDescription = [e nextObject])) {
        [htmlBody appendFormat:@"%@<br>", [sessionDescription htmlRepresentation]] ;
    }

    temp = [NSString stringWithFormat:@"<html><head><title>%@</title></head><body><p>%@</body></html>", [[self applicationFullName] htmlRepresentation], htmlBody] ;
#ifdef WO451
    buf = [MSBuffer bufferWithCString:(char *)[temp cString]] ;
#else    
    buf = [MSBuffer bufferWithCString:(char *)[temp UTF8String]] ;
#endif    
    
    MHRESPOND_TO_CLIENT(buf, HTTPOK, nil);
}

@end

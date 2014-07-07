//
//  MHApplication+Private.m
//  MSFoundation
//
//  Created by Geoffrey Guilbon on 20/11/13.
//
//

#import "MSNet_Private.h"

NSMutableString *MHOpenFileForSubstitutions(NSString *file)
{
#ifdef WO451
    return [NSMutableString stringWithContentsOfFile:file] ;
#else
    return [NSMutableString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:NULL] ;
#endif
}

@implementation MHApplication (Private)

- (void)validateAuthentication:(MHNotification *)notification {
    
    MHAppAuthentication authType = [notification authenticationType] ;
    MSCertificate *peerCertificate = [[[notification message] clientSecureSocket] getPeerCertificate] ;
    MHSession *session = [notification session] ;
    
    if (session) { authType = [session authenticationType] ; }
    
    if (peerCertificate) {
        [self logWithLevel:MHAppDebug log:@"SSL AUTH : received client certificate : %@",peerCertificate] ;
    }

    [self logWithLevel:MHAppDebug log:@"validateAuthentication with authentication type : %@", MHAuthenticationNameForType(authType)] ;
    
    switch (authType) {

        case MHAuthCustom:
        {
            [self validateAuthentication:notification certificate:peerCertificate] ;
            break ;
        }
            
        case MHAuthTicket:
        {
            NSString *ticket = [notification storedAuthenticationTicket] ;
            [self validateAuthentication:notification ticket:ticket certificate:peerCertificate] ;
            break ;
        }
            
        case MHAuthChallengedPasswordLogin:
        {
            NSString *login = [notification storedAuthenticationLogin] ;
            NSString *password = [notification storedAuthenticationPassword] ;
            NSString *plainStoredChallenge = [notification memberNamedInSession:SESSION_PARAM_CHALLENGE] ;

            [self validateAuthentication:notification
                                   login:login
                      challengedPassword:password
                        sessionChallenge:plainStoredChallenge
                             certificate:peerCertificate] ;

            break;
        }
            
        case MHAuthChallengedPasswordLoginOnTarget:
        {
            NSString *login = [notification storedAuthenticationLogin] ;
            NSString *password = [notification storedAuthenticationPassword] ;
            NSString *plainStoredChallenge = [notification memberNamedInSession:SESSION_PARAM_CHALLENGE] ;
            NSString *target = [notification memberNamedInSession:SESSION_PARAM_TARGET] ;
            
            [self validateAuthentication:notification
                                   login:login challengedPassword:password
                        sessionChallenge:plainStoredChallenge
                                  target:target
                             certificate:peerCertificate] ;
            break;
        }
            
        case MHAuthPKChallengeAndURN:
        {
            NSString *challenge = [notification storedAuthenticationChallenge] ;
            NSString *plainStoredChallenge = [notification memberNamedInSession:SESSION_PARAM_CHALLENGE] ;
            NSString *urn = [notification memberNamedInSession:SESSION_PARAM_URN] ;
            
            [self validateAuthentication:notification
                               challenge:challenge
                        sessionChallenge:plainStoredChallenge
                                    urn:urn
                             certificate:peerCertificate] ;
            break ;
        }
            
        default:
             MSRaise(NSInternalInconsistencyException, @"validateAuthentication : authentication type not supported : '%@'", MHAuthenticationNameForType(authType)) ;
            break;
    }
}

- (void)deleteExpiredTickets
{
    NSEnumerator *ticketEnum = [_tickets keyEnumerator] ;
    NSString *ticket = nil ;
    NSMutableArray *ticketsArray = [NSMutableArray array];
    
    while ((ticket = [ticketEnum nextObject]))
    {
        MSTimeInterval ticketValidityEnd = [[[_tickets objectForKey:ticket] objectForKey:MHAPP_TICKET_VALIDITY] longLongValue] ;
        if (GMTNow() > ticketValidityEnd)
        {
            if(ticketValidityEnd!=0){
                [ticketsArray addObject:ticket];
            }
        }
    }
    [_tickets removeObjectsForKeys:ticketsArray] ;
}

- (BOOL)isGUIApplication { return NO ; }
- (BOOL)isAdminApplication {return NO ; }

@end

@implementation MHGUIApplication (Private)

+ (MSBuffer *)loginInterfaceAppChoiceWithParameters:(NSDictionary *)params {
    
    MSBuffer *loginInterface = nil ;    
    NSString *knownCustomer = [params objectForKey:@"knownCustomer"] ;
    NSString *knownGroup    = [params objectForKey:@"knownGroup"] ;
    NSString *url           = [params objectForKey:@"url"] ;
    NSString *errorMessage = [params objectForKey:@"errorMessage"] ;
    
    NSString *file = nil ;
    NSString *applicationList = @"" ;
    NSArray *guiApps = [params objectForKey:@"guiApplications"] ;
    
    NSEnumerator *e = [guiApps objectEnumerator] ;
    NSDictionary *appURLInfos ;
    NSString *fileName = @"default_choice_login" ;
    BOOL isDir = NO ;
    
    file = [[NSBundle bundleForClass:[MHApplication class]]  pathForResource:fileName ofType:@"html"] ;
    
 NSLog(@"%@ %@",file, fileName);
    if (MSFileExistsAtPath(file, &isDir) && !isDir)
    {
        void *bytes ;
        NSMutableString *page = MHOpenFileForSubstitutions(file) ;
                
        while ((appURLInfos = [e nextObject]))
        {
            NSString *appURL = [appURLInfos objectForKey:@"url"] ;
            MHApplication *app = [appURLInfos objectForKey:@"application"] ;
            NSString *appUseName = ([[app instanceName] length]) ? [[app instanceName] htmlRepresentation] : [[app applicationFullName] htmlRepresentation] ;
            
            if(knownCustomer && knownGroup) // customer and group url ex : /city/group
            {
                if([knownCustomer isEqual:[appURLInfos objectForKey:@"customer"]] && [knownGroup isEqual:[appURLInfos objectForKey:@"group"]])
                {
                    applicationList = [applicationList stringByAppendingFormat:@"<option value=\"%@\">%@</option>\n",
                                       appURL,
                                       appUseName] ;
                }
            }
            else // customer url only eg : /city
            {
                if([knownCustomer isEqual:[appURLInfos objectForKey:@"customer"]])
                {
                    applicationList = [applicationList stringByAppendingFormat:@"<option value=\"%@\">%@ - %@</option>\n",
                                       appURL,
                                       [appURLInfos objectForKey:@"group"],
                                       appUseName] ;
                }
            }
        }
        
        page = [page replaceOccurrencesOfString:@"%__APPLICATION_LIST__%" withString:applicationList] ;
        page = [page replaceOccurrencesOfString:@"%__ERROR_MESSAGE__%" withString:[errorMessage length] ? errorMessage : @""] ;
        page = [page replaceOccurrencesOfString:@"%__CUSTOMERGROUP__%" withString:url] ;
       
        bytes = (void *)[page UTF8String] ;
        loginInterface = AUTORELEASE(MSCreateBufferWithBytes(bytes, strlen(bytes))) ;
        
    } else
    {
        MSRaise(NSGenericException, @"MHGUIApplication : cannot find interface templace at path '%@'", file) ;
    }
    
    return loginInterface ;
}

- (void)validateAuthentication:(MHNotification *)notification
{
    if ([notification authenticationType] == MHAuthSimpleGUIPasswordAndLogin)
    {
        NSString *login = [notification storedAuthenticationLogin] ;
        NSString *password = [notification storedAuthenticationPassword] ;
        MSCertificate *peerCertificate = [[[notification message] clientSecureSocket] getPeerCertificate] ;
        
        [self validateSimpleGUIAuthentication:notification login:login password:password certificate:peerCertificate] ;
    } else
    {
        [super validateAuthentication:notification] ;
    }

}

- (BOOL)isGUIApplication { return YES ; }

@end

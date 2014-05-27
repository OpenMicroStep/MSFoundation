//
//  MHAuthenticatedApplication+Private.m
//  MSFoundation
//
//  Created by Geoffrey Guilbon on 20/11/13.
//
//

#import "_MASHPrivate.h"

NSMutableString *MHOpenFileForSubstitutions(NSString *file)
{
#ifdef WO451
    return [NSMutableString stringWithContentsOfFile:file] ;
#else
    return [NSMutableString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:NULL] ;
#endif
}

@implementation MHAuthenticatedApplication (Private)

- (void)validateAuthentication:(MHNotification *)notification {
    
    MHAppAuthentication authType = [notification authenticationType] ;
    MSCertificate *peerCertificate = [[[notification message] clientSecureSocket] getPeerCertificate] ;
    
    if (peerCertificate) {
        [self logWithLevel:MHAppDebug log:@"SSL AUTH : received client certificate : %@",peerCertificate] ;
    }

    switch (authType) {
        case MHAuthLoginPass:
        {
            NSString *login = [notification storedGUIAuthenticationLogin] ;
            NSString *password = [notification storedGUIAuthenticationPassword] ;

            [self validateAuthentication:notification login:login password:password certificate:peerCertificate] ;
            break;
        }
        case MHAuthTicket:
        {
            NSString *ticket = [notification storedTicket] ;
            [self validateAuthentication:notification ticket:ticket certificate:peerCertificate] ;
            break ;
        }
            
        case MHAuthChallenge:
        {
            NSString *challenge = [notification storedChallenge] ;
            [self validateAuthentication:notification challenge:challenge certificate:peerCertificate] ;
            break ;
        }
        
        case MHAuthCustom:
        {
            [self validateAuthentication:notification certificate:peerCertificate] ;
            break ;
        }
            
        default:
             MSRaise(NSInternalInconsistencyException, @"validateAuthentication : authentication type not supported : %d", authType) ;
            break;
    }
}

@end

@implementation MHGUIAuthenticatedApplication (Private)

+ (MSBuffer *)loginInterfaceWithParameters:(NSDictionary *)params {
    
    MSBuffer *loginInterface = nil ;    
    NSString *knownCustomer = [params objectForKey:@"knownCustomer"] ;
    NSString *knownGroup    = [params objectForKey:@"knownGroup"] ;
    NSString *url           = [params objectForKey:@"url"] ;
    MSUInt baseUrlComponentsCount = (MSUInt)[[params objectForKey:@"baseUrlComponentsCount"] intValue] ;
    NSString *errorMessage = [params objectForKey:@"errorMessage"] ;
    MSInt listeningPort = [[params objectForKey:@"listeningPort"] intValue] ;
    
    NSString *file = nil ;
    NSString *applicationList = @"" ;
    NSArray *applicationBaseURLs = [params objectForKey:@"applicationBaseURLs"] ;
    
    NSEnumerator *e = [applicationBaseURLs objectEnumerator] ;
    NSDictionary *appURLInfos ;
    NSString *fileName = @"default_choice_login" ;
    BOOL isDir = NO ;
    
    file = [[NSBundle bundleForClass:[MHApplication class]]  pathForResource:fileName ofType:@"html"] ;
    
    if (MSFileExistsAtPath(file, &isDir) && !isDir)
    {
        void *bytes ;
        NSMutableString *page = MHOpenFileForSubstitutions(file) ;
                
        while ((appURLInfos = [e nextObject]))
        {
            MSInt appListeningPort = [[appURLInfos objectForKey:@"listeningPort"] intValue] ;
            if((appListeningPort == listeningPort) && [[appURLInfos objectForKey:@"application"] isKindOfClass:[MHGUIAuthenticatedApplication class]]) //only display Authenticated application in list
            {
                NSString *appURL = [appURLInfos objectForKey:@"url"] ;
                MHApplication *app = [MHApplication applicationForURL:appURL listeningPort:listeningPort baseUrlComponentsCount:baseUrlComponentsCount] ;
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
        }
        
        page = [page replaceOccurrencesOfString:@"%__APPLICATION_LIST__%" withString:applicationList] ;
        page = [page replaceOccurrencesOfString:@"%__ERROR_MESSAGE__%" withString:[errorMessage length] ? errorMessage : @""] ;
        page = [page replaceOccurrencesOfString:@"%__CUSTOMERGROUP__%" withString:url] ;
       
        bytes = (void *)[page UTF8String] ;
        loginInterface = AUTORELEASE(MSCreateBufferWithBytes(bytes, strlen(bytes))) ;
        
    } else
    {
        MSRaise(NSGenericException, @"MHGUIAuthenticatedApplication : cannot find interface templace at path '%@'", file) ;
    }
    
    return loginInterface ;
}


@end

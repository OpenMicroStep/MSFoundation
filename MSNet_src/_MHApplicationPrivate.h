//
//  MHApplication+Private.h
//  MSFoundation
//
//  Created by Geoffrey Guilbon on 20/11/13.
//
//

#define MHNOTIF_PARAM_MHAPP_AUTH_TYPE  @"__MHAPP_AUTH_TYPE__"
#define MHNOTIF_PARAM_MHLOGIN          @"__MHLOGIN__"
#define MHNOTIF_PARAM_MHPWD            @"__MHPWD__"
#define MHNOTIF_PARAM_MHTARGET         @"__MHTARGET__"
#define MHNOTIF_PARAM_CERT             @"__MHCERT__"
#define MHNOTIF_PARAM_TICKET           @"__MHTICKET__"
#define MHNOTIF_PARAM_CHALLENGE        @"__MHCHALLENGE__"

#define MHAPP_TICKET_VALIDITY       @"ticketValidity"
#define MHAPP_TICKET_CREATIONDATE   @"ticketCreationDate"
#define MHAPP_TICKET_PARAMETERS     @"ticketParameters"

#define SESSION_PARAM_URN           @"__MH_SESS_URN__"
#define SESSION_PARAM_TARGET        @"__MH_SESS_TARGET__"
#define SESSION_PARAM_LOGIN         @"__MH_SESS_LOGIN__"
#define SESSION_PARAM_CHALLENGE     @"__MH_SESS_PLAIN_CHALLENGE__"

NSMutableString *MHOpenFileForSubstitutions(NSString *file) ;

@interface MHApplication (Private)

- (void)validateAuthentication:(MHNotification *)notification ;
- (void)deleteExpiredTickets ;
- (BOOL)isGUIApplication ;
- (BOOL)isAdminApplication ;

@end

@interface MHGUIApplication (Private)

+ (MSBuffer *)loginInterfaceAppChoiceWithParameters:(NSDictionary *)params ;
- (BOOL)isGUIApplication ;

@end

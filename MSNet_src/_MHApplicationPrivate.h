//
//  MHAuthenticatedApplication+Private.h
//  MSFoundation
//
//  Created by Geoffrey Guilbon on 20/11/13.
//
//

#define MHNOTIF_PARAM_MHAPP_AUTH_TYPE  @"__MHAPP_AUTH_TYPE__"
#define MHNOTIF_PARAM_MHLOGIN          @"__MHLOGIN__"
#define MHNOTIF_PARAM_MHPWD            @"__MHPWD__"
#define MHNOTIF_PARAM_CERT             @"__MHCERT__"
#define MHNOTIF_PARAM_TICKET           @"__MHTICKET__"
#define MHNOTIF_PARAM_CHALLENGE        @"__MHCHALLENGE__"

NSMutableString *MHOpenFileForSubstitutions(NSString *file) ;

@interface MHAuthenticatedApplication (Private)

- (void)validateAuthentication:(MHNotification *)notification ;

@end

@interface MHGUIAuthenticatedApplication (Private)

+ (MSBuffer *)loginInterfaceWithParameters:(NSDictionary *)params ;

@end

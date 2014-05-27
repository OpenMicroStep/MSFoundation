//  MSAuthentication.m, ecb, 131017

#import "MHRepositoryKit.h"

BOOL isPasswordVerified(NSString *givenPwd, NSString *knownPwd)
{
    return YES;
    givenPwd= nil; // unused parameter
    knownPwd= nil; // unused parameter
}

BOOL isCertificateVerified(MSCertificate *givenCertif, MSCertificate *knownCertif)
{
    BOOL isVerified = NO ;
    
    if (givenCertif && knownCertif) {
        isVerified = [givenCertif isEqual:knownCertif] ;
    }
    
    return isVerified ;
}

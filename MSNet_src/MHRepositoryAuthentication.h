//  MSAuthentication.h, ecb, 131017

BOOL isPasswordVerified(NSString *givenPwd, NSString *knownPwd);
BOOL isCertificateVerified(MSCertificate *givenCertif, MSCertificate *knownCertif);

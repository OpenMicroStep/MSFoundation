//
//  MHCertificateAdditions.m
//  MSFoundation
//
//  Created by Geoffrey Guilbon on 22/10/13.
//
//

#import "_MASHPrivate.h"

#define SET_STR(X,S) { id __s__ = S ; X = __s__ ? __s__ : @"" ; }

@implementation MSCertificate (MHCertificateAdditions)

- (NSString *)uniqueRepositoryName
{
    NSString *name, *country, *organisation, *serial, *cname ;
    
    SET_STR(name, [self issuerCommonName]) ;
    SET_STR(country, [self issuerCountryName]) ;
    SET_STR(organisation, [self issuerOrganizationName]) ;
    SET_STR(serial, [self serial]) ;
    SET_STR(cname, [self subjectCommonName]) ;
    
    return [NSString stringWithFormat:@"%@:%@:%@:%@:%@",cname, country, organisation, name, serial] ;
}

@end

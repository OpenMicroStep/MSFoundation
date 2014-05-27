/*
 
 MSCertificate.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Geoffrey Guilbon : gguilbon@gmail.com
 
 
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
 
 WARNING : this header file cannot be included alone, please direclty
 include <MSFoundation/MSFoundation.h>
 */

#import "MSNet_Private.h"
#import "MSASCIIString.h"
#import "MSDate.h"
#import <openssl/x509.h>

@implementation MSCertificate

#define OID_MAX_LENGTH 128

- (NSString *)_X509StringFromASN1Object:(void *)object
{
    MSInt len ;
    char *buf = (char *)malloc(OID_MAX_LENGTH * sizeof(char)) ;
    MSBuffer *data = nil ;

    len = OPENSSL_OBJ_obj2txt(buf, OID_MAX_LENGTH, object, 0) ;
    data = MSCreateBufferWithBytesNoCopyNoFree(buf, len) ;
    
#ifdef WO451
    return [[[NSString alloc] initWithCStringNoCopy:((CBuffer*)data)->buf length:((CBuffer*)data)->length freeWhenDone:YES] autorelease] ;
#else
	return [[[NSString alloc] initWithBytesNoCopy:((CBuffer*)data)->buf length:((CBuffer*)data)->length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease] ;
#endif
}

- (NSString *)_X509StringFromASN1String:(void *)str
{
	char *buffer ;
    MSInt len ;
    
	if ((len = OPENSSL_ASN1_STRING_to_UTF8((unsigned char**)&buffer, str)) < 0) { return nil ; }
#ifdef WO451
    return [[[NSString alloc] initWithCStringNoCopy:buffer length:len freeWhenDone:YES] autorelease] ;
#else
	return [[[NSString alloc] initWithBytesNoCopy:buffer length:len encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease] ;
#endif
}

- (NSDictionary *)_X509DictionaryFrom509Name:(X509_NAME *)name
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary] ;
    int i, count = OPENSSL_X509_NAME_entry_count(name) ;
    
    for (i = 0; i < count; i++) {
        NSString *key;
        void *entry = OPENSSL_X509_NAME_get_entry(name, i) ;
        void *obj = OPENSSL_X509_NAME_ENTRY_get_object(entry) ;
        void *str = OPENSSL_X509_NAME_ENTRY_get_data(entry) ;
        key = [self _X509StringFromASN1Object: obj];
        if (! [dict objectForKey:key]) { [dict setObject:[self _X509StringFromASN1String:str] forKey:key] ; }
    }
    
    return dict ;
}

- (NSString *)_serialFromX509
{
    void *serialBN = OPENSSL_ASN1_INTEGER_to_BN(OPENSSL_X509_get_serialNumber(_cert), NULL) ;
    char *serialHex = OPENSSL_BN_bn2hex(serialBN) ;

    return AUTORELEASE(MSCreateASCIIStringWithBytes((void *)serialHex, strlen(serialHex), YES, YES)) ;
}

- (NSString *)_issuerValueForKey:(NSString *)key
{
    if(!_issuer) ASSIGN(_issuer, [self _X509DictionaryFrom509Name:OPENSSL_X509_get_issuer_name(_cert)]) ;
    
    return [_issuer objectForKey:key] ;
}

- (NSString *)_subjectValueForKey:(NSString *)key
{
    if(!_subject) ASSIGN(_subject, [self _X509DictionaryFrom509Name:OPENSSL_X509_get_subject_name(_cert)]) ;
    
    return [_subject objectForKey:key] ;
}

- (NSString *)serial
{
    if(!_serial) ASSIGN(_serial, [self _serialFromX509]) ;
    
    return _serial ;
}

+ (id)certificateWithX509:(void *)x509
{
     return [[[self alloc] initWithX509:x509] autorelease] ;
}


- (id)initWithX509:(void *)x509
{
    _cert = x509 ;
    
    return self ;
}

+ (id)certificateWithBuffer:(MSBuffer *)buffer
{
    return [[[self alloc] initWithBuffer:buffer] autorelease] ;
}

- (id)initWithBuffer:(MSBuffer *)buffer
{
    BIO *certbio = OPENSSL_BIO_new_mem_buf((void *)[buffer bytes], [buffer length]) ;
    
    //try to read certificate with PEM format
    _cert = OPENSSL_PEM_read_bio_X509(certbio, NULL, 0, NULL) ;

    if(!_cert) // if certificate is not PEM, try DER format
    {
        if(OPENSSL_BIO_reset(certbio)) { MSRaise(NSGenericException, @"MSCertificate cannot reset BIO") ; }
        _cert = OPENSSL_d2i_X509_bio(certbio, NULL) ;
    }
    
    if(!_cert)
    {
        MSRaise(NSGenericException, @"MSCertificate wrong format, cannot read PEM or DER certificate from data") ;
    }
    
    OPENSSL_BIO_free_all(certbio) ;
    
    return self ;
}

- (void)dealloc
{
    if(_cert) OPENSSL_X509_free(_cert) ;
    
    DESTROY(_issuer) ;
    DESTROY(_subject) ;
    
    [super dealloc] ;
}

- (NSString *)issuerCommonName { return [self _issuerValueForKey:@"commonName"] ; }
- (NSString *)issuerCountryName { return [self _issuerValueForKey:@"countryName"] ; }
- (NSString *)issuerOrganizationName { return [self _issuerValueForKey:@"organizationName"] ; }

- (NSString *)subjectCommonName { return [self _subjectValueForKey:@"commonName"] ; }
- (NSString *)subjectCountryName { return [self _subjectValueForKey:@"countryName"] ; }
- (NSString *)subjectDnQualifier { return [self _subjectValueForKey:@"dnQualifier"] ; }
- (NSString *)subjectOrganizationName { return [self _subjectValueForKey:@"organizationName"] ; }
- (NSString *)subjectOrganizationalUnitName { return [self _subjectValueForKey:@"organizationalUnitName"] ; }

- (NSString *)fingerPrint:(MSDigest)digest
{
    unsigned int fprint_size;
    unsigned char fprint[EVP_MAX_MD_SIZE];
    const void *fprint_type = MSDigestToEVP_MD(digest) ;
    
    memset(fprint, 0, EVP_MAX_MD_SIZE) ;
        
    if (!OPENSSL_X509_digest(_cert, fprint_type, fprint, &fprint_size))
    {
        MSRaise(NSGenericException, @"MSCertificate failed to create SHA fingerprint") ;
    }
    
    return MSBytesToHexaString(fprint, fprint_size , NO) ;
}

#define DIC_ADD(D,V,K) value = V ; if(V) { [dic setObject:V forKey:K] ; }

- (NSString *)description {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary] ;
    id value ;
    
    DIC_ADD(div, [self issuerCommonName], @"issuerCommonName")
    DIC_ADD(div, [self issuerOrganizationName], @"issuerOrganizationName")
    DIC_ADD(div, [self issuerCountryName], @"issuerCountryName")
    DIC_ADD(div, [self issuerOrganizationName], @"issuerOrganizationName")
    DIC_ADD(div, [self subjectCommonName], @"subjectCommonName")
    DIC_ADD(div, [self issuerCountryName], @"issuerCountryName")
    DIC_ADD(div, [self subjectDnQualifier], @"subjectDnQualifier")
    DIC_ADD(div, [self subjectOrganizationName], @"subjectOrganizationName")
    DIC_ADD(div, [self subjectOrganizationalUnitName], @"subjectOrganizationalUnitName")
    DIC_ADD(div, [self serial], @"serial")
    DIC_ADD(div, [self fingerPrint:MS_SHA1], @"SHA fingerPrint")
    
    return [dic description] ;
}

- (MSDate *)_dateFromASN1_TIME:(void *)asn1Time
{
    ASN1_GENERALIZEDTIME *generalizedTime ;
    NSString *strDate ;
    NSCalendarDate *date ;
    
    generalizedTime = OPENSSL_ASN1_TIME_to_generalizedtime(asn1Time, NULL) ;
    strDate = [MSASCIIString stringWithBytes:generalizedTime->data length:generalizedTime->length] ;
    date = [NSCalendarDate dateWithString:strDate calendarFormat:@"%Y%m%d%H%M%SZ"] ;

    return [MSDate dateWithDate:date] ;
}

- (MSDate *)notValidAfter
{
    return [self _dateFromASN1_TIME:OPENSSL_X509_get_notAfter(_cert)] ;
}

- (MSDate *)notValidBefore
{
    return [self _dateFromASN1_TIME:OPENSSL_X509_get_notBefore(_cert)] ;
}

- (BOOL)isEqual:(MSCertificate *)certificate
{
    return [[self fingerPrint:MS_SHA1] isEqual:[certificate fingerPrint:MS_SHA1]] ;
}

@end

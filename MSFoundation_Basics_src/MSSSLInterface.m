/*
 
 MSSLInterface.m
 
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
 */

#import "MSFoundation_Private.h"
#import <openssl/err.h>
#import <openssl/rand.h>
#import <openssl/evp.h>
#import <openssl/ssl.h>

#define ERR_BUFF_SIZE 1024

NSString *MSGetOpenSSLErrStr()
{
	char err_buff[ERR_BUFF_SIZE];
	OPENSSL_ERR_error_string_n(OPENSSL_ERR_get_error(),err_buff,ERR_BUFF_SIZE) ;
	
#ifdef WIN32
	return [NSString stringWithCString:err_buff] ;
#else
	return [NSString stringWithCString:err_buff encoding:NSUTF8StringEncoding] ;
#endif
}

MSFoundationExport NSString *MSGetOpenSSL_SSLErrStr(void *ssl, int ret)
{
    NSString *errorStr ;
    int errnum = OPENSSL_SSL_get_error(ssl, ret) ;
    
    switch (errnum) {
        case SSL_ERROR_NONE:                errorStr = @"SSL_ERROR_NONE" ; break;
        case SSL_ERROR_ZERO_RETURN:         errorStr = @"SSL_ERROR_ZERO_RETURN" ; break;
        case SSL_ERROR_WANT_READ:           errorStr = @"SSL_ERROR_WANT_READ" ; break;
        case SSL_ERROR_WANT_WRITE:          errorStr = @"SSL_ERROR_WANT_WRITE" ; break;
        case SSL_ERROR_WANT_CONNECT:        errorStr = @"SSL_ERROR_WANT_CONNECT" ; break;
        case SSL_ERROR_WANT_ACCEPT:         errorStr = @"SSL_ERROR_WANT_ACCEPT" ; break;
        case SSL_ERROR_WANT_X509_LOOKUP:    errorStr = @"SSL_ERROR_WANT_X509_LOOKUP" ; break;
        case SSL_ERROR_SYSCALL:             errorStr = [NSString stringWithFormat:@"SSL_ERROR_SYSCALL : %@", MSGetOpenSSLErrStr()] ; break;
        case SSL_ERROR_SSL:                 errorStr = [NSString stringWithFormat:@"SSL_ERROR_SSL : %@", MSGetOpenSSLErrStr()] ; break;
            
        default: errorStr = @"MSGetOpenSSL_SSLErrStr Error"; break;
    }

    return errorStr ;
}

void MSRaiseCryptoOpenSSLException()
{
	OPENSSL_ERR_load_crypto_strings();
	MSRaise(NSGenericException, @"Error using crypto openssl function '%@'", MSGetOpenSSLErrStr()) ;
}

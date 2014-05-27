/*
 
 _MSDigest.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
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
 
 A call to the MSFoundation initialize function must be done before using
 these functions.
 */

#import "MSNet_Private.h"
#import <openssl/evp.h>

const EVP_MD *MSDigestToEVP_MD(MSDigest digest)
{
	switch (digest) {
            
		case MS_MD5:
			return OPENSSL_EVP_md5();
		case MS_SHA1:
			return OPENSSL_EVP_sha1();
        case MS_SHA256:
			return OPENSSL_EVP_sha256();
        case MS_SHA512:
			return OPENSSL_EVP_sha512();
		case MS_DSS1:
			return OPENSSL_EVP_dss1();
		case MS_MDC2:
			return OPENSSL_EVP_mdc2();
		case MS_RIPEMD160:
			return OPENSSL_EVP_ripemd160();
		default:
			MSRaise(NSInternalInconsistencyException, @"Digest type Not supported") ;
	}
    return NULL ;
}

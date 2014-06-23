/*
 
 MSDigest.m
 
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
 */

#import "MSNet_Private.h"
#import <openssl/evp.h>

#define WORKING_BLOCK_SIZE 1024

NSString *MSDigestData(MSDigest digest, const void *bytes, NSUInteger length)
{
	EVP_MD_CTX mdctx ;
	const EVP_MD *md = NULL ;
	unsigned char inBuff[WORKING_BLOCK_SIZE], *outBuff ;
	int outLen ;
	NSUInteger remainingData = length ;
	NSRange range ;
    NSString *hash ;
	MSBuffer *data = nil ;
    
    OPENSSL_initialize() ;
    
    if(length < 1)
    {
        return nil ;
    }
	
    md = MSDigestToEVP_MD(digest) ;
	
	// Initialisations
	OPENSSL_EVP_MD_CTX_init(&mdctx) ;
  data = AUTORELEASE(MSCreateBufferWithBytes((void *)bytes, length)) ;
	outBuff = (unsigned char *)malloc(EVP_MAX_MD_SIZE * sizeof(unsigned char)) ;
	range.location = 0;
	range.length = WORKING_BLOCK_SIZE ;
	
	if(!OPENSSL_EVP_DigestInit_ex(&mdctx, md, NULL))
	{
		MSRaiseCryptoOpenSSLException();
	}
	
	// Digest loop
	while(remainingData > 0)
	{
		if(remainingData < WORKING_BLOCK_SIZE)
		{
			range.length = remainingData;
		}
		
		[data getBytes:inBuff range:range];
		
		if(!OPENSSL_EVP_DigestUpdate(&mdctx, inBuff, range.length))
		{
			MSRaiseCryptoOpenSSLException();
		}
		
		range.location += range.length;
		remainingData  -= range.length;
	}
	
	// Digest endings
	if(!OPENSSL_EVP_DigestFinal_ex(&mdctx, outBuff, &outLen))
	{
		MSRaiseCryptoOpenSSLException();
	}
	
	hash = MSBytesToHexaString(outBuff, (NSUInteger)outLen, NO) ;
    
	free(outBuff);
	OPENSSL_EVP_MD_CTX_cleanup(&mdctx);
	
	return hash ; 
}

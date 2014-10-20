/*
 
 _RSACipher.m
 
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

#import "MSNet_Private.h"
#import <openssl/rsa.h>

@implementation _RSACipher

- (void) _initMembers
{
	_rsaKey = NULL;
}

-(id) initWithPEMKey:(NSData *)key type:(MSCipherType)type
{
	void *bioKey;
	[self _initMembers];

	bioKey = OPENSSL_BIO_new_mem_buf((void *)[key bytes], (int)[key length]);

	if(!bioKey)
	{
		MSRaise(NSGenericException, @"Error bio reading private key '%@' openssl errstr:%@", key, MSGetOpenSSLErrStr()) ;
	}
	
	switch (type) {
		case RSAEncoder:
			_rsaKey = (RSA *) OPENSSL_PEM_read_bio_RSA_PUBKEY(bioKey, NULL, NULL, NULL);
			break;
		case RSADecoder:
			_rsaKey = (RSA *) OPENSSL_PEM_read_bio_RSAPrivateKey(bioKey, NULL, NULL, NULL);
			break;
		default:
			MSRaiseFrom(NSInternalInconsistencyException, self, _cmd, @"MSCipher wrong cipher type");
			break;
	}
	
	OPENSSL_BIO_free(bioKey);
	
	if(!_rsaKey)
	{
		MSRaise(NSGenericException, @"Error reading RSA key '%@' openssl errstr:%@", key, MSGetOpenSSLErrStr()) ;
	}
	
	_cipherType = type;
	return self;
}


- (void) dealloc
{
	OPENSSL_RSA_free(_rsaKey);
	[super dealloc];
}
	
- (NSData *) _encryptData:(NSData *)plainData
{
	unsigned int buffSize = OPENSSL_RSA_size(_rsaKey);
	unsigned char *encryptedBuff =  (unsigned char *)malloc(buffSize);
	
	int len = OPENSSL_RSA_public_encrypt([plainData length], (unsigned char *)[plainData bytes], encryptedBuff, _rsaKey, RSA_PKCS1_PADDING);
	
    if(len == -1)
    {
        free(encryptedBuff);
		return nil;
    }
	
    return AUTORELEASE(MSCreateBufferWithBytesNoCopy(encryptedBuff, (NSUInteger)len));
}

- (BOOL) _isPrivate
{
	return(((RSA *)_rsaKey)->d != NULL);
}

- (NSData *) encryptData:(NSData *)plainData
{
	if([self _isPrivate])
	{
		MSRaise(NSGenericException, @"Error : trying to encrypt data with private key") ;
	}
	
	if(plainData == nil)
	{
		return nil;
	}

	return [self _encryptData:plainData];
}

- (NSData *) _decryptData:(NSData *)cipherData
{
	unsigned int buffSize = OPENSSL_RSA_size(_rsaKey);
	unsigned char *clearBuff =  (unsigned char *)malloc(buffSize);
	
    int len = OPENSSL_RSA_private_decrypt([cipherData length], (unsigned char *)[cipherData bytes], clearBuff, _rsaKey, RSA_PKCS1_PADDING);
	
    if(len == -1)
    {
        free(clearBuff);
		return nil;
    }
		
	return AUTORELEASE(MSCreateBufferWithBytesNoCopy(clearBuff, (NSUInteger)len));
}

- (NSData *) decryptData:(NSData *)cipherData
{
	if(![self _isPrivate])
	{
		MSRaise(NSGenericException, @"Error : trying to encrypt data with public key") ;
	}
	
	if(cipherData == nil)
	{
		return nil;
	}

    return [self _decryptData:cipherData];
}

+ (NSData *)_bioToPrivateKeyFromRSA:(RSA *)rsa
{
	int res = 0;
	int keyLen = 0;
	BIO *bio = NULL;
	char *buff = NULL;
	
	bio = (BIO *)OPENSSL_BIO_new(OPENSSL_BIO_s_mem());
	res = OPENSSL_PEM_write_bio_RSAPrivateKey(bio, rsa, NULL, NULL, 0, NULL, NULL);

	if(res == 0)
	{
		MSRaise(NSGenericException, @"Error writing private key to BIO") ;
	}
	
	keyLen = (int)OPENSSL_BIO_ctrl_pending(bio);
	buff = (char*)malloc(keyLen * sizeof(char));
	OPENSSL_BIO_read(bio, buff, keyLen);
	OPENSSL_BIO_free_all(bio);
	
	//buff is not freed because it's managed inside MSBuffer;
	return [[[MSBuffer alloc] initWithBytesNoCopy:buff length:keyLen freeWhenDone:YES] autorelease];
}

+ (NSData *)_bioToPublicKeyFromRSA:(RSA *)rsa
{
	int res = 0;
	int keyLen = 0;
	BIO *bio = NULL;
	char *buff = NULL;

	bio = (BIO *)OPENSSL_BIO_new(OPENSSL_BIO_s_mem());
	res = OPENSSL_PEM_write_bio_RSA_PUBKEY(bio, rsa);

	if(res == 0)
	{
		MSRaise(NSGenericException, @"Error writing public key to BIO") ;
	}

	keyLen = (int)OPENSSL_BIO_ctrl_pending(bio);
	buff = (char*)malloc(keyLen * sizeof(char));
	OPENSSL_BIO_read(bio, buff, keyLen);
	OPENSSL_BIO_free_all(bio);

	//buff is not freed because it's managed inside MSBuffer;
	return [[[MSBuffer alloc] initWithBytesNoCopy:buff length:keyLen freeWhenDone:YES] autorelease];	
}

+ (MSCouple *) createKeyPairWithKeyType:(MSCipherKeyType)keyType
{
	RSA *keys = NULL;
	MSCouple *keyPairCouple = nil;
	
	//generate key pair
	keys = (RSA *)OPENSSL_RSA_generate_key(keyType,RSA_F4,NULL,NULL);
	
	if(!keys)
	{
		MSRaise(NSGenericException, @"openssl errstr:%@", MSGetOpenSSLErrStr()) ;
	}

	keyPairCouple = MSCreateCouple([self _bioToPublicKeyFromRSA:keys], [self _bioToPrivateKeyFromRSA:keys]);

	OPENSSL_RSA_free(keys);
	
	return keyPairCouple;
}

- (MSCipherType)cipherType
{
	return _cipherType;
}

@end

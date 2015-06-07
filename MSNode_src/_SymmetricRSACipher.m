/*
 
 _SymmetricCipher.m
 
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

#import "MSNode_Private.h"

#define SYM_KEY_SIZE 128 //Max 245 for RSA 2048 key
#define AES_256_KEY_SIZE 256
#define AES_TYPE AES256CBC

@implementation _SymmetricRSA

- (id) initWithPEMKey:(NSData *)key type:(MSCipherType)type
{
	switch (type) {
		case SymmetricRSAEncoder:
			_rsaCipher = [[_RSACipher alloc] initWithPEMKey:key type:RSAEncoder];
			break;
		case SymmetricRSADecoder:
			_rsaCipher = [[_RSACipher alloc] initWithPEMKey:key type:RSADecoder];
			break;
		default:
			MSRaiseFrom(NSInternalInconsistencyException, self, _cmd, @"MSCipher wrong cipher type");
			break;
	}
	return self;
}

- (void) dealloc
{
	[_rsaCipher release];
	[super dealloc];
}

- (NSData *)encryptData:(NSData *)data
{
	NSData *symKey, *cipherData, *cipherKey;
	NSMutableData *symetricRSACipherData;
	_SymmetricCipher *aesCoder;
	
	//Generate symetric key
	symKey = MSCreateRandomBuffer(SYM_KEY_SIZE);
	aesCoder = [[_SymmetricCipher alloc] initWithKey:symKey type:AES_TYPE];
	
	//Encode data using symetric cipher
	cipherData = [aesCoder encryptData:data];
	
	//Encode symetric key using public key
	cipherKey = [_rsaCipher encryptData:symKey];
	
	//Add cipher key at the beginning of cipher data
	symetricRSACipherData = [NSMutableData dataWithData:cipherKey];
	[symetricRSACipherData appendData:cipherData];
	
    [symKey release];
	[aesCoder release];
	return symetricRSACipherData;
}

- (NSData *)decryptData:(NSData *)data
{
	NSData *cipherKey, *symKey, *cipherData, *symetricRSAPlainData;
	_SymmetricCipher *aesDecoder;
	
	//Get cipher key using private key
	cipherKey = [data subdataWithRange:NSMakeRange(0, AES_256_KEY_SIZE)];
	
	//Decode cipher key
	symKey = [_rsaCipher decryptData:cipherKey];
	
	//Decode data with symetric cipher
	cipherData = [data subdataWithRange:NSMakeRange(AES_256_KEY_SIZE, [data length] - AES_256_KEY_SIZE)];
	aesDecoder = [[_SymmetricCipher alloc] initWithKey:symKey type:AES_TYPE];
	
	symetricRSAPlainData = [aesDecoder decryptData:cipherData];

	[aesDecoder release];
	return symetricRSAPlainData;
}

- (BOOL)verify:(NSData *)signature ofMessage:(NSData*)message
{
  return [_rsaCipher verify:signature ofMessage:message];
}

- (NSData *)sign:(NSData *)message
{
  return [_rsaCipher sign:message];
}

- (MSCipherType)cipherType
{
	return [_rsaCipher cipherType];
}

@end

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

#define BINKEY_ROUND_COUNT 5
#define WORKING_BLOCK_SIZE 1024
#define SALT_SIZE 8

@implementation _SymmetricCipher

- (int)_binKeySize
{
	return EVP_CIPHER_key_length(_cipher);
}

- (void)_generateBinKeyAndIVFromKey:(NSData *)key andSalt:(unsigned char *)salt
{
    // Generate key and IV for cipher using SHA digest
	int size = EVP_BytesToKey(_cipher, EVP_sha1(), salt, [key bytes], (int)[key length], BINKEY_ROUND_COUNT, _binKey, _iv);
    
	if (size != [self _binKeySize])
	{
		MSRaise(NSGenericException, @"EVP_BytesToKey : MSCipher binKey size is %d, should be %d", size, [self _binKeySize]) ;
	}
}

- (id)_initWithKey:(NSData *)key
{
    ASSIGN(_key, key) ;
    
    // Initialize contexts
	_ctx = EVP_CIPHER_CTX_new() ;
    if(!_ctx)
    {
        MSRaise(NSGenericException, @"MSCipher unable to create ssl context") ;
    }
    EVP_CIPHER_CTX_init(_ctx);
	
	// memory allocations
	_binKey = (unsigned char *) malloc([self _binKeySize] * sizeof(unsigned char));
	_iv = (unsigned char *) malloc(EVP_CIPHER_iv_length(_cipher) * sizeof(unsigned char));

	return self;
}

- (NSData *)_cryptData:(NSData *)data doCrypt:(BOOL)doEncrypt
{
	unsigned char inBuff[WORKING_BLOCK_SIZE + EVP_MAX_BLOCK_LENGTH], outBuff[WORKING_BLOCK_SIZE + EVP_MAX_BLOCK_LENGTH];
	int outLen;
	NSUInteger remainingData = (NSUInteger)[data length];
	MSBuffer *outData = AUTORELEASE(MSCreateBuffer([data length])) ;
	NSRange range;
	unsigned char salt[SALT_SIZE];
  
    range.location = 0;

    if(doEncrypt)
    {
        MSBuffer *randBuf ;
        
        // Initialize salt and put it in output buffer
        if(! (randBuf = MSCreateRandomBuffer(SALT_SIZE)))
        {
            MSRaise(NSGenericException, @"MSCipher failed to create salt") ;
        }
        
        memcpy(salt, ((CBuffer*)randBuf)->buf, SALT_SIZE) ;
        CBufferAppendBytes((CBuffer *)outData, salt, SALT_SIZE) ;
        
        DESTROY(randBuf) ;
    }
    else
    {
        //get salt from data
        if(remainingData < SALT_SIZE)
        {
            MSRaise(NSGenericException, @"MSCipher data too short to containt salt %u/%u", remainingData, SALT_SIZE) ;
        }
        
        range.length = SALT_SIZE;
        [data getBytes:salt range:range];
                
        //read data after salt
        range.location = SALT_SIZE;
        remainingData  -= range.length;
    }

    //Generate BinKey and IV
    [self _generateBinKeyAndIVFromKey:_key andSalt:salt] ;
    
	range.length = WORKING_BLOCK_SIZE;
    
	if(!EVP_CipherInit_ex(_ctx, _cipher, NULL, _binKey, _iv, doEncrypt))
	{
		MSRaiseCryptoOpenSSLException();
	}

	// Encryption loop
	while(remainingData > 0)
	{
		if(remainingData < WORKING_BLOCK_SIZE)
		{
			range.length = remainingData;
		}
		
		[data getBytes:inBuff range:range];
		
		if(!EVP_CipherUpdate(_ctx, outBuff, &outLen, inBuff, range.length))
		{
			MSRaiseCryptoOpenSSLException();
		}
		CBufferAppendBytes((CBuffer *)outData, outBuff, outLen) ;
		
		range.location += range.length;
		remainingData  -= range.length;
	}
	
	// Encryption endings
	if(!EVP_CipherFinal_ex(_ctx, outBuff, &outLen))
	{
		MSRaiseCryptoOpenSSLException();
	}
	CBufferAppendBytes((CBuffer *)outData, outBuff, outLen) ;
	
	EVP_CIPHER_CTX_cleanup(_ctx);
	
	return outData;
}


- (id) initWithKey:(NSData *)key type:(MSCipherType)type
{
	switch (type) {
		case AES256CBC:
			_cipher = (const EVP_CIPHER *)EVP_aes_256_cbc();
			break;
		case AES192CBC:
			_cipher = (const EVP_CIPHER *)EVP_aes_192_cbc();
			break;
		case AES128CBC:
			_cipher = (const EVP_CIPHER *)EVP_aes_128_cbc();
			break;
		case BlowfishCBC:
			_cipher = (const EVP_CIPHER *)EVP_bf_cbc();
			break;
		case BlowfishCFB:
			_cipher = (const EVP_CIPHER *)EVP_bf_cfb64();
			break;
		case BlowfishOFB:
			_cipher = (const EVP_CIPHER *)EVP_bf_ofb();
			break;
		default:
			MSRaiseFrom(NSInternalInconsistencyException, self, _cmd, @"MSCipher wrong symmetric cipher type");
			break;
	}
	
	_cipherType = type;
	return [self _initWithKey:key];
}

- (void) dealloc
{
	EVP_CIPHER_CTX_free(_ctx);
	free(_binKey);
	free(_iv);
    DESTROY(_key);
	[super dealloc];
}

- (NSData *)encryptData:(NSData *)plainData
{
	return [self _cryptData:plainData doCrypt:YES];
}

- (NSData *)decryptData:(NSData *)cipherData
{
	return [self _cryptData:cipherData doCrypt:NO];
}

static void computeHMAC(unsigned char *key, int key_sz, unsigned char *msg, int msg_sz, unsigned char *out, unsigned int *out_sz)
{
  HMAC_CTX hctx;
  unsigned int outlen;
  HMAC_CTX_init(&hctx);
  if(!HMAC_Init_ex(&hctx, key, key_sz, EVP_sha1(), NULL) ||
     !HMAC_Update(&hctx, msg, msg_sz) ||
     !HMAC_Final(&hctx, out, &outlen)) {
    MSRaiseCryptoOpenSSLException();
  }
  HMAC_CTX_cleanup(&hctx);
}

- (BOOL)verify:(NSData *)signature ofMessage:(NSData*)message
{
  unsigned char expected[EVP_MAX_MD_SIZE];
  unsigned int expectedLength;
  computeHMAC((unsigned char*)[_key bytes], [_key length], (unsigned char*)[message bytes], [message length], expected, &expectedLength);
  return expectedLength == [signature length]
      && memcmp([signature bytes], expected, expectedLength) == 0;
}

- (NSData *)sign:(NSData *)message
{
  unsigned char expected[EVP_MAX_MD_SIZE];
  unsigned int expectedLength;
  computeHMAC((unsigned char*)[_key bytes], [_key length], (unsigned char*)[message bytes], [message length], expected, &expectedLength);
  return [NSData dataWithBytes:expected length:expectedLength];
}

- (MSCipherType)cipherType
{
	return _cipherType;
}


@end;

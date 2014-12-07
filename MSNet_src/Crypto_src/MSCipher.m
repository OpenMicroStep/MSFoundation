/*
 
 MSCipher.m
 
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
 */

#import "MSNet_Private.h"

/////////////////////  OpenSSL Win32 specific /////////////////////

@implementation MSCipher

+ (id)allocWithZone:(NSZone *)zone { return [_MSCipherAllocator allocator] ; }
+ (id)alloc { return [_MSCipherAllocator allocator] ; }

+ (id)cipherWithKey:(NSData *)key type:(MSCipherType)type
{
    return [[[self alloc] initWithKey:key type:type] autorelease] ;
}

+ (id)cipherWithContentsOfKeyFile:(NSString *)path type:(MSCipherType)type
{
    return [[[self alloc] initWithContentsOfKeyFile:path type:type] autorelease] ;
}

- (id)initWithKey:(NSData *)key type:(MSCipherType)type
{
	return [self notImplemented:_cmd] ;
}

- (id)initWithContentsOfKeyFile:(NSString *)path type:(MSCipherType)type
{
	NSData *data = [NSData dataWithContentsOfFile:path] ;
	if ([data length]) {
		return [self initWithKey:data type:type] ;
	}
	return nil ;
}

- (NSData *)encryptData:(NSData *)plainData
{
	return [self notImplemented:_cmd] ;
}
- (NSData *)decryptData:(NSData *)cipherData
{
	return [self notImplemented:_cmd] ;
}

- (BOOL)verify:(NSData *)signature ofMessage:(NSData*)message
{
  return [self notImplemented:_cmd] ;
}

- (NSData *)sign:(NSData *)data
{
  return [self notImplemented:_cmd] ;
}

- (MSCipherType)cipherType
{
	(void)[self notImplemented:_cmd] ;
	return 0;
}


@end

@implementation _MSCipherConcrete
+ (id)allocWithZone:(NSZone *)zone { return NSAllocateObject([self class], 0, zone) ; }
+ (id)alloc { return MSCreateObject([self class]) ; }
@end


static _MSCipherAllocator *__cipherAllocatorSingleton = nil;

@implementation _MSCipherAllocator
+ (void)load { if (!__cipherAllocatorSingleton) __cipherAllocatorSingleton = (_MSCipherAllocator *)MSCreateObject(self) ; }
+ (id)allocWithZone:(NSZone *)zone { return __cipherAllocatorSingleton ; }
+ (id)alloc { return __cipherAllocatorSingleton ; }
+ (id)new { return __cipherAllocatorSingleton ; }
+ (id)allocator { OPENSSL_initialize() ; return __cipherAllocatorSingleton ; }
- (id)init { return self ; }

- (id)initWithKey:(NSData *)key type:(MSCipherType)type
{
	switch (type) {
		case AES256CBC:
		case AES192CBC:
		case AES128CBC:
		case BlowfishCBC:
		case BlowfishCFB:
		case BlowfishOFB:
			return (id)[[_SymmetricCipher alloc] initWithKey:key type:type] ; 
			break;
		case RSAEncoder:
		case RSADecoder:
			return (id)[[_RSACipher alloc] initWithPEMKey:key type:type] ;
			break;
		case SymmetricRSAEncoder:
		case SymmetricRSADecoder:
			return (id)[[_SymmetricRSA alloc] initWithPEMKey:key type:type] ; 
			break;
			
		default:
			MSRaiseFrom(NSInternalInconsistencyException, self, _cmd, @"MSCipher cipher type Not supported");
			break;
	}
	
	return nil;
}



- (id)retain { return self ; }
- (oneway void)release { }
- (id)autorelease { return self; }
- (void)dealloc {if (0) [super dealloc] ;} // No warning

@end

#define KEY_GENERATION_TRIES_COUNT 16;

MSCouple *MSCreateKeyPair(MSCipherKeyType type) // The return couple contains the public and the private key in that order.
{
    OPENSSL_initialize() ;
	return [_RSACipher createKeyPairWithKeyType:type] ;
}

MSBuffer *MSCreateRandomBuffer(NSUInteger length) // The return MSBuffer is retained
{
    unsigned int tries_count, max_tries = 0 ;
    unsigned char *buff = NULL ;
    
    OPENSSL_initialize()  ;
    buff = (unsigned char *) malloc(length * sizeof(unsigned char)) ;      
    
    max_tries = KEY_GENERATION_TRIES_COUNT ;
    
	for(tries_count=0; tries_count < max_tries; tries_count++)
	{
		if(OPENSSL_RAND_bytes(buff, length))
		{
			break;
		}
	}
	
	if(tries_count >= max_tries) {
		free(buff) ;
		return nil ;
	}
	
	//buff not freed now because will be freed when MSBuffer does dealloc
	return [[MSBuffer alloc] initWithBytesNoCopy:buff length:length freeWhenDone:YES] ;
}

/*

 MSSecureHash.m

 This file is is a part of the MicroStep Framework.

 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011

 Vincent Rouillé : v-rouille@logitud.fr

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
 include <MSNet/MSNet>

 A call to the MSFoundation initialize function must be done before using
 these functions.
 */

#import "MSNet_Private.h"

typedef struct {
    long long passAlgorithm, passHardness, challengeAlgorithm, challengeHardness;
    NSString *passSalt, *challengeSalt;
} MSSecureHashChallengeInfo;

static NSString *_computeHash(NSString *content, MSUInt algorithm, MSUInt hardness, NSString *salt);

static BOOL MSSecureHashIsValidAlgorithm(MSUInt algorithm)
{
    return algorithm == 1;
    // TODO: Remove SHA512 before it becomes popular (ie. before any production version) and use bcrypt
    // SHA512 is easy to implement on a GPU and FPGA with around 267.1 M/s on HD7970 (200E in 2014)
    // bcrypt use a special blowfish key expansion approch that makes the implementation slow & hard on GPU & FPGA
    // bcrypt is also not (YET ?) vulnerable to bitslicing
    // To defend against recent FPGA, scrypt can also be considered see : http://www.tarsnap.com/scrypt.html
}

static BOOL MSSecureHashIsValid(MSUInt algorithm, NSString *hash)
{
    switch (algorithm) {
        case 1:
            return [hash length] == 128;
        default:
            return NO;
    }
}

static inline NSString *bufferToBase64String(MSBuffer * raw) {
    MSBuffer *b64Challenge= [raw encodedToBase64];
    return AUTORELEASE(MSCreateASCIIStringWithBytes((void *)[b64Challenge bytes], [b64Challenge length], YES, YES));
}

static NSCharacterSet *__base64charset = nil;

@implementation MSSecureHash
+ (void)load
{
    NEW_POOL;
    __base64charset= [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="] retain];
    KILL_POOL;
}

+ (MSUInt)defaultAlgorithm { return 1; }
+ (MSUInt)defaultHardness { return 1000; }
+ (MSUInt)defaultSecureKeyHardness { return 2000; }

+ (NSString *)generateSalt
{
    MSBuffer *salt = MSCreateRandomBuffer(8);
    MSBuffer *b64salt = [salt encodedToBase64];
    NSString *saltInHexa = AUTORELEASE(MSCreateASCIIStringWithBytes((void*)[b64salt bytes], [b64salt length], YES, YES));
    RELEASE(salt);
    return saltInHexa;
}

+ (NSString *)generatePasswordRequest
{
    return [NSString stringWithFormat:@"%u:%u<%@>", [self defaultAlgorithm], [self defaultHardness], [self generateSalt]];
}

#pragma mark Init

+ (id)secureHashWithContent:(NSString *)content
{
    return AUTORELEASE([ALLOC(self) initWithContent:content]);
}

+ (id)secureHashWithContent:(NSString *)content algorithm:(MSUInt)algorithm hardness:(MSUInt)hardness salt:(NSString *)salt
{
    return AUTORELEASE([ALLOC(self) initWithContent:content algorithm:algorithm hardness:hardness salt:salt]);
}

+ (id)secureHashWithSecureHash:(NSString *)secureHash
{
    return AUTORELEASE([ALLOC(self) initWithSecureHash:secureHash]);
}

- (id)initWithContent:(NSString *)content
{
    return [self initWithContent:content
                       algorithm:[[self class] defaultAlgorithm]
                        hardness:[[self class] defaultHardness]
                            salt:[[self class] generateSalt]];
}

- (id)initWithContent:(NSString *)content algorithm:(MSUInt)algorithm hardness:(MSUInt)hardness salt:(NSString *)salt
{
    if(content) {
        _algorithm = algorithm;
        _hardness = hardness;
        ASSIGN(_salt, salt);
        ASSIGN(_hash, _computeHash(content, algorithm, hardness, salt));
        if(_hash)
            return self;
    }

    RELEASE(self);
    return nil;
}

- (id)initWithHash:(NSString *)hash algorithm:(MSUInt)algorithm hardness:(MSUInt)hardness salt:(NSString *)salt
{
    if(hardness > 0 && salt && hash &&
       MSSecureHashIsValidAlgorithm(algorithm) &&
       MSSecureHashIsValid(algorithm, hash))
    {
        _algorithm = algorithm;
        _hardness = hardness;
        ASSIGN(_salt, salt);
        ASSIGN(_hash, hash);
        return self;
    }

    RELEASE(self);
    return nil;
}

- (id)initWithSecureHash:(NSString *)secureHash
{
    NSScanner *scanner = [NSScanner scannerWithString:secureHash];
    long long algorithm, hardness;
    NSString *salt, *hash;

    if([scanner scanLongLong:&algorithm] &&
       [scanner scanString:@":" intoString:NULL] &&
       [scanner scanLongLong:&hardness] &&
       [scanner scanString:@"<" intoString:NULL] &&
       [scanner scanCharactersFromSet:__base64charset intoString:&salt] &&
       [scanner scanString:@">" intoString:NULL] &&
       [scanner scanCharactersFromSet:__base64charset intoString:&hash] &&
       [scanner isAtEnd] &&
       algorithm > 0 && algorithm < MSUIntMax &&
       hardness > 0 && hardness < MSUIntMax &&
       MSSecureHashIsValidAlgorithm(algorithm) &&
       MSSecureHashIsValid(algorithm, hash))
    {
        _algorithm = algorithm;
        _hardness = hardness;
        ASSIGN(_salt, salt);
        ASSIGN(_hash, hash);
        return self;
    }

    RELEASE(self);
    return nil;
}

- (void)dealloc
{
    DESTROY(_salt);
    DESTROY(_hash);
    [super dealloc];
}

#pragma mark Getters

- (MSUInt)algorithm
{
    return _algorithm;
}
- (MSUInt)hardness
{
    return _hardness;
}
- (NSString *)salt
{
    return _salt;
}

- (NSString *)hash
{
    return _hash;
}

- (NSString *)secureHash
{
    return [NSString stringWithFormat:@"%u:%u<%@>%@", _algorithm, _hardness, _salt, _hash];
}

#pragma mark Algorithms

static NSString * _computeAlgorithm1Hash(NSString *content, MSUInt hardness, NSString * salt);

static NSString *_computeHash(NSString *content, MSUInt algorithm, MSUInt hardness, NSString *salt)
{
    NSString *hash = nil;
    switch (algorithm) {
        case 1:
            hash = _computeAlgorithm1Hash(content, hardness, salt);
            break;

        default:
            break;
    }
    return MSSecureHashIsValid(algorithm, hash) ? hash : nil;
}


static NSString * _computeAlgorithm1Hash(NSString *content, MSUInt hardness, NSString * salt)
{
    MSDigest *md;
    MSBuffer *step;
    MSUInt i;
    md = [ALLOC(MSDigest) initWithType:MS_SHA512];
    [md updateWithData:[salt dataUsingEncoding:NSUTF8StringEncoding]];
    [md updateWithData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    step = [md digest];
    for(i = 0; i < hardness; ++i) {
        [md updateWithData:step];
        step = [md digest];
    }
    RELEAZEN(md);
    return MSBytesToHexaString([step bytes], [step length], NO);
}

#pragma mark Challenge

static BOOL parseChallengeInfo(NSString *challengeInfo, MSSecureHashChallengeInfo *outInfo)
{
    NSScanner *scanner = [NSScanner scannerWithString:challengeInfo];
    return
    [scanner scanLongLong:&(outInfo->passAlgorithm)] &&
    [scanner scanString:@":" intoString:NULL] &&
    [scanner scanLongLong:&(outInfo->passHardness)] &&
    [scanner scanString:@"<" intoString:NULL] &&
    [scanner scanCharactersFromSet:__base64charset intoString:&(outInfo->passSalt)] &&
    [scanner scanString:@">" intoString:NULL] &&
    [scanner scanLongLong:&(outInfo->challengeAlgorithm)] &&
    [scanner scanString:@":" intoString:NULL] &&
    [scanner scanLongLong:&(outInfo->challengeHardness)] &&
    [scanner scanString:@"<" intoString:NULL] &&
    [scanner scanCharactersFromSet:__base64charset intoString:&(outInfo->challengeSalt)] &&
    [scanner scanString:@">" intoString:NULL] &&
    [scanner isAtEnd] &&
    outInfo->passAlgorithm > 0 && outInfo->passAlgorithm < MSUIntMax &&
    outInfo->passHardness > 0 && outInfo->passHardness < MSUIntMax &&
    outInfo->challengeAlgorithm > 0 && outInfo->challengeAlgorithm < MSUIntMax &&
    outInfo->challengeHardness > 0 && outInfo->challengeHardness < MSUIntMax &&
    MSSecureHashIsValidAlgorithm(outInfo->passAlgorithm) &&
    MSSecureHashIsValidAlgorithm(outInfo->challengeAlgorithm);
}

+ (MSBuffer *)generateRawChallenge
{
    return AUTORELEASE(MSCreateRandomBuffer(8));
}

+ (NSString *)plainChallenge:(MSBuffer *)rawChallenge
{
    return bufferToBase64String(rawChallenge);
}

+ (NSString *)fakeChallengeInfo
{
    return [NSString stringWithFormat:@"%u:%u<%@>%u:%u<%@>",
            [self defaultAlgorithm], [self defaultHardness], [self generateSalt],  // Password info
            [self defaultAlgorithm], [self defaultHardness], [self generateSalt]]; // Challenge info
}

+ (NSString *)challengeResultFor:(NSString *)content withChallengeInfo:(NSString *)challengeInfo
{
    MSSecureHashChallengeInfo i;
    if(parseChallengeInfo(challengeInfo, &i)) {
        NSString *hash1 = _computeHash(content, i.passAlgorithm, i.passHardness, i.passSalt);
        NSString *hash2 = _computeHash(hash1, i.challengeAlgorithm, i.challengeHardness, i.challengeSalt);
        return hash2;
    }
    return nil;
}

- (NSString *)challengeInfo
{
    Class myClass = [self class];
    return [NSString stringWithFormat:@"%u:%u<%@>%u:%u<%@>",
            _algorithm, _hardness, _salt, // Password info
            [myClass defaultAlgorithm], [myClass defaultHardness], [myClass generateSalt]]; // Challenge info
}

- (BOOL)isValidChallengedResult:(NSString *)result withChallengeInfo:(NSString *)challengeInfo
{
    MSSecureHashChallengeInfo i;
    if(parseChallengeInfo(challengeInfo, &i) &&
       (MSUInt)i.passAlgorithm == _algorithm &&
       (MSUInt)i.passHardness == _hardness &&
       [_salt isEqualToString:i.passSalt])
    {
        NSString *expectedResult = _computeHash(_hash, i.challengeAlgorithm, i.challengeHardness, i.challengeSalt);
        return [expectedResult isEqualToString:result];
    }
    return NO;
}

#pragma mark RSA

+ (NSString *)generateSecureKeyRequest
{
    return [NSString stringWithFormat:@"%u:%u<%@>", [self defaultAlgorithm], [self defaultSecureKeyHardness], [self generateSalt]];
}

- (MSCouple *)generateSecuredKeyPair
{
    // Create a new RSA2048 key pair
    // The public key is return in the OpenSSL normal format (-----BEGIN PUBLIC KEY-----)
    // The ciphered private key is returned in secure hash like format algorithm:hardness<salt>ciphertype:privatekey
    MSCouple *pair, *resultPair=nil ;
    NSData *pk, *sk;
    MSCipher *aes ;
    NSAutoreleasePool *pool;
    NSString *skString= nil, *pkString= nil;

    pool = NEW(NSAutoreleasePool);
    NS_DURING
    pair = MSCreateKeyPair(RSA2048) ;
    pk = [pair firstMember] ;
    sk = [pair secondMember] ;
    aes = [MSCipher cipherWithKey:[_hash dataUsingEncoding:NSUTF8StringEncoding] type:AES256CBC] ;
    sk = [aes encryptData:sk] ;
    if(sk) {
        skString = bufferToBase64String([MSBuffer bufferWithData:sk]);
        skString = [NSString stringWithFormat:@"%u:%u<%@>%u:%@", _algorithm, _hardness, _salt, (MSUInt)AES256CBC, skString];
        pkString = [[[NSString alloc] initWithData:pk encoding:NSUTF8StringEncoding] autorelease];
    }
    RELEASE(pair) ;
    NS_HANDLER

    NS_ENDHANDLER

    if(skString && pkString)
        resultPair = [[MSCouple alloc] initWithFirstMember:pkString secondMember:skString];

    DESTROY(pool) ;

    return [resultPair autorelease];
}

@end

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

static BOOL MSSecureHashIsValidAlgorithm(MSUInt algorithm)
{
    return algorithm == 1;
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


@implementation MSSecureHash

+ (MSUInt)defaultAlgorithm { return 1; }
+ (MSUInt)defaultHardness { return 1000; }

+ (NSString *)generateSalt
{
    MSBuffer *salt = MSCreateRandomBuffer(8);
    NSString *saltInHexa = MSBytesToHexaString([salt bytes], [salt length], NO);
    RELEASE(salt);
    return saltInHexa;
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
        _salt = salt;
        _hash = [self _computeHash:content withAlgorithm:algorithm withHardness:hardness];
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
        _salt = salt;
        _hash = hash;
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
    NSCharacterSet *hexSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"];
    
    if([scanner scanLongLong:&algorithm] &&
       [scanner scanString:@":" intoString:NULL] &&
       [scanner scanLongLong:&hardness] &&
       [scanner scanString:@"<" intoString:NULL] &&
       [scanner scanCharactersFromSet:hexSet intoString:&salt] &&
       [scanner scanString:@">" intoString:NULL] &&
       [scanner scanCharactersFromSet:hexSet intoString:&hash] &&
       [scanner isAtEnd] &&
       algorithm > 0 && algorithm < MSUIntMax &&
       hardness > 0 && hardness < MSUIntMax &&
       MSSecureHashIsValidAlgorithm(algorithm) &&
       MSSecureHashIsValid(algorithm, hash))
    {
        _algorithm = algorithm;
        _hardness = hardness;
        _salt = salt;
        _hash = hash;
        return self;
    }
    
    RELEASE(self);
    return nil;
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

- (NSString *)_computeHash:(NSString *)content withAlgorithm:(MSUInt)algorithm withHardness:(MSUInt)hardness
{
    NSString *hash = nil;
    switch (algorithm) {
        case 1:
            hash = [self _computeAlgorithm1Hash:content withHardness:hardness];
            break;
            
        default:
            break;
    }
    return MSSecureHashIsValid(algorithm, hash) ? hash : nil;
}


- (NSString *)_computeAlgorithm1Hash:(NSString *)content withHardness:(MSUInt)hardness
{
    MSDigest *md;
    MSBuffer *step;
    MSUInt i;
    md = [ALLOC(MSDigest) initWithType:MS_SHA512];
    [md updateWithData:[_salt dataUsingEncoding:NSUTF8StringEncoding]];
    [md updateWithData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    step = [md digest];
    for(i = 0; i < hardness; ++i) {
        [md updateWithData:step];
        step = [md digest];
    }
    return MSBytesToHexaString([step bytes], [step length], NO);
}

#pragma mark Challenge

+ (MSBuffer *)generateRawChallenge
{
  return AUTORELEASE(MSCreateRandomBuffer(8));
}

+ (NSString *)plainChallenge:(MSBuffer *)rawChallenge
{
  MSBuffer *b64Challenge= [rawChallenge encodedToBase64];
  return AUTORELEASE(MSCreateASCIIStringWithBytes((void *)[b64Challenge bytes], [b64Challenge length], YES, YES));
}

+ (NSString *)fakeChallengeInfo
{
    return [NSString stringWithFormat:@"%u:%u<%@>%u:%u<%@>%@",
            [self defaultAlgorithm], [self defaultHardness], [self generateSalt], // Password info
            [self defaultAlgorithm], [self defaultHardness], [self generateSalt], // Challenge info
            [self plainChallenge:[self generateRawChallenge]]];
}

- (NSString *)challengeInfo
{
  Class myClass = [self class];
  return [NSString stringWithFormat:@"%u:%u<%@>%u:%u<%@>%@",
          _algorithm, _hardness, _salt, // Password info
          [myClass defaultAlgorithm], [myClass defaultHardness], [myClass generateSalt], // Challenge info
          [myClass plainChallenge:[myClass generateRawChallenge]]];
}

- (BOOL)isValidChallengedResult:(NSString *)result withChallengeInfo:(NSString *)challengeInfo
{
  NSScanner *scanner = [NSScanner scannerWithString:challengeInfo];
  long long passAlgorithm, passHardness, challengeAlgorithm, challengeHardness;
  NSString *passSalt, *challengeSalt, *challenge;
  NSCharacterSet *hexSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"];
  
  if([scanner scanLongLong:&passAlgorithm] &&
     [scanner scanString:@":" intoString:NULL] &&
     [scanner scanLongLong:&passHardness] &&
     [scanner scanString:@"<" intoString:NULL] &&
     [scanner scanCharactersFromSet:hexSet intoString:&passSalt] &&
     [scanner scanString:@">" intoString:NULL] &&
     [scanner scanLongLong:&challengeAlgorithm] &&
     [scanner scanString:@":" intoString:NULL] &&
     [scanner scanLongLong:&challengeHardness] &&
     [scanner scanString:@"<" intoString:NULL] &&
     [scanner scanCharactersFromSet:hexSet intoString:&challengeSalt] &&
     [scanner scanString:@">" intoString:NULL] &&
     [scanner scanCharactersFromSet:hexSet intoString:&challenge] &&
     [scanner isAtEnd] &&
     passAlgorithm > 0 && passAlgorithm < MSUIntMax &&
     passHardness > 0 && passHardness < MSUIntMax &&
     challengeAlgorithm > 0 && challengeAlgorithm < MSUIntMax &&
     challengeHardness > 0 && challengeHardness < MSUIntMax &&
     MSSecureHashIsValidAlgorithm(passAlgorithm) &&
     MSSecureHashIsValidAlgorithm(challengeAlgorithm) &&
     (MSUInt)passAlgorithm == _algorithm &&
     (MSUInt)passHardness == _hardness &&
     [_salt isEqualToString:passSalt] &&
     [challenge length] > 0)
  {
    NSString *expectedResult = [self _computeHash:[challenge stringByAppendingString:_hash]
                                    withAlgorithm:challengeAlgorithm
                                     withHardness:challengeHardness];
    return [expectedResult isEqualToString:result];
  }
  return NO;
}
@end

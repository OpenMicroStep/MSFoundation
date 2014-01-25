/*
 
 MSCoderAdditions.h
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
  
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

#if defined(WO451)
#define MUST_DEFINE_KEY_CODING
#define MUST_ENCODE_INTEGERS
#elif defined(MAC_OS_X_VERSION_MAX_ALLOWED)
#if MAC_OS_X_VERSION_10_2 > MAC_OS_X_VERSION_MAX_ALLOWED
#define MUST_DEFINE_KEY_CODING
#endif
#if MAC_OS_X_VERSION_10_5 > MAC_OS_X_VERSION_MAX_ALLOWED
#define MUST_ENCODE_INTEGERS
#endif
#endif

@interface NSCoder (MSObjectAdditions)

- (void)encodeCArray:(CArray *)objects forKey:(NSString *)key;
- (NSUInteger)decodeInCArray:(CArray *)objects retainObjects:(BOOL)flag forKey:(NSString *)key;

- (void)encodeUnsignedInteger:(NSUInteger)intv forKey:(NSString *)key;
- (NSUInteger)decodeUnsignedIntegerForKey:(NSString *)key;

#ifdef MUST_DEFINE_KEY_CODING
/*
 in old OpenStep implementations (WO451 and old MacOSX versions),
 allowsKeyedCoding method from NSCoder allways returns NO.
 
 That means that all keyed encoding methods do nothing and
 all keyed decoding methods returns nil, null or a 0 number.
 
 So, subclassers MUST overwrite all these methods.
 
 */
- (BOOL)allowsKeyedCoding; 
- (void)encodeObject:(id)objv forKey:(NSString *)key;
- (void)encodeConditionalObject:(id)objv forKey:(NSString *)key;
- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key;
- (void)encodeInt:(int)intv forKey:(NSString *)key;
- (void)encodeInt32:(MSInt)intv forKey:(NSString *)key;
- (void)encodeInt64:(MSLong)intv forKey:(NSString *)key;
- (void)encodeFloat:(float)realv forKey:(NSString *)key;
- (void)encodeDouble:(double)realv forKey:(NSString *)key;
- (void)encodeBytes:(const MSByte *)bytesp length:(NSUInteger)lenv forKey:(NSString *)key;

- (BOOL)containsValueForKey:(NSString *)key;
- (id)decodeObjectForKey:(NSString *)key;
- (BOOL)decodeBoolForKey:(NSString *)key;
- (int)decodeIntForKey:(NSString *)key;
- (MSInt)decodeInt32ForKey:(NSString *)key;
- (MSLong)decodeInt64ForKey:(NSString *)key;
- (float)decodeFloatForKey:(NSString *)key;
- (double)decodeDoubleForKey:(NSString *)key;
- (const MSByte *)decodeBytesForKey:(NSString *)key returnedLength:(NSUInteger *)lengthp;   // returned bytes immutable!
#endif
#ifdef MUST_ENCODE_INTEGERS
- (void)encodeInteger:(NSInteger)intv forKey:(NSString *)key;
- (NSInteger)decodeIntegerForKey:(NSString *)key;
#endif
@end

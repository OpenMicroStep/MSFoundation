/*
 
 MSCoderAdditions.m
 
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
 
 */

#import "MSFoundation_Private.h"

@implementation NSCoder (MSObjectAdditions)

// ========== Microstep extensions start ==========
- (void)encodeCArray:(CArray *)objects forKey:(NSString *)key
{
  key= nil; // Unused parameter
  if (objects) {
    NSArray *array = [ALLOC(NSArray) initWithObjects:objects->pointers count:objects->count];
    [self encodeObject:array forKey:@"ms-array"];
    RELEASE(array);
  }
}

- (NSUInteger)decodeInCArray:(CArray *)objects retainObjects:(BOOL)flag forKey:(NSString *)key
{
  NSArray *array = [self decodeObjectForKey:@"ms-array"];
  if (array && objects) {
    NSUInteger i, count = [array count];
    for (i = 0; i < count; i++) {
      CArrayAddObject(objects, [array objectAtIndex:i]);
    }
    return count;
  }
  return 0;
  flag= NO; // Unused parameter
  key= nil; // Unused parameter
}


- (void)encodeUnsignedInteger:(NSUInteger)intv forKey:(NSString *)key
{
  NSInteger c = *((NSInteger *)(&intv));
  [self encodeInteger:c forKey:key];
}

- (NSUInteger)decodeUnsignedIntegerForKey:(NSString *)key
{
  NSInteger intv = [self decodeIntegerForKey:key];
  NSUInteger c = *((NSUInteger *)(&intv));
  return c;
}

// ========== Microstep extensions end ==========

#ifdef MUST_DEFINE_KEY_CODING
- (BOOL)allowsKeyedCoding { return NO; }

- (void)encodeObject:(id)objv forKey:(NSString *)key {}
- (void)encodeConditionalObject:(id)objv forKey:(NSString *)key {}
- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key {}
- (void)encodeInt:(int)intv forKey:(NSString *)key {}
- (void)encodeInt32:(MSInt)intv forKey:(NSString *)key {}
- (void)encodeInt64:(MSLong)intv forKey:(NSString *)key {}
- (void)encodeFloat:(float)realv forKey:(NSString *)key {}
- (void)encodeDouble:(double)realv forKey:(NSString *)key {}
- (void)encodeBytes:(const MSByte *)bytesp length:(NSUInteger)lenv forKey:(NSString *)key {}

- (BOOL)containsValueForKey:(NSString *)key { return NO; }
- (id)decodeObjectForKey:(NSString *)key { return nil; }
- (BOOL)decodeBoolForKey:(NSString *)key { return NO; }
- (int)decodeIntForKey:(NSString *)key { return 0; }
- (MSInt)decodeInt32ForKey:(NSString *)key { return 0; }
- (MSLong)decodeInt64ForKey:(NSString *)key { return 0; }
- (float)decodeFloatForKey:(NSString *)key { return 0.0; }
- (double)decodeDoubleForKey:(NSString *)key { return 0.0; }
- (const MSByte *)decodeBytesForKey:(NSString *)key returnedLength:(NSUInteger *)lengthp
{ if (lengthp) *lengthp = 0; return (const MSByte *)NULL; }
#endif

#ifdef MUST_ENCODE_INTEGERS
- (void)encodeInteger:(NSInteger)intv forKey:(NSString *)key {}
- (NSInteger)decodeIntegerForKey:(NSString *)key { return (NSInteger)0; }
#endif
@end

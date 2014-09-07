/* MSDecimal.h
 
 This header file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
Herve Malaingre : herve@malaingre.com
Eric Baradat :  k18rt@free.fr

 
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

// convienient predefined constants

#define MSD_Zero          ((MSDecimal*)MM_Zero)
#define MSD_One           ((MSDecimal*)MM_One)
#define MSD_Two           ((MSDecimal*)MM_Two)
#define MSD_Three         ((MSDecimal*)MM_Three)
#define MSD_Four          ((MSDecimal*)MM_Four)
#define MSD_Five          ((MSDecimal*)MM_Five)
#define MSD_Ten           ((MSDecimal*)MM_Ten)

#define MSD_PI            ((MSDecimal*)MM_PI)
#define MSD_HALF_PI       ((MSDecimal*)MM_HALF_PI)
#define MSD_2_PI          ((MSDecimal*)MM_2_PI)
#define MSD_E             ((MSDecimal*)MM_E)

#define MSD_LOG_E_BASE_10 ((MSDecimal*)MM_LOG_E_BASE_10)
#define MSD_LOG_10_BASE_E ((MSDecimal*)MM_LOG_10_BASE_E)
#define MSD_LOG_2_BASE_E  ((MSDecimal*)MM_LOG_2_BASE_E)
#define MSD_LOG_3_BASE_E  ((MSDecimal*)MM_LOG_3_BASE_E)

// TODO: if super class is NSNumber, we need to implement all the ..Value
// methods and indeed decimalValue. Revoir aussi isEqualToDecimal

@interface MSDecimal : NSObject // Not an NSNumber
{
@private
  unsigned char *_data;
  long _id;
  int  _malloclength;
  int  _datalength;
  int  _exponent;
  int  _sign;
}

// decimalWith[UTF8]String returns nil if no decimal found.
+ (id)decimalWithUTF8String:(const char*)s;
+ (id)decimalWithString:(NSString*)s;

+ (id)decimalWithDouble:(double)d;
+ (id)decimalWithLong:(MSLong)l;
+ (id)decimalWithULong:(MSULong)u;
+ (id)decimalWithMantissa:(MSULong)m exponent:(MSInt)e sign:(int)sign;
  // sign: +1 | -1

// initWith[UTF8]String returns nil if no decimal found.
- (id)initWithUTF8String:(const char*)d;
- (id)initWithString:(NSString*)d;

- (id)initWithDouble:(double)d;
- (id)initWithLong:(MSLong)l;
- (id)initWithULong:(MSULong)u;
- (id)initWithMantissa:(MSULong)m exponent:(MSInt)e sign:(int)sign;

- (BOOL)isEqualToDecimal:(MSDecimal*)o;

- (MSChar)    charValue;
- (MSByte)    byteValue;
- (MSShort)   shortValue;
- (MSUShort)  unsignedShortValue;
- (MSInt)     intValue;
- (MSUInt)    unsignedIntValue;
- (MSLong)    longValue;
- (MSULong)   unsignedLongValue;
- (NSInteger) integerValue;
- (NSUInteger)unsignedIntegerValue;

- (MSDecimal*)floorDecimal;
- (MSDecimal*)ceilDecimal;

- (MSDecimal*)decimalByAdding:(MSDecimal*)d;
- (MSDecimal*)decimalBySubtracting:(MSDecimal*)d;
- (MSDecimal*)decimalByMultiplyingBy:(MSDecimal*)d;
- (MSDecimal*)decimalByDividingBy:(MSDecimal*)d decimalPlaces:(int)decimalPlaces;

@end

@interface NSObject (MSDecimal)
- (MSDecimal*)toDecimal; // returns nil
@end

@interface NSNumber (MSDecimal)
- (MSDecimal*)toDecimal;
@end

@interface NSString (MSDecimal)
- (MSDecimal*)toDecimal;
@end

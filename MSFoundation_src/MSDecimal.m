/* MSDecimal.m
 
 This implementation file is is a part of the MicroStep Framework.
 
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
 
 */

#import "MSFoundation_Private.h"

#define MS_DECIMAL_LAST_VERSION 301

@implementation MSDecimal
+ (void)load{ MSFinishLoadingAddClass(self); }
+ (void)finishLoading{ [MSDecimal setVersion:MS_DECIMAL_LAST_VERSION]; }

#pragma mark Initialisation

+ (id)allocWithZone:(NSZone*)zone {return MSAllocateObject(self, 0, zone);}
+ (id)alloc                       {return MSAllocateObject(self, 0, NULL);}
+ (id)new                         {return MSAllocateObject(self, 0, NULL);}

+ (id)decimalWithUTF8String:(const char*)x
{
  return AUTORELEASE((id)CCreateDecimalWithUTF8String(x));
}
+ (id)decimalWithString:(NSString*)x
{
  return AUTORELEASE((id)CCreateDecimalWithSES(SESFromString(x),NO,NULL,NULL));
}
+ (id)decimalWithDouble:(double)x
{
  return AUTORELEASE((id)CCreateDecimalWithDouble(x));
}
+ (id)decimalWithLongLong:(MSLong)x
{
  return AUTORELEASE((id)CCreateDecimalWithLongLong(x));
}
+ (id)decimalWithULongLong:(MSULong)x
{
  return AUTORELEASE((id)CCreateDecimalWithULongLong(x));
}
+ (id)decimalWithMantissa:(MSULong)m exponent:(MSInt)e sign:(int)sign
{
  MSDecimal *x= (id)CCreateDecimalWithMantissaExponentSign(m,e,sign);
  return AUTORELEASE(x);
}
- (id)initWithUTF8String:(const char*)x
{
  RELEASE(self);
  return (id)CCreateDecimalWithUTF8String(x);
}
- (id)initWithString:(NSString*)x
{
  RELEASE(self);
  return (id)CCreateDecimalWithSES(SESFromString(x),NO,NULL,NULL);
}
- (id)initWithDouble:(double)x
{
  self= (id)m_apm_init((CDecimal*)self);
  m_apm_set_double((CDecimal*)self, x);
  return self;
}
- (id)initWithLongLong:(MSLong)x
{
  self= (id)m_apm_init((CDecimal*)self);
  m_apm_set_long((CDecimal*)self, x);
  return self;
}
- (id)initWithULongLong:(MSULong)x
{
  self= (id)m_apm_init((CDecimal*)self);
  m_apm_set_ulong((CDecimal*)self, x);
  return self;
}
- (id)initWithMantissa:(MSULong)m exponent:(MSInt)e sign:(int)sign
{
  self= (id)m_apm_init((CDecimal*)self);
  m_apm_set_mantissa_exponent_sign((CDecimal*)self, m, e, sign);
  return self;
}

- (void)dealloc { CDecimalFreeInside(self); [super dealloc]; }

#pragma mark Copying

- (id)copyWithZone:(NSZone*)zone
{
  return !zone || zone == [self zone] ? RETAIN(self) : CDecimalCopy(self);
}

#pragma mark Standard methods

- (BOOL)isEqual:(id)o
{
  if (o == self) return YES;
  return [o isKindOfClass:[MSDecimal class]] ?
      CDecimalEquals((CDecimal*)self, (CDecimal*)o):
      NO;
}

- (BOOL)isEqualToDecimal:(MSDecimal*)o
{
  return CDecimalEquals((CDecimal*)self, (CDecimal*)o);
}

- (MSChar)    charValue             {return CDecimalCharValue    ((CDecimal*)self);}
- (MSByte)    byteValue             {return CDecimalByteValue    ((CDecimal*)self);}
- (MSShort)   shortValue            {return CDecimalShortValue   ((CDecimal*)self);}
- (MSUShort)  unsignedShortValue    {return CDecimalUShortValue  ((CDecimal*)self);}
- (MSInt)     intValue              {return CDecimalIntValue     ((CDecimal*)self);}
- (MSUInt)    unsignedIntValue      {return CDecimalUIntValue    ((CDecimal*)self);}
- (MSLong)    longLongValue         {return CDecimalLongValue    ((CDecimal*)self);}
- (MSULong)   unsignedLongLongValue {return CDecimalULongValue   ((CDecimal*)self);}
- (NSInteger) integerValue          {return CDecimalIntegerValue ((CDecimal*)self);}
- (NSUInteger)unsignedIntegerValue  {return CDecimalUIntegerValue((CDecimal*)self);}

- (NSString*)description   {return [(id)CCreateDecimalDescription((CDecimal*)self) autorelease];}
- (NSString*)toString      {return [self description];}
- (NSString*)displayString {return [self description];}


#pragma mark Obtaining other decimals

- (MSDecimal*)floorDecimal
{
  return AUTORELEASE((id)CCreateDecimalFloor((CDecimal*)self));
}
- (MSDecimal*)ceilDecimal
{
  return AUTORELEASE((id)CCreateDecimalCeil((CDecimal*)self));
}

- (MSDecimal*)decimalByAdding:(MSDecimal*)d
{
  return AUTORELEASE((id)CCreateDecimalAdd((CDecimal*)self, (CDecimal*)d));
}
- (MSDecimal*)decimalBySubtracting:(MSDecimal*)d
{
  return AUTORELEASE((id)CCreateDecimalSubtract((CDecimal*)self, (CDecimal*)d));
}
- (MSDecimal*)decimalByMultiplyingBy:(MSDecimal*)d
{
  return AUTORELEASE((id)CCreateDecimalMultiply((CDecimal*)self, (CDecimal*)d));
}
- (MSDecimal*)decimalByDividingBy:(MSDecimal*)d decimalPlaces:(int)decimalPlaces
{
  return AUTORELEASE((id)CCreateDecimalDivide((CDecimal*)self, (CDecimal*)d, decimalPlaces));
}

#pragma mark NSCoding // TODO:

- (id)initWithCoder:(NSCoder *)aCoder
{
  self= (id)m_apm_init((CDecimal*)self);
  if ([aCoder allowsKeyedCoding]) {
    // Do something
    }
  else {
    // Do something else
    }
  return self;
}

- (id)replacementObjectForPortCoder:(NSPortCoder *)encoder
{
  if ([encoder isBycopy]) return self;
  return [super replacementObjectForPortCoder:encoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  if ([aCoder allowsKeyedCoding]) {
    // Do something
    }
  else {
    // Do something else
    }
}

@end

@implementation NSObject (MSDecimal)
- (MSDecimal*)toDecimal
{
  return nil;
}
@end

@implementation NSNumber (MSDecimal)
- (MSDecimal*)toDecimal
{
  const char *c= [self objCType];
  return strcmp(@encode(float  ),c)==0 ||
         strcmp(@encode(double ),c)==0 ? [MSDecimal decimalWithDouble:[self doubleValue]] :
         strcmp(@encode(MSULong),c)==0 ? [MSDecimal decimalWithULongLong: [self unsignedLongLongValue]] :
                                         [MSDecimal decimalWithLongLong:  [self longLongValue]];
}
@end

@implementation NSString (MSDecimal)
- (MSDecimal*)toDecimal
{
  return [MSDecimal decimalWithString:self];
}
@end

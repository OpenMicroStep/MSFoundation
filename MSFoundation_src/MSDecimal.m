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

#import "MSFoundationPrivate_.h"

#define MS_DECIMAL_LAST_VERSION 301

static Class __MSDecimalClass= Nil;

@implementation MSDecimal

+ (void)load { if (!__MSDecimalClass) __MSDecimalClass= [self class]; }

+ (void)initialize
{
  if ([self class] == [MSDecimal class]) {
    [MSDecimal setVersion:MS_DECIMAL_LAST_VERSION];}
}

#pragma mark Initialisation

+ (id)allocWithZone:(NSZone*)zone {return MSAllocateObject(self, 0, zone);}
+ (id)alloc                       {return MSAllocateObject(self, 0, NULL);}
+ (id)new                         {return MSAllocateObject(self, 0, NULL);}

+ (id)decimalFromUTF8String:(char*)d
{
  return DECIMALU(d);
}
+ (id)decimalFromString:(NSString*)d
{
  return DECIMALS(d);
}
+ (id)decimalFromDouble:(double)d
{
  return DECIMALD(d);
}
+ (id)decimalFromLong:(long)d
{
  return DECIMALL(d);
}
+ (id)decimalFromMantissa:(unsigned long long)m exponent:(int)e sign:(int)sign
{
  MSDecimal *x= (id)CCreateDecimalFromMantissaExponentSign(m,e,sign);
  return AUTORELEASE(x);
}

- (id)initFromUTF8String:(char*)d
{
  self= (id)m_apm_init((CDecimal*)self);
  m_apm_set_string((CDecimal*)self, d);
  return self;
}
- (id)initFromString:(NSString*)d
{
  self= (id)m_apm_init((CDecimal*)self);
  m_apm_set_string((CDecimal*)self, [d UTF8String]);
  return self;
}
- (id)initFromDouble:(double)d
{
  self= (id)m_apm_init((CDecimal*)self);
  m_apm_set_double((CDecimal*)self, d);
  return self;
}
- (id)initFromLong:(long)d
{
  self= (id)m_apm_init((CDecimal*)self);
  m_apm_set_long((CDecimal*)self, d);
  return self;
}
- (id)initFromMantissa:(unsigned long long)m exponent:(int)e sign:(int)sign
{
  self= (id)m_apm_init((CDecimal*)self);
  set_mantissa_exponent_sign((CDecimal*)self, m, e, sign);
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

// TODO: Voir avec MSString
- (NSString *)toString
{
  return [NSString string];
}

- (NSString *)description { return [self toString]; }
- (NSString *)displayString
{
  return nil;
}

#pragma mark Obtaining other decimals

- (MSDecimal*)floorDecimal
{
  return AUTORELEASE((id)CDecimalFloor((CDecimal*)self));
}
- (MSDecimal*)ceilDecimal
{
  return AUTORELEASE((id)CDecimalCeil((CDecimal*)self));
}

- (MSDecimal*)decimalByAdding:(MSDecimal*)d
{
  return AUTORELEASE((id)CDecimalAdd((CDecimal*)self, (CDecimal*)d));
}
- (MSDecimal*)decimalBySubtracting:(MSDecimal*)d
{
  return AUTORELEASE((id)CDecimalSubtract((CDecimal*)self, (CDecimal*)d));
}
- (MSDecimal*)decimalByMultiplyingBy:(MSDecimal*)d
{
  return AUTORELEASE((id)CDecimalMultiply((CDecimal*)self, (CDecimal*)d));
}
- (MSDecimal*)decimalByDividingBy:(MSDecimal*)d decimalPlaces:(int)decimalPlaces
{
  return AUTORELEASE((id)CDecimalDivide((CDecimal*)self, (CDecimal*)d, decimalPlaces));
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

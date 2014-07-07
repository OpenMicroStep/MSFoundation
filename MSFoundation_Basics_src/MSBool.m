/*
 
 MSBool.m
 
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

#define MS_BOOL_LAST_VERSION		999

MSBool *MSTrue = nil ;
MSBool *MSFalse = nil ;

@interface _MSFalseBool : MSBool
@end

@interface _MSTrueBool : MSBool
@end

@implementation MSBool

+ (void)initialize
{ if ([self class] == [MSBool class]) { [MSBool setVersion:MS_BOOL_LAST_VERSION] ; } }

+ (id)trueNumber { return MSTrue ; }
+ (id)falseNumber { return MSFalse ; }
+ (NSNumber *)numberWithBool:(BOOL)value { return (value ? MSTrue : MSFalse) ; }
+ (id)allocWithZone:(NSZone *)zone { return MSFalse ; zone= nil; }
+ (id)alloc { return MSFalse ; }
+ (id)new { return MSFalse ; }
- (id)retain { return self ; }
- (oneway void)release {}
- (id)autorelease { return self ; }
- (const char *)objCType { return "C" ; }
- (id)init { return self ; }
- (void)_internalRelease { [ super release] ; }
- (void)dealloc {if (0) [super dealloc];} // No warning

- (id)copyWithZone:(NSZone *)zone { return self ; zone= nil; }
- (id)copy{ return self ; }

- (void)encodeWithCoder:(NSCoder *)aCoder { return ; aCoder= nil; }
- (id)initWithCoder:(NSCoder *)aDecoder{ return self ; aDecoder= nil; }

- (Class)classForAchiver { return [self class] ; }
- (Class)classForCoder { return [self class] ; }
- (Class)classForPortCoder { return [self class] ; }

- (id)replacementObjectForPortCoder:(NSPortCoder *)encoder { return self ; encoder= nil; }
@end

@implementation _MSFalseBool 
+ (void)load { if (!MSFalse) MSFalse = (MSBool *)MSCreateObject(self) ; }
- (void)getValue:(void *)value
{
	if (value) *((unsigned char *)value) = '\0' ;
}
- (char)charValue { return 0 ; }
- (unsigned char)unsignedCharValue { return 0 ; }
- (short)shortValue { return 0 ; }
- (unsigned short)unsignedShortValue { return 0 ; }
- (int)intValue { return 0 ; }
- (unsigned int)unsignedIntValue { return 0 ; }
- (long)longValue { return 0 ; }
- (unsigned long)unsignedLongValue { return 0 ; }
- (long long)longLongValue { return 0 ; }
- (unsigned long long)unsignedLongLongValue { return 0 ; }
- (NSInteger)integerValue { return 0 ; }
- (NSUInteger)unsignedIntegerValue { return 0; }
- (float)floatValue { return 0 ; }
- (double)doubleValue { return 0 ; }
- (BOOL)boolValue { return NO ; }
- (NSString *)stringValue { return @"NO" ; }
- (BOOL)isTrue { return NO ; }
- (BOOL)isEqualToNumber:(NSNumber *)number { return number && (number == self || ![number isTrue]) ? YES : NO ; }
- (BOOL)isEqualToValue:(NSValue *)value { return value && (value == self || ![value isTrue]) ? YES : NO ; }
- (NSString *)description { return @"NO" ; }
- (NSString *)toString { return @"NO" ; }
- (NSString *)listItemString { return @"NO" ; }
- (NSString *)descriptionWithLocale:(NSDictionary *)locale { return @"NO" ; locale= nil; }
- (NSString *)descriptionWithLocale:(NSDictionary *)d indent:(unsigned)l { return @"NO" ; d= nil; l= 0; }
- (NSString *)htmlRepresentation { return @"false" ; }
- (NSString *)jsonRepresentation { return @"false" ; }
- (NSString *)displayString { return @"false" ; }
- (NSComparisonResult)compare:(NSNumber *)otherNumber
{
	int other = [otherNumber intValue] ;
	if (other < 0) return NSOrderedDescending ;
	return other > 0 ? NSOrderedAscending : NSOrderedSame ;
}
/*
- (void)encodeWithJSONEncoder:(MSJSONEncoder *)encoder withReference:(unsigned)reference { [encoder encodeString:@"false"] ; }
*/
@end

@implementation _MSTrueBool 
+ (void)load { if (!MSTrue) MSTrue = (MSBool *)MSCreateObject(self) ; }
- (void)getValue:(void *)value { if (value) *((unsigned char *)value) = '\001' ; }
+ (id)allocWithZone:(NSZone *)zone { return (id)MSTrue ; zone= nil; }
+ (id)alloc { return (id)MSTrue ; }
+ (id)new { return (id)MSTrue ; }
- (char)charValue { return 1 ; }
- (unsigned char)unsignedCharValue { return 1 ; }
- (short)shortValue { return 1 ; }
- (unsigned short)unsignedShortValue { return 1 ; }
- (int)intValue { return 1 ; }
- (unsigned int)unsignedIntValue { return 1 ; }
- (long)longValue { return 1 ; }
- (unsigned long)unsignedLongValue { return 1 ; }
- (long long)longLongValue { return 1 ; }
- (unsigned long long)unsignedLongLongValue { return 1 ; }
- (NSInteger)integerValue { return 1 ; }
- (NSUInteger)unsignedIntegerValue { return 1; }
- (float)floatValue { return 1 ; }
- (double)doubleValue { return 1 ; }
- (BOOL)boolValue { return YES ; }
- (NSString *)stringValue { return @"YES" ; }
- (NSString *)toString { return @"YES" ; }
- (NSString *)listItemString { return @"YES" ; }
- (BOOL)isTrue { return YES ; }
- (BOOL)isEqualToNumber:(NSNumber *)number { return number && (number == self || [number isTrue]) ? YES : NO ; }
- (BOOL)isEqualToValue:(NSValue *)value { return value && (value == self || [value isTrue]) ? YES : NO ; }
- (NSString *)description { return @"YES" ; }
- (NSString *)descriptionWithLocale:(NSDictionary *)locale { return @"YES" ; locale= nil; }
- (NSString *)descriptionWithLocale:(NSDictionary *)d indent:(unsigned)l { return @"YES" ; d= nil; l= 0; }
- (NSString *)htmlRepresentation { return @"true" ; }
- (NSString *)jsonRepresentation { return @"true" ; }
- (NSString *)displayString { return @"true" ; }
- (NSComparisonResult)compare:(NSNumber *)otherNumber
{
	int other = [otherNumber intValue] ;
	if (other < 1) return NSOrderedDescending ;
	return other > 1 ? NSOrderedAscending : NSOrderedSame ;
}
/*
- (void)encodeWithJSONEncoder:(MSJSONEncoder *)encoder withReference:(unsigned)reference { [encoder encodeString:@"true"] ; }
*/
@end

/*   MSString.m
 
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

@implementation NSString (MSAddendum)
- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)allowLossyConversion
{
  MSBuffer *buf= nil;
  if (allowLossyConversion || [self canBeConvertedToEncoding:encoding]) {
    NSData *data= [self dataUsingEncoding:encoding allowLossyConversion:YES];
    buf= [MSBuffer bufferWithBytes:[data bytes] length:[data length]];}
  return (const char *)[buf cString];
}
@end

@implementation MSString
#pragma mark alloc / init

+ (id)allocWithZone:(NSZone*)zone {return MSAllocateObject(self, 0, zone);}
+ (id)alloc                       {return MSAllocateObject(self, 0, NULL);}
+ (id)new                         {return MSAllocateObject(self, 0, NULL);}
+ (id)string         {return AUTORELEASE(MSAllocateObject(self, 0, NULL));}
- (id)init
  {
  return self;
  }
- (id)initWithFormat:(NSString *)fmt locale:(id)locale arguments:(va_list)args
  {
  RELEASE(self);
  return (MSString*)[[NSString alloc] initWithFormat:fmt locale:locale arguments:args];
  }
- (void)dealloc
  {
  CStringFreeInside(self);
  [super dealloc];
  }

#pragma mark Primitives

- (NSUInteger)length
{
  return _length;
}
- (unichar)characterAtIndex:(NSUInteger)index
//The index value must not lie outside the bounds of the receiver.
{
  return _buf[index];
}
- (void)getCharacters:(unichar*)buffer range:(NSRange)rg
{
  NSUInteger i,n; unichar *p;
  p= _buf+rg.location;
  for (n= rg.length, i=0; i<n; i++) {*buffer++= *p++;}
}

#pragma mark Global methods

- (NSUInteger)hash:(unsigned)depth {return CStringHash(self, depth);}

- (id)copyWithZone:(NSZone*)z // La copie n'est pas mutable TODO: à revoir ?
  {
  CString *s= (CString*)MSAllocateObject([MSString class], 0, z);
  CStringAppendString(s, (const CString*)self);
  return (id)s;
  }
- (id)mutableCopyWithZone:(NSZone*)z
  {
  CString *s= (CString*)MSAllocateObject([MSMutableString class], 0, z);
  CStringAppendString(s, (const CString*)self);
  return (id)s;
  }
/*
- (BOOL)isEqualToString:(NSString*)s
  {
  if (s == (id)self) return YES;
  if (!s) return NO;
  if ([s _isMS]) return CStringEquals((CString*)self,(CString*)s);
  return [super isEqualToString:s];
  }
*/
- (BOOL)isEqual:(id)object
  {
  if (object == (id)self) return YES;
  if (!object) return NO;
  if ([object isKindOfClass:[MSString class]]) {
    return CStringEquals((CString*)self, (CString*)object);}
  else if ([object isKindOfClass:[NSString class]]) { // TODO: a revoir. Quid dans l'autre sens ?
    BOOL eq; NSUInteger i,n= [object length]; unichar b[n?n:1];
    [object getCharacters:b range:NSMakeRange(0, n)];
    for (eq= YES, i= 0; eq && i<n; i++) eq= (_buf[i]==b[i]);
//NSLog(@"MSString isEqual %@ %@= %@ %@\n",self,(eq?@"=":@"!"),[object class],object);
    return eq;}
  return NO;
  }

#pragma mark description

- (NSString*)description
{
  return self;
}

@end

@implementation MSMutableString

+ (id)stringWithCapacity:(NSUInteger)capacity
  {
  id d= MSAllocateObject(self, 0, NULL);
  CStringGrow((CString*)d, capacity);
  return AUTORELEASE(d);
  }

- (id)initWithCapacity:(NSUInteger)capacity
  {
  CStringGrow((CString*)self, capacity);
  return self;
  }

@end

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
#import "MSStringBooleanAdditions_Private.i"

BOOL MSStringIsTrue(NSString *s)
{ 
	SES ses = SESFromString(s) ;
	if (SESOK(ses)) {
		return _MSStringIsTrue(ses, CUnicharIsSpace, NULL) ;
	}
	return NO ;
}
BOOL MSEqualStrings(NSString *s1, NSString *s2)
{
  if (s1 != s2) {
    if (s1 && s2) {
      SES ses1= [s1 stringEnumeratorStructure] ;
      SES ses2= [s2 stringEnumeratorStructure] ;
      NSUInteger len1= ses1.length ;
      // TODO: a revoir, les length n'ont pas à être égales mais simplement à la
      // fin i==iend et j==jend
      if (len1 == ses2.length) {
        NSUInteger i,iend,j,jend ;
        i= SESStart(ses1); iend= SESEnd(ses1);
        j= SESStart(ses2); jend= SESEnd(ses2);
        while (i < iend && j < jend)
          if (SESIndexN(ses1, &i) != SESIndexN(ses2, &j)) return NO ;
        return YES ;}}
    return NO ;}
  return YES ;
}
BOOL MSInsensitiveEqualStrings(NSString *s1, NSString *s2)
{
  if (s1 != s2) {
    if (s1 && s2) {
      SES ses1 = [s1 stringEnumeratorStructure];
      SES ses2 = [s2 stringEnumeratorStructure];
      NSUInteger len1 = ses1.length ;
      if (len1 == ses2.length) {
        NSUInteger i,iend,j,jend ;
        i= SESStart(ses1); iend= SESEnd(ses1);
        j= SESStart(ses2); jend= SESEnd(ses2);
        while (i < iend && j < jend)
          if (!CUnicharInsensitiveEquals(SESIndexN(ses1,&i),SESIndexN(ses2,&j)))
            return NO ;
        return YES ;}}
    return NO ;}
  return YES ;
}

@implementation NSString (MSAddendum)
static inline NSString *_createStringWithContentsOfUTF8File(NSString *file)
{
	NSMutableData *data = [ALLOC(NSMutableData) initWithContentsOfFile:file] ;
	NSUInteger len = [data length] ;
	MSByte *bytes = (MSByte *)[data bytes] ;
	MSString *ret = nil ;
	
	if (len >= 3 && bytes[0] == 0xef && bytes[1] == 0xbb && bytes[2] == 0xbf) {
		len -= 3 ;
		bytes += 3 ;
	}
	if (len) {
		
		ret = (MSString*)CCreateString(len) ;
		if (!CStringAppendSupposedEncodingBytes((CString *)ret, bytes, len, NSUTF8StringEncoding, NULL)) {
			DESTROY(ret) ;
		}
	}
	
	RELEASE(data) ;
	
	return ret ;
}
+ (NSString *)stringWithContentsOfUTF8File:(NSString *)file { return AUTORELEASE(_createStringWithContentsOfUTF8File(file)) ; }

- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)allowLossyConversion
{
  MSBuffer *buf= nil;
  if (allowLossyConversion || [self canBeConvertedToEncoding:encoding]) {
    NSData *data= [self dataUsingEncoding:encoding allowLossyConversion:YES];
    buf= [MSBuffer bufferWithBytes:[data bytes] length:[data length]];}
  return (const char *)[buf cString];
}
static unichar _slowChai(const void *self, NSUInteger *pos)
{
  return [(NSString*)self characterAtIndex:(*pos)++];
}
- (SES)stringEnumeratorStructure
{
  return MSMakeSES((const void*)self, _slowChai, 0,[self length], 0);
}

- (NSMutableString *)replaceOccurrencesOfString:(NSString *)tag withString:(NSString *)replace
{
    NSArray *subStrings = [self componentsSeparatedByString:tag] ;
    return [[[subStrings componentsJoinedByString:replace] mutableCopy] autorelease] ;
}

NSRange MSStringFind(NSString *source, NSString *searched)
{
	NSRange ret = {NSNotFound,0} ;
	if (source && searched) {
		SES ses = SESFromString(source) ;
		if (SESOK(ses)) {
			ses = SESFind(ses, SESFromString(searched)) ;
			if (SESOK(ses)) { ret = (NSRange){ses.start, ses.length} ; }
		}
	}
	return ret ;
}

- (NSString *)mid:(NSUInteger)position
{
	NSUInteger selfLen = (NSUInteger)[self length] ;
	if (position < selfLen) {
		return [self substringWithRange: NSMakeRange(position, selfLen - position)] ;		
	}
	return @"" ;
}
- (NSString *)mid:(NSUInteger)position :(NSUInteger)length
{
	if (length) {
		NSUInteger selfLen = (NSUInteger)[self length] ;
		if (position < selfLen) {
			return [self substringWithRange: NSMakeRange(position , (length == NSUIntegerMax || position+length > selfLen ? selfLen - position : length))] ;
		}
	}
	return @"" ;
}

- (NSString *)left:(NSUInteger)length
{
	if (length) {
		NSUInteger selfLen = [self length] ;
		if (length > selfLen) length = selfLen ;
		if (length) return [self substringWithRange: NSMakeRange(0 , length)] ;
	}
	return @"" ;
}

- (NSString *)substringBeforeString:(NSString *)string
{
    NSUInteger p = MSStringFind(self, string).location ;
    return (p == NSNotFound ? (id)nil : (id)[self left:p]) ; 
}
- (NSString *)substringAfterString:(NSString *)string
{
    NSRange r = MSStringFind(self, string) ;
    return (r.location == NSNotFound ? (id)nil : [self mid: r.location+r.length]) ;
}

static inline NSString *_MSTrimAt(NSString *source, NSUInteger position, NSUInteger length, CUnicharChecker matchingChar)
{
	if (source && matchingChar) {
		if (length) {
			SES ses = SESFromString(source) ;
			if (SESOK(ses) && position < ses.length) {
				ses.start = position ;
				if (length == NSUIntegerMax || position + length > ses.length) ses.length -= position ;
				else ses.length = length ;
				ses = SESExtractPart(ses, matchingChar) ;
				if (SESOK(ses)) { return [source substringWithRange:NSMakeRange(ses.start, ses.length)] ; }
			}
		}
		return @"" ;
	}
	return nil ;
}
NSString *MSTrimAt(NSString *self, NSUInteger position, NSUInteger length, CUnicharChecker checker)
{
  return _MSTrimAt(self, position, length, (checker ? (CUnicharChecker)checker : CUnicharIsSolid)) ;
}

- (NSString *)trim { return _MSTrimAt(self,0, NSUIntegerMax, (CUnicharChecker)CUnicharIsSolid) ; }

- (BOOL)containsString:(NSString *)anotherString
{
    if (anotherString) {
        if ([anotherString length]) {
            NSRange r = [self rangeOfString:anotherString] ;
            return r.location == NSNotFound ? NO : YES ;
        }
        return YES ;
    }
    return NO ;
}

- (const char *)asciiCString { return _MSUnicodeToASCIICString(self) ; }

- (BOOL)hasExtension:(NSString *)ext
{
    return (ext ? MSEqualStrings([self pathExtension], ext) : ([[self pathExtension] length] ? NO : YES)) ;
}

- (NSString *)stringWithURLEncoding:(NSStringEncoding)conversionEncoding
{
    if ([self length]) {
        NSData *conversion = [self dataUsingEncoding:conversionEncoding allowLossyConversion:YES] ;
        NSUInteger len = [conversion length] ;
        char *s = (char *)[conversion bytes] ;
        if (len && s) {
            NSString *ret ;
            MSBuffer *buffer = MSURLFromBytes(s, len) ;
            len = [buffer length] ;
#ifdef WO451
            if (len) ret = [NSString stringWithCString:[buffer bytes] length:len] ;
#else
            CBufferAppendByte((CBuffer *)buffer, 0) ;
            if (len) ret = [NSString stringWithUTF8String:[buffer bytes]] ;
#endif
            else ret = [NSString string] ;
            return ret ;
        }
    }
    return self ;
}
- (NSString *)stringWithURLEncoding
{
    return [self stringWithURLEncoding:NSISOLatin1StringEncoding] ;
}

- (NSString *)stringByAppendingURLComponent:(NSString *)urlComponent
{
    if ([urlComponent length]) {
        if ([self characterAtIndex:([self length]-1)] == (unichar)'/') return [self stringByAppendingFormat:@"%@", urlComponent];
        else return [self stringByAppendingFormat:@"/%@", urlComponent];
    }
    else return self ;
}

- (NSString *)stringByDeletingLastURLComponent
{
    NSRange range = [self rangeOfString:@"/" options:NSBackwardsSearch range:NSMakeRange(0, ([self length]-1))] ;
    if(range.length && range.location)
    {
        return [self substringWithRange:NSMakeRange(0, range.location)] ;
    }
    else return self ;
}

- (NSString*)decodedURLString
{
	char *s = (char *)[self UTF8String] ; // on retourne à use form de buffer (!?!)
	if (s && *s) {
		NSUInteger len = (NSUInteger)strlen(s) ;
		MSString *ret = (MSString*)CCreateString(len) ;
		
		if (CStringAppendURLBytes((CString*)ret, (void *)s, len, NSUTF8StringEncoding, NULL)) {
			return AUTORELEASE(ret) ;
		}
		RELEASE(ret) ;
	}
	return [NSString string] ;
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
- (SES)stringEnumeratorStructure
{
  return MSMakeSESWithBytes(_buf, _length, NSUnicodeStringEncoding);
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

- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding
{
  CBuffer *b= CCreateBufferWithString((CString*)self, encoding);
  AUTORELEASE((MSBuffer*)b);
  return (const char *)CBufferCString(b);
}
- (const char *)UTF8String
{
  return [self cStringUsingEncoding:NSUTF8StringEncoding];
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

/*
 
 MSJSONEncoder.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Jean-Michel Bertheas :  jean-michel.bertheas@club-internet.fr
 
 
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

//#import "_MSFoundationPrivate.h"
//#import "MSUnicodeString.h"
//#import "MSNaturalArray.h"
//#import "MSDate.h"
//#import "MSColor.h"
//#import "MSStringEnumeration.h"
#import "MSNet_Private.h"

@interface MSJSONEncoder (Private)
- (void)_clean ;
@end

@implementation MSJSONEncoder

+ (id)encoder
{
    return [[[self alloc] init] autorelease];
}

- (void)dealloc
{
    [self _clean] ;
    [super dealloc] ;
}

- (void)encodeBytes:(void *)bytes length:(unsigned int)length
{ 
    MSBuffer *buf = [[MSBuffer bufferWithBytesNoCopy:bytes length:length] encodedToBase64] ;
    CStringAppendBytes((CString*)_content, NSASCIIStringEncoding, [buf bytes], [buf length]);
}

- (void)encodeUnichar:(unichar)c
{
  CStringAppendCharacter((CString*)_content, c);
}

- (void)encodeString:(NSString *)s
{
  CStringAppendSES((CString*)_content, SESFromString(s));
}

- (void)encodeStringDelimiter
{
  CStringAppendCharacter((CString*)_content, (unichar)'"');
}

- (void)encodeUnsignedChar:(unsigned char)c
{
  CStringAppendFormat((CString*)_content, "%hhu", c);
}

- (void)encodeChar:(char)c
{   
  CStringAppendFormat((CString*)_content, "%hhd", c);
}

- (void)encodeUnsignedShort:(unsigned short)s
{   
  CStringAppendFormat((CString*)_content, "%hu", s);
}

- (void)encodeShort:(short)s
{
  CStringAppendFormat((CString*)_content, "%hd", s);
}

- (void)encodeUnsignedInt:(unsigned int)i
{
  CStringAppendFormat((CString*)_content, "%u", i);
}

- (void)encodeInt:(int)i
{
  CStringAppendFormat((CString*)_content, "%d", i);
}

- (void)encodeUnsignedLongLong:(unsigned long long)l
{
  CStringAppendFormat((CString*)_content, "%llu", l);
}

- (void)encodeLongLong:(long long)l
{
  CStringAppendFormat((CString*)_content, "%lld", l);
}

- (void)encodeFloat:(float)f
{
  CStringAppendFormat((CString*)_content, "%f", f);
}
- (void)encodeDouble:(double)d
{
  CStringAppendFormat((CString*)_content, "%f", d);
}

- (void)encodeObject:(id)anObject withReference:(unsigned)reference
{
    if (!anObject)
        CStringAppendSES((CString*)_content, SESFromString(@"null"));
    else {
        NSUInteger ref = (NSUInteger)CDictionaryObjectForKey(_jsonEncodedObjectReferences, anObject) ;
        
        if (ref) {
            if (reference) {
                NSString *jsonObjectRef = [NSString stringWithFormat:@"{\"$ref\":\"%lu\"}", ref] ;
                CStringAppendSES((CString*)_content, SESFromString(jsonObjectRef));
            }
            else {
                MSRaise(NSGenericException, @"Circular reference detected during JSON encoding (class = %@, ref = %lu)", NSStringFromClass([anObject class]), ref) ;
            }
        }
        else {
            ref = CDictionaryCount(_jsonEncodedObjectReferences) + 1 ;
            
            CDictionarySetObjectForKey(_jsonEncodedObjectReferences, (id)(intptr_t)ref, anObject) ;
            
            [anObject encodeWithJSONEncoder:self withReference:(reference ? ref : 0)] ;

            if (!reference) {
                CDictionarySetObjectForKey(_jsonEncodedObjectReferences, nil, anObject) ;
            }
        }
    }
}

- (MSString *)encodeRootObject:(id)anObject withReferences:(BOOL)manageReferences
{
    MSString *ret = nil ;

    _jsonEncodedObjectReferences = CCreateDictionaryWithOptions(128, CDictionaryNatural, CDictionaryNatural);

    _content = (MSString*)CCreateString(65536) ;
    
    [self encodeObject:anObject withReference:manageReferences ? 1 : 0] ;

    ret = [_content retain] ;
    [self _clean] ;
    return [ret autorelease] ; 
}

- (void)startObjectEncodingWithReference:(unsigned)reference isSimple:(BOOL)isSimple
{
    if (reference) {
        NSString *jsonId = [NSString stringWithFormat:@"{\"id\":\"%u\",", reference] ;
        CStringAppendSES((CString*)_content, SESFromString(jsonId));
    }
    else if (!isSimple) CStringAppendCharacter((CString*)_content, (unichar)'{');
}

- (void)startArrayEncodingWithReference:(unsigned)reference
{
    if (reference) {
        NSString *jsonId = [NSString stringWithFormat:@"{\"id\":\"%u\",", reference] ;
        CStringAppendSES((CString*)_content, SESFromString(jsonId));
    }
    else CStringAppendCharacter((CString*)_content, (unichar)'[');
}

- (void)endObjectEncodingWithReference:(unsigned)reference isSimple:(BOOL)isSimple
{
    if (reference || !isSimple) CStringAppendCharacter((CString*)_content, (unichar)'}');
}

- (void)endArrayEncodingWithReference:(unsigned)reference
{
    if (reference) CStringAppendCharacter((CString*)_content, (unichar)'}');
    else           CStringAppendCharacter((CString*)_content, (unichar)']');
}

- (void)encodeDictionary:(NSDictionary *)aDictionary withReference:(unsigned)reference
{
    unsigned int count = [aDictionary count] ;
    
    [self startObjectEncodingWithReference:reference isSimple:NO] ;
    
    if (count) {
        NSEnumerator *e = [aDictionary keyEnumerator] ;
        id key = [e nextObject] ;
        NSString *jsonKey = [NSString stringWithFormat:@"\"%@\":", key] ;
        CStringAppendSES((CString*)_content, SESFromString(jsonKey));
        [self encodeObject:[aDictionary objectForKey:key] withReference:reference] ;
        
        while ((key = [e nextObject])) {
            jsonKey = [NSString stringWithFormat:@",\"%@\":", key] ;
            CStringAppendSES((CString*)_content, SESFromString(jsonKey));
            [self encodeObject:[aDictionary objectForKey:key] withReference:reference] ;
        }
    }
    [self endObjectEncodingWithReference:reference isSimple:NO] ;
}

- (void)_clean
{
    DESTROY(_jsonEncodedObjectReferences) ;
    DESTROY(_content) ;
}

@end

@implementation NSObject (MSJSONEncoding)
- (NSDictionary *)msSnapshot { return nil ; }

- (void)encodeWithJSONEncoder:(MSJSONEncoder *)encoder withReference:(unsigned)reference
{
    if ([self msSnapshot]) {
        [encoder startObjectEncodingWithReference:reference isSimple:NO] ;
        [encoder encodeObject:self withReference:reference] ;
        [encoder endObjectEncodingWithReference:reference isSimple:NO] ;
    }
    else
        [NSException raise:NSInternalInconsistencyException format:@"Class %@ can't be json encoded! SnapShot not found.", NSStringFromClass(ISA(self))] ;
}
- (MSString *)jsonString
{
    MSJSONEncoder *encoder = NEW(MSJSONEncoder) ;
    MSString *ret = [encoder encodeRootObject:self withReferences:NO] ;
    RELEASE(encoder) ;
    return ret ;
}
- (MSString *)jsonStringWithReferences
{
    MSJSONEncoder *encoder = NEW(MSJSONEncoder) ;
    MSString *ret = [encoder encodeRootObject:self withReferences:YES] ;
    RELEASE(encoder) ;
    return ret ;
}

@end

@implementation NSNull (MSJSONEncoding)
- (void)encodeWithJSONEncoder:(MSJSONEncoder *)encoder withReference:(unsigned)reference {[encoder encodeString:@"null"] ; }
@end

@implementation NSString (MSJSONEncoding)
- (void)encodeWithJSONEncoder:(MSJSONEncoder *)encoder withReference:(unsigned)reference
{ 
    NSString *escapedString = nil ;
	SES ses = [self stringEnumeratorStructure] ;
  
    if (SESOK(ses)) {
        NSUInteger len = SESLength(ses) ;
        register NSUInteger i, estimatedLen = (len * 1.1) + 2 ;
		CHAI characterAtIndex = SESCHAI(ses) ;
        CString *uEscapedString = CCreateString(estimatedLen) ; //memory optimization (by default approximatively 10% characters can be escaped)
        for (i = SESStart(ses) ; i < SESEnd(ses) ; i++) {
            unichar c = characterAtIndex(self,i) ;

            if (uEscapedString->length == (uEscapedString->size-2)) {
                CString *newUnicodeString ;
                estimatedLen = (estimatedLen * 1.1) + 2 ; //memory optimization (grow by approximatively 10%)
                newUnicodeString = CCreateString(estimatedLen);
                CStringAppendString(newUnicodeString, uEscapedString);
                RELEASE((id)uEscapedString);
                uEscapedString = newUnicodeString ;
            }

            if (CUnicharIsEOL(c)) {
                uEscapedString->buf[uEscapedString->length++] = (unichar)'\\' ;
                uEscapedString->buf[uEscapedString->length++] = (unichar)'n' ;
            }
            else if((c == (unichar)'\\')
                || (c == (unichar)'"')) { 
                uEscapedString->buf[uEscapedString->length++] = (unichar)'\\' ;
                uEscapedString->buf[uEscapedString->length++] = c ;
            }
            else {
                uEscapedString->buf[uEscapedString->length++] = c ;
            }
        }
        escapedString = (NSString *)uEscapedString ;
    }
    else escapedString = @"" ;

    [encoder startObjectEncodingWithReference:reference isSimple:YES] ;
    if(reference) [encoder encodeString:@"\"value\":"] ;
    [encoder encodeStringDelimiter] ;
    [encoder encodeString:escapedString] ;
    [encoder encodeStringDelimiter] ;
    [encoder endObjectEncodingWithReference:reference isSimple:YES] ;

    RELEASE(escapedString) ;
}
@end

@implementation NSNumber (MSJSONEncoding)
- (void)encodeWithJSONEncoder:(MSJSONEncoder *)encoder withReference:(unsigned)reference
{
    unsigned char type = *[self objCType] ;

    [encoder startObjectEncodingWithReference:reference isSimple:YES] ;
    if(reference) [encoder encodeString:@"\"value\":"] ;
    switch (type) {
        case 'c': [encoder encodeChar:[self charValue]] ; break;
        case 'C': [encoder encodeUnsignedChar:[self unsignedCharValue]] ; break;
        case 's': [encoder encodeShort:[self shortValue]] ; break;
        case 'S': [encoder encodeUnsignedShort:[self unsignedShortValue]] ; break;
        case 'i': [encoder encodeInt:[self intValue]] ; break;
        case 'I': [encoder encodeUnsignedInt:[self unsignedIntValue]] ; break;
        case 'l': [encoder encodeInt:[self longValue]] ; break;
        case 'L': [encoder encodeUnsignedInt:[self unsignedLongValue]] ; break;
        case 'q': [encoder encodeLongLong:[self longLongValue]] ; break;
        case 'Q': [encoder encodeUnsignedLongLong:[self unsignedLongLongValue]] ; break;
        case 'f': [encoder encodeFloat:[self floatValue]] ; break;
        case 'd': [encoder encodeDouble:[self doubleValue]] ; break;
#ifdef WO451
        default:  [NSException raise:NSInvalidArgumentException format:@"Unknown number type '%s'", type] ; break;
#else
        default:  [NSException raise:NSInvalidArgumentException format:@"Unknown number type '%hhu'", type] ; break;
#endif
    }
    [encoder endObjectEncodingWithReference:reference isSimple:YES] ;
}
@end

#ifdef MSFOUNDATION_FORCOCOA
@implementation NSDecimalNumber (MSJSONEncoding)
- (void)encodeWithJSONEncoder:(MSJSONEncoder *)encoder withReference:(unsigned)reference
{
    unsigned i ;
    NSDecimal d = [self decimalValue] ;

    [encoder startObjectEncodingWithReference:reference isSimple:NO] ;
    [encoder encodeString:@"\"exponent\":"] ;
    [encoder encodeInt:(int)d._exponent] ;
    [encoder encodeString:@",\"length\":"] ;
    [encoder encodeUnsignedInt:d._length] ;
    [encoder encodeString:@",\"isNegative\":"] ;
    [encoder encodeUnsignedInt:d._isNegative] ;
    [encoder encodeString:@",\"isCompact\":"] ;
    [encoder encodeUnsignedInt:d._isCompact] ;
    [encoder encodeString:@",\"reserved\":"] ;
    [encoder encodeUnsignedInt:d._reserved] ;
    for (i = 0; i < 8 ; i++) { 
        [encoder encodeString:[NSString stringWithFormat:@",\"mantissa%u\":", i]] ;
        [encoder encodeUnsignedShort:d._mantissa[i]] ;
    }
    [encoder endObjectEncodingWithReference:reference isSimple:NO] ;
}
@end
#endif

@implementation NSDictionary (MSJSONEncoding)
- (NSDictionary *)msSnapshot { return self; }
- (void)encodeWithJSONEncoder:(MSJSONEncoder *)encoder withReference:(unsigned)reference { [encoder encodeDictionary:[self msSnapshot] withReference:reference] ; }
@end

@implementation NSArray (MSJSONEncoding)
- (void)encodeWithJSONEncoder:(MSJSONEncoder *)encoder withReference:(unsigned)reference
{
    NSUInteger count = [self count] ;

    [encoder startArrayEncodingWithReference:reference] ;
    if (reference) {
        [encoder encodeString:@"\"items\":["] ;
    }

    if (count) {
        NSUInteger i ;

        [encoder encodeObject:[self objectAtIndex:0] withReference:reference] ;
        
        for (i = 1 ; i < count ; i++) { 
            [encoder encodeUnichar:(unichar)','] ;
            [encoder encodeObject:[self objectAtIndex:i] withReference:reference] ;
        }
    }
    if (reference) [encoder encodeUnichar:(unichar)']'] ;
    [encoder endArrayEncodingWithReference:reference] ;
}
@end

@implementation MSNaturalArray (MSJSONEncoding)
- (void)encodeWithJSONEncoder:(MSJSONEncoder *)encoder withReference:(unsigned)reference
{
    NSUInteger count = [self count] ;
    
    [encoder startArrayEncodingWithReference:reference] ;
    if (reference) {
        [encoder encodeString:@"\"items\":"] ;
    }
    
    if (count) {
        NSUInteger i ;
        
        [encoder encodeUnichar:(unichar)'['] ;
        [encoder encodeUnsignedInt:_naturals[0]] ;
        
        for (i = 1 ; i < count ; i++) { 
            [encoder encodeUnichar:(unichar)','] ;
            [encoder encodeUnsignedInt:_naturals[i]] ;
        }
        [encoder encodeUnichar:(unichar)']'] ;
    }
    [encoder endArrayEncodingWithReference:reference] ;
}
@end

@implementation NSDate (MSJSONEncoding)
- (void)encodeWithJSONEncoder:(MSJSONEncoder *)encoder withReference:(unsigned)reference
{ 
    [encoder startObjectEncodingWithReference:reference isSimple:YES] ;
    if(reference) [encoder encodeString:@"\"value\":"] ;
    [encoder encodeLongLong:(long long)[self timeIntervalSince1970]] ;
    [encoder endObjectEncodingWithReference:reference isSimple:YES] ;
}
@end

@implementation MSCouple (MSJSONEncoding)
- (void)encodeWithJSONEncoder:(MSJSONEncoder *)encoder withReference:(unsigned)reference
{
    [encoder startArrayEncodingWithReference:reference] ;
    if (reference) {
        [encoder encodeString:@"\"items\":["] ;
    }
    
    [encoder encodeObject:[self firstMember] withReference:reference] ;
    [encoder encodeUnichar:(unichar)','] ;
    [encoder encodeObject:[self secondMember] withReference:reference] ;
    if (reference) [encoder encodeUnichar:(unichar)']'] ;

    [encoder endArrayEncodingWithReference:reference] ;
}
@end

@implementation MSColor (MSJSONEncoding)
- (void)encodeWithJSONEncoder:(MSJSONEncoder *)encoder withReference:(unsigned)reference
{
    [encoder startObjectEncodingWithReference:reference isSimple:YES] ;
    if(reference) [encoder encodeString:@"\"value\":"] ;
    [encoder encodeStringDelimiter] ;
    [encoder encodeString:[self toString]] ;
    [encoder encodeStringDelimiter] ;
    [encoder endObjectEncodingWithReference:reference isSimple:YES] ;
}
@end

@implementation NSData (MSJSONEncoding)
- (void)encodeWithJSONEncoder:(MSJSONEncoder *)encoder withReference:(unsigned)reference
{
    [encoder startObjectEncodingWithReference:reference isSimple:YES] ;
    if(reference) [encoder encodeString:@"\"value\":"] ;
    [encoder encodeStringDelimiter] ;
    [encoder encodeBytes:(void *)[self bytes] length:[self length]] ;
    [encoder encodeStringDelimiter] ;
    [encoder endObjectEncodingWithReference:reference isSimple:YES] ;
}
@end

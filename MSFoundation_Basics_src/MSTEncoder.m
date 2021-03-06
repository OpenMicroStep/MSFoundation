/*

 MSTEncoder.m

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

#import "MSFoundation_Private.h"
/*
#import "MSTEncoder.h"
#import "MSCBuffer.h"
#import "MSNaturalArray.h"
#import "MSCouple.h"
#import "MSBool.h"
#import "MSColor.h"
#import "MSDate.h"
*/
#define MSTEncoderLastVersion	100

static const char *__hexa = "0123456789ABCDEF" ;

static inline BOOL isMSTETokenTypeReferenced(MSByte tokenType)
{
    return tokenType >= MSTE_TOKEN_TYPE_DECIMAL_VALUE;
}

static inline BOOL isMSTETokenTypeDirectValue(MSByte tokenType)
{
    return tokenType < MSTE_TOKEN_TYPE_REFERENCED_OBJECT;
}

static inline MSByte _ShortValueToHexaCharacter(MSByte c)
{
    if (c < 16) return (MSByte)__hexa[c] ;
    MSRaise(NSGenericException, @"_ShortValueToHexaCharacter - not an hexadecimal value %u", c) ;
    return 0 ;
}

@interface MSTEncoder (Private)

- (void)_encodeTokenSeparator ;

- (void)_encodeTokenType:(MSByte)MSTEToken ;

- (void)_encodeGlobalUnicodeString:(const char *)str ;
- (void)_encodeGlobalUnsignedLongLong:(MSULong)l ;
- (void)_encodeGlobalHexaUnsignedInt:(MSUInt)i at:(MSByte *)pointer;

- (void)_clean ;
@end

@interface NSObject (MSTEncodingPrivate)
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder ;
@end

@implementation MSTEncoder
+ (void)initialize {[MSTEncoder setVersion:MSTEncoderLastVersion];}
+ (id)encoder
{
    return [[[self alloc] init] autorelease];
}

- (void)dealloc
{
    [self _clean] ;
    [super dealloc] ;
}

- (void)encodeBool:(BOOL)b withTokenType:(BOOL)token
{
    if (token) {
        [self _encodeTokenSeparator] ;
        if (b) [self _encodeTokenType:MSTE_TOKEN_TYPE_TRUE] ;
        else [self _encodeTokenType:MSTE_TOKEN_TYPE_FALSE] ;
    }
}

- (void)encodeBytes:(void *)bytes length:(NSUInteger)length withTokenType:(BOOL)token
{
    if (token) {
        [self _encodeTokenSeparator] ;
        [self _encodeTokenType:MSTE_TOKEN_TYPE_BASE64_DATA] ;
    }

    [self _encodeTokenSeparator] ;
    CBufferAppendByte((CBuffer *)_content, (MSByte)'"') ;
    if (bytes && length) CBufferBase64EncodeAndAppendBytes((CBuffer *)_content, bytes, length) ;
    CBufferAppendByte((CBuffer *)_content, (MSByte)'"') ;
}

- (void)encodeUnicodeString:(const char *)str withTokenType:(BOOL)token // encodes an UTF8 string
{
    if (str) {
        NSUInteger len = (MSUInt)strlen(str) ;
        if (token) {
            [self _encodeTokenSeparator] ;
            [self _encodeTokenType:MSTE_TOKEN_TYPE_STRING] ;
        }

        [self _encodeTokenSeparator] ;
        CBufferAppendByte((CBuffer *)_content, (MSByte)'"') ;
        if (len) {
            NSUInteger i ;

            for (i=0 ; i<len ; i++) {
                MSByte c = (MSByte)str[i] ;
                switch (c) { //Escape some characters
                    case 34 : { // double quote
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'"') ;
                        break ;
                    }
                    case 92 : { // antislash
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                        break ;
                    }
                    case 47 : { // slash
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'/') ;
                        break ;
                    }
                    case 8 : { // backspace
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'b') ;
                        break ;
                    }
                    case 12 : { // formfeed
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'f') ;
                        break ;
                    }
                    case 10 : { // newline
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'n') ;
                        break ;
                    }
                    case 13 : { // carriage return
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'r') ;
                        break ;
                    }
                    case 9 : { // tabulation
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'t') ;
                        break ;
                    }
                    default: {
                        CBufferAppendByte((CBuffer *)_content, c) ;
                        break ;
                    }
                }
            }
        }
        CBufferAppendByte((CBuffer *)_content, (MSByte)'"') ;
    }
    else MSRaise(NSGenericException, @"encodeUnicodeString:withTokenType: no string to encode!") ;
}

- (void)encodeString:(NSString *)s withTokenType:(BOOL)token // transforms a string in its UTF16 counterpart and encodes it
{
    [self encodeString:s withTokenType:token andDoubleQuotes:YES] ;
}

- (void)encodeString:(NSString *)s withTokenType:(BOOL)token andDoubleQuotes:(BOOL)doubleQuotes
{
    if (s) {
        SES ses= SESFromString(s);
        NSUInteger i;
        if (token) {
            [self _encodeTokenSeparator] ;
            [self _encodeTokenType:MSTE_TOKEN_TYPE_STRING] ;
        }

        [self _encodeTokenSeparator] ;
        if (doubleQuotes) {
            CBufferAppendByte((CBuffer *)_content, (MSByte)'"') ;
        }

        if (SESOK(ses)) {
            for (i= SESStart(ses); i < SESEnd(ses); ) {
                unichar c = SESIndexN(ses, &i);
                switch (c) { //Escape some characters
                    case 34 : { // double quote
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'"') ;
                        break ;
                    }
                    case 92 : { // antislash
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                        break ;
                    }
                    case 47 : { // slash
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'/') ;
                        break ;
                    }
                    case 8 : { // backspace
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'b') ;
                        break ;
                    }
                    case 12 : { // formfeed
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'f') ;
                        break ;
                    }
                    case 10 : { // newline
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'n') ;
                        break ;
                    }
                    case 13 : { // carriage return
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'r') ;
                        break ;
                    }
                    case 9 : { // tabulation
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_content, (MSByte)'t') ;
                        break ;
                    }
                    default: {
                        if ((c < 32) || (c > 127)) { //escape non printable ASCII characters with a 4 characters in UTF16 hexadecimal format (\UXXXX)
                            MSByte b0 = (MSByte)((c & 0xF000)>>12);
                            MSByte b1 = (MSByte)((c & 0x0F00)>>8);
                            MSByte b2 = (MSByte)((c & 0x00F0)>>4);
                            MSByte b3 = (MSByte)(c & 0x000F);

                            CBufferAppendByte((CBuffer *)_content, (MSByte)'\\') ;
                            CBufferAppendByte((CBuffer *)_content, (MSByte)'u') ;
                            CBufferAppendByte((CBuffer *)_content, _ShortValueToHexaCharacter(b0)) ;
                            CBufferAppendByte((CBuffer *)_content, _ShortValueToHexaCharacter(b1)) ;
                            CBufferAppendByte((CBuffer *)_content, _ShortValueToHexaCharacter(b2)) ;
                            CBufferAppendByte((CBuffer *)_content, _ShortValueToHexaCharacter(b3)) ;
                        }
                        else CBufferAppendByte((CBuffer *)_content, (MSByte)c) ;
                        break ;
                    }
                }
            }
        }
      if (doubleQuotes) {
          CBufferAppendByte((CBuffer *)_content, (MSByte)'"') ;
      }
    }
    else MSRaise(NSGenericException, @"encodeString:withTokenType: no string to encode!") ;
}

static inline void _encodeTokenTypeWithSeparator(id self, MSByte MSTEToken, BOOL token)
{
  if (token) {
    [self _encodeTokenSeparator] ;
    [self _encodeTokenType:MSTEToken] ;}
  [self _encodeTokenSeparator] ;
}

- (void)encodeDecimal:(MSDecimal *)d withTokenType:(BOOL)token
{
    char *ascii= NULL;
    _encodeTokenTypeWithSeparator(self, MSTE_TOKEN_TYPE_DECIMAL_VALUE, token);
    ascii= m_apm_to_fixpt_stringexp(-1, (CDecimal*)d, '.', 0, 0);
    CBufferAppendCString((CBuffer *)_content, ascii);
    free(ascii);
}

- (void)encodeUnsignedChar:(MSByte)c withTokenType:(BOOL)token
{
    char toAscii[4] = "";
    _encodeTokenTypeWithSeparator(self, MSTE_TOKEN_TYPE_UNSIGNED_CHAR, token);
    sprintf(toAscii, "%u", c);
    CBufferAppendCString((CBuffer *)_content, toAscii);
}

- (void)encodeChar:(MSChar)c withTokenType:(BOOL)token
{
    char toAscii[5] = "";
    _encodeTokenTypeWithSeparator(self, MSTE_TOKEN_TYPE_CHAR, token);
    sprintf(toAscii, "%d", c);
    CBufferAppendCString((CBuffer *)_content, toAscii);
}

- (void)encodeUnsignedShort:(MSUShort)s withTokenType:(BOOL)token
{
    char toAscii[6] = "";
    _encodeTokenTypeWithSeparator(self, MSTE_TOKEN_TYPE_UNSIGNED_SHORT, token);
    sprintf(toAscii, "%u", s);
    CBufferAppendCString((CBuffer *)_content, toAscii);
}

- (void)encodeShort:(MSShort)s withTokenType:(BOOL)token
{
    char toAscii[7] = "";
    _encodeTokenTypeWithSeparator(self, MSTE_TOKEN_TYPE_SHORT, token);
    sprintf(toAscii, "%d", s);
    CBufferAppendCString((CBuffer *)_content, toAscii);
}

- (void)encodeUnsignedInt:(MSUInt)i withTokenType:(BOOL)token
{
    char toAscii[11] = "";
    _encodeTokenTypeWithSeparator(self, MSTE_TOKEN_TYPE_UNSIGNED_INT32, token);
    sprintf(toAscii, "%u", i);
    CBufferAppendCString((CBuffer *)_content, toAscii);
}

- (void)encodeInt:(MSInt)i withTokenType:(BOOL)token
{
    char toAscii[12] = "";
    _encodeTokenTypeWithSeparator(self, MSTE_TOKEN_TYPE_INT32, token);
    sprintf(toAscii, "%d", i);
    CBufferAppendCString((CBuffer *)_content, toAscii);
}

- (void)encodeUnsignedLongLong:(MSULong)l withTokenType:(BOOL)token
{
    char toAscii[21] = "";
    _encodeTokenTypeWithSeparator(self, MSTE_TOKEN_TYPE_UNSIGNED_INT64, token);
    sprintf(toAscii, "%llu", l);
    CBufferAppendCString((CBuffer *)_content, toAscii);
}

- (void)encodeLongLong:(MSLong)l withTokenType:(BOOL)token
{
    char toAscii[22] = "";
    _encodeTokenTypeWithSeparator(self, MSTE_TOKEN_TYPE_INT64, token);
    sprintf(toAscii, "%lld", l);
    CBufferAppendCString((CBuffer *)_content, toAscii);
}

- (void)encodeFloat:(float)f withTokenType:(BOOL)token
{
    char toAscii[20] = "";
    _encodeTokenTypeWithSeparator(self, MSTE_TOKEN_TYPE_FLOAT, token);
    sprintf(toAscii, "%f", f);
    CBufferAppendCString((CBuffer *)_content, toAscii);
}

- (void)encodeDouble:(double)d withTokenType:(BOOL)token
{
    char toAscii[40] = "";
    _encodeTokenTypeWithSeparator(self, MSTE_TOKEN_TYPE_DOUBLE, token);
    sprintf(toAscii, "%.15f", d);
    CBufferAppendCString((CBuffer *)_content, toAscii);
}

- (void)encodeArray:(NSArray *)anArray
{
    id object ;
    NSEnumerator *e = [anArray objectEnumerator] ;

    [self encodeUnsignedLongLong:(MSULong)[anArray count] withTokenType:NO] ;
    while ((object = [e nextObject])) {
        [self encodeObject:object] ;
    }
}

- (void)encodeDictionary:(NSDictionary *)aDictionary
{
    id key ;
    NSEnumerator *ek = [aDictionary keyEnumerator] ;

    [self encodeUnsignedLongLong:(MSULong)[aDictionary count] withTokenType:NO] ;
    while ((key = [ek nextObject])) {
        id object = [aDictionary objectForKey:key] ;
        NSUInteger keyReference = (NSUInteger)CDictionaryObjectForKey(_keys, key) ;
        if (!keyReference) {
            keyReference = ++_lastKeyIndex ;
            CDictionarySetObjectForKey(_keys, (id)keyReference, key) ;
            [_keysArray addObject:key] ;
        }
        [self encodeUnsignedLongLong:(MSULong)(keyReference-1) withTokenType:NO] ;
        [self encodeObject:object] ;
    }
}

- (void)encodeObject:(id)anObject
{
    MSByte MSTEToken = [anObject MSTEToken];
    BOOL isReferencing = isMSTETokenTypeReferenced(MSTEToken);
    [self _encodeTokenSeparator] ;
    if (isReferencing) {
        NSUInteger objectReference = (NSUInteger)CDictionaryObjectForKey(_encodedObjects, anObject) ;
        if (objectReference) {
            //this is an already encoded object
            [self _encodeTokenType:MSTE_TOKEN_TYPE_REFERENCED_OBJECT] ;
            [self encodeUnsignedInt:(objectReference-1) withTokenType:NO] ;
            return;
        }
        else {
            objectReference = ++_lastReference ;
            CDictionarySetObjectForKey(_encodedObjects, (id)objectReference, anObject) ;

            if (MSTEToken == MSTE_TOKEN_TYPE_USER_CLASS) {
                NSString *identifier = [anObject MSTEIdentifier] ;
                NSDictionary *snapshot = [anObject MSTESnapshot] ;
                if (!identifier) MSRaise(NSGenericException, @"-[%@ MSTEIdentifier] returned nil", [anObject class]) ;
                if (!snapshot) MSRaise(NSGenericException, @"-[%@ MSTESnapshot] returned nil", [anObject class]) ;
                NSUInteger classIndex = (NSUInteger)CDictionaryObjectForKey(_classes, identifier) ;
                if (!classIndex) {
                    classIndex = ++_lastClassIndex ;
                    CDictionarySetObjectForKey(_classes, (id)classIndex, identifier) ;
                    [_classesArray addObject:identifier] ;
                }
                [self _encodeTokenType:(MSTE_TOKEN_TYPE_USER_CLASS + classIndex - 1)] ;
                [self encodeDictionary:snapshot] ;
                return;
            }
        }
    }

    [self _encodeTokenType:MSTEToken] ;
    if (!isMSTETokenTypeDirectValue(MSTEToken))
        [anObject encodeWithMSTEncoder:self] ;
}

- (MSBuffer *)encodeRootObject:(id)anObject
{
    MSBuffer *ret = nil ;
    NSUInteger crcPos;
    NSEnumerator *ec, *ek ;
    NSString *aClassName, *aKey ;

    _keysArray = NEW(NSMutableArray) ;
    _classesArray = NEW(NSMutableArray) ;
    _classes = CCreateDictionaryWithOptions(32, CDictionaryObject, CDictionaryPointer);
    _keys = CCreateDictionaryWithOptions(256, CDictionaryObject, CDictionaryPointer);
    _encodedObjects = CCreateDictionaryWithOptions(256, CDictionaryPointer, CDictionaryPointer);
    _global = (MSBuffer*)CCreateBuffer(65536) ;
    _content = (MSBuffer*)CCreateBuffer(65536) ;

    [self encodeObject:anObject] ;

    //MSTE header
    CBufferAppendCString((CBuffer *)_global, "[\"MSTE") ;
    CBufferAppendCString((CBuffer *)_global, MSTE_CURRENT_VERSION) ;
    CBufferAppendCString((CBuffer *)_global, "\",") ;

    [self _encodeGlobalUnsignedLongLong:(5+_lastKeyIndex+_lastClassIndex+_tokenCount)] ;
    CBufferAppendCString((CBuffer *)_global, ",\"CRC");
    crcPos = ((CBuffer*)_global)->length ;
    CBufferAppendCString((CBuffer *)_global, "00000000\",");

    //Classes list
    ec = [_classesArray objectEnumerator] ;
    [self _encodeGlobalUnsignedLongLong:(MSByte)[_classesArray count]] ;
    while ((aClassName = [ec nextObject])) {
        CBufferAppendByte((CBuffer *)_global, (MSByte)',');
        [self _encodeGlobalUnicodeString:[aClassName UTF8String]] ;
    }

    //Keys list
    ek = [_keysArray objectEnumerator] ;
    CBufferAppendByte((CBuffer *)_global, (MSByte)',');
    [self _encodeGlobalUnsignedLongLong:(MSUInt)[_keysArray count]] ;
    while ((aKey = [ek nextObject])) {
        CBufferAppendByte((CBuffer *)_global, (MSByte)',');
        [self _encodeGlobalUnicodeString:[aKey UTF8String]] ;
    }

    if (((CBuffer*)_content)->length) {
        CBufferAppendBuffer((CBuffer *)_global, (const CBuffer *)_content) ;
    }

    CBufferAppendByte((CBuffer *)_global, (MSByte)']');

    [self _encodeGlobalHexaUnsignedInt:[_global largeCRC] at:((CBuffer*)_global)->buf+crcPos] ;

    ret = [_global retain] ;
    [self _clean] ;
    return [ret autorelease] ;
}

@end

@implementation MSTEncoder (Private)

- (void)_encodeTokenSeparator { _tokenCount++ ; CBufferAppendByte((CBuffer *)_content, (MSByte)',') ; }

- (void)_encodeTokenType:(MSByte)MSTEToken
{
    char toAscii[4] = "";
    sprintf(toAscii, "%u", (unsigned int)MSTEToken);
    CBufferAppendBytes((CBuffer *)_content, toAscii, strlen(toAscii));
}

- (void)_encodeGlobalUnicodeString:(const char *)str // encodes an UTF8 string
{
    if (str) {
        NSUInteger len = (MSUInt)strlen(str) ;
        CBufferAppendByte((CBuffer *)_global, (MSByte)'"') ;
        if (len) {
            NSUInteger i ;

            for (i=0 ; i<len ; i++) {
                MSByte c = (MSByte)str[i] ;
                switch (c) { //Escape some characters
                    case 9 : { // \t
                        CBufferAppendByte((CBuffer *)_global, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_global, (MSByte)'t') ;
                        break ;
                    }
                    case 10 : { // \n
                        CBufferAppendByte((CBuffer *)_global, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_global, (MSByte)'n') ;
                        break ;
                    }
                    case 13 : { // \r
                        CBufferAppendByte((CBuffer *)_global, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_global, (MSByte)'r') ;
                        break ;
                    }
                    case 34 : { // \"
                        CBufferAppendByte((CBuffer *)_global, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_global, (MSByte)'"') ;
                        break ;
                    }
                    case 92 : { // antislash
                        CBufferAppendByte((CBuffer *)_global, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_global, (MSByte)'\\') ;
                        break ;
                    }
                    case 47 : { // slash
                        CBufferAppendByte((CBuffer *)_global, (MSByte)'\\') ;
                        CBufferAppendByte((CBuffer *)_global, (MSByte)'/') ;
                        break ;
                    }
                    default: {
                        CBufferAppendByte((CBuffer *)_global, (MSByte)c) ;
                        break ;
                    }
                }
            }
        }
        CBufferAppendByte((CBuffer *)_global, (MSByte)'"') ;
    }
    else MSRaise(NSGenericException, @"_encodeGlobalUnicodeString: no string to encode!") ;
}

- (void)_encodeGlobalUnsignedLongLong:(MSULong)l
{
    char toAscii[21] = "";
    NSUInteger len, j ;

    sprintf(toAscii, "%llu", l);
    len = (MSUInt)strlen(toAscii) ;
    for (j=0 ; j<len ; j++) {
        CBufferAppendByte((CBuffer *)_global, (MSByte)toAscii[j]) ;
    }
}

- (void)_encodeGlobalHexaUnsignedInt:(MSUInt)i at:(MSByte *)pointer
{
    MSByte b0 = (MSByte)((i & 0xF0000000)>>28);
    MSByte b1 = (MSByte)((i & 0x0F000000)>>24);
    MSByte b2 = (MSByte)((i & 0x00F00000)>>20);
    MSByte b3 = (MSByte)((i & 0x000F0000)>>16);
    MSByte b4 = (MSByte)((i & 0x0000F000)>>12);
    MSByte b5 = (MSByte)((i & 0x00000F00)>>8);
    MSByte b6 = (MSByte)((i & 0x000000F0)>>4);
    MSByte b7 = (MSByte)(i & 0x0000000F);

    *pointer = _ShortValueToHexaCharacter(b0) ; pointer++ ;
    *pointer = _ShortValueToHexaCharacter(b1) ; pointer++ ;
    *pointer = _ShortValueToHexaCharacter(b2) ; pointer++ ;
    *pointer = _ShortValueToHexaCharacter(b3) ; pointer++ ;
    *pointer = _ShortValueToHexaCharacter(b4) ; pointer++ ;
    *pointer = _ShortValueToHexaCharacter(b5) ; pointer++ ;
    *pointer = _ShortValueToHexaCharacter(b6) ; pointer++ ;
    *pointer = _ShortValueToHexaCharacter(b7) ;
}

- (void)_clean
{
    DESTROY(_classes) ;
    DESTROY(_keys) ;
    DESTROY(_encodedObjects) ;
    _lastKeyIndex = _lastClassIndex = _lastReference = _tokenCount = 0 ;
    DESTROY(_keysArray) ;
    DESTROY(_classesArray) ;
    DESTROY(_content) ;
    DESTROY(_global) ;
}

@end

@implementation NSObject (MSTEncoding)

- (MSByte)MSTEToken { return 0 ; }
- (NSString *)MSTEIdentifier { return NSStringFromClass([self class]); }
- (NSDictionary *)MSTESnapshot { [self notImplemented:_cmd] ; return nil ; } //must be overriden by subclasse to be encoded as a dictionary. keys of snapshot are member names, values are MSCouple with the member in firstMember and in secondMember : nil if member is strongly referenced, or not nil if member is weakly referenced.

- (MSBuffer *)MSTEncodedBuffer
{
    MSTEncoder *encoder = NEW(MSTEncoder) ;
    MSBuffer *ret = [encoder encodeRootObject:self] ;
    RELEASE(encoder) ;
    return ret ;
}
@end

@implementation NSObject (MSTEncodingPrivate)
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder { [self notImplemented:_cmd] ; MSUnused(encoder); } //must be overriden by subclasse to be encoded
@end

@implementation NSNull (MSTEncoding)
- (MSByte)MSTEToken { return MSTE_TOKEN_TYPE_NULL ; }
@end

@implementation MSBool (MSTEncoding)
- (MSByte)MSTEToken
{
    if ([self isTrue]) return MSTE_TOKEN_TYPE_TRUE ;
    else return MSTE_TOKEN_TYPE_FALSE ;
}
@end

@implementation NSString (MSTEncoding)
- (MSByte)MSTEToken { return [self length] ? MSTE_TOKEN_TYPE_STRING : MSTE_TOKEN_TYPE_EMPTY_STRING ; }
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder
{
    if ([self length]) [encoder encodeString:self withTokenType:NO] ;
}
@end

static NSNumber *__aBool = nil ;


@implementation MSDecimal (MSTEncoding)
- (MSByte)MSTEToken { return MSTE_TOKEN_TYPE_DECIMAL_VALUE ; }
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder
{
  [encoder encodeDecimal:self withTokenType:NO];
}
@end

@implementation NSNumber (MSTEncoding)
- (MSByte)MSTEToken { return MSTE_TOKEN_TYPE_DECIMAL_VALUE ; }
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder
{
  char type = *[self objCType] ;
  switch (type) {
    case 'c': [encoder encodeChar:[self charValue] withTokenType:NO] ; break;
    case 'C': [encoder encodeUnsignedChar:[self unsignedCharValue] withTokenType:NO] ; break;
    case 's': [encoder encodeShort:[self shortValue] withTokenType:NO] ; break;
    case 'S': [encoder encodeUnsignedShort:[self unsignedShortValue] withTokenType:NO] ; break;
    case 'i': [encoder encodeInt:[self intValue] withTokenType:NO] ; break;
    case 'I': [encoder encodeUnsignedInt:[self unsignedIntValue] withTokenType:NO] ; break;
    case 'l': [encoder encodeInt:(int)[self longValue] withTokenType:NO] ; break;
    case 'L': [encoder encodeUnsignedInt:(unsigned int)[self unsignedLongValue] withTokenType:NO] ; break;
    case 'q': [encoder encodeLongLong:[self longLongValue] withTokenType:NO] ; break;
    case 'Q': [encoder encodeUnsignedLongLong:[self unsignedLongLongValue] withTokenType:NO] ; break;
    case 'f': [encoder encodeFloat:[self floatValue] withTokenType:NO] ; break;
    case 'd': [encoder encodeDouble:[self doubleValue] withTokenType:NO] ; break;
    default:  [NSException raise:NSInvalidArgumentException format:@"Unknown number type '%hhu'", type] ; break;
  }
}
@end

@implementation NSDictionary (MSTEncoding)
- (MSByte)MSTEToken { return MSTE_TOKEN_TYPE_DICTIONARY ; }
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder { [encoder encodeDictionary:self] ; }
@end

@implementation MSDictionary (MSTEncoding)
- (MSByte)MSTEToken { return MSTE_TOKEN_TYPE_DICTIONARY ; }
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder { [encoder encodeDictionary:(NSDictionary*)self] ; }
@end

@implementation NSArray (MSTEncoding)
- (MSByte)MSTEToken { return MSTE_TOKEN_TYPE_ARRAY ; }
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder { [encoder encodeArray:self] ; }
@end

@implementation MSNaturalArray (MSTEncoding)
- (MSByte)MSTEToken { return MSTE_TOKEN_TYPE_NATURAL_ARRAY ; }
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder
{
    NSUInteger i;
    [encoder encodeUnsignedLongLong:(MSULong)_count withTokenType:NO] ;
    for (i = 0; i < _count ; i++) [encoder encodeUnsignedInt:(MSUInt)_naturals[i] withTokenType:NO] ;
}
@end

@implementation NSDate (MSTEncoding)
- (MSByte)MSTEToken { return MSTE_TOKEN_TYPE_TIMESTAMP ; }
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder
{
  if (![[NSDate distantPast] isEqual:self] && ![[NSDate distantFuture] isEqual:self]) {
    [encoder encodeDouble:[self timeIntervalSince1970] withTokenType:NO] ;
  }
  else {
    [NSException raise:NSGenericException format:@"MSTE protocol does not allow to encode distant past and distant future for NSDate class!"] ;
  }
}
@end

@implementation MSDate (MSTEncoding)
- (MSByte)MSTEToken { return MSTE_TOKEN_TYPE_DATE ; }
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder
{
  if (![[MSDate distantPast] isEqual:self] && ![[MSDate distantFuture] isEqual:self]) {
    [encoder encodeLongLong:[self secondsSinceLocalReferenceDate]+CDateSecondsFrom19700101To20010101 withTokenType:NO] ;
  }
  else {
    [NSException raise:NSGenericException format:@"MSTE protocol does not allow to encode distant past and distant future for MSDate class!"] ;
  }
}
@end

@implementation MSCouple (MSTEncoding)
- (MSByte)MSTEToken { return MSTE_TOKEN_TYPE_COUPLE ; }
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder
{
    [encoder encodeObject:_members[0]] ;
    [encoder encodeObject:_members[1]] ;
}
@end

@implementation NSData (MSTEncoding)
- (MSByte)MSTEToken { return [self length] ? MSTE_TOKEN_TYPE_BASE64_DATA : MSTE_TOKEN_TYPE_EMPTY_DATA ;  }
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder { if ([self length]) [encoder encodeBytes:(void *)[self bytes] length:[self length] withTokenType:NO] ; }
@end

@implementation MSColor (MSTEncoding)
- (MSByte)MSTEToken { return MSTE_TOKEN_TYPE_COLOR ; }
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder { [encoder encodeUnsignedInt:[self cssValue] withTokenType:NO] ; }
@end

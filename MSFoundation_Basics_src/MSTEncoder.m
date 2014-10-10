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
static NSDictionary *__decimalLocale = nil ;


static inline MSByte _ShortValueToHexaCharacter(MSByte c)
{
    if (c < 16) return __hexa[c] ;
    MSRaise(NSGenericException, @"_ShortValueToHexaCharacter - not an hexadecimal value %u", c) ;
    return 0 ;
}

@interface MSTEncoder (Private)

- (void)_encodeTokenSeparator ;

- (void)_encodeTokenType:(MSByte)tokenType ;

- (void)_encodeGlobalUnicodeString:(const char *)str ;
- (void)_encodeGlobalUnsignedLongLong:(MSULong)l ;
- (void)_encodeGlobalHexaUnsignedInt:(MSUInt)i at:(MSByte *)pointer;

- (void)_clean ;
@end

@interface NSObject (MSTEncodingPrivate)
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder ;
@end

@implementation MSTEncoder

+ (id)encoder
{
    return [[[self alloc] init] autorelease];
}

+ (void)initialize
{
    if ([self class] == [MSTEncoder class]) {
        [MSTEncoder setVersion:MSTEncoderLastVersion] ;
    }
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
        NSUInteger len = [s length] ;
        if (token) {
            [self _encodeTokenSeparator] ;
            [self _encodeTokenType:MSTE_TOKEN_TYPE_STRING] ;
        }
        
        [self _encodeTokenSeparator] ;
        if (doubleQuotes) {
            CBufferAppendByte((CBuffer *)_content, (MSByte)'"') ;
        }
      
        if (len) {
            NSUInteger i ;
            
            for (i=0 ; i<len ; i++) {
                unichar c = [s characterAtIndex:i] ;
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

- (void)encodeUnsignedChar:(MSByte)c withTokenType:(BOOL)token
{
    char toAscii[4] = "";
    NSUInteger len, i ;
    
    if (token) {
        [self _encodeTokenSeparator] ;
        [self _encodeTokenType:MSTE_TOKEN_TYPE_UNSIGNED_CHAR] ;
    }
    
    [self _encodeTokenSeparator] ;
    sprintf(toAscii, "%u", c);
    len = (MSUInt)strlen(toAscii) ;
    for (i=0 ; i<len ; i++) {
        CBufferAppendByte((CBuffer *)_content, (MSByte)toAscii[i]) ;
    }
}

- (void)encodeChar:(MSChar)c withTokenType:(BOOL)token
{
    char toAscii[5] = "";
    NSUInteger len, i ;
    
    if (token) {
        [self _encodeTokenSeparator] ;
        [self _encodeTokenType:MSTE_TOKEN_TYPE_CHAR] ;
    }
    
    [self _encodeTokenSeparator] ;
    sprintf(toAscii, "%d", c);
    len = (MSUInt)strlen(toAscii) ;
    for (i=0 ; i<len ; i++) {
        CBufferAppendByte((CBuffer *)_content, (MSByte)toAscii[i]) ;
    }
}

- (void)encodeUnsignedShort:(MSUShort)s withTokenType:(BOOL)token
{
    char toAscii[6] = "";
    NSUInteger len, i ;
    
    if (token) {
        [self _encodeTokenSeparator] ;
        [self _encodeTokenType:MSTE_TOKEN_TYPE_UNSIGNED_SHORT] ;
    }
    
    [self _encodeTokenSeparator] ;
    sprintf(toAscii, "%u", s);
    len = (MSUInt)strlen(toAscii) ;
    for (i=0 ; i<len ; i++) {
        CBufferAppendByte((CBuffer *)_content, (MSByte)toAscii[i]) ;
    }
}

- (void)encodeShort:(MSShort)s withTokenType:(BOOL)token
{
    char toAscii[7] = "";
    NSUInteger len, i ;
    
    if (token) {
        [self _encodeTokenSeparator] ;
        [self _encodeTokenType:MSTE_TOKEN_TYPE_SHORT] ;
    }
    
    [self _encodeTokenSeparator] ;
    sprintf(toAscii, "%d", s);
    len = (MSUInt)strlen(toAscii) ;
    for (i=0 ; i<len ; i++) {
        CBufferAppendByte((CBuffer *)_content, (MSByte)toAscii[i]) ;
    }
}

- (void)encodeUnsignedInt:(MSUInt)i withTokenType:(BOOL)token
{
    char toAscii[11] = "";
    NSUInteger len, j ;
    
    if (token) {
        [self _encodeTokenSeparator] ;
        [self _encodeTokenType:MSTE_TOKEN_TYPE_UNSIGNED_INT32] ;
    }
    
    [self _encodeTokenSeparator] ;
    sprintf(toAscii, "%u", i);
    len = (MSUInt)strlen(toAscii) ;
    for (j=0 ; j<len ; j++) {
        CBufferAppendByte((CBuffer *)_content, (MSByte)toAscii[j]) ;
    }
}

- (void)encodeInt:(MSInt)i withTokenType:(BOOL)token
{
    char toAscii[12] = "";
    NSUInteger len, j ;
    
    if (token) {
        [self _encodeTokenSeparator] ;
        [self _encodeTokenType:MSTE_TOKEN_TYPE_INT32] ;
    }
    
    [self _encodeTokenSeparator] ;
    sprintf(toAscii, "%d", i);
    len = (MSUInt)strlen(toAscii) ;
    for (j=0 ; j<len ; j++) {
        CBufferAppendByte((CBuffer *)_content, (MSByte)toAscii[j]) ;
    }
}

- (void)encodeUnsignedLongLong:(MSULong)l withTokenType:(BOOL)token
{
    char toAscii[21] = "";
    NSUInteger len, j ;
    
    if (token) {
        [self _encodeTokenSeparator] ;
        [self _encodeTokenType:MSTE_TOKEN_TYPE_UNSIGNED_INT64] ;
    }
    
    [self _encodeTokenSeparator] ;
    sprintf(toAscii, "%llu", l);
    len = (MSUInt)strlen(toAscii) ;
    for (j=0 ; j<len ; j++) {
        CBufferAppendByte((CBuffer *)_content, (MSByte)toAscii[j]) ;
    }
}

- (void)encodeLongLong:(MSLong)l withTokenType:(BOOL)token
{
    char toAscii[22] = "";
    NSUInteger len, j ;
    
    if (token) {
        [self _encodeTokenSeparator] ;
        [self _encodeTokenType:MSTE_TOKEN_TYPE_INT64] ;
    }
    
    [self _encodeTokenSeparator] ;
    sprintf(toAscii, "%lld", l);
    len = (MSUInt)strlen(toAscii) ;
    for (j=0 ; j<len ; j++) {
        CBufferAppendByte((CBuffer *)_content, (MSByte)toAscii[j]) ;
    }
}

- (void)encodeFloat:(float)f withTokenType:(BOOL)token
{
    char toAscii[20] = "";
    NSUInteger len, j ;
    
    if (token) {
        [self _encodeTokenSeparator] ;
        [self _encodeTokenType:MSTE_TOKEN_TYPE_FLOAT] ;
    }
    
    [self _encodeTokenSeparator] ;
    sprintf(toAscii, "%f", f);
    len = (MSUInt)strlen(toAscii) ;
    for (j=0 ; j<len ; j++) {
        CBufferAppendByte((CBuffer *)_content, (MSByte)toAscii[j]) ;
    }
}

- (void)encodeDouble:(double)d withTokenType:(BOOL)token
{
    char toAscii[40] = "";
    NSUInteger len, j ;
    
    if (token) {
        [self _encodeTokenSeparator] ;
        [self _encodeTokenType:MSTE_TOKEN_TYPE_DOUBLE] ;
    }
    
    [self _encodeTokenSeparator] ;
    sprintf(toAscii, "%.15f", d);
    len = (MSUInt)strlen(toAscii) ;
    for (j=0 ; j<len ; j++) {
        CBufferAppendByte((CBuffer *)_content, (MSByte)toAscii[j]) ;
    }
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
    [self encodeDictionary:(NSDictionary *)aDictionary isSnapshot:NO] ;
}

- (void)encodeDictionary:(NSDictionary *)aDictionary isSnapshot:(BOOL)isSnapshot
{
    id key ;
    NSEnumerator *ek = [aDictionary keyEnumerator] ;
    NSMutableArray *keys = [ALLOC(NSMutableArray) initWithCapacity:[aDictionary count]] ;
    NSMutableArray *objects = [ALLOC(NSMutableArray) initWithCapacity:[aDictionary count]] ;
    NSUInteger i, count ;
  
    if (isSnapshot) {
        while ((key = [ek nextObject])) {
            id o = [aDictionary objectForKey:key] ;
            id object = nil ;
          
            if (![o isKindOfClass:[MSCouple class]]) {
                [NSException raise:NSGenericException format:@"encodeDictionary:isSnapshot: one object is not a MSCouple in a snapshot!"] ;
            }
            else {
                object = [o firstMember] ;
            }
          
            if ([object singleEncodingCode:self] != MSTE_TOKEN_TYPE_NULL) {
                [keys addObject:[key toString]] ;
                [objects addObject:o] ;
            }
        }
    }
    else {
        while ((key = [ek nextObject])) {
            id object = [aDictionary objectForKey:key] ;
            if ([object singleEncodingCode:self] != MSTE_TOKEN_TYPE_NULL) {
                [keys addObject:[key toString]] ;
                [objects addObject:object] ;
            }
        }
    }
    
    count = [keys count] ;
    [self encodeUnsignedLongLong:(MSULong)count withTokenType:NO] ;
    
    for (i = 0 ; i< count ; i++) {
        NSString *stringKey = [keys objectAtIndex:i] ;
        NSUInteger keyReference = (NSUInteger)NSMapGet(_keys, (const void *)stringKey) ;
        if (!keyReference) {
            keyReference = ++_lastKeyIndex ;
            NSMapInsertKnownAbsent(_keys, (const void *)stringKey, (const void *)keyReference) ;
            [_keysArray addObject:stringKey] ;
        }
        
        [self encodeUnsignedLongLong:(MSULong)(keyReference-1) withTokenType:NO] ;
        if (isSnapshot) {
            MSCouple *o = [objects objectAtIndex:i] ;
            id manageReference = [o secondMember] ;
          
            if (manageReference) [self encodeObject:[o firstMember] withReferencing:YES] ;
            else [self encodeObject:[o firstMember] withReferencing:NO] ;
        }
        else [self encodeObject:[objects objectAtIndex:i]] ;
    }
    RELEASE(keys) ;
    RELEASE(objects) ;
}

- (void)encodeObject:(id)anObject { [self encodeObject:anObject withReferencing:YES] ; }

- (void)encodeObject:(id)anObject withReferencing:(BOOL)referencing
{
    MSInt singleToken = [anObject singleEncodingCode:self] ;
    if (singleToken != MSTE_TOKEN_MUST_ENCODE) {
        [self _encodeTokenSeparator] ;
        [self _encodeTokenType:singleToken] ;
    }
    else {
        NSUInteger objectReference = (NSUInteger)NSMapGet(_encodedObjects, (const void *)anObject) ;
        
        if (objectReference) {
            //this is an already encoded object
            [self _encodeTokenSeparator] ;
            [self _encodeTokenType:MSTE_TOKEN_TYPE_REFERENCED_OBJECT] ;
            [self encodeUnsignedInt:(objectReference-1) withTokenType:NO] ;
        }
        else {
            MSByte tokenType = [anObject tokenTypeWithReference:referencing] ;
            if (tokenType >= MSTE_TOKEN_TYPE_USER_CLASS) {
                Class objectClass ;
                NSUInteger classIndex ;
                NSDictionary *snapshot = [anObject MSTESnapshot] ;
                if (!snapshot) MSRaise(NSGenericException, @"encodeObject: Specific user classes must implement MSTESnapshot to be encoded as a dictionary!") ;
                
                objectClass = [anObject class] ;
                classIndex = (NSUInteger)NSMapGet(_classes, (const void *)objectClass) ;
                
                if (!classIndex) {
                    classIndex = ++_lastClassIndex ;
                    NSMapInsertKnownAbsent(_classes, (const void *)objectClass, (const void *)classIndex) ;
                    [_classesArray addObject:NSStringFromClass(objectClass)] ;
                }
                
                objectReference = ++_lastReference ;
                NSMapInsertKnownAbsent(_encodedObjects, (const void *)anObject, (const void *)objectReference) ;
                [self _encodeTokenSeparator] ;
                [self _encodeTokenType:(MSTE_TOKEN_TYPE_USER_CLASS + classIndex - 1)] ;
                [self encodeDictionary:snapshot isSnapshot:YES] ;
            }
            else if (tokenType <= MSTE_TOKEN_LAST_DEFINED_TYPE) {
              
                if (referencing) {
                    objectReference = ++_lastReference ;
                    NSMapInsertKnownAbsent(_encodedObjects, (const void *)anObject, (const void *)objectReference) ;
                }
              
                [self _encodeTokenSeparator] ;
                [self _encodeTokenType:tokenType] ;
                [anObject encodeWithMSTEncoder:self] ;
            }
            else {
                MSRaise(NSGenericException, @"encodeObject: cannot encode an object with token type %u!", (MSUInt)tokenType) ;
            }
            
        }
    }
}

- (MSBuffer *)encodeRootObject:(id)anObject
{
    NSZone *zone = [self zone] ;
    MSBuffer *ret = nil ;
    MSByte *crcPointer ;
    NSEnumerator *ec, *ek ;
    NSString *aClassName, *aKey ;
    
    _keysArray = NEW(NSMutableArray) ;
    _classesArray = NEW(NSMutableArray) ;
    _classes = NSCreateMapTableWithZone(NSObjectMapKeyCallBacks, NSIntegerMapValueCallBacks, 32, zone) ;
    _keys = NSCreateMapTableWithZone(NSObjectMapKeyCallBacks, NSIntegerMapValueCallBacks, 256, zone) ;
    _encodedObjects = NSCreateMapTableWithZone(NSNonOwnedPointerMapKeyCallBacks, NSIntegerMapValueCallBacks, 256, zone) ;
    _global = MSCreateBuffer(65536) ;
    _content = MSCreateBuffer(65536) ;
    
    [self encodeObject:anObject] ;
    
    //MSTE header
    CBufferAppendCString((CBuffer *)_global, "[\"MSTE") ;
    CBufferAppendCString((CBuffer *)_global, MSTE_CURRENT_VERSION) ;
    CBufferAppendCString((CBuffer *)_global, "\",") ;
  
    [self _encodeGlobalUnsignedLongLong:(5+_lastKeyIndex+_lastClassIndex+_tokenCount)] ;
    CBufferAppendCString((CBuffer *)_global, ",\"CRC");
    crcPointer = ((CBuffer*)_global)->buf+((CBuffer*)_global)->length ;
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
        MSBAddBuffer(_global, _content) ;
    }
    
    CBufferAppendByte((CBuffer *)_global, (MSByte)']');
    
    [self _encodeGlobalHexaUnsignedInt:[_global largeCRC] at:crcPointer] ;
    
    ret = [_global retain] ;
    [self _clean] ;
    return [ret autorelease] ;
}

@end

@implementation MSTEncoder (Private)

- (void)_encodeTokenSeparator { _tokenCount++ ; CBufferAppendByte((CBuffer *)_content, (MSByte)',') ; }

- (void)_encodeTokenType:(MSByte)tokenType
{
    char toAscii[4] = "";
    NSUInteger len, i ;

    sprintf(toAscii, "%u", tokenType);
    len = (MSUInt)strlen(toAscii) ;
    for (i=0 ; i<len ; i++) {
        CBufferAppendByte((CBuffer *)_content, toAscii[i]);
    }
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
    if (_classes) NSFreeMapTable(_classes) ;
    if (_keys) NSFreeMapTable(_keys) ;
    if (_encodedObjects) NSFreeMapTable(_encodedObjects) ;
    _keys = _classes = _encodedObjects = (NSMapTable *)nil ;
    _lastKeyIndex = _lastClassIndex = _lastReference = _tokenCount = 0 ;
    DESTROY(_keysArray) ;
    DESTROY(_classesArray) ;
    DESTROY(_content) ;
    DESTROY(_global) ;
}

@end

@implementation NSObject (MSTEncoding)

- (MSByte)tokenType { return MSTE_TOKEN_TYPE_USER_CLASS ; } //must be overriden by subclasse to be encoded if tokenTypeWithReference: method is not overriden
- (MSByte)tokenTypeWithReference:(BOOL)isReferenced { return [self tokenType] ; } //must be overriden by subclasse to be encoded if tokenType method is not overriden

- (NSDictionary *)MSTESnapshot { [self notImplemented:_cmd] ; return nil ; } //must be overriden by subclasse to be encoded as a dictionary. keys of snapshot are member names, values are MSCouple with the member in firstMember and in secondMember : nil if member is strongly referenced, or not nil if member is weakly referenced.

- (MSInt)singleEncodingCode:(MSTEncoder *)encoder {return MSTE_TOKEN_MUST_ENCODE ; }
- (MSBuffer *)MSTEncodedBuffer
{
    MSTEncoder *encoder = NEW(MSTEncoder) ;
    MSBuffer *ret = [encoder encodeRootObject:self] ;
    RELEASE(encoder) ;
    return ret ;
}

@end

@implementation NSObject (MSTEncodingPrivate)

- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder { (void)[self notImplemented:_cmd] ; } //must be overriden by subclasse to be encoded

@end

@implementation NSNull (MSTEncoding)
- (MSByte)tokenType { return MSTE_TOKEN_TYPE_NULL ; }
- (MSInt)singleEncodingCode:(MSTEncoder *)encoder { return MSTE_TOKEN_TYPE_NULL ; }
@end

@implementation MSBool (MSTEncoding)
- (MSInt)singleEncodingCode:(MSTEncoder *)encoder
{
    if ([self isTrue]) return MSTE_TOKEN_TYPE_TRUE ;
    else return MSTE_TOKEN_TYPE_FALSE ;
}
- (MSByte)tokenType
{
    if ([self isTrue]) return MSTE_TOKEN_TYPE_TRUE ;
    else return MSTE_TOKEN_TYPE_FALSE ;
}
@end

@implementation NSString (MSTEncoding)
- (MSInt)singleEncodingCode:(MSTEncoder *)encoder
{
    return [self length] ? MSTE_TOKEN_MUST_ENCODE : MSTE_TOKEN_TYPE_EMPTY_STRING ;
}
- (MSByte)tokenType { return MSTE_TOKEN_TYPE_STRING ; }
@end

@implementation NSString (MSTEncodingPrivate)
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder
{
    if ([self length]) [encoder encodeString:self withTokenType:NO] ;
}
@end

static NSNumber *__aBool = nil ;

@implementation NSNumber (MSTEncoding)
- (MSInt)singleEncodingCode:(MSTEncoder *)encoder
{
  unsigned char type = *[self objCType] ;
  if (type == 'c') {
    if(!__aBool) __aBool = [NSNumber numberWithBool:YES] ;
    if([self isKindOfClass:[__aBool class]]) {
      if ([self isTrue]) return MSTE_TOKEN_TYPE_TRUE ;
      else return MSTE_TOKEN_TYPE_FALSE ;
    }
  }
  return MSTE_TOKEN_MUST_ENCODE ;
}

- (MSByte)tokenType { return MSTE_TOKEN_TYPE_DECIMAL_VALUE ; }
- (MSByte)tokenTypeWithReference:(BOOL)isReferenced
{
  if (isReferenced) {
    return [self tokenType] ;
  }
  else {
    unsigned char type = *[self objCType] ;
    switch (type) {
      case 'c':
      {
        return MSTE_TOKEN_TYPE_CHAR ;
        break ;
      }
      case 'C':
      {
        return MSTE_TOKEN_TYPE_UNSIGNED_CHAR ;
        break ;
      }
      case 's':
      {
        return MSTE_TOKEN_TYPE_SHORT ;
        break ;
      }
      case 'S':
      {
        return MSTE_TOKEN_TYPE_UNSIGNED_SHORT ;
        break ;
      }
      case 'i':
      case 'l':
      {
        return MSTE_TOKEN_TYPE_INT32 ;
        break ;
      }
      case 'I':
      case 'L':
      {
        return MSTE_TOKEN_TYPE_UNSIGNED_INT32 ;
        break ;
      }
      case 'q':
      {
        return MSTE_TOKEN_TYPE_INT64 ;
        break ;
      }
      case 'Q':
      {
        return MSTE_TOKEN_TYPE_UNSIGNED_INT64 ;
        break ;
      }
      case 'f':
      {
        return MSTE_TOKEN_TYPE_FLOAT ;
        break ;
      }
      case 'd':
      {
        return MSTE_TOKEN_TYPE_DOUBLE ;
        break ;
      }
#ifdef WO451
      default:  [NSException raise:NSInvalidArgumentException format:@"Unknown number type '%s'", type] ; break;
#else
      default:  [NSException raise:NSInvalidArgumentException format:@"Unknown number type '%hhu'", type] ; break;
#endif
    }
    return 0 ;
  }
}
@end

@implementation NSNumber (MSTEncodingPrivate)
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder
{
  unsigned char type = *[self objCType] ;
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
#ifdef WO451
    default:  [NSException raise:NSInvalidArgumentException format:@"Unknown number type '%s'", type] ; break;
#else
    default:  [NSException raise:NSInvalidArgumentException format:@"Unknown number type '%hhu'", type] ; break;
#endif
  }
}
@end

@implementation NSDecimalNumber (MSTEncodingPrivate)
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder
{
  if (!__decimalLocale) __decimalLocale = [[NSDictionary alloc] initWithObjectsAndKeys:@".", NSLocaleDecimalSeparator, nil];
  [encoder encodeString:[self descriptionWithLocale:__decimalLocale] withTokenType:NO andDoubleQuotes:NO] ;
}
@end

@implementation NSDictionary (MSTEncoding)
- (MSByte)tokenType { return MSTE_TOKEN_TYPE_DICTIONARY ; }
@end

@implementation NSDictionary (MSTEncodingPricate)
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder { [encoder encodeDictionary:self] ; }
@end

@implementation NSArray (MSTEncoding)
- (MSByte)tokenType { return MSTE_TOKEN_TYPE_ARRAY ; }
@end

@implementation NSArray (MSTEncodingPrivate)
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder { [encoder encodeArray:self] ; }
@end

@implementation MSNaturalArray (MSTEncoding)
- (MSByte)tokenType { return MSTE_TOKEN_TYPE_NATURAL_ARRAY ; }
@end

@implementation MSNaturalArray (MSTEncodingPrivate)
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder
{
    NSUInteger i;
    [encoder encodeUnsignedLongLong:(MSULong)_count withTokenType:NO] ;
    for (i = 0; i < _count ; i++) [encoder encodeUnsignedInt:(MSUInt)_naturals[i] withTokenType:NO] ;
}
@end

@implementation NSDate (MSTEncoding)
- (MSByte)tokenType { return MSTE_TOKEN_TYPE_TIMESTAMP ; }
@end

@implementation NSDate (MSTEncodingPrivate)
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

@implementation NSCalendarDate (MSTEncodingPrivate)
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder
{
  if (![[NSCalendarDate distantPast] isEqual:self] && ![[NSCalendarDate distantFuture] isEqual:self]) {
    [encoder encodeDouble:[self timeIntervalSince1970] withTokenType:NO] ;
  }
  else {
    [NSException raise:NSGenericException format:@"MSTE protocol does not allow to encode distant past and distant future for NSCalendarDate class!"] ;
  }
}
@end

@implementation MSDate (MSTEncoding)
- (MSByte)tokenType { return MSTE_TOKEN_TYPE_DATE ; }
@end

@implementation MSDate (MSTEncodingPrivate)
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder
{
  if (![[MSDate distantPast] isEqual:self] && ![[MSDate distantFuture] isEqual:self]) {
    [encoder encodeLongLong:(MSLong)[self timeIntervalSince1970] withTokenType:NO] ;
  }
  else {
    [NSException raise:NSGenericException format:@"MSTE protocol does not allow to encode distant past and distant future for MSDate class!"] ;
  }
}
@end

@implementation MSCouple (MSTEncoding)
- (MSByte)tokenType { return MSTE_TOKEN_TYPE_COUPLE ; }
@end

@implementation MSCouple (MSTEncodingPrivate)
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder
{
    [encoder encodeObject:_members[0]] ;
    [encoder encodeObject:_members[1]] ;
}
@end

@implementation NSData (MSTEncoding)
- (MSByte)tokenType { return MSTE_TOKEN_TYPE_BASE64_DATA ; }
@end

@implementation NSData (MSTEncodingPrivate)
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder { [encoder encodeBytes:(void *)[self bytes] length:[self length] withTokenType:NO] ; }
@end

@implementation MSColor (MSTEncoding)
- (MSByte)tokenType { return MSTE_TOKEN_TYPE_COLOR ; }
@end

@implementation MSColor (MSTEncodingPrivate)
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder { [encoder encodeUnsignedInt:[self cssValue] withTokenType:NO] ; }
@end

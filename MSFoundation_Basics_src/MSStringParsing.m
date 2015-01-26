/*
 
 MSStringParsing.m
 
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

// values for decodingMask and acceptanceMask
#define MSPPLParseArray				0x00000001
#define MSPPLParseDict				0x00000002
#define MSPPLParseData              0x00000004
#define MSPPLParseString            0x00000008
#define MSPPLParseAll				0x0000000f

#define MSPPLParseSubArray			0x00000010
#define MSPPLParseSubDict			0x00000020
#define MSPPLParseSubData           0x00000040
#define MSPPLParseSubString         0x00000080
#define MSPPLParseSubAll			0x000000f0

typedef struct _ParseContext
{
    SES ses;
    MSUInt flags;
    NSUInteger pos;
    unichar c;
    id error;
} ParseContext;

static inline BOOL ParseContextNext(ParseContext *context)
{
    BOOL ret= context->pos < SESLength(context->ses);
    if(ret) {
        context->c = SESIndexN(context->ses, &context->pos);
    }
    return ret;
}

static BOOL ParseContextNextWord(ParseContext *context)
{
    while (ParseContextNext(context)) {
        if (context->c == (unichar)'/') {
            BOOL ret;
            NSUInteger ppos = context->pos;
            if(!ParseContextNext(context)) {
                return YES;
            }
            if(context->c == (unichar)'/') { // Single Line Comment
                while ((ret= ParseContextNext(context)) && !CUnicharIsEOL(context->c));
                if(!ret) return NO;
            }
            else if(context->c == (unichar)'*') { // Multiline comment
                BOOL canClose= NO;
                while ((ret= ParseContextNext(context))) {
                    if(canClose && context->c == (unichar)'/')
                        break;
                    if(context->c == (unichar)'*')
                        canClose= YES;
                }
                if(!ret) return NO;
            }
            else {
                context->pos = ppos;
                return YES;
            }
        }
        else if(!CUnicharIsSpaceOrEOL(context->c)) {
            return YES;
        }
    }
    return NO;
}

static void ParseContextError(ParseContext *context, NSString* object, NSString *expect)
{
    if(!context->error)
        context->error= FMT(@"Error while parsing %@, %@ was expected at %lld", object, expect, (MSLong)context->pos);
}

static id parsePList(NSString *str, MSUInt flags, NSString **error);
static id parseObject(ParseContext *context, BOOL isRoot);
static MSDictionary *parseDictionary(ParseContext *context);
static MSArray *parseArray(ParseContext *context);
static inline MSString *parseString(ParseContext *context);
static MSString *parseQuotedString(ParseContext *context);
static MSString *parseSimpleString(ParseContext *context);
static MSBuffer *parseData(ParseContext *context);

static id parsePList(NSString *str, MSUInt flags, NSString **error)
{
    id ret= nil;
    ParseContext context;
    context.ses= SESFromString(str);
    context.flags= flags > 0 ? flags : MSPPLParseAll | MSPPLParseAll;
    context.pos= 0;
    context.error= nil;
    if (SESOK(context.ses)) {
        if(!ParseContextNextWord(&context)) ParseContextError(&context, @"Object", @"Something");
        else {
            ret= parseObject(&context, YES);
            if(ParseContextNextWord(&context)) {
                DESTROY(ret);
                ParseContextError(&context, @"Object", @"Nothing");
            }
        }
        if(context.error && error)
            *error= context.error;
    }
    return AUTORELEASE(ret);
}

static inline id parseObjectIfAllowed(ParseContext *context, BOOL isRoot, id (*parseMethod)(ParseContext*), MSUInt rootFlags, MSUInt subFlags, NSString* desc)
{
    if(isRoot && !(context->flags & rootFlags)) {
        ParseContextError(context, @"Object", FMT(@"Root must be a %@", desc));
        return nil;
    }
    else if(!isRoot && !(context->flags & subFlags)) {
        ParseContextError(context, @"Object", FMT(@"%@ is not allowed in this context", desc));
        return nil;
    }
    return parseMethod(context);
}

static id parseObject(ParseContext *context, BOOL isRoot)
{
    switch (context->c) {
        case (unichar)'{':
            return parseObjectIfAllowed(context, isRoot, parseDictionary, MSPPLParseDict, MSPPLParseSubDict, @"dictionary");
        case (unichar)'(':
            return parseObjectIfAllowed(context, isRoot, parseArray, MSPPLParseArray, MSPPLParseSubArray, @"array");
        case (unichar)'<':
            return parseObjectIfAllowed(context, isRoot, parseData, MSPPLParseData, MSPPLParseSubData, @"data");
        default:
            return parseObjectIfAllowed(context, isRoot, parseString, MSPPLParseString, MSPPLParseSubString, @"string");
    }
}

static MSDictionary *parseDictionary(ParseContext *context)
{
    id ret, key=nil, obj=nil, expect=nil;
    
    expect= @"key or '}'";
    ret= (id)CCreateDictionary(0);
    while (ParseContextNextWord(context)) {
        if(context->c == (unichar)'}')
            return ret;
        
        // key
        key= parseString(context);
        if(!key) break;
        
        // =
        expect= @"'='";
        if(!ParseContextNextWord(context) || context->c != (unichar)'=') break;
        
        // object
        expect= @"object";
        if(!ParseContextNextWord(context) || !(obj= parseObject(context, NO))) break;
        CDictionarySetObjectForKey((CDictionary*)ret, obj, key);
        DESTROY(key);
        RELEASE(obj);
        
        // ;
        expect= @"';'";
        if(!ParseContextNextWord(context) || context->c != (unichar)';') break;
        
        expect= @"key or '}'";
    }
    
    ParseContextError(context, @"Dictionary", expect);
    DESTROY(key);
    RELEASE(ret);
    return nil;
}

static MSArray *parseArray(ParseContext *context)
{
    id ret, obj= nil, expect=nil;
    
    expect= @"object or ')'";
    ret= (id)CCreateArray(0);
    while (ParseContextNextWord(context)) {
        if(context->c == (unichar)')')
            return ret;
        
        // object
        if(!(obj= parseObject(context, NO))) break;
        CArrayAddObject((CArray*)ret, obj);
        RELEASE(obj);
        
        // ,
        expect= @"',' or ')'";
        if(!ParseContextNextWord(context)) break;
        if(context->c == (unichar)')')
            return ret;
        if(context->c != (unichar)',') break;
        
        expect= @"object or ')'";
    }
    
    ParseContextError(context, @"Array", expect);
    RELEASE(ret);
    return nil;
}

static inline MSString *parseString(ParseContext *context)
{
    return (context->c == (unichar)'"') ? parseQuotedString(context) : parseSimpleString(context);
}

static unichar parseUnichar(ParseContext *context)
{
    NSUInteger ppos= context->pos; unichar pc= context->c;
    unichar c= 0; MSUInt pos= 0;
    while (pos < 4 && ParseContextNext(context) && CUnicharIsIsoDigit(context->c)) {
        c += ((context->c - (unichar)'0') << (pos * 4));
        ++pos;
    }
    if(pos != 4) {
        context->pos= ppos;
        return pc;
    }
    return c;
}

static MSString *parseQuotedString(ParseContext *context)
{
    unichar c;
    id expect = @"[^\"]+";
    CString *ret= CCreateString(0);
    while(ParseContextNext(context)) {
        if(context->c == (unichar)'\\') {
            expect = @"\\t, \\n, \\r, \\U[0-9]{4}, \\\"";
            if(!ParseContextNext(context))
                break;
            c= context->c;
            switch (c) {
                case 't': context->c= '\t'; break;
                case 'n': context->c= '\n'; break;
                case 'r': context->c= '\r'; break;
                case '"': context->c= '"';  break;
                case 'U':
                case 'u': context->c = parseUnichar(context); break;
                default:  break;
            }
            expect = @"[^\"]+";
        }
        else if(context->c == '"') {
            return (MSString*)ret;
        }
        CStringAppendCharacter(ret, context->c);
    }
    
    ParseContextError(context, @"String", expect);
    RELEASE((id)ret);
    return nil;
}

static MSString *parseSimpleString(ParseContext *context)
{
    NSUInteger ppos;
    CString *ret= CCreateString(0);
    while((CUnicharIsLetter(context->c) || CUnicharIsIsoDigit(context->c) || context->c == (unichar)'_')) {
        CStringAppendCharacter(ret, context->c);
        ppos= context->pos;
        if(!ParseContextNext(context))
            break;
    }
    if(CStringLength(ret)) {
        context->pos= ppos;
        return (MSString *)ret;
    }
    
    ParseContextError(context, @"String", @"[A-Za-z0-9_]+");
    RELEASE((id)ret);
    return nil;
}

static MSBuffer *parseData(ParseContext *context)
{
    MSByte byte, b1; BOOL first= YES;
    CBuffer *ret= CCreateBuffer(0);
    while(ParseContextNext(context)) {
        if(context->c == '>') {
            if(!first) break;
            return (MSBuffer*) ret;
        }
        if(!CUnicharIsSpaceOrEOL(context->c)) {
            if('a' <= context->c && context->c <= 'f') {
                byte = (MSByte)(context->c - (unichar)'a') + 10;
            }
            else if('A' <= context->c && context->c <= 'F') {
                byte = (MSByte)(context->c - (unichar)'A') + 10;
            }
            else if('0' <= context->c && context->c <= '9') {
                byte = (MSByte)(context->c - (unichar)'0');
            }
            else break;
            if(first) b1= byte;
            else CBufferAppendByte(ret, (MSByte)(b1 << 4) + byte);
            first= !first;
        }
    }
    
    ParseContextError(context, @"Data", @"[A-Fa-f0-9]+");
    RELEASE((id)ret);
    return nil;
}

static id parsePListLogError(NSString *str, MSUInt flags)
{
    id ret, error=nil;
    ret= parsePList(str, flags, &error);
    if(error)
        NSLog(@"%@", error);
    return ret;
}
@implementation NSString (MSPPPLParsing)

- (NSMutableDictionary *)dictionaryValue
{ return parsePListLogError(self, MSPPLParseDict | MSPPLParseSubAll); }

- (NSMutableArray *)arrayValue
{ return parsePListLogError(self, MSPPLParseArray | MSPPLParseSubAll); }

- (NSMutableDictionary *)stringsDictionaryValue
{ return parsePListLogError(self, MSPPLParseDict | MSPPLParseSubString); }

- (NSMutableArray *)stringsArrayValue
{ return parsePListLogError(self, MSPPLParseArray | MSPPLParseSubString); }

@end


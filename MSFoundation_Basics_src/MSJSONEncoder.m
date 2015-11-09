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

#import "MSFoundation_Private.h"

typedef CBuffer CJSONEncoder;

static void CJSONEncoderPushTrue(CJSONEncoder *encoder)
{
    CBufferAppendBytes(encoder, "true", 4);
}
static void CJSONEncoderPushFalse(CJSONEncoder *encoder)
{
    CBufferAppendBytes(encoder, "false", 5);
}
static void CJSONEncoderPushNull(CJSONEncoder *encoder)
{
    CBufferAppendBytes(encoder, "null", 4);
}
static inline void CJSONEncoderPushRawBytes(CJSONEncoder *encoder, const char *bytes, NSUInteger length)
{
    CBufferAppendBytes(encoder, bytes, length);
}
static void CJSONEncoderPushNumber(CJSONEncoder *encoder, double number)
{
    char buffer[40]; int n;
    n= snprintf(buffer, 40, "%f", number);
    CBufferAppendBytes(encoder, buffer, n);
}
static void CJSONEncoderPushSES(CJSONEncoder *encoder, SES ses)
{
    NSUInteger i, end; unichar u;
    if (SESOK(ses)) {
        for(i= SESStart(ses), end= SESEnd(ses); i < end;) {
            u= SESIndexN(ses, &i);
            switch(u) {
                case '\"': CBufferAppendBytes(encoder, "\\\"", 2); break;
                case '\\': CBufferAppendBytes(encoder, "\\\\", 2); break;
                case '/' : CBufferAppendBytes(encoder, "\\/" , 2); break;
                case '\b': CBufferAppendBytes(encoder, "\\b" , 2); break;
                case '\f': CBufferAppendBytes(encoder, "\\f" , 2); break;
                case '\n': CBufferAppendBytes(encoder, "\\n" , 2); break;
                case '\r': CBufferAppendBytes(encoder, "\\r" , 2); break;
                case '\t': CBufferAppendBytes(encoder, "\\t" , 2); break;
                default:
                    if (u > 21 && u < 127)
                        CBufferAppendByte(encoder, (MSByte)u);
                    else {
                        char buffer[8]; int n;
                        n= snprintf(buffer, 8, "\\u%04x", u);
                        CBufferAppendBytes(encoder, buffer, n);
                    }
                    break;
            }

        }
    }
}

@interface NSObject (MSJSONEncodingImpl)
- (void)encodeWithJSONEncoder:(CJSONEncoder *)encoder;
@end

@implementation NSObject (MSJSONEncodingImpl)
- (MSBuffer *)JSONEncodedBuffer
{
    CBuffer *b;
    b= CCreateBuffer(0);
    [self encodeWithJSONEncoder:b];
    return AUTORELEASE(b);
}
- (void)encodeWithJSONEncoder:(CJSONEncoder *)encoder
{

}
@end

@implementation NSNull (MSJSONEncodingImpl)
- (void)encodeWithJSONEncoder:(CJSONEncoder *)encoder
{
    CJSONEncoderPushNull(encoder);
}
@end
@implementation NSNumber (MSJSONEncodingImpl)
- (void)encodeWithJSONEncoder:(CJSONEncoder *)encoder
{
    if (self == MSTrue) CJSONEncoderPushTrue(encoder);
    else if (self == MSFalse) CJSONEncoderPushFalse(encoder);
    else CJSONEncoderPushNumber(encoder, [self doubleValue]);
}
@end
@implementation MSDecimal (MSJSONEncodingImpl)
- (void)encodeWithJSONEncoder:(CJSONEncoder *)encoder
{
    CJSONEncoderPushNumber(encoder, [self doubleValue]);
}
@end
@implementation NSString (MSJSONEncodingImpl)
- (void)encodeWithJSONEncoder:(CJSONEncoder *)encoder
{
    CJSONEncoderPushRawBytes(encoder, "\"", 1);
    CJSONEncoderPushSES(encoder, SESFromString(self));
    CJSONEncoderPushRawBytes(encoder, "\"", 1);
}
@end
@implementation NSArray (MSJSONEncodingImpl)
- (void)encodeWithJSONEncoder:(CJSONEncoder *)encoder
{
    NSEnumerator *e; id o; BOOL first= YES;
    CJSONEncoderPushRawBytes(encoder, "[", 1);
    e= [self objectEnumerator];
    if ((o= [e nextObject])) {
        [o encodeWithJSONEncoder:encoder];
    }
    while((o= [e nextObject])) {
        CJSONEncoderPushRawBytes(encoder, ",", 1);
        [o encodeWithJSONEncoder:encoder];
    }
    CJSONEncoderPushRawBytes(encoder, "]", 1);
}
@end
@implementation NSDictionary (MSJSONEncodingImpl)
- (void)encodeWithJSONEncoder:(CJSONEncoder *)encoder
{
    NSEnumerator *e; id k, o; BOOL first= YES;
    CJSONEncoderPushRawBytes(encoder, "{", 1);
    e= [self keyEnumerator];
    if ((k= [e nextObject])) {
        o= [self objectForKey:k];
        [k encodeWithJSONEncoder:encoder];
        CJSONEncoderPushRawBytes(encoder, ":", 1);
        [o encodeWithJSONEncoder:encoder];
    }
    while((k= [e nextObject])) {
        o= [self objectForKey:k];
        CJSONEncoderPushRawBytes(encoder, ",", 1);
        [k encodeWithJSONEncoder:encoder];
        CJSONEncoderPushRawBytes(encoder, ":", 1);
        [o encodeWithJSONEncoder:encoder];
    }
    CJSONEncoderPushRawBytes(encoder, "}", 1);
}
@end

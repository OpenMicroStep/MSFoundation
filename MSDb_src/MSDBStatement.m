//
//  MSDBStatement.m
//  _MicroStep
//
//  Created by Vincent Rouillé on 25/11/2014.
//
//

#import "MSDb_Private.h"

@implementation MSDBStatement
- (BOOL)bindObjects:(NSArray *)bindings
{
    BOOL ret= YES;
    id binding;
    MSUInt parameterIndex= 0;
    NSEnumerator *e= [bindings objectEnumerator];
    while(ret && (binding= [e nextObject])) {
        // TODO: Extend object with MSDBBinding category to do the binding
        if(binding == MSNull) {
            ret= [self bindNullAt:parameterIndex];
        } else if([binding isKindOfClass:[NSString class]]) {
            ret= [self bindString:binding at:parameterIndex];
        } else if([binding isKindOfClass:[MSBuffer class]]) {
            ret= [self bindBuffer:binding at:parameterIndex];
        } else if([binding isKindOfClass:[MSDecimal class]]) {
            ret= [self bindString:[binding description] at:parameterIndex];
        } else if([binding isKindOfClass:[NSNumber class]]) {
            ret= [self bindNumber:binding at:parameterIndex];
        } else if([binding isKindOfClass:[MSDate class]]) {
            ret= [self bindDate:binding at:parameterIndex];
        } else {
            ASSIGN(_lastError, ([NSString stringWithFormat:@"bindObjects failed, unknown class %@", [binding class]]));
            ret= NO;
        }
        ++parameterIndex;
    }
    return ret;
}
- (BOOL)bindChar:           (MSChar)value at:(MSUInt)parameterIndex { (void)value; (void)parameterIndex; return NO; }
- (BOOL)bindByte:           (MSByte)value at:(MSUInt)parameterIndex { (void)value; (void)parameterIndex; return NO; }
- (BOOL)bindShort:         (MSShort)value at:(MSUInt)parameterIndex { (void)value; (void)parameterIndex; return NO; }
- (BOOL)bindUnsignedShort:(MSUShort)value at:(MSUInt)parameterIndex { (void)value; (void)parameterIndex; return NO; }
- (BOOL)bindInt:             (MSInt)value at:(MSUInt)parameterIndex { (void)value; (void)parameterIndex; return NO; }
- (BOOL)bindUnsignedInt:    (MSUInt)value at:(MSUInt)parameterIndex { (void)value; (void)parameterIndex; return NO; }
- (BOOL)bindLong:           (MSLong)value at:(MSUInt)parameterIndex { (void)value; (void)parameterIndex; return NO; }
- (BOOL)bindUnsignedLong:  (MSULong)value at:(MSUInt)parameterIndex { (void)value; (void)parameterIndex; return NO; }
- (BOOL)bindFloat:           (float)value at:(MSUInt)parameterIndex { (void)value; (void)parameterIndex; return NO; }
- (BOOL)bindDouble:         (double)value at:(MSUInt)parameterIndex { (void)value; (void)parameterIndex; return NO; }
- (BOOL)bindDate:          (MSDate *)date at:(MSUInt)parameterIndex { (void)date;  (void)parameterIndex; return NO; }
- (BOOL)bindNumber:      (NSNumber*)value at:(MSUInt)parameterIndex
{
    MSChar type = *[value objCType] ;
    switch (type) {
        case 'c': return [self bindChar:[value charValue] at:parameterIndex] ;
        case 'C': return [self bindByte:[value unsignedCharValue] at:parameterIndex] ;
        case 's': return [self bindShort:[value shortValue] at:parameterIndex] ;
        case 'S': return [self bindUnsignedShort:[value unsignedShortValue] at:parameterIndex] ;
        case 'i': return [self bindInt:[value intValue] at:parameterIndex] ;
        case 'I': return [self bindUnsignedInt:[value unsignedIntValue] at:parameterIndex] ;
        case 'l': return [self bindLong:[value longValue] at:parameterIndex] ;
        case 'L': return [self bindUnsignedLong:[value unsignedLongValue] at:parameterIndex] ;
        case 'q': return [self bindLong:[value longLongValue] at:parameterIndex] ;
        case 'Q': return [self bindUnsignedLong:[value unsignedLongLongValue] at:parameterIndex] ;
        case 'f': return [self bindFloat:[value floatValue] at:parameterIndex] ;
        case 'd': return [self bindDouble:[value doubleValue] at:parameterIndex] ;
        default: return [self bindString:[value description] at:parameterIndex];
    }
}
- (BOOL)bindString:     (NSString*)string at:(MSUInt)parameterIndex { (void)string;(void)parameterIndex; return NO; }
- (BOOL)bindBuffer:     (MSBuffer*)buffer at:(MSUInt)parameterIndex { (void)buffer;(void)parameterIndex; return NO; }
- (BOOL)bindNullAt:(MSUInt)parameterIndex { (void)parameterIndex; return NO; }

- (MSDBResultSet *)fetch { return [self notImplemented:_cmd]; }
- (MSInt)execute { [self notImplemented:_cmd]; return NO; }

- (NSString *)lastError { return _lastError; }
@end

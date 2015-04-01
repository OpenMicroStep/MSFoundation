//
//  MSDBStatement.m
//  _MicroStep
//
//  Created by Vincent Rouillé on 25/11/2014.
//
//

#import "MSDatabase_Private.h"

@implementation MSDBStatement

- (id)initWithRequest:(NSString *)request withDatabaseConnection:(MSDBConnection *)connection
{
  if((self= [super initWithDatabaseConnection:connection])) {
    ASSIGN(_request, request);
  }
  return self;
}

- (void)dealloc
{
  RELEASE(_request);
  [super dealloc];
}

- (BOOL)bindObjects:(NSArray *)bindings
{
    BOOL ret= YES;
    NSEnumerator *e; id obj;
    MSUInt parameterIndex= 0;
    for(e= [bindings objectEnumerator]; (ret && (obj= [e nextObject]));) {
        ret= [self bindObject:obj at:parameterIndex];
        ++parameterIndex;
    }
    return ret;
}

- (BOOL)bindObject:               (id)obj at:(MSUInt)parameterIndex
{
    BOOL ret;
    // TODO: Extend object with MSDBBinding category to do the binding
    if(obj == MSNull) {
        ret= [self bindNullAt:parameterIndex];
    } else if([obj isKindOfClass:[NSString class]]) {
        ret= [self bindString:obj at:parameterIndex];
    } else if([obj isKindOfClass:[MSBuffer class]]) {
        ret= [self bindBuffer:obj at:parameterIndex];
    } else if([obj isKindOfClass:[MSDecimal class]]) {
        ret= [self bindString:[obj description] at:parameterIndex];
    } else if([obj isKindOfClass:[NSNumber class]]) {
        ret= [self bindNumber:obj at:parameterIndex];
    } else if([obj isKindOfClass:[MSDate class]]) {
        ret= [self bindDate:obj at:parameterIndex];
    } else {
        ASSIGN(_lastError, [NSString stringWithFormat:@"Unknown class"]);
        ret= NO;
    }
    //NSLog(@"bindObject:(%@*)%@ at:%u", [obj class], obj, parameterIndex);
    if(!ret) {
        if(!_lastError) ASSIGN(_lastError, @"Unknown error");
        [self error:_cmd desc:[NSString stringWithFormat:@"bindObject:(%@*)obj at:%u failed -> %@", [obj class], parameterIndex, _lastError]];
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

- (void)error:(SEL)inMethod desc:(NSString *)desc
{
    desc= [NSString stringWithFormat:@"%@-> %@", NSStringFromSelector(inMethod), desc];
    ASSIGN(_lastError, desc);
}

- (NSString *)lastError { return [NSString stringWithFormat:@"%@\nrequest = %@", _lastError, _request]; }
@end

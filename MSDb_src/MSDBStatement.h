//
//  MSDBStatement.h
//  _MicroStep
//
//  Created by Vincent Rouillé on 25/11/2014.
//
//

@interface MSDBStatement : MSDBOperation {
@private
  NSString *_request;
  NSString *_lastError;
}

- (id)initWithRequest:(NSString *)request withDatabaseConnection:(MSDBConnection *)connection ;
- (BOOL)bindObjects:(NSArray *)bindings;
- (BOOL)bindObject:               (id)obj at:(MSUInt)parameterIndex ;
- (BOOL)bindChar:           (MSChar)value at:(MSUInt)parameterIndex ;
- (BOOL)bindByte:           (MSByte)value at:(MSUInt)parameterIndex ;
- (BOOL)bindShort:         (MSShort)value at:(MSUInt)parameterIndex ;
- (BOOL)bindUnsignedShort:(MSUShort)value at:(MSUInt)parameterIndex ;
- (BOOL)bindInt:             (MSInt)value at:(MSUInt)parameterIndex ;
- (BOOL)bindUnsignedInt:    (MSUInt)value at:(MSUInt)parameterIndex ;
- (BOOL)bindLong:           (MSLong)value at:(MSUInt)parameterIndex ;
- (BOOL)bindUnsignedLong:  (MSULong)value at:(MSUInt)parameterIndex ;
- (BOOL)bindFloat:           (float)value at:(MSUInt)parameterIndex ;
- (BOOL)bindDouble:         (double)value at:(MSUInt)parameterIndex ;
- (BOOL)bindDate:          (MSDate *)date at:(MSUInt)parameterIndex ;
- (BOOL)bindNumber:     (NSNumber*)number at:(MSUInt)parameterIndex ;
- (BOOL)bindString:     (NSString*)string at:(MSUInt)parameterIndex ;
- (BOOL)bindBuffer:     (MSBuffer*)buffer at:(MSUInt)parameterIndex ;
- (BOOL)bindNullAt:(MSUInt)parameterIndex;

- (MSDBResultSet *)fetch;
- (MSInt)execute;

- (NSString *)lastError;
@end

@interface MSDBStatement (ForImplementations)
- (void)error:(NSString *)desc;
@end

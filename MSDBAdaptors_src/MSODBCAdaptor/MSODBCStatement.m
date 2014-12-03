//
//  MSOBDCStatement.m
//  _MicroStep
//
//  Created by Vincent Rouillé on 28/11/2014.
//
//

#import "MSODBCAdaptorKit.h"

#define ODBC_SUCCEEDED_RET(METHOD, RET) ({ BOOL __b__ = SQL_SUCCEEDED(RET); if(!__b__) [self error:_cmd desc:@#METHOD @" failed" ret:RET]; __b__; })
#define ODBC_SUCCEEDED(METHOD, ARGS...) ({ SQLRETURN __r__ = METHOD(ARGS); BOOL __b__ = SQL_SUCCEEDED(__r__); if(!__b__) [self error:_cmd desc:@#METHOD @" failed" ret:__r__]; __b__; })

#define BIND_PARAM(name, type, c_type, sql_type, sql_size) \
-(BOOL)name:(type)value at:(MSUInt)parameterIndex { \
    if(parameterIndex < _bindSize) { \
        type *pValue= &((_bindInfos + parameterIndex)->u._ ## type); \
        *pValue= value; \
        return ODBC_SUCCEEDED(SQLBindParameter, _stmt, (SQLUSMALLINT)(parameterIndex + 1), SQL_PARAM_INPUT, c_type, sql_type, sql_size, 0, (SQLPOINTER)pValue, (SQLLEN)sizeof(value), NULL); \
    } \
    return NO; \
}

const SQLLEN indNULL = SQL_NULL_DATA;

@implementation MSODBCStatement

- (void)error:(SEL)inMethod desc:(NSString *)desc ret:(SQLRETURN)returnedValue
{
    SQLSMALLINT i = 0;
    SQLINTEGER native;
    SQLCHAR state[7];
    SQLCHAR text[1024];
    SQLSMALLINT len;
    SQLRETURN ret;
    NSMutableString *error;
    
    error= [NSMutableString stringWithFormat:@"%@-> %@:%lld ", NSStringFromSelector(inMethod), desc, (MSLong)returnedValue];
    do
    {
        ret = SQLGetDiagRec(SQL_HANDLE_STMT, _stmt, ++i, state, &native, text,sizeof(text), &len );
        if(ret == SQL_SUCCESS_WITH_INFO && len) {
            SQLCHAR *longText= MSMalloc(sizeof(SQLCHAR) * len, "error:desc:handleType:handle:");
            ret= SQLGetDiagRec(SQL_HANDLE_STMT, _stmt, ++i, state, &native, longText,len, &len);
            [error appendFormat:@"%s:%d:%d:%s;", state, (int)i, (int)native, longText];
            MSFree(longText, "error:desc:handleType:handle:");
        } else if (SQL_SUCCEEDED(ret)) {
            [error appendFormat:@"%s:%d:%d:%s;", state, (int)i, (int)native, text];
        }
    }
    while( ret == SQL_SUCCESS );
    
    ASSIGN(_lastError, error);
}

- (id)initWithStatement:(SQLHSTMT)stmt withConnection:(MSODBCConnection *)connection
{
    SQLSMALLINT numParams;
    if(!SQL_SUCCEEDED(SQLNumParams(stmt, &numParams))) {
        RELEAZEN(self);
    }
    else if((self = [super initWithDatabaseConnection:connection])) {
        _stmt= stmt;
        _bindSize= (MSUInt)numParams;
        _bindInfos= MSCalloc(_bindSize, sizeof(MSODBCBindParamInfo), "Alloc ODBCStatement bind infos");
    }
    return self;
}

- (void)terminateOperation
{
    if(_bindInfos) {
        MSODBCBindParamInfo *cur= _bindInfos;
        MSODBCBindParamInfo *end= _bindInfos + _bindSize;
        while (cur < end) {
            switch (cur->type) {
                case SQL_C_CHAR:
                case SQL_C_BINARY:
                    [cur->u._id release];
                    break;
                    
                case SQL_C_TIMESTAMP:
                    MSFree(cur->u._timestamp, "Free SQL_TIMESTAMP_STRUCT allocated by bindDate");
                    break;
                    
                default:
                    break;
            }
            ++cur;
        }
        MSFree(_bindInfos, "Free ODBCStatement bind infos");
        _bindInfos= NULL;
    }
    if(_stmt)
        ODBC_SUCCEEDED(SQLFreeHandle, SQL_HANDLE_STMT, _stmt);
    _stmt= NULL;
    [super terminateOperation] ;
}

BIND_PARAM(bindChar, MSChar, SQL_C_STINYINT, SQL_TINYINT, 3);
BIND_PARAM(bindByte, MSByte, SQL_C_TINYINT, SQL_TINYINT, 3);
BIND_PARAM(bindShort, MSShort, SQL_C_SSHORT, SQL_SMALLINT, 5);
BIND_PARAM(bindUnsignedShort, MSUShort, SQL_C_SHORT, SQL_SMALLINT, 5);
BIND_PARAM(bindInt, MSInt, SQL_C_LONG, SQL_INTEGER, 10);
BIND_PARAM(bindUnsignedInt, MSUInt, SQL_C_ULONG, SQL_INTEGER, 10);
BIND_PARAM(bindLong, MSLong, SQL_C_SBIGINT, SQL_BIGINT, 19);
BIND_PARAM(bindUnsignedLong, MSULong, SQL_C_UBIGINT, SQL_BIGINT, 20);
BIND_PARAM(bindFloat, float, SQL_C_FLOAT, SQL_FLOAT, 15);
BIND_PARAM(bindDouble, double, SQL_C_DOUBLE, SQL_DOUBLE, 15);

- (BOOL)bindDate:          (MSDate *)date at:(MSUInt)parameterIndex
{
    if(parameterIndex < _bindSize) {
        SQL_TIMESTAMP_STRUCT* pValue= MSCalloc(1, sizeof(SQL_TIMESTAMP_STRUCT), "Alloc SQL_TIMESTAMP_STRUCT for bindDate");
        pValue->year= (SQLSMALLINT)[date yearOfCommonEra];
        pValue->month= (SQLUSMALLINT)[date monthOfYear];
        pValue->day= (SQLUSMALLINT)[date dayOfMonth];
        pValue->hour= (SQLUSMALLINT)[date hourOfDay];
        pValue->minute= (SQLUSMALLINT)[date minuteOfHour];
        pValue->second= (SQLUSMALLINT)[date secondOfDay];
        pValue->fraction= 0;
        (_bindInfos + parameterIndex)->u._timestamp= pValue;
        return ODBC_SUCCEEDED(SQLBindParameter, _stmt, (SQLUSMALLINT)(parameterIndex + 1), SQL_PARAM_INPUT, SQL_C_TIMESTAMP, SQL_TIMESTAMP, 19, 0, (SQLPOINTER)pValue, (SQLLEN)sizeof(SQL_TIMESTAMP_STRUCT), NULL);
    }
    return NO;
}

- (BOOL)bindString:     (NSString*)string at:(MSUInt)parameterIndex
{
    if(parameterIndex < _bindSize) {
        NSData *data= [(MSODBCConnection *)_connection sqlDataFromString:string];
        NSUInteger length= [data length];
        MSODBCBindParamInfo *bindInfo= _bindInfos + parameterIndex;
        bindInfo->u._id= [data retain];
        bindInfo->len= (SQLLEN)length;
        return ODBC_SUCCEEDED(SQLBindParameter, _stmt, (SQLUSMALLINT)(parameterIndex + 1), SQL_PARAM_INPUT, SQL_C_CHAR, SQL_VARCHAR, length, 0, (SQLPOINTER)[data bytes], bindInfo->len, &bindInfo->len);
    }
    return NO;
}

- (BOOL)bindBuffer:     (MSBuffer*)buffer at:(MSUInt)parameterIndex
{
    if(parameterIndex < _bindSize) {
        NSUInteger length= [buffer length];
        MSODBCBindParamInfo *bindInfo= _bindInfos + parameterIndex;
        bindInfo->u._id= [buffer retain];
        bindInfo->len= (SQLLEN)length;
        return ODBC_SUCCEEDED(SQLBindParameter, _stmt, (SQLUSMALLINT)(parameterIndex + 1), SQL_PARAM_INPUT, SQL_C_BINARY, SQL_BINARY, length, 0, (SQLPOINTER)[buffer bytes], bindInfo->len, &bindInfo->len);
    }
    return NO;
}

- (BOOL)bindNullAt:(MSUInt)parameterIndex
{
    return parameterIndex < _bindSize &&
           ODBC_SUCCEEDED(SQLBindParameter, _stmt, (SQLUSMALLINT)(parameterIndex + 1), SQL_PARAM_INPUT, 0, 0, 0, 0, NULL, 0, (SQLLEN*)&indNULL);
}

- (MSDBResultSet *)fetch
{
    if (ODBC_SUCCEEDED(SQLExecute, _stmt))
        return AUTORELEASE([ALLOC(MSODBCResultSet) initWithStatement:_stmt withConnection:(MSODBCConnection *)_connection withMSStatement:self]);
    return nil;
}

- (MSInt)execute
{
    SQLLEN rowCount;
    SQLRETURN ret= SQLExecute(_stmt);
    if(ret == SQL_NO_DATA)
        return 0;
    if (ODBC_SUCCEEDED_RET(SQLExecute, ret)
     && ODBC_SUCCEEDED(SQLRowCount, _stmt, &rowCount))
        return (MSInt)rowCount;
    return MSSQL_ERROR;
}

- (NSString *)lastError
{
    return _lastError;
}
@end

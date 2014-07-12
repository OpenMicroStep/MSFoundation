/*
 
 MSODBCResultSet.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Frederic Olivi : fred.olivi@free.fr
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

#import "MSODBCResultSet.h"

#ifdef WIN32
#import "../_MSDBGenericConnection.h"
#else
#import "_MSDBGenericConnection.h"
#import <iODBC/sql.h>
#import <iODBC/sqlext.h>
#import <iODBC/sqltypes.h>
#import <iODBC/sqlucode.h>
#endif

#import "MSODBCConnection.h"
#import "_MSODBCResultSetPrivate.h"


#ifndef CHAR_BUFFERSIZE

#define NUM_BUFFERSIZE	80
#define CHAR_BUFFERSIZE 1024
#define LOB_BUFFERSIZE 32768

#define ODBC_RESULT_NOT_INITIALIZED	0
#define ODBC_POSSIBLE_RESULT		1
#define ODBC_NO_MORE_RESULTS		2

#define ODBC_NULL		-1
#define ODBC_CHAR		0
#define ODBC_FLOAT		1
#define ODBC_DOUBLE		2
#define ODBC_INTEGER	3
#define ODBC_BLOB		4
#define ODBC_NUMERIC	5
#define ODBC_DATE		6
#define ODBC_TIME		7
#define ODBC_DATETIME	8

#endif

typedef union
{
	BOOL _bool;
	MSChar _char;
	MSByte  _byte;
	MSShort _short;
	MSUShort _ushort;
	MSInt _int; 
	MSUInt _uint; 
	float _float;
	double _double;
	MSLong _bigint;
	MSULong _ubigint;
	SQL_DATE_STRUCT _date;
	SQL_TIME_STRUCT _time;
	SQL_TIMESTAMP_STRUCT _timestamp;
	SQL_NUMERIC_STRUCT _numeric;
	SQLGUID _guid;
	SQL_INTERVAL_STRUCT _interval;
} SQL_RESULT_VALUE_STRUCT;

typedef	struct
{
	BOOL isNull;
	SQL_RESULT_VALUE_STRUCT value;	
} SQLRESULT;



@implementation MSODBCResultSet

- (void)dealloc
{
    DESTROY(_values) ;
    [super dealloc] ;
}


-(BOOL) _charBuffer:(CBuffer *)msBuff AtIndex:(short)index
{
    SQLRETURN sts;
    SQLLEN indicator;
    char buff[CHAR_BUFFERSIZE];
    BOOL fetchNextData = TRUE;
    BOOL dataAvailable = YES;


    if(!msBuff) {
        MSRaise(NSMallocException, @"Impossible to allow %lu bytes buffer.",(unsigned long)CHAR_BUFFERSIZE) ;
        return NO;
    }

    while (fetchNextData)  {
        sts = SQLGetData(_hstmt, index+1, SQL_C_CHAR,buff, CHAR_BUFFERSIZE-1, &indicator);

        if (indicator == SQL_NULL_DATA)	{
            dataAvailable=NO;
            break;
        }
        if (sts == SQL_NO_DATA) {
            break;
        }

        fetchNextData = (sts != SQL_NO_DATA) && (indicator != SQL_NULL_DATA) ;
        CBufferAppendCString( msBuff, buff);

    }

    return dataAvailable;
}


-(BOOL) _getBuffer:(CBuffer *)msBuff AtIndex:(short)index
{
    SQLRETURN sts;
    SQLLEN indicator;
    char buff[LOB_BUFFERSIZE];
    SQLINTEGER NumBytes;
    BOOL fetchNextData = TRUE;
    BOOL dataAvailable = YES;


    if(!msBuff) {
        MSRaise(NSMallocException, @"Impossible to allow %lu bytes buffer.",(unsigned long)LOB_BUFFERSIZE) ;
        return NO;
    }

    while (fetchNextData)  {

        sts = SQLGetData(_hstmt, index+1, SQL_C_BINARY,buff, LOB_BUFFERSIZE, &indicator);

        if (sts == SQL_NO_DATA) {break;}

        if (indicator == SQL_NULL_DATA)	{dataAvailable=NO;break;}
        fetchNextData = (sts != SQL_NO_DATA) && (indicator != SQL_NULL_DATA) ;

        NumBytes = (indicator > LOB_BUFFERSIZE) || (indicator == SQL_NO_TOTAL) ?	LOB_BUFFERSIZE : indicator;
        CBufferAppendBytes(msBuff, buff, NumBytes);

    }

    return dataAvailable;
}



-(NSString *) stringAtIndex:(int)index
{
    MSBuffer *msBuff = MSCreateBuffer(CHAR_BUFFERSIZE);

    if(!msBuff) {
        MSRaise(NSMallocException, @"Impossible to allow %lu bytes buffer.",(unsigned long)CHAR_BUFFERSIZE) ;
        return @"";
    }

    if (![self _charBuffer:(CBuffer *)msBuff AtIndex:index]) {	RELEASE(msBuff); return @""; }
    AUTORELEASE(msBuff);
    
    return [(_MSDBGenericConnection *)_connection stringWithSQLBuffer:msBuff] ;
}


BOOL _getSQLResult(HSTMT stmt, NSUInteger column, SQLSMALLINT type,SQLLEN size, SQLRESULT* sqlResult)
{
    SQLLEN	indicator;
    SQLRETURN   sts;
    memset(sqlResult, 0, sizeof(SQLRESULT));

    sts = SQLGetData(stmt, column+1, type,&(sqlResult->value),size, &indicator);
    sqlResult->isNull =  (indicator==SQL_NULL_DATA) ;

    return ((sts == SQL_SUCCESS) ? YES : NO) ;
}



BOOL _getResultAsChar(HSTMT stmt, NSUInteger column,char *buff, BOOL *isNull,int *len)
{
    SQLLEN	indicator;
    SQLRETURN   sts;

    sts = SQLGetData(stmt, column+1, SQL_C_CHAR,buff,NUM_BUFFERSIZE, &indicator);

//    NSLog(@"SQLGetData sts = %u",sts);

    *len = 0;
    *isNull = (indicator==SQL_NULL_DATA) ;
    if (*isNull == NO) {*len = indicator;}
    return ((sts == SQL_SUCCESS) ? YES : NO) ;
}

void fillTypes(SQLSMALLINT sqlType, _MSODBCType* type)
{
    switch (sqlType)
    {
        case SQL_CHAR:
        case SQL_VARCHAR:
        case SQL_LONGVARCHAR:
            type->cType = SQL_C_CHAR;
            type->oType = ODBC_CHAR;
            //NSLog(@"SQL_CHAR %lu / %u",(unsigned long)type->size,type->decimalSize);
            break;
        case SQL_WCHAR:
        case SQL_WVARCHAR:
        case SQL_WLONGVARCHAR:
            type->cType = SQL_C_TCHAR;
            type->oType = ODBC_CHAR;
            //NSLog(@"SQL_WCHAR %lu / %u",(unsigned long)type->size,type->decimalSize);
            break;
        case SQL_DECIMAL: //Not sure ... need some tests
            type->cType = SQL_C_DOUBLE;
            type->oType = ODBC_FLOAT;
            //NSLog(@"SQL_DECIMAL %lu / %u",(unsigned long)type->size,type->decimalSize);
            break;
        case SQL_NUMERIC:
            type->cType =SQL_C_NUMERIC;
            type->oType =ODBC_NUMERIC;
            //NSLog(@"SQL_NUMERIC %lu / %u",(unsigned long)type->size,type->decimalSize);
            break;
        case SQL_SMALLINT:
            type->cType = SQL_C_SSHORT;
            type->oType = ODBC_INTEGER;
            //NSLog(@"SQL_SMALLINT %lu / %u",(unsigned long)type->size,type->decimalSize);
            break;
        case SQL_INTEGER:
            type->cType = SQL_C_SLONG;
            type->oType = ODBC_INTEGER;
            //NSLog(@"SQL_INTEGER %lu / %u",(unsigned long)type->size,type->decimalSize);
            break;

        case SQL_REAL:
            type->cType = SQL_C_FLOAT;
            type->oType = ODBC_FLOAT;
            //NSLog(@"SQL_REAL %lu / %u",(unsigned long)type->size,type->decimalSize);
            break;
        case SQL_FLOAT:
            type->cType = SQL_C_FLOAT;
            type->oType = ODBC_FLOAT;
            //NSLog(@"SQL_FLOAT %lu / %u",(unsigned long)type->size,type->decimalSize);
            break;
        case SQL_DOUBLE:
            type->cType = SQL_C_DOUBLE;
            type->oType = ODBC_DOUBLE;
            //NSLog(@"SQL_DOUBLE %lu / %u",(unsigned long)type->size,type->decimalSize);
            break;
        case SQL_BIT:
            type->cType =  SQL_C_SHORT; //Can't use SQL_C_Bit  Oracle : 0-9 not 0 or 1
            type->oType = ODBC_INTEGER;
            //NSLog(@"SQL_BIT %lu / %u",(unsigned long)type->size,type->decimalSize);
            break;
        case SQL_TINYINT:
            type->cType =  SQL_C_STINYINT;
            type->oType = ODBC_INTEGER;
            //NSLog(@"SQL_TINYINT %lu / %u",(unsigned long)type->size,type->decimalSize);
            break;
        case SQL_BIGINT:
            type->cType =  SQL_C_SBIGINT;
            type->oType = ODBC_INTEGER;
            //NSLog(@"SQL_BIGINT %lu / %u",(unsigned long)type->size,type->decimalSize);
            break;
        case SQL_BINARY:
        case SQL_VARBINARY:
        case SQL_LONGVARBINARY:
            type->cType =   SQL_C_BINARY;
            type->oType = ODBC_BLOB;
            //NSLog(@"SQL_BINARY %lu",(unsigned long)type->size);
            break;
        case SQL_TYPE_DATE:
            type->cType =   SQL_C_TYPE_DATE;
            type->oType = ODBC_DATE;
            //NSLog(@"SQL_TYPE_DATE %lu",(unsigned long)type->size);
            break;
        case SQL_TYPE_TIME:
            type->cType =   SQL_C_TYPE_TIME;
            type->oType = ODBC_TIME;
            //NSLog(@"SQL_TYPE_TIME %lu",(unsigned long)type->size);
            break;
        case SQL_TYPE_TIMESTAMP:
            type->cType =   SQL_C_TYPE_TIMESTAMP;
            type->oType = ODBC_DATETIME;
            //NSLog(@"SQL_TYPE_TIMESTAMP %lu",(unsigned long)type->size);
            break;
            /* 	    	case SQL_INTERVAL_MONTH:
            strcpy(tmp -> szTypeName, "SQL_INTERVAL_MONTH");
            tmp -> nCType = SQL_C_INTERVAL_MONTH;
            break;
        case SQL_INTERVAL_YEAR:
            strcpy(tmp -> szTypeName, "SQL_INTERVAL_YEAR");
            tmp -> nCType = SQL_C_INTERVAL_YEAR;
            break;
        case SQL_INTERVAL_YEAR_TO_MONTH:
            strcpy(tmp -> szTypeName, "SQL_INTERVAL_YEAR_TO_MONTH");
            tmp -> nCType = SQL_C_INTERVAL_YEAR_TO_MONTH;
            break;
        case SQL_INTERVAL_DAY:
            strcpy(tmp -> szTypeName, "SQL_INTERVAL_DAY");
            tmp -> nCType = SQL_C_INTERVAL_DAY;
            break;
        case SQL_INTERVAL_HOUR:
            strcpy(tmp -> szTypeName, "SQL_INTERVAL_HOUR");
            tmp -> nCType = SQL_C_INTERVAL_HOUR;
            break;
        case SQL_INTERVAL_MINUTE:
            strcpy(tmp -> szTypeName, "SQL_INTERVAL_MINUTE");
            tmp -> nCType = SQL_C_INTERVAL_MINUTE;
            break;
        case SQL_INTERVAL_SECOND:
            strcpy(tmp -> szTypeName, "SQL_INTERVAL_SECOND");
            tmp -> nCType = SQL_C_INTERVAL_SECOND;
            break;
        case SQL_INTERVAL_DAY_TO_HOUR:
            strcpy(tmp -> szTypeName, "SQL_INTERVAL_DAY_TO_HOUR");
            tmp -> nCType = SQL_C_INTERVAL_DAY_TO_HOUR;
            break;
        case SQL_INTERVAL_DAY_TO_MINUTE:
            strcpy(tmp -> szTypeName, "SQL_INTERVAL_DAY_TO_MINUTE");
            tmp -> nCType = SQL_C_INTERVAL_DAY_TO_MINUTE;
            break;
        case SQL_INTERVAL_DAY_TO_SECOND:
            strcpy(tmp -> szTypeName, "SQL_INTERVAL_DAY_TO_SECOND");
            tmp -> nCType = SQL_C_INTERVAL_DAY_TO_SECOND;
            break;
        case SQL_INTERVAL_HOUR_TO_MINUTE:
            strcpy(tmp -> szTypeName, "SQL_INTERVAL_HOUR_TO_MINUTE");
            tmp -> nCType = SQL_C_INTERVAL_HOUR_TO_MINUTE;
            break;
        case SQL_INTERVAL_HOUR_TO_SECOND:
            strcpy(tmp -> szTypeName, "SQL_INTERVAL_HOUR_TO_SECOND");
            tmp -> nCType = SQL_C_INTERVAL_HOUR_TO_SECOND;
            break;
        case SQL_INTERVAL_MINUTE_TO_SECOND:
            strcpy(tmp -> szTypeName, "SQL_INTERVAL_MINUTE_TO_SECOND");
            tmp -> nCType = SQL_C_INTERVAL_MINUTE_TO_SECOND;
            break;
        case SQL_GUID:
            strcpy(tmp -> szTypeName, "SQL_GUID");
            tmp -> nCType = SQL_C_CHAR;
            break; */
        default:
            NSLog(@"Unknown result set column data type %i",sqlType);
    }

}

- (id)initWithStatement:(SQLHSTMT)statement connection:(MSDBConnection *)connection
{
    if ((self = [super initWithDatabaseConnection:connection])) {
        short count = 0;//
        SQLTCHAR colName[256];
        SQLSMALLINT colType;
        SQLULEN colSize;
        SQLSMALLINT decimalSize;
        SQLSMALLINT colNullable;
        MSArray *keys ;
        _MSODBCType *types ;
        int i = 0;

        if (!SQL_SUCCEEDED(SQLNumResultCols(statement, &count))) { RELEASE(self) ; return nil ; }

        if (!(keys = MSCreateArray(count))) { RELEASE(self) ; return nil ; }
        if (!(types = (_MSODBCType *)MSMalloc(sizeof(_MSODBCType)*count, "-[MSODBCResultSet initWithStatement:connection:]"))) { RELEASE(keys) ; RELEASE(self) ; return nil ; }

        for (i = 0 ; i < count ; i++) {
            NSString *s = nil ;
            if (SQL_SUCCEEDED(SQLDescribeCol(statement, i+1, (SQLTCHAR *) colName,sizeof(colName), NULL, &colType, &colSize, &decimalSize,&colNullable)))
            {
                s = [(_MSDBGenericConnection *)_connection stringWithSQLCString:(char *)colName] ;
                types[i].type = colType ;
                types[i].size = colSize ;
                types[i].decimalSize = decimalSize ;
                types[i].nullable = (colNullable == SQL_NULLABLE ? YES : NO) ;

                //NSLog(@"SQLDescribeCol %s type=%i size=%u decimalSize=%u",colName, types[i].type ,(int)types[i].size,types[i].decimalSize);

                fillTypes(colType,&types[i]);

            }
            if (!s) { RELEASE(keys) ; RELEASE(self) ; return nil ; }
            MSAAdd(keys, s) ;
        }
        _columnsDescription = RETAIN([_MSODBCRowKeys rowKeysWithKeys:keys]) ;
        ((_MSODBCRowKeys *) _columnsDescription)->_types = types ; // possible because _MSODBCRowKeys is a private subclass.

        RELEASE(keys) ;
        if (!_columnsDescription) { RELEASE(self) ; return nil ; }

        _hstmt = statement ;
        _state = ODBC_RESULT_NOT_INITIALIZED ;
    }
    return self ;
}

- (void)terminateOperation
{
    if ([self isActive]) {
        if (_hstmt) {SQLFreeHandle(SQL_HANDLE_STMT, _hstmt);}
        _hstmt = NULL ;
        _state = ODBC_NO_MORE_RESULTS ;
        [(_MSDBGenericConnection *)_connection unregisterOperation:self] ;
        [super terminateOperation] ;
    }
}

- (BOOL)nextRow
{
    if (_state != ODBC_NO_MORE_RESULTS && (SQL_SUCCEEDED(SQLFetch(_hstmt)))) {
        _state = ODBC_POSSIBLE_RESULT ;
        return YES ;
    }
    else { _state = ODBC_NO_MORE_RESULTS ; }
    return NO ;
}

- (MSColumnType)typeOfColumn:(NSUInteger)column
{
    if (_hstmt) {
        if (column <  MSACount(_columnsDescription->_keys)) {

            _MSODBCType type =[((_MSODBCRowKeys *)_columnsDescription) typeAtIndex:column];

            switch (type.oType) {
                case ODBC_CHAR:
                    return MSStringColumn ;
                case ODBC_INTEGER:
                case ODBC_FLOAT:
                case ODBC_DOUBLE:
                case ODBC_NUMERIC:
                    return MSNumberColumn ;
                case ODBC_BLOB:
                    return MSDataColumn ;
                case ODBC_NULL:
                    return MSNoValueColumn;
                default:
                    return MSUnknownTypeColumn ;
            }
        }
        MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"try to reach undefined column at index %lu", (unsigned long)column) ;
    }
    MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"terminated request cannot deliver information on columns %lu", (unsigned long)column) ;
    return MSUnknownTypeColumn ;
}


#define _GET_NUMBER_VALUE_METHOD(NAME, TYPE, CONVERT_FUNCTION) \
- (BOOL)get ## NAME ## At:(TYPE *)aValue column:(NSUInteger)column error:(MSInt *)errorPtr \
{ \
	MSInt error = MSNoColumn ; \
	BOOL good = NO ; \
	_MSODBCType type ;\
	char buff[NUM_BUFFERSIZE+1]; \
	BOOL isNull; \
    BOOL convRes; \
    int len; \
    if (_state == ODBC_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; } \
	else if (_state == ODBC_NO_MORE_RESULTS) { error = MSFetchIsOver ; } \
	else if (column <  MSACount(_columnsDescription->_keys)) { \
		type =[((_MSODBCRowKeys *)_columnsDescription) typeAtIndex:column];	\
		switch (type.oType) { \
			case ODBC_INTEGER: \
			case ODBC_FLOAT: \
			case ODBC_DOUBLE: \
			case ODBC_NUMERIC:{ \
				if (_getResultAsChar(_hstmt,column,buff,&isNull,&len)){ \
                    if (isNull) { \
						error = MSNullFetch; \
					} else { \
                        TYPE value; \
                        convRes = CONVERT_FUNCTION(buff,len,&value); \
						if (convRes) { \
							if (aValue) *aValue = value ; \
							error = MSFetchOK ; good = YES ; \
						} \
						else { error = MSNotConverted ; } \
					} \
				}\
				else { error = MSNotConverted ; } \
				break ; \
			}\
			default: \
				error = MSNotConverted ; \
				break ; \
		} \
	} \
	if (errorPtr) *errorPtr = error ; \
	return good ; \
}


//long  MSStrtod(const char *StringPtr, char **stopString, int unusedBase) { return strtod(StringPtr, stopString) ;} 
//float MSStrtof(const char *StringPtr, char **stopString, int unusedBase) { return strtof(StringPtr, stopString) ;} 


_GET_NUMBER_VALUE_METHOD(Char, MSChar,   MSGetChar)
_GET_NUMBER_VALUE_METHOD(Byte, MSByte,   MSGetByte)
_GET_NUMBER_VALUE_METHOD(Short, MSShort, MSGetShort)
//_GET_NUMBER_VALUE_METHOD(UnsignedShort, MSUShort, MSGetUShort)
_GET_NUMBER_VALUE_METHOD(Int, MSInt,  MSGetInt)
_GET_NUMBER_VALUE_METHOD(Long, MSLong,  MSGetLong)
//_GET_NUMBER_VALUE_METHOD(UnsignedLong, MSULong, unsigned long, MSGetULong)
_GET_NUMBER_VALUE_METHOD(Float, float,   MSGetFloat)
_GET_NUMBER_VALUE_METHOD(Double, double, MSGetDouble)




- (BOOL)getDateAt:(MSTimeInterval *)aDate column:(NSUInteger)column error:(MSInt *)errorPtr
{
    MSInt error = MSNoColumn ;
    BOOL good = NO ;
    SQLRESULT result;
    _MSODBCType type ;
    if (_state == ODBC_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; }
    else if (_state == ODBC_NO_MORE_RESULTS) { error = MSFetchIsOver ; }
    else if (column <  MSACount(_columnsDescription->_keys)) {

        type =[((_MSODBCRowKeys *)_columnsDescription) typeAtIndex:column];

        switch (type.oType)
        {
            case ODBC_DATE:
            case ODBC_TIME:
            case ODBC_DATETIME:{
                if (_getSQLResult(_hstmt,column,type.cType,SQL_TIMESTAMP_LEN, &result)) {
                    if (result.isNull) {
                        error = MSNullFetch ;
                    } else {
                        if (aDate) *aDate = timeIntervalFromDate(result.value._timestamp.year, result.value._timestamp.month, result.value._timestamp.day,
                                                                 result.value._timestamp.hour, result.value._timestamp.minute, result.value._timestamp.second) ;
                        error = MSFetchOK ; good = YES ;
                    }
                }
                break ;
            }
            case ODBC_FLOAT:{
                float f;
                if ([self getFloatAt:&f column:column error:&error]) {
                    if (aDate) *aDate = (MSTimeInterval)f ;
                    error = MSFetchOK ; good = YES ;
                }
                break ;
            }
            case ODBC_DOUBLE:{
                double d;
                if ([self getDoubleAt:&d column:column error:&error]) {
                    if (aDate) *aDate = (MSTimeInterval)d ;
                    error = MSFetchOK ; good = YES ;
                }
                break ;
            }

            case ODBC_INTEGER:{
                MSLong l;
                if ([self getLongAt:&l column:column error:&error]) {
                    if (aDate) *aDate = (MSTimeInterval)l ;
                    error = MSFetchOK ; good = YES ;
                }
                break;
            }

            case ODBC_CHAR:{
                MSBuffer *msBuff = MSCreateBuffer(CHAR_BUFFERSIZE);

                if(!msBuff) {
                    MSRaise(NSMallocException, @"Impossible to alloc %lu bytes buffer.",(unsigned long)CHAR_BUFFERSIZE) ;
                    error = MSNotConverted ;
                    break ;
                }

                if ([self _charBuffer:(CBuffer *)msBuff AtIndex:column]) {
                    if (aDate  && [msBuff length]) {
                        if ((good = MSGetSqlDateFromBytes(msBuff,[msBuff length], aDate))) { error = MSFetchOK ; }
                        else { error = MSNotConverted ; }
                    }
                    else {error = MSNullFetch ;}
                }

                RELEASE(msBuff);

                break ;
            }
            case ODBC_NULL:
                error = MSNullFetch ;
                break ;

            default:
                error = MSNotConverted ;
                break ;
        }
    }
    if (errorPtr) *errorPtr = error ;
    return good ;
}


- (BOOL)getStringAt:(MSString*)aString column:(NSUInteger)column error:(MSInt*)errorPtr
{
    _MSODBCType type ;

    MSInt error = MSNoColumn ;
    BOOL good = NO ;

    if (_state == ODBC_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; }
    else if (_state == ODBC_NO_MORE_RESULTS) { error = MSFetchIsOver ; }
    else if (column <  MSACount(_columnsDescription->_keys)) {
        type =[((_MSODBCRowKeys *)_columnsDescription) typeAtIndex:column];
        switch (type.oType) {
            case ODBC_INTEGER:
            case ODBC_FLOAT:
            case ODBC_DOUBLE:
            case ODBC_NUMERIC:
            case ODBC_CHAR:
            {
                MSBuffer *msBuff = MSCreateBuffer(CHAR_BUFFERSIZE);

                if(!msBuff) {
                    MSRaise(NSMallocException, @"Impossible to allow %lu bytes buffer.",(unsigned long)CHAR_BUFFERSIZE) ;
                    return NO;
                }

                if ([self _charBuffer:(CBuffer *)msBuff AtIndex:column]) {
                    [(_MSDBGenericConnection *)_connection addSQLBuffer:msBuff toString:aString] ;
                    error = MSFetchOK;
                    good = YES;
                    RELEASE(msBuff);
                }
                else {RELEASE(msBuff);error = MSNullFetch;}
            }
                break;

            default:
                error = MSNotConverted ;
                break ;
        }
    }
    if (errorPtr) *errorPtr = error ;
    return good ;
}

- (id)objectAtColumn:(NSUInteger)column
{
    _MSODBCType type ;
    SQLRESULT result;

    if (_state == ODBC_POSSIBLE_RESULT) {
        if (column < MSACount(_columnsDescription->_keys)) {
            NSNumber *keyNumber = [NSNumber numberWithUnsignedLong:column] ;
            id value = nil ;
            if (!_values) {
                _values = [ALLOC(NSMutableDictionary) initWithCapacity:[_columnsDescription count]] ;
            }
            else {
                value = [_values objectForKey:keyNumber] ;
                if (value) return value ;
            }
            type =[((_MSODBCRowKeys *)_columnsDescription) typeAtIndex:column];
            //NSLog(@"types sqltype=%i  cType=%i oType=%i",type.type,type.cType, type.oType);

            switch (type.oType) {


                case ODBC_INTEGER:
                {
                    if (_getSQLResult(_hstmt,column,type.cType,sizeof(MSLong), &result))
                    {
                        value = (result.isNull ? nil : [NSNumber numberWithLongLong:result.value._bigint]) ;
                        if (value) [_values setObject:value forKey:keyNumber] ;
                        return value;
                    }
                    else
                    { MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"unable to read data integer from column at index %lu", (unsigned long)column);return nil; }
                }

                case ODBC_FLOAT:
                {
                    if (_getSQLResult(_hstmt,column,type.cType,0, &result))
                    {
                        value = (result.isNull ? nil : [NSNumber numberWithFloat:result.value._float]) ;
                        if (value) [_values setObject:value forKey:keyNumber] ;
                        return value;
                    }
                    else
                    { MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"unable to read float data from column at index %lu", (unsigned long)column);return nil; }
                }

                case ODBC_DOUBLE:
                {
                    if (_getSQLResult(_hstmt,column,type.cType,0, &result))
                    {
                        value = (result.isNull ? nil : [NSNumber numberWithDouble:result.value._double]) ;
                        if (value) [_values setObject:value forKey:keyNumber] ;
                        return value;
                    }
                    else
                    { MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"unable to read double data from column at index %lu", (unsigned long)column);return nil; }
                }

                case ODBC_NUMERIC:
                {
                    if (type.decimalSize == 0) {
                        if (_getSQLResult(_hstmt,column,SQL_C_SBIGINT,sizeof(MSLong), &result))
                        {
                            value = (result.isNull ? nil : [NSNumber numberWithLongLong:result.value._bigint]) ;
                            if (value) [_values setObject:value forKey:keyNumber] ;
                            return value;
                        }
                    }
                    else {
                        if (_getSQLResult(_hstmt,column,SQL_C_DOUBLE,sizeof(double), &result))
                        {
                            value = (result.isNull ? nil : [NSNumber numberWithDouble:result.value._double]) ;
                            if (value) [_values setObject:value forKey:keyNumber] ;
                            return value;
                        }
                    }
                    MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"unable to read data integer from column at index %lu", (unsigned long)column);return nil;
                }

                case ODBC_CHAR:
                {
                    MSBuffer *msBuff = MSCreateBuffer(CHAR_BUFFERSIZE);

                    if(!msBuff) {
                        MSRaise(NSMallocException, @"Impossible to allow %lu bytes buffer.",(unsigned long)CHAR_BUFFERSIZE) ;
                        return nil;
                    }

                    if (![self _charBuffer:(CBuffer *)msBuff AtIndex:column]) {
                        RELEASE(msBuff);
                        return nil;
                    }
                    AUTORELEASE(msBuff);
                    value = [(_MSDBGenericConnection *)_connection stringWithSQLBuffer:msBuff] ;
                    if (value) [_values setObject:value forKey:keyNumber] ;
                    return value;
                }
                    
                case ODBC_BLOB:{
                    MSBuffer *msBuff = MSCreateBuffer(LOB_BUFFERSIZE);

                    if(!msBuff) {
                        MSRaise(NSMallocException, @"Impossible to allow %lu bytes buffer.",(unsigned long)LOB_BUFFERSIZE) ;
                        return nil;
                    }

                    if (![self _getBuffer:(CBuffer *)msBuff AtIndex:column]) {	RELEASE(msBuff); return nil ; }
                    AUTORELEASE(msBuff);
                    value = [NSData dataWithBytes:msBuff->_buf length:(NSUInteger)[msBuff length]] ;
                    if (value) [_values setObject:value forKey:keyNumber] ;
                    return value;

                }
                case ODBC_DATE:
                case ODBC_TIME:
                case ODBC_DATETIME:
                    if (_getSQLResult(_hstmt,column,type.cType,SQL_TIMESTAMP_LEN, &result)) {
                        //NSLog(@"DateTime = %s",result.value._timestamp);

                        if (result.isNull) return nil;
                        
                        value = [MSDate dateWithYear:result.value._timestamp.year month:result.value._timestamp.month day:result.value._timestamp.day
                                                hour:result.value._timestamp.hour minute:result.value._timestamp.minute second:result.value._timestamp.second] ;
                        if (value) [_values setObject:value forKey:keyNumber] ;
                        return value;
                    }

                    case ODBC_NULL:
                    default:
                        break ;

            }
        }
        else {
            MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"try to reach undefined column at index %lu", (unsigned long)column) ;
        }
    }
    return nil ;
}

- (BOOL)getBufferAt:(MSBuffer *)aBuffer column:(NSUInteger)column error:(MSInt *)errorPtr
{
    _MSODBCType type ;

    MSInt error = MSNoColumn ;
    BOOL good = NO ;

    if (_state == ODBC_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; }
    else if (_state == ODBC_NO_MORE_RESULTS) { error = MSFetchIsOver ; }
    else if (column <  MSACount(_columnsDescription->_keys)) {
        type =[((_MSODBCRowKeys *)_columnsDescription) typeAtIndex:column];
        switch (type.oType) {
            case ODBC_BLOB:
            {
                if ([self _getBuffer:(CBuffer *)aBuffer AtIndex:column]) {
                    error = MSFetchOK;good = YES;
                }
                else {error = MSNullFetch;}
            }
                break;

            default:
                error = MSNotConverted ;
                break ;
        }
    }
    if (errorPtr) *errorPtr = error ;
    return good ;
}

- (MSArray *)allValues
{
    if (_state == ODBC_POSSIBLE_RESULT) {
        NSUInteger columnsCount = MSACount(_columnsDescription->_keys) ;
        MSArray *values = MSCreateArray(columnsCount) ;
        if (columnsCount && values) {
            NSUInteger i ;
            for (i = 0; i < columnsCount ; i++) {
                id o = [self objectAtColumn:i] ;
                if (!o) { o = MSNull ; }
                MSAAdd(values, o) ;
            }
        }
        return AUTORELEASE(values) ;
    }
    return nil ;
}

- (MSRow *)rowDictionary
{
    if (_state == ODBC_POSSIBLE_RESULT) {
        NSUInteger columnsCount = MSACount(_columnsDescription->_keys) ;
        if (columnsCount) {
            NSUInteger i ;
            MSArray *values = MSCreateArray(columnsCount) ;
            if (values) {
                MSRow *row ;
                for (i = 0; i < columnsCount ; i++) {
                    id o = [self objectAtColumn:i] ;
                    if (!o) { o = MSNull ; }
                    MSAAdd(values, o) ;
                }
                row = [ALLOC(MSRow) initWithRowKeys:_columnsDescription values:values] ;
                RELEASE(values) ;
                return AUTORELEASE(row) ;
            }
        }
    }
    return nil ;
}

@end


@implementation _MSODBCRowKeys : MSRowKeys


- (_MSODBCType)typeAtIndex:(NSUInteger)idx
{
    if (idx >= MSACount(_keys)) {
        MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"column %lu out of bounds [0, %lu]", (unsigned long)idx, (unsigned long)MSACount(_keys)) ;
    }
    return _types[idx] ;
}

- (void)dealloc
{
    FREE(_types, "-[MSODBCRowKeys dealloc]") ;
    [super dealloc] ;
}

@end


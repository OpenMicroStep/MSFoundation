/*
 
 MSMySQLResultSet.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
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
 
 */

#import "MSMySQLAdaptorKit.h"

#define MYSQL_RESULT_NOT_INITIALIZED	0
#define MYSQL_POSSIBLE_RESULT			1
#define MYSQL_NO_MORE_RESULTS			2

static MSColumnType _mysqlFieldTypeToMSColumnType(enum enum_field_types type)
{
    switch (type) {
        case MYSQL_TYPE_DECIMAL:
        case MYSQL_TYPE_TINY:
        case MYSQL_TYPE_SHORT:
        case MYSQL_TYPE_LONG:
        case MYSQL_TYPE_FLOAT:
        case MYSQL_TYPE_DOUBLE:
        case MYSQL_TYPE_LONGLONG:
        case MYSQL_TYPE_INT24:
        case MYSQL_TYPE_BIT:
        case MYSQL_TYPE_NEWDECIMAL:
            return MSNumberColumn ;
            
        case MYSQL_TYPE_VARCHAR:
        case MYSQL_TYPE_VAR_STRING:
        case MYSQL_TYPE_STRING:
            return MSStringColumn ;
            
        case MYSQL_TYPE_TINY_BLOB:
        case MYSQL_TYPE_MEDIUM_BLOB:
        case MYSQL_TYPE_LONG_BLOB:
        case MYSQL_TYPE_BLOB:
            return MSDataColumn ;
            
        case MYSQL_TYPE_TIMESTAMP:
        case MYSQL_TYPE_DATE:
        case MYSQL_TYPE_TIME:
        case MYSQL_TYPE_DATETIME:
        case MYSQL_TYPE_YEAR:
        case MYSQL_TYPE_NEWDATE:
            return MSDateColumn ;
            
        case MYSQL_TYPE_NULL:
            return MSNoValueColumn ;
            
        default:
            //MYSQL_TYPE_ENUM
            //MYSQL_TYPE_SET
            //MYSQL_TYPE_GEOMETRY
            return MSUnknownTypeColumn ;
    }
}

static float  MSStrtof(const char *StringPtr, char **stopString) { return strtof(StringPtr, stopString) ; }
static double MSStrtod(const char *StringPtr, char **stopString) { return strtod(StringPtr, stopString) ; }

@implementation MSMySQLResultSet

- (id)initWithStatement:(MYSQL_STMT *)statement withConnection:(MSMySQLConnection *)connection withMSStatement:(MSMySQLStatement *)msStatement
{
    if ((self = [super initWithDatabaseConnection:connection])) {
        MYSQL_RES *res= mysql_stmt_result_metadata(statement);
        NSUInteger count = mysql_num_fields(res) ;
		MSArray *keys= [[MSArray alloc] mutableInitWithCapacity:count noRetainRelease:YES nilItems:NO];
		MYSQL_FIELD *field; NSString *s; MYSQL_BIND *bind; MSMysqlBindParamInfo *bindInfo;

		if (!keys) { RELEASE(self) ; return nil ; }
        
        _bindSize= count;
        _bind= MSCalloc(_bindSize, sizeof(MYSQL_BIND), "MSMySQLResultSet::_bind");
        _bindInfos= MSCalloc(_bindSize, sizeof(MSMysqlBindParamInfo), "MSMySQLResultSet::_bindInfos");
        bind= _bind;
        bindInfo= _bindInfos;
        while((field = mysql_fetch_field(res)))
        {
            // Field name
            if (!field->name || !*field->name) { RELEASE(keys) ; RELEASE(self) ; return nil ; }
            s = [ALLOC(NSString) initWithCString:field->name encoding:NSUTF8StringEncoding] ;
            if (!s) { RELEASE(keys) ; RELEASE(self) ; return nil ; }
            [keys addObject:s];
            
            // Bindings
            bind->buffer_type= field->type;
            switch (field->type) {
                case MYSQL_TYPE_TINY:       bind->buffer= (void *)&bindInfo->u._MSChar; break;
                case MYSQL_TYPE_SHORT:      bind->buffer= (void *)&bindInfo->u._MSShort; break;
                case MYSQL_TYPE_INT24:      bind->buffer= (void *)&bindInfo->u._MSInt; break;
                case MYSQL_TYPE_LONG:       bind->buffer= (void *)&bindInfo->u._MSInt; break;
                case MYSQL_TYPE_LONGLONG:   bind->buffer= (void *)&bindInfo->u._MSLong; break;
                case MYSQL_TYPE_FLOAT:      bind->buffer= (void *)&bindInfo->u._float; break;
                case MYSQL_TYPE_DOUBLE:     bind->buffer= (void *)&bindInfo->u._double; break;
                
                case MYSQL_TYPE_TIME:
                case MYSQL_TYPE_DATE:
                case MYSQL_TYPE_DATETIME:
                case MYSQL_TYPE_TIMESTAMP:
                    bindInfo->u._time= MSMalloc(sizeof(MYSQL_TIME), "MSMySQLResultSet MYSQL_TIME");
                    bind->buffer= bindInfo->u._time;
                    break;
                    
                case MYSQL_TYPE_NEWDECIMAL:
                case MYSQL_TYPE_STRING:
                case MYSQL_TYPE_VAR_STRING:
                case MYSQL_TYPE_TINY_BLOB:
                case MYSQL_TYPE_BLOB:
                case MYSQL_TYPE_MEDIUM_BLOB:
                case MYSQL_TYPE_LONG_BLOB:
                case MYSQL_TYPE_BIT:
                    break;
                
                default:
                    break;
            }
            bind->is_unsigned = ((field->flags & UNSIGNED_FLAG) == UNSIGNED_FLAG);
            bind->is_null = &bindInfo->is_null;
            bind->length = &bindInfo->length;
            ++bindInfo;
            ++bind;
		}

        mysql_stmt_bind_result(statement, _bind);

		_columnsDescription = RETAIN([MSRowKeys rowKeysWithKeys:keys]) ;
		RELEASE(keys) ;
		if (!_columnsDescription) { RELEASE(self) ; return nil ; }
        
        _stmt= statement ;
        _state= MYSQL_RESULT_NOT_INITIALIZED ;
        ASSIGN(_msstmt, msStatement) ;
    }
    return self ;
}

- (void)terminateOperation
{
    if(_bind && _bindInfos) {
        size_t i;
        MYSQL_BIND *bind;
        MSMysqlBindParamInfo *bindInfo;
        for(i= 0; i < _bindSize; ++i) {
            bind= _bind + i;
            bindInfo= _bindInfos + i;
            switch (bind->buffer_type) {
                case MYSQL_TYPE_TIME:
                case MYSQL_TYPE_DATE:
                case MYSQL_TYPE_DATETIME:
                case MYSQL_TYPE_TIMESTAMP:
                    free(bindInfo->u._time);
                    break;
                default:
                    break;
            }
        }
        free(_bind);
        free(_bindInfos);
        _bind= NULL;
        _bindInfos= NULL;
    }
    _state = MYSQL_NO_MORE_RESULTS ;
    RELEAZEN(_msstmt);
    [super terminateOperation] ;
}

- (MSColumnType)typeOfColumn:(NSUInteger)column
{
    if(column < _bindSize) {
        return _mysqlFieldTypeToMSColumnType(_bind[column].buffer_type);
    }
    MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"try to reach undefined column at index %lu", (unsigned long)column) ;
	return MSUnknownTypeColumn ;
}

- (BOOL)nextRow
{
    int ret;
    if(_state == MYSQL_NO_MORE_RESULTS)
        return NO;
    
    ret= mysql_stmt_fetch(_stmt);
    if(ret == MYSQL_RET_OK || ret == MYSQL_DATA_TRUNCATED) {
		_state = MYSQL_POSSIBLE_RESULT ;
        return YES;
    }
	_state = MYSQL_NO_MORE_RESULTS ;
	return NO ;
}



#define _GET_STMT_NUMBER_VALUE_METHOD(NAME, TYPE, MYSQLTYPE, LEFT, RIGHT, CONVERSION_TYPE, CSTRTO) \
- (BOOL)get ## NAME ## At:(TYPE *)aValue column:(NSUInteger)column error:(MSInt *)errorPtr \
{ \
	MSInt error = MSNoColumn ; \
	BOOL good = NO ; \
	if (_state == MYSQL_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; } \
	else if (_state == MYSQL_NO_MORE_RESULTS) { error = MSFetchIsOver ; } \
	else if (column <  _bindSize) { \
        MYSQL_BIND *bind= _bind + column; \
        if(*bind->is_null || bind->buffer_type == MYSQL_TYPE_NULL) { \
            error = MSNullFetch; \
			good = YES ; \
		} \
		else \
		{ \
            error = MSFetchOK ; \
            if(bind->buffer_type == MYSQLTYPE) { \
                if(aValue) *aValue= *(TYPE*)bind->buffer; \
                good = YES ; \
            } else { \
                CONVERSION_TYPE bigValue=0; \
                switch (bind->buffer_type) { \
                    case MYSQL_TYPE_TINY: bigValue = (CONVERSION_TYPE)(*(MSChar *)bind->buffer); break; \
                    case MYSQL_TYPE_SHORT: bigValue = (CONVERSION_TYPE)(*(MSShort *)bind->buffer); break; \
                    case MYSQL_TYPE_LONG: bigValue = (CONVERSION_TYPE)(*(MSInt *)bind->buffer); break; \
                    case MYSQL_TYPE_LONGLONG: bigValue = (CONVERSION_TYPE)(*(MSLong *)bind->buffer); break; \
                    case MYSQL_TYPE_INT24: bigValue = (CONVERSION_TYPE)(*(MSInt *)bind->buffer); break; \
                    case MYSQL_TYPE_FLOAT: bigValue = (CONVERSION_TYPE)(*(float *)bind->buffer); break; \
                    case MYSQL_TYPE_DOUBLE: bigValue = (CONVERSION_TYPE)(*(double *)bind->buffer); break; \
                    \
                    case MYSQL_TYPE_NEWDECIMAL: \
                    case MYSQL_TYPE_STRING: \
                    case MYSQL_TYPE_VAR_STRING: \
                    case MYSQL_TYPE_TINY_BLOB: \
                    case MYSQL_TYPE_BLOB: \
                    case MYSQL_TYPE_MEDIUM_BLOB: \
                    case MYSQL_TYPE_LONG_BLOB: \
                    case MYSQL_TYPE_BIT: \
                    { \
                        char *data= malloc(_bindInfos[column].length); \
                        bind->buffer= data; \
                        bind->buffer_length= _bindInfos[column].length; \
                        mysql_stmt_fetch_column(_stmt, bind, (unsigned int)column, 0); \
                        bigValue= CSTRTO(data, NULL); \
                        free(data); \
                        bind->buffer= NULL; \
                        bind->buffer_length= 0; \
                        break; \
                    } \
                    \
                    default: \
                        error = MSNotConverted ; \
                        break ; \
                } \
                if (error == MSFetchOK && bigValue >= LEFT && bigValue <= RIGHT) { \
                    if (aValue) *aValue = (TYPE)bigValue ; \
                    good = YES ; \
                } \
				else { error = MSNotConverted ; } \
			} \
		} \
	} \
	if (errorPtr) *errorPtr = error ; \
	return good ; \
}

_GET_STMT_NUMBER_VALUE_METHOD(Char, MSChar, MYSQL_TYPE_TINY, MSCharMin, MSCharMax, MSLong, CStrToLongLong)
_GET_STMT_NUMBER_VALUE_METHOD(Byte, MSByte, MYSQL_TYPE_TINY, 0, MSByteMax, MSULong, CStrToULongLong)
_GET_STMT_NUMBER_VALUE_METHOD(Short, MSShort, MYSQL_TYPE_SHORT, MSShortMin, MSShortMax, MSLong, CStrToLongLong)
_GET_STMT_NUMBER_VALUE_METHOD(UnsignedShort, MSUShort, MYSQL_TYPE_SHORT, 0, MSUShortMax, MSULong, CStrToULongLong)
_GET_STMT_NUMBER_VALUE_METHOD(Int, MSInt, MYSQL_TYPE_LONG, MSIntMin, MSIntMax, MSLong, CStrToLongLong)
_GET_STMT_NUMBER_VALUE_METHOD(UnsignedInt, MSUInt, MYSQL_TYPE_LONG, 0, MSUIntMax, MSULong, CStrToULongLong)
_GET_STMT_NUMBER_VALUE_METHOD(Long, MSLong, MYSQL_TYPE_LONGLONG, MSLongMin, MSLongMax, MSLong, CStrToLongLong)
_GET_STMT_NUMBER_VALUE_METHOD(UnsignedLong, MSULong, MYSQL_TYPE_LONGLONG, 0, MSULongMax, MSULong, CStrToULongLong)
_GET_STMT_NUMBER_VALUE_METHOD(Float, float, MYSQL_TYPE_FLOAT, -FLT_MAX, FLT_MAX, double, MSStrtof)
_GET_STMT_NUMBER_VALUE_METHOD(Double, double, MYSQL_TYPE_DOUBLE, -DBL_MAX, DBL_MAX, double, MSStrtod)

- (BOOL)getDateAt:(MSTimeInterval *)aDate column:(NSUInteger)column error:(MSInt *)errorPtr
{
    MSInt error = MSNoColumn ;
    BOOL good = NO ;
    if (_state == MYSQL_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; }
    else if (_state == MYSQL_NO_MORE_RESULTS) { error = MSFetchIsOver ; }
    else if (column <  _bindSize) {
        MYSQL_BIND *bind= _bind + column;
        if(*bind->is_null || bind->buffer_type == MYSQL_TYPE_NULL) {
            error = MSNullFetch;
			good = YES ;
		}
        else
        {
            MSTimeInterval time= 0;
            error = MSFetchOK;
            switch (bind->buffer_type)
            {
                case MYSQL_TYPE_TIMESTAMP:
                case MYSQL_TYPE_DATE:
                case MYSQL_TYPE_TIME:
                case MYSQL_TYPE_DATETIME:
                case MYSQL_TYPE_NEWDATE:{
                    MYSQL_TIME *mtime= (MYSQL_TIME*)bind->buffer;
                    if (aDate) {
                        CDate *d= CCreateDateWithYMDHMS(mtime->year, mtime->month, mtime->day, mtime->hour, mtime->minute, mtime->second);
                        *aDate= CDateSecondsBetweenDates(d, CDate20010101);
                        RELEAZEN(d);
                    }
                    error = MSFetchOK ; good = YES ;
                }
                    
                case MYSQL_TYPE_TINY: time = (MSTimeInterval)(*(MSChar *)bind->buffer); break;
                case MYSQL_TYPE_SHORT: time = (MSTimeInterval)(*(MSShort *)bind->buffer); break;
                case MYSQL_TYPE_LONG: time = (MSTimeInterval)(*(MSInt *)bind->buffer); break;
                case MYSQL_TYPE_LONGLONG: time = (MSTimeInterval)(*(MSLong *)bind->buffer); break;
                case MYSQL_TYPE_INT24: time = (MSTimeInterval)(*(MSInt *)bind->buffer); break;
                case MYSQL_TYPE_FLOAT: time = (MSTimeInterval)(*(float *)bind->buffer); break;
                case MYSQL_TYPE_DOUBLE: time = (MSTimeInterval)(*(double *)bind->buffer); break;
                
                case MYSQL_TYPE_DECIMAL:
                case MYSQL_TYPE_NEWDECIMAL:{
                    char *data= malloc(*bind->length);
                    bind->buffer= data;
                    bind->buffer_length= *bind->length;
                    mysql_stmt_fetch_column(_stmt, bind, (unsigned int)column, 0);
                    time = (MSTimeInterval)strtod(data, NULL);
                    free(data);
                    bind->buffer= NULL;
                    bind->buffer_length= 0;
                    break;
                }
                    
                case MYSQL_TYPE_TINY_BLOB:
                case MYSQL_TYPE_MEDIUM_BLOB:
                case MYSQL_TYPE_LONG_BLOB:
                case MYSQL_TYPE_BLOB:
                case MYSQL_TYPE_VARCHAR:
                case MYSQL_TYPE_VAR_STRING:
                case MYSQL_TYPE_STRING:{
                    char *data= malloc(*bind->length);
                    bind->buffer= data;
                    bind->buffer_length= *bind->length;
                    mysql_stmt_fetch_column(_stmt, bind, (unsigned int)column, 0);
                    if (bind->buffer && *bind->length) {
                        if (!(good = MSGetSqlDateFromBytes((void *)bind->buffer,*bind->length, aDate))) { error = MSNotConverted ; }
                    }
                    free(data);
                    bind->buffer= NULL;
                    bind->buffer_length= 0;
                    break;
                }
                    
                default: 
                    error = MSNotConverted ;
                    break ;
            }
            if(!good && error == MSFetchOK) {
                good= YES;
                if(aDate) *aDate= time;
            }
        }
    }
    if (errorPtr) *errorPtr = error ;
    return good ;
}

- (BOOL)getStringAt:(MSString*)aString column:(NSUInteger)column error:(MSInt*)errorPtr
{
	MSInt error = MSNoColumn ;
	BOOL good = NO ; 
	if (_state == MYSQL_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; }
	else if (_state == MYSQL_NO_MORE_RESULTS) { error = MSFetchIsOver ; }
    else if (column <  _bindSize) {
        MYSQL_BIND *bind= _bind + column;
        if(*bind->is_null || bind->buffer_type == MYSQL_TYPE_NULL) {
            error = MSNullFetch;
			good = YES ;
		}
		else 
		{
            error = MSFetchOK;
            good= YES;
            
            switch (bind->buffer_type)
            {
                case MYSQL_TYPE_TINY: if(aString) CStringAppendEncodedFormat((CString*)aString, NSUTF8StringEncoding, "%hhd", *(MSChar *)bind->buffer); break;
                case MYSQL_TYPE_SHORT: if(aString) CStringAppendEncodedFormat((CString*)aString, NSUTF8StringEncoding, "%hd", *(MSShort *)bind->buffer); break;
                case MYSQL_TYPE_LONG: if(aString) CStringAppendEncodedFormat((CString*)aString, NSUTF8StringEncoding, "%d", *(MSInt *)bind->buffer); break;
                case MYSQL_TYPE_LONGLONG: if(aString) CStringAppendEncodedFormat((CString*)aString, NSUTF8StringEncoding, "%lld", *(MSLong *)bind->buffer); break;
                case MYSQL_TYPE_INT24: if(aString) CStringAppendEncodedFormat((CString*)aString, NSUTF8StringEncoding, "%d", *(MSInt *)bind->buffer); break;
                case MYSQL_TYPE_FLOAT: if(aString) CStringAppendEncodedFormat((CString*)aString, NSUTF8StringEncoding, "%f", *(float *)bind->buffer); break;
                case MYSQL_TYPE_DOUBLE: if(aString) CStringAppendEncodedFormat((CString*)aString, NSUTF8StringEncoding, "%f", *(double *)bind->buffer); break;
                
                case MYSQL_TYPE_DECIMAL:
                case MYSQL_TYPE_NEWDECIMAL:
                case MYSQL_TYPE_TINY_BLOB:
                case MYSQL_TYPE_MEDIUM_BLOB:
                case MYSQL_TYPE_LONG_BLOB:
                case MYSQL_TYPE_BLOB:
                case MYSQL_TYPE_VARCHAR:
                case MYSQL_TYPE_VAR_STRING:
                case MYSQL_TYPE_STRING:{
                    char *data= malloc(*bind->length);
                    bind->buffer= data;
                    bind->buffer_length= *bind->length;
                    mysql_stmt_fetch_column(_stmt, bind, (unsigned int)column, 0);
                    if (bind->buffer && *bind->length && aString) {
                        CStringAppendBytes((CString*)aString, NSUTF8StringEncoding, bind->buffer, *bind->length);
                    }
                    free(data);
                    bind->buffer= NULL;
                    bind->buffer_length= 0;
                    break;
                }
                    
                default: 
                    good= NO;
                    error = MSNotConverted ;
                    break ;
            }
		}
	}
	if (errorPtr) *errorPtr = error ;
	return good ;
}

- (BOOL)getBufferAt:(MSBuffer *)aBuffer column:(NSUInteger)column error:(MSInt *)errorPtr
{
	MSInt error = MSNoColumn ;
	BOOL good = NO ; 
	if (_state == MYSQL_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; }
	else if (_state == MYSQL_NO_MORE_RESULTS) { error = MSFetchIsOver ; }
    else if (column <  _bindSize) {
        MYSQL_BIND *bind= _bind + column;
        if(*bind->is_null || bind->buffer_type == MYSQL_TYPE_NULL) {
            error = MSNullFetch;
			good = YES ;
		}
		else 
		{
            error = MSFetchOK;
            good= YES;
            
            switch (bind->buffer_type)
            {
                case MYSQL_TYPE_TINY: if(aBuffer) CBufferAppendBytes((CBuffer*)aBuffer, (MSChar *)bind->buffer, sizeof(MSChar)); break;
                case MYSQL_TYPE_SHORT: if(aBuffer) CBufferAppendBytes((CBuffer*)aBuffer, (MSShort *)bind->buffer, sizeof(MSShort)); break;
                case MYSQL_TYPE_LONG: if(aBuffer) CBufferAppendBytes((CBuffer*)aBuffer, (MSInt *)bind->buffer, sizeof(MSInt)); break;
                case MYSQL_TYPE_LONGLONG: if(aBuffer) CBufferAppendBytes((CBuffer*)aBuffer, (MSLong *)bind->buffer, sizeof(MSLong)); break;
                case MYSQL_TYPE_INT24: if(aBuffer) CBufferAppendBytes((CBuffer*)aBuffer, (MSInt *)bind->buffer, sizeof(MSInt)); break;
                case MYSQL_TYPE_FLOAT: if(aBuffer) CBufferAppendBytes((CBuffer*)aBuffer, (float *)bind->buffer, sizeof(float)); break;
                case MYSQL_TYPE_DOUBLE: if(aBuffer) CBufferAppendBytes((CBuffer*)aBuffer, (double *)bind->buffer, sizeof(double)); break;
                
                case MYSQL_TYPE_DECIMAL:
                case MYSQL_TYPE_NEWDECIMAL:
                case MYSQL_TYPE_TINY_BLOB:
                case MYSQL_TYPE_MEDIUM_BLOB:
                case MYSQL_TYPE_LONG_BLOB:
                case MYSQL_TYPE_BLOB:
                case MYSQL_TYPE_VARCHAR:
                case MYSQL_TYPE_VAR_STRING:
                case MYSQL_TYPE_STRING:{
                    char *data= malloc(*bind->length);
                    bind->buffer= data;
                    bind->buffer_length= *bind->length;
                    mysql_stmt_fetch_column(_stmt, bind, (unsigned int)column, 0);
                    if (bind->buffer && *bind->length && aBuffer) {
                        CBufferAppendBytes((CBuffer*)aBuffer, bind->buffer, *bind->length);
                    }
                    free(data);
                    bind->buffer= NULL;
                    bind->buffer_length= 0;
                    break;
                }
                    
                default: 
                    good= NO;
                    error = MSNotConverted ;
                    break ;
            }
		}
	}
	if (errorPtr) *errorPtr = error ;
	return good ;
}

- (id)objectAtColumn:(NSUInteger)column
{
	if (_state == MYSQL_POSSIBLE_RESULT) {
		if (column <  _bindSize) {
            MYSQL_BIND *bind= _bind + column;
            if(!*bind->is_null) {
                switch (bind->buffer_type) {
                    case MYSQL_TYPE_FLOAT:   return [NSNumber numberWithFloat:*(float*)bind->buffer] ;
                    case MYSQL_TYPE_DOUBLE:  return [NSNumber numberWithDouble:*(double*)bind->buffer] ;
                    case MYSQL_TYPE_TINY:    return bind->is_unsigned ? [NSNumber numberWithUnsignedChar:*(MSByte*)bind->buffer] : [NSNumber numberWithDouble:*(MSChar*)bind->buffer] ;
                    case MYSQL_TYPE_SHORT:   return bind->is_unsigned ? [NSNumber numberWithUnsignedShort:*(MSUShort*)bind->buffer] : [NSNumber numberWithShort:*(MSShort*)bind->buffer] ;
                    case MYSQL_TYPE_LONG:    return bind->is_unsigned ? [NSNumber numberWithUnsignedInt:*(MSUInt*)bind->buffer] : [NSNumber numberWithInt:*(MSInt*)bind->buffer] ;
                    case MYSQL_TYPE_LONGLONG:return bind->is_unsigned ? [NSNumber numberWithUnsignedLongLong:*(MSULong*)bind->buffer] : [NSNumber numberWithLongLong:*(MSLong*)bind->buffer] ;
                    case MYSQL_TYPE_INT24:   return bind->is_unsigned ? [NSNumber numberWithUnsignedInt:*(MSUInt*)bind->buffer] : [NSNumber numberWithInt:*(MSInt*)bind->buffer] ;
                    
                    case MYSQL_TYPE_TIMESTAMP:
                    case MYSQL_TYPE_DATE:
                    case MYSQL_TYPE_TIME:
                    case MYSQL_TYPE_DATETIME:
                    case MYSQL_TYPE_NEWDATE:{
                        MYSQL_TIME *mtime= (MYSQL_TIME*)bind->buffer;
                        return [MSDate dateWithYear:mtime->year month:mtime->month day:mtime->day hour:mtime->hour minute:mtime->minute second:mtime->second] ;
                    }
                    
                    case MYSQL_TYPE_DECIMAL:
                    case MYSQL_TYPE_NEWDECIMAL:{
                        id ret= nil;
                        char *data= malloc(*bind->length);
                        bind->buffer= data;
                        bind->buffer_length= *bind->length;
                        mysql_stmt_fetch_column(_stmt, bind, (unsigned int)column, 0);
                        if (bind->buffer && *bind->length) {
                            ret= [MSDecimal decimalWithUTF8String:bind->buffer];
                        }
                        bind->buffer= NULL;
                        bind->buffer_length= 0;
                        return ret;
                    }
                    
                    case MYSQL_TYPE_VARCHAR:
                    case MYSQL_TYPE_VAR_STRING:
                    case MYSQL_TYPE_STRING:{
                        id ret= nil;
                        char *data= malloc(*bind->length);
                        bind->buffer= data;
                        bind->buffer_length= *bind->length;
                        mysql_stmt_fetch_column(_stmt, bind, (unsigned int)column, 0);
                        if (bind->buffer && *bind->length) {
                            ret= [ALLOC(MSString) initWithBytes:bind->buffer length:*bind->length encoding:NSUTF8StringEncoding];
                        }
                        bind->buffer= NULL;
                        bind->buffer_length= 0;
                        return ret;
                    }
                    
                    case MYSQL_TYPE_BLOB:
                    case MYSQL_TYPE_TINY_BLOB:
                    case MYSQL_TYPE_MEDIUM_BLOB:
                    case MYSQL_TYPE_LONG_BLOB:{
                        id ret= nil;
                        char *data= malloc(*bind->length);
                        bind->buffer= data;
                        bind->buffer_length= *bind->length;
                        mysql_stmt_fetch_column(_stmt, bind, (unsigned int)column, 0);
                        if (bind->buffer && *bind->length) {
                            ret= [MSBuffer bufferWithBytesNoCopy:bind->buffer length:*bind->length];
                        }
                        bind->buffer= NULL;
                        bind->buffer_length= 0;
                        return ret;
                    }
                    
                    case MYSQL_TYPE_NULL:
                    default: 
                        break ;
                }
            }
		}
		else {
			MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"try to reach undefined column at index %lu", (unsigned long)column) ;
		}
	}
	return nil ;
}

@end

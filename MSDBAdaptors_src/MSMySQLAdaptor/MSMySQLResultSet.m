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
#import "_MSDBGenericConnection.h"
#import "MSMySQLResultSet.h"
#import "my_time.h"

#define MYSQL_RESULT_NOT_INITIALIZED	0
#define MYSQL_POSSIBLE_RESULT			1
#define MYSQL_NO_MORE_RESULTS			2

@implementation MSMySQLResultSet

- (id)initWithMySQLRes:(MYSQL_RES *)result connection:(MSDBConnection *)connection
{
	if ((self = [super initWithDatabaseConnection:connection])) 
	{
		NSUInteger count = mysql_num_fields(result) ;
		MSArray *keys = MSCreateArray(count) ;
		MYSQL_FIELD *field;

		if (!keys) { RELEASE(self) ; return nil ; }
		
		while((field = mysql_fetch_field(result))) 
		{
			if (!field->name || !*field->name) { RELEASE(keys) ; RELEASE(self) ; return nil ; }
				NSString *s = [ALLOC(NSString) initWithCString:field->name encoding:NSUTF8StringEncoding] ;
				if (!s) { RELEASE(keys) ; RELEASE(self) ; return nil ; }
				MSAAddUnretained(keys, s) ;
		}

		_columnsDescription = RETAIN([MSRowKeys rowKeysWithKeys:keys]) ;
		RELEASE(keys) ;
		if (!_columnsDescription) { RELEASE(self) ; return nil ; }
		
		_row = NULL ;
		_state = MYSQL_RESULT_NOT_INITIALIZED ;
		_result = result ;
	}
	return self ;
}

- (void)dealloc
{
	if (_result) 
	{
		mysql_free_result(_result);
		_result = NULL ;
	}
	[super dealloc] ;
}

- (void)terminateOperation
{
	if (_connection) {
		_state = MYSQL_NO_MORE_RESULTS ;
		if (_result) 
		{
			mysql_free_result(_result);
			_result = NULL ;
		}
		_row = NULL ;
		[(_MSDBGenericConnection *)_connection unregisterOperation:self] ;
		[super terminateOperation] ;
	}
}

- (MSColumnType)typeOfColumn:(NSUInteger)column
{
	if (_result) {
		if (column <  MSACount(_columnsDescription->_keys)) {
			MYSQL_FIELD *field = mysql_fetch_field_direct(_result, column);
			switch (field->type) {
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
		MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"try to reach undefined column at index %lu", (unsigned long)column) ;
	}
	MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"terminated request cannot deliver information on columns %lu", (unsigned long)column) ;
	return MSUnknownTypeColumn ;
}


- (BOOL)nextRow
{
	if (_state != MYSQL_NO_MORE_RESULTS && (_row = mysql_fetch_row(_result))) {
		_state = MYSQL_POSSIBLE_RESULT ;
		return YES ;
	}
	else { _state = MYSQL_NO_MORE_RESULTS ; }
	return NO ;
}


#define _GET_NUMBER_VALUE_METHOD(NAME, TYPE, LEFT, RIGHT, INTERNAL_TYPE, CONVERT_FUNCTION) \
- (BOOL)get ## NAME ## At:(TYPE *)aValue column:(NSUInteger)column error:(MSInt *)errorPtr \
{ \
	MSInt error = MSNoColumn ; \
	BOOL good = NO ; \
	if (_state == MYSQL_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; } \
	else if (_state == MYSQL_NO_MORE_RESULTS) { error = MSFetchIsOver ; } \
	else if (column <  MSACount(_columnsDescription->_keys)) { \
		if (!_row[column]) { \
			error = MSNullFetch ; \
			good = YES ; \
		} \
		else \
		{ \
			MYSQL_FIELD *field = mysql_fetch_field_direct(_result, column); \
			switch (field->type) { \
				case MYSQL_TYPE_DECIMAL: \
				case MYSQL_TYPE_TINY: \
				case MYSQL_TYPE_SHORT: \
				case MYSQL_TYPE_LONG: \
				case MYSQL_TYPE_FLOAT: \
				case MYSQL_TYPE_DOUBLE: \
				case MYSQL_TYPE_LONGLONG: \
				case MYSQL_TYPE_INT24: \
				case MYSQL_TYPE_BIT: \
				case MYSQL_TYPE_NEWDECIMAL:{ \
					char *stopString; \
					INTERNAL_TYPE value = CONVERT_FUNCTION(_row[column], &stopString, 10); \
					if ((LEFT == RIGHT) || (value >= LEFT && value <= RIGHT)) { \
						if (aValue) *aValue = (TYPE)value ; \
						error = MSFetchOK ; good = YES ; \
					} \
					else { error = MSNotConverted ; } \
					break ; \
				} \
				case MYSQL_TYPE_NULL: \
					error = MSNullFetch ; \
					break ; \
				default: \
					error = MSNotConverted ; \
					break ; \
			} \
		} \
	} \
	if (errorPtr) *errorPtr = error ; \
	return good ; \
}

long  MSStrtod(const char *StringPtr, char **stopString, int unusedBase) { return strtod(StringPtr, stopString) ;} 
float MSStrtof(const char *StringPtr, char **stopString, int unusedBase) { return strtof(StringPtr, stopString) ;} 

_GET_NUMBER_VALUE_METHOD(Char, MSChar, -128, 127, int, strtol)
_GET_NUMBER_VALUE_METHOD(Byte, MSByte, 0, 256, int, strtoul)
_GET_NUMBER_VALUE_METHOD(Short, MSShort, -32768, 32767, int, strtol)
_GET_NUMBER_VALUE_METHOD(UnsignedShort, MSUShort, 0, 65536, int, strtoul)
_GET_NUMBER_VALUE_METHOD(Int, MSInt, 0, 0, int, strtol)
_GET_NUMBER_VALUE_METHOD(Long, MSLong, 0, 0, long, strtoll)
_GET_NUMBER_VALUE_METHOD(UnsignedLong, MSULong, 0, 0, unsigned long, strtoull)
_GET_NUMBER_VALUE_METHOD(Float, float, 0, 0, double, MSStrtod)
_GET_NUMBER_VALUE_METHOD(Double, double, 0, 0, double, MSStrtof)


- (BOOL)getDateAt:(MSTimeInterval *)aDate column:(NSUInteger)column error:(MSInt *)errorPtr
{
	MSInt error = MSNoColumn ;
	BOOL good = NO ; 
	char *stopString;
	if (_state == MYSQL_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; }
	else if (_state == MYSQL_NO_MORE_RESULTS) { error = MSFetchIsOver ; }
	else if (column <  MSACount(_columnsDescription->_keys)) {
		if (!_row[column]) {
			error = MSNullFetch ;
			good = YES ;
		}
		else 
		{
			MYSQL_FIELD *field = mysql_fetch_field_direct(_result, column);
			switch (field->type) 
			{
				case MYSQL_TYPE_TIMESTAMP:
				case MYSQL_TYPE_DATE:
				case MYSQL_TYPE_TIME:
				case MYSQL_TYPE_DATETIME:
				case MYSQL_TYPE_NEWDATE:{
					unsigned long *lengths = mysql_fetch_lengths(_result) ;
					unsigned long l = lengths[column] ;
					MYSQL_TIME l_time ;
					int was_cut ;
				
					str_to_datetime(_row[column], l, &l_time, /*uint flags*/0, &was_cut);
					if (aDate) *aDate = timeIntervalFromDate(l_time.year, l_time.month, l_time.day, l_time.hour, l_time.minute, l_time.second) ;
					error = MSFetchOK ; good = YES ;
					break ;
				}
				case MYSQL_TYPE_FLOAT:{
					float t = strtof(_row[column], &stopString);
					if (aDate) *aDate = (MSTimeInterval)t ;
					error = MSFetchOK ; good = YES ;
					break ;
				}
				case MYSQL_TYPE_DECIMAL:
				case MYSQL_TYPE_NEWDECIMAL:
				case MYSQL_TYPE_DOUBLE:{
					double t = strtod(_row[column], &stopString);
					if (aDate) *aDate = (MSTimeInterval)t ;
					error = MSFetchOK ; good = YES ;
					break ;
				}
				
				case MYSQL_TYPE_TINY:
				case MYSQL_TYPE_SHORT:
				case MYSQL_TYPE_LONG:
				case MYSQL_TYPE_LONGLONG:
				case MYSQL_TYPE_INT24:{
					MSLong s = strtoll(_row[column], &stopString, 10) ;
					if (aDate) *aDate = (MSTimeInterval)s ;
					error = MSFetchOK ; good = YES ;
					break ;
				}
				
				case MYSQL_TYPE_VARCHAR:
				case MYSQL_TYPE_VAR_STRING:
				case MYSQL_TYPE_STRING:{
					const unsigned char *s = (unsigned char *)_row[column] ;
					unsigned l ;
					if (s && (l = strlen((char *)s))) {
						if ((good = MSGetSqlDateFromBytes((void *)s,l, aDate))) { error = MSFetchOK ; }
						else { error = MSNotConverted ; } 
					}
					else { error = MSNullFetch ; }
					break ;
				}
				
				case MYSQL_TYPE_TINY_BLOB:
				case MYSQL_TYPE_MEDIUM_BLOB:
				case MYSQL_TYPE_LONG_BLOB:
				case MYSQL_TYPE_BLOB:{
					void *bytes = (void *)_row[column] ;
					unsigned long *lengths = mysql_fetch_lengths(_result) ;
					unsigned long l = lengths[column] ;
					if (bytes && lengths && (l > 0)) {
						if ((good = MSGetSqlDateFromBytes(bytes,l, aDate))) { error = MSFetchOK ; }
						else { error = MSNotConverted ; } 
					}
					else { error = MSNullFetch ; }
					break ;
				}
				case MYSQL_TYPE_NULL:
					error = MSNullFetch ;
					break ;
				
				default: 
					error = MSNotConverted ;
					break ;
			}		
		}
	}
	if (errorPtr) *errorPtr = error ;
	return good ;
}

- (BOOL)getStringAt:(CUnicodeBuffer *)aString column:(NSUInteger)column error:(MSInt *)errorPtr
{
	MSInt error = MSNoColumn ;
	BOOL good = NO ; 
	if (_state == MYSQL_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; }
	else if (_state == MYSQL_NO_MORE_RESULTS) { error = MSFetchIsOver ; }
	if (column <  MSACount(_columnsDescription->_keys)) {
		if (!_row[column]) {
			error = MSNullFetch ;
			good = YES ;
		}
		else 
		{
			MYSQL_FIELD *field = mysql_fetch_field_direct(_result, column);
			switch (field->type) {
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
				case MYSQL_TYPE_VARCHAR:
				case MYSQL_TYPE_VAR_STRING:
				case MYSQL_TYPE_STRING:
				case MYSQL_TYPE_TINY_BLOB:
				case MYSQL_TYPE_MEDIUM_BLOB:
				case MYSQL_TYPE_LONG_BLOB:
				case MYSQL_TYPE_BLOB:
				case MYSQL_TYPE_TIMESTAMP:
				case MYSQL_TYPE_DATE:
				case MYSQL_TYPE_TIME:
				case MYSQL_TYPE_DATETIME:
				case MYSQL_TYPE_YEAR:
				case MYSQL_TYPE_NEWDATE:{
					const unsigned char *s = (unsigned char *)_row[column] ;
					if (s) {
						unsigned l = strlen((char *)s) ;
						if (l) {
							// we assume we have a UTF8 string
							if (aString) { 
								good = CUnicodeBufferAppendUTF8Bytes(aString, (void *)s, (NSUInteger)l) ;
								if (!good) { error = MSFetchMallocError ; }
							}
						}
						if (good) { error = MSFetchOK ; }
					}
					else { error = MSNullFetch ; }
					break ;
				}
				case MYSQL_TYPE_NULL:
					error = MSNullFetch ;
					break ;
					
				default: 
					error = MSNotConverted ;
					break ;
			}
		}
	}
	if (errorPtr) *errorPtr = error ;
	return good ;
}

- (BOOL)getBufferAt:(CBuffer *)aBuffer column:(NSUInteger)column error:(MSInt *)errorPtr 
{
	MSInt error = MSNoColumn ;
	BOOL good = NO ; 
	if (_state == MYSQL_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; }
	else if (_state == MYSQL_NO_MORE_RESULTS) { error = MSFetchIsOver ; }
	if (column <  MSACount(_columnsDescription->_keys)) {
		if (!_row[column]) {
			error = MSNullFetch ;
			good = YES ;
		}
		else 
		{
			MYSQL_FIELD *field = mysql_fetch_field_direct(_result, column);
			switch (field->type) {
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
				case MYSQL_TYPE_VARCHAR:
				case MYSQL_TYPE_VAR_STRING:
				case MYSQL_TYPE_STRING:
				case MYSQL_TYPE_TINY_BLOB:
				case MYSQL_TYPE_MEDIUM_BLOB:
				case MYSQL_TYPE_LONG_BLOB:
				case MYSQL_TYPE_BLOB:
				case MYSQL_TYPE_TIMESTAMP:
				case MYSQL_TYPE_DATE:
				case MYSQL_TYPE_TIME:
				case MYSQL_TYPE_DATETIME:
				case MYSQL_TYPE_YEAR:
				case MYSQL_TYPE_NEWDATE:{
					void *bytes = (void *)_row[column] ;
					if (bytes) {
						unsigned long *lengths = mysql_fetch_lengths(_result) ;
						unsigned long l = lengths[column] ;
						if (l) {
							if (aBuffer) { 
								good = CBufferAppendBytes(aBuffer, bytes, (NSUInteger)l) ;
								if (!good) { error = MSFetchMallocError ; }
							}
						}
						if (good) { error = MSFetchOK ; }
					}
					else { error = MSNullFetch ; }
					break ;
				}
				case MYSQL_TYPE_NULL:
					error = MSNullFetch ;
					break ;
					
				default: 
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
		if (column < MSACount(_columnsDescription->_keys)) {
			char *stopString;
			MYSQL_FIELD *field;
			if (!_row[column]) return nil ;
			
			field = mysql_fetch_field_direct(_result, column);
			switch (field->type) {
				case MYSQL_TYPE_FLOAT:
					return [NSNumber numberWithDouble:strtof(_row[column], &stopString)] ;
				case MYSQL_TYPE_DOUBLE:
					return [NSNumber numberWithDouble:strtod(_row[column], &stopString)] ;
				case MYSQL_TYPE_TINY:
				case MYSQL_TYPE_SHORT:
				case MYSQL_TYPE_LONG:
				case MYSQL_TYPE_LONGLONG:
				case MYSQL_TYPE_INT24:
				case MYSQL_TYPE_BIT:
					return [NSNumber numberWithLongLong:(long long)strtoll(_row[column], &stopString, 10)] ;
				case MYSQL_TYPE_TIMESTAMP:
				case MYSQL_TYPE_DATE:
				case MYSQL_TYPE_TIME:
				case MYSQL_TYPE_DATETIME:
				case MYSQL_TYPE_NEWDATE:{
					unsigned long *lengths = mysql_fetch_lengths(_result) ;
					unsigned long l = lengths[column] ;
					MYSQL_TIME l_time ;
					int was_cut ;
					
					str_to_datetime(_row[column], l, &l_time, /*uint flags*/0, &was_cut);
					return [MSDate dateWithYear:l_time.year month:l_time.month day:l_time.day hour:l_time.hour minute:l_time.minute second:l_time.second] ;
				}
				case MYSQL_TYPE_VARCHAR:
				case MYSQL_TYPE_VAR_STRING:
				case MYSQL_TYPE_STRING:{
					const unsigned char *s = (unsigned char *)_row[column] ;
					if (s) {
						unsigned l = strlen((char *)s) ;
						if (l) { return [NSString stringWithCString:(char *)s encoding:NSUTF8StringEncoding] ; }
						return @"" ;
					}
					break;
				}
				case MYSQL_TYPE_TINY_BLOB:
				case MYSQL_TYPE_MEDIUM_BLOB:
				case MYSQL_TYPE_LONG_BLOB:
				case MYSQL_TYPE_BLOB:{
					void *bytes = (void *)_row[column] ;
					unsigned long *lengths = mysql_fetch_lengths(_result) ;
					if (bytes && lengths) {
						unsigned long l = lengths[column] ;
						if (l) {
							return [NSData dataWithBytes:bytes length:(NSUInteger)l] ;
						}
						return [NSData data] ;
					}			
				}
				case MYSQL_TYPE_NULL:
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

- (MSArray *)allValues
{
	if (_state == MYSQL_POSSIBLE_RESULT) {
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
	if (_state == MYSQL_POSSIBLE_RESULT) {
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

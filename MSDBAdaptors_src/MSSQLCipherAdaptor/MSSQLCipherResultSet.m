/*
 
 MSSQLiteResultSet.m
 
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
/*
#ifdef WIN32
#import "../_MSDBGenericConnection.h"
#else
#import "_MSDBGenericConnection.h"
#endif
#import "MSSQLCipherResultSet.h"
*/
#import "MSSQLCipherAdaptorKit.h"

#define SQLITE_RESULT_NOT_INITIALIZED	0
#define SQLITE_POSSIBLE_RESULT			1
#define SQLITE_NO_MORE_RESULTS			2

@implementation MSSQLCipherResultSet

- (id)initWithStatement:(sqlite3_stmt *)statement withConnection:(MSSQLCipherConnection *)connection withMSStatement:(MSSQLCipherStatement *)msStatement
{
    if ((self = [super initWithDatabaseConnection:connection])) {
        int i, count = (int)sqlite3_column_count(statement) ;
        MSArray *keys = MSCreateArray((NSUInteger)count) ;
        
        if (!keys) { RELEASE(self) ; return nil ; }
        
        for	(i = 0 ; i < count ; i++) {
            const char *name = sqlite3_column_name(statement, i) ;
            
            NSString *s ;
            
            if (!name || !*name) { RELEASE(keys) ; RELEASE(self) ; return nil ; }
            s = [NSString stringWithCString:name encoding:NSUTF8StringEncoding] ;
            if (!s) { RELEASE(keys) ; RELEASE(self) ; return nil ; }
            CArrayAddObject((CArray*)keys, s);
        }
        _columnsDescription = RETAIN([MSRowKeys rowKeysWithKeys:keys]) ;
        RELEASE(keys) ;
        if (!_columnsDescription) { RELEASE(self) ; return nil ; }
        
        _statement= statement ;
        _state= SQLITE_RESULT_NOT_INITIALIZED ;
        ASSIGN(_msstmt, msStatement) ;
    }
    return self ;
}

- (void)terminateOperation
{
    if(!_msstmt)
        sqlite3_finalize(_statement) ;
    else
        sqlite3_reset(_statement);
    RELEAZEN(_msstmt) ;
    _statement = NULL ;
    _state = SQLITE_NO_MORE_RESULTS ;
    [super terminateOperation] ;
}

- (MSColumnType)typeOfColumn:(NSUInteger)column
{
	if (_statement) {
		if (column <  (NSUInteger)sqlite3_column_count(_statement)) {
			int type = sqlite3_column_type(_statement, (int)column) ;
			switch (type) {
				case SQLITE_INTEGER:
				case SQLITE_FLOAT:
					return MSNumberColumn ;
				case SQLITE_TEXT:
					return MSStringColumn ;
				case SQLITE_BLOB:
					return MSDataColumn ;
				case SQLITE_NULL:
					return MSNoValueColumn ;
				default:
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
	if (_state != SQLITE_NO_MORE_RESULTS && sqlite3_step(_statement) == SQLITE_ROW) {
		_state = SQLITE_POSSIBLE_RESULT ;
		return YES ;
	}
	else {
        _state = SQLITE_NO_MORE_RESULTS ;
        return NO ;
    }
}


#define _GET_NUMBER_VALUE_METHOD(NAME, TYPE, LEFT, RIGHT, INTERNAL_TYPE, FETCH_FUNCTION) \
- (BOOL)get ## NAME ## At:(TYPE *)aValue column:(NSUInteger)column error:(MSInt *)errorPtr \
{ \
	MSInt error = MSNoColumn ; \
	BOOL good = NO ; \
	if (_state == SQLITE_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; } \
	else if (_state == SQLITE_NO_MORE_RESULTS) { error = MSFetchIsOver ; } \
	else if (column < (NSUInteger)sqlite3_column_count(_statement)) { \
		int columnType = sqlite3_column_type(_statement, (int)column) ; \
		switch (columnType) { \
			case SQLITE_FLOAT: \
			case SQLITE_INTEGER: \
			case SQLITE_TEXT: \
			case SQLITE_BLOB:{ \
				INTERNAL_TYPE value = FETCH_FUNCTION(_statement, (int)column); \
				if ((LEFT == RIGHT) || (value >= LEFT && value <= RIGHT)) { \
					if (aValue) *aValue = (TYPE)value ; \
					error = MSFetchOK ; good = YES ; \
				} \
				else { error = MSNotConverted ; } \
				break ; \
			} \
			case SQLITE_NULL: \
				error = MSNullFetch ; \
				break ; \
			default: \
				error = MSNotConverted ; \
				break ; \
		} \
	} \
	if (errorPtr) *errorPtr = error ; \
	return good ; \
}

_GET_NUMBER_VALUE_METHOD(Char, MSChar, -128, 127, int, sqlite3_column_int)
_GET_NUMBER_VALUE_METHOD(Byte, MSByte, 0, 256, int, sqlite3_column_int)
_GET_NUMBER_VALUE_METHOD(Short, MSShort, -32768, 32767, int, sqlite3_column_int)
_GET_NUMBER_VALUE_METHOD(UnsignedShort, MSUShort, 0, 65536, int, sqlite3_column_int)
_GET_NUMBER_VALUE_METHOD(Int, MSInt, 0, 0, int, sqlite3_column_int)
_GET_NUMBER_VALUE_METHOD(Long, MSLong, 0, 0, sqlite3_int64, sqlite3_column_int64)
_GET_NUMBER_VALUE_METHOD(Float, float, 0, 0, double, sqlite3_column_double)
_GET_NUMBER_VALUE_METHOD(Double, double, 0, 0, double, sqlite3_column_double)


- (BOOL)getDateAt:(MSTimeInterval *)aDate column:(NSUInteger)column error:(MSInt *)errorPtr
{
	MSInt error = MSNoColumn ;
	BOOL good = NO ; 
	if (_state == SQLITE_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; }
	else if (_state == SQLITE_NO_MORE_RESULTS) { error = MSFetchIsOver ; }
	else if (column <  (NSUInteger)sqlite3_column_count(_statement)) {
		int columnType = sqlite3_column_type(_statement, (int)column) ;
		switch (columnType) {
			case SQLITE_FLOAT:{
				double t = sqlite3_column_double(_statement, (int)column) ;
				if (aDate) *aDate = (MSTimeInterval)t ;
				error = MSFetchOK ; good = YES ;
				break ;
			}
			case SQLITE_INTEGER:{
				sqlite3_int64 s = sqlite3_column_int64(_statement, (int)column) ;
				if (aDate) *aDate = (MSTimeInterval)s ;
				error = MSFetchOK ; good = YES ;
				break ;
			}
			case SQLITE_TEXT:{
				const unsigned char *s = sqlite3_column_text(_statement, (int)column) ;
				size_t l ;
				if (s && (l = strlen((char *)s))) {
					if ((good = MSGetSqlDateFromBytes((void *)s,(NSUInteger)l, aDate))) { error = MSFetchOK ; }
					else { error = MSNotConverted ; } 
				}
				else { error = MSNullFetch ; }
				break ;
			}
			case SQLITE_BLOB:{
				void *bytes = (void *)sqlite3_column_blob(_statement, (int)column) ;
				int l ;
				if (bytes && (l = sqlite3_column_bytes(_statement, (int)column)) > 0) {
					if ((good = MSGetSqlDateFromBytes(bytes,(NSUInteger)l, aDate))) { error = MSFetchOK ; }
					else { error = MSNotConverted ; } 
				}
				else { error = MSNullFetch ; }
				break ;
			}
			case SQLITE_NULL:
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
	MSInt error = MSNoColumn ;
	BOOL good = NO ; 
	if (_state == SQLITE_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; }
	else if (_state == SQLITE_NO_MORE_RESULTS) { error = MSFetchIsOver ; }
	if (column <  (NSUInteger)sqlite3_column_count(_statement)) {
		int columnType = sqlite3_column_type(_statement, (int)column) ;
		switch (columnType) {
			case SQLITE_FLOAT:
			case SQLITE_INTEGER:
			case SQLITE_TEXT:
			case SQLITE_BLOB:{
				const unsigned char *s = sqlite3_column_text(_statement, (int)column) ;
				if (s) {
					size_t l = strlen((char *)s) ;
					if (l) {
						// we assume we have a UTF8 string
						if (aString) { 
              CStringAppendBytes((CString*)aString, NSUTF8StringEncoding, (void *)s, (NSUInteger)l) ;
							good = YES;
						}
					}
					if (good) { error = MSFetchOK ; }
				}
				else { error = MSNullFetch ; }
				break ;
			}
			case SQLITE_NULL:
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

- (BOOL)getBufferAt:(MSBuffer *)aBuffer column:(NSUInteger)column error:(MSInt *)errorPtr
{
	MSInt error = MSNoColumn ;
	BOOL good = NO ; 
	if (_state == SQLITE_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; }
	else if (_state == SQLITE_NO_MORE_RESULTS) { error = MSFetchIsOver ; }
	if (column <  (NSUInteger)sqlite3_column_count(_statement)) {
		int type = sqlite3_column_type(_statement, (int)column) ;
		switch (type) {
			case SQLITE_FLOAT:
			case SQLITE_INTEGER:
			case SQLITE_TEXT:
			case SQLITE_BLOB:{
				void *bytes = (void *)sqlite3_column_blob(_statement, (int)column) ;
				if (bytes) {
					int l = sqlite3_column_bytes(_statement, (int)column) ;
					if (l) {
						if (aBuffer) { 
              CBufferAppendBytes((CBuffer*)aBuffer, bytes, (NSUInteger)l) ;
							good = YES;
						}
					}
					if (good) { error = MSFetchOK ; }
				}
				else { error = MSNullFetch ; }
				break ;
			}
			case SQLITE_NULL:
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

- (id)objectAtColumn:(NSUInteger)column
{
	if (_state == SQLITE_POSSIBLE_RESULT) {
		if (column < (NSUInteger)sqlite3_column_count(_statement)) {
			int type = sqlite3_column_type(_statement, (int)column) ;
			switch (type) {
				case SQLITE_FLOAT:
					return [NSNumber numberWithDouble:sqlite3_column_double(_statement, (int)column)] ;
				case SQLITE_INTEGER:
					return [NSNumber numberWithLongLong:(long long)sqlite3_column_int64(_statement, (int)column)] ;
				case SQLITE_TEXT:{
					const unsigned char *s = sqlite3_column_text(_statement, (int)column) ;
					if (s) {
            return *s ? [NSString stringWithCString:(char *)s encoding:NSUTF8StringEncoding] : @"";
          }
				}
				case SQLITE_BLOB:{
					void *bytes = (void *)sqlite3_column_blob(_statement, (int)column) ;
					if (bytes) {
						int l = sqlite3_column_bytes(_statement, (int)column) ;
						return l ? [NSData dataWithBytes:bytes length:(NSUInteger)l] : [NSData data] ;
					}
				}
				case SQLITE_NULL:
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

@end

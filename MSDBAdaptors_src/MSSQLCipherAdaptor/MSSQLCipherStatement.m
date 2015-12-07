
/*

 MSSQLCipherStatement.m

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

#import "MSSQLCipherAdaptorKit.h"

#define SQLCIPHER_SUCCESS(X) ({ int __ret__ = (X); BOOL __r__ = (__ret__ == SQLITE_OK || __ret__ == SQLITE_DONE); if(!__r__) [self error:[NSString stringWithUTF8String:sqlite3_errstr(__ret__)]]; __r__; })

@implementation MSSQLCipherStatement

- (id)initWithRequest:(NSString *)request withDatabaseConnection:(MSSQLCipherConnection *)connection withStmt:(sqlite3_stmt *)stmt
{
    if((self= [super initWithRequest:request withDatabaseConnection:connection])) {
        _stmt= stmt;
    }
    return self;
}

- (BOOL)bindChar:           (MSChar)value at:(MSUInt)parameterIndex { return SQLCIPHER_SUCCESS(sqlite3_bind_int(_stmt, (int)parameterIndex+1, (int)value)); }
- (BOOL)bindByte:           (MSByte)value at:(MSUInt)parameterIndex { return SQLCIPHER_SUCCESS(sqlite3_bind_int(_stmt, (int)parameterIndex+1, (int)value)); }
- (BOOL)bindShort:         (MSShort)value at:(MSUInt)parameterIndex { return SQLCIPHER_SUCCESS(sqlite3_bind_int(_stmt, (int)parameterIndex+1, (int)value)); }
- (BOOL)bindUnsignedShort:(MSUShort)value at:(MSUInt)parameterIndex { return SQLCIPHER_SUCCESS(sqlite3_bind_int(_stmt, (int)parameterIndex+1, (int)value)); }
- (BOOL)bindInt:             (MSInt)value at:(MSUInt)parameterIndex { return SQLCIPHER_SUCCESS(sqlite3_bind_int(_stmt, (int)parameterIndex+1, (int)value)); }
- (BOOL)bindUnsignedInt:    (MSUInt)value at:(MSUInt)parameterIndex { return SQLCIPHER_SUCCESS(sqlite3_bind_int64(_stmt, (int)parameterIndex+1, (sqlite3_int64)value)); }
- (BOOL)bindLong:           (MSLong)value at:(MSUInt)parameterIndex { return SQLCIPHER_SUCCESS(sqlite3_bind_int64(_stmt, (int)parameterIndex+1, (sqlite3_int64)value));}
- (BOOL)bindUnsignedLong:  (MSULong)value at:(MSUInt)parameterIndex {
    if(value <= MSLongMax) {
        return SQLCIPHER_SUCCESS(sqlite3_bind_int64(_stmt, (int)parameterIndex+1, (sqlite3_int64)value));
    }
    else {
        char buf[21];
        sqlite3_snprintf(21, buf, "%llu", value);
        return SQLCIPHER_SUCCESS(sqlite3_bind_text(_stmt, (int)parameterIndex+1, buf, (int)strlen(buf), SQLITE_TRANSIENT));
    }
}
- (BOOL)bindFloat:           (float)value at:(MSUInt)parameterIndex { return SQLCIPHER_SUCCESS(sqlite3_bind_double(_stmt, (int)parameterIndex+1, (double)value)); }
- (BOOL)bindDouble:         (double)value at:(MSUInt)parameterIndex { return SQLCIPHER_SUCCESS(sqlite3_bind_double(_stmt, (int)parameterIndex+1, value)); }
- (BOOL)bindDate:          (MSDate *)date at:(MSUInt)parameterIndex
{
    sqlite3_int64 value;
    value= [date secondsSinceDate:(MSDate *)CDate19700101];
    return SQLCIPHER_SUCCESS(sqlite3_bind_int64(_stmt, (int)parameterIndex+1, value));
}

- (BOOL)bindString:     (NSString*)string at:(MSUInt)parameterIndex
{
    NSData *data= [string dataUsingEncoding:NSUTF8StringEncoding];
    return SQLCIPHER_SUCCESS(sqlite3_bind_text(_stmt, (int)parameterIndex+1, [data bytes], (int)[data length], SQLITE_TRANSIENT));
}

- (BOOL)bindBuffer:     (MSBuffer*)buffer at:(MSUInt)parameterIndex
{
    return SQLCIPHER_SUCCESS(sqlite3_bind_blob(_stmt, (int)parameterIndex+1, [buffer bytes], (int)[buffer length], SQLITE_TRANSIENT));
}

- (BOOL)bindNullAt:(MSUInt)parameterIndex
{
    return SQLCIPHER_SUCCESS(sqlite3_bind_null(_stmt, (int)parameterIndex+1));
}

- (MSDBResultSet *)fetch
{
    return AUTORELEASE([ALLOC(MSSQLCipherResultSet) initWithStatement:_stmt withConnection:(MSSQLCipherConnection *)_connection withMSStatement:self]);
}

- (MSInt)execute
{
    int ret;
    ret= sqlite3_step(_stmt);
    while (ret == SQLITE_ROW)
        ret= sqlite3_step(_stmt);
    if(SQLCIPHER_SUCCESS(ret)) {
        return [(MSSQLCipherConnection *)_connection affectedRows];
    }
    return MSSQL_ERROR;
}

- (void)terminateOperation
{
    sqlite3_finalize(_stmt);
    _stmt= NULL;
    [super terminateOperation] ;
}

@end

/*
 
 MSODBCConnection.m
 
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
#import "MSODBCConnection.h"

#ifdef WIN32
#else
#import <iODBC/sql.h>
#import <iODBC/sqlext.h>
#import <iODBC/sqltypes.h>
#import <iODBC/sqlucode.h>
#endif


#import <MSFoundation/MSUnichar.h>
#import "MSODBCTransaction.h"
#import "MSODBCResultSet.h"
#import "MSODBCConnection.h"
#import "_MSODBCConnectionPrivate.h"

#define NS2TEXT(S) [(_MSDBGenericConnection *)self sqlCStringWithString:S]

#define TEXT2NS(C)	[NSString stringWithCString:(const char *)C encoding:_readEncoding]

@implementation MSODBCConnection

#ifdef WIN32
+ (void)initialize
{
    initializeOdbcLibraryForWin32() ;
}
#endif

- (SQLHDBC)hdbc { return _hdbc; }

- (void)logError:(NSString *)fn hstmt:(HSTMT)hstmt
{
    SQLINTEGER i = 0;
    SQLINTEGER native;
    SQLTCHAR state[7];
    SQLTCHAR text[1024];
    SQLSMALLINT len;
    SQLRETURN ret;

    NSLog(@"The driver reported the following diagnostics while running %@",fn);
	
    do
    {
        ret = SQLGetDiagRec(SQL_HANDLE_STMT, hstmt, ++i, state, &native, text,sizeof(text), &len );
        if (SQL_SUCCEEDED(ret))
            NSLog(@"%s:%d:%d:%s\n", state, (int)i, (int)native, text);
    }
    while( ret == SQL_SUCCESS );
	

    do
    {
        ret = SQLGetDiagRec(SQL_HANDLE_DBC, _hdbc, ++i, state, &native, text,sizeof(text), &len );
        if (SQL_SUCCEEDED(ret))
            NSLog(@"%@:%d:%d:%@\n", TEXT2NS(state), (int)i, (int)native, TEXT2NS(text));
    }
    while( ret == SQL_SUCCESS );

    do
    {
        ret = SQLGetDiagRec(SQL_HANDLE_ENV, _henv, ++i, state, &native, text,sizeof(text), &len );
        if (SQL_SUCCEEDED(ret))
            NSLog(@"%@:%d:%d:%@\n", TEXT2NS(state), (int)i,(int)native, TEXT2NS(text));
    }
    while( ret == SQL_SUCCESS );
}

- (id)initWithConnectionDictionary:(NSDictionary *)dictionary
{
    if ((self = [super initWithConnectionDictionary:dictionary])) {
        NSString *cnxstr = [dictionary objectForLazyKey:@"connectionString"] ;
        NSMutableDictionary *tDict ;
        _MSODBCThreadContext *context ;

        if (![cnxstr length]) {
            RELEASE(self) ;
            return nil ;
        }

        tDict = [[NSThread currentThread] threadDictionary] ;
        context = [tDict objectForKey:@"_$odbcContext"] ;

        if (!context) {
            // creation de l'env
            context = [ALLOC(_MSODBCThreadContext) init] ;
            if (context) {
                [tDict setObject:context forKey:@"_$odbcContext"] ;
                RELEASE(context) ;
            }
            else {
                RELEASE(self) ;
                return nil ;
            }
        }
        _henv = [context environnement] ;


        [_currentDictionary setObject:cnxstr forKey:@"$_connectionString"] ;
        _cFlags.readOnly = [[dictionary objectForLazyKey:@"read-only"] isTrue] || [[dictionary objectForLazyKey:@"readonly"] isTrue] ;
    }
    return self ;
}

- (BOOL)_connectWithConnectionString:(NSString *)cnxStr
{
    SQLTCHAR dataSource[4096];
    SQLSMALLINT dsLen;

    if (!SQL_SUCCEEDED(SQLAllocHandle (SQL_HANDLE_DBC, _henv, &_hdbc))) return NO;

    //must be before the SQLSetConnectAttr functions
    if (!SQL_SUCCEEDED(SQLDriverConnect(_hdbc, 0,(SQLCHAR *)NS2TEXT(cnxStr), SQL_NTS, dataSource, sizeof (dataSource), &dsLen, SQL_DRIVER_COMPLETE))) return NO;

    if (!SQL_SUCCEEDED(SQLSetConnectAttr(_hdbc, SQL_ATTR_AUTOCOMMIT,(SQLPOINTER)SQL_AUTOCOMMIT_OFF,SQL_IS_UINTEGER))) return NO;

    if (_cFlags.readOnly) {
        if (!SQL_SUCCEEDED(SQLSetConnectAttr(_hdbc, SQL_ATTR_ACCESS_MODE, (SQLPOINTER)SQL_MODE_READ_ONLY,SQL_IS_UINTEGER))) return NO;
    }

    return YES;
}

- (BOOL)connect
{
    if (![self isConnected]) {
        NSString *cnxstr = [_currentDictionary objectForKey:@"$_connectionString"] ;

        if (![self _connectWithConnectionString:cnxstr]) {
            [self logError:@"" hstmt:nil];
            _lastError = ODBCFailAtOpen ;
            _hdbc = NULL ;
            return NO ;
        }
        _cFlags.connected = YES ;
        [[NSNotificationCenter defaultCenter] postNotificationName:MSConnectionDidConnectNotification object:self] ;
    }
    return YES ;
}


-(BOOL) _disconnect
{
    if (_hdbc) {
        if (!SQL_SUCCEEDED(SQLDisconnect(_hdbc))) return NO;
        if (!SQL_SUCCEEDED(SQLFreeHandle (SQL_HANDLE_DBC, _hdbc))) return NO;
    }
    return YES;
}


- (BOOL)disconnect
{
    if ([self isConnected]) {
        RETAIN(self) ; // since the terminateAllOperations can release us, we must keep that object alive until we decide to release it
        [self terminateAllOperations] ;

        if (![self _disconnect]){
            [self logError:@"" hstmt:nil];
            _lastError = ODBCFailAtClose ;
            return NO ;
        }
        _hdbc = NULL ;
        _cFlags.connected = NO ;
        [[NSNotificationCenter defaultCenter] postNotificationName:MSConnectionDidDisconnectNotification object:self] ;
        RELEASE(self) ;
    }
    return YES ;
}


- (MSDBTransaction *)openTransaction
{
    if (!_cFlags.readOnly && [self connect] && [self openedTransactionsCount] == 0) {
        // only one transaction at a time
        MSODBCTransaction *transaction = [ALLOC(MSODBCTransaction) initWithDatabaseConnection:self] ;
        if (transaction) {
            CArrayAddObjectWithoutRetain(&_operations, transaction) ;
            return transaction;
        }
    }
    return nil ;
}

-(MSDBResultSet *)fetchWithStatement:(HSTMT)statement
{
    MSODBCResultSet *resultSet ;
    resultSet = [ALLOC(MSODBCResultSet) initWithStatement:statement connection:self] ;
    if (resultSet) {
        // === WARNING === the connection does not retain its operations...
        CArrayAddObjectWithoutRetain(&_operations, resultSet) ;
        return AUTORELEASE(resultSet) ;
    }
    return nil ;
}

- (MSDBResultSet *)fetchWithRequest:(NSString *)query
{
    SQLHSTMT hstmt;
    if ([query length] && [self connect]) {
        if (SQL_SUCCEEDED(SQLAllocHandle(SQL_HANDLE_STMT, _hdbc, &hstmt)))
        {
            if (SQL_SUCCEEDED(SQLExecDirect(hstmt,(SQLCHAR *)NS2TEXT(query),SQL_NTS))) {
                return [self fetchWithStatement:hstmt];
            } else {
                NSLog(@"Error in sql request %@",query);
            }
        }
    }
    return nil ;
}

- (MSArray *)tableNames
{
    MSArray *array = MSCreateArray(8) ;
    MSDBResultSet *set ;
    HSTMT hstmt = NULL;
    NEW_POOL ;

    if (SQL_SUCCEEDED(SQLAllocHandle(SQL_HANDLE_STMT, _hdbc, &hstmt)))
    {
        // only tables, no views
        //NSLog(@"hstmt = %u",(int)hstmt);

        if (SQL_SUCCEEDED(SQLTables(hstmt,
                                    (SQLCHAR *)NULL, 0, //NULL, 0, // no specific catalog
                                    (SQLCHAR *)NULL, 0, //NULL, 0, // no specific schema
                                    (SQLCHAR *)NULL, 0, //NULL, 0, // no specific table
                                    (SQLCHAR *)"TABLE", 5)))
        {
            set = [self fetchWithStatement:hstmt];
            while ([set nextRow]) {
                NSString *s = [[set objectAtColumn:2] toString] ;
                if ([s length]) { MSAAdd(array,s) ; }
            }
        }
    }

    KILL_POOL ;

    return AUTORELEASE(array) ;
}


@end

@implementation _MSODBCThreadContext


- (void)freeEnv
{
    if (_henv){
        if (!SQL_SUCCEEDED(SQLFreeHandle (SQL_HANDLE_ENV, _henv))) { NSLog(@"Unable to free environnement handle"); };
        _henv= NULL;
    }
}

- (id)init
{
    if (!SQL_SUCCEEDED(SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &_henv))) { _henv = NULL ; RELEASE(self) ; return nil ; }
    if (!SQL_SUCCEEDED(SQLSetEnvAttr(_henv, SQL_ATTR_ODBC_VERSION, (SQLPOINTER)SQL_OV_ODBC3, SQL_IS_UINTEGER)))
    { [self freeEnv] ; RELEASE(self) ; return nil ; }

    return self ;
}


- (void)dealloc
{
    [self freeEnv];
    [super dealloc] ;
}

- (HSTMT)environnement { return _henv ; }

@end

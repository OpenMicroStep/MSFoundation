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

#import "MSODBCAdaptorKit.h"
#import "_MSODBCConnectionPrivate.h"

@implementation MSODBCConnection

#define ODBC_SUCCEEDED(HANDLE_TYPE, HANDLE, METHOD, ARGS...) ({ BOOL __r__ = SQL_SUCCEEDED(METHOD(ARGS)); if(!__r__) [self error:_cmd desc:@#METHOD @" failed" handleType:HANDLE_TYPE handle:HANDLE]; __r__; })
#define ODBC_SUCCEEDED_DBC(METHOD, ARGS...) ODBC_SUCCEEDED(SQL_HANDLE_DBC, _hdbc, METHOD, ARGS)
#define ODBC_SUCCEEDED_ENV(METHOD, ARGS...) ODBC_SUCCEEDED(SQL_HANDLE_ENV, _henv, METHOD, ARGS)
#define ODBC_SUCCEEDED_STMT(STMT, METHOD, ARGS...) ODBC_SUCCEEDED(SQL_HANDLE_STMT, STMT, METHOD, ARGS)

- (void)error:(SEL)inMethod desc:(NSString *)desc handleType:(SQLSMALLINT)handleType handle:(SQLHANDLE)handle
{
    SQLSMALLINT i = 0;
    SQLINTEGER native;
    SQLCHAR state[7];
    SQLCHAR text[1024];
    SQLSMALLINT len;
    SQLRETURN ret;
    NSMutableString *error;
    
    error= [NSMutableString stringWithFormat:@"%@-> %@: ", NSStringFromSelector(inMethod), desc];
    do
    {
        ret = SQLGetDiagRec(handleType, handle, ++i, state, &native, text,sizeof(text), &len );
        if(ret == SQL_SUCCESS_WITH_INFO && len) {
            SQLCHAR *longText= MSMalloc(sizeof(SQLCHAR) * len, "error:desc:handleType:handle:");
            ret= SQLGetDiagRec(handleType, handle, ++i, state, &native, longText,len, &len);
            [error appendFormat:@"%s:%d:%d:%s;", state, (int)i, (int)native, longText];
            MSFree(longText, "error:desc:handleType:handle:");
        } else if (SQL_SUCCEEDED(ret)) {
            [error appendFormat:@"%s:%d:%d:%s;", state, (int)i, (int)native, text];
        }
    }
    while( ret == SQL_SUCCESS );
  
    [self error:inMethod desc:error];
}

- (id)initWithConnectionDictionary:(MSDictionary *)dictionary
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
        _cFlags.usr1 = YES;
        _cFlags.readOnly = [[dictionary objectForLazyKey:@"read-only"] isTrue] || [[dictionary objectForLazyKey:@"readonly"] isTrue] ;
    }
    return self ;
}

- (BOOL)_connectWithConnectionString:(NSString *)cnxStr
{
    BOOL ret;
    SQLCHAR dataSource[4096];
    SQLSMALLINT dsLen;
    
    if(!ODBC_SUCCEEDED_ENV(SQLAllocHandle, SQL_HANDLE_DBC, _henv, &_hdbc))
      return NO;
    
    ret= ODBC_SUCCEEDED_DBC(SQLDriverConnect, _hdbc, 0,(SQLCHAR *)[self sqlCStringWithString:cnxStr], SQL_NTS, dataSource, sizeof (dataSource), &dsLen, SQL_DRIVER_COMPLETE);
    if(ret) {
      ret= ODBC_SUCCEEDED_DBC(SQLSetConnectAttr, _hdbc, SQL_ATTR_AUTOCOMMIT, (SQLPOINTER)SQL_AUTOCOMMIT_OFF, SQL_IS_UINTEGER);
      if(ret && _cFlags.readOnly)
        ret= ODBC_SUCCEEDED_DBC(SQLSetConnectAttr, _hdbc, SQL_ATTR_ACCESS_MODE, (SQLPOINTER)SQL_MODE_READ_ONLY,SQL_IS_UINTEGER);
      if(!ret)
        ODBC_SUCCEEDED_DBC(SQLDisconnect, _hdbc);
    }
    
    if(!ret) {
        ODBC_SUCCEEDED_DBC(SQLFreeHandle, SQL_HANDLE_DBC, _hdbc);
        _hdbc= NULL;
    }
    return ret;
}

- (BOOL)connect
{
    if (!_cFlags.connected) {
        NSString *cnxstr = [_currentDictionary objectForKey:@"$_connectionString"] ;
        if (![self _connectWithConnectionString:cnxstr])
            return NO ;
        _cFlags.connected = YES ;
        [[NSNotificationCenter defaultCenter] postNotificationName:MSConnectionDidConnectNotification object:self] ;
    }
    return YES ;
}

- (BOOL)_disconnect
{
    BOOL ret;
    ret= ODBC_SUCCEEDED_DBC(SQLDisconnect, _hdbc)
      && ODBC_SUCCEEDED_DBC(SQLFreeHandle, SQL_HANDLE_DBC, _hdbc);
    if(ret) _hdbc= NULL;
    return ret;
}

- (BOOL)beginTransaction
{
    return YES;
}

- (BOOL)commit
{
    return ODBC_SUCCEEDED_DBC(SQLEndTran, SQL_HANDLE_DBC, _hdbc, SQL_COMMIT);
}

- (BOOL)rollback
{
    return ODBC_SUCCEEDED_DBC(SQLEndTran, SQL_HANDLE_DBC, _hdbc, SQL_ROLLBACK);
}

- (BOOL)isInTransaction
{
    return YES;
}

- (MSDBStatement *)statementWithRequest:(NSString *)request
{
    if ([request length] && [self connect]) {
        SQLHSTMT hstmt;
        if (ODBC_SUCCEEDED_DBC(SQLAllocHandle, SQL_HANDLE_STMT, _hdbc, &hstmt)
         && ODBC_SUCCEEDED_STMT(hstmt, SQLPrepare, hstmt,(SQLCHAR *)[self sqlCStringWithString:request],SQL_NTS))
                return AUTORELEASE([ALLOC(MSODBCStatement) initWithRequest:request withDatabaseConnection:self withStmt:hstmt]);
    }
    return nil ;
}

-(MSDBResultSet *)fetchWithStatement:(HSTMT)statement
{
    return AUTORELEASE([ALLOC(MSODBCResultSet) initWithStatement:statement withConnection:self withMSStatement:nil]) ;
}

- (MSDBResultSet *)fetchWithRequest:(NSString *)query
{
    SQLHSTMT hstmt;
    if ([query length] && [self connect]) {
        if (ODBC_SUCCEEDED_DBC(SQLAllocHandle, SQL_HANDLE_STMT, _hdbc, &hstmt)) {
            if (ODBC_SUCCEEDED_STMT(hstmt, SQLExecDirect, hstmt,(SQLCHAR *)[self sqlCStringWithString:query],SQL_NTS)) {
                return [self fetchWithStatement:hstmt];
            }
        }
    }
    return nil ;
}

- (MSArray *)tableNames
{
    CArray *array = CCreateArray(8) ;
    MSDBResultSet *set ;
    HSTMT hstmt = NULL;
    NEW_POOL ;
    
    if (ODBC_SUCCEEDED_DBC(SQLAllocHandle, SQL_HANDLE_STMT, _hdbc, &hstmt))
    {
        if (ODBC_SUCCEEDED_STMT(hstmt, SQLTables, hstmt,
                                                 (SQLCHAR *)NULL, 0, //NULL, 0, // no specific catalog
                                                 (SQLCHAR *)NULL, 0, //NULL, 0, // no specific schema
                                                 (SQLCHAR *)NULL, 0, //NULL, 0, // no specific table
                                                 (SQLCHAR *)"TABLE", 5))
        {
            set = [self fetchWithStatement:hstmt];
            while ([set nextRow]) {
                NSString *s = [[set objectAtColumn:2] toString] ;
                if ([s length]) { CArrayAddObject(array,s) ; }
            }
        }
    }
    
    KILL_POOL ;
    
    return AUTORELEASE(array) ;
}

- (NSString *)escapeString:(NSString *)aString withQuotes:(BOOL)withQuotes ;
{
    if (aString) {
        SES ses = SESFromString(aString) ;
        if (SESOK(ses)) {
            NSUInteger i, len = SESLength(ses) ;
            CString *result = CCreateString(len+(withQuotes?2:0)) ;
            unichar c ;
            
            if (withQuotes) { CStringAppendCharacter(result, 0x0027) ; }
            for (i = 0 ; i < len ; ) {
                c = SESIndexN(ses, &i) ;
                CStringAppendCharacter(result, c) ;
                if (c == 0x0027) { CStringAppendCharacter(result, 0x0027) ; }
            }
            if (withQuotes) { CStringAppendCharacter(result, 0x0027) ; }
            
            return AUTORELEASE((id)result) ;
        }
        return withQuotes ? @"''" : @"" ;
    }
    return nil ;
}



- (MSInt)executeRawSQL:(NSString *)sql
{
    BOOL ret = NO ;
    if ([self connect]) {
        HSTMT hstmt;
        
        ret = ODBC_SUCCEEDED_DBC(SQLAllocHandle, SQL_HANDLE_STMT, _hdbc, &hstmt)
           && ODBC_SUCCEEDED_STMT(hstmt, SQLExecDirect, hstmt,(SQLCHAR *)[self sqlCStringWithString:sql],SQL_NTS);
        if (hstmt)
            ODBC_SUCCEEDED_STMT(hstmt, SQLFreeHandle, SQL_HANDLE_STMT, hstmt);
    }
    
    return ret ? 0 : -1 ;
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

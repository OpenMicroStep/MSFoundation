/*
 
 MSMySQLConnection.m
 
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

@implementation MSMySQLConnection

#pragma mark Connection

- (id)initWithConnectionDictionary:(MSDictionary *)dictionary
{
    if ((self= [super initWithConnectionDictionary:dictionary])) {
        NSString *host, *sock, *db, *user, *pwd, *timeout; id port;
        host=    [dictionary objectForLazyKeys:@"host", @"host-name", @"server", @"server-name", nil];
        port=    [dictionary objectForLazyKeys:@"port", nil];
        sock=    [dictionary objectForLazyKeys:@"sock", @"socket", nil];
        db=      [dictionary objectForLazyKeys:@"database", @"database-name", @"db", @"db-name", nil];
        user=    [dictionary objectForLazyKeys:@"user", @"user-name", @"login", nil];
        pwd=     [dictionary objectForLazyKeys:@"password", @"pwd", nil];
        timeout= [[dictionary objectForLazyKey:@"timeout"] description];
        
        if (![host length] || ![db length] || ![user length]) {
            RELEAZEN(self);
        }
        else {
            if (![timeout length]) timeout= [NSString stringWithFormat:@"%u",
                                             MYSQL_CONNECTION_DEFAULT_TIMEOUT];
            
                      [_currentDictionary setObject:host    forKey:@"$_host"];
            if (port) [_currentDictionary setObject:port    forKey:@"$_port"];
            if (sock) [_currentDictionary setObject:sock    forKey:@"$_sock"];
                      [_currentDictionary setObject:db      forKey:@"$_database"];
                      [_currentDictionary setObject:user    forKey:@"$_user"];
                      [_currentDictionary setObject:pwd     forKey:@"$_password"];
                      [_currentDictionary setObject:timeout forKey:@"$_timeout"];
        }
    }
    return self;
}

#define CLAMP(value, min, max) \
MIN(MAX(value, min), max)

static inline MSUInt _NSStringToMSUInt(NSString *str)
{
    return (MSUInt)CLAMP([str longLongValue], 0, MSUIntMax);
}

- (BOOL)connect
{
    if (!_cFlags.connected) {
        const char *host, *sock, *db, *user, *pwd;
        MSUInt timeout, port;
        host=    [[_currentDictionary objectForKey:@"$_host"    ] UTF8String];
        port=    _NSStringToMSUInt([_currentDictionary objectForKey:@"$_port"]);
        sock=    [[_currentDictionary objectForKey:@"$_sock"    ] UTF8String];
        db=      [[_currentDictionary objectForKey:@"$_database"] UTF8String];
        user=    [[_currentDictionary objectForKey:@"$_user"    ] UTF8String];
        pwd=     [[_currentDictionary objectForKey:@"$_password"] UTF8String];
        timeout= _NSStringToMSUInt([_currentDictionary objectForKey:@"$_timeout"]);
        
        if(mysql_init(&_db) != &_db)
            MSDB_RETURN_ERROR(NO, @"MYSQL object initialization failed");
        
        if(mysql_options(&_db, MYSQL_OPT_CONNECT_TIMEOUT, (const char *)&timeout) != MYSQL_RET_OK)
            NSLog(@"Unable to setup MYSQL_OPT_CONNECT_TIMEOUT to %u", timeout);
        
        if (!(mysql_real_connect(&_db, host, user, pwd, db, port, sock, 0))) {
            MSDB_ERROR_ARGS(@"MySQL database could not be opened: %s", mysql_error(&_db));
            mysql_close(&_db);
        }
        else {
            my_bool enableTruncation= 0;
            
            //force use of UTF8 character set
            mysql_query(&_db, "SET NAMES utf8");
            mysql_query(&_db, "SET CHARACTER SET utf8");
            // Si l'autocommit ne peut pas être off, c'est pas grave, openTransaction
            // quoiqu'il arrive s'en charge.
            if (mysql_autocommit(&_db, 0) != MYSQL_RET_OK) {
                NSLog(@"Warning: Unable to remove auto-commit mode!");
            }
            
            if(mysql_options(&_db, MYSQL_REPORT_DATA_TRUNCATION, &enableTruncation) != MYSQL_RET_OK) {
                NSLog(@"Warning: Unable to remove report data truncation!");
            }
            
            _cFlags.connected= YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:MSConnectionDidConnectNotification object:self];
        }
    }
    
    return (BOOL)_cFlags.connected;
}

- (BOOL)_disconnect
{
    mysql_close(&_db);
    return YES;
}

#pragma mark Scheme

- (MSArray *)tableNames
{
	MSArray *array= [MSArray mutableArray];
    MYSQL_RES *result;
    NEW_POOL;
    
    if(![self connect])
        return nil;
    
    result= mysql_list_tables(&_db, NULL);
    if (result) {
        MSUInt num_fields; MYSQL_ROW row; NSUInteger *lengths; MSUInt i; NSString *tableName;
        num_fields= mysql_num_fields(result);
        while ((row= mysql_fetch_row(result))) {
            lengths= mysql_fetch_lengths(result);
            for (i= 0; i < num_fields; i++) {
                tableName= [NSString stringWithFormat:@"%.*s ", (MSInt)lengths[i], row[i] ? row[i] : "NULL"];
                tableName= [tableName trim];
                if ([tableName length]) [array addObject:tableName];}}
        mysql_free_result(result);}
    
    KILL_POOL;
    return (MSArray*)array;
}

#pragma mark Transaction

#define MYSQL_SUCCEEDED(code)  ({ BOOL __x__= (code == 0); if(!__x__) [self error:_cmd desc:[NSString stringWithUTF8String:mysql_error(&_db)]]; __x__; })
#define MYSQL_SUCCEEDED_STMT(stmt, code)  ({ BOOL __x__= (code == 0); if(!__x__) [self error:_cmd desc:[NSString stringWithUTF8String:mysql_stmt_error(stmt)]]; __x__; })

- (BOOL)beginTransaction
{
    BOOL ret= [self executeRawSQL:@"START TRANSACTION"] != MSSQL_ERROR;
    if(ret) _cFlags.inTransaction= YES;
    return ret;
}

- (BOOL)commit
{
    BOOL ret= [self connect] && MYSQL_SUCCEEDED(mysql_commit(&_db));
    if(ret) _cFlags.inTransaction= NO;
    return ret;
}

- (BOOL)rollback
{
    BOOL ret= [self connect] && MYSQL_SUCCEEDED(mysql_rollback(&_db));
    if(ret) _cFlags.inTransaction= NO;
    return ret;
}

#pragma mark Request

- (MSDBStatement *)statementWithRequest:(NSString *)request
{
    if ([self connect] && [request length]) {
        NSData *d= [connection sqlDataFromString:request];
        MYSQL_STMT *stmt= mysql_stmt_init(&_db);
        if(mysql_stmt_prepare(stmt, [d bytes], [d length]) == MYSQL_RET_OK)
            return AUTORELEASE([ALLOC(MSSQLCipherStatement) initWithRequest:request withDatabaseConnection:self withStmt:stmt]);
        else
            MSDB_ERROR_ARGS(@"Unable to prepare statement '%@': %s", request, sqlite3_errmsg(_db));
    }
    return nil ;
}

- (MSDBResultSet *)fetchWithRequest:(NSString *)sql
{
    MYSQL_STMT *stmt;
    NSData *request;
    
    if(![self connect])
        return nil;
    
    stmt= mysql_stmt_init(&_db);
    if(!stmt) {
        [self error:_cmd desc:[NSString stringWithUTF8String:mysql_error(&_db)]];
        return nil;
    }
    
    request= [self sqlDataFromString:sql];
    if (MYSQL_SUCCEEDED_STMT(stmt, mysql_stmt_prepare(stmt, [request bytes], [request length]) == MYSQL_RET_OK)
     && MYSQL_SUCCEEDED_STMT(stmt, mysql_stmt_execute(stmt))) {
        return AUTORELEASE([ALLOC(MSMySQLResultSet) initWithStatement:stmt withConnection:self withMSStatement:nil]);
    }
    return nil;
}

- (MSInt)executeRawSQL:(NSString *)command {
    if(![self connect])
        return MSSQL_ERROR;
    if(mysql_query(&_db, [command UTF8String]) != MYSQL_RET_OK) {
        MSDB_ERROR_ARGS(@"Unable to execute request '%@': %s", command, mysql_error(&_db));
        return MSSQL_ERROR;
    }
    return MSSQL_OK;
}

- (NSString *)escapeString:(NSString *)aString withQuotes:(BOOL)withQuotes
{
    if (aString && [self connect]) {
        NSString *stringToEscape, *escapeString ;
        const char* strToEscape ;
        char *escapeStr ;
        MSULong escapeLen ;
        size_t l ;
        /*
         if (withQuotes)
         {
         stringToEscape = [NSString stringWithFormat:@"'%@'", aString] ;
         }
         else
         {
         stringToEscape = aString ;
         }
         */
        stringToEscape = aString ;
        strToEscape = [stringToEscape UTF8String] ;
        l = strlen(strToEscape) ;
        // TODO: a revoir car 2*l peut ne pas suffir.
        // De plus, ce n'est pas la peine de créer 2 fois des strings pour juste
        // rajouter les "". Il suffit de mysql_real_escape_string(... escapeStr+1 ...)
        escapeStr = MSMalloc((2*l+1)*sizeof(char), "- [MSMySQLConection escapeString:withQuotes:]");
        
        escapeLen = mysql_real_escape_string(&_db, escapeStr, strToEscape, l);
        escapeString = [NSString stringWithCString:escapeStr encoding:NSUTF8StringEncoding] ;
        if (withQuotes)
            escapeString = [NSString stringWithFormat:@"\"%@\"", escapeString] ;
        MSFree(escapeStr, "- [MSMySQLConection escapeString:withQuotes:]"); 
        
        return escapeString ;
    }
    return nil ;
}

@end

/************************** TO DO IN THIS FILE  ****************
 
 (1)	check to implemente read only access to database if possible
 
 *************************************************************/

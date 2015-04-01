/*
 
 MSSQLiteConnection.m
 
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

@implementation MSSQLCipherConnection

#pragma mark Connection

- (id)initWithConnectionDictionary:(MSDictionary *)dictionary
{
    NSString* key = nil ;
    
    if ((self = [super initWithConnectionDictionary:dictionary])) {
        NSString *path = [dictionary objectForLazyKey:@"path"] ;
        if (!path) { path = [dictionary objectForLazyKey:@"db-path"] ;}
        if (!path) { path = [dictionary objectForLazyKey:@"database-path"] ;}
        if (![path length]) {
            RELEASE(self) ;
            return nil ;
        }
        
        key = [dictionary objectForLazyKey:@"key"] ;
        
        [_currentDictionary setObject:path forKey:@"$_db"] ;
        if (key) [_currentDictionary setObject:key forKey:@"$_key"] ;
        
        _cFlags.readOnly = [[dictionary objectForLazyKey:@"read-only"] isTrue] || [[dictionary objectForLazyKey:@"readonly"] isTrue] ;
    }
    return self ;
}

- (BOOL)connect
{
    if (!_cFlags.connected) {
        int flags = (_cFlags.readOnly ? SQLITE_OPEN_READONLY : SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE) ;
        const char *dbpath = [[_currentDictionary objectForKey:@"$_db"] fileSystemRepresentation] ;
        const char *key = [[_currentDictionary objectForKey:@"$_key"] fileSystemRepresentation] ;
        if (sqlite3_open_v2(dbpath, &_db, flags, NULL) != SQLITE_OK) {
            MSDB_ERROR_ARGS(@"Unable to open database: %s", sqlite3_errmsg(_db));
        } else if (key && sqlite3_key(_db, key, (int)strlen(key)) != SQLITE_OK) {
            MSDB_ERROR(@"Unable to setup sqlite3 encryption key");
        } else if(sqlite3_exec(_db, "SELECT count(*) FROM sqlite_master;", NULL, NULL, NULL) != SQLITE_OK) {
            MSDB_ERROR(@"Unable to open database: incorrect key");
        } else{
            _cFlags.connected = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:MSConnectionDidConnectNotification object:self] ;
        }
        if(!_cFlags.connected) {
            // TODO: Upadate sqlite3, so sqlite3_close_v2 can be used
            sqlite3_close_v2(_db);
            _db= NULL;
        }
    }
    return _cFlags.connected ;
}

- (BOOL)_disconnect
{
    sqlite3_close_v2(_db);
    _db = NULL ;
    return YES;
}

#pragma mark Scheme

- (MSArray *)tableNames
{
    CArray *array = CCreateArray(8) ;
    MSDBResultSet *set ;
    NEW_POOL ;
    
    set = [self fetchWithRequest:@"SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"] ;
    while ([set nextRow]) {
        NSString *s = [[set objectAtColumn:0] toString] ;
        if ([s length]) { CArrayAddObject(array, s) ; }
    }
    
    KILL_POOL ;
    
    return AUTORELEASE((MSArray*)array) ;
}

#pragma mark Transaction

- (BOOL)beginTransaction
{
    BOOL ret= [self executeRawSQL:@"BEGIN TRANSACTION"] != MSSQL_ERROR;
    if(ret) _cFlags.inTransaction= YES;
    return ret;
}

- (BOOL)commit
{
    BOOL ret= [self executeRawSQL:@"COMMIT"] != MSSQL_ERROR;
    if(ret) _cFlags.inTransaction= NO;
    return ret;
}

- (BOOL)rollback
{
    BOOL ret= [self executeRawSQL:@"ROLLBACK"] != MSSQL_ERROR;
    if(ret) _cFlags.inTransaction= NO;
    return ret;
}

#pragma mark Request

- (MSDBStatement *)statementWithRequest:(NSString *)request
{
    if ([self connect] && [request length]) {
        const char *query = [request UTF8String];
        sqlite3_stmt *stmt;
        if(sqlite3_prepare_v2(_db, query, -1, &stmt, NULL) == SQLITE_OK)
            return AUTORELEASE([ALLOC(MSSQLCipherStatement) initWithRequest:request withDatabaseConnection:self withStmt:stmt]);
        else
            MSDB_ERROR_ARGS(@"Unable to prepare statement '%@': %s", request, sqlite3_errmsg(_db));
    }
    return nil ;
}

- (MSDBResultSet *)fetchWithRequest:(NSString *)request
{
    if ([request length]) {
        const char *query = [request UTF8String];
        sqlite3_stmt *stmt;
        if(sqlite3_prepare_v2(_db, query, -1, &stmt, NULL) == SQLITE_OK)
            return AUTORELEASE([ALLOC(MSSQLCipherResultSet) initWithStatement:stmt withConnection:self withMSStatement:nil]) ;
        else
            MSDB_ERROR_ARGS(@"Unable to prepare statement '%@': %s", request, sqlite3_errmsg(_db));
    }
    return nil ;
}

- (MSInt)affectedRows
{
    return sqlite3_changes(_db);
}

- (MSInt)executeRawSQL:(NSString *)command
{
    char *errMsg= NULL; int ret;
    if((ret= sqlite3_exec(_db, [command UTF8String], NULL, NULL, &errMsg)) != SQLITE_OK) {
        MSDB_ERROR_ARGS(@"Unable to execute request '%@': %d %p %s", command, ret, _db, errMsg);
        sqlite3_free(errMsg);
        return -1;
    }
    return 0;
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

@end
/************************** TO DO IN THIS FILE  ****************
 
 (1)	verify we don't need to protect sqlite3_ functions from raising exceptions...
 (2)	in URI mode should we keep fileSystemRepresentation or use UTF8 for the URL ?
 
 *************************************************************/


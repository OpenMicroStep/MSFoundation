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
#import "MSSQLiteTransaction.h"
#import "MSSQLiteResultSet.h"
#import "MSSQLiteConnection.h"


@implementation MSSQLiteConnection

- (id)initWithConnectionDictionary:(NSDictionary *)dictionary
{
	if ((self = [super initWithConnectionDictionary:dictionary])) {
		NSString *path = [dictionary objectForLazyKey:@"path"] ;
		if (!path) { path = [dictionary objectForLazyKey:@"db-path"] ;}
		if (!path) { path = [dictionary objectForLazyKey:@"database-path"] ;}
		if (![path length]) {
			RELEASE(self) ;
			return nil ;
		}
		[_currentDictionary setObject:path forKey:@"$_db"] ;
		_cFlags.readOnly = [[dictionary objectForLazyKey:@"read-only"] isTrue] || [[dictionary objectForLazyKey:@"readonly"] isTrue] ;
	}
	return self ;
}

- (BOOL)connect
{
	if (![self isConnected]) {
		int flags = (_cFlags.readOnly ? SQLITE_OPEN_READONLY : SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE) ;
		const char *dbpath = [[_currentDictionary objectForKey:@"$_db"] fileSystemRepresentation] ;
		int result ;

		if ((result = sqlite3_open_v2(dbpath, &_db, flags, NULL)) != SQLITE_OK) {
			const char *errorMsg = sqlite3_errmsg(_db);
			NSLog(@"SQLite database could not be opened for reason : %@",[NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]);
			sqlite3_close(_db);
			_lastError = SQLiteFailAtOpen ;
			_db = NULL ;
			return NO ;
		}
		_cFlags.connected = YES ;
		[[NSNotificationCenter defaultCenter] postNotificationName:MSConnectionDidConnectNotification object:self] ;
	}
	return YES ;
}

- (BOOL)disconnect
{
	if ([self isConnected]) {
		RETAIN(self) ; // since the terminateAllOperations can release us, we must keep that object alive until we decide to release it
		[self terminateAllOperations] ;
		
		if (sqlite3_close(_db) != SQLITE_OK){
			const char *errorMsg = sqlite3_errmsg(_db);
			NSLog(@"SQLite database could not be closed for reason: %@",[NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]);
			_lastError = SQLiteFailAtClose ;
			return NO ;
		}
		_db = NULL ;
		_cFlags.connected = NO ;
		[[NSNotificationCenter defaultCenter] postNotificationName:MSConnectionDidDisconnectNotification object:self] ;
		RELEASE(self) ;
	}
	return YES ;
}

- (MSDBResultSet *)fetchWithRequest:(NSString *)sql 
{
	if ([sql length] && [self connect]) {
		const char *query = [sql UTF8String];
		sqlite3_stmt *statement;
		MSSQLiteResultSet *resultSet ;
		
		sqlite3_prepare_v2(_db, query, -1, &statement, NULL);
		
		resultSet = [ALLOC(MSSQLiteResultSet) initWithStatement:statement connection:self] ;
		if (resultSet) {
			// === WARNING === the connection does not retain its operations...
			[_operations addObject:resultSet] ;
			return AUTORELEASE(resultSet) ;
		}
	}
	return nil ;
}

- (MSInt)executeRawSQL:(NSString *)command
{
  return sqlite3_exec(_db, [command UTF8String], NULL, NULL, NULL);
}


- (MSDBTransaction *)openTransaction
{
	if (!_cFlags.readOnly && [self connect] && [self openedTransactionsCount] == 0) {
		// only one transaction at a time
		if ([self executeRawSQL:@"BEGIN TRANSACTION;"] == MSSQL_OK) {
			MSSQLiteTransaction *transaction = [ALLOC(MSSQLiteTransaction) initWithDatabaseConnection:self] ;
			if (transaction) {
				[_operations addObject:transaction] ;
				return transaction;
			}
		}
	}
	return nil ;
}

- (MSArray *)tableNames
{
	MSArray *array = MSCreateArray(8) ;
	MSDBResultSet *set ;
	NEW_POOL ;
	
	set = [self fetchWithRequest:@"SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"] ;
	while ([set nextRow]) {
		NSString *s = [[set objectAtColumn:0] toString] ;
		if ([s length]) { MSAAdd(array,s) ; }
	}
	
	KILL_POOL ;
	
	return AUTORELEASE(array) ;
}

- (NSString *)escapeString:(NSString *)aString withQuotes:(BOOL)withQuotes ;
{
	if (aString) {
		SES ses = SESFromString(aString) ;
		if (SESOK(ses)) {
			NSUInteger i;
			CHAI characterAtIndex = SESCHAI(ses) ;
			MSUnicodeString *result = MSCreateUnicodeString(SESLength(ses)+(withQuotes?2:0)) ;
			unichar c ;

			if (withQuotes) { MSUAddUnichar(result, 0x0027) ; }
			for (i = SESStart(ses) ; i < SESEnd(ses) ; i++) {
				c = characterAtIndex(aString,i) ;
				MSUAddUnichar(result, c) ;
				if (c == 0x0027) { MSUAddUnichar(result, 0x0027) ; }
			}
			if (withQuotes) { MSUAddUnichar(result, 0x0027) ; }
			
			return AUTORELEASE(result) ;
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


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

- (id)initWithConnectionDictionary:(NSDictionary *)dictionary
  {
  if ((self= [super initWithConnectionDictionary:dictionary])) {
    NSString *host, *sock, *db, *user, *pwd, *timeout; id port;
    host=    [dictionary objectForLazyKeys:@"host", @"host-name",
                                           @"server", @"server-name", nil];
    port=    [dictionary objectForLazyKeys:@"port", nil];
    sock=    [dictionary objectForLazyKeys:@"sock", @"socket", nil];
    db=      [dictionary objectForLazyKeys:@"database", @"database-name",
                                           @"db", @"db-name", nil];
    user=    [dictionary objectForLazyKeys:@"user", @"user-name",
                                           @"login", nil];
    pwd=     [dictionary objectForLazyKeys:@"password", @"pwd", nil];
    timeout= [[dictionary objectForLazyKey:@"timeout"] description];

    if (![host length] || ![db length] || ![user length] ||
        ![pwd length]) {
      RELEASE(self);
      self= nil;}
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

      _cFlags.readOnly= (MSUInt)
        [[dictionary objectForLazyKeys:@"read-only",@"readonly", nil] isTrue];}}
  return self;
  }

- (BOOL)connect
  {
  if (![self isConnected]) {
    const char *host, *sock, *db, *user, *pwd, *timeout; int port;
    host=    [[_currentDictionary objectForKey:@"$_host"    ] UTF8String];
    port=    [[_currentDictionary objectForKey:@"$_port"    ] intValue];
    sock=    [[_currentDictionary objectForKey:@"$_sock"    ] UTF8String];
    db=      [[_currentDictionary objectForKey:@"$_database"] UTF8String];
    user=    [[_currentDictionary objectForKey:@"$_user"    ] UTF8String];
    pwd=     [[_currentDictionary objectForKey:@"$_password"] UTF8String];
    timeout= [[_currentDictionary objectForKey:@"$_timeout" ] UTF8String];

    mysql_init(&_db); 
    mysql_options(&_db, MYSQL_OPT_CONNECT_TIMEOUT, timeout); 
    if (!(mysql_real_connect(&_db, host, user, pwd, db, (MSUInt)port, sock, 0))) {
      const char *errorMsg= mysql_error(&_db);
      NSLog(@"MySQL database could not be opened for reason : %@",
        [NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]);
      mysql_close(&_db);
      _lastError= MySQLFailAtConnect;}
    else {
      //force use of UTF8 character set
      mysql_query(&_db, "SET NAMES utf8");
      mysql_query(&_db, "SET CHARACTER SET utf8");
      if (!mysql_autocommit(&_db, '0')) { //auto-commit not allowed! TODO ???
        NSLog(@"Unable to remove auto-commit mode!");
        //mysql_close(&_db);
        //_lastError= MySQLFailAtConfigure;
        }
      _cFlags.connected= YES;
      [[NSNotificationCenter defaultCenter] postNotificationName:
        MSConnectionDidConnectNotification object:self];}}
  return _cFlags.connected;
  }

- (BOOL)disconnect
{
	if ([self isConnected]) {
		RETAIN(self) ; // since the terminateAllOperations can release us, we must keep that object alive until we decide to release it
		[self terminateAllOperations] ;
		
		mysql_close(&_db);
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
		MYSQL_RES *result ;
		
		mysql_query(&_db, query);
		result = mysql_store_result(&_db) ;
		MSMySQLResultSet *resultSet = [ALLOC(MSMySQLResultSet) initWithMySQLRes:result connection:self] ;
		if (resultSet) {
			// === WARNING === the connection does not retain its operations...
			[_operations addObject:resultSet] ;
			return AUTORELEASE(resultSet) ;
		}
	}
	return nil ;
}

- (int)executeRawSQL:(char *)command { return mysql_query(&_db, command) ; }


- (MSDBTransaction *)openTransaction
{
	if (!_cFlags.readOnly && [self connect] && [self openedTransactionsCount] == 0) {
		// only one transaction at a time
		// nothing special to do because transaction is activated
		MSMySQLTransaction *transaction = [ALLOC(MSMySQLTransaction) initWithDatabaseConnection:self] ;
		if (transaction) {
			[_operations addObject:transaction] ;
			return transaction;
		}
	}
	return nil ;
}

- (MSArray *)tableNames
{
	MSArray *array = MSCreateArray(8) ;
	MYSQL_RES *result;
	NEW_POOL ;
	
	result = mysql_list_tables(&_db, NULL);
	if (result)
	{
		MSUInt num_fields = mysql_num_fields(result);
		MYSQL_ROW row;
		
		while ((row = mysql_fetch_row(result)))
		{
			NSUInteger *lengths = mysql_fetch_lengths(result);
			for (MSUInt i=0; i < num_fields; i++)
			{
				NSString *tableName = [NSString stringWithFormat:@"%.*s ", (MSInt) lengths[i], row[i] ? row[i] : "NULL"];
				tableName = [tableName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				if ([tableName length]) { MSAAdd(array,tableName) ; }
			}
		}
		
		mysql_free_result(result);
	}
	
	KILL_POOL ;
	
	return AUTORELEASE(array) ;
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

- (NSUInteger)lastError {return _lastError;}
@end

/************************** TO DO IN THIS FILE  ****************
 
 (1)	check to implemente read only access to database if possible
 
 *************************************************************/


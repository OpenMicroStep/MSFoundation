/*

 MSDBConnection.h

 This file is is a part of the MicroStep Framework.

 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011

 Herve Malaingre : herve@malaingre.com
 Frederic Olivi : fred.olivi@free.fr
 Eric Baradat :  k18rt@free.fr
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

 WARNING : this header file cannot be included alone, please direclty
 include <MSFoundation/MSFoundation.h>
 */
/*
 IMPORTANT WARNING : as it should be, a connection does not
 retain its operations. At the contrary, each operation retains its
 connection to be sure that the connection exists until it needs it.

 When a new operation occurs, it allways must open connect the
 connection to its database. At the contrary, when a connection
 disconnect all pending operations shoud be notified that they
 have no connection any more...

 */

#define MSSQL_ERROR -1

@class MSDBTransaction, MSDBResultSet, MSDBStatement, MSDBScheme, MSDBOperation ;

@interface MSDBConnection : NSObject {
@private
  MSDictionary *_originalDictionary ;
  NSString *_lastError ;
}

#pragma mark Connection


// The instance returned by the two following methods are not cached on contrary
// to the previous one.
+ (id)connectionWithDictionary:(MSDictionary *)connectionDictionary;
- (id)initWithConnectionDictionary:(MSDictionary *)dictionary;

- (MSDictionary *)connectionDictionary;
- (BOOL)isConnected;
- (BOOL)connect ;
- (BOOL)disconnect ;

#pragma mark Errors

- (NSString *)lastError;

#pragma mark Manage operations

- (void)terminateAllOperations ;

#pragma mark Transaction

- (BOOL)beginTransaction;
- (BOOL)endTransactionSuccessfully:(BOOL)commit;
- (BOOL)commit;
- (BOOL)rollback;
- (BOOL)isInTransaction;

// gives us an new opened transaction for new modification scheme
- (MSDBTransaction *)openTransaction ;

#pragma mark Requests high level API

// Run a 'SELECT columns FROM table WHERE where' query and returns the result set, if an error occurs returns nil
- (MSDBResultSet *)select:(NSArray *)columns from:(NSString *)table where:(NSString *)where ;
- (MSDBResultSet *)select:(NSArray *)columns from:(NSString *)table where:(NSString *)where withBindings:(NSArray *)bindings ;
- (MSDBResultSet *)select:(NSArray *)columns from:(NSString *)table where:(NSString *)where withBindings:(NSArray *)bindings orderBy:(NSString *)orderBy limit:(MSCouple *)limit ;
- (MSDBResultSet *)select:(NSArray *)columns from:(NSString *)table where:(NSString *)where withBindings:(NSArray *)bindings groupBy:(NSString *)groupby having:(NSString *)having orderBy:(NSString *)orderBy limit:(MSCouple *)limit ;

// Count the number of row that a 'SELECT columns FROM table WHERE where' without limits would returns, if an error occurs returns -1
- (NSInteger)countRowsFrom:(NSString *)table where:(NSString *)where withBindings:(NSArray *)bindings ;
- (NSInteger)countRowsFrom:(NSString *)table where:(NSString *)where withBindings:(NSArray *)bindings groupBy:(NSString *)groupby having:(NSString *)having ;

// INSERT/UPDATE a row into the given table
- (BOOL)insert:(NSDictionary *)values into:(NSString *)table ;
- (BOOL)insertOrUpdate:(NSDictionary *)values into:(NSString *)table ;
- (MSInt)update:(NSString *)table set:(NSDictionary *)values where:(NSString *)where ;
- (MSInt)update:(NSString *)table set:(NSDictionary *)values where:(NSString *)where withBindings:(NSArray *)bindings ;

// DELETE rows according to the filter
- (MSInt)deleteFrom:(NSString *)table where:(NSString *)where ;
- (MSInt)deleteFrom:(NSString *)table where:(NSString *)where withBindings:(NSArray *)bindings ;

#pragma mark Requests mid level API

- (MSDBStatement *)statementForSelect:(NSArray *)columns from:(NSString *)table where:(NSString *)where groupBy:(NSString *)groupby having:(NSString *)having orderBy:(NSString *)orderBy limit:(MSCouple *)limit ;
- (MSDBStatement *)statementForCountRowsFrom:(NSString *)table query:(NSString *)where groupBy:(NSString *)groupby having:(NSString *)having ;
- (MSDBStatement *)statementForInsert:(NSArray *)columns into:(NSString *)table ;
- (MSDBStatement *)statementForInsertOrUpdate:(NSArray *)columns into:(NSString *)table ;
- (MSDBStatement *)statementForUpdate:(NSString *)table set:(NSArray *)columns where:(NSString *)where ;
- (MSDBStatement *)statementForDeleteFrom:(NSString *)table where:(NSString *)where ;

#pragma mark Requests low level API

- (MSDBStatement *)statementWithRequest:(NSString *)request ;
- (MSDBResultSet *)fetchWithRequest:(NSString *)sqlRequest ;

#define MSSQL_OK 0
// executeRawSQL is to be used when no other return than ok or error is espected.
// Do NOT use it for DELETE INSERT etc. because theses operations are to be done
// inside a transaction.
// Nevertheless, you may have to use it for operations like START/BEGIN TRANSACTION;
// or other.
- (MSInt)executeRawSQL:(NSString *)sqlRequest ;

#pragma mark Other

- (MSArray *)tableNames ;

// a shortcut. returns 0 on error.
- (NSUInteger)countRowsFrom:(NSString *)tableName query:(NSString *)whereClause ;

// TODO: Remove the two following method as they lead to bad and potentially insecure usage of raw query
// Prepared statement are there to handle the security of data that comes from an unknown source.
// Statement are also faster with custom non static data
- (NSString *)escapeString:(NSString *)aString withQuotes:(BOOL)withQuotes ;
- (NSString *)escapeString:(NSString *)aString ; // no quotes

@end

@interface MSDBConnection (ForImplementations)
- (void)error:(NSString *)desc;

- (void)registerOperation:(MSDBOperation *)anOperation ;
- (void)unregisterOperation:(MSDBOperation *)anOperation ;
@end

@interface MSDBConnection (IdentifiersManagement)
- (void)reserveIdentifiers:(NSUInteger)count ;
- (void)reserveIdentifiers:(NSUInteger)count forKey:(NSString *)key ;

- (MSULong)nextIdentifier ;
- (MSULong)nextIdentifierForKey:(NSString *)key ;

- (MSULong)firstIdentifierOf:(NSUInteger)count ;
- (MSULong)firstIdentifierOf:(NSUInteger)count forKey:(NSString *)key;
@end

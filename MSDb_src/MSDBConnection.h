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
@class MSDBTransaction, MSDBResultSet ;


@interface MSDBConnection : NSObject
{
@protected
  NSDictionary *_originalDictionary ;
}

+ (NSUInteger)maximumConnections;

// The class method uniqueConnectionWithDictionary: re-serve the same connection
// if used twice with the same (equal) dictionary.
// The class of the returned object is the principal class of the adaptor
// declared in the dictionary.
// TODO: A remove method ?
+ (id)uniqueConnectionWithDictionary:(NSDictionary *)dictionary;

// The instance returned by the two following methods are not cached on contrary
// to the previous one.
+ (id)connectionWithDictionary:(NSDictionary *)connectionDictionary;
- (id)initWithConnectionDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)connectionDictionary;

// a shortcut. returns 0 on error.
- (NSUInteger)countRowsFrom:(NSString *)tableName query:(NSString *)whereClause ;

- (MSInt)lastError; // Not implemented in all Adaptor ???

#pragma mark Implemented in generic

- (NSUInteger)requestSizeLimit ;           // default
- (NSUInteger)inClauseElementsCountLimit ; // default

- (MSArray *)allOperations ;
- (MSArray *)pendingRequests ;
- (MSArray *)openedTransactions ;

- (BOOL)isConnected ;

#pragma mark Implemented by adaptors

// In adaptors, needs to begin with a call to super
//- (id)initWithConnectionDictionary:(NSDictionary *)dictionary;

- (BOOL)connect ;
- (BOOL)disconnect ;

// list of the tables of the connected database
- (MSArray *)tableNames ;

- (MSDBResultSet *)fetchWithRequest:(NSString *)sqlRequest ;

// gives us an new opened transaction for new modification scheme
- (MSDBTransaction *)openTransaction ;

#define MSSQL_OK 0 // Successful result
// executeRawSQL is to be used when no other return than ok or error is espected.
// Do NOT use it for DELETE INSERT etc. because theses operations are to be done
// inside a transaction.
// Nevertheless, you may have to use it for operations like START/BEGIN TRANSACTION;
// or other.
- (MSInt)executeRawSQL:(NSString *)sqlRequest ;

- (NSString *)escapeString:(NSString *)aString withQuotes:(BOOL)withQuotes ;
- (NSString *)escapeString:(NSString *)aString ; // no quotes

@end

@interface MSDBConnection (IdentifiersManagement)
- (void)reserveIdentifiers:(NSUInteger)count ;
- (void)reserveIdentifiers:(NSUInteger)count forKey:(NSString *)key ;

- (MSULong)nextIdentifier ;
- (MSULong)nextIdentifierForKey:(NSString *)key ;

- (MSULong)firstIdentifierOf:(NSUInteger)count ;
- (MSULong)firstIdentifierOf:(NSUInteger)count forKey:(NSString *)key;
@end

MSDatabaseExport NSString *MSConnectionDidConnectNotification ;
MSDatabaseExport NSString *MSConnectionDidDisconnectNotification ;

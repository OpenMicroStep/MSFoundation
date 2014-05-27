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

+ (id)connectionWithDictionary:(NSDictionary *)connectionDictionary ;
- (id)initWithConnectionDictionary:(NSDictionary *)dictionary; 

- (NSDictionary *)connectionDictionary ;

- (BOOL)connect ;
- (BOOL)disconnect ;
- (BOOL)isConnected ;

- (NSUInteger)requestSizeLimit ;
- (NSUInteger)inClauseElementsCountLimit ;

- (NSString *)escapeString:(NSString *)aString withQuotes:(BOOL)withQuotes ;
- (NSString *)escapeString:(NSString *)aString ; // no quotes

- (MSArray *)tableNames ; // list of the tables of the connected database
- (MSDBResultSet *)fetchWithRequest:(NSString *)sqlRequest ;
- (MSDBTransaction *)openTransaction ; // gives us an new opened transaction for new modification scheme

- (MSArray *)allOperations ;
- (MSArray *)pendingRequests ; 
- (MSArray *)openedTransactions ;

- (NSUInteger)countRowsFrom:(NSString *)tableName query:(NSString *)whereClause ; // a shortcut. returns 0 on error.

- (NSUInteger)lastError;

@end

@interface MSDBConnection (IdentifiersManagement)
- (void)reserveIdentifiers:(NSUInteger)count ;
- (void)reserveIdentifiers:(NSUInteger)count forKey:(NSString *)key ;

- (MSULong)nextIdentifier ;
- (MSULong)nextIdentifierForKey:(NSString *)key ;

- (MSULong)firstIdentifierOf:(NSUInteger)count ;
- (MSULong)firstIdentifierOf:(NSUInteger)count forKey:(NSString *)key;
@end

MSExport NSString *MSConnectionDidConnectNotification ;
MSExport NSString *MSConnectionDidDisconnectNotification ;


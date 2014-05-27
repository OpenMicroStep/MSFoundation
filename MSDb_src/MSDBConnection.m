/*
 
 MSDBConnection.m
 
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

#import "MSObi_Private.h"

static NSLock *__connectionsLock = nil ;
static NSMutableDictionary *__adaptors = nil ;

NSString *MSConnectionDidConnectNotification = @"MSConnectionDidConnectNotification" ;
NSString *MSConnectionDidDisconnectNotification = @"MSConnectionDidDisconnectNotification" ;

@implementation MSDBConnection

+ (void)initialize
{
	if (!__connectionsLock) {
		__connectionsLock = NEW(NSLock) ; 
		__adaptors = [ALLOC(NSMutableDictionary) initWithCapacity:31] ;
	}
}

+ (NSUInteger)maximumConnections { return NSUIntegerMax ; }

+ (NSBundle *)_loadAdaptorBundleNamed:(NSString *)name
{
	NSBundle *bundle = [NSBundle mainBundle] ;
	NSString *path = [bundle pathForResource:name ofType:@"dbadaptor"] ;
	NSEnumerator *e ;

	// we look in our main bundle
	if ([path length] && (bundle = [NSBundle bundleWithPath:path]) && [bundle load]) { return bundle ; }
	
	// then in all frameworks
	e = [[NSBundle allFrameworks] objectEnumerator] ;
	while ((bundle = [e nextObject])) {
            path = [bundle pathForResource:name ofType:@"dbadaptor"] ;
            if ([path length] && (bundle = [NSBundle bundleWithPath:path]) && [bundle load]) { return bundle ; }		
	}

    NSLog(@"Unable to fin database adaptor named '%@'", name);
	return nil ;
}

+ (id)_adaptorWithConnectionDictionary:(NSDictionary *)dictionary ;
{
	NSString *name = [dictionary objectForLazyKey:@"adaptor"] ;
	id adaptor = nil ;
	
	if ((name = [name toString])) {
		adaptor = [__adaptors objectForLazyKey:name] ;
		if (!adaptor) {
			NSString *key = [name lowercaseString] ;
			adaptor = [self _loadAdaptorBundleNamed:name] ;
			if (adaptor) {
				[__adaptors setObject:adaptor forLazyKey:key] ;
			}
		}
	}
	return adaptor ;
}

- (id)initWithConnectionDictionary:(NSDictionary *)dictionary { (void)[self notImplemented:_cmd] ; return nil ; dictionary= nil; }
- (void)setDelegate:(id)delegate { (void)[self notImplemented:_cmd] ; delegate= nil; }
- (id)delegate { return [self notImplemented:_cmd] ; }

+ (id)connectionWithDictionary:(NSDictionary *)connectionDictionary ;
{
	if ([connectionDictionary count] > 1) {
		[__connectionsLock lock] ;
		{
			// protected code here
			NSMutableDictionary *tDict = [[NSThread currentThread] threadDictionary] ;
			MSMutableArray *tConnections = [tDict objectForKey:@"_MSDBConnectionArray_"] ;
			NSUInteger i, count = MSACount(tConnections) ;
			id adaptor ;
			id c ;
			
			for (i = 0 ; i < count ; i++) {
				c = MSAIndex(tConnections, i) ;
				if ([[c connectionDictionary] isEqualToDictionary:connectionDictionary]) {
					[__connectionsLock unlock] ;
					return c ;
				}
			}

			adaptor = [self _adaptorWithConnectionDictionary:connectionDictionary] ;
			if (adaptor) {
				Class connectionClass = [adaptor principalClass] ;
				if (connectionClass) {
					c = MSCreateObject(connectionClass) ;
					if ((c = [c initWithConnectionDictionary:connectionDictionary])) {
						if (!tConnections) {
							tConnections = MSCreateMutableArray(7) ;
							[tDict setObject:tConnections forKey:@"_MSDBConnectionArray_"] ;
							RELEASE(tConnections) ;
						}
						MSAAdd(tConnections, c) ;
						[__connectionsLock unlock] ;
						return AUTORELEASE(c) ;
					}
				}
			}
			
		}
		[__connectionsLock unlock] ;
	}
	return nil ;	
}

- (NSUInteger)countRowsFrom:(NSString *)tableName query:(NSString *)whereClause ;
{
	MSUInt ret = 0 ;
	if ([tableName length]) {
		MSDBResultSet *set ;
		NSString *sql = nil ;
		NEW_POOL ;
		
		if ([whereClause length]) {
			sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@;", tableName, whereClause] ;
		}
		else {
			sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@;", tableName] ;
		}
		set = [self fetchWithRequest:sql] ;
		if (set && [set nextRow]) {
			if (![set getUnsignedIntAt:&ret column:0]) ret = 0 ;
		}
		
		KILL_POOL ;
	}
	return (NSUInteger)ret ;	
}
			   

- (NSDictionary *)connectionDictionary { return [self notImplemented:_cmd] ; }

- (BOOL)connect { return [self notImplemented:_cmd] ? YES : NO ; }
- (BOOL)disconnect { return [self notImplemented:_cmd] ? YES : NO ; }
- (BOOL)isConnected { return [self notImplemented:_cmd] ? YES : NO ; }

- (NSUInteger)requestSizeLimit { return 1024 ; }
- (NSUInteger)inClauseElementsCountLimit { return 256 ; }
- (NSString *)escapeString:(NSString *)aString { return [self escapeString:aString withQuotes:NO] ; }
- (NSString *)escapeString:(NSString *)aString withQuotes:(BOOL)withQuotes { return [self notImplemented:_cmd] ; aString= nil; withQuotes= NO; }

- (MSDBResultSet *)fetchWithRequest:(NSString *)sqlRequest { return [self notImplemented:_cmd] ; sqlRequest= nil; }
- (MSDBTransaction *)openTransaction { return [self notImplemented:_cmd] ; }

- (MSArray *)allOperations { return [self notImplemented:_cmd] ; }
- (MSArray *)pendingRequests { return [self notImplemented:_cmd] ; }
- (MSArray *)openedTransactions { return [self notImplemented:_cmd] ; }
- (MSArray *)tableNames { return [self notImplemented:_cmd] ; }

- (NSUInteger)lastError {return 0;}

@end

@implementation MSDBConnection (IdentifiersManagement)

- (void)reserveIdentifiers:(NSUInteger)count { [self notYetImplemented:_cmd] ; count= 0; }
- (void)reserveIdentifiers:(NSUInteger)count forKey:(NSString *)key { [self notYetImplemented:_cmd] ; count= 0; key= nil; }

- (MSULong)nextIdentifier { (void)[self notYetImplemented:_cmd] ; return 0 ;}
- (MSULong)nextIdentifierForKey:(NSString *)key { (void)[self notYetImplemented:_cmd] ; return 0 ; key= nil; }

- (MSULong)firstIdentifierOf:(NSUInteger)count { (void)[self notYetImplemented:_cmd] ; return 0 ; count= 0; }
- (MSULong)firstIdentifierOf:(NSUInteger)count forKey:(NSString *)key { (void)[self notYetImplemented:_cmd] ; return  0 ; count= 0; key= nil; }

@end

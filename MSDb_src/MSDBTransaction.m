//
//  MSDBTransaction.m
//  MSFoundation
//
//  Created by Hervé MALAINGRE on 10/10/11.
//  Copyright 2011 LOGITUD Solutions. All rights reserved.
//

#import "MSObi_Private.h"

@implementation MSDBTransaction

- (void)cancel { return [self terminateOperation] ; }
- (BOOL)save { return [self saveWithError:NULL] ; }
- (BOOL)saveWithError:(MSInt *)error { return [self notImplemented:_cmd] ? YES : NO ; error= nil;}
- (BOOL)isOpened { return _connection ? YES : NO ; }
- (BOOL)appendSQLCommand:(NSString *)sql { return [self appendSQLCommand:sql error:NULL] ; }
- (BOOL)appendSQLCommand:(NSString *)sql error:(MSInt *)errorPtr { return [self notImplemented:_cmd] ? YES : NO ; sql= nil; errorPtr= nil;}

- (NSString *)escapeString:(NSString *)aString withQuotes:(BOOL)withQuotes { return [_connection escapeString:aString withQuotes:withQuotes] ; }
- (NSString *)escapeString:(NSString *)aString { return [_connection escapeString:aString] ; }

@end

@implementation MSDBTransaction (IdentifiersManagement)

- (void)reserveIdentifiers:(NSUInteger)count { [_connection reserveIdentifiers:count] ; }
- (void)reserveIdentifiers:(NSUInteger)count forKey:(NSString *)key { [_connection reserveIdentifiers:count forKey:key] ; }

- (MSULong)nextIdentifier { return [_connection nextIdentifier] ; }
- (MSULong)nextIdentifierForKey:(NSString *)key { return [_connection nextIdentifierForKey:key] ; }

- (MSULong)firstIdentifierOf:(NSUInteger)count { return [_connection firstIdentifierOf:count] ; }
- (MSULong)firstIdentifierOf:(NSUInteger)count forKey:(NSString *)key { return [_connection firstIdentifierOf:count forKey:key] ; }

@end

//
//  MSDBTransaction.m
//  MSFoundation
//
//  Created by Hervé MALAINGRE on 10/10/11.
//  Copyright 2011 LOGITUD Solutions. All rights reserved.
//

#import "MSDb_Private.h"

@implementation MSDBTransaction

- (BOOL)appendSQLCommand:(NSString *)sql { return [self appendSQLCommand:sql error:NULL] ; }
- (BOOL)appendSQLCommand:(NSString *)sql error:(MSInt *)errorPtr { if(errorPtr) *errorPtr= 0; return [[self databaseConnection] executeRawSQL:sql] == MSSQL_OK;}

- (void)cancel { [self terminateOperation] ; }
- (BOOL)save { return [self saveWithError:NULL] ; }
- (BOOL)saveWithError:(MSInt *)error
{
  BOOL ret;
  if(error) *error= 0;
  ret= [_connection commit];
  [super terminateOperation];
  return ret;
}

- (NSString *)escapeString:(NSString *)aString withQuotes:(BOOL)withQuotes { return [_connection escapeString:aString withQuotes:withQuotes] ; }
- (NSString *)escapeString:(NSString *)aString { return [_connection escapeString:aString] ; }

- (void)terminateOperation
{
  if([_connection isInTransaction])
    [_connection rollback];
  [super terminateOperation];
}

@end

@implementation MSDBTransaction (IdentifiersManagement)

- (void)reserveIdentifiers:(NSUInteger)count { [_connection reserveIdentifiers:count] ; }
- (void)reserveIdentifiers:(NSUInteger)count forKey:(NSString *)key { [_connection reserveIdentifiers:count forKey:key] ; }

- (MSULong)nextIdentifier { return [_connection nextIdentifier] ; }
- (MSULong)nextIdentifierForKey:(NSString *)key { return [_connection nextIdentifierForKey:key] ; }

- (MSULong)firstIdentifierOf:(NSUInteger)count { return [_connection firstIdentifierOf:count] ; }
- (MSULong)firstIdentifierOf:(NSUInteger)count forKey:(NSString *)key { return [_connection firstIdentifierOf:count forKey:key] ; }

@end

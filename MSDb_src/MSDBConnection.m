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

#import "MSDatabase_Private.h"

static MSDictionary *__adaptors = nil ;

NSString *MSConnectionDidConnectNotification=    @"MSConnectionDidConnectNotification" ;
NSString *MSConnectionDidDisconnectNotification= @"MSConnectionDidDisconnectNotification" ;

@implementation MSDBConnection

#pragma mark Connection

+ (void)load
{
    __adaptors = [ALLOC(MSDictionary) mutableInitWithCapacity:31] ;
}

static inline NSBundle *_loadBundleAtPath(id path)
{
    NSBundle *bundle;
    return ([path length] &&
            (bundle= [NSBundle bundleWithPath:path]) &&
            [bundle load]) ?
    bundle : nil;
}

static inline NSBundle *_loadAdaptorBundleNamed(NSString *name)
{
    NSBundle *upBundle,*bundle; NSString *path; NSEnumerator *e;
    bundle= nil;
    
    // we look in our main bundle
    upBundle= [NSBundle mainBundle];
    path= [upBundle pathForResource:name ofType:@"dbadaptor"];
    bundle= _loadBundleAtPath(path);
    
    // then in all frameworks
    if (!bundle) {
        e= [[NSBundle allFrameworks] objectEnumerator];
        while (!bundle && (upBundle= [e nextObject])) {
            path= [upBundle pathForResource:name ofType:@"dbadaptor"];
            bundle= _loadBundleAtPath(path);}}
    
    // On regarde dans mainBundleDir et mainBundleDir/../bundle
    if (!bundle) {
        NSString *upBundleDir,*nameExt;
        nameExt= FMT(@"%@.%@",name,@"dbadaptor");
        upBundleDir= [[NSBundle mainBundle] bundlePath];
        path= [upBundleDir stringByAppendingPathComponent:nameExt];
        bundle= _loadBundleAtPath(path);
        if (!bundle) {
            path= [upBundleDir stringByAppendingPathComponent:@"../bundle"];
            path= [path stringByAppendingPathComponent:nameExt];
            bundle= _loadBundleAtPath(path);
            //NSLog(@"_loadAdaptorBundleNamed %@ %@",path,bundle);
        }}
    
    if (!bundle) NSLog(@"Unable to find database adaptor named '%@'", name);
    return bundle;
}

static inline id _adaptorWithConnectionDictionary(MSDictionary *dictionary)
{
    static MSDictionary *synonyms= nil;
    id adaptor= nil, name, x;
    
    if (!synonyms) synonyms= [[MSDictionary alloc] initWithObjectsAndKeys:@"MSMySqlAdaptor", @"mysql", nil];
    if ((name= [[dictionary objectForLazyKey:@"adaptor"] toString])) {
        if ((x= [synonyms objectForLazyKey:name])) name= x;
        if (!(adaptor= [__adaptors objectForLazyKey:name]) &&
            (adaptor= _loadAdaptorBundleNamed(name))) {
            [__adaptors setObject:adaptor forLazyKey:[name lowercaseString]];}}
    return adaptor;
}

static inline id _retainedCnxWithConnectionDictionary(MSDictionary *dictionary)
{
    id cnx= nil, adaptor, c;
    MSDictionary *d= [[MSDictionary alloc] initWithDictionary:dictionary];
    if ((adaptor= _adaptorWithConnectionDictionary(d))) {
        Class connectionClass= [adaptor principalClass];
        if (connectionClass) {
            c= MSCreateObject(connectionClass);
            cnx= [c initWithConnectionDictionary:dictionary];}}
    [d release];
    return cnx;
}

+ (id)connectionWithDictionary:(MSDictionary *)params
{
    return [[[self alloc] initWithConnectionDictionary:params] autorelease];
}

- (id)initWithConnectionDictionary:(MSDictionary *)connectionDictionary
{
    
    // Not from subclass, we first need to load the bundle and return a subclass
    // TODO: with HM: Si toujours unique à ce niveau alors notImplemented, l'accès
    // non unique restant possible par les subclasses.
    if ([self isMemberOfClass:[MSDBConnection class]]) {
        ASSIGN(self, _retainedCnxWithConnectionDictionary(connectionDictionary));}
    // from subclass, nothing to do than retain the dictionary
    else {
        _originalDictionary= [connectionDictionary copy];
        _lastError= nil;
    }
    
    return self;
}

- (MSDictionary *)connectionDictionary { return _originalDictionary ; }

- (BOOL)isConnected { return [self notImplemented:_cmd] ? YES : NO ; }
- (BOOL)connect     { return [self notImplemented:_cmd] ? YES : NO ; }
- (BOOL)disconnect  { [self notImplemented:_cmd]; return NO; }

- (void)dealloc
{
    RELEASE(_originalDictionary);
    RELEASE(_lastError);
    [super dealloc];
}

#pragma mark Errors

- (void)error:(SEL)inMethod desc:(NSString *)desc
{
    desc= [NSString stringWithFormat:@"%@-> %@", NSStringFromSelector(inMethod), desc];
    ASSIGN(_lastError, desc);
}

- (NSString *)lastError { return _lastError; }

#pragma mark Scheme

- (MSDBScheme *)scheme   { return [self notImplemented:_cmd]; }
- (MSArray *)tableNames  { return [self notImplemented:_cmd]; }

#pragma mark Manage operations

- (void)terminateAllOperations { [self notImplemented:_cmd]; }
- (void)registerOperation:(MSDBOperation *)anOperation { [self notImplemented:_cmd]; (void)anOperation; }
- (void)unregisterOperation:(MSDBOperation *)anOperation { [self notImplemented:_cmd]; (void)anOperation; }

#pragma mark Transaction

- (BOOL)beginTransaction { [self notImplemented:_cmd]; return NO; }
- (BOOL)endTransactionSuccessfully:(BOOL)commit
{ return commit ? [self commit] : [self rollback]; }
- (BOOL)commit           { [self notImplemented:_cmd]; return NO; }
- (BOOL)rollback         { [self notImplemented:_cmd]; return NO; }
- (BOOL)isInTransaction  { [self notImplemented:_cmd]; return NO; }
- (MSDBTransaction *)openTransaction {
    MSDBTransaction *ret = nil;
    if([self beginTransaction]) {
        ret= [[ALLOC(MSDBTransaction) initWithDatabaseConnection:self] autorelease];
    }
    return ret;
}

#pragma mark Requests high level API

- (MSDBResultSet *)select:(NSArray *)columns from:(NSString *)table where:(NSString *)where
{  return [self select:columns from:table where:where withBindings:nil groupBy:nil having:nil orderBy:nil limit:nil]; }
- (MSDBResultSet *)select:(NSArray *)columns from:(NSString *)table where:(NSString *)where withBindings:(NSArray *)bindings
{  return [self select:columns from:table where:where withBindings:bindings groupBy:nil having:nil orderBy:nil limit:nil]; }
- (MSDBResultSet *)select:(NSArray *)columns from:(NSString *)table where:(NSString *)where withBindings:(NSArray *)bindings orderBy:(NSString *)orderBy limit:(MSCouple *)limit ;
{  return [self select:columns from:table where:where withBindings:bindings groupBy:nil having:nil orderBy:orderBy limit:limit]; }
- (MSDBResultSet *)select:(NSArray *)columns from:(NSString *)table where:(NSString *)where withBindings:(NSArray *)bindings groupBy:(NSString *)groupby having:(NSString *)having orderBy:(NSString *)orderBy limit:(MSCouple *)limit
{
    MSDBResultSet *ret= nil;
    MSDBStatement *stmt;
    NEW_POOL;
    stmt= [self statementForSelect:columns from:table where:where groupBy:groupby having:having orderBy:orderBy limit:limit];
    if(![stmt bindObjects:bindings]) {
        [stmt terminateOperation];
        MSDB_ERROR_ARGS(@"Unable to bind objects: %@", [stmt lastError]);
    } else {
        ret= [[stmt fetch] retain];
    }
    KILL_POOL;
    return [ret autorelease];
}

- (NSInteger)countRowsFrom:(NSString *)table where:(NSString *)where withBindings:(NSArray *)bindings
{ return [self countRowsFrom:table where:where withBindings:bindings groupBy:nil having:nil]; }
- (NSInteger)countRowsFrom:(NSString *)table where:(NSString *)where withBindings:(NSArray *)bindings groupBy:(NSString *)groupby having:(NSString *)having
{
    NSInteger ret= -1;
    MSLong retAsLong;
    MSDBResultSet *result;
    NEW_POOL;
    result= [self select:[NSArray arrayWithObject:@"COUNT(*)"] from:table where:where withBindings:bindings groupBy:groupby having:having orderBy:nil limit:nil];
    if([result nextRow] && [result getLongAt:&retAsLong column:0]) {
        ret= (NSInteger)retAsLong;
    } else if(result) {
        MSDB_ERROR(@"No row returned by SELECT COUNT(*)");
    }
    KILL_POOL;
    return ret;
}

static inline MSInt stmt_execute(MSDBConnection *self, SEL _cmd, MSDBStatement *stmt, NSArray *bindings)
{
    MSInt ret= MSSQL_ERROR;
    if(stmt) {
        if(![stmt bindObjects:bindings])
            MSDB_ERROR_ARGS(@"Unable to bind objects:%@", [stmt lastError]);
        else if((ret= [stmt execute]) == MSSQL_ERROR)
            MSDB_ERROR_ARGS(@"Error while executing statement: %@", [stmt lastError]);
    }
    return ret;
}

- (BOOL)insert:(NSDictionary *)values into:(NSString *)table
{
    BOOL ret;
    MSDBStatement *stmt;
    NEW_POOL;
    stmt= [self statementForInsert:[values allKeys] into:table];
    ret= stmt_execute(self, _cmd, stmt, [values allValues]) != MSSQL_ERROR;
    KILL_POOL;
    return ret;
}

- (BOOL)insertOrUpdate:(NSDictionary *)values into:(NSString *)table
{
    BOOL ret;
    MSDBStatement *stmt;
    NEW_POOL;
    stmt= [self statementForInsertOrUpdate:[values allKeys] into:table];
    ret= stmt_execute(self, _cmd, stmt, [values allValues]) != MSSQL_ERROR;
    KILL_POOL;
    return ret;
}

- (MSInt)update:(NSString *)table set:(NSDictionary *)values where:(NSString *)where
{ return [self update:table set:values where:where withBindings:nil]; }

- (MSInt)update:(NSString *)table set:(NSDictionary *)values where:(NSString *)where withBindings:(NSArray *)bindings
{
    MSInt ret;
    MSDBStatement *stmt;
    NEW_POOL;
    stmt= [self statementForUpdate:table set:[values allKeys] where:where];
    ret= stmt_execute(self, _cmd, stmt, [[values allValues] arrayByAddingObjectsFromArray:bindings]);
    KILL_POOL;
    return ret;
}

- (MSInt)deleteFrom:(NSString *)table where:(NSString *)where
{ return [self deleteFrom:table where:where withBindings:nil]; }
- (MSInt)deleteFrom:(NSString *)table where:(NSString *)where withBindings:(NSArray *)bindings
{
    MSInt ret;
    MSDBStatement *stmt;
    NEW_POOL;
    stmt= [self statementForDeleteFrom:table where:where];
    ret= stmt_execute(self, _cmd, stmt, bindings);
    KILL_POOL;
    return ret;
}

#pragma mark Requests mid level API

- (MSDBStatement *)statementForSelect:(NSArray *)columns from:(NSString *)table where:(NSString *)where groupBy:(NSString *)groupby having:(NSString *)having orderBy:(NSString *)orderBy limit:(MSCouple *)limit
{
    NSMutableString *query;
    if(![columns count])
        return nil;
    
    query= [NSMutableString stringWithFormat:@"SELECT %@ FROM %@", [columns componentsJoinedByString:@", "], table];
    if(where)
        [query appendFormat:@" WHERE %@", where];
    if(groupby) {
        [query appendFormat:@" GROUP BY %@", groupby];
        if(having)
            [query appendFormat:@" HAVING %@", having];
    } else if(having)
        return nil;
    if(orderBy)
        [query appendFormat:@" ORDER BY %@", orderBy];
    if(limit)
        [query appendFormat:@" LIMIT %@, %@", [limit firstMember], [limit secondMember]];
    
    return [self statementWithRequest:query];
}

- (MSDBStatement *)statementForCountRowsFrom:(NSString *)table query:(NSString *)where groupBy:(NSString *)groupby having:(NSString *)having
{
    return [self statementForSelect:[NSArray arrayWithObject:@"COUNT(*)"] from:table where:where groupBy:groupby having:having orderBy:nil limit:nil];
}

- (MSDBStatement *)statementForInsert:(NSArray *)columns into:(NSString *)table
{
    NSUInteger count;
    NSMutableString *query;
    count= [columns count];
    if(!count)
        return nil;
    
    query= [NSMutableString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (", table, [columns componentsJoinedByString:@", "]];
    while (count > 1) {
        [query appendString:@"?, "];
        --count;
    }
    if(count > 0)
        [query appendString:@"?"];
    [query appendString:@")"];
    return [self statementWithRequest:query];
}

- (MSDBStatement *)statementForInsertOrUpdate:(NSArray *)columns into:(NSString *)table
{ (void)columns; (void)table; return [self notImplemented:_cmd]; }

- (MSDBStatement *)statementForUpdate:(NSString *)table set:(NSArray *)columns where:(NSString *)where
{
    NSUInteger i, count;
    NSMutableString *query;
    count= [columns count];
    if(!count) {
        [self error:_cmd desc:@"columns is empty, nothing to update"];
        return nil; }
    
    query= [NSMutableString stringWithFormat:@"UPDATE %@ SET ", table];
    [query appendFormat:@"%@ = ?", [columns objectAtIndex:0]];
    for (i= 1; i < count; ++i) {
        [query appendFormat:@", %@ = ?", [columns objectAtIndex:i]];
    }
    if(where)
        [query appendFormat:@" WHERE %@", where];
    return [self statementWithRequest:query];
}

- (MSDBStatement *)statementForDeleteFrom:(NSString *)table where:(NSString *)where
{
    NSString *query;
    if(where)
        query= [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", table, where];
    else
        query= [NSString stringWithFormat:@"DELETE FROM %@", table];
    return [self statementWithRequest:query];
}

#pragma mark Requests low level API

- (MSDBStatement *)statementWithRequest:(NSString *)request
{ (void)request ; return [self notImplemented:_cmd] ; }
- (MSDBResultSet *)fetchWithRequest:(NSString *)sqlRequest
{ (void)sqlRequest ; return [self notImplemented:_cmd] ; }
- (MSInt)executeRawSQL:(NSString *)sqlRequest
{ (void)sqlRequest ; [self notImplemented:_cmd] ; return MSSQL_ERROR ; }

#pragma mark Deprecated / Dangerous

- (NSUInteger)countRowsFrom:(NSString *)tableName query:(NSString *)whereClause
{
    NSInteger count= [self countRowsFrom:tableName where:whereClause withBindings:nil];
    if(count < 0)
        count= 0;
    return (NSUInteger)count;
}
- (NSString *)escapeString:(NSString *)aString
{ return [self escapeString:aString withQuotes:NO] ; }
- (NSString *)escapeString:(NSString *)aString withQuotes:(BOOL)withQuotes
{ return [self notImplemented:_cmd] ; aString= nil; withQuotes= NO; }

@end

@implementation MSDBConnection (IdentifiersManagement)

- (void)reserveIdentifiers:(NSUInteger)count
{ [self notYetImplemented:_cmd] ; count= 0; }
- (void)reserveIdentifiers:(NSUInteger)count forKey:(NSString *)key
{ [self notYetImplemented:_cmd] ; count= 0; key= nil; }

- (MSULong)nextIdentifier
{ (void)[self notYetImplemented:_cmd] ; return 0 ;}
- (MSULong)nextIdentifierForKey:(NSString *)key
{ (void)[self notYetImplemented:_cmd] ; return 0 ; key= nil; }

- (MSULong)firstIdentifierOf:(NSUInteger)count
{ (void)[self notYetImplemented:_cmd] ; return 0 ; count= 0; }
- (MSULong)firstIdentifierOf:(NSUInteger)count forKey:(NSString *)key
{ (void)[self notYetImplemented:_cmd] ; return  0 ; count= 0; key= nil; }

@end

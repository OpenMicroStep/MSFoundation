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

#import "MSDb_Private.h"

static NSLock *__connectionsLock = nil ;
static NSMutableDictionary *__adaptors = nil ;

NSString *MSConnectionDidConnectNotification=    @"MSConnectionDidConnectNotification" ;
NSString *MSConnectionDidDisconnectNotification= @"MSConnectionDidDisconnectNotification" ;

@implementation MSDBConnection

+ (void)initialize
{
  if (!__connectionsLock) {
    __connectionsLock = NEW(NSLock) ;
    __adaptors = [ALLOC(NSMutableDictionary) initWithCapacity:31] ;
  }
}

+ (NSUInteger)maximumConnections { return NSUIntegerMax ; }

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

static inline id _adaptorWithConnectionDictionary(NSDictionary *dictionary)
{
  static MSDictionary *synonyms= nil;
  id adaptor= nil, name, x;

  if (!synonyms) synonyms= [[MSDictionary alloc] initWithObjectsAndKeys:
    @"MSMySqlAdaptor", @"mysql", nil];
  if ((name= [[dictionary objectForLazyKey:@"adaptor"] toString])) {
    if ((x= [synonyms objectForLazyKey:name])) name= x;
    if (!(adaptor= [__adaptors objectForLazyKey:name]) &&
         (adaptor= _loadAdaptorBundleNamed(name))) {
      [__adaptors setObject:adaptor forLazyKey:[name lowercaseString]];}}
  return adaptor;
}

static inline id _retainedCnxWithConnectionDictionary(NSDictionary *dictionary)
{
  id cnx= nil, adaptor, c;
  if ((adaptor= _adaptorWithConnectionDictionary(dictionary))) {
    Class connectionClass= [adaptor principalClass];
    if (connectionClass) {
      c= MSCreateObject(connectionClass);
      cnx= [c initWithConnectionDictionary:dictionary];}}
  return cnx;
}

+ (id)uniqueConnectionWithDictionary:(NSDictionary *)connectionDictionary
{
  id cnx= nil;
  NSMutableDictionary *tDict;
  MSArray *tConnections;
  id ae,c;
    
  if ([connectionDictionary count] <= 1) RELEAZEN(self);
  else {
    [__connectionsLock lock] ;

    // protected code here
    tDict= [[NSThread currentThread] threadDictionary];
    tConnections= [tDict objectForKey:@"_MSDBConnectionArray_"];

    for (ae=[tConnections objectEnumerator]; !cnx && (c= [ae nextObject]);) {
      if ([[c connectionDictionary] isEqualToDictionary:connectionDictionary]) {
//NSLog(@"uniqueConnectionWithDictionary %@ REUSED",c);
        cnx= c;}}
    if (!cnx) {
      if ((cnx= _retainedCnxWithConnectionDictionary(connectionDictionary))) {
        if (!tConnections) {
          tConnections= [[MSArray alloc] mutableInitWithCapacity:7];
          [tDict setObject:tConnections forKey:@"_MSDBConnectionArray_"];
          RELEASE(tConnections);}
        [tConnections addObject:cnx];
        AUTORELEASE(cnx);}}

    [__connectionsLock unlock];}
  return cnx;
}

+ (id)connectionWithDictionary:(NSDictionary *)params
{
  return [[[self alloc] initWithConnectionDictionary:params] autorelease];
}
- (id)initWithConnectionDictionary:(NSDictionary *)connectionDictionary
{
  // Not from subclass, we first need to load the bundle and return a subclass
  // TODO: with HM: Si toujours unique à ce niveau alors notImplemented, l'accès
  // non unique restant possible par les subclasses.
  if ([self isMemberOfClass:[MSDBConnection class]]) {
    ASSIGN(self, _retainedCnxWithConnectionDictionary(connectionDictionary));}
  // from subclass, nothing to do than retain the dictionary
  else _originalDictionary= [connectionDictionary copyWithZone:[self zone]];
  return self;
}

- (NSDictionary *)connectionDictionary { return _originalDictionary ; }

- (void)dealloc
{
  RELEASE(_originalDictionary);
  [super dealloc];
}

- (NSUInteger)countRowsFrom:(NSString *)tableName query:(NSString *)whereClause
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

- (MSInt)lastError {return MSSQL_OK;}

- (void)setDelegate:(id)delegate
{ (void)[self notImplemented:_cmd] ; delegate= nil; }

- (id)delegate
{ return [self notImplemented:_cmd] ; }

- (NSUInteger)requestSizeLimit           { return 1024 ; }
- (NSUInteger)inClauseElementsCountLimit { return  256 ; }

- (MSArray *)allOperations      { return [self notImplemented:_cmd] ; }
- (MSArray *)pendingRequests    { return [self notImplemented:_cmd] ; }
- (MSArray *)openedTransactions { return [self notImplemented:_cmd] ; }

- (BOOL)isConnected { return [self notImplemented:_cmd] ? YES : NO ; }

- (BOOL)connect     { return [self notImplemented:_cmd] ? YES : NO ; }
- (BOOL)disconnect  { return [self notImplemented:_cmd] ? YES : NO ; }

- (MSArray *)tableNames { return [self notImplemented:_cmd] ; }

- (MSDBResultSet *)fetchWithRequest:(NSString *)sqlRequest
{ return [self notImplemented:_cmd] ; sqlRequest= nil; }

- (MSDBTransaction *)openTransaction { return [self notImplemented:_cmd] ; }
- (MSInt)executeRawSQL:(NSString *)sqlRequest
{ return [self notImplemented:_cmd] ? 1 : 0; sqlRequest= nil; }

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

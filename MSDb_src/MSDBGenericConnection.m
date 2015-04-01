/*
 
 MSDBGenericConnection.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
 Eric Baradat :  k18rt@free.fr
 Jean-Michel Bertheas :  jean-michel.bertheas@club-internet.fr
 Hugues Nauguet :  h.nauguet@laposte.net
 Frederic Olivi : fred.olivi@free.fr
 
 
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
 
 WARNING : this implementation file concerns A PRIVATE CLASS
 
 */

#import "MSDatabase_Private.h"

@implementation MSDBGenericConnection

// TODO: MSGetEncodingFrom was declared in MSUnichar.h Good choice ? in MSNet ?
static NSStringEncoding _MSGetEncodingFrom(id object)
{
  static NSDictionary *__knownEncodings= nil;
  id res= nil ;
  if (!__knownEncodings) {
    id utf8=     [NSNumber numberWithInt:NSUTF8StringEncoding] ;
    id isolatin= [NSNumber numberWithInt:NSISOLatin1StringEncoding] ;
    id mac=      [NSNumber numberWithInt:NSMacOSRomanStringEncoding] ;
    id ansi=     [NSNumber numberWithInt:NSWindowsCP1252StringEncoding] ;
    id next=     [NSNumber numberWithInt:NSNEXTSTEPStringEncoding] ;
    id utf16=    [NSNumber numberWithInt:NSUTF16StringEncoding] ;
    __knownEncodings= [ALLOC(NSDictionary) initWithObjectsAndKeys:
      utf8, @"UTF8", utf8, @"UTF-8", utf8, utf8,
      isolatin, @"ISOLATIN", isolatin, @"ISOLATIN1", isolatin, @"ISO-LATIN",
      isolatin, @"ISO-LATIN-1", isolatin, isolatin,
      mac, @"MAC", mac, @"MACROMAN", mac, @"MAC-ROMAN", mac, @"MACOSROMAN",
      mac, @"MAC-OS-ROMAN", mac, mac,
      ansi, @"WIN", ansi, @"WINDOWS", ansi, @"WINLATIN1", ansi, @"WIN-LATIN-1",
      ansi, @"WINDOWS-LATIN-1", ansi, @"ANSI", ansi, ansi,
      next, @"NEXT", next, @"NEXTSTEP", next, next,
      utf16, @"UNICODE", utf16, @"UTF16", utf16, @"UTF-16", utf16, utf16,
      nil] ; }
  
  if (object) {
    if ([object isKindOfClass:[NSNumber class]]) {
      res= [__knownEncodings objectForKey:[NSNumber numberWithInt:[object intValue]]] ; }
    else {
      NSString *s= [[object toString] uppercaseString] ;
      if ([s length]) {
        res= [__knownEncodings objectForKey:s] ;
        if (!res) {
          res= [__knownEncodings objectForKey:[NSNumber numberWithInt:[s intValue]]] ; }}}}
  return (res ? (NSStringEncoding)[res intValue] : 0) ;
}

#pragma mark Init

- (id)initWithConnectionDictionary:(MSDictionary *)dictionary
{
  if ((self= [super initWithConnectionDictionary:dictionary])) {
    NSStringEncoding encoding ;
    NSZone *zone = [self zone] ;
    
    _currentDictionary = [dictionary mutableCopyWithZone:zone] ;
    
    _writeEncoding = _readEncoding = NSUTF8StringEncoding ;
    
    _operations = [[MSArray alloc] mutableInitWithCapacity:0 noRetainRelease:YES nilItems:NO] ;

    // WARNING : you can get NSNEXTSTEPStringEncoding and NSUTF16StringEncoding
    if ((encoding= _MSGetEncodingFrom([dictionary objectForKey:@"encoding"]))) {
      _readEncoding= _writeEncoding= encoding ; }
    if ((encoding= _MSGetEncodingFrom([dictionary objectForKey:@"read-encoding"]))) {
      _readEncoding= encoding ; }
    if ((encoding= _MSGetEncodingFrom([dictionary objectForKey:@"write-encoding"]))) {
      _writeEncoding= encoding ; }
    _cFlags.connected= NO;
    _cFlags.inTransaction= NO;
    _cFlags.readOnly= (MSUInt)[[dictionary objectForLazyKeys:@"read-only",@"readonly", nil] isTrue];}
  return self ;
}

- (void)dealloc
{
  [self disconnect] ;  
  RELEASE(_currentDictionary) ;
  RELEASE(_operations) ;
  [super dealloc] ;
}


//- (BOOL)connect ;
- (BOOL)disconnect
{
    if (_cFlags.connected) {
        // since the terminateAllOperations can release us, we must keep that object
        // alive until we decide to release it
        RETAIN(self) ;
        [self terminateAllOperations] ;
        if([self _disconnect]) {
            _cFlags.connected = NO ;
            [[NSNotificationCenter defaultCenter] postNotificationName:MSConnectionDidDisconnectNotification object:self] ;
        }
        RELEASE(self) ;
    }
    return !_cFlags.connected;
}
- (BOOL)_disconnect { [self notImplemented:_cmd]; return NO; }

- (BOOL)isConnected { return _cFlags.connected ; }

#pragma mark Transaction

- (BOOL)isInTransaction { return _cFlags.inTransaction ; }

//- (NSString *)escapeString:(NSString *)aString withQuotes:(BOOL)withQuotes ;
//- (NSString *)escapeString:(NSString *)aString ; // no quotes

//- (MSArray *)tableNames ;

#pragma mark Manage operations

- (void)terminateAllOperations
{
  NSUInteger i = [_operations count] ;
  // leave this loop in that order if you don't want to destroy the element of your array
  // before the end of the loop
  while (i-- > 0) {[[_operations objectAtIndex:i] terminateOperation] ;}
  
  if([self isInTransaction])
    [self rollback];
}

- (void)registerOperation:(MSDBOperation *)anOperation
{
  [_operations addObject:anOperation];
}

- (void)unregisterOperation:(MSDBOperation *)anOperation
{
  [_operations removeObjectIdenticalTo:anOperation];
}

#pragma mark SQLString <-> NSString

- (const char*)sqlCStringWithString:(NSString *)string
{
  return [string cStringUsingEncoding:_writeEncoding allowLossyConversion:YES] ;
}
- (NSData *)sqlDataFromString:(NSString *)string
{
  return [string dataUsingEncoding:_writeEncoding allowLossyConversion:YES] ;
}

- (NSString*)stringFromSQLString:(const char *)sqlString
{
  return sqlString ? [NSString stringWithCString:sqlString encoding:_readEncoding] : nil;
}

- (NSString*)stringFromSQLString:(const char *)sqlString length:(NSUInteger)length
{
  return sqlString ? [[[NSString alloc] initWithBytes:sqlString length:length encoding:_readEncoding] autorelease] : nil;
}

- (NSString*)stringFromSQLData:(NSData *)data
{
  return data ? [[[NSString alloc] initWithData:data encoding:_readEncoding] autorelease] : nil;
}

- (void)addSQLBuffer:(MSBuffer *)sqlBuffer toString:(MSString *)unicodebuffer
{
  CStringAppendBytes((CString*)unicodebuffer, _readEncoding, [sqlBuffer bytes], [sqlBuffer length]);
}

@end

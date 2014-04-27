/*
 
 _MSDBGenericConnection.m
 
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

#import "_MSDBGenericConnection.h"

@implementation _MSDBGenericConnection

- (id)initWithConnectionDictionary:(NSDictionary *)dictionary
{
	NSZone *zone = [self zone] ;

	_operations = (CArray){Nil, NULL, 0, 0} ;
	_originalDictionary = [dictionary copyWithZone:zone] ;
	_currentDictionary = [dictionary mutableCopyWithZone:zone] ;
	_identifiersStore = [[NSMutableDictionary allocWithZone:zone] initWithCapacity:31] ;
    
    _writeEncoding = _readEncoding = NSUTF8StringEncoding ;
    
    // MSGetEncodingFrom is declared in MSUnichar.h. WARNING : you can get NSNEXTSTEPStringEncoding and NSUTF16StringEncoding
    
    if (MSGetEncodingFrom([dictionary objectForKey:@"encoding"], &_writeEncoding)) { _readEncoding = _writeEncoding ; }
    (void)MSGetEncodingFrom([dictionary objectForKey:@"write-encoding"], &_writeEncoding) ;
    (void)MSGetEncodingFrom([dictionary objectForKey:@"read-encoding"], &_readEncoding) ;

	return self ;
}

- (BOOL)isConnected { return _cFlags.connected ; }

- (NSDictionary *)connectionDictionary { return _originalDictionary ; }
- (NSUInteger)requestSizeLimit { (void)[self connect] ; return _requestSizeLimit ; }
- (NSUInteger)inClauseElementsCountLimit { (void)[self connect] ; return _inClauseMaxElements ; }

- (void)terminateAllOperations
{
	NSUInteger i = CArrayCount(&_operations) ;
	// leave this loop in that order if you don't want to destroy the element of you array
	// before the end of the loop
	while (i-- > 0) {[CArrayObjectAtIndex(&_operations, i) terminateOperation] ;} 
}

- (void)resetOperationsArray
{
	if (CArrayCount(&_operations)) {
		CArrayRemoveAllObjectsWithoutRelease(&_operations) ;
		CArrayAdjustSize(&_operations) ;
	}
}

- (void)unregisterOperation:(MSDBOperation *)anOperation
{
	NSUInteger i = CArrayIndexOfIdenticalObject(&_operations, anOperation, 0, CArrayCount(&_operations)) ;
	if (i != NSNotFound) {
		CArrayRemoveObjectAtIndexWithoutRelease(&_operations, i) ;
	}
}


- (void)dealloc
{
	// if we dealloc, that means that we have no operations pending (if pending operations remain, we are retain by these operations)
	[self disconnect] ;
	[self resetOperationsArray] ;
	
	DESTROY(_originalDictionary) ;
	DESTROY(_currentDictionary) ;
	DESTROY(_identifiersStore) ;
	[super dealloc] ;
}

- (MSArray *)allOperations
{
	NSUInteger count = _operations.count ;
	MSArray *array = MSCreateArray(count) ;
	(void)CArrayAddArray((CArray *)array, &_operations) ;
	return AUTORELEASE(array) ;
}

- (MSArray *)_operationsOfClass:(Class)searchedClass
{
	NSUInteger i, count = _operations.count ;
	MSArray *array = MSCreateArray(count) ;

	for (i = 0 ; i < count ; i++) {
		MSDBOperation *o = CArrayObjectAtIndex(&_operations, i) ;
		if ([o isKindOfClass:searchedClass]) {
			MSAAdd(array, o) ;
		}
	}
	return array ;
}

- (MSArray *)pendingRequests { return [self _operationsOfClass:[MSDBResultSet class]] ; }
- (MSArray *)openedTransactions { return [self _operationsOfClass:[MSDBTransaction class]] ; }
- (NSUInteger)openedTransactionsCount 
{
	NSUInteger i, count = _operations.count, total = 0 ;
	Class searchedClass = [MSDBTransaction class] ;
	for (i = 0 ; i < count ; i++) {
		MSDBOperation *o = CArrayObjectAtIndex(&_operations, i) ;
		if ([o isKindOfClass:searchedClass]) { total ++ ; }
	}
	return total ;
}

- (const char *)sqlCStringWithString:(NSString *)aString
{
    return [aString cStringUsingEncoding:_writeEncoding allowLossyConversion:YES] ;
}

- (NSString *)stringWithSQLCString:(const char *)cString ;
{
    return cString ? [NSString stringWithCString:(const char *)cString encoding:_readEncoding] : nil ;
}

- (NSString *)stringWithSQLBuffer:(MSBuffer *)buffer
{
    return buffer ? AUTORELEASE([ALLOC(NSString) initWithData:buffer encoding:_readEncoding]) : nil ;
}

- (void)addSQLString:(const char *)cString toUnicodeBuffer:(CUnicodeBuffer *)buffer
{
    NSString *s = [self stringWithSQLCString:cString] ;
    if (s) { CUnicodeBufferAppendString(buffer, s) ; }
}

- (void)addSQLBuffer:(MSBuffer *)sqlBuffer toUnicodeBuffer:(CUnicodeBuffer *)unicodebuffer
{
    if (sqlBuffer && unicodebuffer) {
        NSString *s = AUTORELEASE([ALLOC(NSString) initWithData:sqlBuffer encoding:_readEncoding]) ;
        if (s) { CUnicodeBufferAppendString(unicodebuffer, s) ; }
    }
}

@end

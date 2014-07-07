
/*
 
 MSMySQLTransaction.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
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
 
 */

#import "MSMySQLAdaptorKit.h"

@interface MSMySQLConnection (MSMySQLTransaction)

- (BOOL)commit ;
- (BOOL)rollback ;
- (MSInt)getLastError ;

@end


@implementation MSMySQLConnection (MSMySQLTransaction)

- (BOOL)commit { return mysql_commit(&_db) ; }
- (BOOL)rollback { return mysql_rollback(&_db) ; }

- (MSInt)getLastError
{
	if ([self connect])	return (MSInt)mysql_errno(&_db) ;
	else return -1 ;
}

@end


@implementation MSMySQLTransaction

- (BOOL)appendSQLCommand:(NSString *)sql error:(MSInt *)errorPtr
{
	BOOL ret = NO ;
	int error = MSMySQLExec(_connection, (char *)[sql UTF8String]) ;
	ret = (error == 0 ? YES : NO) ;
	if (errorPtr) { *errorPtr = (MSInt)error ; }
	return ret ;
}

- (void)terminateOperation
{
	if ([self isOpened]) {
		if ([(MSMySQLConnection *)_connection rollback]) {
			MSRaiseFrom(NSGenericException, self, _cmd, @"impossible to rollback current transaction") ;
		}
		
		[(MSDBGenericConnection *)_connection unregisterOperation:self] ;
		[super terminateOperation] ;
	}
}

- (BOOL)saveWithError:(MSInt *)errorPtr
{
	if ([self isOpened]) {
		if ([(MSMySQLConnection *)_connection commit]) {
			[self terminateOperation] ;
			if (errorPtr) { *errorPtr = [(MSMySQLConnection *)_connection getLastError] ; }
			return NO ;
		}
		[(MSDBGenericConnection *)_connection unregisterOperation:self] ;
		[super terminateOperation] ;
		return YES ;
	}
	return NO ;
}

@end

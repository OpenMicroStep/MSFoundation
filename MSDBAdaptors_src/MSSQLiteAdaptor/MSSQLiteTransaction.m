
/*
 
 MSSQLiteTransaction.m
 
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
#import "_MSDBGenericConnection.h"
#import "MSSQLiteTransaction.h"
#import "MSSQLiteConnection.h"


@implementation MSSQLiteTransaction

- (BOOL)appendSQLCommand:(NSString *)sql error:(MSInt *)errorPtr
{
	BOOL ret = NO ;
  if ([self isActive]) {
  	int error = [_connection executeRawSQL:sql] ;
	  ret = (error == MSSQL_OK ? YES : NO) ;
	  if (errorPtr) { *errorPtr = (MSInt)error ; }}
	return ret ;
}

- (void)terminateOperation
{
	if ([self isActive]) {
		int error = [_connection executeRawSQL:@"ROLLBACK;"] ;
		int try = 0 ;
		
		/*
     since SQLite is not a real database server, the database
     can be locked by another user (or thread). we try 3 more
     times in 3 seconds to rollback our transaction
		 */
		while (error == SQLITE_BUSY && try < 3) {
			[NSThread sleepForTimeInterval:1] ;
			error = [_connection executeRawSQL:@"ROLLBACK;"] ;
		}
		
		if (error != SQLITE_OK) {
			MSRaiseFrom(NSGenericException, self, _cmd, @"impossible to rollback current transaction") ;
		}
		
		[super terminateOperation] ;
	}
}

- (BOOL)saveWithError:(MSInt *)errorPtr
{
	if ([self isActive]) {
		int error = [_connection executeRawSQL:@"COMMIT;"] ;
		if (error != SQLITE_OK) {
			[self terminateOperation] ;
			if (errorPtr) { *errorPtr = error ; }
			return NO ;
		}
		[super terminateOperation] ;
		return YES ;
	}
	return NO ;
}

@end

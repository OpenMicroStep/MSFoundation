/*
 
 _MSDBGenericConnection.h
 
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
 
 WARNING : this header file IS PRIVATE and maint to be included in
 every adaptors
 
 */
#import <MSFoundation/MSFoundation.h>

typedef struct _MSDBGenericConnectionFlagsStruct {
#ifdef __BIG_ENDIAN__
    MSUInt connected:1;
	MSUInt readOnly:1;
	MSUInt usr1:1;
	MSUInt usr2:1;
    MSUInt _pad:28;
#else
    MSUInt _pad:28;
	MSUInt usr2:1;
	MSUInt usr1:1;
	MSUInt readOnly:1;
    MSUInt connected:1;
#endif
} _MSDBGenericConnectionFlags ;

@interface _MSDBGenericConnection : MSDBConnection
{
@protected
	NSDictionary *_originalDictionary ;
	NSMutableDictionary *_currentDictionary ;
	NSMutableDictionary *_identifiersStore ;
	NSStringEncoding _readEncoding ;
    NSStringEncoding _writeEncoding ;
    
	CArray _operations ;
	
	NSUInteger _requestSizeLimit ;
	NSUInteger _inClauseMaxElements ;
	
	_MSDBGenericConnectionFlags _cFlags ;
}

- (id)initWithConnectionDictionary:(NSDictionary *)dictionary ;

- (NSUInteger)openedTransactionsCount ;

- (void)resetOperationsArray ;
- (void)terminateAllOperations ;
- (void)unregisterOperation:(MSDBOperation *)anOperation ;

- (const char *)sqlCStringWithString:(NSString *)aString ;
- (NSString *)stringWithSQLCString:(const char *)cString ;
- (NSString *)stringWithSQLBuffer:(MSBuffer *)buffer ;
- (void)addSQLString:(const char *)cString toUnicodeBuffer:(CUnicodeBuffer *)buffer ;
- (void)addSQLBuffer:(MSBuffer *)sqlBuffer toUnicodeBuffer:(CUnicodeBuffer *)unicodebuffer ;
@end

/*
 
 MSDBTransaction.h
 
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
 
 WARNING : this header file cannot be included alone, please direclty
 include <MSFoundation/MSFoundation.h>
 */

@interface MSDBTransaction : MSDBOperation

// Please don't directly send COMMIT or ROLLBACK commands to the database
// MSDBTransaction handle that for you throught save and cancel methods ;

// methods apply only if the operation isActive.

// The following methods needs to be implemented by adaptors:
// - (BOOL)appendSQLCommand:(NSString *)sql error:(MSInt *)errorPtr
//   For the folllowing methods, the MSDBOperation (super) terminateOperation method,
//   needs to be called at end.
// - (void)terminateOperation
// - (BOOL)saveWithError:(MSInt *)error

- (BOOL)appendSQLCommand:(NSString *)sql ;
- (BOOL)appendSQLCommand:(NSString *)sql error:(MSInt *)errorPtr ;

- (void)cancel ;  // same as terminateOperation (terminate and close the operation without saving) ;

- (BOOL)save ;
- (BOOL)saveWithError:(MSInt *)error ;

- (NSString *)escapeString:(NSString *)aString withQuotes:(BOOL)withQuotes ;
- (NSString *)escapeString:(NSString *)aString ; // no quotes

@end

@interface MSDBTransaction (IdentifiersManagement)

- (void)reserveIdentifiers:(NSUInteger)count ;
- (void)reserveIdentifiers:(NSUInteger)count forKey:(NSString *)key ;

- (MSULong)nextIdentifier ;
- (MSULong)nextIdentifierForKey:(NSString *)key ;

- (MSULong)firstIdentifierOf:(NSUInteger)count ;
- (MSULong)firstIdentifierOf:(NSUInteger)count forKey:(NSString *)key;

@end


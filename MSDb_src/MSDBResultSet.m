/*
 
 MSDBResultSet.m
 
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

#import "MSDb_Private.h"

@implementation MSDBResultSet

- (void)dealloc
{
	DESTROY(_columnsDescription) ;
	[super dealloc] ;
}
- (BOOL)nextRow { return NO ; }

- (NSUInteger)columnsCount { return [_columnsDescription count] ; }
- (NSString *)nameOfColumn:(NSUInteger)column { return [[_columnsDescription keys] objectAtIndex:column] ; }
- (MSColumnType)typeOfColumn:(NSUInteger)column { return MSNoValueColumn ; column= 0; }
- (NSArray *)columnNames { return [_columnsDescription keys] ; }

- (id)objectForKey:(id)aKey
{
	id o = nil ;
	if (aKey && _columnsDescription) {
		NSUInteger idx = [_columnsDescription indexForKey:aKey] ;
		if (idx != NSNotFound) {
            o = [self objectAtColumn:idx] ;
        }
	}
	return o ;
}

- (id)objectAtColumn:(NSUInteger)idx { return [self notImplemented:_cmd] ; idx= 0; }
- (MSRow *)rowDictionary { return [self notImplemented:_cmd] ; }


- (MSArray *)allValues { return [self notImplemented:_cmd] ; }

- (BOOL)getCharAt:(MSChar *)aValue column:(NSUInteger)column { return [self getCharAt:aValue column:column error:NULL] ; }
- (BOOL)getByteAt:(MSByte *)aValue column:(NSUInteger)column { return [self getByteAt:aValue column:column error:NULL] ; }
- (BOOL)getShortAt:(MSShort *)aValue column:(NSUInteger)column { return [self getShortAt:aValue column:column error:NULL] ; }
- (BOOL)getUnsignedShortAt:(MSUShort *)aValue column:(NSUInteger)column { return [self getUnsignedShortAt:aValue column:column error:NULL] ; }
- (BOOL)getIntAt:(MSInt *)aValue column:(NSUInteger)column { return [self getIntAt:aValue column:column error:NULL] ; }
- (BOOL)getUnsignedIntAt:(MSUInt *)aValue column:(NSUInteger)column { return [self getUnsignedIntAt:aValue column:column error:NULL] ; }
- (BOOL)getLongAt:(MSLong *)aValue column:(NSUInteger)column { return [self getLongAt:aValue column:column error:NULL] ; }
- (BOOL)getUnsignedLongAt:(MSULong *)aValue column:(NSUInteger)column { return [self getUnsignedLongAt:aValue column:column error:NULL] ; }
- (BOOL)getFloatAt:(float *)aValue column:(NSUInteger)column { return [self getFloatAt:aValue column:column error:NULL] ; }
- (BOOL)getDoubleAt:(double *)aValue column:(NSUInteger)column { return [self getDoubleAt:aValue column:column error:NULL] ; }
- (BOOL)getDateAt:(MSTimeInterval *)aDate column:(NSUInteger)column { return [self getDateAt:aDate column:column error:NULL] ; }
- (BOOL)getStringAt:(CUnicodeBuffer *)aString column:(NSUInteger)column { return [self getStringAt:aString column:column error:NULL] ; }
- (BOOL)getBufferAt:(CBuffer *)aBuffer column:(NSUInteger)column { return [self getBufferAt:aBuffer column:column error:NULL] ; }


- (BOOL)getCharAt:(MSChar *)aValue column:(NSUInteger)column error:(MSInt *)error
{ if (error) *error = MSNoAdaptor ; return NO ; aValue= NULL; column= 0; }
- (BOOL)getShortAt:(MSShort *)aValue column:(NSUInteger)column error:(MSInt *)error
{ if (error) *error = MSNoAdaptor ; return NO ; aValue= NULL; column= 0; }
- (BOOL)getIntAt:(MSInt *)aValue column:(NSUInteger)column error:(MSInt *)error
{ if (error) *error = MSNoAdaptor ; return NO ; aValue= NULL; column= 0; }
- (BOOL)getLongAt:(MSLong *)aValue column:(NSUInteger)column error:(MSInt *)error
{ if (error) *error = MSNoAdaptor ; return NO ; aValue= NULL; column= 0; }
- (BOOL)getFloatAt:(float *)aValue column:(NSUInteger)column error:(MSInt *)error
{ if (error) *error = MSNoAdaptor ; return NO ; aValue= NULL; column= 0; }
- (BOOL)getDoubleAt:(double *)aValue column:(NSUInteger)column error:(MSInt *)error
{ if (error) *error = MSNoAdaptor ; return NO ; aValue= NULL; column= 0; }
- (BOOL)getDateAt:(MSTimeInterval *)aDate column:(NSUInteger)column error:(MSInt *)error
{ if (error) *error = MSNoAdaptor ; return NO ; aDate= NULL; column= 0; }
- (BOOL)getStringAt:(CUnicodeBuffer *)aString column:(NSUInteger)column error:(MSInt *)error
{ if (error) *error = MSNoAdaptor ; return NO ; aString= NULL; column= 0; }
- (BOOL)getBufferAt:(CBuffer *)aBuffer column:(NSUInteger)column error:(MSInt *)error
{ if (error) *error = MSNoAdaptor ; return NO ; aBuffer= NULL; column= 0; }

- (BOOL)getByteAt:(MSByte *)aValue column:(NSUInteger)column error:(MSInt *)error
{ return [self getCharAt:(MSChar *)aValue column:column error:error] ; }

- (BOOL)getUnsignedShortAt:(MSUShort *)aValue column:(NSUInteger)column error:(MSInt *)error
{ return [self getShortAt:(MSShort *)aValue column:column error:error] ; }

- (BOOL)getUnsignedIntAt:(MSUInt *)aValue column:(NSUInteger)column error:(MSInt *)error
{ return [self getIntAt:(MSInt *)aValue column:column error:error] ; }

- (BOOL)getUnsignedLongAt:(MSULong *)aValue column:(NSUInteger)column error:(MSInt *)error
{ return [self getLongAt:(MSLong *)aValue column:column error:error] ; }

@end

BOOL MSGetSqlDateFromBytes(void *bytes, NSUInteger length, MSTimeInterval *t)
{
	// TO DO : decoding a STANDARD SQL DATE
	return NO ;
  bytes= NULL; length= 0; t= NULL;
}


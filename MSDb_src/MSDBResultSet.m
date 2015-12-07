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

#import "MSDatabase_Private.h"

@implementation MSDBResultSet

- (void)dealloc
{
  RELEASE(_columnsDescription) ;
  [super dealloc] ;
}

- (BOOL)nextRow { [self notImplemented:_cmd]; return NO ; }
- (id)objectAtColumn:(NSUInteger)idx { return [self notImplemented:_cmd] ; idx= 0; }


- (NSUInteger)columnsCount
{ return [_columnsDescription count] ; }
- (NSArray *)columnNames
{ return [_columnsDescription keys] ; }

- (NSString *)nameOfColumn:(NSUInteger)column
{ return [[_columnsDescription keys] objectAtIndex:column] ; }
- (MSColumnType)typeOfColumn:(NSUInteger)column
{ return MSNoValueColumn ; column= 0; }

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

- (MSArray *)allValues
{
  NSUInteger columnsCount = [self columnsCount] ;
  CArray *values = CCreateArray(columnsCount) ;
  if (columnsCount && values) {
    NSUInteger i ;
    for (i = 0; i < columnsCount ; i++) {
      id o = [self objectAtColumn:i] ;
      if (!o) { o = MSNull ; }
      CArrayAddObject(values, o) ;
    }
  }
  return AUTORELEASE(values) ;
}

- (MSRow *)rowDictionary
{
	return AUTORELEASE([ALLOC(MSRow) initWithRowKeys:_columnsDescription values:[self allValues]]) ;
}

- (BOOL)getCharAt:           (MSChar *)aValue column:(NSUInteger)column { return [self getCharAt:         aValue column:column error:NULL]; }
- (BOOL)getByteAt:           (MSByte *)aValue column:(NSUInteger)column { return [self getByteAt:         aValue column:column error:NULL]; }
- (BOOL)getShortAt:         (MSShort *)aValue column:(NSUInteger)column { return [self getShortAt:        aValue column:column error:NULL]; }
- (BOOL)getUnsignedShortAt:(MSUShort *)aValue column:(NSUInteger)column { return [self getUnsignedShortAt:aValue column:column error:NULL]; }
- (BOOL)getIntAt:             (MSInt *)aValue column:(NSUInteger)column { return [self getIntAt:          aValue column:column error:NULL]; }
- (BOOL)getUnsignedIntAt:    (MSUInt *)aValue column:(NSUInteger)column { return [self getUnsignedIntAt:  aValue column:column error:NULL]; }
- (BOOL)getLongAt:           (MSLong *)aValue column:(NSUInteger)column { return [self getLongAt:         aValue column:column error:NULL]; }
- (BOOL)getUnsignedLongAt:  (MSULong *)aValue column:(NSUInteger)column { return [self getUnsignedLongAt: aValue column:column error:NULL]; }
- (BOOL)getFloatAt:           (float *)aValue column:(NSUInteger)column { return [self getFloatAt:        aValue column:column error:NULL]; }
- (BOOL)getDoubleAt:         (double *)aValue column:(NSUInteger)column { return [self getDoubleAt:       aValue column:column error:NULL]; }
- (BOOL)getDateAt:    (MSTimeInterval *)aDate column:(NSUInteger)column { return [self getDateAt:          aDate column:column error:NULL]; }
- (BOOL)getStringAt:      (MSString *)aString column:(NSUInteger)column { return [self getStringAt:      aString column:column error:NULL]; }
- (BOOL)getBufferAt:      (MSBuffer *)aBuffer column:(NSUInteger)column { return [self getBufferAt:      aBuffer column:column error:NULL]; }

#define NUMBERATCOLUMN(self, aValue, column, error, SELECTOR) ({                          \
  BOOL ret= NO; id o= [self objectAtColumn:column];                                       \
  if (!o) { if (error) *error= MSFetchMallocError; }                                      \
  else if (o == MSNull) { if (error) *error= MSNullFetch; }                               \
  else if ([o isKindOfClass:[NSNumber class]] || [o isKindOfClass:[MSDecimal class]]) {   \
    *aValue= [o SELECTOR];                                                                \
    ret= YES;                                                                             \
  }                                                                                       \
  else if (error) *error= MSNotConverted;                                                 \
  ret;                                                                                    \
})

- (BOOL)getCharAt:           (MSChar *)aValue column:(NSUInteger)column error:(MSInt *)error { return NUMBERATCOLUMN(self, aValue, column, error, charValue); }
- (BOOL)getByteAt:           (MSByte *)aValue column:(NSUInteger)column error:(MSInt *)error { return NUMBERATCOLUMN(self, aValue, column, error, unsignedCharValue); }
- (BOOL)getShortAt:         (MSShort *)aValue column:(NSUInteger)column error:(MSInt *)error { return NUMBERATCOLUMN(self, aValue, column, error, shortValue); }
- (BOOL)getUnsignedShortAt:(MSUShort *)aValue column:(NSUInteger)column error:(MSInt *)error { return NUMBERATCOLUMN(self, aValue, column, error, unsignedShortValue); }
- (BOOL)getIntAt:             (MSInt *)aValue column:(NSUInteger)column error:(MSInt *)error { return NUMBERATCOLUMN(self, aValue, column, error, intValue); }
- (BOOL)getUnsignedIntAt:    (MSUInt *)aValue column:(NSUInteger)column error:(MSInt *)error { return NUMBERATCOLUMN(self, aValue, column, error, unsignedIntValue); }
- (BOOL)getLongAt:           (MSLong *)aValue column:(NSUInteger)column error:(MSInt *)error { return NUMBERATCOLUMN(self, aValue, column, error, longLongValue); }
- (BOOL)getUnsignedLongAt:  (MSULong *)aValue column:(NSUInteger)column error:(MSInt *)error { return NUMBERATCOLUMN(self, aValue, column, error, unsignedLongLongValue); }
- (BOOL)getFloatAt:           (float *)aValue column:(NSUInteger)column error:(MSInt *)error { return NUMBERATCOLUMN(self, aValue, column, error, floatValue); }
- (BOOL)getDoubleAt:         (double *)aValue column:(NSUInteger)column error:(MSInt *)error { return NUMBERATCOLUMN(self, aValue, column, error, doubleValue); }
- (BOOL)getDateAt:   (MSTimeInterval *)aDate column:(NSUInteger)column error:(MSInt *)error {
  BOOL ret= NO; id o= [self objectAtColumn:column];
  if (!o) {
    *error= MSFetchMallocError;
  }
  else if (o == MSNull) {
    *error= MSNullFetch;
  }
  else if ([o isKindOfClass:[NSDate class]]) {
    *aDate= [o timeIntervalSinceReferenceDate];
    ret= YES;
  }
  else if (error) {
    *error= MSNotConverted;
  }
  return ret;
}

- (BOOL)getStringAt:     (MSString *)aString column:(NSUInteger)column error:(MSInt *)error {
  BOOL ret= NO; id o= [self objectAtColumn:column];
  if (!o) {
    *error= MSFetchMallocError;
  }
  else if (o == MSNull) {
    *error= MSNullFetch;
  }
  else if ([o isKindOfClass:[NSString class]]) {
    [aString appendString:o];
    ret= YES;
  }
  else if ([o isKindOfClass:[NSNumber class]] || [o isKindOfClass:[MSDecimal class]]) {
    [aString appendString:[o description]];
    ret= YES;
  }
  else if (error) {
    *error= MSNotConverted;
  }
  return ret;
}
- (BOOL)getBufferAt:     (MSBuffer *)aBuffer column:(NSUInteger)column error:(MSInt *)error {
  BOOL ret= NO; id o= [self objectAtColumn:column];
  if (!o) {
    *error= MSFetchMallocError;
  }
  else if (o == MSNull) {
    *error= MSNullFetch;
  }
  else if ([o isKindOfClass:[NSData class]]) {
    [aBuffer appendData:o];
    ret= YES;
  }
  else if (error) {
    *error= MSNotConverted;
  }
  return ret;
}

@end

BOOL MSGetSqlDateFromBytes(void *bytes, NSUInteger length, MSTimeInterval *t)
{
  // TODO: decoding a STANDARD SQL DATE
  return NO ;
  bytes= NULL; length= 0; t= NULL;
}


/*
 
 MSDBResultSet.h
 
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
typedef enum {
  MSUnknownTypeColumn = 0,
  MSNoValueColumn,
  MSStringColumn,
  MSDataColumn,
  MSDateColumn,
  MSNumberColumn,
  MSSpatialColumn
} MSColumnType ;

#ifndef MSFetchOK
#define MSFetchOK             0
#define MSNullFetch           1
#define MSNoColumn           -1
#define MSNotConverted       -2
#define MSNoAdaptor          -3
#define MSFetchMallocError   -4
#define MSNotInitalizedFetch -5
#define MSFetchIsOver        -6
#endif

@class MSDBConnection, MSRowKeys ;

@interface MSDBResultSet : MSDBOperation
{
  MSRowKeys *_columnsDescription ;
}

- (BOOL)nextRow ; // you need to make a nextRow to access the first row

// informations on columns
- (NSUInteger)columnsCount ;
- (MSArray *)columnNames ;
- (NSString *)nameOfColumn:(NSUInteger)column ;
- (MSColumnType)typeOfColumn:(NSUInteger)column ;

// getting values
// in all getting values method, when the value is null, we get NO as result
- (BOOL)getCharAt:           (MSChar *)aValue column:(NSUInteger)column ;
- (BOOL)getByteAt:           (MSByte *)aValue column:(NSUInteger)column ;
- (BOOL)getShortAt:         (MSShort *)aValue column:(NSUInteger)column ;
- (BOOL)getUnsignedShortAt:(MSUShort *)aValue column:(NSUInteger)column ;
- (BOOL)getIntAt:             (MSInt *)aValue column:(NSUInteger)column ;
- (BOOL)getUnsignedIntAt:    (MSUInt *)aValue column:(NSUInteger)column ;
- (BOOL)getLongAt:           (MSLong *)aValue column:(NSUInteger)column ;
- (BOOL)getUnsignedLongAt:  (MSULong *)aValue column:(NSUInteger)column ;
- (BOOL)getFloatAt:           (float *)aValue column:(NSUInteger)column ;
- (BOOL)getDoubleAt:         (double *)aValue column:(NSUInteger)column ;
- (BOOL)getDateAt:    (MSTimeInterval *)aDate column:(NSUInteger)column ;
- (BOOL)getStringAt:      (MSString *)aString column:(NSUInteger)column ; // beware, the string you get is appended to your unicode buffe
- (BOOL)getBufferAt:      (MSBuffer *)aBuffer column:(NSUInteger)column ; // beware, the data you get is appended to your buffer

// - (BOOL)getPointAt:(CPoint *)aPoint column:(NSUInteger)column ;
// - (BOOL)getPolylineAt:(CPolyline *)aPolygon column:(NSUInteger)column ;
// - (BOOL)getPolygonAt:(CPolygon *)aPolygon column:(NSUInteger)column ;

// with this set of method, we get indication on how we get the value
- (BOOL)getCharAt:           (MSChar *)aValue column:(NSUInteger)column error:(MSInt *)error ;
- (BOOL)getByteAt:           (MSByte *)aValue column:(NSUInteger)column error:(MSInt *)error ;
- (BOOL)getShortAt:         (MSShort *)aValue column:(NSUInteger)column error:(MSInt *)error ;
- (BOOL)getUnsignedShortAt:(MSUShort *)aValue column:(NSUInteger)column error:(MSInt *)error ;
- (BOOL)getIntAt:             (MSInt *)aValue column:(NSUInteger)column error:(MSInt *)error ;
- (BOOL)getUnsignedIntAt:    (MSUInt *)aValue column:(NSUInteger)column error:(MSInt *)error ;
- (BOOL)getLongAt:           (MSLong *)aValue column:(NSUInteger)column error:(MSInt *)error ;
- (BOOL)getUnsignedLongAt:  (MSULong *)aValue column:(NSUInteger)column error:(MSInt *)error ;
- (BOOL)getFloatAt:           (float *)aValue column:(NSUInteger)column error:(MSInt *)error ;
- (BOOL)getDoubleAt:         (double *)aValue column:(NSUInteger)column error:(MSInt *)error ;
- (BOOL)getDateAt:    (MSTimeInterval *)aDate column:(NSUInteger)column error:(MSInt *)error ;
- (BOOL)getStringAt:      (MSString *)aString column:(NSUInteger)column error:(MSInt *)error ; // beware, the string you get is appended to your unicode buffer
- (BOOL)getBufferAt:      (MSBuffer *)aBuffer column:(NSUInteger)column error:(MSInt *)error ; // beware, the data you get is appended to your buffer

// generic method to get values as object
- (id)objectAtColumn:(NSUInteger)index  ; // returns nil if an error occured or if the column is null. raises if you are out of bounds
- (id)objectForKey:(id)aKey ; // returns nil if an error occured or if the column is null or absent
- (MSRow *)rowDictionary ; // null columns are represented as null objects
- (MSArray *)allValues ; // null columns are represented as null objects
@end

MSDatabaseExport BOOL MSGetSqlDateFromBytes(void *bytes, NSUInteger length, MSTimeInterval *t) ;

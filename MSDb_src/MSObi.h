/* MSObi.h
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre: herve@malaingre.com
 Eric Baradat:    k18rt@free.fr
 
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

#define MSUnchanged 0x00 // Obi OValue
#define MSCreate    0x01 // Obi
#define MSDelete    0x02 // Obi
#define MSModify    0x05 // Obi Some values to add and remove
#define MSSubModify 0x06 // Obi The modification take place on the sub-instance
#define MSAdd       0x03 // OValue Some new values
#define MSRemove    0x04 // OValue Some values to remove

#define S8 0xF9 // signed  8
#define R8 0xF6 // real    8
#define T8 0xAF // txt     8
#define B8 0xEC // obj     8
typedef union {
  MSLong    s;  // PRIVATE
  double    r;
  MSString *t;  // t est retained
  MSOid    *b;} // base id = oid value retained
_btypedValue;

@class MSObi,MSOdb;
@interface MSOValue : NSObject
{
@private
  MSOid* _cid;       // car oid
  MSObi* _car;       // The car obi.
  MSByte _state;     // MSUnchanged | MSAdd | MSRemove | MSSubModify
  //                    Cet état n'a de sens que vis-à-vis de l'obi qui
  //                    contient cette valeur
  MSByte _valueType; // From car obi, 0x00: Unknown
  // TODO: mettre le vrai type, pas la table.
  MSTimeInterval _timestamp; // The timestamp of the value in
  _btypedValue   _value;
  MSObi*         _subValue; // when the value is an id
}

+ (id)valueWithCid:(MSOid*)cid state:(MSByte)state type:(MSByte)type
         timestamp:(MSTimeInterval)t value:(_btypedValue)v;
- (id)initWithCid:(MSOid*)cid state:(MSByte)state type:(MSByte)type
        timestamp:(MSTimeInterval)t value:(_btypedValue)v;

// equal: Equality on _cid,_timestamp and _value. Not _state.
- (BOOL)equal:(id)x;
- (NSComparisonResult)compare:(id)x;
- (MSOid*)cid;
- (MSTimeInterval)timestamp;
- (id)typedValue;
// stringValue: Nil if the value is not of that type
- (NSString*)stringValue;
- (MSOid*)oidValue;
- (MSObi*)subValue;
- (MSByte)state;
- (void)setState:(MSByte)state;
- (void)setSub:(MSObi*)o;
- (NSString*)description:(int)n;
- (NSString*)descriptionInContext:(id)ctx;
@end

@interface MSObi : NSObject
{
@private
  id      _db;     // the unretained MSDatabase
  MSByte  _status; // création, destruction, ajout et/ou suppression de valeurs
  MSOid  *_oid;    // référence de l'instance. Négative si non enregistré ?
  MSOid  *_entOid; // référence de l'entité
  MSObi  *_ent;
  MSMutableDictionary *_valuesByCid;
}

+ (id)obiWithLocalId:(id)db;
- (id)iniWithLocalId:(id)db;
+ (id)obiWithOid: (MSOid*)oid :(id)db;
- (id)initWithOid:(MSOid*)oid :(id)db;
- (MSOid*)oid;
- (MSByte)status;
- (NSString*)description:(int)n;
// descriptionInContext:ctx
// ctx= {'Odb'=>    MSOdb*,
//       'Strict'=> If YES, no obi completude,
//       'Small'=>  If YES, no system name translation,
//       }
- (NSString*)descriptionInContext:(MSDictionary*)ctx;
// Get
- (MSArray*)cids;
- (MSDictionary*)allValuesByCid;

// allValuesForCid:cid
// Returns all the values of the car for any timestamp
- (MSArray*)allValuesForCid:(MSOid*)cid;

// valuesForCid:cid
// Returns all the values of the car for the current timestamp
- (MSArray*)valuesForCid:(MSOid*)cid;

// valueForCid:cid
// Returns only one value (for the current timestamp)
- (MSOValue*)valueForCid:(MSOid*)cid;

- (MSArray*)typedValuesForCid:(MSOid*)cid;
- (id)typedValueForCid:(MSOid*)cid;
- (MSArray*)stringValuesForCid:(MSOid*)cid;

// stringValueForCid:cid
// Returns only the first (last ?) value (for the last timestamp)
// Nil if the value is not of that type
- (NSString*)stringValueForCid:(MSOid*)cid;
- (MSArray*)oidValuesForCid:(MSOid*)cid;
- (MSOid*)oidValueForCid:(MSOid*)cid;
- (MSObi*)subValueForCid:(MSOid*)cid;
- (NSString*)systemName;
// Set
- (BOOL)setValue:(MSOValue*)v;
@end

@interface MSObi (Private)
- (void)setOid:(MSOid*)oid;
@end

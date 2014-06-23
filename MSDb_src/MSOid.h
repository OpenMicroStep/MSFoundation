/* MSOid.h
 
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

@class MSOid,MSOdb;
typedef MSString* txt;
typedef MSOid*    oid; // object id
typedef id        vid; // virtual id: oid | txt | MSObi*
typedef id        uid; // union id: vid | MSUid*

@protocol MSOidProtocol
- (MSOid*)oid;
- (NSString*)systemName;
@end

// TODO: lien vers la DB
// TODO: mask de la DB ? Dans l'_oid ?
@interface MSOid : NSObject <NSCopying>
{
@private
  MSLong _oid;
}
+ (id)oidWithLongValue:(MSLong)a;
- (id)initWithLongValue:(MSLong)a;
- (NSComparisonResult)compare:(id)x;
- (NSUInteger)hash:(unsigned)depth; // For MSDictionary
- (MSOid*)oid;
- (MSLong)longValue;
- (NSString*)descriptionForDb:(MSOdb*)db;
- (BOOL)isLocal;
- (void)setNonLocalLongValue:(MSLong)a;
  // Uniquement si _oid est local (négatif).
@end

// Souvent on se réfère à un objet de type uid lorsqu'il fait référence à un oid
// sans nécessairement en être un. C'est soit un oid, soit un libellé système,
// soit un MSObi. Ce même type peut aussi faire référence à une collection de
// uid.

@class MSOdb;
@interface MSUid : NSObject
{
@private
  MSMutableArray *_txtsInOids; // refere to one in _oids
  MSMutableArray *_txtsMore;   // may refere or not to one in _oids (not in previous array)
  MSMutableArray *_oids;
}
+ (id)uid;
+ (id)uidWithUid:(uid)u;
- (id)initWithUid:(uid)u;
- (void)addUid:(uid)u;
- (BOOL)containsVid:(vid)v;
- (id)oids;
- (id)otherSystemNames;
- (MSUid*)resolvedUidForOdb:(MSOdb*)db;
- (NSUInteger)count;
- (NSString*)descriptionInContext:(MSDictionary*)ctx;
  // Ctx= {'Odb'=>    MSOdb*,
  //       'Strict'=> If YES, no obi completude,
  //       'Small'=>  If YES, no system name translation,
  //       }

- (uid)firstUid;
- (BOOL)addFirstOid:(MSOid*)u;
- (void)removeFirstUid;
@end

extern MSOid    *MSEntEntId;    // id de l'entité 'Ent'
//extern MSOid    *MSEntCarId;    // id de l'entité 'Car'
extern MSOid    *MSEntTypId;    // id de l'entité 'Typ'
extern MSOid    *MSCarEntityId;         // id de la car 'entité'
extern MSOid    *MSCarSystemNameId;     // id de la car 'system name'
extern MSString *MSCarSystemNameLib;    // id de la car 'system name'
//extern MSOid    *MSCarClassNameId;     // id de la car 'class name'
//extern MSOid    *MSCarCharacteristicId; // id de la car 'caract.'
extern MSOid    *MSCarTypeId;           // id de la car 'type'
extern MSOid    *MSCarTableId;          // id de la car 'table'
//extern MSOid    *MSCarGabaritId;        // id de la car 'gabarit'
//extern MSOid    *MSCarDomaineId;        // id de la car 'domaine'
extern MSOid    *MSCarDateId;           // id de la car 'date'
//extern MSOid    *MSCarLibelleId;        // id de la car 'libellé'
//extern MSOid    *MSTypIDId;  // id du Type 'ID'
//extern MSOid    *MSTypSIDId; // id du Type 'SID'
//extern MSOid    *MSTypSTRId; // id du Type 'STR'
//extern MSOid    *MSTypINTId; // id du Type 'INT'
//extern MSOid    *MSTypDATId; // id du Type 'DAT'
//extern MSOid    *MSTypDTRId; // id du Type 'DTR'
//extern MSOid    *MSTypDURId; // id du Type 'DUR'
extern MSOid    *MSObiDatabaseId;           // id de la 'database'

#pragma mark private

extern NSString *_obiDesc(MSLong level, MSDictionary *ctx,
  MSUid *todoOrder, MSMutableDictionary *todo);

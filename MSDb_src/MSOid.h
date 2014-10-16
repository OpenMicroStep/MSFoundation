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

#define MSContextOdb          @"Odb"
#define MSContextSystemNames  @"Names"
#define MSContextCompleteness @"All"
// descriptionInContext:ctx
// ctx= {MSContextOdb=>     MSOdb*,
//       MSContextSystemNames=>  if YES, obi completeness (default NO)
//       MSContextCompleteness=> if YES, obi completeness (default NO)
//       'Options'=> ('Completude','System name translation')
//       'Strict'=> If YES, no obi completude,
//       'Small'=>  If YES, no system name translation,
//       }
// The context may also be the MSOdb alone.
// If strict (default), the description includes only the obis of self.
// If not strict, the description includes all the obis needed to be completed.
// If small (default), The MSOid are represented as number.
// If not small, all MSOid with system name are remplaced by there system name.

// MSOid is the id of a oui-base object. It may be in a 'local' temporary state,
// meaning not yet a fully database reserved number.
// TODO: lien vers la DB ?
// TODO: mask de la DB ? Dans l'_oid ?

@class MSOdb;
@interface MSOid : NSObject <NSCopying>
{
@private
  MSLong _oid;
}
+ (id)oidWithLongLongValue:(MSLong)a;
- (id)initWithLongLongValue:(MSLong)a;

- (NSComparisonResult)compare:(id)x;
- (NSUInteger)hash:(unsigned)depth; // For MSDictionary
- (NSString*)sqlDescription:(MSOdb*)db;
- (NSString*)descriptionInContext:(id)ctx;

- (MSOid*)oid;
- (MSLong)longLongValue;
- (BOOL)isLocal;

// replaceLocalLongLongValue:a
// Uniquement si _oid est local (négatif).
- (void)replaceLocalLongLongValue:(MSLong)a;
@end

// A oui-base object is called a 'obi'.
// A MSUid's object is a collection of obi identifiers.
// An identifier may be a MSOid but also the system name of the obi.
// Some of the identifiers in the collection may be refered by both.
// The MSUid is resolved when the MSOid of all the system names
// in the collection are known (_txtsMore is empty).

// In some case, the obi itself may be also used as its own identifier
// (that why MSObi responds to oid message).
// We refer a system name identifier with the type txt.
// We refer a virtual identifier (txt, MSOid* or MSObi*) with the type vid.
// We refer a collection witch may be a simple identifier (vid), a MSUid or
// an array of vid or MSUid or array with the type uid.

typedef MSString* txt;
//typedef MSOid*    oid; // object id
typedef id        vid; // virtual id: txt | MSOid* | MSObi*
typedef id        uid; // union id: vid | MSUid*

@interface MSUid : NSObject
{
@private
  MSMutableArray *_txtsInOids; // refere to one in _oids
  MSMutableArray *_txtsMore;   // may refer or not to one in _oids (not in previous array)
  MSMutableArray *_oids;
}
+ (id)uid;
+ (id)uidWithUid:(uid)u;
- (id)initWithUid:(uid)u;
- (BOOL)containsVid:(vid)v;
- (id)oids;
- (id)otherSystemNames;
- (MSUid*)resolvedUidForOdb:(MSOdb*)db;
- (NSUInteger)count;
- (NSString*)descriptionInContext:(id)ctx;

- (vid)firstVid;
- (BOOL)addOidAtFirst:(MSOid*)u;
- (BOOL)moveOidAtFirst:(MSOid*)u;
- (void)removeFirstVid;
- (void)addUid:(uid)u;
- (void)removeOid:(MSOid*)o;
@end

MSDatabaseExport MSOid    *MSEntEntId;    // ent 'ENT'
MSDatabaseExport MSOid    *MSEntCarId;    // ent 'Car'
MSDatabaseExport MSOid    *MSEntTypId;    // ent 'Typ'
MSDatabaseExport MSOid    *MSCarEntityId;         // car 'entity'
MSDatabaseExport MSString *MSCarEntityLib;
MSDatabaseExport MSOid    *MSCarSystemNameId;     // car 'system name'
MSDatabaseExport MSString *MSCarSystemNameLib;
MSDatabaseExport MSOid    *MSCarCharacteristicId; // car 'characteristique'
MSDatabaseExport MSOid    *MSCarTypeId;           // car 'type'
MSDatabaseExport MSString *MSCarTypeLib;
MSDatabaseExport MSOid    *MSCarTableId;          // car 'table'
MSDatabaseExport MSOid    *MSCarPatternId;        // 'pattern'
//MSDatabaseExport MSOid  *MSCarDomainEntityId;   // 'domain entity'
MSDatabaseExport MSOid    *MSCarDomainListId;     // 'domain list'
MSDatabaseExport MSOid    *MSCarCardinalityId;    // car 'cardinality'
MSDatabaseExport MSString *MSCarCardinalityLib;
//MSDatabaseExport MSOid  *MSCarClassNameId;      // car 'class name'
MSDatabaseExport MSOid    *MSCarElementId;        // car 'element'
//MSDatabaseExport MSOid  *MSCarLabelId;          // car 'label'
//MSDatabaseExport MSOid    *MSCarSubobjectId;      // car 'subobject'
MSDatabaseExport MSOid    *MSCarURNId;            // car 'urn'
MSDatabaseExport MSOid    *MSCarLoginId;          // car 'login'
MSDatabaseExport MSOid    *MSCarDateId;           // car 'date'
//MSDatabaseExport MSOid  *MSTypIDId;  // typ 'ID'
//MSDatabaseExport MSOid  *MSTypSIDId; // typ 'SID'
//MSDatabaseExport MSOid  *MSTypSTRId; // typ 'STR'
//MSDatabaseExport MSOid  *MSTypINTId; // typ 'INT'
//MSDatabaseExport MSOid  *MSTypDATId; // typ 'DAT'
//MSDatabaseExport MSOid  *MSTypDTRId; // typ 'DTM'
//MSDatabaseExport MSOid  *MSTypDURId; // typ 'DUR'

MSDatabaseExport MSOid    *MSObiDatabaseId;  // obi 'database'
MSDatabaseExport MSString *MSObiDatabaseLib;
MSDatabaseExport MSOid    *MSCarNextOidId;   // car 'next oid'
MSDatabaseExport MSString *MSCarNextOidLib;

MSDatabaseExport MSString *MSEntParameterLib;
MSDatabaseExport MSString *MSCarLabelLib;
MSDatabaseExport MSString *MSCarURNLib;
MSDatabaseExport MSString *MSCarParameterLib;
MSDatabaseExport MSString *MSCarFirstNameLib;
MSDatabaseExport MSString *MSCarMiddleNameLib;
MSDatabaseExport MSString *MSCarLastNameLib;
MSDatabaseExport MSString *MSCarLoginLib;
MSDatabaseExport MSString *MSCarHashedPasswordLib;
MSDatabaseExport MSString *MSCarResetPasswordLib;
MSDatabaseExport MSString *MSCarPublicKeyLib;
MSDatabaseExport MSString *MSCarPrivateKeyLib;
MSDatabaseExport MSString *MSCarCipheredPrivateKeyLib;
MSDatabaseExport MSString *MSCarStringLib;
MSDatabaseExport MSString *MSCarIntLib;
MSDatabaseExport MSString *MSCarBoolLib;
MSDatabaseExport MSString *MSCarGmtLib;
MSDatabaseExport MSString *MSCarDateLib;
MSDatabaseExport MSString *MSCarDtmLib;
MSDatabaseExport MSString *MSCarDurationLib;

#pragma mark MSDictionary obis description

@protocol MSObiDescriptionPt
- (NSString*)description:(int)level inContext:(id)ctx;
- (NSString*)descriptionInContext:(id)ctx;
@end
@interface MSDictionary (ObisDescription) <MSObiDescriptionPt>
@end

#pragma mark private

MSDatabaseExport NSString *_obiDesc(MSLong level, id ctx,
                          MSUid *todoOrder, MSMutableDictionary *todo);

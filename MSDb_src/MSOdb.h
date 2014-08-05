/* MSOdb.h
 
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

// TODO: Décrire un obi Database avec version, next id attribuable, uuid.

@interface MSOdb : NSObject
{
@public
@private
  MSDBConnection* _db;
  MSDBTransaction *_tr;
  MSArray* _valTables;
  MSMutableDictionary* _entByOid;
  MSMutableDictionary* _sysObiByOid;
  MSMutableDictionary* _sysObiByName;
}

// databaseWithParameters:dict
// Ouvre une connexion à la base spécifiée dans 'dict', qui contient les clés:
//   host:             localhost
//   port:             nil | (NSNumber)8888
//   adaptor,dbtype:   mysql | oracle
//   socket:           /Applications/MAMP/tmp/mysql/mysql.sock
//   database:         Spaf-Prod-11
//   user,username:    root
//   pwd,password:     root
// Retourne nil si la connexion a échouée.
// La connexion est fermée lors du dealloc.
+ (id)databaseWithParameters:(MSDictionary*)dict;
- (id)initWithParameters:(MSDictionary*)dict;

- (MSObi*)systemObiWithOid:(MSOid*)x;
- (MSObi*)systemObiWithName:(NSString*)name;
- (MSObi*)systemObiWithVid:(vid)vid;
- (MSDictionary*)systemEntsByOid;
- (MSDictionary*)systemObisByOid;
- (MSArray*)systemNames;

// newOidValue:nb
// The next oid long value enabled for the db. All the next nb value are
// considered as consumed.
- (MSLong)newOidValue:(MSLong)nb;

// oidsWithCars:cars
// Retourne les id des obis qui vérifient tous les car-i de cars.
// cars=dict(car1=>val1, car2=>val2...) cari est un oid, un obi ou un libellé
// Si val-i est une valeur, la car-i doit prendre cette valeur.
// Si val-i est un array vide, on demande juste l'existance d'une valeur.
// si l'array est non vide, la car-i doit être l'une des valeurs de l'array (IN)
// Ex:
// SELECT VAL_INST FROM TJ_VAL_STR WHERE
//   ((VAL_CAR=1 AND VAL="ecb")AND(VAL_CAR=2 AND VAL IN("qs","eee")))
// TODO: oidsWithCars:(MSDictionary*)cars timestamp:t
// REM: Parce que l'interclassement de TJ_VAL_STR:VAL est utf8_general_ci,
// les recherches sur les strings sont insensibles à la case.
// TODO: RAJOUTER UN ARGUMENT STRICT COMPARAISON.
// TODO: RAJOUTER LA RECHERCHE SUR UN INTERVAL.
- (MSUid*)oidsWithCars:(MSDictionary*)cars;

// fillIds:ids withCars:cars
// ids et cars sont des uid.
// Retourne les ids remplis avec les cars.
// Si cars est nil, remplit toutes les cars des instances.
// La car 'entity' est toujours remplie même si elle n'est pas demandée.
- (MSMutableDictionary*)fillIds:(uid)ids withCars:(uid)cars;

- (BOOL)changeObi:(MSObi*)x;
- (BOOL)changeObis:(MSDictionary*)x;

- (BOOL)beginTransaction;
- (BOOL)endTransactionSuccessfully:(BOOL)commit;

- (MSMutableDictionary*)decodeObis:(MSString*)x root:(MSObi**)pRoot;

// Redirected on _db
- (NSString*)escapeString:(NSString*)aString withQuotes:(BOOL)withQuotes;

@end

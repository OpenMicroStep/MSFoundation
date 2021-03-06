/* MSOdb.m

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

#import "MSDatabase_Private.h"

@implementation MSOdb

+ (void)initialize
{
  if ([self class] == [MSOdb class]) {
    [MSOid class];}
}

#pragma mark Alloc

+ (id)databaseWithParameters:(MSDictionary*)dict
  {
  return [[[self alloc] initWithParameters:dict] autorelease];
  }

- (id)initWithParameters:(MSDictionary*)dict
  {
  // Ouverture de la connexion.
  BOOL connected= NO; id db;
  if ((db= [MSDBConnection connectionWithDictionary:dict])) {
    _db= RETAIN(db);
    connected= [_db connect];}
//NSLog(@"connected: %d error: %lu",connected,[_db lastError]);
  if (connected) {
    id ts,te,t;
    _valTables= (id)[[MSArray alloc] mutableInit];
    ts= [_db tableNames];
    for (te=[ts objectEnumerator]; (t= [te nextObject]); ) {
      if ([t rangeOfString:@"TJ_VAL_"].location!=NSNotFound) {
        [(id)_valTables addObject:[t substringFromIndex:7]];}}
//NSLog(@"_valTables %@",_valTables);
//NSLog(@"database %@",dict);
    }
  else RELEAZEN(self);
  return self;
  }

- (void)dealloc
  {
  // Fermeture de la connexion.
  [_tr           release]; // abort la transaction si en cours
  [_db disconnect];
  [_db           release];
  [_valTables    release];
  [_entByOid     release];
  [_sysObiByOid  release];
  [_sysObiByName release];
  [super dealloc];
  }

- (NSString*)description
{
  return [MSString stringWithFormat:@"[MSOdb:%p]", self];
}

- (NSString*)escapeString:(NSString*)aString withQuotes:(BOOL)withQuotes
  {
  return [_db escapeString:aString withQuotes:withQuotes];
  }

#pragma mark Private

// - (NSString*)_inValues:(id)u
// retourne nil ou '="v"' ou ' IN("v1","v2")' (or not quoted)
// If u is a dict, we take the keys.
// If u is an MSUid we take the oids, not the otherSystemNames.
// Values of u needs to respond to sqlDescription:
- (NSString*)_inValues:(id)u
  {
  NSMutableString *r;
  NSUInteger n,rn; id ae, v; BOOL dict,first;
  if ((n= [u count])==0) r= nil; // @"" ? recherche de l'existance
//  r= [NSMutableString stringWithFormat:@"=%@", [self _escape:@""]];
  else if (n==1) r= [NSMutableString stringWithString:@"="];
  else           r= [NSMutableString stringWithString:@" IN("];
  if ([u respondsToSelector:@selector(dictionaryEnumerator)]) {
    ae= [u dictionaryEnumerator]; dict= YES;}
  else {
    ae= [([u isKindOfClass:[MSUid class]]?[u oids]:u) objectEnumerator]; dict= NO;}
  for (rn= n, first= YES; (v= (dict?[ae nextKey]:[ae nextObject]));) { // first= NO
    id desc= [(MSOValue*)v sqlDescription:self];
    //if (![desc length]) desc= [_db escapeString:@"" withQuotes:YES];
    //[r appendFormat:@"%@%@",(first?@"":@","),desc];
//NSLog(@"_inValues '%@' '%@' %lu",v,desc,[desc length]);
    if ([desc length]) {
      [r appendFormat:@"%@%@",(first?@"":@","),desc];
      if (first) first= NO;}
    else rn--;}
  if (n>1) [r appendString:@")"];
  if (rn!=n && rn==0) r= nil;
  // Erreur si rn!=n ? u= ["a", "", "c"]
  return r;
  }

#pragma mark Private _table4Cid

- (MSOid*)_vid2oid:(vid)x
  {
  MSOid* r; id o;
  if (!x) r= nil;
  else if ([x respondsToSelector:@selector(oid)]) r= [x oid];
  else if ([x isKindOfClass:[NSString class]]) {
    r= ((o= [self systemObiWithName:x]) ? [o oid] :
        (o= [self systemObiWithOid:[MSOid oidWithLongLongValue:[x longLongValue]]]) ? [o oid] :
        nil);}
  else if ([x isKindOfClass:[NSNumber class]]) {
    r= (o= [self systemObiWithOid:[MSOid oidWithLongLongValue:[x longLongValue]]]) ? [o oid] :
       nil;}
  else r= nil;
  return r;
  }
static __inline__ MSDictionary *_mutableDict(id* d, BOOL* new)
  {
  if (!*new) {*d= [MSDictionary mutableDictionaryWithDictionary:*d]; *new= YES;}
  return *d;
  }

//- (MSDictionary*)_idsDict:(MSDictionary*)d
// d: dict vid-> values
// Une même car ne doit pas apparaître plusieurs fois, par exemple par son
// oid et par son libellé. Sinon, une seule condition persiste.
// TODO: Union des valeurs ?
// Retourne : cid -> null || vals (tj un array même si au départ une seule valeur)
// Si null(= [NSNull null]) on recherchera, PARMI les oids trouvés sans cette cid, ceux qui
// n'ont pas de valeurs pour cette cid.
// vals peut être un array vide dans le cas où l'on accepte toutes les valeurs
// pour cette car. Cela permet de sélectionner les instances qui ont une
// valeur pour une car donnée (NomSystème par exemple).
// Et si une car n'existe pas ? on retourne nil car quand on cherche via
// oidsWithCars, TOUTES les cars doivent être égales (login, pwd)
- (MSDictionary*)_idsDict:(MSDictionary*)d
  {
  BOOL new,newO,unknownKey; id de,k,nk, o;
  if (!d) return nil;
  new= NO; unknownKey= NO;
  de= [d dictionaryEnumerator];
  while ((k= [de nextKey])) {
//NSLog(@"1 %@",k);
    nk= [self _vid2oid:k];
//NSLog(@"2 %@",nk);
    o= [de currentObject]; newO= NO;
    if (!ISEQUAL([NSNull null], o) &&
        ![o isKindOfClass:[NSArray class]] &&
        ![o isKindOfClass:[MSUid class]]) {
      o= ISEQUAL(@"", o)?[MSArray array]:[MSArray arrayWithObject:o]; newO= YES;}
    if (!nk) unknownKey= YES;
    else if (newO || !ISEQUAL(k,nk)) {
      [_mutableDict(&d, &new) setObject:o forKey:nk];
      // On remove après car o n'est a priori retenu que par le dico
      if (!ISEQUAL(k,nk)) [_mutableDict(&d, &new) removeObjectForKey:k];}}
  return [d count]==0 || unknownKey ? nil : d;
  }

- (NSString*)_table4Cid:(MSOid*)cid
  {
  return [[self systemObiWithOid:cid] carTable];
  }

//- (MSDictionary*)_tabledCars:(id)cars
// cars: uid ou array de cid ou dict vid-> value(s).
// Une même car ne doit pas apparaître plusieurs fois, par exemple par son
// oid et par son libellé. Sinon, une seule car ou car-> value(s) persiste.
// Retourne : tbl -> cids ou tbl -> cids -> values (tj array)
// (pour les seules tables nécessaires)
// TODO: Et si une car n'existe pas ? retourner nil car quand on cherche via
// oidsWithCars, TOUTES les cars doivent être égales (login, pwd)
- (MSDictionary*)_tabledCars:(id)cars
  {
  BOOL isDict; MSDictionary *search; id ce, cid, t, o;
  isDict= [cars respondsToSelector:@selector(dictionaryEnumerator)];
  search= [MSDictionary mutableDictionary];
  if (isDict) {cars= [self _idsDict:cars ]; ce= [cars dictionaryEnumerator];}
  else        {cars= [[[MSUid uidWithUid:cars] resolvedUidForOdb:self] oids]; ce= [cars objectEnumerator];}
  while ((cid= (isDict?[ce nextKey]:[ce nextObject]))) {
    if ((t= [self _table4Cid:cid])) {
      if (!(o= [search objectForKey:t])) {
        o= isDict ? [MSDictionary mutableDictionary] : [MSUid uid];
        [search setObject:o forKey:t];}
      if (!isDict) [o addUid:cid];
      else [(MSDictionary*)o setObject:[ce currentObject] forKey:cid];}}
  return [search count]==0 ? nil : search;
  }
#pragma mark Private Query

// On lève toutes les instances potentielles et on intersecte ensuite.
// On ne dit pas que les valeurs sont valides au temps t.
- (MSOid*)_oidsWithTabledCars:(MSDictionary*)tcars
  {
  MSDictionary *search,*nullCids;
  id ids,q,te,t, cs,ce,cid,vs,vsStr, oi,oc,ocs,ie, x;
  MSULong nc; MSLong i,c; MSDBResultSet *result;
  if (![tcars count]) return nil;
  search= [MSDictionary mutableDictionary];
  nullCids= [MSDictionary mutableDictionary];
  te= [tcars dictionaryEnumerator];
  nc= 0;
//NSLog(@"Q1 %@",tcars);
  while ((t= [te nextKey])) {
    q= nil;
    cs=  [te currentObject];
    nc+= [cs count];
    ce=  [cs dictionaryEnumerator];
    // on recherche tous les VAL_INST de TJ_VAL_.$table vérifiant car-i in val-i(s)
    while ((cid= [ce nextKey])) {
      if (ISEQUAL([NSNull null], (vs= [ce currentObject]))) {
        nc--;
        if (!(x= [nullCids objectForKey:t])) [nullCids setObject:(x= [MSUid uid]) forKey:t];
        [x addUid:cid];}
      else {
        if (!q) q= [NSMutableString stringWithFormat:
          @"SELECT VAL_INST,VAL_CAR FROM TJ_VAL_%@ WHERE ",t];
        else [q appendString:@"OR"];
        [q appendFormat:@"(VAL_CAR=%@",cid];
//NSLog(@"Q4 %@ %@ %lu",vs,[vs class],(unsigned long)[vs count]);
        if (![vs count] || !(vsStr= [self _inValues:vs])) [q appendString:@")"];
        else [q appendFormat:@" AND VAL%@)",vsStr];}}
//NSLog(@"Q5 %@",q);
    result= [_db fetchWithRequest:q];
    while ([result nextRow]) {
      [result getLongAt:&i column:0]; oi= [MSOid oidWithLongLongValue:i];
      [result getLongAt:&c column:1]; oc= [MSOid oidWithLongLongValue:c];
      if (!(ocs= [search objectForKey:oi]))
        [search setObject:[NSMutableArray arrayWithObject:oc] forKey:oi];
      else if (![ocs containsObject:oc])
        [ocs addObject:oc];}
    [result terminateOperation];}
  ids= [MSUid uid];
  for (ie= [search dictionaryEnumerator]; (oi= [ie nextKey]);) {
    if ([[search objectForKey:oi] count]==nc) [ids addUid:oi];}
  if ([nullCids count]) {
//NSLog(@"Q7 %@",ids);
    for (te= [nullCids dictionaryEnumerator]; [ids count] && (t= [te nextKey]);) {
      q= [NSMutableString stringWithFormat:
        @"SELECT VAL_INST FROM TJ_VAL_%@ WHERE (VAL_INST%@) AND (VAL_CAR%@)",
        t,[self _inValues:ids],[self _inValues:[te currentObject]]];
//NSLog(@"Q8 %@",q);
      result= [_db fetchWithRequest:q];
      while ([result nextRow]) {
        [result getLongAt:&i column:0]; oi= [MSOid oidWithLongLongValue:i];
        [ids removeOid:oi];}}
//NSLog(@"Q9 %@",ids);
    }
//NSLog(@"Q10 %@",ids);
  return ids;
  }

#pragma mark Private build system obis

- (void)_buildSystemObis
  {
  id cars,tcars,ids,os,de,oid,o,n,ctx;
  cars= [MSDictionary dictionaryWithKey:MSCarSystemNameId andObject:[MSArray array]];
  tcars= [MSDictionary dictionaryWithKey:@"STR" andObject:cars];
  ids= [self _oidsWithTabledCars:tcars];
  if (!(os= [self _fillIds:ids withCars:nil returnAll:YES])) os= [MSDictionary mutableDictionary];
  ASSIGN(_sysObiByOid, os);
  ASSIGN(_entByOid, [MSDictionary mutableDictionary]);
  ASSIGN(_sysObiByName, [MSDictionary mutableDictionary]);
  for (de= [os dictionaryEnumerator]; (oid= [de nextKey]);) {
    o= [de currentObject];
    n= [o stringValueForCid:MSCarSystemNameId];
    if (n) [_sysObiByName setObject:o forKey:n];
    // else NSLog(@"bad sys obi %@ %@",oid,o);
/*
    if (ISEQUAL([o oidValueForCid:MSCarEntityId],MSEntEntId))
      [_entByOid setObject:o forKey:oid];
*/
    }
ctx= [MSDictionary dictionaryWithObjectsAndKeys:self,MSContextOdb,
[NSNumber numberWithBool:YES],MSContextSystemNames,
[NSNumber numberWithBool:YES],MSContextCompleteness,
nil];
//NSLog(@"_buildSystemObis _sysObiByOid: %lu",[_sysObiByOid count]);
//NSLog(@"_sysObiByOid: %@",[_sysObiByOid descriptionInContext:ctx]);
//NSLog(@"_sysObiByName: %@",_sysObiByName);
//o= [MSDictionary dictionaryWithObjectsAndKeys:self,@"Odb",nil];
//NSLog(@"_buid: %@",[ids descriptionInContext:o]);
ctx= nil;
  }
- (BOOL)_addSystemObi:(MSObi*)o withName:(NSString*)n
{
  BOOL ret= NO; MSOid *oid;
  if (!_sysObiByOid) [self _buildSystemObis];
  oid= [o oid];
  if (!n) n= [o stringValueForCid:MSCarSystemNameId];
  if (oid && ![_sysObiByOid  objectForKey:oid] &&
      n   && ![_sysObiByName objectForKey:n  ]) {
    [_sysObiByOid  setObject:o forKey:oid];
    [_sysObiByName setObject:o forKey:n  ];
//NSLog(@"_addSystemObi %@ %@",n,[_sysObiByOid  objectForKey:oid]);
    ret= YES;}
  return ret;
}
- (MSObi*)systemObiWithOid:(MSOid*)x
  {
  if (!_sysObiByOid) [self _buildSystemObis];
  return !x?nil:[_sysObiByOid objectForKey:x];
  }
- (MSObi*)systemObiWithName:(NSString*)name
  {
  if (!_sysObiByName) [self _buildSystemObis];
  return !name?nil:[_sysObiByName objectForKey:name];
  }
- (MSObi*)systemObiWithVid:(vid)vid
  {
  if (!_sysObiByOid) [self _buildSystemObis];
  vid= [self _vid2oid:vid];
  return !vid?nil:[_sysObiByOid objectForKey:vid];
  }
- (MSDictionary*)systemEntsByOid
  {
  if (!_entByOid) [self _buildSystemObis];
  return _entByOid;
  }
- (MSDictionary*)systemObisByOid
  {
  if (!_sysObiByOid) [self _buildSystemObis];
  return _sysObiByOid;
  }
- (MSArray*)systemNames
  {
  if (!_sysObiByOid) [self _buildSystemObis];
  return [_sysObiByName allKeys];
  }

- (MSLong)newOidLongLongValue:(MSLong)nb
{
  static MSLong freeOidv= 500001;
  MSLong r= 0; MSObi *car,*db; _btypedValue tv; MSOValue *v; BOOL ok, unsetTr;
  if (nb<=0) return 0;
  car= [self systemObiWithOid:MSCarNextOidId];
  db= [self systemObiWithOid:MSObiDatabaseId];
  if ((ok= (car && db))) {
    // TODO: test si la transaction échoue next oid n'est pas enregistré.
    //       Est-on sûr que les no n'ont pas été retenus ?
    //       Alternative: autoincrémemt, vérrou ?
    // On va chercher en base pour avoir le dernier.
    // BEGIN TRANSACTION
    if (_tr) unsetTr= NO;
    else {unsetTr= YES; _tr= [[_db openTransaction] retain];}
    db= [[self fillIds:MSObiDatabaseId withCars:nil] objectForKey:MSObiDatabaseId];
    //next oid: old oid + nb
    v= [db valueForCid:[car oid]];
    r= [v longLongValue];
//NSLog(@"db2 r %lld freeOidv %lld %@",r,freeOidv,db);
    if (r<freeOidv) r= freeOidv;
    [v setState:MSRemove];
    tv.s= r+nb;
    v= [MSOValue valueWithCid:[car oid] state:MSAdd type:S8 value:tv];
    [db setValue:v];
    ok= [self changeObi:db].ok;
//NSLog(@"db3 ret change %lld %lld %d",r,tv.s,ok);
    // END TRANSACTION
    if (unsetTr) {
      if (ok) ok= [_tr saveWithError:NULL];
      else [_tr terminateOperation];
      RELEAZEN(_tr);}}
  return ok ? r : 0;
}

#pragma mark Query

- (MSOid*)oidsWithCars:(MSDictionary*)cars
  {
  return [self _oidsWithTabledCars:[self _tabledCars:cars]];
  }

#pragma mark Fill


static inline MSByte _valueTypeFromTable(id table)
{
  return [table isEqualToString:@"ID" ] ? B8 :
         [table isEqualToString:@"INT"] ? S8 :
         [table isEqualToString:@"FLT"] ? R8 :
         [table isEqualToString:@"STR"] ? T8 : 0x00;
}
// - (MSUid*)_fillAllIds:(MSDictionary*)all :inVals :table :inCids4Table
// TODO: table -> type pour redescendre les types au niveau des values
// Ex:
// SELECT VAL_INST,VAL_CAR,VAL FROM TJ_VAL_STR WHERE
//   VAL_INST IN(1,2)[ AND VAL_CAR IN(1,2)]
// all est l'ensemble des instances.
// En retour l'ensembles des nouveaux id (qui sont des valeurs de
// caractéristiques recherchées et qui ne sont pas encore dans all).
// inVals est la string de l'ensemble des id des instances recherchées.
// table est la table des caractéristiques recherchées.
// inCids4Table est nil ou la string des caractéristiques à lever sous la forme
// IN(car_id1,car_id2).
// La ou les valeurs de chaque caractéristique pour chaque id sont toujours
// stockées dans le tableau $all[$id][$car_id]['_val'].
// TODO: timestamp: VAL_INST,VAL_CAR,VAL_TMP,VAL
// TODO: comment je change un obi de classe ? Quand je connais la classe,
// je fais un [class obiWithObi ?]
- (MSUid*)_fillAllIds:(mutable MSDictionary*)all :inVals :table :inCids4Table
  {
  id ret,q,result,inst,oid,cid,val,o; MSLong bid;
  BOOL tIsId,tIsInt,tIsFlt,tIsStr; _btypedValue tv; MSByte type;
  tIsId=  [table isEqualToString:@"ID"];
  tIsInt= [table isEqualToString:@"INT"];
  tIsFlt= [table isEqualToString:@"FLT"];
  tIsStr= [table isEqualToString:@"STR"];
  type= _valueTypeFromTable(table);
  ret= tIsId ? [MSUid uid] : nil;
  if (type) {
    q= FMT(@"SELECT VAL_INST,VAL_CAR,VAL FROM TJ_VAL_%@ WHERE VAL_INST%@%@%@",
       table,inVals,(inCids4Table?@" AND VAL_CAR":@""),
       (inCids4Table?inCids4Table:@""));
//NSLog(@"All %@",[all allKeys]);
//NSLog(@"Q %@",q);
    result= [_db fetchWithRequest:q];
    while ([result nextRow]) {
      [result getLongAt:&bid column:0];
      oid= [MSOid oidWithLongLongValue:bid];
      inst= [all objectForKey:oid];
//NSLog(@"X %@",inst);
      [result getLongAt:&bid  column:1];
      cid= [MSOid oidWithLongLongValue:bid];
//NSLog(@"Y %@",cid);
      if      (tIsInt) [result getLongAt:  &(tv.s) column:2];
      else if (tIsFlt) [result getDoubleAt:&(tv.r) column:2];
      else if (tIsStr) {
        tv.t= [MSString new]; // retained
        //BOOL r=
        [result getStringAt:(tv.t) column:2];
//NSLog(@"S %@",tv.t);
        }
      else if (tIsId) {
        MSLong b;
        [result getLongAt:&b column:2];
        tv.b= [[MSOid alloc] initWithLongLongValue:b];} // retained
//NSLog(@"X0 %@",tv.t);
      val= [MSOValue valueWithCid:cid state:MSUnchanged type:type value:tv];
//NSLog(@"X1 %@.%@.%@   %@",oid,cid,val,inst);
      [inst setValue:val];
//NSLog(@"X2 %@.%@.%@   %@",oid,cid,val,inst);
      if (tIsId) {
        if (!(o= [all objectForKey:tv.b])) {
          [all setObject:(o= [MSObi obiWithOid:tv.b :self]) forKey:tv.b];
          [ret addUid:tv.b];}
        [val setSub:o];
        }}
//NSLog(@"Z %@",ret);
    [result terminateOperation];}
  return ret;
  }

- (mutable MSDictionary*)_fillIds:(uid)ids withCars:(uid)cars returnAll:(BOOL)returnAll
{
  MSDictionary *ret,*all,*tcids; MSUid *is,*is2;
  id o,ie,i,inIds,ts,te,t,cids4t,inCids4t;
  if (ids && ![ids isKindOfClass:[MSUid class]]) ids= [MSUid uidWithUid:ids];
  if (![ids count]) return nil;
  ret= [MSDictionary mutableDictionary];
  all= [MSDictionary mutableDictionary];
  is= [ids resolvedUidForOdb:self];
  for (ie= [[is oids] objectEnumerator]; (i= [ie nextObject]);) {
    [ret setObject:(o= [MSObi obiWithOid:i :self]) forKey:i];
    [all setObject:o forKey:i];}
//NSLog(@"3 %lu %@",[all count],[all objectForKey:[MSOid oidWithLongLongValue:1310]]);
//id de;
//for (de=[all dictionaryEnumerator]; (i=[de nextKey]);) NSLog(@"%@ %@",i,[de currentObject]);
  tcids= [self _tabledCars:cars];
  if (!tcids) { // on recherche toutes les cars
    tcids= [MSDictionary mutableDictionary];
    ts= _valTables;
    for (te= [ts objectEnumerator]; (t= [te nextObject]); ) {
      [tcids setObject:[MSArray array] forKey:t];}}
  // Sinon on veut au moins 'entity' et TODO: 'version' et 'class name' s'il existe
  else if (!(cids4t= [tcids objectForKey:(t= @"ID")])) {
    [tcids setObject:[MSUid uidWithUid:MSCarEntityId] forKey:t];}
  else if (![cids4t containsVid:MSCarEntityId]) {
    [cids4t addUid:MSCarEntityId];}
  // Si au moins une car prend ses valeurs dans 'ID' on commence par
  // rechercher récursivement tous les ids.
  if ((cids4t= [tcids objectForKey:(t= @"ID")])) {
    inCids4t= [self _inValues:cids4t];
    is2= [MSUid uidWithUid:is];
    while ([is2 count]) {
//NSLog(@"4 %@",is2);
      inIds= [self _inValues:is2];
      is2= [self _fillAllIds:all :inIds :t :inCids4t];}}
  inIds= [self _inValues:all];
  for (te= [tcids dictionaryEnumerator]; (t= [te nextKey]);) {
    if (![t isEqualToString:@"ID"]) {
      cids4t= [te currentObject];
      inCids4t= [self _inValues:cids4t];
//NSLog(@"6 %@",t);
      [self _fillAllIds:all :inIds :t :inCids4t];}}
//NSLog(@"8 %@",all);
//NSLog(@"9 %@",ret);
  return returnAll ? all : ret;
}

- (MSDictionary*)fillIds:(uid)ids withCars:(uid)cars
{
  return [self _fillIds:ids withCars:cars returnAll:NO];
}
- (MSDictionary*)allFilledIds:(uid)ids withCars:(uid)cars
{
  return [self _fillIds:ids withCars:cars returnAll:YES];
}

- (boolerr)changeObi:(MSObi*)obi
{
  return [self changeObis:[MSDictionary dictionaryWithKeysAndObjects:
      [obi oid], obi, nil]];
}
// TODO: revoir executeRawSQL
// TODO: transaction et faire un roolback si echec
// TODO: pas execute mais appendSQL
// TODO: traiter la destruction des subobjects automatiquement
// Pour Add et Remove, on vérifie d'abord que l'entité existe et n'est pas disabled.
// On fait les Remove avant les Add au cas où on ferait un Add et Remove de la même valeur.
// Les deletes à la fin pour vérifier qu'on n'a plus de lien externe sur la grappe
// (l'objet et ses sous-objets).
// Enfin, on vérifie les uniques. Et les one ?
- (boolerr)changeObis:(MSDictionary*)x
// Faire les remove en dernier en ajoutant les sid remplacés ou retirés
  {
  NSString *err= nil; id de,obi,q,result,e,t,cid,vs,ve,tStr; MSOValue *v; NSUInteger n;
  MSOid *oid; MSByte status; MSLong bid,oidv; BOOL unsetTr,sys,done,creat; MSInt r;
  sys= NO;
  // BEGIN TRANSACTION
  if (_tr) unsetTr= NO;
  else {unsetTr= YES; _tr= [[_db openTransaction] retain];}
  if (_tr==nil) err= @"ouverture de la transaction impossible";
  else for (de= [x dictionaryEnumerator]; !err && (oid= [de nextKey]);) {
    obi= [de currentObject];
//NSLog(@"CHANGE %@",obi);
//NSLog(@"CHANGE %@",[self systemObiWithOid:[MSOid oidWithLongLongValue:103]]);
    done= NO;
    if ((status= [(MSObi*)obi status])==MSDelete) {
      // Vérif suppression
      // Il ne doit être lié à aucun autre obi et ses sous-objets également
      // TODO: on doit aussi vérifier que ceux auxquels il est lié ne sont pas
      // dans x et marqué à détruire.
      // TODO: On fait les delete à la fin, ie après les remove et add
      q= FMT(@"SELECT VAL_INST FROM TJ_VAL_ID WHERE VAL=%@ OR VAL_CAR=%@",oid,oid);
      result= [_db fetchWithRequest:q];
      if ([result nextRow]) {
        [result getLongAt:&bid column:0];
//NSLog(@"SUPPR NON AUTORISÉE (%lld lié à) %@",bid,oid);
        err= FMT(@"suppression non autorisée (%lld lié à) %@",bid,oid);}
      [result terminateOperation];
      // TODO: Supprimer aussi tous les sous-objets de type SID
      for (e= [_valTables objectEnumerator]; !err && (t= [e nextObject]); ) {
        q= FMT(@"DELETE FROM TJ_VAL_%@ WHERE VAL_INST=%@",t,oid);
        if ((r= [_db executeRawSQL:q])==0) done= YES;
        else err= FMT(@"suppression impossible; erreur: %d; requête:%@",r,q);
//NSLog(@"DELETE %d %@",ok,q);
        }}
    else {
      // TODO: Si pas creat pour Add et Remove, l'objet doit exister et ne pas être disabled
      // TODO: Si un remove n'existe pas, c'est une erreur, c'est que la car a été changée entre temps par quelqu'un d'autre.
      creat= NO;
      if ((oidv= [oid longLongValue])<0) {
        oidv= [self newOidLongLongValue:1]; creat= YES;}
      e= [[obi allValuesByCid] dictionaryEnumerator];
      while (!err && (cid= [e nextKey])) {
        if (ISEQUAL(cid, MSCarSystemNameId)) sys= YES;
        vs= [e currentObject];
        tStr= [self _table4Cid:cid];
//NSLog(@"CID %@ %@ %@",[cid class],cid,tStr);
        for (ve= [vs objectEnumerator]; !err && (v= [ve nextObject]);) {
          if ([v state]==MSRemove) {
            q= FMT(@"DELETE FROM TJ_VAL_%@ WHERE VAL_INST=%lld "
                   @"AND VAL_CAR=%@ AND VAL=%@",
                   tStr,oidv,cid,[v sqlDescription:self]);
            if ((r= [_db executeRawSQL:q])==0) done= YES;
            else err= FMT(@"retrait de la valeur impossible; erreur: %d; requête:%@",r,q);
//NSLog(@"REMOVE %d %@",ok,q);
            }}
        for (ve= [vs objectEnumerator]; !err && (v= [ve nextObject]);) {
          if ([v state]==MSAdd) {
            q= FMT(@"INSERT INTO TJ_VAL_%@ (VAL_INST,VAL_CAR,VAL) VALUES "
                   @"(%lld,%@,%@)",
                   tStr,oidv,cid,[v sqlDescription:self]);
            if ((r= [_db executeRawSQL:q])==0) done= YES;
            else err= FMT(@"ajout de la valeur impossible; erreur: %d; requête:%@",r,q);
//NSLog(@"ADD %d %@",ok,q);
            }}}
      //if (ok && creat) [obi setOid:[MSOid oidWithLongLongValue:oidv]];
      if (!err && creat) [[obi oid] replaceLocalLongLongValue:oidv]; // TODO: que quand tout est ok.
      }
    if (!err && done && [_sysObiByOid objectForKey:x]) sys= YES;}
  // On remove les values MSRemove et les MSAdd passent MSUnchanged.
  if (!err) {
    for (de= [x dictionaryEnumerator]; !err && (oid= [de nextKey]);) {
      if ((status= [(MSObi*)obi status])==MSDelete) {
        // Delete de toutes les values ?
        }
      else {
        e= [[obi allValuesByCid] dictionaryEnumerator];
        while (!err && (cid= [e nextKey])) {
          vs= [e currentObject];
          for (n= [vs count]; n>0; n--) {
            if ([(v= [vs objectAtIndex:n-1]) state]==MSRemove) {
              [vs removeObjectAtIndex:n-1];}
            else if ([v state]==MSAdd) {
              [v setState:MSUnchanged];}}}}}}
  // TODO: Verif des unique (login, urn...)
  // Si un des obis est un obi system on les reload tous
  // TODO: attention on reload même pour next oid !!!
  if (!err && sys) {
    RELEAZEN(_entByOid);
    RELEAZEN(_sysObiByOid);
    RELEAZEN(_sysObiByName);}
  // END TRANSACTION: COMMIT OU ROLLBACK
  if (unsetTr) {
    if (err) [_tr terminateOperation];
    else if (![_tr saveWithError:&r])
      err= FMT(@"commit impossible; erreur: %d", r);
    RELEAZEN(_tr);}
  return RE(err);
  }

- (BOOL)beginTransaction
{
  BOOL ret= NO;
  if (!_tr && (_tr= [[_db openTransaction] retain])) ret= YES;
  return ret;
}
- (BOOL)endTransactionSuccessfully:(BOOL)commit
{
  BOOL ret= YES;
  if (!_tr) ret= NO;
  else if (commit) ret= [_tr saveWithError:NULL];
  else [_tr terminateOperation];
  RELEAZEN(_tr);
  return ret;
}

static inline id _subtrim(id l, NSRange rg) // sub to range and trim
{
  if (rg.location!=NSNotFound) l= [l substringWithRange:rg];
  return [l trim];
}

typedef struct _DecodeStruct {
  id db;
  MSDictionary *all;
  MSDictionary *byName;
  MSDictionary *unresolved;}
_DS;

// _obi(l, db, all, byName)
// On recherche dans all puis dans db et sinon, on le crée
// l est un nombre ou une string.
// Si on crée à partir d'une string, l'obi est créé avec un oid local (négatif)
static inline id _obi(id l, _DS d, BOOL creatFromName)
{
  id obi= nil, oid= nil; unichar u;
  if ([l isKindOfClass:[MSOid class]]) oid= l;
  else if (![l length]) oid= nil;
  else if ((u= [l characterAtIndex:0])==(unichar)'-' || CUnicharIsIsoDigit(u)) {
    oid= [MSOid oidWithLongLongValue:[l longLongValue]];}
  if (oid) {
    obi= [d.all objectForKey:oid];
    if (!obi) {
      obi= [d.db systemObiWithOid:oid];
      if (obi) [d.all setObject:obi forKey:oid];}
    if (!obi) {
      obi= [MSObi obiWithOid:oid :d.db];
      if (obi) [d.all setObject:obi forKey:oid];}}
  else {
    obi= [d.byName objectForKey:l];
    if (!obi) {
      obi= [d.db systemObiWithName:l];
      if (obi) [d.all setObject:obi forKey:[obi oid]];}
    if (!obi && creatFromName) {
      obi= [MSObi obiWithLocalId:d.db];
      if (obi) {
        [d.byName setObject:obi forKey:l];
        [d.all setObject:obi forKey:[obi oid]];}}}
  return obi;
}

// void _addIfNeeded(obi, cid, tableStr, v, o, d)
// Ajoute à obi cid:v sauf si exsite déjà (quand T8 ou B8) TODO: S8 R8
static inline void _addIfNeeded(id obi, id cid, MSByte type, id v)
{
  id vs,val,vo; _btypedValue tv;
  vs= [obi typedValuesForCid:cid];
  vo= nil;
  if      (type==T8) {tv.t= vo= RETAIN( v     );} // retained
  else if (type==B8) {tv.b= vo= RETAIN([v oid]);} // retained
  else if (type==S8) {vo= RETAIN([NSNumber numberWithLongLong:(tv.s= [v longLongValue])]);}
  if (vo && [vs containsObject:vo]) RELEASE(vo);
  else {
//if(type==S8)NSLog(@"cid %@ vo %@ %@ vs %@ %d",cid,[vo class],vo,vs,[vs containsObject:vo]);
    if(type==S8) RELEASE(vo);
    val= [MSOValue valueWithCid:cid state:MSAdd type:type value:tv];
    // TODO: add vobi as val subObject
    [obi setValue:val];
    }
//NSLog(@"===== %@ -> car: %@ value: %@",[obi oid],cid,v);
}
static inline void _addUnresolved(id obi, id car, id v, _DS d)
// in resolved, car is a string or an oid, v is a string or MSObi
{
  id oid; MSDictionary *dict; MSArray *vs;
  if (!(dict= [d.unresolved objectForKey:(oid=[obi oid])])) {
    dict= [MSDictionary mutableDictionary];
    [d.unresolved setObject:dict forKey:oid];}
  if ([car isKindOfClass:[MSObi class]]) car= [car oid];
  if (!(vs= [dict objectForKey:car])) {
    vs= [MSArray mutableArray];
    [dict setObject:vs forKey:car];}
  [vs addObject:v];
}
static inline BOOL _addCarValue(id obi, id car, id v, _DS d, BOOL addToUnresolved)
  {
  BOOL ret= NO; id x,typId,typ,t,cid; MSByte type= 0;
//NSLog(@"----- %@ -> car: %@ value: %@",[obi oid],car,v);
  if ([car isKindOfClass:[NSString class]] && !(car=_obi((x= car), d, NO))) {
    if (addToUnresolved) {_addUnresolved(obi, x, v, d); addToUnresolved= NO;}}
  t= nil;
  // on recherche t: le type de la car (peut-être inconnu)
  if (car && (typId= [car oidValueForCid:MSCarTypeId])) {
    typ= [d.all objectForKey:typId];
    if (!typ) {
      typ= [d.db systemObiWithOid:typId];
      if (typ) [d.all setObject:typ forKey:typId];}
    t= [typ typTable];}
  type= t?_valueTypeFromTable(t):0x00;
  cid= [car oid];
  if (car && !type) {
    if      ([v isKindOfClass:[MSObi class]]) type= B8;
    else if (ISEQUAL(cid,MSCarTableId))       type= T8;
    else if (ISEQUAL(cid,MSCarTypeId ))       type= B8;
    else if (ISEQUAL(cid,MSCarSystemNameId))  type= T8;
    else if (ISEQUAL(cid,MSCarEntityId    ))  type= B8;}
  if (type==B8 && [v isKindOfClass:[NSString class]] && !(v= _obi((x= v), d, NO))) {
    if (addToUnresolved) {_addUnresolved(obi, car, x, d); addToUnresolved= NO;}}
  if (type && v) {
    _addIfNeeded(obi,cid,type,v);
    ret= YES;}
  else if (addToUnresolved) _addUnresolved(obi, car, v, d);
  return ret;
  }
// Constant used: MSCarEntityId MSCarSystemNameId MSCarTypeId MSCarTableId
static id _readObiCidValue(MSString *x, NSUInteger *plineBeg, NSUInteger xEnd,
  _DS d, BOOL one, BOOL *pok)
{
  id obiEntityValue, obi, l,c,car,v,o; BOOL cis_id, subOk;
  NSUInteger lineBeg,nextLineBeg, lineEnd; NSRange rg;
  NSUInteger state;
  obi= obiEntityValue= nil;
  for (state= 1, lineBeg= *plineBeg; (state==1 || (!one && state==2)) && lineBeg<xEnd;) {
    [x getLineStart:&lineBeg end:&nextLineBeg contentsEnd:&lineEnd
       forRange:NSMakeRange(lineBeg,1)];
    l= [x substringWithRange:NSMakeRange(lineBeg, lineEnd-lineBeg)];
    lineBeg= nextLineBeg;
    rg= [l rangeOfString:@"//"];
    l= _subtrim(l, (rg.location==NSNotFound?rg:NSMakeRange(0,rg.location)));
    if ([l length]) {
//NSLog(@"-%@-",l);
      if (state==2) { // Nouvel objet
        state= 1; obi= obiEntityValue= nil;}
      rg= [l rangeOfString:@":"];
      // Lecture de l'entité
      if (!rg.length) { // pas de ':', c'est l'entité d'un nouvel objet
        obiEntityValue= l;}
      // Lecture des cars
      else {
        c= _subtrim(l, NSMakeRange(0,rg.location));
        cis_id= ISEQUAL(c,@"_id");
        if (ISEQUAL(c,@"_end")) state= 2; // this is the end
        else if (!obi && !obiEntityValue) state= 0;
        // en fait on pourrait accepter !obiEntityValue mais alors il faudrait
        // la rechercher à partir de upC
        else if (obi && cis_id) state= 0; // _id ne peut être que la 1ère car
        else { // car: value
          v= _subtrim(l, NSMakeRange(NSMaxRange(rg),[l length]-NSMaxRange(rg)));
          if (!obi) {
            obi= _obi((cis_id?v:nil),d,NO);
            if (!obi) state= 0;
            else if (obiEntityValue) {
              car= _obi(MSCarEntityId,d,NO);
              _addCarValue(obi, car, obiEntityValue, d, YES);}}
          if (state==1 && !cis_id) {
            if (!(car= _obi(c,d,NO))) car= c;
            if (!v || ISEQUAL(v,@"")) { // début d'un sous obi
              o= _readObiCidValue(x,&lineBeg,xEnd, d, YES,&subOk);
              if (!subOk || !o) state= 0;
              else _addCarValue(obi, car, o, d, YES);}
            // Enfin, la car normale
            else {
              _addCarValue(obi, car, v, d, YES);
              // Attention cette car doit être la deuxième après _id
              // Car pas de sous-objet si jamais on doit échanger (cf. ci-après).
              // Si un obi systeme est redéfinit, il doit aussi redéfinir son
              // _id et celui-ci doit être identique.
              // TODO: Si _id local (ie champs _id non redéfinit), échanger
              // l'obi avec l'obi système ?
              // Ex: ENT / _id: xxx / system name : Car ...
              // TODO: Si _id non local et non identique, => conflit.
              // On enregistre dans byName et si déjà connu, on échange l'obi
              // avec celui de byName.
              if (([car isKindOfClass:[MSObi class]] && ISEQUAL([car oid],MSCarSystemNameId)) ||
                  ISEQUAL(c,MSCarSystemNameLib)) {
                id knownObi= [d.byName objectForKey:v];
if(knownObi)NSLog(@"%@ -%@-",(!knownObi?@"Ajouté":knownObi==obi?@"Déjà connu":@"Remplacé"),v);
                if (!knownObi) {
                  [d.byName setObject:obi forKey:v];
                  [d.db _addSystemObi:obi withName:v];}
                else if (knownObi!=obi) {
                  // On est obligé de prendre le knownObi car il est peut-être
                  // déjà utilisé par ailleurs. Néanmoins, si ![[obi oid] isLocal]
                  // mais [[knownObi oid] isLocal], il faut changer la valeur de
                  // l'oid de knownObi par celle de obi.
                  if ([[knownObi oid] isLocal] && ![[obi oid] isLocal])
                    [[knownObi oid] replaceLocalLongLongValue:[[obi oid] longLongValue]];
                  obi= knownObi;
                  }}}}}}}}
  *plineBeg= lineBeg;
  *pok= (state==2);
  return obi;
}
// decodeObis:x
// Référence locale négative ou référence externe system name ou #id ?
// Retourne tous les obis décodés, le dernier étant le root.
- (MSDictionary*)decodeObis:(MSString*)x root:(MSObi**)pRoot
{
  id ret= nil;
  id db= self;
//db= nil;
  MSDictionary *all,*byName,*unresolved; _DS d;
  BOOL ok,fd; NSUInteger lineBeg,xEnd; id obi;
  id ctx= [MSDictionary dictionaryWithObjectsAndKeys:db,MSContextOdb,
    [NSNumber numberWithBool:YES],MSContextSystemNames,
    [NSNumber numberWithBool:YES],MSContextCompleteness,
    //[NSNumber numberWithBool:YES],@"Strict",
    //[NSNumber numberWithBool:YES],@"Small" ,
    nil];
  all= [MSDictionary new];
  byName= [MSDictionary new];
  unresolved= [MSDictionary new];
  d.db= db; d.all= all; d.byName= byName; d.unresolved= unresolved;
  lineBeg= 0;
  xEnd= [x length];
  obi= _readObiCidValue(x,&lineBeg,xEnd, d, NO,&ok);
  for (fd=YES; fd;) {
    id ks,ke,k,cs,ce,c,o,car,vs; MSDictionary *ocvs; NSUInteger n;
//NSLog(@"unresolved count: %ld",[unresolved count]);
    fd= NO;
    ks= [unresolved allKeys];
    for (ke= [ks objectEnumerator]; (k= [ke nextObject]);) {
      o= [all objectForKey:k];
      ocvs= [unresolved objectForKey:k];
      cs= [ocvs allKeys];
      for (ce= [cs objectEnumerator]; (c= [ce nextObject]);) {
        car= [c isKindOfClass:[NSString class]]?[byName objectForKey:c]:[all objectForKey:c];
        vs= [ocvs objectForKey:c];
        for (n=[vs count]; n>0; n--) {
          if (_addCarValue(o, car, [vs objectAtIndex:n-1], d, NO)) {
            fd= YES;
            [vs removeObjectAtIndex:n-1];}}
        if ([vs count]==0) [ocvs removeObjectForKey:c];}
      if ([ocvs count]==0) [unresolved removeObjectForKey:k];}}
  if (pRoot) *pRoot= obi;
//NSLog(@"A");
//NSLog(@"all:%@",[MSUid uidWithUid:[all allKeys]]);
//NSLog(@"all:%@",[all allObjects]);
//NSLog(@"byName:%@",[byName allKeys]);
  if([unresolved count])NSLog(@"unresolved:%@",unresolved);
  if([all count]) {
    ret= [[all retain] autorelease]; }
  RELEASE(all);
  RELEASE(byName);
  RELEASE(unresolved);
  return ret;
  ctx= nil;
}
@end

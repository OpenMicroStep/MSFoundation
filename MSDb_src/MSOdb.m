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

#import "MSObi_Private.h"

@implementation MSOdb

+ (void)initialize
{
  if ([self class] == [MSOdb class]) {
    }
}

#pragma mark Alloc

+ (id)databaseWithParameters:(MSDictionary*)dict
  {
  return [[[self alloc] initWithParameters:dict] autorelease];
  }

static inline Class _loadClassInBundle(id className, id bundleName, id bundleTop)
{
  Class dbClass= Nil;
  NSBundle * bdl;
  NSString *path= [bundleTop pathForResource:bundleName ofType:@"dbadaptor"];
  if ([path length] && (bdl= [NSBundle bundleWithPath:path]) && [bdl load]) {
    dbClass= NSClassFromString(className);}
  return dbClass;
}
- (id)initWithParameters:(MSDictionary*)dict
  {
  // Ouverture de la connexion.
  BOOL connected=NO;
  Class dbClass=Nil;
  id n, bundleName= @"MSMySQLAdaptor", className= @"MSMySQLConnection";
  n= [dict objectForLazyKeys:@"adaptator", @"dbtype", nil];
  if ([n isEqual:@"mysql"] || [n isEqual:className]) {
    dbClass= NSClassFromString(className);}
  if (!dbClass) {
    NSBundle *bundle= [NSBundle mainBundle];
    dbClass= _loadClassInBundle(className, bundleName, bundle);}
  if (!dbClass) {
    NSEnumerator *fe= [[NSBundle allFrameworks] objectEnumerator];
    NSBundle *framework;
    while (!dbClass && (framework= [fe nextObject])) {
      dbClass= _loadClassInBundle(className, bundleName, framework);}}
//NSLog(@"adaptator: %@ class: %@",n,dbClass);
  if (dbClass) {
    _db= [ALLOC(dbClass) initWithConnectionDictionary:dict];
    connected= [_db connect];}
//NSLog(@"connected: %d error: %lu",connected,[_db lastError]);
  if (connected) {
    id ts,te,t;
    _valTables= (id)[[MSMutableArray alloc] init];
    ts= [_db tableNames];
    for (te=[ts objectEnumerator]; (t= [te nextObject]); ) {
      if ([t rangeOfString:@"TJ_VAL_"].location!=NSNotFound) {
        [(id)_valTables addObject:[t substringFromIndex:7]];}}
NSLog(@"_valTables %@",_valTables);
    }
  else RELEAZEN(self);
  return self;
  }

- (void)dealloc
  {
  // Fermeture de la connexion.
  [_db disconnect];
  [_valTables    release];
  [_entByOid     release];
  [_sysObiByOid  release];
  [_sysObiByName release];
  [super dealloc];
  }

- (NSString*)description
{
  CString *s;
  s= MSSCreate(NULL);
  CStringAppendEncodedFormat(s, NSUTF8StringEncoding, "[MSOdb:%p]", self);
  return (id)s;
}

#pragma mark Private

- (NSString*)_escape:(id)s // quoted:(BOOL)quoted
  {
  return [_db escapeString:[s description] withQuotes:YES];
  }

- (NSString*)_inValues:(id)u quoted:(BOOL)quoted
  // retourne nil ou '="v"' ou ' IN("v1","v2")' (or not quoted)
  // If u is a dict, we take the keys.
  {
  NSMutableString *r;
  NSUInteger n; id ae, v; BOOL dict,first;
  if ((n= [u count])==0) r= nil; // @"" ? recherche de l'existance
//  r= [NSMutableString stringWithFormat:@"=%@", [self _escape:@""]];
  else if (n==1) r= [NSMutableString stringWithString:@"="];
  else           r= [NSMutableString stringWithString:@" IN("];
  if ([u respondsToSelector:@selector(dictionaryEnumerator)]) {
    ae= [u dictionaryEnumerator]; dict= YES;}
  else {
    ae= [([u isKindOfClass:[MSUid class]]?[u oids]:u) objectEnumerator]; dict= NO;}
  for (first= YES; (v= (dict?[ae nextKey]:[ae nextObject])); first= NO) {
    [r appendFormat:@"%@%@",(first?@"":@","),(quoted?[self _escape:v]:v)];}
  if (n>1) [r appendString:@")"];
  return r;
  }

#pragma mark Private _table4Cid

- (MSOid*)_vid2oid:(vid)x
  {
  oid r; id o;
  if (!x) r= nil;
  else if ([x respondsToSelector:@selector(oid)]) r= [x oid];
  else if ([x isKindOfClass:[NSString class]]) {
    r= ((o= [self systemObiWithName:x]) ? [o oid] :
        (o= [self systemObiWithOid:[MSOid oidWithLongValue:[x intValue]]]) ? [o oid] :
        nil);}
  else if ([x isKindOfClass:[NSNumber class]]) r= [MSOid oidWithLongValue:[(NSNumber*)x longValue]];
  else r= nil;
  return r;
  }
static __inline__ MSMutableDictionary *_mutableDict(id* d, BOOL* new)
  {
  if (!*new) {*d= [MSMutableDictionary dictionaryWithDictionary:*d]; *new= YES;}
  return *d;
  }
- (MSDictionary*)_idsDict:(MSDictionary*)d
  // d: dict car-> values
  // car est un vid.
  // Une même car ne doit pas apparaître plusieurs fois, par exemple par son
  // oid et par son libellé. Sinon, une seule condition persiste.
  // TODO: Union des valeurs ?
  // Retourne : cid -> vals (tj un array même si au départ un seule valeur)
  // vals peut être un array vide dans le cas où l'on accepte toutes les valeurs
  // pour cette car. Cela permet de sélectionner les instances qui ont une
  // valeur pour une car donnée (NomSystème par exemple).
  // Et si une car n'existe pas ? on retourne nil car quand on cherche via
  // oidsWithCars, TOUTES les cars doivent être égales (login, pwd)
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
    if (![o isKindOfClass:[NSArray class]]) {
      o= [MSArray arrayWithObject:o]; newO= YES;}
    if (!nk) unknownKey= YES;
    else if (newO || nk!=k) {
      [_mutableDict(&d, &new) setObject:o forKey:nk];
      if (nk!=k) [_mutableDict(&d, &new) removeObjectForKey:k];}}
  return [d count]==0 || unknownKey ? nil : d;
  }

- (NSString*)_table4Cid:(oid)cid
  {
  id typId,typ,t;
  typId= [[self systemObiWithOid:cid] oidValueForCid:MSCarTypeId];
  typ= [self systemObiWithOid:typId];
  if (!(t= [typ stringValueForCid:MSCarTableId]))
    t= [typ stringValueForCid:MSCarSystemNameId];
  return t;
  }
- (MSMutableDictionary*)_tabledCars:(id)cars
  // cars: uid ou dict car-> value(s) où car est un uuid.
  // Une même car ne doit pas apparaître plusieurs fois, par exemple par son
  // oid et par son libellé. Sinon, une seule car ou car-> value(s) persiste.
  // Retourne : tbl -> cids ou tbl -> cids -> values (tj array)
  // (pour les seules tables nécessaires)
  // TODO: Et si une car n'existe pas ? retourner nil car quand on cherche via oidsWithCars, TOUTES les cars doivent être égales (login, pwd)
  {
  BOOL isDict; MSMutableDictionary *search; id ce, cid, t, o;
  isDict= [cars respondsToSelector:@selector(dictionaryEnumerator)];
  search= [MSMutableDictionary dictionary];
  if (isDict) {cars= [self _idsDict:cars ]; ce= [cars dictionaryEnumerator];}
  else        {cars= [[[MSUid uidWithUid:cars] resolvedUidForOdb:self] oids]; ce= [cars objectEnumerator];}
  while ((cid= (isDict?[ce nextKey]:[ce nextObject]))) {
    if ((t= [self _table4Cid:cid])) {
      if (!(o= [search objectForKey:t])) {
        o= isDict ? [MSMutableDictionary dictionary] : [MSUid uid];
        [search setObject:o forKey:t];}
      if (isDict) [(MSMutableDictionary*)o setObject:[ce currentObject] forKey:cid];
      else        [o addUid:cid];}}
  return [search count]==0 ? nil : search;
  }
#pragma mark Private Query

// On lève toutes les instances potentielles et on intersecte ensuite.
// On ne dit pas que les valeurs sont valides au temps t.
- (MSOid*)_oidsWithTabledCars:(MSDictionary*)tcars
  {
  MSMutableDictionary *search;
  id ids,q,te,t, cs,ce,cid,vs, oi,oc,ocs,ie;
  BOOL quoted; MSULong nc; MSLong i,c; MSDBResultSet *result;
  if (![tcars count]) return nil;
  ids= nil;
  search= [MSMutableDictionary dictionary];
  te= [tcars dictionaryEnumerator];
  nc= 0;
//NSLog(@"Q1 %@",tcars);
  while ((t= [te nextKey])) {
    quoted= [t isEqual:@"STR"]; // TODO: QUE STR ?
    q= nil;
    cs=  [te currentObject];
    nc+= [cs count];
    ce=  [cs dictionaryEnumerator];
    // on recherche tous les VAL_INST de TJ_VAL_.$table vérifiant car-i in val-i(s)
    while ((cid= [ce nextKey])) {
      if (!q) q= [NSMutableString stringWithFormat:
        @"SELECT VAL_INST,VAL_CAR FROM TJ_VAL_%@ WHERE ",t];
      else [q appendString:@"OR"];
      [q appendFormat:@"(VAL_CAR=%@",cid];
      vs= [ce currentObject];
      if (![vs count]) [q appendString:@")"];
      else [q appendFormat:@" AND VAL%@)",[self _inValues:vs quoted:quoted]];}
//NSLog(@"Q5 %@",q);
    result= [_db fetchWithRequest:q];
    while ([result nextRow]) {
      [result getLongAt:&i column:0]; oi= [MSOid oidWithLongValue:i];
      [result getLongAt:&c column:1]; oc= [MSOid oidWithLongValue:c];
      if (!(ocs= [search objectForKey:oi]))
        [search setObject:[NSMutableArray arrayWithObject:oc] forKey:oi];
      else if (![ocs containsObject:oc])
        [ocs addObject:oc];}
    [result terminateOperation];}
  ids= [MSUid uid];
  for (ie= [search dictionaryEnumerator]; (oi= [ie nextKey]);) {
    if ([[search objectForKey:oi] count]==nc) [ids addUid:oi];}
//NSLog(@"Q9 %@",ids);
  return ids;
  }

#pragma mark Private build system obis

- (void)_buildSystemObis
  {
  id cars,tcars,ids,os,de,oid,o,n;
  cars= [MSDictionary dictionaryWithKey:MSCarSystemNameId andObject:[MSArray array]];
  tcars= [MSDictionary dictionaryWithKey:@"STR" andObject:cars];
  ids= [self _oidsWithTabledCars:tcars];
  os= [self fillIds:ids withCars:nil];
  ASSIGN(_sysObiByOid, os);
  ASSIGN(_entByOid, [NSMutableDictionary dictionary]);
  ASSIGN(_sysObiByName, [NSMutableDictionary dictionary]);
  for (de= [os dictionaryEnumerator]; (oid= [de nextKey]);) {
    o= [de currentObject];
    n= [o stringValueForCid:MSCarSystemNameId];
    if (n) [_sysObiByName setObject:o forKey:n];
    else NSLog(@"bad sys obi %@ %@",oid,o);
/*
    if (ISEQUAL([o oidValueForCid:MSCarEntityId],MSEntEntId))
      [_entByOid setObject:o forKey:oid];
*/
    }
//NSLog(@"_buildSystemObis _sysObiByOid: %lu",[_sysObiByOid count]);
//NSLog(@"_sysObiByOid:  %@",_sysObiByOid);
//NSLog(@"_sysObiByName: %@",_sysObiByName);
//o= [MSDictionary dictionaryWithObjectsAndKeys:self,@"Odb",nil];
//NSLog(@"_buid: %@",[ids descriptionInContext:o]);
  }
- (MSObi*)systemObiWithOid:(oid)x
  {
  if (!_sysObiByOid) [self _buildSystemObis];
  return !x?nil:[_sysObiByOid objectForKey:x];
  }
- (MSObi*)systemObiWithName:(NSString*)name
  {
  if (!_sysObiByName) [self _buildSystemObis];
  return !name?nil:[_sysObiByName objectForKey:name];
  }
- (NSDictionary*)systemEntsByOid
  {
  if (!_entByOid) [self _buildSystemObis];
  return _entByOid;
  }
- (NSDictionary*)systemObisByOid
  {
  if (!_sysObiByOid) [self _buildSystemObis];
  return _sysObiByOid;
  }

- (MSLong)newOidLongValue:(MSLong)nb
{
  static MSLong oidv= 5000000;
  MSLong r;
  if (nb<=0) return 0;
  r= oidv;
  oidv+= nb;
  return r;
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
// TODO: table -> type pour redescendre les types au niveau des values
- (MSUid*)_fillAllIds:(MSMutableDictionary*)all :inVals :table :inCids4Table
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
      oid= [MSOid oidWithLongValue:bid];
      inst= [all objectForKey:oid];
//NSLog(@"X %@",inst);
      [result getLongAt:&bid  column:1];
      cid= [MSOid oidWithLongValue:bid];
//NSLog(@"Y %@",cid);
      if      (tIsInt) [result getLongAt:  &(tv.s) column:2];
      else if (tIsFlt) [result getDoubleAt:&(tv.r) column:2];
      else if (tIsStr) {
        tv.t= [MSString new]; // retained
        //BOOL r=
        [result getStringAt:(CString*)(tv.t) column:2];
//NSLog(@"S %@",tv.t);
        }
      else if (tIsId) {
        MSLong b;
        [result getLongAt:&b column:2];
        tv.b= [[MSOid alloc] initWithLongValue:b];} // retained
//NSLog(@"X0 %@",tv.t);
      val= [MSOValue valueWithCid:cid state:MSUnchanged type:type
        timestamp:0 value:tv];
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

- (MSMutableDictionary*)fillIds:(uid)ids withCars:(uid)cars
{
  MSMutableDictionary *ret,*all,*tcids; MSUid *is,*is2;
  id o,ie,i,inIds,ts,te,t,cids4t,inCids4t;
  if (ids && ![ids isKindOfClass:[MSUid class]]) ids= [MSUid uidWithUid:ids];
  if (![ids count]) return nil;
  ret= [MSMutableDictionary dictionary];
  all= [MSMutableDictionary dictionary];
  is= [ids resolvedUidForOdb:self];
//NSLog(@"2 %@",is);
  for (ie= [[is oids] objectEnumerator]; (i= [ie nextObject]);) {
    [ret setObject:(o= [MSObi obiWithOid:i :self]) forKey:i];
    [all setObject:o forKey:i];}
//NSLog(@"3 %lu %@",[all count],[all objectForKey:[MSOid oidWithLongValue:1310]]);
//id de;
//for (de=[all dictionaryEnumerator]; (i=[de nextKey]);) NSLog(@"%@ %@",i,[de currentObject]);
  tcids= [self _tabledCars:cars];
  if (!tcids) { // on recherche toutes les cars
    tcids= [MSMutableDictionary dictionary];
    ts= _valTables;
    for (te= [ts objectEnumerator]; (t= [te nextObject]); ) {
      [tcids setObject:[MSArray array] forKey:t];}}
  // Sinon on veut au moins 'entity' et TODO: 'version' et 'class name' s'il existe
  else if (!(cids4t= [tcids objectForKey:(t= @"ID")])) {
    [tcids setObject:[MSArray arrayWithObject:MSCarEntityId] forKey:t];}
  else if (![cids4t containsObject:MSCarEntityId]) {
    [cids4t addObject:MSCarEntityId];}
  // Si au moins une car prend ses valeurs dans 'ID' on commence par
  // rechercher récursivement tous les ids.
  if ((cids4t= [tcids objectForKey:(t= @"ID")])) {
    inCids4t= [self _inValues:cids4t quoted:NO];
    is2= [MSUid uidWithUid:is];
    while ([is2 count]) {
//NSLog(@"4 %@",is2);
      inIds= [self _inValues:is2 quoted:NO];
      is2= [self _fillAllIds:all :inIds :t :inCids4t];}}
  inIds= [self _inValues:all quoted:NO];
  for (te= [tcids dictionaryEnumerator]; (t= [te nextKey]);) {
    if (![t isEqualToString:@"ID"]) {
      cids4t= [te currentObject];
      inCids4t= [self _inValues:cids4t quoted:NO];
//NSLog(@"6 %@",t);
      [self _fillAllIds:all :inIds :t :inCids4t];}}
//NSLog(@"8 %@",all);
//NSLog(@"9 %@",ret);
  return ret;
}

// TODO: revoir executeRawSQL
// TODO: faire un roolback si echec
// TODO: traiter les sub sid automatiquement
- (BOOL)changeObis:(MSDictionary*)x
  {
  id de,obi,q,result,e,t,cid,vs,ve,v,tStr;
  MSOid *oid; MSByte status; MSLong bid,oidv; BOOL ok,sys,done,creat,quoted;
  sys= NO;
  // BEGIN TRANSACTION
  for (ok= YES, de= [x dictionaryEnumerator]; ok && (oid= [de nextKey]);) {
    obi= [de currentObject];
    done= NO;
    status= [(MSObi*)obi status];
    if (status==MSDelete) {
      // Vérif suppression
      // Il ne doit être lié à aucun autre obi
      // TODO: on pourrait aussi vérifier que ceux auxquels il est lié ne sont pas
      // dans x et marqué à détruire.
      q= FMT(@"SELECT VAL_INST FROM TJ_VAL_ID WHERE VAL=%@ OR VAL_CAR=%@",oid,oid);
      result= [_db fetchWithRequest:q];
      if ([result nextRow]) {
        [result getLongAt:&bid column:0];
NSLog(@"SUPPR NON AUTORISÉE (lié à %lld) %@",bid,obi);
        ok= NO;}
      [result terminateOperation];
      // TODO: Supprimer aussi tous les sous-objets de type SID
      for (e= [_valTables objectEnumerator]; ok && (t= [e nextObject]); ) {
        q= FMT(@"DELETE FROM TJ_VAL_%@ WHERE VAL_INST=%@",t,oid);
        if ([_db executeRawSQL:[q UTF8String]]) ok= NO; else done= YES;
NSLog(@"%d %@",ok,q);
        }
      }
    else {
      creat= NO;
      if ((oidv= [oid longValue])<0) {
        oidv= [self newOidLongValue:1]; creat= YES;}
      e= [[obi allValuesByCid] dictionaryEnumerator];
      while (ok && (cid= [e nextKey])) {
        if (ISEQUAL(cid, MSCarSystemNameId)) sys= YES;
        vs= [e currentObject];
        tStr= [self _table4Cid:cid];
        quoted= [tStr isEqual:@"STR"];
        for (ve= [vs objectEnumerator]; ok && (v= [ve nextObject]);) {
          if ([v state]==MSRemove) {
            if (quoted) v= [self _escape:v];
            q= FMT(@"DELETE FROM TJ_VAL_%@ WHERE VAL_INST=%lld "
                    "AND VAL_CAR=%@ AND VAL=%@",t,oidv,cid,[v typedValue]);
            if ([_db executeRawSQL:[q UTF8String]]) ok= NO; else done= YES;}}
        for (ve= [vs objectEnumerator]; ok && (v= [ve nextObject]);) {
          if ([v state]==MSAdd) {
            if (quoted) v= [self _escape:v];
            q= FMT(@"INSERT INTO TJ_VAL_%@ WHERE VAL_INST=%lld "
                    "AND VAL_CAR=%@ AND VAL=%@",t,oidv,cid,[v typedValue]);
            if ([_db executeRawSQL:[q UTF8String]]) ok= NO; else done= YES;}}}
      if (ok && creat) [obi setOid:[MSOid oidWithLongValue:oidv]];}
    if (ok && done && [_sysObiByOid objectForKey:x]) sys= YES;}
  // Si un des obis est un obi system on les reload tous
  if (ok && sys) {
    RELEAZEN(_entByOid);
    RELEAZEN(_sysObiByOid);
    RELEAZEN(_sysObiByName);}
  // COMMIT OU ROLLBACK
  return ok;
  }

static inline id _subtrim(id l, NSRange rg)
{
  if (rg.location!=NSNotFound) l= [l substringWithRange:rg];
  return [l stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
static inline id _obi(id l, id db, MSMutableDictionary *all, MSMutableDictionary *byName)
{
  id obi= nil, oid;
  if (![l length]) return  nil;
  if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[l characterAtIndex:0]]) {
    oid= [MSOid oidWithLongValue:[l longLongValue]];
    // On reccherche dans all puis dans db et sinon, on le crée
    obi= [all objectForKey:oid];
    if (!obi) {
      obi= [db systemObiWithOid:oid];
      if (obi) [all setObject:obi forKey:oid];}
    if (!obi) {
      obi= [MSObi obiWithOid:oid :db];
      if (obi) [all setObject:obi forKey:oid];}}
  else {
    obi= [byName objectForKey:l];
    if (!obi) {
      obi= [db systemObiWithName:l];
      if (obi) [all setObject:obi forKey:[obi oid]];}
    if (!obi) {
      obi= [MSObi obiWithLocalId:db];
      if (obi) {
        [byName setObject:obi forKey:l];
        [all setObject:obi forKey:[obi oid]];}}}
  return obi;
}
static inline void _addIfNeeded(id obi, id cid, id tableStr, id v,
  id db, MSMutableDictionary *all, MSMutableDictionary *byName)
{
  id vobi,vs,val,vo; _btypedValue tv; MSByte type;
  type= _valueTypeFromTable(tableStr);
  if (type==B8 && [v isKindOfClass:[NSString class]]) {
    vobi= _obi(v,db,all,byName);
    v= [vobi oid];}
  vs= [obi typedValuesForCid:cid];
  vo= nil;
  if (type==0 || type==T8) {tv.t= vo= RETAIN(v);} // retained
  else if       (type==B8) {tv.b= vo= RETAIN(v);} // retained
//NSLog(@"vs %@ %d",vs,[vs containsObject:vo]);
  if (vo && [vs containsObject:vo]) RELEASE(vo);
  else {
    val= [MSOValue valueWithCid:cid state:MSAdd type:type
      timestamp:0 value:tv];
    [obi setValue:val];
    }
}
- (MSMutableDictionary*)decodeObis:(MSString*)x
{
  id db= nil;
//id db= self;
  MSMutableDictionary *all,*byName; MSMutableArray *obis;
  BOOL ok; NSUInteger lbeg,nlbeg,lend,xend; id l,veObi,c,v,obi,cObi; NSRange rg;
  all= [MSMutableDictionary new];
  byName= [MSMutableDictionary new];
  [byName setObject:@"_id"  forKey:@"_id" ];
  [byName setObject:@"_end" forKey:@"_end"];
  obis= [MSMutableArray new];
  veObi= obi= nil;
  for (ok= YES, xend= [x length], lbeg= 0; ok && lbeg<xend; lbeg= nlbeg) {
    [x getLineStart:&lbeg end:&nlbeg contentsEnd:&lend forRange:NSMakeRange(lbeg,1)];
    l= [x substringWithRange:NSMakeRange(lbeg, lend-lbeg)];
    rg= [l rangeOfString:@"//"];
    l= _subtrim(l, (rg.location==NSNotFound?rg:NSMakeRange(0,rg.location)));
    if ([l length]) {
NSLog(@"-%@-",l);
      rg= [l rangeOfString:@":"];
      if (!rg.length) { // C'est l'entité d'un nouvel objet
        veObi= l;}
      else {
        c= _subtrim(l, NSMakeRange(0,rg.location));
        if (ISEQUAL(c,@"_end")) {
          if ([obis count]) [obis removeLastObject]; else ok= NO;
          obi= [obis count]?[obis objectAtIndex:1]:nil;
          veObi= nil;}
        else if (ISEQUAL(c,@"_id")) {
          v= _subtrim(l, NSMakeRange(NSMaxRange(rg),[l length]-NSMaxRange(rg)));
          obi= _obi(v,db,all,byName);
          if (!obi || !veObi) ok= NO;
          else {
            _addIfNeeded(obi,MSCarEntityId,@"ID",veObi,db,all,byName);}}
        else { // cid: value
          id typId,typ,t;
          cObi= _obi(c,db,all,byName);
          v= _subtrim(l, NSMakeRange(NSMaxRange(rg),[l length]-NSMaxRange(rg)));
          // on recherche t: le type de la car (peut-être inconnu)
          t= 0;
          if ((typId= [cObi oidValueForCid:MSCarTypeId])) {
            typ= [all objectForKey:typId];
            if (!typ) {
              typ= [db systemObiWithOid:typId];
              if (typ) [all setObject:typ forKey:typId];}
            if (typ && !(t= [typ stringValueForCid:MSCarTableId]))
              t= [typ stringValueForCid:MSCarSystemNameId];}
          _addIfNeeded(obi,[cObi oid],t,v,db,all,byName);
          }}}}
NSLog(@"A");
NSLog(@"all:%@",[MSUid uidWithUid:[all allKeys]]);
NSLog(@"all:%@",[all allObjects]);
NSLog(@"byName:%@",[byName allKeys]);
  return [all count]?all:nil;
}
@end

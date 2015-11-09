/* MSOid.m

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

MSOid *MSEntEntId,*MSEntCarId,*MSEntTypId;
MSOid *MSCarEntityId,*MSCarSystemNameId,*MSCarCharacteristicId,*MSCarTypeId,
      *MSCarTableId,*MSCarPatternId,*MSCarDomainEntityId,*MSCarDomainListId,
      *MSCarCardinalityId,*MSCarMandatoryId,*MSCarUniqueId,
      *MSCarElementId,*MSCarLabelId,*MSCarURNId,*MSCarLoginId,*MSCarDateId;
// MSCarSubobjectId
MSOid *MSTypIDId,*MSTypSTRId,*MSTypINTId,
      *MSTypDATId,*MSTypDTRId,*MSTypDURId;
MSOid *MSObiDatabaseId,*MSCarNextOidId;

MSString *MSCarEntityLib,*MSCarSystemNameLib,*MSCarTypeLib,
         *MSCarCardinalityLib,*MSCarMandatoryLib,*MSCarUniqueLib,
         *MSObiDatabaseLib,*MSCarNextOidLib;

MSString *MSEntParameterLib;
MSString *MSCarLabelLib,*MSCarURNLib,*MSCarParameterLib,
         *MSCarFirstNameLib,*MSCarMiddleNameLib,*MSCarLastNameLib,
         *MSCarLoginLib,*MSCarHashedPasswordLib,*MSCarResetPasswordLib,
         *MSCarPublicKeyLib,*MSCarPrivateKeyLib,*MSCarCipheredPrivateKeyLib;
MSString *MSCarStringLib,*MSCarIntLib,*MSCarBoolLib,
         *MSCarGmtLib,*MSCarDateLib,*MSCarDtmLib,*MSCarDurationLib;

@implementation MSOid

+ (void)initialize
{
  if ([self class] == [MSOid class]) {
    MSEntEntId= [[MSOid alloc] initWithLongLongValue:1]; // ent 'ENT'
    MSEntCarId= [[MSOid alloc] initWithLongLongValue:3]; // ent 'Car'
    MSEntTypId= [[MSOid alloc] initWithLongLongValue:5]; // ent 'Typ'
    MSCarEntityId=         [[MSOid alloc] initWithLongLongValue:101]; // car 'entity'
    MSCarEntityLib=        MSCreateString("entity");
    MSCarSystemNameId=     [[MSOid alloc] initWithLongLongValue:102]; // car 'system name'
//  MSCarSystemNameLib=    MSCreateString("nom système");
    MSCarSystemNameLib=    MSCreateString("system name");
    MSCarCharacteristicId= [[MSOid alloc] initWithLongLongValue:103]; // car 'characteristique'
    MSCarTypeId=           [[MSOid alloc] initWithLongLongValue:105]; // car 'type'
    MSCarTypeLib=          MSCreateString("type");
    MSCarTableId=          [[MSOid alloc] initWithLongLongValue:106]; // car 'table'
    MSCarPatternId=        [[MSOid alloc] initWithLongLongValue:107]; // car 'pattern'
//  MSCarDomainEntityId=   [[MSOid alloc] initWithLongLongValue:109]; // car 'domain entity'
    MSCarDomainListId=     [[MSOid alloc] initWithLongLongValue:110]; // car 'domain list'
    MSCarCardinalityId=    [[MSOid alloc] initWithLongLongValue:115]; // car 'cardinality'
    MSCarCardinalityLib=   MSCreateString("cardinality");
    MSCarMandatoryId=      [[MSOid alloc] initWithLongLongValue:243]; // car 'mandatory'
    MSCarMandatoryLib=     MSCreateString("mandatory");
    MSCarUniqueId=         [[MSOid alloc] initWithLongLongValue:245]; // car 'unique'
    MSCarUniqueLib=        MSCreateString("unique");
//  MSCarClassNameId=      [[MSOid alloc] initWithLongLongValue:116]; // car 'class name'
    MSCarElementId=        [[MSOid alloc] initWithLongLongValue:155]; // car 'element'
//  MSCarLabelId=          [[MSOid alloc] initWithLongLongValue:232]; // car 'label'
//  MSCarSubobjectId=      [[MSOid alloc] initWithLongLongValue:247]; // car 'subobject'
    MSCarURNId=            [[MSOid alloc] initWithLongLongValue:301]; // car 'urn'
    MSCarLoginId=          [[MSOid alloc] initWithLongLongValue:321]; // car 'login'
    MSCarDateId=           [[MSOid alloc] initWithLongLongValue:533]; // car 'date'
//  MSTypIDId=  [[MSOid alloc] initWithLongLongValue:2001]; // typ 'ID'
//  MSTypSIDId= [[MSOid alloc] initWithLongLongValue:2003]; // typ 'SID'
//  MSTypSTRId= [[MSOid alloc] initWithLongLongValue:2021]; // typ 'STR'
//  MSTypINTId= [[MSOid alloc] initWithLongLongValue:2041]; // typ 'INT'
//  MSTypDATId= [[MSOid alloc] initWithLongLongValue:2053]; // typ 'DAT'
//  MSTypDTRId= [[MSOid alloc] initWithLongLongValue:2055]; // typ 'DTM'
//  MSTypDURId= [[MSOid alloc] initWithLongLongValue:2057]; // typ 'DUR'
    MSObiDatabaseId=        [[MSOid alloc] initWithLongLongValue:9000]; // 'database'
    MSObiDatabaseLib=       MSCreateString("database");         // lib de l'obi 'database'
    MSCarNextOidId=         [[MSOid alloc] initWithLongLongValue:401];  // car 'next oid'
    MSCarNextOidLib=        MSCreateString("next oid");         // lib de la car 'next oid'

    MSEntParameterLib=          MSCreateString("Parameter");
    MSCarLabelLib=              MSCreateString("label");
    MSCarURNLib=                MSCreateString("urn");
    MSCarParameterLib=          MSCreateString("parameter");
    MSCarFirstNameLib=          MSCreateString("first name");
    MSCarMiddleNameLib=         MSCreateString("middle name");
    MSCarLastNameLib=           MSCreateString("last name");
    MSCarLoginLib=              MSCreateString("login");
    MSCarHashedPasswordLib=     MSCreateString("hashed password");
    MSCarResetPasswordLib=      MSCreateString("must change password");
    MSCarPublicKeyLib=          MSCreateString("public key");
    MSCarPrivateKeyLib=         MSCreateString("private key");
    MSCarCipheredPrivateKeyLib= MSCreateString("ciphered private key");
    MSCarStringLib=             MSCreateString("string");
    MSCarIntLib=                MSCreateString("int");
    MSCarBoolLib=               MSCreateString("bool");
    MSCarGmtLib=                MSCreateString("gmt");
    MSCarDateLib=               MSCreateString("date");
    MSCarDtmLib=                MSCreateString("date & time");
    MSCarDurationLib=           MSCreateString("duration");
    }
}

#pragma mark Class/Init methods

+ (id)oidWithLongLongValue:(MSLong)a
{
  return [[[self alloc] initWithLongLongValue:a] autorelease];
}

- (id)initWithLongLongValue:(MSLong)a
{
  _oid= a;
  return self;
}

#pragma mark Copying

- (id)copyWithZone:(NSZone *)zone
{
  return [self retain];
  zone= NULL; // unused parameter
}

#pragma mark Standard methods

- (BOOL)isEqual:(id)object
{
  if (object == (id)self) return YES;
  if (!object || ![object isKindOfClass:[MSOid class]]) return NO;
  return _oid==((MSOid*)object)->_oid;
}

- (NSComparisonResult)compare:(id)x
  {
  NSComparisonResult ret;
  if (!x) ret= NSOrderedDescending;
  else if ([x isKindOfClass:[MSOid class]]) {
    MSLong xoid= [(MSOid*)x longLongValue];
    ret= (_oid < xoid ? NSOrderedAscending : _oid > xoid ? NSOrderedDescending : NSOrderedSame);}
  else ret= NSOrderedSame; // ???
  return ret;
  }

- (NSUInteger)hash:(unsigned)depth
{
  return (NSUInteger)_oid;
  depth= 0;
}

- (NSString*)description
{
  CString *s= CCreateString(0);
  CStringAppendFormat(s, "%ld", _oid);
  return AUTORELEASE(s);
}
- (NSString*)sqlDescription:(MSOdb*)db
  {
  return [self description];
  db= nil;
  }
- (NSString*)descriptionInContext:(id)ctx
  {
  return [self description];
  ctx= nil;
  }

- (MSOid*)oid
{
  return self;
}

- (MSLong)longLongValue
{
  return _oid;
}

- (BOOL)isLocal
{
  return (_oid<0);
}

- (void)replaceLocalLongLongValue:(MSLong)a
{
  if (_oid<0) _oid= a;
}
@end

@implementation MSUid

+ (void)initialize
{
  if ([self class] == [MSUid class]) {
    }
}

#pragma mark Class/Init methods

+ (id)uid
{
  return [[self alloc] autorelease];
}
+ (id)uidWithUid:(uid)u
{
  return [[[self alloc] initWithUid:u] autorelease];
}

- (id)initWithUid:(uid)u
{
  [self addUid:u];
  return self;
}

- (void)dealloc
  {
  RELEASE(_txtsInOids);
  RELEASE(_txtsMore);
  RELEASE(_oids);
  [super dealloc];
  }

#pragma mark Copying

- (id)copyWithZone:(NSZone *)zone
{
  return [[[self class] alloc] initWithUid:self];
  zone= NULL; // unused parameter
}

#pragma mark Equal

// TODO: Use sortedArray
static inline BOOL _ISEQUALSET(id a, id b)
{
  BOOL ret= NO;
  NSUInteger an,bn,i,j; id ai;
  if (a == b) return YES;
  if (!a || !b) return NO;
  an= [a count]; bn= [b count];
  if (an==bn) {
    for (ret= YES, i= 0; ret && i<an; i++) {
      ai= [a objectAtIndex:i];
      for (ret= NO, j= 0; !ret && j<bn; j++) {
        ret= ISEQUAL(ai, [b objectAtIndex:j]);}}}
  return ret;
}
- (BOOL)isEqual:(id)object
{
  BOOL ret;
  id o= nil;
  if (object == (id)self) return YES;
  if (!object) return NO;
  if (![object isKindOfClass:[MSUid class]]) {
    o= object= [[[self class] alloc] initWithUid:object];}
  ret= _ISEQUALSET([self oids], [object oids]) &&
       _ISEQUALSET([self otherSystemNames], [object otherSystemNames]);
  RELEASE(o);
  return ret;
}

- (NSString*)description
{
  NSMutableString *s; id oe,o; BOOL first;
  s= [NSMutableString string];
  [s appendString:@"["];
  for (first= YES, oe= [_oids objectEnumerator]; (o= [oe nextObject]);) {
    [s appendFormat:@"%@%@",(first?@"":@", "),o];
    if (first) {first= NO;}}
  for (oe= [_txtsMore objectEnumerator]; (o= [oe nextObject]);) {
    [s appendFormat:@"%@%@",(first?@"":@", "),o];
    if (first) {first= NO;}}
  [s appendString:@"]"];
  return s;
}

- (NSString*)description:(int)level inContext:(id)ctx
{
  MSOdb *db; MSUid *ids; id todo; NSString *ret;
  if ([ctx isKindOfClass:[MSOdb class]]) db= ctx;
  else db= [(MSDictionary*)ctx objectForKey:MSContextOdb];
  if (!db) ret= [self description];
  else {
    ids= [self resolvedUidForOdb:db];
    todo= [db fillIds:ids withCars:nil];
    ret= _obiDesc(level, ctx, ids, todo);}
  return ret;
}

- (NSString*)descriptionInContext:(id)ctx
  {
  return [self description:0 inContext:ctx];
  }

#pragma mark methods

static inline BOOL _addAtFirstToArray(id o, id *pArray)
{
  if (!*pArray) *pArray= [[MSArray alloc] mutableInit];
  [*pArray insertObject:o atIndex:0];
  return YES;
}
static inline void _addToArray(id o, id *pArray)
{
  if (!*pArray) *pArray= [[MSArray alloc] mutableInit];
  [*pArray addObject:o];
}
static inline BOOL _addReferedSystemName(id n, id *ptxtsMore, id *ptxtsInOids)
// Retourne YES s'il faut ajouter l'oid correspondant
// Retourne NO si le nom est connu comme se référant déjà à un oid.
{
  BOOL add= YES;
  if ([n length]) {
    if ([*ptxtsMore containsObject:n]) [*ptxtsMore removeObject:n];
    if ([*ptxtsInOids containsObject:n]) add= NO;
    else _addToArray(n, ptxtsInOids);}
  return add;
}
static inline void _addUid(uid o, id self, id *ptxtsMore, id *ptxtsInOids, id *poids)
{
  if ([o isKindOfClass:[MSUid class]] || [o isKindOfClass:[NSArray class]]) {
    [self addUid:o];}
  else if ([o isKindOfClass:[NSString class]]) {
    if ([o length] && ![*ptxtsInOids containsObject:o] && ![*ptxtsMore containsObject:o]) {
      _addToArray(o, ptxtsMore);}}
  else if ([o respondsToSelector:@selector(oid)]) {
    BOOL add= YES; MSOid *oid;
    if ([o respondsToSelector:@selector(systemName)]) {
      add= _addReferedSystemName([o systemName],ptxtsMore,ptxtsInOids);}
    if (add && ![*poids containsObject:(oid= [o oid])]) {
      _addToArray(o, poids);}}
}

- (void)addUid:(uid)u_
{
  id u1,u2,ue,o,n,txtsInOids;
  if (!u_) return;
  u1= u2= nil; txtsInOids= nil;
  if ([u_ isKindOfClass:[MSUid class]]) {
    MSUid *uu= (MSUid*)u_;
    if (!_txtsInOids && !_txtsMore && !_oids) {
      _txtsInOids= [[MSArray alloc] mutableInitWithArray:uu->_txtsInOids];
      _txtsMore=   [[MSArray alloc] mutableInitWithArray:uu->_txtsMore];
      _oids=       [[MSArray alloc] mutableInitWithArray:uu->_oids];}
    else {
      u1= uu->_oids;
      u2= uu->_txtsMore;
      txtsInOids= uu->_txtsInOids;}}
  else if ([u_ isKindOfClass:[NSArray class]]) u1= u_;
  else _addUid(u_, self,&_txtsMore, &_txtsInOids, &_oids);
  for (ue= [u1 objectEnumerator]; (o= [ue nextObject]);) {
    _addUid(o, self,&_txtsMore, &_txtsInOids, &_oids);}
  for (ue= [u2 objectEnumerator]; (o= [ue nextObject]);) {
    _addUid(o, self,&_txtsMore, &_txtsInOids, &_oids);}
  for (ue= [txtsInOids objectEnumerator]; (n= [ue nextObject]);) {
    _addReferedSystemName(n,&_txtsMore,&_txtsInOids);}
}

- (void)removeOid:(MSOid*)o
{
  NSUInteger idx= 0;
  if (o && _oids && (idx= [_oids indexOfObject:o])!=NSNotFound)
   [_oids removeObjectAtIndex:idx];
}

- (id)oids
{
  return _oids;
}
- (NSEnumerator*)oidEnumerator
{
  return [_oids objectEnumerator];
}
- (id)otherSystemNames
{
  return _txtsMore;
}

- (MSUid*)resolvedUidForOdb:(MSOdb*)db
{
  MSUid *ret; id ne,n,oid;
  if (![_txtsMore count]) return self;
  ret= [[self class] uidWithUid:nil];
  ret->_oids=       [[MSArray alloc] mutableInitWithArray:_oids];
  ret->_txtsInOids= [[MSArray alloc] mutableInitWithArray:_txtsInOids];
  for (ne= [_txtsMore objectEnumerator]; (n= [ne nextObject]);) {
    oid= [[db systemObiWithName:n] oid];
    if (oid) {
      if (![ret->_oids containsObject:oid]) _addToArray(oid, &(ret->_oids));
      _addToArray(n, &(ret->_txtsInOids));}}
  return ret;
}

- (NSUInteger)count
{
  return [_oids count]+[_txtsMore count];
}

- (BOOL)containsVid:(vid)v
{
  BOOL fd= NO;
  if ([v isKindOfClass:[NSString class]]) {
    if ([v length] && ([_txtsInOids containsObject:v] || [_txtsMore containsObject:v])) {
      fd= YES;}}
  else if ([v respondsToSelector:@selector(oid)]) {
    fd= [_oids containsObject:[v oid]];}
  return fd;
}

#pragma mark methods for first

- (vid)firstVid
{
  return [_oids     count]?[_oids     objectAtIndex:0]:
         [_txtsMore count]?[_txtsMore objectAtIndex:0]:nil;
}

// TODO: Plutôt setOidAtFirst: combinaison des deux ?

- (BOOL)addOidAtFirst:(MSOid*)u
{
  BOOL ret= NO;
  if (u && !(_oids && [_oids containsObject:u])) {
    ret= _addAtFirstToArray(u, &_oids);}
  return ret;
}

- (BOOL)moveOidAtFirst:(MSOid*)u
{
  BOOL ret= NO; NSUInteger idx= 0;
//NSLog(@"move %@ %@",u,_oids);
  if (u && _oids && (idx= [_oids indexOfObject:u])!=NSNotFound) {
    ret= YES;
    if (idx!=0) {[_oids removeObjectAtIndex:idx]; [_oids insertObject:u atIndex:0];}}
//NSLog(@"move %ld %@",idx,self);
  return ret;
}

- (void)removeFirstVid
{
  if      ([_oids     count]) [_oids     removeObjectAtIndex:0];
  else if ([_txtsMore count]) [_txtsMore removeObjectAtIndex:0];
}

@end

@implementation MSDictionary (ObisDescription)

- (NSString*)description:(int)level inContext:(id)ctx
{
  MSOdb *db; MSUid *ids; id todo; NSString *ret;
  if ([ctx isKindOfClass:[MSOdb class]]) db= ctx;
  else db= [(MSDictionary*)ctx objectForKey:MSContextOdb];
  if (!db) ret= [self description];
  else {
    ids= [MSUid uidWithUid:[self allKeys]];
    todo= [MSDictionary mutableDictionaryWithDictionary:self];
    ret= _obiDesc(level, ctx, ids, todo);}
  return ret;
}

- (NSString*)descriptionInContext:(id)ctx
  {
  return [self description:0 inContext:ctx];
  }

@end

#pragma mark private

#define _cmp(A,B,SAME) \
  ((A) < (B) ? NSOrderedAscending : (A) > (B) ? NSOrderedDescending : (SAME))
static NSComparisonResult _obiOrderCmp(id e1, id e2, void *ctx)
  {
  NSComparisonResult ret= NSOrderedSame; id ae1,ae2,ee1,ee2;
  MSULong e1e,e1u,e2e,e2u;
  ae1= [(MSDictionary*)e1 objectForKey:@"_order"];
  ae2= [(MSDictionary*)e2 objectForKey:@"_order"];
  ee1= [ae1 objectEnumerator];
  ee2= [ae2 objectEnumerator];
  // On passe en MSULong car si <0 alors rangé avec les >10000
  e1e= (MSULong)[(MSOid*)[ee1 nextObject] longLongValue];
  e1u= (MSULong)[(MSOid*)[ee1 nextObject] longLongValue];
  e2e= (MSULong)[(MSOid*)[ee2 nextObject] longLongValue];
  e2u= (MSULong)[(MSOid*)[ee2 nextObject] longLongValue];
  if ((e1u<=10000 && e2u<=10000)||(e1u>10000 && e2u>10000))
    ret= _cmp(e1e, e2e, _cmp(e1u, e2u, NSOrderedSame));
  else ret= _cmp(e1u, e2u, NSOrderedSame);
  return ret;
  ctx= NULL;
  }
static NSComparisonResult _oidOrderCmp(MSOid* oid1, MSOid *oid2, void *ctx)
  {
  MSULong l1,l2;
  l1= (MSULong)[oid1 longLongValue];
  l2= (MSULong)[oid2 longLongValue];
  return _cmp(l1, l2, NSOrderedSame);
  ctx= NULL;
  }

static NSString *_obiRecDesc(MSLong level0, MSLong level,
  BOOL names, BOOL complet, MSOdb *db,
  MSUid *todoOrder,
  mutable MSDictionary *todo, mutable MSDictionary *done)
{
  vid vid; id o,entObi,ent,order,x,e,cids,cid,car,name,values,ve,value,type,oidValue,sub,sobi;
  MSDictionary *dict; MSLong i; BOOL isId,isSid,isCarEnt;
  if (![todoOrder count]) return nil;
  vid= [todoOrder firstVid]; o= RETAIN([todo objectForKey:vid]);
  [todoOrder removeFirstVid];
  [todo removeObjectForKey:vid];
  ent= [o oidValueForCid:MSCarEntityId];
  entObi= [db systemObiWithOid:ent];
  if (YES) { // level==level0 on remplit même quand c'est un sous-objet pour savoir qu'on l'a traité
    dict= [MSDictionary mutableDictionary];
    e= ent ? ent :[MSOid oidWithLongLongValue:0];
    order= [MSArray arrayWithObjects:e,vid, nil];
    [dict setObject:order forKey:@"_order"];
    [done setObject:dict forKey:vid];}
  else dict= nil;
  if (!ent) ent= @"No entity";
  if (names && (name= [entObi systemName])) ent= name;
  x= [NSMutableString string];
  [x appendString:@"\n"];
  for (i= 0; i<level; i++) [x appendString:@"  "];
  [x appendFormat:@"%@\n",ent?ent:@"Unknown entity"];
  for (i= 0; i<level; i++) [x appendString:@"  "];
  [x appendFormat:@"_id: %@\n",vid];
  if ((value= [o systemName])) {
    for (i= 0; i<level; i++) [x appendString:@"  "];
    cid= MSCarSystemNameId;
    if (names) cid= MSCarSystemNameLib;
    [x appendFormat:@"%@: %@\n",cid,value];}
  cids= [[o allValuesByCid] allKeys];
  cids= [cids sortedArrayUsingFunction:_oidOrderCmp context:NULL];
  for (e= [cids objectEnumerator]; (cid= [e nextObject]);) if (!ISEQUAL(cid,MSCarSystemNameId)) {
//NSLog(@"c %@",cid);
    isCarEnt= ISEQUAL(cid,MSCarEntityId);
    car= [db systemObiWithOid:cid];
    type= [car carType];
    isId=   ISEQUAL(type,@"ID");
    isSid=  ISEQUAL(type,@"SID");
  //isSid= [[entObi entPatternOfCid:cid] longLongValueForCid:MSCarSubobjectId]!=0;
    values= [[o allValuesByCid] objectForKey:cid];
    if (names && (name= [car systemName])) cid= name;
    for (ve= [values objectEnumerator]; (value= [ve nextObject]);) {
//NSLog(@"v %@",cid);
      oidValue= isId || isSid ? [value oidValue] : nil;
      if ((sub= isSid ? [value subValue] : nil)) {
        if ([todoOrder containsVid:oidValue]) {
//NSLog(@"..... moved %@",oidValue);
          [todoOrder moveOidAtFirst:oidValue];}
        else { // Il a déjà été fait ou on le voit pour la première fois
//NSLog(@"+++++ add %@",oidValue);
          [todoOrder addOidAtFirst:oidValue];
          [todo setObject:sub forKey:oidValue];}
        value= _obiRecDesc(level0, level+1, names, complet, db, todoOrder, todo, done);
        // Qu'il ait déjà été fait ou non on indique dans done qu'il ne faut pas l'inclure à la fin.
        // Rem: Si on le supprime simplement, il peut être rajouté par un lien externe (par complétude).
        // Rem: on ne peut pas prendre directement celui de done à cause du level (sauf à le ré-indenter).
        [(MSDictionary*)[done objectForKey:oidValue] removeObjectForKey:@"txt"];
//NSLog(@"----- done %@ %@ %@",oidValue,[done objectForKey:oidValue],[done allKeys]);
        }
      else if (complet && oidValue &&
               ![todo objectForKey:oidValue] &&
               ![done objectForKey:oidValue]) {
        if (!(sobi= [db systemObiWithOid:oidValue])) {
NSLog(@"ADDING NOT SYSTEM OBI FOR COMPLETUDE %@",oidValue);
          sobi= [[db fillIds:oidValue withCars:nil] objectForKey:oidValue];}
else NSLog(@"ADDING SYSTEM OBI FOR COMPLETUDE %@ %@",oidValue,[done objectForKey:oidValue]);
        if (sobi) {
          [todo setObject:sobi forKey:oidValue];
          [todoOrder addUid:oidValue];}}
      if (!isCarEnt) { // La car entité a déjà été écrite
        for (i= 0; i<level; i++) [x appendString:@"  "];
        if (!isSid && oidValue && names && (name= [[db systemObiWithOid:oidValue] systemName]))
          value= name;
        [x appendFormat:@"%@: %@\n",cid,value];}
//NSLog(@"%@: %@\n",cid,value);
      }}
  if (level==level0) [dict setObject:x forKey:@"txt"];
  if (level>=level0) {
    for (i= 0; i<level; i++) [x appendString:@"  "];
    [x appendString:@"_end:"];
    if (level==level0) [x appendString:@"\n"];}
//if(level)NSLog(@"%@",vid);
  RELEASE(o);
  return x;
}

NSString *_obiDesc(MSLong level, id ctx, MSUid *todoOrder, mutable MSDictionary *todo)
{
  MSOdb *db; BOOL names,complet;
  id done,x,y,e,ds;
  MSDictionary *dict;
  if ([ctx isKindOfClass:[MSOdb class]]) {db= ctx; names= NO; complet= NO;}
  else {
    db= [(MSDictionary*)ctx objectForKey:MSContextOdb];
    names=   [[(MSDictionary*)ctx objectForKey:MSContextSystemNames ] boolValue];
    complet= [[(MSDictionary*)ctx objectForKey:MSContextCompleteness] boolValue];}

  x= [NSMutableString string];
  [x appendFormat:@"// Description of: %@",[todoOrder description]];
  done= [MSDictionary mutableDictionary];
//level++;
  while ([todoOrder count])
    _obiRecDesc(level, level, names, complet, db, todoOrder, todo, done);
  ds= [(MSDictionary*)done allObjects];
  ds= [ds sortedArrayUsingFunction:_obiOrderCmp context:NULL];
  for (e= [ds objectEnumerator]; (dict= [e nextObject]);) {
    if ((y= [dict objectForKey:@"txt"])) [x appendString:y];}
  return x;
}

#pragma mark NSString sqlDescription

@implementation  NSString (sqlDescription)
- (NSString*)sqlDescription:(MSOdb*)db
{
  return ![self length] ? nil : [db escapeString:self withQuotes:YES];
}
@end

/*
@implementation MSOid (MSTEncoding)
- (MSInt)singleEncodingCode:(MSTEncoder*)encoder
{
  return MSTE_TOKEN_MUST_ENCODE;
  encoder= nil;
}
- (MSByte)tokenType
{
  return MSTE_TOKEN_TYPE_DECIMAL_VALUE;
}
- (MSByte)tokenTypeWithReference:(BOOL)isReferenced
{
  return isReferenced ? [self tokenType] : MSTE_TOKEN_TYPE_INT64;
}
- (void)encodeWithMSTEncoder:(MSTEncoder *)encoder
{
  [encoder encodeLongLong:_oid withTokenType:NO];
}
@end
*/

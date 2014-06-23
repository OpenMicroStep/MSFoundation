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

#import "MSObi_Private.h"

MSOid *MSEntEntId,*MSEntCarId,*MSEntTypId;
MSOid *MSCarEntityId,*MSCarSystemNameId,*MSCarCharacteristicId,*MSCarTypeId,
      *MSCarTableId,*MSCarGabaritId,*MSCarDomaineId,*MSCarDateId,*MSCarLibelleId;
MSOid *MSTypIDId,*MSTypSIDId,*MSTypSTRId,*MSTypINTId,
      *MSTypDATId,*MSTypDTRId,*MSTypDURId;
MSOid *MSObiDatabaseId;

MSString *MSCarSystemNameLib;

@implementation MSOid

+ (void)initialize
{
  if ([self class] == [MSOid class]) {
    MSEntEntId= [[MSOid alloc] initWithLongValue:1]; // id  de l'entité 'ENT'
//  MSEntCarId= [[MSOid alloc] initWithLongValue:3]; // id  de l'entité 'Car'
    MSEntTypId= [[MSOid alloc] initWithLongValue:5]; // id  de l'entité 'Typ'
    MSCarEntityId=         [[MSOid alloc] initWithLongValue:101]; // id  de la car 'entité'
    MSCarSystemNameId=     [[MSOid alloc] initWithLongValue:102]; // id  de la car 'system name'
    MSCarSystemNameLib=    MSCreateString("nom système");         // lib de la car 'system name'
//  MSCarClassNameId=      [[MSOid alloc] initWithLongValue:102]; // id  de la car 'class name'
//  MSCarCharacteristicId= [[MSOid alloc] initWithLongValue:103]; // id  de la car 'caract.'
    MSCarTypeId=           [[MSOid alloc] initWithLongValue:105]; // id  de la car 'type'
    MSCarTableId=          [[MSOid alloc] initWithLongValue:106]; // id  de la car 'table'
//  MSCarGabaritId=        [[MSOid alloc] initWithLongValue:107]; // id  de la car 'gabarit'
//  MSCarDomaineId=        [[MSOid alloc] initWithLongValue:109]; // id  de la car 'domaine'
    MSCarDateId=           [[MSOid alloc] initWithLongValue:135]; // id  de la car 'date'
//  MSCarLibelleId=        [[MSOid alloc] initWithLongValue:232]; // id  de la car 'libellé'
//  MSTypIDId=  [[MSOid alloc] initWithLongValue:1055]; // id  du Type 'ID'
//  MSTypSIDId= [[MSOid alloc] initWithLongValue:1056]; // id  du Type 'SID'
//  MSTypSTRId= [[MSOid alloc] initWithLongValue:1061]; // id  du Type 'STR'
//  MSTypINTId= [[MSOid alloc] initWithLongValue:1062]; // id  du Type 'INT'
//  MSTypDATId= [[MSOid alloc] initWithLongValue:1063]; // id  du Type 'DAT'
//  MSTypDTRId= [[MSOid alloc] initWithLongValue:1064]; // id  du Type 'DTR'
//  MSTypDURId= [[MSOid alloc] initWithLongValue:1065]; // id  du Type 'DUR'
    MSObiDatabaseId=       [[MSOid alloc] initWithLongValue:100000]; // id  de la 'database'
    }
}

#pragma mark Class/Init methods

+ (id)oidWithLongValue:(MSLong)a
{
  return AUTORELEASE([[self alloc] initWithLongValue:a]);
}

- (id)initWithLongValue:(MSLong)a
{
  _oid= a;
  return self;
}

#pragma mark Copying

- (id)copyWithZone:(NSZone *)zone
{
  return RETAIN(self);
  zone= NULL; // unused parameter
}

#pragma mark Standard methods

- (BOOL)isEqual:(id)object
{
  if (object == (id)self) return YES;
  if (!object) return NO;
  if ([object isKindOfClass:[MSOid class]]) {
    return _oid==((MSOid*)object)->_oid;}
  return NO;
}

- (NSComparisonResult)compare:(id)x
  {
  NSComparisonResult ret;
  if (!x) ret= NSOrderedDescending;
  else if ([x isKindOfClass:[MSOid class]]) {
    MSLong xoid= [(MSOid*)x longValue];
    ret= (_oid < xoid ? NSOrderedAscending : _oid > xoid ? NSOrderedDescending : NSOrderedSame);}
  else ret= NSOrderedSame;
  return ret;
  }

- (NSUInteger)hash:(unsigned)depth
{
  return (NSUInteger)_oid;
  depth= 0;
}

- (NSString*)description
{
  MSString *s;
  s= MSCreateString(NULL);
  CStringAppendEncodedFormat((CString*)s, NSUTF8StringEncoding, "%ld", _oid);
  return s;
}
- (NSString*)descriptionForDb:(MSOdb*)db
  {
  return [self description];
  db= nil;
  }

- (MSOid*)oid
{
  return self;
}

- (MSLong)longValue
{
  return _oid;
}

- (BOOL)isLocal
{
  return (_oid<0);
}

- (void)setNonLocalLongValue:(MSLong)a
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
  return AUTORELEASE([self alloc]);
}
+ (id)uidWithUid:(uid)u
{
  return AUTORELEASE([[self alloc] initWithUid:u]);
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
    o= RETAIN(object= [[[self class] alloc] initWithUid:object]);}
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

#pragma mark methods

static inline BOOL _addAtFirstToArray(id o, id *pArray)
{
  if (!*pArray) *pArray= [[MSMutableArray alloc] init];
  [*pArray insertObject:o atIndex:0];
  return YES;
}
static inline void _addToArray(id o, id *pArray)
{
  if (!*pArray) *pArray= [[MSMutableArray alloc] init];
  [*pArray addObject:o];
}
static inline BOOL _addReferedSystemName(id n, id *ptxtsMore, id *ptxtsInOids)
// Retourne YES s'il faut ajouter l'oid correspondant
// Retourne NO si le nom est connu comme se référent déjà à un oid.
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
    BOOL add= YES;
    if ([o respondsToSelector:@selector(systemName)]) {
      add= _addReferedSystemName([o systemName],ptxtsMore,ptxtsInOids);}
    if (add && ![*poids containsObject:o]) {
      _addToArray([o oid], poids);}}
}

- (void)addUid:(uid)u_
{
  id u1,u2,ue,o,n,txtsInOids;
  if (!u_) return;
  u1= u2= nil; txtsInOids= nil;
  if ([u_ isKindOfClass:[MSUid class]]) {
    MSUid *uu= (MSUid*)u_;
    if (!_txtsInOids && !_txtsMore && !_oids) {
      _txtsInOids= COPY(uu->_txtsInOids);
      _txtsMore=   COPY(uu->_txtsMore);
      _oids=       COPY(uu->_oids);}
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

- (id)oids
{
  return _oids;
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
  ret->_oids=       COPY(_oids);
  ret->_txtsInOids= COPY(_txtsInOids);
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
    fd= [_oids containsObject:v];}
  return fd;
}

- (NSString*)description:(int)level inContext:(MSDictionary*)ctx
{
  MSOdb *db; MSUid *ids; id todo;
  db= [ctx objectForKey:@"Odb"];
  ids= [self resolvedUidForOdb:db];
  todo= [db fillIds:ids withCars:nil];
  return _obiDesc(level, ctx, ids, todo);
}

- (NSString*)descriptionInContext:(MSDictionary*)ctx
  {
  return [self description:0 inContext:ctx];
  }

#pragma mark methods for first

- (uid)firstUid
{
  return [_oids     count]?[_oids     objectAtIndex:0]:
         [_txtsMore count]?[_txtsMore objectAtIndex:0]:nil;
}

- (BOOL)addFirstOid:(MSOid*)u
{
  BOOL ret= NO;
  if (u && ![_oids containsObject:u]) {
    ret= _addAtFirstToArray(u, &_oids);}
  return ret;
}

- (void)removeFirstUid
{
  if      ([_oids     count]) [_oids     removeObjectAtIndex:0];
  else if ([_txtsMore count]) [_txtsMore removeObjectAtIndex:0];
}

@end

#pragma mark private

static NSComparisonResult _obiOrderCmp(id e1, id e2, void *ctx)
  {
  NSComparisonResult ret= NSOrderedSame; id ae1,ae2,ee1,ee2,o1,o2;
  ae1= [(MSDictionary*)e1 objectForKey:@"_order"];
  ae2= [(MSDictionary*)e2 objectForKey:@"_order"];
  ee1= [ae1 objectEnumerator]; ee2= [ae2 objectEnumerator]; o1= o2= nil;
  while (ret==NSOrderedSame) {
    if      (!(o1= [ee1 nextObject])) ret= NSOrderedAscending;
    else if (!(o2= [ee2 nextObject])) ret= NSOrderedDescending;
    else ret= [(MSOid*)o1 compare:o2];}
  return ret;
  ctx= NULL;
  }

static NSString *_obiRecDesc(MSLong level0, MSLong level,
  BOOL verbose, BOOL strict, MSOdb *db,
  MSUid *todoOrder,
  MSMutableDictionary *todo, MSMutableDictionary *done)
{
  uid uid; id o,ent,order,x,e,cid,car,name,values,ve,value,typeid,oidValue,sub,sobi;
  MSMutableDictionary *dict; MSLong i; BOOL isId,isSid,isCarEnt;
  if (![todoOrder count]) return nil;
  uid= [todoOrder firstUid]; o= RETAIN([todo objectForKey:uid]);
  [todoOrder removeFirstUid];
  [todo removeObjectForKey:uid];
  ent= [o oidValueForCid:MSCarEntityId];
  if (!ent) ent= @"No entity";
  if (level==level0) {
    dict= [MSMutableDictionary dictionary];
    order= [MSArray arrayWithObjects:ent,uid, nil];
    [dict setObject:order forKey:@"_order"];
    [done setObject:dict forKey:uid];}
  else dict= nil;
  if (verbose && (name= [[db systemObiWithOid:ent] systemName])) ent= name;
  x= [NSMutableString string];
  [x appendString:@"\n"];
  for (i= 0; i<level; i++) [x appendString:@"  "];
  [x appendFormat:@"%@\n",ent?ent:@"Unknown entity"];
  for (i= 0; i<level; i++) [x appendString:@"  "];
  [x appendFormat:@"_id: %@\n",uid];
  for (e= [[o allValuesByCid] dictionaryEnumerator]; (cid= [e nextKey]);) {
//NSLog(@"c %@",cid);
    isCarEnt= ISEQUAL(cid,MSCarEntityId);
    car= [db systemObiWithOid:cid];
    typeid= [car oidValueForCid:MSCarTypeId];
    isId=  ISEQUAL([[db systemObiWithOid:typeid] systemName],@"ID");
    isSid= ISEQUAL([[db systemObiWithOid:typeid] systemName],@"SID");
    if (verbose && (name= [car systemName])) cid= name;
    values= [e currentObject];
    for (ve= [values objectEnumerator]; (value= [ve nextObject]);) {
//NSLog(@"v %@",cid);
    oidValue= isId || isSid ? [value oidValue] : nil;
      sub= isSid ? [value subValue] : nil;
      if (sub) {
        if ([todoOrder addFirstOid:oidValue]) {
          [todo setObject:sub forKey:oidValue];
          value= _obiRecDesc(level0, level+1, verbose, strict, db, todoOrder, todo, done);}
        else {
          sub= nil;
          }}
      else if (!strict && oidValue &&
          ![todo objectForKey:oidValue] &&
          ![done objectForKey:oidValue] &&
           (sobi= [db systemObiWithOid:oidValue])) {
        [todo setObject:sobi forKey:oidValue];
        [todoOrder addUid:oidValue];}
      if (!isCarEnt) {
        for (i= 0; i<level; i++) [x appendString:@"  "];
        if (oidValue && verbose && (name= [[db systemObiWithOid:oidValue] systemName]))
          value= name;
        [x appendFormat:@"%@: %@\n",cid,value];}
//NSLog(@"%@: %@\n",cid,value);
      }}
  [dict setObject:x forKey:@"txt"];
  if (level>=level0) {
    for (i= 0; i<level; i++) [x appendString:@"  "];
    [x appendString:@"_end:"];
    if (level==level0) [x appendString:@"\n"];}
//NSLog(@"%@",x);
  RELEASE(o);
  return x;
}

NSString *_obiDesc(MSLong level, MSDictionary *ctx,
  MSUid *todoOrder, MSMutableDictionary *todo)
{
  MSOdb *db; BOOL verbose,strict;
  id done,x,e,ds;
  MSDictionary *dict;
  db=       [ctx objectForKey:@"Odb"];
  verbose= ![[ctx objectForKey:@"Small" ] boolValue];
  strict=   [[ctx objectForKey:@"Strict"] boolValue];
  
  x= [NSMutableString string];
  [x appendFormat:@"// Description of: %@",[todoOrder description]];
  done= [MSMutableDictionary dictionary];
//level++;
  while ([todoOrder count])
    _obiRecDesc(level, level, verbose, strict, db, todoOrder, todo, done);
  ds= [(MSDictionary*)done allObjects];
  ds= [ds sortedArrayUsingFunction:_obiOrderCmp context:NULL];
  for (e= [ds objectEnumerator]; (dict= [e nextObject]);) {
    [x appendString:[dict objectForKey:@"txt"]];}
  return x;
}

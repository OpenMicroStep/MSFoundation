/* MSObi.m
 
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

static BOOL _btypedValuesEquals(a, b, type)
  _btypedValue a, b; MSByte type;
  {
  BOOL ret= NO;
  if      (type==S8) ret= a.s==b.s;
  else if (type==R8) ret= a.r==b.r;
  else if (type==T8) ret= (a.t==b.t) ? YES : (!a.t || !b.t) ? NO : [a.t isEqualToString:b.t];
  else if (type==B8) ret= ISEQUAL(a.b,b.b);
  return ret;
  }
#define _cmp(A,B,SAME) \
  ((A) < (B) ? NSOrderedAscending : (A) > (B) ? NSOrderedDescending : (SAME))
static NSComparisonResult _btypedValuesCompare(a, b, type)
  _btypedValue a, b; MSByte type;
  {
  NSComparisonResult ret= NSOrderedSame;
  if      (type==S8) ret= _cmp(a.s,b.s,NSOrderedSame);
  else if (type==R8) ret= _cmp(a.r,b.r,NSOrderedSame);
  else if (type==T8) ret= (a.t==b.t) ? NSOrderedSame : !a.t ? NSOrderedAscending :
                          !b.t ? NSOrderedDescending : [a.t compare:b.t];
  else if (type==B8) ret= _cmp([a.b longLongValue],[b.b longLongValue],NSOrderedSame);
  return ret;
  }

@implementation MSOValue : NSObject
+ (id)valueWithCid:(MSOid*)cid state:(MSByte)state type:(MSByte)type
  value:(_btypedValue)v
  {
  return AUTORELEASE([ALLOC(self) initWithCid:cid state:state type:type
    timestamp:MSLongMin value:v]);
  }
+ (id)valueWithCid:(MSOid*)cid state:(MSByte)state type:(MSByte)type
  timestamp:(MSTimeInterval)t value:(_btypedValue)v
  {
  return AUTORELEASE([ALLOC(self) initWithCid:cid state:state type:type
    timestamp:t value:v]);
  }

// TODO: si v est un txt le copie-t-on ?
- (id)initWithCid:(MSOid*)cid state:(MSByte)state type:(MSByte)type
  timestamp:(MSTimeInterval)t value:(_btypedValue)v
  {
  _cid=       RETAIN(cid);
  _car=       nil;
  _state=     state;
  _valueType= type;
  _timestamp= t;
  _value=     v;
  _subValue=  nil;
  return self;
  }

// TODO: que fait-on pour v ?
- (void)dealloc
  {
  RELEASE(_cid);
  RELEASE(_car);
  RELEASE(_subValue);
  if      (_valueType==T8) RELEASE(_value.t);
  else if (_valueType==B8) RELEASE(_value.b);
  [super dealloc];
  }

- (NSString*)_descriptionWithType:(BOOL)withType :(BOOL)withState
  {
  id v;
  if (_valueType==S8) { // TODO: GMT, DAT, DTM, DUR, BOOL
    if (ISEQUAL(_cid,MSCarDateId)) {
      id d= [[MSDate alloc] initWithSecondsSinceLocalReferenceDate:_value.s];
      v= [d descriptionWithCalendarFormat:(withType?@"D %d/%m/%Y":@"%d/%m/%Y")];
      RELEASE(d);}
    else v= FMT((withType?@"S %lld":@"%lld"), _value.s);}
  else v=
    _valueType==R8 ? FMT((withType?@"R %f":@"%f"), _value.r) :
    _valueType==B8 ? FMT((withType?@"B %@":@"%@"), _value.b) :
    _valueType==T8 ? (withType?FMT(@"T %@",_value.t):_value.t) :
    @"Unknown value";
  if (withState) {
    if      (_state==MSRemove) v= FMT(@"%@[-]",v);
    else if (_state==MSAdd   ) v= FMT(@"%@[+]",v);}
  return v;
  }
- (NSString*)description:(int)n
  {
  id v= [self _descriptionWithType:YES :YES];
  if (_valueType==B8 && !n && _subValue) v=  [_subValue description:n+1];
//return FMT(@"[%lld %lld %@]", _carBid, _timestamp, v);
  return ISEQUAL(_cid,MSCarEntityId) ? v : FMT(@"{%@}", v);
  }
- (NSString*)description
  {
  return [self _descriptionWithType:NO :YES];
  }
- (NSString*)sqlDescription:(MSOdb*)db
  {
  id v= [self _descriptionWithType:NO :NO];
  if (!_valueType || _valueType==T8) {
    v=[db escapeString:(!_valueType?@"":v) withQuotes:YES];}
  return v;
  }
- (NSString*)descriptionInContext:(id)ctx
  {
  id db, v= [self _descriptionWithType:NO :YES];
  if (!_valueType || _valueType==T8) {
    if ([ctx isKindOfClass:[MSOdb class]]) db= ctx;
    else db= [(MSDictionary*)ctx objectForKey:MSContextOdb];
    v=[db escapeString:(!_valueType?@"":v) withQuotes:YES];}
  return v;
  }

- (MSOid*)cid
  {
  return _cid;
  }
- (MSTimeInterval)timestamp
  {
  return _timestamp;
  }
- (id)typedValue
  {
  return _valueType==B8 ? _value.b :
         _valueType==S8 ? [NSNumber numberWithLongLong:_value.s] :
         _valueType==R8 ? [NSNumber numberWithDouble:  _value.r] :
         _valueType==T8 ? (id)_value.t :
         nil;
  }
- (MSLong)longLongValue
  {
  return _valueType!=S8 ? 0 : _value.s;
  }
- (NSString*)stringValue
  {
  return _valueType!=T8 ? nil : _value.t;
  }
- (MSOid*)oidValue
  {
  return _valueType!=B8 ? nil : _value.b;
  }
- (id)subValue
  {
  return _valueType!=B8 ? nil : _subValue;
  }

- (BOOL)equal:(id)x
  {
  BOOL ret= NO;
  MSOValue* v;
  if ([x isKindOfClass:[MSOValue class]]) {
    v= x;
    ret= ISEQUAL(_cid,v->_cid) && _timestamp==v->_timestamp &&
         _btypedValuesEquals(_value,v->_value,_valueType);}
  return ret;
  }

- (NSComparisonResult)compare:(id)x
  {
  NSComparisonResult ret= NSOrderedSame;
  MSOValue* v;
  if ([x isKindOfClass:[MSOValue class]]) {
    v= x;
    ret= _cmp([_cid longLongValue], [v->_cid longLongValue],
         _cmp(_timestamp, v->_timestamp,
         _btypedValuesCompare(_value,v->_value,_valueType)));}
  return ret;
  }

- (MSByte)state
  {
  return _state;
  }
- (void)setState:(MSByte)state
  {
  _state= state;
  }

- (void)setSub:(MSObi*)o
  {
  if (_valueType==B8) ASSIGN(_subValue, o);
  }

@end

@implementation MSObi

+ (void)initialize
{
  if ([self class] == [MSObi class]) {
    }
}

#pragma mark Class/Init methods

+ (id)obiWithLocalId:(id)db
  {
  return AUTORELEASE([ALLOC(self) iniWithLocalId:db]);
  }
+ (id)obiWithOid:(MSOid*)oid :(id)db
  {
  return AUTORELEASE([ALLOC(self) initWithOid:oid :db]);
  }
- (id)iniWithLocalId:(id)db
  {
  static MSLong _MSObiNewLocalOidValue= -1;
  MSOid *oid;
  // Lock
  oid= [MSOid oidWithLongLongValue:_MSObiNewLocalOidValue--];
  // Si serveur qui ne s'arrête jamais ?
  if (_MSObiNewLocalOidValue>=0) _MSObiNewLocalOidValue= -1;
  // Unlock
  return [self initWithOid:oid :db];
  }
- (id)initWithOid:(MSOid*)oid :(id)db
  {
  _db=          db;
  _status=      MSUnchanged;
  _oid=         RETAIN(oid);
  _entOid=      nil;
  _ent=         nil;
  _valuesByCid= [MSDictionary new];
  return self;
  }

- (void)dealloc
  {
  RELEASE(_oid);
  RELEASE(_entOid);
  RELEASE(_ent);
  RELEASE(_valuesByCid);
  [super dealloc];
  }

- (NSString*)description:(int)level inContext:(MSDictionary*)ctx
  {
//id e,ce,c,z,vs,ve,v,x= [NSMutableString string]; BOOL first;
  MSUid *ids; id todo;
  ids= [MSUid uidWithUid:_oid];
  todo= [MSDictionary dictionaryWithObject:self forKey:_oid];
/*
  e= [self oidValueForCid:MSCarEntiteId];
  if (OID_EQUALS(e, OID_FROM_BID(100015))) { // CPE_Révision
    if ((z= [self subValueForCid:OID_FROM_BID(110015)])){//cpe_type de révision
      [x appendString:[z _description:n+1]];}
    if ((z= [self valuesForCid:OID_FROM_BID(110019)])){//cpe_rés contrôle
      BOOL ok= YES;
      [x appendFormat:@" - %lu contrôles",[z count]];
      for (ce= [z objectEnumerator]; ok && (c= [ce nextObject]); ) {
        v= [[c subValue] oidValueForCid:OID_FROM_BID(110011)]; // conformité
//NSLog(@"%@",v);
        if (!v || !OID_EQUALS(v, OID_FROM_BID(2341))) ok= NO;} // Oui
      [x appendFormat:@" - Résultat: %@",(ok?@"Ok":@"NOT OK")];}
    }
  else if (OID_EQUALS(e, OID_FROM_BID(100009))) { // CPE_Rés pt de contrôle
    [x appendFormat:@"%@",
      [[self subValueForCid:OID_FROM_BID(110007)]
        _description:n+1]];//pt contrôle
    [x appendFormat:@" - Conformité: %@",
      [[self subValueForCid:OID_FROM_BID(110011)]
        _description:n+1]];//conformité
    }

  else if ((v= [self stringValueForCid:MSCarNomSystemeId])) {
    [x appendString:v];}
  else if ((v= [self stringValueForCid:MSCarLabelId])) {
    [x appendString:v];}
  else {
    if (n==0) {
      //if (OID_EQUALS(MSEntEntId,[self oidValueForCid:MSCarEntiteId])) {
      //  v= [self stringValueForCid:MSCarNomSystemeId];
      //  [x appendString:(v?v:@"?")];}
      vs= [_valuesByCid objectForKey:MSCarEntiteId]; first= YES;
      for (ve= [vs objectEnumerator]; (v= [ve nextObject]); first= NO) {
        z= [v _description:n];
        if (!first) [x appendString:@"-"];
        [x appendString:(z?z:@"?")];}
      for (ce= [_valuesByCid keyEnumerator]; (c= [ce nextObject]); ) {
        if (!OID_EQUALS(c, MSCarEntiteId)) {
          [x appendString:@" "];
          z= [[_db systemObiWithOid:c] stringValueForCid:MSCarNomSystemeId];
          [x appendString:(z?z:@"?")];
          //[x appendString:@"("];
          vs= [_valuesByCid objectForKey:c];
          for (ve= [vs objectEnumerator]; (v= [ve nextObject]); ) {
            z= [v _description:n]; [x appendString:(z?z:@"?")];}
        //[x appendString:@")"];
        }}}
    else {
      [x appendFormat:@"%lu cars",[_valuesByCid count]];}}
*/
  return _obiDesc(level, ctx, ids, todo);
  }
- (NSString*)descriptionInContext:(MSDictionary*)ctx
  {
  return [self description:0 inContext:ctx];
  }
- (NSString*)description:(int)n
  {
  return [self description:n inContext:nil];
  }
- (NSString*)description
  {
  return [self description:0 inContext:nil];
  }

- (MSOid*)oid
  {
  return _oid;
  }
- (MSByte)status
  {
  return _status;
  }
- (void)setStatus:(MSByte)status
  {
  _status= status;
  }

#pragma mark Get values

- (MSArray*)cids
  {
  return [_valuesByCid allKeys];
  }
- (MSDictionary*)allValuesByCid
  {
  return _valuesByCid;
  }
- (MSArray*)allValuesForCid:(MSOid*)cid
  {
  return [_valuesByCid objectForKey:cid];
  }
// TODO: The current timestamp
- (MSArray*)valuesForCid:(MSOid*)cid
  {
  id vs; NSUInteger n,ni; BOOL end; MSTimeInterval ti,t=0;
  vs= [_valuesByCid objectForKey:cid];
  n= [vs count];
  if (n>1) {
    t= [[vs objectAtIndex:n-1] timestamp];
    if (t!=[[vs objectAtIndex:0] timestamp]) {
      for (ni= n-1, end= NO; !end && ni>0;) {
        ti= [[vs objectAtIndex: ni-1] timestamp];
        if (ti!=t) end= YES; else ni--;}
      vs= [vs subarrayWithRange:NSMakeRange(ni, n-ni)];
      }}
  return vs;
  }
- (MSOValue*)valueForCid:(MSOid*)cid
  {
  id vs,vi,v=nil; NSUInteger n; BOOL end; MSTimeInterval ti,t=0;
  vs= [_valuesByCid objectForKey:cid];
  n= [vs count];
  for (end= NO; !end && n>0; n--) {
    vi= [vs objectAtIndex:n-1];
    ti= [vi timestamp];
    if (!v || t==ti) {v= vi; t= ti;}
    else end= YES;}
  return v;
  }
- (NSArray*)typedValuesForCid:(MSOid*)cid
  {
  MSArray* vs; NSUInteger n,i; id v,ret;
  ret= [MSArray mutableArray];
  if ((vs= [self valuesForCid:cid]) && (n= [vs count])) {
    for (i=0; i<n; i++) if ((v= [[vs objectAtIndex:i] typedValue])) {
      CArrayAddObject((CArray*)ret, v);}}
  [ret setImmutable];
  return ret;
  }
- (id)typedValueForCid:(MSOid*)cid
  {
  MSOValue *v; id ret= nil;
  if ((v= [self valueForCid:cid])) {
    ret= [v typedValue];}
  return ret;
  }
- (MSArray*)stringValuesForCid:(MSOid*)cid
  {
  MSArray* vs; NSUInteger n,i; id v,ret;
  ret= [MSArray mutableArray];
  if ((vs= [self valuesForCid:cid]) && (n= [vs count])) {
    for (i=0; i<n; i++) if ((v= [[vs objectAtIndex:i] stringValue])) {
      CArrayAddObject((CArray*)ret, v);}}
  [ret setImmutable];
  return ret;
  }
- (MSLong)longLongValueForCid:(MSOid*)cid
  {
  MSOValue *v; MSLong ret= 0;
  if ((v= [self valueForCid:cid])) {
    ret= [v longLongValue];}
  return ret;
  }
- (NSString*)stringValueForCid:(MSOid*)cid
  {
  MSOValue *v; NSString *ret= nil;
  if ((v= [self valueForCid:cid])) {
    ret= [v stringValue];}
  return ret;
  }
- (MSUid*)oidValuesForCid:(MSOid*)cid
  {
  MSArray* vs; NSUInteger n,i; id v,ret;
  ret= [MSUid uid];
  if ((vs= [self valuesForCid:cid]) && (n= [vs count])) {
    for (i= 0; i<n; i++) if ((v= [[vs objectAtIndex:i] oidValue])) [ret addUid:v];}
  return ret;
  }
- (MSOid*)oidValueForCid:(MSOid*)cid
  {
  MSOValue *v; MSOid* ret= nil;
  if ((v= [self valueForCid:cid])) {
    ret= [v oidValue];}
  return ret;
  }
- (MSObi*)subValueForCid:(MSOid*)cid
  {
  MSOValue *v; id ret= nil;
  if ((v= [self valueForCid:cid])) {
    ret= [v subValue];}
  return ret;
  }
- (NSString*)systemName
  {
  return [self stringValueForCid:MSCarSystemNameId];
  }

#pragma mark Set values

// TODO: best search and sorting dichotomie
- (BOOL)_setValue:(MSOValue*)v :(MSByte)how
  {
  BOOL ret= NO;
  MSOid* cid= [v cid];
  id vs;
  if (_status!=MSDelete && cid) {
      if (!(vs= [_valuesByCid objectForKey:cid])) {
        [_valuesByCid setObject:(vs= [MSArray mutableArray]) forKey:cid];
        ret= YES;}
      else ret= ([vs indexOfObject:v]==NSNotFound);
      if (ret) {
        [vs addObject:v];
        //[vs sortUsingSelector:@selector(compare:)];
        if (how==MSAdd) {
          [v setState:how];
          _status=
            _status==MSUnchanged ? MSAdd    :
            _status==MSRemove    ? MSModify :
            _status;}}}
  return ret;
  }
- (BOOL)setValue:(MSOValue*)v
  // Return YES if set
  {
  return [self _setValue:v :MSUnchanged];
  }

- (void)removeIdenticalLocalValue:(MSOValue*)v
  {
  id cid,vs; NSUInteger idx;
  if ((cid= [v cid]) && (vs= [_valuesByCid objectForKey:cid]) &&
      (idx= [vs indexOfObjectIdenticalTo:v])!=NSNotFound) {
    [vs removeObjectAtIndex:idx];}
  }

@end

@implementation MSObi (Sys)
- (MSObi*)entPatternOfCid:(MSOid*)cid
{
  id patterns,e,p,pFd;
  pFd= nil;
  if (cid) {
    patterns= [self valuesForCid:MSCarPatternId];
    for (e= [patterns objectEnumerator]; !pFd && (p= [e nextObject]);) {
      p= [(MSOValue*)p subValue];
      if (ISEQUAL(cid, [p oidValueForCid:MSCarCharacteristicId])) pFd= p;}}
  return pFd;
}
- (MSObi*)_carObiType
{
  id r= [self subValueForCid:MSCarTypeId];
  if (!r) // subValue may not be set.
    r= [_db systemObiWithOid:[self oidValueForCid:MSCarTypeId]];
  return r;
}
- (NSString*)carType
{
  return [[self _carObiType] systemName];
}
- (NSString*)carTable
{
  return [[self _carObiType] typTable];
}
- (MSByte)carTableType
{
  id tb= [self carTable];
  return ISEQUAL(tb,@"ID") ? B8 : ISEQUAL(tb,@"STR") ? T8 : ISEQUAL(tb,@"INT") ? S8 : 0;
}
- (NSString*)typTable
{
  id t= [self stringValueForCid:MSCarTableId];
  return t ? t : [self systemName];
}
@end

@implementation MSObi (Private)
- (void)setOid:(MSOid*)oid
{
  ASSIGN(_oid, oid);
}
@end

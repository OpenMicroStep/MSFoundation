// msfoundation_string_validate.m, ecb, 130911

#include "msfoundation_validate.h"

@interface SimpleTypesContainer : NSObject
{
@public
  BOOL _bool ;
  MSByte _byte ;
  MSChar _char ;
  MSUShort _ushort ;
  MSShort _short ;
  MSUInt _uint ;
  MSInt _int ;
  MSULong _ulong ;
  MSLong _long ;
  double _double ;
  float _float ;

@protected
  NSNumber *_boolNumber ;
  NSNumber *_byteNumber ;
  NSNumber *_charNumber ;
  NSNumber *_ushortNumber ;
  NSNumber *_shortNumber ;
  NSNumber *_uintNumber ;
  NSNumber *_intNumber ;
  NSNumber *_ulongNumber ;
  NSNumber *_longNumber ;
  NSNumber *_doubleNumber ;
  NSNumber *_floatNumber ;
}

- (void)setBoolNumber:(BOOL)abool ;
- (void)setByteNumber:(MSByte)ashort ;
- (void)setCharNumber:(MSChar)achar ;
- (void)setUShortNumber:(MSUShort)aushort ;
- (void)setShortNumber:(MSShort)ashort ;
- (void)setUIntNumber:(MSUInt)auint ;
- (void)setIntNumber:(MSInt)aint ;
- (void)setULongNumber:(MSULong)aulong ;
- (void)setLongNumber:(MSLong)along ;
- (void)setDoubleNumber:(double)adouble ;
- (void)setFloatNumber:(float)afloat ;

@end

@implementation SimpleTypesContainer : NSObject

- (void)dealloc {
  RELEASE(_boolNumber) ;
  RELEASE(_byteNumber) ;
  RELEASE(_charNumber) ;
  RELEASE(_ushortNumber) ;
  RELEASE(_shortNumber) ;
  RELEASE(_uintNumber) ;
  RELEASE(_intNumber) ;
  RELEASE(_ulongNumber) ;
  RELEASE(_longNumber) ;
  RELEASE(_doubleNumber) ;
  RELEASE(_floatNumber) ;
  [super dealloc] ;
}

- (void)setBoolNumber:(BOOL)abool { ASSIGN(_boolNumber, [NSNumber numberWithBool:abool]); }
- (void)setByteNumber:(MSByte)abyte { ASSIGN(_byteNumber, [NSNumber numberWithUnsignedChar:abyte]); }
- (void)setCharNumber:(MSChar)achar { ASSIGN(_charNumber, [NSNumber numberWithChar:achar]); }
- (void)setShortNumber:(MSShort)ashort { ASSIGN(_shortNumber, [NSNumber numberWithShort:ashort]); }
- (void)setUShortNumber:(MSUShort)aushort { ASSIGN(_ushortNumber, [NSNumber numberWithUnsignedShort:aushort]); }
- (void)setUIntNumber:(MSUInt)auint { ASSIGN(_uintNumber, [NSNumber numberWithUnsignedInt:auint]); }
- (void)setIntNumber:(MSInt)aint { ASSIGN(_intNumber, [NSNumber numberWithInt:aint]); }
- (void)setULongNumber:(MSULong)aulong { ASSIGN(_ulongNumber, [NSNumber numberWithUnsignedLongLong:aulong]); }
- (void)setLongNumber:(MSLong)along { ASSIGN(_longNumber, [NSNumber numberWithLongLong:along]); }
- (void)setDoubleNumber:(double)adouble { ASSIGN(_doubleNumber, [NSNumber numberWithDouble:adouble]); }
- (void)setFloatNumber:(float)afloat { ASSIGN(_floatNumber, [NSNumber numberWithFloat:afloat]); }

- (NSString *)description {
  return [NSString stringWithFormat:@"SimpleTypesContainer: %@/%u/%d%u/%d/%u/%d/%llu/%lld/%f/%f - %@/%@%@/%@/%@/%@/%@/%@/%@/%@/%@",
     (_bool ? @"YES" : @"NO"),
     _byte,
     _char,
     _ushort,
     _short,
     _uint,
     _int,
     _ulong,
     _long,
     _double,
     _float,
     _boolNumber,
     _byteNumber,
     _charNumber,
     _ushortNumber,
     _shortNumber,
     _uintNumber,
     _intNumber,
     _ulongNumber,
     _longNumber,
     _doubleNumber,
     _floatNumber,
     nil] ;
}

- (BOOL)isEqual:(id)object
{
  BOOL result = NO ;
  
  if ([object isKindOfClass:[self class] ]) {
    SimpleTypesContainer *o = (SimpleTypesContainer *)object ;

    result = (_bool == o->_bool) &&
      (_byte == o->_byte) &&
      (_char == o->_char) &&
      (_ushort == o->_ushort) &&
      (_short == o->_short) &&
      (_uint == o->_uint) &&
      (_int == o->_int) &&
      (_ulong == o->_ulong) &&
      (_long == o->_long) &&
      (_double == o->_double) &&
      (_float == o->_float) ;
    
    if (result) { result = ((_boolNumber && o->_boolNumber) ? ([_boolNumber boolValue] == [o->_boolNumber boolValue]) : ((!_boolNumber && !(o->_boolNumber)) ? YES : NO)) ; }
    if (result) { result = ((_byteNumber && o->_byteNumber) ? ([_byteNumber unsignedCharValue] == [o->_byteNumber unsignedCharValue]) : ((!_byteNumber && !(o->_byteNumber)) ? YES : NO)) ; }
    if (result) { result = ((_charNumber && o->_charNumber) ? ([_charNumber charValue] == [o->_charNumber charValue]) : ((!_charNumber && !(o->_charNumber)) ? YES : NO)) ; }
    if (result) { result = ((_ushortNumber && o->_ushortNumber) ? ([_ushortNumber unsignedShortValue] == [o->_ushortNumber unsignedShortValue]) : ((!_ushortNumber && !(o->_ushortNumber)) ? YES : NO)) ; }
    if (result) { result = ((_shortNumber && o->_shortNumber) ? ([_shortNumber shortValue] == [o->_shortNumber shortValue]) : ((!_shortNumber && !(o->_shortNumber)) ? YES : NO)) ; }
    if (result) { result = ((_uintNumber && o->_uintNumber) ? ([_uintNumber unsignedIntValue] == [o->_uintNumber unsignedIntValue]) : ((!_uintNumber && !(o->_uintNumber)) ? YES : NO)) ; }
    if (result) { result = ((_intNumber && o->_intNumber) ? ([_intNumber intValue] == [o->_intNumber intValue]) : ((!_intNumber && !(o->_intNumber)) ? YES : NO)) ; }
    if (result) { result = ((_ulongNumber && o->_ulongNumber) ? ([_ulongNumber unsignedLongLongValue] == [o->_ulongNumber unsignedLongLongValue]) : ((!_ulongNumber && !(o->_ulongNumber)) ? YES : NO)) ; }
    if (result) { result = ((_longNumber && o->_longNumber) ? ([_longNumber longLongValue] == [o->_longNumber longLongValue]) : ((!_longNumber && !(o->_longNumber)) ? YES : NO)) ; }
    if (result) { result = ((_doubleNumber && o->_doubleNumber) ? ([_doubleNumber doubleValue] == [o->_doubleNumber doubleValue]) : ((!_doubleNumber && !(o->_doubleNumber)) ? YES : NO)) ; }
    if (result) { result =((_floatNumber && o->_floatNumber) ? ([_floatNumber floatValue] == [o->_floatNumber floatValue]) : ((!_floatNumber && !(o->_floatNumber)) ? YES : NO)) ; }
  }
  return result ;
}

- (NSDictionary *)MSTESnapshot
{
  NSMutableDictionary *res = [NSMutableDictionary dictionary] ;
  
  [res setObject:CREATE_MSTE_SNAPSHOT_VALUE([NSNumber numberWithBool:_bool], NO) forKey:@"_bool"] ;
  [res setObject:CREATE_MSTE_SNAPSHOT_VALUE([NSNumber numberWithUnsignedChar:_byte], NO) forKey:@"_byte"] ;
  [res setObject:CREATE_MSTE_SNAPSHOT_VALUE([NSNumber numberWithChar:_char], NO) forKey:@"_char"] ;
  [res setObject:CREATE_MSTE_SNAPSHOT_VALUE([NSNumber numberWithUnsignedShort:_ushort], NO) forKey:@"_ushort"] ;
  [res setObject:CREATE_MSTE_SNAPSHOT_VALUE([NSNumber numberWithShort:_short], NO) forKey:@"_short"] ;
  [res setObject:CREATE_MSTE_SNAPSHOT_VALUE([NSNumber numberWithUnsignedInt:_uint], NO) forKey:@"_uint"] ;
  [res setObject:CREATE_MSTE_SNAPSHOT_VALUE([NSNumber numberWithInt:_int], NO) forKey:@"_int"] ;
  [res setObject:CREATE_MSTE_SNAPSHOT_VALUE([NSNumber numberWithUnsignedLongLong:_ulong], NO) forKey:@"_ulong"] ;
  [res setObject:CREATE_MSTE_SNAPSHOT_VALUE([NSNumber numberWithLongLong:_long], NO) forKey:@"_long"] ;
  [res setObject:CREATE_MSTE_SNAPSHOT_VALUE([NSNumber numberWithDouble:_double], NO) forKey:@"_double"] ;
  [res setObject:CREATE_MSTE_SNAPSHOT_VALUE([NSNumber numberWithFloat:_float], NO) forKey:@"_float"] ;

  if (_boolNumber) { [res setObject:CREATE_MSTE_SNAPSHOT_VALUE(_boolNumber, YES) forKey:@"_boolNumber"] ; }
  if (_byteNumber) { [res setObject:CREATE_MSTE_SNAPSHOT_VALUE(_byteNumber, YES) forKey:@"_byteNumber"] ; }
  if (_charNumber) { [res setObject:CREATE_MSTE_SNAPSHOT_VALUE(_charNumber, YES) forKey:@"_charNumber"] ; }
  if (_ushortNumber) { [res setObject:CREATE_MSTE_SNAPSHOT_VALUE(_ushortNumber, YES) forKey:@"_ushortNumber"] ; }
  if (_shortNumber) { [res setObject:CREATE_MSTE_SNAPSHOT_VALUE(_shortNumber, YES) forKey:@"_shortNumber"] ; }
  if (_uintNumber) { [res setObject:CREATE_MSTE_SNAPSHOT_VALUE(_uintNumber, YES) forKey:@"_uintNumber"] ; }
  if (_intNumber) { [res setObject:CREATE_MSTE_SNAPSHOT_VALUE(_intNumber, YES) forKey:@"_intNumber"] ; }
  if (_ulongNumber) { [res setObject:CREATE_MSTE_SNAPSHOT_VALUE(_ulongNumber, YES) forKey:@"_ulongNumber"] ; }
  if (_longNumber) { [res setObject:CREATE_MSTE_SNAPSHOT_VALUE(_longNumber, YES) forKey:@"_longNumber"] ; }
  if (_doubleNumber) { [res setObject:CREATE_MSTE_SNAPSHOT_VALUE(_doubleNumber, YES) forKey:@"_doubleNumber"] ; }
  if (_floatNumber) { [res setObject:CREATE_MSTE_SNAPSHOT_VALUE(_floatNumber, YES) forKey:@"_floatNumber"] ; }

  return res ;
}

- (id)initWithDictionary:(NSDictionary *)values
{
  _bool = [[values objectForKey:@"_bool"] boolValue] ;
  
  _byte = [[values objectForKey:@"_byte"] unsignedCharValue] ;
  _char = [(NSNumber*)[values objectForKey:@"_char"] charValue] ;
  _ushort = [[values objectForKey:@"_ushort"] unsignedShortValue] ;
  _short = [[values objectForKey:@"_short"] shortValue] ;
  _uint = [[values objectForKey:@"_uint"] unsignedIntValue] ;
  _int = [[values objectForKey:@"_int"] intValue] ;
  _ulong = [[values objectForKey:@"_ulong"] unsignedLongLongValue] ;
  _long = [[values objectForKey:@"_long"] longLongValue] ;
  _double = [[values objectForKey:@"_double"] doubleValue] ;
  _float = [[values objectForKey:@"_float"] floatValue] ;

  ASSIGN(_boolNumber, [values objectForKey:@"_boolNumber"]) ;
  ASSIGN(_byteNumber, [values objectForKey:@"_byteNumber"]) ;
  ASSIGN(_charNumber, [values objectForKey:@"_charNumber"]) ;
  ASSIGN(_shortNumber, [values objectForKey:@"_shortNumber"]) ;
  ASSIGN(_ushortNumber, [values objectForKey:@"_ushortNumber"]) ;
  ASSIGN(_uintNumber, [values objectForKey:@"_uintNumber"]) ;
  ASSIGN(_intNumber, [values objectForKey:@"_intNumber"]) ;
  ASSIGN(_ulongNumber, [values objectForKey:@"_ulongNumber"]) ;
  ASSIGN(_longNumber, [values objectForKey:@"_longNumber"]) ;
  ASSIGN(_doubleNumber, [values objectForKey:@"_doubleNumber"]) ;
  ASSIGN(_floatNumber, [values objectForKey:@"_floatNumber"]) ;

	return self ;
}

@end

@interface Person : NSObject
{
	NSString *_name;
	NSString *_firstName;
	NSDate *_birthday;
	
	Person *_maried_to ;
	Person *_father ;
	Person *_mother ;
}

+ (id)personWithName:(NSString *)name firstName:(NSString *)firstName birthDay:(NSDate *)birthDay;
- (id)initWithName:(NSString *)name firstName:(NSString *)firstName birthDay:(NSDate *)birthDay;

- (void)setMariedTo:(Person *)person;
- (void)setFather:(Person *)person;
- (void)setMother:(Person *)person;

- (NSString *)name;
- (NSString *)firstName;
- (NSDate *)birthday;
- (Person *)mariedTo;
- (Person *)father;
- (Person *)mother;

@end

@interface SubPerson : Person
@end


@implementation Person

+ (id)personWithName:(NSString *)name firstName:(NSString *)firstName birthDay:(NSDate *)birthDay
{
	return [[[self alloc] initWithName:(NSString *)name firstName:(NSString *)firstName birthDay:(NSDate *)birthDay] autorelease] ;
}
- (id)initWithName:(NSString *)name firstName:(NSString *)firstName birthDay:(NSDate *)birthDay
{
	_name = [name retain] ;
	_firstName = [firstName retain] ;
	_birthday = [birthDay retain] ;
  return self;
}

- (void)dealloc
{
	RELEASE(_name) ;
	RELEASE(_firstName) ;
	RELEASE(_birthday) ;
	RELEASE(_maried_to) ;
	RELEASE(_father) ;
	RELEASE(_mother) ;
	[super dealloc] ;
}

- (void)setMariedTo:(Person *)person { 	_maried_to = [person retain] ; }
- (void)setFather:(Person *)person { 	_father = [person retain] ; }
- (void)setMother:(Person *)person { 	_mother = [person retain] ; }

- (NSString *)name { return _name ; }
- (NSString *)firstName { return _firstName ; }
- (NSDate *)birthday { return _birthday ; }
- (Person *)mariedTo { return _maried_to ; }
- (Person *)father { return _father ; }
- (Person *)mother { return _mother ; }

- (NSString *)description { return [NSString stringWithFormat:@"Person: %@ %@ %@", _name, _firstName, _birthday] ; }

- (NSDictionary *)MSTESnapshot
{
  NSMutableDictionary *res = [NSMutableDictionary dictionary] ;
  
  if (_name) { [res setObject:CREATE_MSTE_SNAPSHOT_VALUE(_name, YES) forKey:@"name"] ; }
  if (_firstName) { [res setObject:CREATE_MSTE_SNAPSHOT_VALUE(_firstName, YES) forKey:@"firstName"] ; }
  if (_birthday) { [res setObject:CREATE_MSTE_SNAPSHOT_VALUE(_birthday, YES) forKey:@"birthday"] ; }
  if (_maried_to) { [res setObject:CREATE_MSTE_SNAPSHOT_VALUE(_maried_to, YES) forKey:@"maried-to"] ; }
  if (_father) { [res setObject:CREATE_MSTE_SNAPSHOT_VALUE(_father, YES) forKey:@"father"] ; }
  if (_mother) { [res setObject:CREATE_MSTE_SNAPSHOT_VALUE(_mother, YES) forKey:@"mother"] ; }
  
  return res ;
}

- (id)initWithDictionary:(NSDictionary *)values
{
	_name = [[values objectForKey:@"name"] retain] ;
	_firstName = [[values objectForKey:@"firstName"] retain] ;
	_birthday = [[values objectForKey:@"birthday"] retain] ;
	_maried_to = [[values objectForKey:@"maried-to"] retain] ;
	_father = [[values objectForKey:@"father"] retain] ;
	_mother = [[values objectForKey:@"mother"] retain] ;
	return self ;
}

- (BOOL)isEqual:(id)object
{
  BOOL result = NO ;
  
  if ([object isMemberOfClass:[self class] ]) {
    Person *o = (Person *)object ;
    result = YES ;
    
    if (result) { result = ISEQUAL(_name, [o name]) ; }
    if (result) { result = ISEQUAL(_firstName, [o firstName]) ; }
    if (result) { result = ISEQUAL(_birthday, [o birthday]) ; }
    //if (result) { result = ISEQUAL(_maried_to, [o mariedTo]) ; } //unlimited loop
    if (result) { result = ISEQUAL(_father, [o father]) ; } ;
    if (result) { result = ISEQUAL(_mother, [o mother]) ; }
  }
  return result ;
}
@end

@implementation SubPerson

- (NSString *)description { return [NSString stringWithFormat:@"SubPerson: %@ %@ %@", _name, _firstName, _birthday] ; }

@end

static inline int _decode(char *ssrc, id ret)
{
  int err= 0;
  NSString *error = nil;
  MSBuffer *src, *enc;
  id o = nil;
//printf("B0: %s\n",ssrc);
  src= MSCreateBufferWithBytes(ssrc, strlen(ssrc));

  NS_DURING
    o = [src MSTDecodedObject] ;
  NS_HANDLER
    error = [localException reason];
    if (!error) {
      error = @"unkown error" ;
    }
  NS_ENDHANDLER
  
  if (error) {
    printf("B1: %s", [error UTF8String]); err++; }
  else if (!ISEQUAL(ret, o)) {
    printf("B3: Bad result for %s -> %s (expected : %s)",ssrc, [[o description] UTF8String], [[ret description] UTF8String]);
    err++; }
  
  error= nil;
  NS_DURING
    enc= [ret MSTEncodedBuffer];
    o = [enc MSTDecodedObject] ;
  NS_HANDLER
    error = [localException reason];
    if (!error) {
      error = @"unkown error" ;
    }
  NS_ENDHANDLER
  
  if (error) {
    printf("E1: %s", [error UTF8String]); err++;
  }
  else if (ret && !ISEQUAL(ret, o)) {
    printf("E3: Bad result for %s -> %s -> %s (expected : %s)",
           [[ret description] UTF8String],
           [[[[NSString alloc] initWithData:enc encoding:NSUTF8StringEncoding] autorelease] UTF8String],
           [[o description] UTF8String],
           [[ret description] UTF8String]);
    err++;
  }
  
    
  RELEAZEN(src);
  RELEAZEN(error);
  return err;
}

static void mste_some(test_t *test)
{
  int err= 0;

/*  { //For generate MSTE expression...
    id o = [NSDecimalNumber decimalNumberWithString:@"12.34"] ;
    MSBuffer *buf = [o MSTEncodedBuffer] ;
    CBufferAppendByte((CBuffer *)buf, 0) ;
    NSLog(@"MSTE -> %@", [NSString stringWithUTF8String:[buf bytes]]);
  }*/
  
  //nil (code 0)
  err += _decode("[\"MSTE0102\",6,\"CRC82413E70\",0,0,0]", nil);
  //objet null (code 0)
//  err += _decode("[\"MSTE0102\",6,\"CRC82413E70\",0,0,0]", [NSNull null]); //A VOIR POUR NULL / NIL!!!
  //True (code 1)
  err += _decode("[\"MSTE0102\",6,\"CRC9B5A0F31\",0,0,1]", [NSNumber numberWithBool:YES]);
  //False (code 2)
  err += _decode("[\"MSTE0102\",6,\"CRCB0775CF2\",0,0,2]", [NSNumber numberWithBool:NO]);
  //Empty string (code 3)
  err += _decode("[\"MSTE0102\",6,\"CRCA96C6DB3\",0,0,3]", @"");
  //Empty data (code 4)
  err += _decode("[\"MSTE0102\",6,\"CRCE62DFB74\",0,0,4]", [NSData data]);
    
  //Simple types (codes 10 -> 19)
  {
    SimpleTypesContainer *o = [[[SimpleTypesContainer alloc] init] autorelease];
    o->_bool = YES ;
    o->_byte = 1 ;
    o->_char = -1 ;
    o->_ushort = 2 ;
    o->_short = -2 ;
    o->_uint = 3 ;
    o->_int = -3 ;
    o->_ulong = 4 ;
    o->_long = -4 ;
    o->_double = 125.75 ;
    o->_float = 12.34f ;
    
    [o setBoolNumber:NO] ;
    [o setByteNumber:10] ;
    [o setCharNumber:-10] ;
    [o setUShortNumber:20] ;
    [o setShortNumber:-20] ;
    [o setUIntNumber:30] ;
    [o setIntNumber:-30] ;
    [o setULongNumber:40] ;
    [o setLongNumber:-40] ;
    [o setDoubleNumber:1230.5] ;
    [o setFloatNumber:-120.5f] ;

    err += _decode("[\"MSTE0102\",94,\"CRC1BB6B687\",1,\"SimpleTypesContainer\",22,\"_char\",\"_float\",\"_byte\",\"_byteNumber\",\"_shortNumber\",\"_charNumber\",\"_floatNumber\",\"_longNumber\",\"_ushort\",\"_ushortNumber\",\"_int\",\"_ulong\",\"_uint\",\"_intNumber\",\"_short\",\"_double\",\"_bool\",\"_uintNumber\",\"_long\",\"_ulongNumber\",\"_doubleNumber\",\"_boolNumber\",50,22,0,10,-1,1,18,12.340000,2,12,1,3,20,10,4,20,-20,5,20,-10,6,20,-120.500000,7,20,-40,8,14,2,9,20,20,10,14,-3,11,16,4,12,16,3,13,20,-30,14,12,-2,15,19,125.750000000000000,16,1,17,20,30,18,16,-4,19,20,40,20,20,1230.500000000000000,21,2]", o);
    //problème possible sur la précision de l'encodage des float et des double en fonction des valeurs choisies
  }
  
  //Decimal number (code 20)
  err += _decode("[\"MSTE0102\",7,\"CRCBF421375\",0,0,20,12.34]", [MSDecimal decimalWithString:@"12.34"]);
  //String "My beautiful string éè" (code 21)
  err += _decode("[\"MSTE0102\",7,\"CRC09065CB6\",0,0,21,\"My beautiful string \\u00E9\\u00E8\"]", @"My beautiful string éè");
  //String "Json \\a/b\"cÆ" (code 21)
  err += _decode("[\"MSTE0102\",7,\"CRC4A08AB7A\",0,0,21,\"Json \\\\a\\/b\\\"c\\u00C6\"]", @"Json \\a/b\"cÆ");
  //date 2001/01/01 (NSDate) (code 22)
  err += _decode("[\"MSTE0102\",7,\"CRC093D5173\",0,0,22,978307200]", [NSDate dateWithTimeIntervalSince1970:GMTFromLocal(978307200)]); //Rajouter le isEqual: entre NSDate et MSDate
  //date 2001/01/01 (MSDate) (code 22)
  err += _decode("[\"MSTE0102\",7,\"CRC093D5173\",0,0,22,978307200]", [MSDate dateWithYear:2001 month:1 day:1]); //[NSDate initWithTimeIntervalSinceReferenceDate:]: method only defined for abstract class.
  //date 2001/01/01 (NSCalendarDate) (code 23)
  err += _decode("[\"MSTE0102\",7,\"CRC5EC4E889\",0,0,23,978307200.000000000000000]", [NSDate dateWithTimeIntervalSinceReferenceDate:0]);
  err += _decode("[\"MSTE0102\",7,\"CRC5EC4E889\",0,0,23,978307200.000000000000000]", [NSDate dateWithString:@"2001-01-01 00:00:00 +0000"]);
  err += _decode("[\"MSTE0102\",7,\"CRC5EC4E889\",0,0,23,978307200.000000000000000]", [NSDate dateWithString:@"2001-01-01 01:00:00 +0100"]);
  err += _decode("[\"MSTE0102\",7,\"CRC5EC4E889\",0,0,23,978307200.000000000000000]", [NSDate dateWithString:@"2001-01-01 02:00:00 +0200"]);
  err += _decode("[\"MSTE0102\",7,\"CRC5EC4E889\",0,0,23,978303600.000000000000000]", [NSDate dateWithString:@"2001-01-01 00:00:00 +0100"]);
  err += _decode("[\"MSTE0102\",7,\"CRC5EC4E889\",0,0,23,978303600.000000000000000]", [NSDate dateWithString:@"2001-01-01 01:00:00 +0200"]);
  //date Color (code 24)
  err += _decode("[\"MSTE0102\",7,\"CRCAB284946\",0,0,24,4034942921]", [MSColor colorWithRed:128 green:87 blue:201 opacity:15]);
  //data via NSData (code 25)
  err += _decode("[\"MSTE0102\",7,\"CRC4964EA3B\",0,0,25,\"YTF6MmUzcjR0NA==\"]", [NSData dataWithBytes:"a1z2e3r4t4" length:10]);
  //data via MSBuffer (code 25)
  err += _decode("[\"MSTE0102\",7,\"CRC4964EA3B\",0,0,25,\"YTF6MmUzcjR0NA==\"]", [MSBuffer dataWithBytes:"a1z2e3r4t4" length:10]);
  //natural array (code 26)
  err += _decode("[\"MSTE0102\",8,\"CRCD6330919\",0,0,26,1,256]", [MSNaturalArray naturalArrayWithNatural:256]);
  //dictionary (code 30)
  err += _decode("[\"MSTE0102\",15,\"CRC891261B3\",0,2,\"key1\",\"key2\",30,2,0,21,\"First object\",1,21,\"Second object\"]", [NSDictionary dictionaryWithObjectsAndKeys:@"First object", @"key1", @"Second object", @"key2", nil]);
  err += _decode("[\"MSTE0102\",15,\"CRC891261B3\",0,2,\"key1\",\"key2\",30,2,0,21,\"First object\",1,21,\"Second object\"]", [MSDictionary dictionaryWithObjectsAndKeys:@"First object", @"key1", @"Second object", @"key2", nil]);
  //array (code 31)
  err += _decode("[\"MSTE0102\",11,\"CRC1258D06E\",0,0,31,2,21,\"First object\",21,\"Second object\"]", [NSArray arrayWithObjects:@"First object", @"Second object", nil]);
  //couple (code 32)
  err += _decode("[\"MSTE0102\",10,\"CRCF8392337\",0,0,32,21,\"First member\",21,\"Second member\"]", [MSCouple coupleWithFirstMember:@"First member" secondMember:@"Second member"]);
  
  //user class (code 50)
  {
    NSString *nomDurand = @"Durand" ;
    Person *pers1 = [Person personWithName:nomDurand firstName:@"Yves" birthDay:[NSDate dateWithTimeIntervalSince1970:-243820800]] ;
    Person *pers2 = [Person personWithName:nomDurand firstName:@"Claire" birthDay:[NSDate dateWithTimeIntervalSince1970:-207360000]] ;
    Person *pers3 = [Person personWithName:nomDurand firstName:@"Lou" birthDay:[NSDate dateWithTimeIntervalSince1970:552096000]] ;
    NSArray *o = [NSArray arrayWithObjects:pers1, pers2, pers3, nil] ;
    
    [pers1 setMariedTo:pers2] ;
    [pers2 setMariedTo:pers1] ;
    [pers3 setMother:pers2] ;
    [pers3 setFather:pers1] ;

    err += _decode("[\"MSTE0102\",59,\"CRCBB46D817\",1,\"Person\",6,\"firstName\",\"maried-to\",\"name\",\"birthday\",\"mother\",\"father\",31,3,50,4,0,21,\"Yves\",1,50,4,0,21,\"Claire\",1,9,1,2,21,\"Durand\",3,23,-207360000.000000000000000,2,9,5,3,23,-243820800.000000000000000,9,3,50,5,0,21,\"Lou\",4,9,3,2,9,5,3,23,552096000.000000000000000,5,9,1]", o);
  }

  //user classes (code >= 50)
  {
    Person *pers1 = [Person personWithName:@"Durand" firstName:@"Yves" birthDay:[NSDate dateWithTimeIntervalSince1970:-243820800]] ;
    SubPerson *pers2 = [SubPerson personWithName:@"Dupond" firstName:@"Ginette" birthDay:[NSDate dateWithTimeIntervalSince1970:-207360000]] ;
    NSArray *o = [NSArray arrayWithObjects:pers1, pers2, nil] ;
      
    err += _decode("[\"MSTE0102\",34,\"CRC7403EC23\",2,\"Person\",\"SubPerson\",3,\"name\",\"firstName\",\"birthday\",31,2,50,3,0,21,\"Durand\",1,21,\"Yves\",2,23,-243820800.000000000000000,51,3,0,21,\"Dupond\",1,21,\"Ginette\",2,23,-207360000.000000000000000]", o);
  }

  //already referenced object (code 9)
  {
    id aString = @"multiple referenced object" ;
    id o = [NSArray arrayWithObjects:aString, aString, nil] ;

    err += _decode("[\"MSTE0102\",11,\"CRC32766EEF\",0,0,31,2,21,\"multiple referenced object\",9,1]", o);
  }

  TASSERT_EQUALS(test, err, 0, "mste errors %d",err);
}

test_t msfoundation_mste[]= {
  {"some",NULL,mste_some,INTITIALIZE_TEST_T_END},
  {NULL}
};

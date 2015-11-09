#import "FoundationCompatibility_Private.h"

@implementation NSScanner
+ (instancetype)scannerWithString:(NSString *)aString
{ return AUTORELEASE([ALLOC(self) initWithString:aString]); }
- (instancetype)initWithString:(NSString *)aString
{
  _charactersToBeSkipped= [[NSCharacterSet whitespaceAndNewlineCharacterSet] retain];
  _string= [aString copy];
  _ses= SESFromString(_string);
  _i= SESStart(_ses);
  return self;
}
- (void)dealloc
{
  [_string release];
  [_charactersToBeSkipped release];
  [super dealloc];
}
- (BOOL)caseSensitive
{ return !_caseInsensitive; }
- (void)setCaseSensitive:(BOOL)flag
{ _caseInsensitive= !flag; }

- (NSCharacterSet *)charactersToBeSkipped
{ return _charactersToBeSkipped; }
- (void)setCharactersToBeSkipped:(NSCharacterSet *)skipSet
{ ASSIGN(_charactersToBeSkipped, skipSet); }

- (NSUInteger)scanLocation
{
  NSUInteger i, n= 0;
  for (i= SESStart(_ses); i < _i; ) {
    SESIndexN(_ses, &i);
    ++n;
  }
  return n;
}
- (void)setScanLocation:(NSUInteger)index
{
  NSUInteger i;
  for (i= SESStart(_ses); index > 0 && i < SESEnd(_ses); ) {
    SESIndexN(_ses, &i);}
  _i= i;
}

- (NSString *)string
{ return _string; }
- (BOOL)isAtEnd
{ return _i == SESEnd(_ses); }

- (void)_skipIgnored
{
  NSUInteger i= _i;
  while (i < SESEnd(_ses) && [_charactersToBeSkipped characterIsMember:SESIndexN(_ses, &i)])
    _i= i;
}
- (BOOL)scanCharactersFromSet:(NSCharacterSet *)scanSet intoString:(NSString **)stringValue
{
  BOOL ret; unichar c; NSUInteger i= _i, l= _i;
  CString *str= stringValue ? CCreateString(0) : NULL;
  [self _skipIgnored];
  while (i < SESEnd(_ses) && [scanSet characterIsMember:(c= SESIndexN(_ses, &i))]) {
    CStringAppendCharacter(str, c);
    l= i;}
  if ((ret= l > _i)) {
    if (stringValue) {
      *stringValue= AUTORELEASE(str);}
    _i= l;}
  else
    RELEASE(str);
  return ret;
}
//- (BOOL)scanDecimal:(NSDecimal *)decimalValue;
//- (BOOL)scanDouble:(double *)doubleValue

- (BOOL)scanFloat:(float *)floatValue
{
  double d; BOOL ret;
  ret= [self scanDouble:&d];
  if (floatValue)
    *floatValue= (float)d;
  return ret;
}
- (BOOL)scanHexInt:(unsigned int *)intValue
{
  unichar c; long long v= 0; BOOL ret; NSUInteger i= _i, l= _i;
  [self _skipIgnored];
  if (i < SESEnd(_ses) && (c= SESIndexN(_ses, &i)) == (unichar)'0') {
    NSUInteger n= i;
    if (n < SESEnd(_ses) && ((c= SESIndexN(_ses, &n)) == (unichar)'x' || c == (unichar)'X')) {
      i= n;}}
  while (i < SESEnd(_ses) && CUnicharIsIsoDigit(c= SESIndexN(_ses, &i))) {
    v = v * 10 + (c - (unichar)'0');
    l= i;}
  if ((ret= l > _i)) {
    if (intValue)
      *intValue= v;
    _i= l;}
  return ret;
}
- (BOOL)scanDouble:(double *)doubleValue
{
  [self notImplemented:_cmd];
  return NO;
}
- (BOOL)scanInt:(int *)intValue
{
  long long i; BOOL ret;
  ret= [self scanLongLong:&i];
  if (intValue)
    *intValue= (int)i;
  return ret;
}
- (BOOL)scanLongLong:(long long *)longLongValue
{
  unichar c; long long v= 0; BOOL ret; NSUInteger i= _i, l= _i;
  [self _skipIgnored];
  while (i < SESEnd(_ses) && CUnicharIsIsoDigit(c= SESIndexN(_ses, &i))) {
    v = v * 10 + (c - (unichar)'0');
    l= i;}
  if ((ret= l > _i)) {
    if (longLongValue) {
      *longLongValue= v;}
    _i= l;}
  return ret;
}
- (BOOL)scanString:(NSString *)string intoString:(NSString **)stringValue
{
  BOOL ret; SES src, searched, fd;
  [self _skipIgnored];
  searched= SESFromString(string);
  src= _ses;
  SESSetStart(src, _i);
  fd= _caseInsensitive ? SESInsensitiveCommonPrefix(src, searched) : SESCommonPrefix(src, searched);
  if ((ret= SESOK(fd))) {
    if (stringValue) {
      *stringValue= AUTORELEASE(_caseInsensitive ? (id)CCreateStringWithSES(fd) : RETAIN(string));}
    _i += SESLength(fd);}
  return ret;
}
- (BOOL)scanUpToCharactersFromSet:(NSCharacterSet *)stopSet intoString:(NSString **)stringValue
{
  unichar c; BOOL ret; NSUInteger i= _i, l= _i;
  CString *str= stringValue ? CCreateString(0) : NULL;
  [self _skipIgnored];
  while (i < SESEnd(_ses) && ![stopSet characterIsMember:(c= SESIndexN(_ses, &i))]) {
    CStringAppendCharacter(str, c);
    l= i;}
  ;
  if ((ret= l > i)) {
    if(stringValue) {
      *stringValue= AUTORELEASE(str);}
      _i= l;}
  else
    RELEASE(str);
  return ret;
}
- (BOOL)scanUpToString:(NSString *)stopString intoString:(NSString **)stringValue
{
  BOOL ret; SES src, searched, fd;
  [self _skipIgnored];
  searched= SESFromString(stopString);
  src= _ses;
  SESSetStart(src, _i);
  fd= _caseInsensitive ? SESInsensitiveFind(src, searched) : SESFind(src, searched);
  if(!(ret= !SESOK(fd)) && (ret= SESStart(src) < SESStart(fd))) {
    SESSetEnd(src, SESStart(fd));}
  if (ret) {
    if (stringValue) {
      *stringValue= AUTORELEASE(CCreateStringWithSES(src));}
    _i= SESEnd(src);}
  return ret;
}
@end